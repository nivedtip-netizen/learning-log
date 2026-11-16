// All FIFO signals in one bundle. The clocking block gives the testbench a
// race-free view: inputs are sampled 1step before the edge, outputs are
// driven #1 after it, so TB and DUT never fight over the same timestep.
interface fifo_if import fifo_pkg::*; (input logic clk);
  logic  rst_n, push, pop, full, empty;
  data_t din, dout;
  logic [$clog2(DEPTH):0] count;

  clocking cb @(posedge clk);
    default input #1step output #1;
    output push, pop, din;
    input  dout, full, empty, count;
  endclocking

  modport dut (input clk, rst_n, push, pop, din, output dout, full, empty, count);
  modport tb  (clocking cb, output rst_n);
endinterface
