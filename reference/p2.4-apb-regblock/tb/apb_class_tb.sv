// P2.4 steps 4-5: class-based APB testbench with an associative-array register
// model and a covergroup. Written for a full SystemVerilog simulator (EDA
// Playground: Riviera-PRO / Questa / VCS). NOT run with Verilator 5.020 (it
// ignores constraints and has no covergroups). The plain-Verilog bench
// tb_apb.v checks the same features and runs on Icarus and Verilator.
interface apb_if (input logic pclk);
  logic presetn, psel, penable, pwrite, pready, pslverr;
  logic [7:0] paddr; logic [31:0] pwdata, prdata; logic [3:0] pstrb;
endinterface

package apb_tb_pkg;
  class apb_txn;
    rand bit        write;
    rand bit [7:0]  addr;
    rand bit [31:0] data;
    rand bit [3:0]  strb;
    bit             err;
    bit  [31:0]     rdata;
    int unsigned    waits;
    constraint c_addr { addr dist { [8'h00:8'h1F] :/ 90, [8'h20:8'hFF] :/ 10 };
                        (addr < 8'h20) -> addr[1:0] dist {2'b00 := 95, [2'b01:2'b11] :/ 5}; }
    constraint c_strb { write -> strb dist {4'b1111 := 60, 4'b0001 := 15, 4'b0011 := 15, [4'b0000:4'b1110] :/ 10}; }
  endclass

  class apb_driver;
    virtual apb_if vif;
    function new(virtual apb_if v); vif = v; endfunction
    task drive(apb_txn t);
      @(posedge vif.pclk);
      vif.psel <= 1; vif.penable <= 0; vif.pwrite <= t.write; vif.paddr <= t.addr;     // setup phase
      vif.pwdata <= t.data; vif.pstrb <= t.write ? t.strb : 4'h0;
      @(posedge vif.pclk); vif.penable <= 1;                                          // access phase
      t.waits = 0;
      do begin @(posedge vif.pclk); if (!vif.pready) t.waits++; end while (!vif.pready);
      t.rdata = vif.prdata; t.err = vif.pslverr;
      vif.psel <= 0; vif.penable <= 0;
    endtask
  endclass

  class apb_scoreboard;
    bit [31:0] model [bit [7:0]];            // associative array indexed by address
    int errors = 0;
    function new();
      model[8'h00] = 0; model[8'h08] = 0; model[8'h0C] = 0; model[8'h14] = 0;
      model[8'h18] = 32'h0001_0200; model[8'h1C] = 32'hFF;
    endfunction
    function bit [31:0] merge(bit [31:0] o, bit [31:0] n, bit [3:0] s);
      for (int b = 0; b < 4; b++) if (s[b]) o[b*8 +: 8] = n[b*8 +: 8];
      return o;
    endfunction
    // hw_event is tied to 0 in this bench, so INT_STATUS only changes through W1C.
    function void check(apb_txn t, bit [31:0] hw_status);
      bit exp_err = (t.addr > 8'h1C) || (t.addr[1:0] != 0);
      bit [31:0] exp;
      if (t.err != exp_err) begin errors++; $error("PSLVERR @%02h got %0b", t.addr, t.err); end
      if (exp_err) return;
      if (t.write) begin
        case (t.addr)
          8'h00, 8'h0C, 8'h14: model[t.addr] = merge(model[t.addr], t.data, t.strb);
          8'h08:               model[t.addr] &= ~merge(0, t.data, t.strb);
          8'h1C:               if (t.strb[0]) model[t.addr] = {24'h0, t.data[7:0]};
          default: ;
        endcase
      end else begin
        exp = (t.addr == 8'h04) ? hw_status : model.exists(t.addr) ? model[t.addr] : 0;
        if (t.rdata !== exp) begin errors++; $error("read @%02h got %h exp %h", t.addr, t.rdata, exp); end
      end
    endfunction
  endclass

  class apb_coverage;
    apb_txn t;
    covergroup cg;
      cp_addr: coverpoint t.addr { bins regs[] = {8'h00, 8'h04, 8'h08, 8'h0C, 8'h10, 8'h14, 8'h18, 8'h1C};
                                   bins bad_range = {[8'h20:8'hFF]};
                                   bins unaligned = default; }
      cp_dir:  coverpoint t.write;
      cp_wait: coverpoint t.waits { bins two = {2}; }       // this bench uses WAIT_STATES = 2
      cp_resp: coverpoint t.err;
      x_all: cross cp_addr, cp_dir, cp_resp {
        ignore_bins ok_never_errs   = binsof(cp_addr.regs) && binsof(cp_resp) intersect {1};
        ignore_bins bad_always_errs = binsof(cp_addr.bad_range) && binsof(cp_resp) intersect {0};
      }
    endgroup
    function new(); cg = new(); endfunction
    function void sample(apb_txn x); t = x; cg.sample(); endfunction
  endclass
endpackage

module tb_apb_class;
  import apb_tb_pkg::*;
  logic pclk = 0; always #5 pclk = ~pclk;
  apb_if bus (pclk);
  logic [31:0] hw_status = 32'h1234_5678;
  apb_regs #(.WAIT_STATES(2)) dut (.pclk(pclk), .presetn(bus.presetn), .psel(bus.psel), .penable(bus.penable),
    .pwrite(bus.pwrite), .paddr(bus.paddr), .pwdata(bus.pwdata), .pstrb(bus.pstrb), .prdata(bus.prdata),
    .pready(bus.pready), .pslverr(bus.pslverr), .hw_status(hw_status), .hw_event(32'h0), .irq(),
    .cmd_valid(), .cmd_data(), .ctrl_o());
  bind apb_regs apb_sva chk (.*);
  initial begin
    apb_driver d = new(bus); apb_scoreboard sb = new(); apb_coverage cov = new();
    bus.presetn = 0; bus.psel = 0; bus.penable = 0;
    repeat (3) @(posedge pclk); bus.presetn = 1;
    repeat (3000) begin
      apb_txn t = new();
      if (!t.randomize()) $fatal(1, "randomize failed");
      d.drive(t); sb.check(t, hw_status); cov.sample(t);
    end
    $display("errors=%0d coverage=%0.1f%% -> %s", sb.errors, cov.cg.get_coverage(), sb.errors ? "FAIL" : "PASS");
    $finish;
  end
endmodule
