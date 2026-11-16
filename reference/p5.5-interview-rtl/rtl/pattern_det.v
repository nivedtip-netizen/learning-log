`timescale 1ns/1ps
// Overlapping detector for any fixed pattern, as a shift register + compare.
// (The FSM version is in P1.3; this is the one-line answer when the pattern is a parameter.)
module pattern_det #(parameter N = 5, parameter [N-1:0] PAT = 5'b10110) (
  input wire clk, rst_n, din, output wire hit
);
  reg [N-1:0] sh; reg [$clog2(N+1)-1:0] fill;          // ignore matches before N bits arrived
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin sh <= 0; fill <= 0; end
    else begin sh <= {sh[N-2:0], din}; if (fill != N) fill <= fill + 1'b1; end
  assign hit = (fill == N) && (sh == PAT);
endmodule
