// tb_counter.v  -  testbench: no ports, it drives and checks the counter
`timescale 1ns/1ps
module tb_counter;
  reg        clk   = 0;
  reg        rst_n = 0;          // start in reset
  reg        en    = 0;
  wire [3:0] count;

  // the design under test (DUT)
  counter dut (.clk(clk), .rst_n(rst_n), .en(en), .count(count));

  always #5 clk = ~clk;          // flips every 5 ns: a 10 ns (100 MHz) clock

  integer   errors   = 0;
  reg [3:0] expected = 0;        // what count should be

  initial begin
    $dumpfile("counter.vcd");    // waveform file for GTKWave
    $dumpvars(0, tb_counter);

    #12 rst_n = 1;               // leave reset between clock edges
    en = 1;

    repeat (20) begin            // 20 cycles: goes past 15 and wraps
      @(posedge clk); #1;        // wait for an edge, then let values settle
      expected = expected + 1;
      if (count !== expected) begin
        errors = errors + 1;
        $display("ERROR at %0t ns: count=%0d expected=%0d", $time, count, expected);
      end
    end

    en = 0;                      // disable: count must hold
    @(posedge clk); #1;
    if (count !== expected) begin
      errors = errors + 1;
      $display("ERROR: count changed while en=0");
    end

    if (errors == 0) $display("PASS");
    else             $display("FAIL: %0d errors", errors);
    $finish;
  end
endmodule
