// run with +UVM_TESTNAME=alu_random_test  or  +UVM_TESTNAME=alu_corner_test
module top;
  import uvm_pkg::*;
  import alu_pkg::*;
  logic clk = 0; always #5 clk = ~clk;
  alu_if bus (clk);
  small_alu dut (.clk(clk), .rst_n(bus.rst_n), .start(bus.start), .op(bus.op), .a(bus.a), .b(bus.b),
                 .done(bus.done), .result(bus.result));
  initial begin bus.rst_n = 0; #22 bus.rst_n = 1; end
  initial begin
    uvm_config_db #(virtual alu_if)::set(null, "*", "vif", bus);
    run_test();
  end
endmodule
