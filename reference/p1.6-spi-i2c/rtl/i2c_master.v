`timescale 1ns/1ps
// I2C master for a 24xx-style EEPROM: byte write and random read (7-bit device address).
//   write: S | dev+W | A | mem_addr | A | data | A | P
//   read : S | dev+W | A | mem_addr | A | Sr | dev+R | A | data | NACK | P
// Open drain: scl_oe / sda_oe = 1 pulls the line low; 0 releases it (pull-up makes 1).
// Each bit is 4 quarter-periods of QDIV clocks: SCL low, low, high (sample), high.
// If the slave NACKs any byte, the transfer stops with a STOP and 'nack' is set.
// No clock stretching or multi-master arbitration (documented limitation).
module i2c_master #(parameter QDIV = 4) (
  input  wire       clk, rst_n,
  input  wire       start, rw,            // rw: 1 = read
  input  wire [6:0] dev,
  input  wire [7:0] mem_addr, wdata,
  output reg  [7:0] rdata,
  output reg        busy, done, nack,
  output reg        scl_oe, sda_oe,
  input  wire       scl_in,             // unused: no clock stretching (see header)
  input  wire       sda_in
);
  localparam IDLE = 3'd0, S_START = 3'd1, S_BYTE = 3'd2, S_RSTART = 3'd3, S_STOP = 3'd4;
  reg [2:0]  st;
  reg [1:0]  q;                           // quarter within a bit
  reg [$clog2(QDIV)-1:0] div;
  reg [3:0]  bitn;                        // 0..7 data, 8 = ack slot
  reg [7:0]  sh;
  reg [1:0]  idx;                         // which byte of the sequence
  reg        is_read, got_nack;
  wire qtick = ({{(32-$clog2(QDIV)){1'b0}}, div} == QDIV-1);

  // byte sequence for this transfer
  wire [7:0] byte_out = (idx == 2'd0) ? {dev, 1'b0} : (idx == 2'd1) ? mem_addr :
                        (idx == 2'd2) ? (is_read ? {dev, 1'b1} : wdata) : 8'hFF;
  wire last_byte = is_read ? (idx == 2'd3) : (idx == 2'd2);
  wire receiving = is_read && (idx == 2'd3);

  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      st <= IDLE; q <= 0; div <= 0; bitn <= 0; sh <= 0; idx <= 0; is_read <= 0;
      rdata <= 0; busy <= 0; done <= 0; nack <= 0; scl_oe <= 0; sda_oe <= 0; got_nack <= 0;
    end else begin
      done <= 1'b0;
      div  <= (st == IDLE || qtick) ? 0 : div + 1'b1;
      case (st)
        IDLE: if (start) begin
                busy <= 1; nack <= 0; got_nack <= 0; is_read <= rw; idx <= 0; q <= 0;
                st <= S_START; scl_oe <= 0; sda_oe <= 0;
              end
        S_START: if (qtick) begin                 // SDA falls while SCL high, then SCL low
                q <= q + 1'b1;
                case (q)
                  2'd0: begin scl_oe <= 0; sda_oe <= 0; end
                  2'd1: sda_oe <= 1;              // START
                  2'd2: scl_oe <= 1;
                  2'd3: begin st <= S_BYTE; bitn <= 0; sh <= byte_out; end
                endcase
              end
        S_RSTART: if (qtick) begin                // SCL low: release SDA, raise SCL, pull SDA low
                q <= q + 1'b1;
                case (q)
                  2'd0: sda_oe <= 0;
                  2'd1: scl_oe <= 0;
                  2'd2: sda_oe <= 1;              // repeated START
                  2'd3: begin scl_oe <= 1; st <= S_BYTE; bitn <= 0; sh <= byte_out; end
                endcase
              end
        S_BYTE: if (qtick) begin
                q <= q + 1'b1;
                case (q)
                  2'd0: begin                     // SCL low: put the bit on SDA
                          scl_oe <= 1;
                          if (bitn < 8) sda_oe <= receiving ? 1'b0 : ~sh[7];
                          else          sda_oe <= receiving ? 1'b0 : 1'b0;   // ack slot: master releases (NACK when receiving)
                        end
                  2'd1: ;
                  2'd2: scl_oe <= 0;              // SCL rises
                  2'd3: begin                     // SCL high: sample
                          if (bitn < 8) begin
                            if (receiving) rdata <= {rdata[6:0], sda_in};
                            sh <= {sh[6:0], 1'b0};
                            bitn <= bitn + 1'b1;
                          end else begin          // ack slot done
                            scl_oe <= 1;
                            if (!receiving && sda_in) begin got_nack <= 1; st <= S_STOP; end
                            else if (last_byte) st <= S_STOP;
                            else if (is_read && idx == 2'd1) begin idx <= 2'd2; st <= S_RSTART; end
                            else begin idx <= idx + 1'b1; st <= S_BYTE; bitn <= 0; end
                          end
                        end
                endcase
                if (q == 2'd3 && bitn == 4'd8 && !(!receiving && sda_in) && !last_byte && !(is_read && idx == 2'd1))
                  sh <= (idx == 2'd0) ? mem_addr : (is_read ? {dev, 1'b1} : wdata);
              end
        S_STOP: if (qtick) begin                  // SCL low with SDA low, SCL high, SDA high
                q <= q + 1'b1;
                case (q)
                  2'd0: begin scl_oe <= 1; sda_oe <= 1; end
                  2'd1: scl_oe <= 0;
                  2'd2: sda_oe <= 0;              // STOP
                  2'd3: begin st <= IDLE; busy <= 0; done <= 1; nack <= got_nack; end
                endcase
              end
        default: st <= IDLE;
      endcase
    end
endmodule
