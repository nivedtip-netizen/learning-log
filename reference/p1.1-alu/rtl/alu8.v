// 8-bit ALU with Z/N/C/V flags.
//  C: ADD = carry out of bit 7; SUB = borrow (a < b unsigned); other ops 0.
//  V: signed overflow, only meaningful for ADD/SUB; other ops 0.
//  Shift amount = b[2:0].
module alu8 (
  input  wire [7:0] a, b,
  input  wire [3:0] op,
  output reg  [7:0] y,
  output wire       z, n,
  output reg        c, v
);
  localparam ADD=4'd0, SUB=4'd1, AND_=4'd2, OR_=4'd3, XOR_=4'd4,
             SLT=4'd5, SLL=4'd6, SRL=4'd7, SRA=4'd8;
  // one shared adder: a + ~b + 1 for SUB
  wire       is_sub = (op == SUB) || (op == SLT);
  wire [7:0] bb     = is_sub ? ~b : b;
  wire [8:0] sum    = {1'b0, a} + {1'b0, bb} + {8'b0, is_sub};
  wire       ovf    = (a[7] == bb[7]) && (sum[7] != a[7]);
  always @(*) begin
    y = 8'h00; c = 1'b0; v = 1'b0;
    case (op)
      ADD:  begin y = sum[7:0]; c = sum[8];  v = ovf; end
      SUB:  begin y = sum[7:0]; c = ~sum[8]; v = ovf; end  // borrow = no carry out
      AND_: y = a & b;
      OR_:  y = a | b;
      XOR_: y = a ^ b;
      SLT:  y = {7'b0, sum[7] ^ ovf};                       // signed a < b
      SLL:  y = a << b[2:0];
      SRL:  y = a >> b[2:0];
      SRA:  y = $signed(a) >>> b[2:0];
      default: y = 8'h00;
    endcase
  end
  assign z = (y == 8'h00);
  assign n = y[7];
endmodule
