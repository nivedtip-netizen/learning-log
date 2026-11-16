`timescale 1ns/1ps
// Glitch-free clock mux for two unrelated clocks.
// Each side has an enable flop chain clocked by its own clock (2-flop sync, then a
// negedge flop so the enable changes only while that clock is low). A side may turn
// on only after the other side's enable is off, so the output never sees a short pulse.
module clk_mux_gf (
  input  wire clk0, clk1, rst_n, sel,      // sel=0 -> clk0, sel=1 -> clk1 (sel may be async)
  output wire clk_out
);
  reg [1:0] s0; reg en0;
  reg [1:0] s1; reg en1;
  always @(posedge clk0 or negedge rst_n) if (!rst_n) s0 <= 2'b11; else s0 <= {s0[0], !sel && !en1};
  always @(negedge clk0 or negedge rst_n) if (!rst_n) en0 <= 1'b1; else en0 <= s0[1];
  always @(posedge clk1 or negedge rst_n) if (!rst_n) s1 <= 2'b00; else s1 <= {s1[0],  sel && !en0};
  always @(negedge clk1 or negedge rst_n) if (!rst_n) en1 <= 1'b0; else en1 <= s1[1];
  assign clk_out = (clk0 & en0) | (clk1 & en1);
endmodule
