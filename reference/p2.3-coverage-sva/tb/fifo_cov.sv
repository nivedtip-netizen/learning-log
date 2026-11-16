// Functional coverage for the FIFO (needs a simulator with covergroups:
// Riviera-PRO, Questa, VCS or Xcelium on EDA Playground).
module fifo_cov #(parameter int DEPTH = 16, A = $clog2(DEPTH)) (
  input logic clk, rst_n, push, pop, full, empty, input logic [A:0] count
);
  covergroup cg @(posedge clk iff rst_n);
    cp_count: coverpoint count {
      bins empty  = {0};
      bins one    = {1};
      bins mid    = {[2:DEPTH-2]};
      bins almost = {DEPTH-1};
      bins full   = {DEPTH};
    }
    cp_push:  coverpoint push;
    cp_pop:   coverpoint pop;
    cp_full:  coverpoint full;
    cp_empty: coverpoint empty;
    x_push_pop_full:  cross cp_push, cp_pop, cp_full;
    x_push_pop_empty: cross cp_push, cp_pop, cp_empty;
    cp_full_exit: coverpoint full { bins full_to_not = (1 => 0); bins not_to_full = (0 => 1); }
  endgroup
  cg cov = new();
  final $display("FIFO functional coverage = %0.2f%%", cov.get_coverage());
endmodule
