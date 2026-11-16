module tb_axil_sva;
  tb_axil tb ();
  bind axil_regs axil_sva chk (.*);
endmodule
