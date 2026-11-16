// Wrapper: the Verilog testbench plus the bound protocol checker.
module tb_apb_sva;
  tb_apb #(.WAIT(2)) tb ();
  bind apb_regs apb_sva chk (.*);
endmodule
