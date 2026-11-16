`timescale 1ns/1ps
// 1) loopback: NBYTES random bytes, checked in order against a model queue
// 2) error injection on rxd: bad stop bit -> frame_err, bad parity -> parity_err
module tb_uart;
  parameter NBYTES = 10000;
  localparam DIV = 2, BIT_CLKS = 16 * DIV;
  reg clk = 0, rst_n = 0, loopback = 1, rxd = 1; always #5 clk = ~clk;
  reg tx_push = 0, rx_pop = 0; reg [7:0] tx_data = 0;
  wire tx_full, rx_empty, txd, ferr, perr, rovf; wire [7:0] rx_data;
  uart_top #(.DIVISOR(DIV), .PAR_EN(1), .PAR_ODD(0)) dut (clk, rst_n, loopback, tx_push, tx_data, tx_full,
                                                         rx_pop, rx_data, rx_empty, rxd, txd, ferr, perr, rovf);
  reg [7:0] q [0:NBYTES-1]; integer sent = 0, got = 0, errors = 0, nferr = 0, nperr = 0;
  always @(posedge clk) begin
    if (ferr) nferr = nferr + 1;
    if (perr) nperr = nperr + 1;
    if (rovf) begin errors = errors + 1; $display("ERR rx fifo overflow"); end
  end
  // driver: push whenever there is room; record only accepted bytes
  always @(posedge clk) if (rst_n && loopback) begin
    if (tx_push && !tx_full) begin q[sent] = tx_data; sent = sent + 1; end
    tx_push <= (sent < NBYTES);
    tx_data <= $random;
  end
  // checker: pop whenever data is waiting
  always @(posedge clk) if (rst_n) begin
    if (rx_pop && !rx_empty) begin
      if (loopback && rx_data !== q[got]) begin errors = errors + 1; if (errors < 5) $display("ERR byte %0d got %h exp %h", got, rx_data, q[got]); end
      got = got + 1;
    end
    rx_pop <= 1'b1;
  end
  task send_frame(input [7:0] d, input bad_par, input bad_stop);
    integer k; begin
      rxd = 0; repeat (BIT_CLKS) @(posedge clk);
      for (k = 0; k < 8; k = k + 1) begin rxd = d[k]; repeat (BIT_CLKS) @(posedge clk); end
      rxd = (^d) ^ bad_par;      repeat (BIT_CLKS) @(posedge clk);
      rxd = !bad_stop;           repeat (BIT_CLKS) @(posedge clk);
      rxd = 1;                   repeat (2*BIT_CLKS) @(posedge clk);
    end endtask
  integer f0, p0, g0;
  initial begin
    #23 rst_n = 1;
    wait (got == NBYTES);
    $display("loopback: %0d bytes sent, %0d received, %0d data errors", sent, got, errors);
    if (nferr || nperr) begin errors = errors + 1; $display("ERR spurious error flags"); end
    // ---- error injection ----
    loopback = 0; repeat (100) @(posedge clk);
    f0 = nferr; p0 = nperr; g0 = got;
    send_frame(8'h5A, 0, 0); if (nferr != f0 || nperr != p0 || got != g0 + 1) begin errors = errors + 1; $display("ERR good frame"); end
    send_frame(8'hC3, 0, 1); if (nferr != f0 + 1)                          begin errors = errors + 1; $display("ERR bad stop not flagged"); end
    send_frame(8'h3C, 1, 0); if (nperr != p0 + 1)                          begin errors = errors + 1; $display("ERR bad parity not flagged"); end
    // glitch shorter than half a bit must not start a frame
    rxd = 0; repeat (BIT_CLKS/4) @(posedge clk); rxd = 1; repeat (3*BIT_CLKS*11) @(posedge clk);
    if (got != g0 + 2) begin errors = errors + 1; $display("ERR glitch or frame count (got %0d)", got - g0); end
    $display("error injection: frame_err=%0d parity_err=%0d (expect 1 1)", nferr - f0, nperr - p0);
    if (errors == 0) $display("tb_uart PASS"); else $display("tb_uart FAIL errors=%0d", errors);
    $finish;
  end
endmodule
