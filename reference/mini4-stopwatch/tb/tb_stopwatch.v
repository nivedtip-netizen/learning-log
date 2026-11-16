`timescale 1ns/1ps
// Self-checking TB: reference model counts seconds in the TB and compares every cycle.
module tb_stopwatch;
  localparam DIV = 4;
  reg clk = 0, rst_n = 0, ss = 0, clr = 0;
  wire [3:0] ones, tens; wire [6:0] so, st; wire [1:0] state;
  stopwatch #(.TICK_DIV(DIV)) dut (clk, rst_n, ss, clr, ones, tens, so, st, state);
  always #5 clk = ~clk;

  integer errors = 0, secs = 0, div = 0, mstate = 0, i;
  reg [6:0] lut [0:9];
  initial begin
    lut[0]=7'b1111110; lut[1]=7'b0110000; lut[2]=7'b1101101; lut[3]=7'b1111001; lut[4]=7'b0110011;
    lut[5]=7'b1011011; lut[6]=7'b1011111; lut[7]=7'b1110000; lut[8]=7'b1111111; lut[9]=7'b1111011;
  end
  // reference model, updated on the same edge as the DUT
  always @(posedge clk) if (rst_n) begin
    if (mstate == 1) begin
      if (div == DIV-1) begin div = 0; secs = (secs + 1) % 60; end else div = div + 1;
    end
    if (clr) begin mstate = 0; secs = 0; div = 0; end
    else if (ss) mstate = (mstate == 0) ? 1 : (mstate == 1) ? 2 : 1;
  end
  always @(negedge clk) if (rst_n) begin
    if (ones !== secs % 10 || tens !== secs / 10 || state !== mstate ||
        so !== lut[secs % 10] || st !== lut[secs / 10]) begin
      errors = errors + 1;
      if (errors < 5) $display("MISMATCH t=%0t dut=%0d%0d st=%0d model=%0d st=%0d", $time, tens, ones, state, secs, mstate);
    end
  end
  task pulse_ss;  begin @(posedge clk); #1 ss = 1;  @(posedge clk); #1 ss = 0;  end endtask
  task pulse_clr; begin @(posedge clk); #1 clr = 1; @(posedge clk); #1 clr = 0; end endtask
  initial begin
    $dumpfile("stopwatch.vcd"); $dumpvars(0, tb_stopwatch);
    #22 rst_n = 1;
    pulse_ss;                       // start
    repeat (DIV*75) @(posedge clk); // run past 59 -> wrap to 00
    pulse_ss;                       // pause
    repeat (30) @(posedge clk);
    pulse_ss;                       // resume
    repeat (DIV*7+2) @(posedge clk);
    pulse_clr;                      // clear while running
    repeat (10) @(posedge clk);
    for (i = 0; i < 300; i = i + 1) begin   // random button presses
      @(posedge clk); #1 ss = ($random % 23 == 0); clr = ($random % 97 == 0);
    end
    #1 ss = 0; clr = 0;
    repeat (5) @(posedge clk);
    if (errors == 0) $display("PASS"); else $display("FAIL errors=%0d", errors);
    $finish;
  end
endmodule
