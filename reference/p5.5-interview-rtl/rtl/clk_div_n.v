`timescale 1ns/1ps
// Divide by any N >= 2 with 50 % duty cycle.
// Even N: toggle every N/2 rising edges. Odd N: a posedge waveform high for (N+1)/2
// cycles, ORed with a copy delayed by half a cycle on the negedge (adds the missing half).
module clk_div_n #(parameter N = 5) (
  input wire clk, rst_n, output wire clk_out
);
  reg [$clog2(N)-1:0] cnt; reg p, n;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) cnt <= 0; else cnt <= (cnt == N-1) ? 0 : cnt + 1'b1;
  generate if (N % 2 == 0) begin : g_even
    always @(posedge clk or negedge rst_n)
      if (!rst_n) p <= 1'b0; else if (cnt == N/2-1 || cnt == N-1) p <= ~p;
    assign clk_out = p;
  end else begin : g_odd
    always @(posedge clk or negedge rst_n) if (!rst_n) p <= 1'b0; else p <= (cnt < (N-1)/2);   // high (N-1)/2 cycles
    always @(negedge clk or negedge rst_n) if (!rst_n) n <= 1'b0; else n <= p;
    assign clk_out = p | n;                                                                    // + half a cycle
  end endgenerate
endmodule
