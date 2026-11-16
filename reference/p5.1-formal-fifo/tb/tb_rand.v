`timescale 1ns/1ps
// Constrained-random simulation of sync_fifo, to compare against formal:
// RUNS short runs of LEN cycles, each from reset, push/pop each 50 %.
// A reference queue checks dout on every accepted pop and the count every cycle.
module tb_rand;
  parameter DEPTH = 4, RUNS = 1000, LEN = 20;
  localparam A = $clog2(DEPTH);
  reg clk = 0, rst_n = 0, push = 0, pop = 0; reg [7:0] din = 0;
  wire [7:0] dout; wire full, empty, af, ae, ovf, udf; wire [A:0] count;
  sync_fifo #(.W(8), .DEPTH(DEPTH), .AF(DEPTH-1), .AE(1)) dut (clk, rst_n, push, pop, din, dout, full, empty, af, ae, ovf, udf, count);
  always #5 clk = ~clk;

  reg [7:0] q [0:255]; integer head, tail, run, cyc, errors = 0, first_fail = -1, seed = 1, seed0; reg acc_pop, acc_push;
  initial begin
    if ($value$plusargs("SEED=%d", seed)) ;
    seed0 = seed;
    for (run = 0; run < RUNS && errors == 0; run = run + 1) begin
      rst_n = 0; push = 0; pop = 0; head = 0; tail = 0;
      @(negedge clk); @(negedge clk); rst_n = 1;
      for (cyc = 0; cyc < LEN; cyc = cyc + 1) begin
        push = $random(seed); pop = $random(seed); din = $random(seed);
        @(posedge clk);
        acc_pop  = pop  && (tail != head);           // both decided from the state before the edge
        acc_push = push && (tail - head) < DEPTH;
        if (acc_pop) begin
          if (dout !== q[head % 256]) begin errors = errors + 1; if (first_fail < 0) first_fail = run; end
          head = head + 1;
        end
        if (acc_push) begin q[tail % 256] = din; tail = tail + 1; end
        #1 if (count !== tail - head) begin
          errors = errors + 1; if (first_fail < 0) first_fail = run;
          $display("run %0d cycle %0d: count=%0d model=%0d", run, cyc, count, tail - head);
        end
        @(negedge clk);
      end
    end
    $display("runs=%0d len=%0d cycles=%0d", run, LEN, run * (LEN + 2));
    if (errors) $display("RESULT: FAIL errors=%0d first_failing_run=%0d seed=%0d", errors, first_fail, seed0);
    else        $display("RESULT: PASS errors=0 seed=%0d", seed0);
    $finish;
  end
endmodule
