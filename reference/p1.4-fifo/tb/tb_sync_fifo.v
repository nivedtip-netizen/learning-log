`timescale 1ns/1ps
// Random push/pop (with bursts that hit full and empty, including push+pop
// together at full and at empty) against a queue model kept in an array.
module tb_sync_fifo;
  localparam DEPTH = 8;
  reg clk = 0, rst_n = 0; always #5 clk = ~clk;
  reg push = 0, pop = 0; reg [7:0] din = 0;
  wire [7:0] dout; wire full, empty, af, ae, ovf, udf; wire [3:0] count;
  sync_fifo #(.W(8), .DEPTH(DEPTH), .AF(6), .AE(1)) dut (clk, rst_n, push, pop, din, dout, full, empty, af, ae, ovf, udf, count);

  reg [7:0] q [0:1023]; integer head = 0, tail = 0, n = 0;   // model
  integer errors = 0, i, pushes = 0, pops = 0, both_full = 0, both_empty = 0, ovfs = 0, udfs = 0, mode;
  reg exp_ovf = 0, exp_udf = 0;
  task err(input [8*32-1:0] m); begin errors = errors + 1; if (errors < 8) $display("ERR %0s t=%0t", m, $time); end endtask

  always @(negedge clk) if (rst_n) begin            // compare flags and data before the edge
    if (empty !== (n == 0)) err("empty");
    if (full  !== (n == DEPTH)) err("full");
    if (count !== n) err("count");
    if (af !== (n >= 6) || ae !== (n <= 1)) err("almost");
    if (n > 0 && dout !== q[head]) err("data");
    if (ovf !== exp_ovf || udf !== exp_udf) err("ovf/udf");
  end
  always @(posedge clk) if (rst_n) begin            // update the model with the DUT's rules
    exp_ovf = 0; exp_udf = 0;
    if (push && pop && n == DEPTH) both_full = both_full + 1;
    if (push && pop && n == 0)     both_empty = both_empty + 1;
    if (pop && n == 0) begin exp_udf = 1; udfs = udfs + 1; end
    if (push && n == DEPTH) begin exp_ovf = 1; ovfs = ovfs + 1; end
    if (pop && n > 0) begin head = (head + 1) % 1024; n = n - 1; pops = pops + 1; if (push && n + 1 < DEPTH) begin q[tail] = din; tail = (tail + 1) % 1024; n = n + 1; pushes = pushes + 1; end end
    else if (push && n < DEPTH) begin q[tail] = din; tail = (tail + 1) % 1024; n = n + 1; pushes = pushes + 1; end
  end
  initial begin
    #22 rst_n = 1;
    for (i = 0; i < 20000; i = i + 1) begin
      @(posedge clk); #1;
      mode = (i / 200) % 3;                         // phases: fill-biased, drain-biased, balanced
      push = (mode == 0) ? ($random % 5 != 0) : (mode == 1) ? ($random % 5 == 0) : $random;
      pop  = (mode == 0) ? ($random % 5 == 0) : (mode == 1) ? ($random % 5 != 0) : $random;
      din  = $random;
    end
    @(posedge clk); #1 push = 0; pop = 0; @(negedge clk);
    $display("pushes=%0d pops=%0d push+pop@full=%0d push+pop@empty=%0d overflows=%0d underflows=%0d",
             pushes, pops, both_full, both_empty, ovfs, udfs);
    if (errors == 0) $display("tb_sync_fifo PASS"); else $display("tb_sync_fifo FAIL errors=%0d", errors);
    $finish;
  end
endmodule
