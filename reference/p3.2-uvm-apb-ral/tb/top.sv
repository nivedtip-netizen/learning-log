// Tests: apb_reset_test apb_bitbash_test apb_random_test apb_w1c_test apb_bad_addr_test apb_wait_stress_test
// Example (Questa): vlog -f files.f; vsim -c top +UVM_TESTNAME=apb_random_test -sv_seed 7 -do "run -all; quit"
module top;
  import uvm_pkg::*;
  import apb_uvm_pkg::*;
  logic pclk = 0; always #5 pclk = ~pclk;
  apb_if bus (pclk);
`ifdef WAIT
  localparam int WS = `WAIT;
`else
  localparam int WS = 1;
`endif
  apb_regs #(.WAIT_STATES(WS)) dut (
    .pclk(pclk), .presetn(bus.presetn), .psel(bus.psel), .penable(bus.penable), .pwrite(bus.pwrite),
    .paddr(bus.paddr), .pwdata(bus.pwdata), .pstrb(bus.pstrb), .prdata(bus.prdata), .pready(bus.pready),
    .pslverr(bus.pslverr), .hw_status(bus.hw_status), .hw_event(bus.hw_event), .irq(),
    .cmd_valid(), .cmd_data(), .ctrl_o());
  bind apb_regs apb_sva chk (.*);
  initial begin
    bus.presetn = 0; bus.hw_status = 32'h0; bus.hw_event = 32'h0;
    #22 bus.presetn = 1;
  end
  initial begin
    uvm_config_db #(virtual apb_if)::set(null, "uvm_test_top", "vif", bus);
    run_test();
  end
endmodule
