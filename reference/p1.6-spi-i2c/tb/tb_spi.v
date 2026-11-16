`timescale 1ns/1ps
// SPI master tasks + register model; 2,000 random reads/writes per mode.
module tb_spi;
  parameter CPOL = 0, CPHA = 0;
  localparam HALF = 80;                    // SCLK = 160 ns, clk = 10 ns (16x)
  reg clk = 0, rst_n = 0; always #5 clk = ~clk;
  reg sclk = CPOL, cs_n = 1, mosi = 0; wire miso; wire [63:0] regs_flat;
  spi_slave #(.CPOL(CPOL), .CPHA(CPHA)) dut (clk, rst_n, sclk, cs_n, mosi, miso, regs_flat);

  reg [7:0] model [0:127]; integer i, errors = 0, nrd = 0, nwr = 0;

  // one 16-bit transfer; returns the 8 bits read during the data phase
  task xfer(input [15:0] frame, output [7:0] rdata);
    integer b; begin
      cs_n = 0;
      for (b = 15; b >= 0; b = b - 1) begin
        if (CPHA == 0) begin
          mosi = frame[b]; #HALF;
          sclk = ~CPOL;                                 // leading edge: both sides sample
          if (b < 8) rdata[b] = miso;
          #HALF; sclk = CPOL;                           // trailing edge: both sides shift
        end else begin
          sclk = ~CPOL; mosi = frame[b]; #HALF;         // leading edge: shift
          sclk = CPOL;                                  // trailing edge: sample
          if (b < 8) rdata[b] = miso;
          #HALF;
        end
      end
      #HALF; cs_n = 1; #(2*HALF);
    end endtask
  task spi_write(input [6:0] a, input [7:0] d); reg [7:0] dummy; begin xfer({1'b0, a, d}, dummy); if (a < 7) model[a] = d; nwr = nwr + 1; end endtask
  task spi_read (input [6:0] a); reg [7:0] r; begin
    xfer({1'b1, a, 8'h00}, r); nrd = nrd + 1;
    if (r !== model[a]) begin errors = errors + 1; if (errors < 5) $display("ERR mode%0d%0d read a=%0d got %h exp %h", CPOL, CPHA, a, r, model[a]); end
  end endtask

  initial begin
    for (i = 0; i < 128; i = i + 1) model[i] = 0;
    model[7] = 8'hA5;
    #33 rst_n = 1; #100;
    spi_read(7);                                        // ID
    spi_write(7, 8'hFF); spi_read(7);                   // read-only stays A5
    spi_write(9, 8'h55); spi_read(9);                   // unmapped reads 0
    for (i = 0; i < 2000; i = i + 1)
      if ($random & 1) spi_write($random % 10 & 7'h7F, $random); else spi_read(($random & 7'h7F) % 10);
    for (i = 0; i < 8; i = i + 1) spi_read(i);
    $display("SPI mode %0d (CPOL=%0d CPHA=%0d): %0d writes %0d reads -> %s", CPOL*2+CPHA, CPOL, CPHA, nwr, nrd, errors ? "FAIL" : "PASS");
    $finish;
  end
endmodule
