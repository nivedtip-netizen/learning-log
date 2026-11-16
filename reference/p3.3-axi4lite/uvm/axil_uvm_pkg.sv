// P3.3 UVM environment for the AXI4-Lite slave. Needs a UVM 1.2 simulator
// (EDA Playground: Riviera-PRO / Questa / VCS). NOT run here; the plain-Verilog
// bench tb/tb_axil.v checks the same things on Icarus/Verilator.
interface axil_if (input logic aclk);
  logic aresetn;
  logic awvalid, awready; logic [7:0] awaddr;
  logic wvalid, wready;   logic [31:0] wdata; logic [3:0] wstrb;
  logic bvalid, bready;   logic [1:0] bresp;
  logic arvalid, arready; logic [7:0] araddr;
  logic rvalid, rready;   logic [31:0] rdata; logic [1:0] rresp;
endinterface

package axil_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum {AW_FIRST, W_FIRST, SAME_CYCLE} order_e;

  class axil_item extends uvm_sequence_item;
    rand bit        write;
    rand bit [7:0]  addr;
    rand bit [31:0] data;
    rand bit [3:0]  strb;
    rand order_e    order;          // for writes: which channel goes first
    rand int unsigned gap;          // cycles between the first and the second channel
    bit [1:0]       resp;
    int unsigned    bp_cycles;      // backpressure seen on B or R (filled by the monitor)
    constraint c_addr  { addr[1:0] == 0; addr dist { [8'h00:8'h3C] :/ 90, [8'h40:8'hFC] :/ 10 }; }
    constraint c_gap   { order == SAME_CYCLE -> gap == 0; gap inside {[0:5]}; }
    constraint c_strb  { strb dist { 4'hF := 50, 4'h1 := 10, 4'h3 := 10, 4'hC := 10, 4'h0 := 5, [4'h2:4'hE] :/ 15 }; }
    `uvm_object_utils_begin(axil_item)
      `uvm_field_int(write, UVM_ALL_ON) `uvm_field_int(addr, UVM_ALL_ON) `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(strb, UVM_ALL_ON)  `uvm_field_int(resp, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "axil_item"); super.new(name); endfunction
  endclass

  typedef uvm_sequencer #(axil_item) axil_sequencer;

  // ---------------- driver: AW and W in two parallel threads ----------------
  class axil_driver extends uvm_driver #(axil_item);
    `uvm_component_utils(axil_driver)
    virtual axil_if vif;
    int unsigned max_bp = 6;        // longest BREADY/RREADY stall
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual axil_if)::get(this, "", "vif", vif)) `uvm_fatal("VIF", "no vif")
    endfunction

    task automatic drive_aw(bit [7:0] a, int unsigned dly);
      repeat (dly) @(posedge vif.aclk);
      vif.awvalid <= 1; vif.awaddr <= a;
      do @(posedge vif.aclk); while (!vif.awready);
      vif.awvalid <= 0;
    endtask
    task automatic drive_w(bit [31:0] d, bit [3:0] s, int unsigned dly);
      repeat (dly) @(posedge vif.aclk);
      vif.wvalid <= 1; vif.wdata <= d; vif.wstrb <= s;
      do @(posedge vif.aclk); while (!vif.wready);
      vif.wvalid <= 0;
    endtask

    // BREADY / RREADY backpressure runs on its own, independent of the items
    task ready_thread();
      forever begin
        @(posedge vif.aclk);
        vif.bready <= ($urandom_range(0, 3) != 0);
        vif.rready <= ($urandom_range(0, 3) != 0);
        if ($urandom_range(0, 9) == 0) begin
          vif.bready <= 0; vif.rready <= 0;
          repeat ($urandom_range(1, max_bp)) @(posedge vif.aclk);
        end
      end
    endtask

    task run_phase(uvm_phase phase);
      vif.awvalid <= 0; vif.wvalid <= 0; vif.arvalid <= 0; vif.bready <= 0; vif.rready <= 0;
      @(posedge vif.aresetn);
      fork ready_thread(); join_none
      forever begin
        seq_item_port.get_next_item(req);
        if (req.write) begin
          fork
            drive_aw(req.addr, req.order == W_FIRST  ? req.gap : 0);
            drive_w(req.data, req.strb, req.order == AW_FIRST ? req.gap : 0);
          join
          do @(posedge vif.aclk); while (!(vif.bvalid && vif.bready));
          req.resp = vif.bresp;
        end else begin
          vif.arvalid <= 1; vif.araddr <= req.addr;
          do @(posedge vif.aclk); while (!vif.arready);
          vif.arvalid <= 0;
          do @(posedge vif.aclk); while (!(vif.rvalid && vif.rready));
          req.data = vif.rdata; req.resp = vif.rresp;
        end
        seq_item_port.item_done();
      end
    endtask
  endclass

  // ---------------- monitor: rebuilds complete transactions ----------------
  class axil_monitor extends uvm_monitor;
    `uvm_component_utils(axil_monitor)
    virtual axil_if vif;
    uvm_analysis_port #(axil_item) ap;
    function new(string name, uvm_component parent); super.new(name, parent); ap = new("ap", this); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual axil_if)::get(this, "", "vif", vif)) `uvm_fatal("VIF", "no vif")
    endfunction
    task run_phase(uvm_phase phase);
      fork mon_write(); mon_read(); join
    endtask
    task mon_write();
      bit [7:0] a; bit [31:0] d; bit [3:0] s; bit got_aw, got_w; time t_aw, t_w; int bp;
      forever begin
        got_aw = 0; got_w = 0; bp = 0;
        while (!(got_aw && got_w)) begin
          @(posedge vif.aclk);
          if (vif.awvalid && vif.awready) begin a = vif.awaddr; got_aw = 1; t_aw = $time; end
          if (vif.wvalid && vif.wready)   begin d = vif.wdata; s = vif.wstrb; got_w = 1; t_w = $time; end
        end
        do begin @(posedge vif.aclk); if (vif.bvalid && !vif.bready) bp++; end while (!(vif.bvalid && vif.bready));
        begin
          axil_item t = axil_item::type_id::create("wr");
          t.write = 1; t.addr = a; t.data = d; t.strb = s; t.resp = vif.bresp; t.bp_cycles = bp;
          t.order = (t_aw < t_w) ? AW_FIRST : (t_w < t_aw) ? W_FIRST : SAME_CYCLE;
          ap.write(t);
        end
      end
    endtask
    task mon_read();
      bit [7:0] a; int bp;
      forever begin
        do @(posedge vif.aclk); while (!(vif.arvalid && vif.arready));
        a = vif.araddr; bp = 0;
        do begin @(posedge vif.aclk); if (vif.rvalid && !vif.rready) bp++; end while (!(vif.rvalid && vif.rready));
        begin
          axil_item t = axil_item::type_id::create("rd");
          t.write = 0; t.addr = a; t.data = vif.rdata; t.resp = vif.rresp; t.bp_cycles = bp;
          ap.write(t);
        end
      end
    endtask
  endclass

  class axil_agent extends uvm_agent;
    `uvm_component_utils(axil_agent)
    axil_sequencer sqr; axil_driver drv; axil_monitor mon;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      sqr = axil_sequencer::type_id::create("sqr", this);
      drv = axil_driver::type_id::create("drv", this);
      mon = axil_monitor::type_id::create("mon", this);
    endfunction
    function void connect_phase(uvm_phase phase); drv.seq_item_port.connect(sqr.seq_item_export); endfunction
  endclass

  // ---------------- scoreboard with a memory reference model ----------------
  class axil_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axil_scoreboard)
    uvm_analysis_imp #(axil_item, axil_scoreboard) imp;
    bit [31:0] mem [16];
    int n = 0, errs = 0;
    function new(string name, uvm_component parent); super.new(name, parent); imp = new("imp", this); endfunction
    function void write(axil_item t);
      bit bad = (t.addr >= 8'h40);
      bit [1:0] exp_resp = bad ? 2'b10 : 2'b00;
      n++;
      if (t.resp !== exp_resp) begin errs++; `uvm_error("SB", $sformatf("%s @%02h resp %0d exp %0d", t.write ? "WR" : "RD", t.addr, t.resp, exp_resp)) end
      if (bad) return;
      if (t.write) begin
        for (int b = 0; b < 4; b++) if (t.strb[b]) mem[t.addr[5:2]][b*8 +: 8] = t.data[b*8 +: 8];
      end else if (t.data !== mem[t.addr[5:2]]) begin
        errs++; `uvm_error("SB", $sformatf("RD @%02h got %08h exp %08h", t.addr, t.data, mem[t.addr[5:2]]))
      end
    endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("SB", $sformatf("%0d transactions, %0d errors", n, errs), UVM_NONE)
    endfunction
  endclass

  // ---------------- coverage ----------------
  class axil_coverage extends uvm_subscriber #(axil_item);
    `uvm_component_utils(axil_coverage)
    axil_item t;
    covergroup cg;
      cp_dir:   coverpoint t.write;
      cp_resp:  coverpoint t.resp { bins okay = {2'b00}; bins slverr = {2'b10}; illegal_bins other = {2'b01, 2'b11}; }
      cp_strb:  coverpoint t.strb iff (t.write) { bins all = {4'hF}; bins b0 = {4'h1}; bins low = {4'h3}; bins high = {4'hC};
                                                   bins none = {4'h0}; bins other = default; }
      cp_order: coverpoint t.order iff (t.write);
      cp_bp:    coverpoint t.bp_cycles { bins none = {0}; bins short = {[1:3]}; bins long = {[4:$]}; }
      x_dir_resp: cross cp_dir, cp_resp;
      x_dir_bp:   cross cp_dir, cp_bp;
    endgroup
    function new(string name, uvm_component parent); super.new(name, parent); cg = new(); endfunction
    function void write(axil_item x); t = x; cg.sample(); endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("COV", $sformatf("coverage = %0.1f%%", cg.get_coverage()), UVM_NONE)
    endfunction
  endclass

  class axil_env extends uvm_env;
    `uvm_component_utils(axil_env)
    axil_agent agt; axil_scoreboard sb; axil_coverage cov;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      agt = axil_agent::type_id::create("agt", this);
      sb  = axil_scoreboard::type_id::create("sb", this);
      cov = axil_coverage::type_id::create("cov", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      agt.mon.ap.connect(sb.imp);
      agt.mon.ap.connect(cov.analysis_export);
    endfunction
  endclass

  // ---------------- sequences and tests ----------------
  class axil_random_seq extends uvm_sequence #(axil_item);
    `uvm_object_utils(axil_random_seq)
    int unsigned n = 1000;
    function new(string name = "axil_random_seq"); super.new(name); endfunction
    task body();
      repeat (n) begin
        axil_item it = axil_item::type_id::create("it");
        start_item(it);
        if (!it.randomize()) `uvm_fatal("RAND", "randomize failed")
        finish_item(it);
      end
    endtask
  endclass

  class axil_random_test extends uvm_test;
    `uvm_component_utils(axil_random_test)
    axil_env env;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase); env = axil_env::type_id::create("env", this); endfunction
    task run_phase(uvm_phase phase);
      axil_random_seq s = axil_random_seq::type_id::create("s");
      phase.raise_objection(this);
      s.start(env.agt.sqr);
      #200;
      phase.drop_objection(this);
    endtask
  endclass

  // heavier backpressure: longer stalls on B and R
  class axil_backpressure_test extends axil_random_test;
    `uvm_component_utils(axil_backpressure_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void end_of_elaboration_phase(uvm_phase phase); env.agt.drv.max_bp = 16; endfunction
  endclass
endpackage

// run: +UVM_TESTNAME=axil_random_test or axil_backpressure_test
module top;
  import uvm_pkg::*;
  import axil_uvm_pkg::*;
  logic aclk = 0; always #5 aclk = ~aclk;
  axil_if bus (aclk);
  axil_regs dut (.aclk(aclk), .aresetn(bus.aresetn),
    .awvalid(bus.awvalid), .awaddr(bus.awaddr), .awready(bus.awready),
    .wvalid(bus.wvalid), .wdata(bus.wdata), .wstrb(bus.wstrb), .wready(bus.wready),
    .bvalid(bus.bvalid), .bresp(bus.bresp), .bready(bus.bready),
    .arvalid(bus.arvalid), .araddr(bus.araddr), .arready(bus.arready),
    .rvalid(bus.rvalid), .rdata(bus.rdata), .rresp(bus.rresp), .rready(bus.rready));
  bind axil_regs axil_sva chk (.*);
  initial begin bus.aresetn = 0; #22 bus.aresetn = 1; end
  initial begin
    uvm_config_db #(virtual axil_if)::set(null, "*", "vif", bus);
    run_test();
  end
endmodule
