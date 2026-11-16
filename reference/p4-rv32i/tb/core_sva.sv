// Core assertions (P4.4), bound to rv32i_pipe. Runs on Verilator 5.020+.
module core_sva (
  input logic clk, rst_n, halted, stall, flush,
  input logic ret_valid, input logic [31:0] ret_pc, ret_rd_wdata, input logic [4:0] ret_rd,
  input logic [31:0] imem_addr
);
  // x0 is never reported as written with a non-zero value
  a_x0_never_written: assert property (@(posedge clk) disable iff (!rst_n)
      ret_valid && ret_rd == 5'd0 |-> ret_rd_wdata == 32'h0)
    else $error("x0 written");
  // instruction addresses stay 4-byte aligned (no compressed instructions)
  a_pc_aligned: assert property (@(posedge clk) disable iff (!rst_n) imem_addr[1:0] == 2'b00)
    else $error("PC not aligned: %h", imem_addr);
  a_ret_pc_aligned: assert property (@(posedge clk) disable iff (!rst_n) ret_valid |-> ret_pc[1:0] == 2'b00)
    else $error("retired PC not aligned");
  // a load-use stall and a branch flush can never happen in the same cycle
  // (the stall needs a load in EX, the flush needs a branch/jump in EX)
  a_no_stall_and_flush: assert property (@(posedge clk) disable iff (!rst_n) !(stall && flush))
    else $error("stall and flush together");
  // nothing retires after the core halts
  a_quiet_after_halt: assert property (@(posedge clk) disable iff (!rst_n) halted |-> !ret_valid)
    else $error("retired after halt");
endmodule
