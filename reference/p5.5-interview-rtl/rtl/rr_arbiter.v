`timescale 1ns/1ps
// Round-robin arbiter, N requesters, one-hot grant, registered pointer.
// Priority starts just after the last winner: no requester can starve.
// Trick: double the request vector, mask off everything below the pointer,
// and pick the lowest set bit with x & -x.
module rr_arbiter #(parameter N = 4) (
  input  wire         clk, rst_n,
  input  wire [N-1:0] req,
  output wire [N-1:0] gnt
);
  reg  [N-1:0]   ptr;                                   // one-hot: highest priority this cycle
  wire [2*N-1:0] dreq  = {req, req};
  wire [2*N-1:0] dmask = dreq & ~({{N{1'b0}}, ptr} - 1'b1);   // keep bits at/after ptr
  wire [2*N-1:0] dgnt  = dmask & (~dmask + 1'b1);       // lowest set bit
  assign gnt = dgnt[N-1:0] | dgnt[2*N-1:N];
  always @(posedge clk or negedge rst_n)
    if (!rst_n) ptr <= {{N-1{1'b0}}, 1'b1};
    else if (|req) ptr <= {gnt[N-2:0], gnt[N-1]};       // next priority = one after the winner
endmodule
