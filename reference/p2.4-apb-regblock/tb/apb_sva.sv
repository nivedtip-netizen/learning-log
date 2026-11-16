// APB protocol assertions, bound to the slave. Runs on Verilator 5.020+ and commercial simulators.
module apb_sva (
  input logic pclk, presetn, psel, penable, pwrite, pready, pslverr,
  input logic [7:0] paddr, input logic [31:0] pwdata
);
  // PENABLE rises only in the cycle after a setup phase (PSEL high, PENABLE low)
  a_setup_before_access: assert property (@(posedge pclk) disable iff (!presetn)
      $rose(penable) |-> $past(psel) && !$past(penable))
    else $error("PENABLE without a setup phase");
  // while the slave holds PREADY low, the master keeps address, direction and data
  a_stable_in_wait: assert property (@(posedge pclk) disable iff (!presetn)
      psel && penable && !pready |=> $stable(paddr) && $stable(pwdata) && $stable(pwrite) && psel && penable)
    else $error("address/data changed while waiting");
  // PENABLE only with PSEL
  a_penable_needs_psel: assert property (@(posedge pclk) disable iff (!presetn) penable |-> psel)
    else $error("PENABLE without PSEL");
  // PSLVERR is only meaningful in the last cycle of a transfer
  a_slverr_only_when_ready: assert property (@(posedge pclk) disable iff (!presetn)
      pslverr |-> psel && penable && pready)
    else $error("PSLVERR outside a completing transfer");
endmodule
