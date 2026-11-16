`timescale 1ns/1ps
// GLS shim: the netlist has no parameters (they were fixed at synthesis), but the
// RTL testbench still passes them. This wrapper keeps the testbench unchanged and
// stops the run if the testbench asks for values the netlist was not built with.
module uart_top #(parameter DIVISOR = 2, PAR_EN = 1, PAR_ODD = 0, DEPTH = 16) (
  input  wire clk, rst_n, loopback,
  input  wire tx_push, input wire [7:0] tx_data, output wire tx_full,
  input  wire rx_pop,  output wire [7:0] rx_data, output wire rx_empty,
  input  wire rxd, output wire txd,
  output wire frame_err, parity_err, rx_overflow
);
  initial if (DIVISOR != 2 || PAR_EN != 1 || PAR_ODD != 0 || DEPTH != 16) begin
    $display("GLS shim: netlist built for DIVISOR=2 PAR_EN=1 PAR_ODD=0 DEPTH=16"); $finish;
  end
  uart_top_gl gl (.clk(clk), .rst_n(rst_n), .loopback(loopback), .tx_push(tx_push), .tx_data(tx_data), .tx_full(tx_full),
                  .rx_pop(rx_pop), .rx_data(rx_data), .rx_empty(rx_empty), .rxd(rxd), .txd(txd),
                  .frame_err(frame_err), .parity_err(parity_err), .rx_overflow(rx_overflow));
endmodule
