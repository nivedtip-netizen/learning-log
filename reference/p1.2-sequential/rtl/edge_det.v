// sig must already be synchronous to clk
module edge_det (input wire clk, rst_n, sig, output wire rise, fall, any);
  reg prev;
  always @(posedge clk or negedge rst_n) if (!rst_n) prev <= 1'b0; else prev <= sig;
  assign rise = sig & ~prev;
  assign fall = ~sig & prev;
  assign any  = sig ^ prev;
endmodule
