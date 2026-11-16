`timescale 1ns/1ps
// TX FIFO -> TX -> line -> RX -> RX FIFO. 'loopback' ties the line inside.
module uart_top #(parameter DIVISOR = 27, PAR_EN = 1, PAR_ODD = 0, DEPTH = 16) (
  input  wire clk, rst_n, loopback,
  input  wire tx_push, input wire [7:0] tx_data, output wire tx_full,
  input  wire rx_pop,  output wire [7:0] rx_data, output wire rx_empty,
  input  wire rxd, output wire txd,
  output wire frame_err, parity_err, rx_overflow
);
  wire tick; baud_gen #(DIVISOR) u_baud (clk, rst_n, tick);
  wire [7:0] tf_dout; wire tf_empty, busy;
  wire tf_pop = !tf_empty && !busy;
  sync_fifo #(.W(8), .DEPTH(DEPTH)) u_txf (.clk(clk), .rst_n(rst_n), .push(tx_push), .pop(tf_pop), .din(tx_data),
    .dout(tf_dout), .full(tx_full), .empty(tf_empty), .almost_full(), .almost_empty(), .overflow(), .underflow(), .count());
  uart_tx #(PAR_EN, PAR_ODD) u_tx (clk, rst_n, tick, tf_pop, tf_dout, txd, busy);
  wire [7:0] rdata; wire rvalid;
  uart_rx #(PAR_EN, PAR_ODD) u_rx (clk, rst_n, tick, loopback ? txd : rxd, rdata, rvalid, frame_err, parity_err);
  sync_fifo #(.W(8), .DEPTH(DEPTH)) u_rxf (.clk(clk), .rst_n(rst_n), .push(rvalid && !frame_err), .pop(rx_pop), .din(rdata),
    .dout(rx_data), .full(), .empty(rx_empty), .almost_full(), .almost_empty(), .overflow(rx_overflow), .underflow(), .count());
endmodule
