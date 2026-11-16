`timescale 1ns/1ps
// One-cycle tick at 16x the baud rate: tick every DIVISOR clocks.
// e.g. 50 MHz, 115200 baud: DIVISOR = 50e6 / (16*115200) ~= 27
module baud_gen #(parameter DIVISOR = 27) (input wire clk, rst_n, output wire tick);
  localparam CW = (DIVISOR > 1) ? $clog2(DIVISOR) : 1;
  reg [CW-1:0] cnt;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) cnt <= 0;
    else        cnt <= (cnt == DIVISOR-1) ? {CW{1'b0}} : cnt + 1'b1;
  assign tick = (cnt == DIVISOR-1);
endmodule
