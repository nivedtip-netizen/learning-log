`timescale 1ns/1ps
// 2-flop synchronizer for a bus. With +define+META the first flop models
// metastability: a bit that changed less than WIN_NS before the capturing edge
// resolves randomly to its old or new value. Gray-coded buses survive this
// (only one bit moves); binary buses do not, which is the point of step 5.
module sync2 #(parameter W = 5) (input wire clk, rst_n, input wire [W-1:0] d, output reg [W-1:0] q);
  reg [W-1:0] s1;
`ifdef META
  localparam real WIN_NS = 4.0;   // wide window so the simulation hits it often
  reg [W-1:0] d_last, d_prev; real t_chg [0:W-1]; integer i;
  initial begin d_last = 0; d_prev = 0; for (i = 0; i < W; i = i + 1) t_chg[i] = -100.0; end
  always @(d) begin                       // remember when each bit moved and what it was
    for (i = 0; i < W; i = i + 1)
      if (d[i] !== d_last[i]) begin d_prev[i] = d_last[i]; t_chg[i] = $realtime; end
    d_last = d;
  end
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin s1 <= 0; q <= 0; end
    else begin
      for (i = 0; i < W; i = i + 1)
        s1[i] <= ($realtime - t_chg[i] < WIN_NS && ($random & 1)) ? d_prev[i] : d[i];
      q <= s1;
    end
`else
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin s1 <= 0; q <= 0; end
    else begin s1 <= d; q <= s1; end
`endif
endmodule
