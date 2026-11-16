// AXI4-Lite protocol checker, bound to the slave (Verilator 5.020+ and commercial simulators).
// Rule for every channel: once VALID is high it stays high, with a stable payload, until READY.
module axil_sva (
  input logic aclk, aresetn,
  input logic awvalid, awready, input logic [7:0] awaddr,
  input logic wvalid, wready, input logic [31:0] wdata, input logic [3:0] wstrb,
  input logic bvalid, bready, input logic [1:0] bresp,
  input logic arvalid, arready, input logic [7:0] araddr,
  input logic rvalid, rready, input logic [31:0] rdata, input logic [1:0] rresp
);
  a_aw_hold: assert property (@(posedge aclk) disable iff (!aresetn) awvalid && !awready |=> awvalid && $stable(awaddr))
    else $error("AW: VALID dropped or AWADDR changed before AWREADY");
  a_w_hold:  assert property (@(posedge aclk) disable iff (!aresetn) wvalid && !wready |=> wvalid && $stable(wdata) && $stable(wstrb))
    else $error("W: VALID dropped or payload changed before WREADY");
  a_b_hold:  assert property (@(posedge aclk) disable iff (!aresetn) bvalid && !bready |=> bvalid && $stable(bresp))
    else $error("B: BVALID dropped or BRESP changed before BREADY");
  a_ar_hold: assert property (@(posedge aclk) disable iff (!aresetn) arvalid && !arready |=> arvalid && $stable(araddr))
    else $error("AR: VALID dropped or ARADDR changed before ARREADY");
  a_r_hold:  assert property (@(posedge aclk) disable iff (!aresetn) rvalid && !rready |=> rvalid && $stable(rdata) && $stable(rresp))
    else $error("R: RVALID dropped or payload changed before RREADY");
  a_no_x_valid: assert property (@(posedge aclk) disable iff (!aresetn)
      !$isunknown({awvalid, wvalid, bvalid, arvalid, rvalid}))
    else $error("X on a VALID signal after reset");
endmodule
