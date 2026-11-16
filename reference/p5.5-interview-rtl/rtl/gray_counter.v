`timescale 1ns/1ps
// Gray-code counter: keep a binary register, output its Gray code from a register
// (no glitches on the output, exactly one bit changes per count).
module gray_counter #(parameter N = 4) (
  input wire clk, rst_n, en, output reg [N-1:0] gray
);
  reg  [N-1:0] bin;
  wire [N-1:0] bin_n = bin + 1'b1;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin bin <= 0; gray <= 0; end
    else if (en) begin bin <= bin_n; gray <= bin_n ^ (bin_n >> 1); end
endmodule
