`timescale 1ns/1ps
`include "rv_defs.vh"
// 32-bit ALU: the P1.1 ALU grown to RV32I width (no flags: branches use rv_branch).
module rv_alu (input wire [31:0] a, b, input wire [3:0] op, output reg [31:0] y);
  always @(*) case (op)
    `ALU_ADD:  y = a + b;
    `ALU_SUB:  y = a - b;
    `ALU_SLL:  y = a << b[4:0];
    `ALU_SLT:  y = {31'b0, $signed(a) < $signed(b)};
    `ALU_SLTU: y = {31'b0, a < b};
    `ALU_XOR:  y = a ^ b;
    `ALU_SRL:  y = a >> b[4:0];
    `ALU_SRA:  y = $signed(a) >>> b[4:0];
    `ALU_OR:   y = a | b;
    `ALU_AND:  y = a & b;
    default:   y = 32'h0;
  endcase
endmodule
