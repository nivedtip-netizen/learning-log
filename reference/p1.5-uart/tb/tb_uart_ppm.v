`timescale 1ns/1ps
// Two separate UARTs: A transmits on clk_a, B receives on clk_b, whose period differs by PCT %.
module tb_uart_ppm;
  parameter real PCT = 2.0;
  parameter NBYTES = 2000;
  localparam DIV = 2;
  real pa = 10.0, pb = 10.0 * (1.0 + PCT/100.0);
  reg ca = 0, cb = 0, rst_n = 0; always #(pa/2) ca = ~ca; always #(pb/2) cb = ~cb;
  reg push = 0, pop = 0; reg [7:0] din = 0; wire full, empty, line; wire [7:0] dout;
  wire fa, pa_, oa, fb, pb_, ob, txb, ea; wire [7:0] da;
  uart_top #(.DIVISOR(DIV)) A (ca, rst_n, 1'b0, push, din, full, 1'b0, da, ea, 1'b1, line, fa, pa_, oa);
  uart_top #(.DIVISOR(DIV)) B (cb, rst_n, 1'b0, 1'b0, 8'h00, , pop, dout, empty, line, txb, fb, pb_, ob);
  reg [7:0] q [0:NBYTES-1]; integer sent = 0, got = 0, errors = 0;
  always @(posedge ca) if (rst_n) begin
    if (push && !full) begin q[sent] = din; sent = sent + 1; end
    push <= (sent < NBYTES);
    din  <= $random;
  end
  always @(posedge cb) if (rst_n) begin
    if (pop && !empty) begin if (dout !== q[got]) errors = errors + 1; got = got + 1; end
    pop <= 1;
    if (fb || pb_) errors = errors + 1;
  end
  initial begin
    #40 rst_n = 1;
    fork wait (got == NBYTES); #20000000; join_any
    $display("RX clock %+0.1f%%: sent=%0d received=%0d errors=%0d -> %s", PCT, sent, got, errors,
             (errors == 0 && got == NBYTES) ? "PASS" : "FAIL");
    $finish;
  end
endmodule
