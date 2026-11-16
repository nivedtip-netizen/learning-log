`timescale 1ns/1ps
// Processing element of an output-stationary systolic array.
// Each cycle: acc += a_in * b_in (signed INT8 x INT8 -> INT32), pass a right, b down.
// PIPE_MUL=1 registers the product first: one more cycle of latency, shorter critical path.
module pe #(parameter PIPE_MUL = 0) (
  input  wire              clk, rst_n, clear,
  input  wire signed [7:0] a_in, b_in,
  output reg  signed [7:0] a_out, b_out,
  output reg  signed [31:0] acc
);
  wire signed [15:0] prod = a_in * b_in;
  wire signed [15:0] prod_use;
  generate if (PIPE_MUL) begin : g_pipe
    reg signed [15:0] prod_q;
    always @(posedge clk or negedge rst_n)
      if (!rst_n) prod_q <= 16'sd0; else prod_q <= clear ? 16'sd0 : prod;
    assign prod_use = prod_q;
  end else begin : g_comb
    assign prod_use = prod;
  end endgenerate

  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin a_out <= 8'sd0; b_out <= 8'sd0; acc <= 32'sd0; end
    else begin
      a_out <= a_in;
      b_out <= b_in;
      acc   <= clear ? 32'sd0 : acc + {{16{prod_use[15]}}, prod_use};
    end
endmodule
