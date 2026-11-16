module tb_core_sva;
  tb_core tb ();
  bind rv32i_pipe core_sva chk (.*);
endmodule
