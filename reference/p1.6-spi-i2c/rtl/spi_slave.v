`timescale 1ns/1ps
// SPI slave with an 8 x 8-bit register map. Frame (MSB first, 16 bits):
//   bit 15 = R/W (1 = read), bits 14:8 = address (7 bits), bits 7:0 = data.
// Registers 0-6 are read/write, register 7 is a read-only ID (0xA5).
// Addresses 8-127 read as 0 and ignore writes.
// SCLK/CS_n/MOSI are synchronized into clk, so clk must be >= ~8x SCLK.
// CPOL = idle level of SCLK. CPHA = 0: sample on the leading edge, shift on the
// trailing edge (first MISO bit set up early). CPHA = 1: shift on leading, sample on trailing.
module spi_slave #(parameter CPOL = 0, CPHA = 0) (
  input  wire clk, rst_n,
  input  wire sclk, cs_n, mosi,
  output wire miso,
  output wire [63:0] regs_flat           // for observation / the rest of the chip
);
  reg [2:0] s_sclk, s_cs, s_mosi;         // 2 sync flops + 1 history flop
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin s_sclk <= {3{CPOL[0]}}; s_cs <= 3'b111; s_mosi <= 0; end
    else begin s_sclk <= {s_sclk[1:0], sclk}; s_cs <= {s_cs[1:0], cs_n}; s_mosi <= {s_mosi[1:0], mosi}; end
  wire sclk_rise = s_sclk[1] & ~s_sclk[2];
  wire sclk_fall = ~s_sclk[1] & s_sclk[2];
  wire active    = ~s_cs[1];
  wire leading   = CPOL ? sclk_fall : sclk_rise;
  wire trailing  = CPOL ? sclk_rise : sclk_fall;
  wire sample_e  = active & (CPHA ? trailing : leading);
  wire shift_e   = active & (CPHA ? leading  : trailing);

  reg [7:0] regs [0:7];
  reg [15:0] rx; reg [4:0] cnt; reg [7:0] tx; reg out_bit;
  wire [7:0] addr = {1'b0, rx[6:0]};      // valid once 8 bits are in
  wire       rd   = rx[7];

  wire [7:0] rd_val = (addr == 8'd7) ? 8'hA5 : (addr < 8'd7) ? regs[addr[2:0]] : 8'h00;
  // on the 16th sample rx[14:0] holds R/W, address and data[7:1]; the new bit is data[0]
  wire       wr_commit = sample_e && cnt == 5'd15 && !rx[14] && rx[13:7] < 7'd7;

  integer i;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      for (i = 0; i < 8; i = i + 1) regs[i] <= 8'h00;
      rx <= 0; cnt <= 0; tx <= 0; out_bit <= 0;
    end else if (!active) begin cnt <= 0; out_bit <= 0; end
    else begin
      if (sample_e) begin
        rx  <= {rx[14:0], s_mosi[1]};
        cnt <= cnt + 1'b1;
      end
      if (wr_commit) regs[rx[9:7]] <= {rx[6:0], s_mosi[1]};
      if (shift_e) begin
        if (cnt == 5'd8) begin                   // header complete: load read data, drive its MSB
          tx      <= rd ? rd_val : 8'h00;
          out_bit <= rd & rd_val[7];
        end else if (cnt > 5'd8) begin
          tx      <= {tx[6:0], 1'b0};
          out_bit <= tx[6];
        end
      end
    end
  assign miso = cs_n ? 1'bz : out_bit;
  genvar g; generate for (g = 0; g < 8; g = g + 1) begin : g_flat
    assign regs_flat[g*8 +: 8] = (g == 7) ? 8'hA5 : regs[g];
  end endgenerate
endmodule
