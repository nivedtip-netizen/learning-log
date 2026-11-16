`timescale 1ns/1ps
// 32 x 32 register file, 2 read ports, 1 write port, x0 reads 0 and ignores writes.
// BYPASS=1 (pipeline): write-through, a read of the register being written this
// cycle returns the new value, so the pipeline needs no WB->ID forwarding path.
// BYPASS=0 (single-cycle): must be 0 there, or 'addi x1, x1, 1' becomes a
// combinational loop (rd1 -> ALU -> wd -> rd1). Found the hard way: the sim hung.
module rv_regfile #(parameter BYPASS = 0) (
  input  wire        clk,
  input  wire [4:0]  ra1, ra2, wa,
  input  wire        we,
  input  wire [31:0] wd,
  output wire [31:0] rd1, rd2
);
  reg [31:0] r [1:31];
  always @(posedge clk) if (we && wa != 5'd0) r[wa] <= wd;
  assign rd1 = (ra1 == 5'd0) ? 32'h0 : (BYPASS && we && wa == ra1) ? wd : r[ra1];
  assign rd2 = (ra2 == 5'd0) ? 32'h0 : (BYPASS && we && wa == ra2) ? wd : r[ra2];
endmodule
