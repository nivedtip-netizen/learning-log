`timescale 1ns/1ps
// Counting pattern written on wclk, read on rclk; every word must arrive once and in order.
// Run with +define+META to model metastability in the synchronizers.
module tb_async_fifo;
  parameter real WPER = 10.0, RPER = 27.0;   // overridden per run with -P
  parameter BUG_BIN = 0;
  reg wclk = 0, rclk = 0, wrst_n = 0, rrst_n = 0;
  always #(WPER/2) wclk = ~wclk;
  always #(RPER/2) rclk = ~rclk;
  reg push = 0, pop = 0; reg [7:0] din = 0; wire [7:0] dout; wire full, empty; wire [3:0] rcount;
  async_fifo #(.W(8), .DEPTH(8), .BUG_BIN(BUG_BIN)) dut (wclk, wrst_n, push, din, full, rclk, rrst_n, pop, dout, empty, rcount);

  localparam N = 5000;
  integer sent = 0, got = 0, errors = 0;
  reg [7:0] exp_d = 0;
  always @(posedge wclk) if (wrst_n) begin
    if (push && !full) begin sent = sent + 1; din <= din + 1; end
    push <= (sent < N) && ($random % 4 != 0);
  end
  // invariant: the read side may under-estimate the fill level (late), never over-estimate it
  integer bad_level = 0;
  always @(negedge rclk) if (rrst_n && rcount > dut.wbin - dut.rbin) begin
    bad_level = bad_level + 1; errors = errors + 1;
    if (bad_level < 4) $display("ERR read side sees %0d words, only %0d exist", rcount, (dut.wbin - dut.rbin) & 15);
  end
  always @(posedge rclk) if (rrst_n) begin
    if (pop && !empty) begin
      if (dout !== exp_d) begin errors = errors + 1; if (errors < 5) $display("ERR got %0d expected %0d", dout, exp_d); end
      exp_d = dout + 1; got = got + 1;          // resync so one loss is counted once
    end
    pop <= ($random % 3 != 0);
  end
  initial begin
    #3 wrst_n = 0; rrst_n = 0;            // a real edge, after both clocks start
    #(3*WPER + 3*RPER) wrst_n = 1; #7 rrst_n = 1;
    fork
      wait (got == N);
      #2000000;                                   // timeout if words were lost
    join_any
    if (got != N) errors = errors + 1;
    $display("wclk=%0.1fns rclk=%0.1fns BUG_BIN=%0d: sent=%0d received=%0d errors=%0d -> %s",
             WPER, RPER, BUG_BIN, sent, got, errors, errors ? "FAIL" : "PASS");
    $finish;
  end
endmodule
