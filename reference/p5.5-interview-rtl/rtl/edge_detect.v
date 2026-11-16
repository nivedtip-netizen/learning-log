`timescale 1ns/1ps
// Rising, falling and any-edge pulses for a signal already in this clock domain.
module edge_detect (
  input wire clk, rst_n, d, output wire rise, fall, any
);
  reg q;
  always @(posedge clk or negedge rst_n) if (!rst_n) q <= 1'b0; else q <= d;
  assign rise = d & ~q;
  assign fall = ~d & q;
  assign any  = d ^ q;
endmodule
