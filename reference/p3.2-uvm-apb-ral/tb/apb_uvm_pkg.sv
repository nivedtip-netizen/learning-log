// P3.2: UVM environment with a register model (RAL) for the P2.4 APB register block.
// Needs a UVM 1.2 simulator (EDA Playground: Riviera-PRO / Questa / VCS). Not run here.
//
//   test -> env -> apb_agent (sequencer, driver, monitor, config)
//                -> scoreboard            (analysis imp from the monitor)
//                -> coverage subscriber   (analysis imp from the monitor)
//                -> reg model + adapter + explicit predictor (fed by the monitor)
package apb_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // =====================================================================
  //  Agent
  // =====================================================================
  class apb_item extends uvm_sequence_item;
    rand bit        write;
    rand bit [7:0]  addr;
    rand bit [31:0] data;
    rand bit [3:0]  strb;
    bit             slverr;
    int unsigned    waits;
    constraint c_strb_default { soft strb == 4'hF; }
    `uvm_object_utils_begin(apb_item)
      `uvm_field_int(write, UVM_ALL_ON)
      `uvm_field_int(addr,  UVM_ALL_ON)
      `uvm_field_int(data,  UVM_ALL_ON)
      `uvm_field_int(strb,  UVM_ALL_ON)
      `uvm_field_int(slverr, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "apb_item"); super.new(name); endfunction
  endclass

  class apb_config extends uvm_object;
    `uvm_object_utils(apb_config)
    virtual apb_if vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    function new(string name = "apb_config"); super.new(name); endfunction
  endclass

  typedef uvm_sequencer #(apb_item) apb_sequencer;

  class apb_driver extends uvm_driver #(apb_item);
    `uvm_component_utils(apb_driver)
    apb_config cfg;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(apb_config)::get(this, "", "cfg", cfg)) `uvm_fatal("CFG", "no apb_config")
    endfunction
    task run_phase(uvm_phase phase);
      virtual apb_if vif = cfg.vif;
      vif.psel <= 0; vif.penable <= 0;
      @(posedge vif.presetn);
      forever begin
        seq_item_port.get_next_item(req);
        @(posedge vif.pclk);
        vif.psel <= 1; vif.penable <= 0; vif.pwrite <= req.write;          // setup phase
        vif.paddr <= req.addr; vif.pwdata <= req.data; vif.pstrb <= req.write ? req.strb : 4'h0;
        @(posedge vif.pclk); vif.penable <= 1;                             // access phase
        do @(posedge vif.pclk); while (!vif.pready);
        if (!req.write) req.data = vif.prdata;                             // read data back to the sequence
        req.slverr = vif.pslverr;
        vif.psel <= 0; vif.penable <= 0;
        seq_item_port.item_done();
      end
    endtask
  endclass

  // Passive: rebuilds every completed transfer from the pins.
  class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)
    apb_config cfg;
    uvm_analysis_port #(apb_item) ap;
    function new(string name, uvm_component parent); super.new(name, parent); ap = new("ap", this); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(apb_config)::get(this, "", "cfg", cfg)) `uvm_fatal("CFG", "no apb_config")
    endfunction
    task run_phase(uvm_phase phase);
      virtual apb_if vif = cfg.vif;
      int waits;
      forever begin
        @(posedge vif.pclk);
        if (vif.psel && vif.penable) begin
          if (!vif.pready) begin waits++; continue; end
          begin
            apb_item t = apb_item::type_id::create("t");
            t.write = vif.pwrite; t.addr = vif.paddr; t.strb = vif.pstrb;
            t.data  = vif.pwrite ? vif.pwdata : vif.prdata;
            t.slverr = vif.pslverr; t.waits = waits;
            ap.write(t);
          end
          waits = 0;
        end
      end
    endtask
  endclass

  class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)
    apb_config cfg; apb_sequencer sqr; apb_driver drv; apb_monitor mon;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(apb_config)::get(this, "", "cfg", cfg)) `uvm_fatal("CFG", "no apb_config")
      mon = apb_monitor::type_id::create("mon", this);
      if (cfg.is_active == UVM_ACTIVE) begin
        sqr = apb_sequencer::type_id::create("sqr", this);
        drv = apb_driver::type_id::create("drv", this);
      end
    endfunction
    function void connect_phase(uvm_phase phase);
      if (cfg.is_active == UVM_ACTIVE) drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  // =====================================================================
  //  Register model (hand-written, one class per register)
  // =====================================================================
  class reg_rw32 extends uvm_reg;          // CTRL, INT_ENABLE, SCRATCH
    `uvm_object_utils(reg_rw32)
    rand uvm_reg_field f;
    function new(string name = "reg_rw32"); super.new(name, 32, UVM_NO_COVERAGE); endfunction
    virtual function void build();
      f = uvm_reg_field::type_id::create("f");
      f.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction
  endclass

  class reg_status extends uvm_reg;        // RO, value comes from hardware
    `uvm_object_utils(reg_status)
    uvm_reg_field f;
    function new(string name = "reg_status"); super.new(name, 32, UVM_NO_COVERAGE); endfunction
    virtual function void build();
      f = uvm_reg_field::type_id::create("f");
      f.configure(this, 32, 0, "RO", 1, 32'h0, 0, 0, 1);       // volatile: not checked by mirror
    endfunction
  endclass

  class reg_int_status extends uvm_reg;    // W1C, set by hardware
    `uvm_object_utils(reg_int_status)
    uvm_reg_field f;
    function new(string name = "reg_int_status"); super.new(name, 32, UVM_NO_COVERAGE); endfunction
    virtual function void build();
      f = uvm_reg_field::type_id::create("f");
      f.configure(this, 32, 0, "W1C", 1, 32'h0, 1, 0, 1);
    endfunction
  endclass

  class reg_cmd extends uvm_reg;           // WO: reads return 0
    `uvm_object_utils(reg_cmd)
    rand uvm_reg_field f;
    function new(string name = "reg_cmd"); super.new(name, 32, UVM_NO_COVERAGE); endfunction
    virtual function void build();
      f = uvm_reg_field::type_id::create("f");
      f.configure(this, 32, 0, "WO", 0, 32'h0, 1, 1, 1);
    endfunction
  endclass

  class reg_version extends uvm_reg;       // RO constant
    `uvm_object_utils(reg_version)
    uvm_reg_field f;
    function new(string name = "reg_version"); super.new(name, 32, UVM_NO_COVERAGE); endfunction
    virtual function void build();
      f = uvm_reg_field::type_id::create("f");
      f.configure(this, 32, 0, "RO", 0, 32'h0001_0200, 1, 0, 1);
    endfunction
  endclass

  class reg_config extends uvm_reg;        // only bits [7:0] exist
    `uvm_object_utils(reg_config)
    rand uvm_reg_field val;
    function new(string name = "reg_config"); super.new(name, 32, UVM_NO_COVERAGE); endfunction
    virtual function void build();
      val = uvm_reg_field::type_id::create("val");
      val.configure(this, 8, 0, "RW", 0, 8'hFF, 1, 1, 1);
    endfunction
  endclass

  class apb_reg_block extends uvm_reg_block;
    `uvm_object_utils(apb_reg_block)
    rand reg_rw32       CTRL, INT_ENABLE, SCRATCH;
    reg_status          STATUS;
    reg_int_status      INT_STATUS;
    rand reg_cmd        CMD;
    reg_version         VERSION;
    rand reg_config     CONFIG;
    uvm_reg_map         map;
    function new(string name = "apb_reg_block"); super.new(name, UVM_NO_COVERAGE); endfunction
    virtual function void build();
      CTRL       = reg_rw32::type_id::create("CTRL");             CTRL.configure(this);       CTRL.build();
      STATUS     = reg_status::type_id::create("STATUS");         STATUS.configure(this);     STATUS.build();
      INT_STATUS = reg_int_status::type_id::create("INT_STATUS"); INT_STATUS.configure(this); INT_STATUS.build();
      INT_ENABLE = reg_rw32::type_id::create("INT_ENABLE");       INT_ENABLE.configure(this); INT_ENABLE.build();
      CMD        = reg_cmd::type_id::create("CMD");               CMD.configure(this);        CMD.build();
      SCRATCH    = reg_rw32::type_id::create("SCRATCH");          SCRATCH.configure(this);    SCRATCH.build();
      VERSION    = reg_version::type_id::create("VERSION");       VERSION.configure(this);    VERSION.build();
      CONFIG     = reg_config::type_id::create("CONFIG");         CONFIG.configure(this);     CONFIG.build();
      map = create_map("map", 'h0, 4, UVM_LITTLE_ENDIAN, 1);
      map.add_reg(CTRL,       'h00, "RW");
      map.add_reg(STATUS,     'h04, "RO");
      map.add_reg(INT_STATUS, 'h08, "RW");
      map.add_reg(INT_ENABLE, 'h0C, "RW");
      map.add_reg(CMD,        'h10, "WO");
      map.add_reg(SCRATCH,    'h14, "RW");
      map.add_reg(VERSION,    'h18, "RO");
      map.add_reg(CONFIG,     'h1C, "RW");
      // hardware changes these, so bit-bash must skip them
      uvm_resource_db #(bit)::set({"REG::", STATUS.get_full_name()},     "NO_REG_BIT_BASH_TEST", 1, this);
      uvm_resource_db #(bit)::set({"REG::", INT_STATUS.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
      uvm_resource_db #(bit)::set({"REG::", CMD.get_full_name()},        "NO_REG_TESTS", 1, this);
      lock_model();
    endfunction
  endclass

  // reg.write()/read() <-> apb_item
  class apb_reg_adapter extends uvm_reg_adapter;
    `uvm_object_utils(apb_reg_adapter)
    function new(string name = "apb_reg_adapter"); super.new(name); provides_responses = 0; supports_byte_enable = 1; endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      apb_item t = apb_item::type_id::create("t");
      t.write = (rw.kind == UVM_WRITE); t.addr = rw.addr; t.data = rw.data;
      t.strb  = (rw.byte_en == 0) ? 4'hF : rw.byte_en[3:0];
      return t;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      apb_item t;
      if (!$cast(t, bus_item)) `uvm_fatal("ADAPT", "not an apb_item")
      rw.kind = t.write ? UVM_WRITE : UVM_READ; rw.addr = t.addr; rw.data = t.data;
      rw.byte_en = t.strb; rw.status = t.slverr ? UVM_NOT_OK : UVM_IS_OK;
    endfunction
  endclass

  // =====================================================================
  //  Scoreboard and coverage
  // =====================================================================
  // Checks what the RAL mirror cannot: PSLVERR on bad addresses and the
  // read-only constant. Register values are checked by mirror(UVM_CHECK).
  class apb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(apb_scoreboard)
    uvm_analysis_imp #(apb_item, apb_scoreboard) imp;
    int n = 0, errs = 0;
    function new(string name, uvm_component parent); super.new(name, parent); imp = new("imp", this); endfunction
    function void write(apb_item t);
      bit exp_err = (t.addr > 8'h1C) || (t.addr[1:0] != 0);
      n++;
      if (t.slverr != exp_err) begin errs++; `uvm_error("SB", $sformatf("PSLVERR=%0b for addr %02h", t.slverr, t.addr)) end
      if (!t.write && t.addr == 8'h18 && t.data != 32'h0001_0200) begin errs++; `uvm_error("SB", "VERSION changed") end
      if (!t.write && t.addr == 8'h10 && t.data != 0) begin errs++; `uvm_error("SB", "CMD read not 0") end
    endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("SB", $sformatf("%0d transfers, %0d errors", n, errs), UVM_NONE)
    endfunction
  endclass

  class apb_coverage extends uvm_subscriber #(apb_item);
    `uvm_component_utils(apb_coverage)
    apb_item t;
    covergroup cg;
      cp_addr: coverpoint t.addr { bins regs[] = {'h00, 'h04, 'h08, 'h0C, 'h10, 'h14, 'h18, 'h1C}; bins bad = default; }
      cp_dir:  coverpoint t.write;
      cp_wait: coverpoint t.waits { bins none = {0}; bins some = {[1:3]}; bins many = {[4:$]}; }
      cp_resp: coverpoint t.slverr;
      x_addr_dir: cross cp_addr, cp_dir;
      x_wait_dir: cross cp_wait, cp_dir;
    endgroup
    function new(string name, uvm_component parent); super.new(name, parent); cg = new(); endfunction
    function void write(apb_item x); t = x; cg.sample(); endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("COV", $sformatf("APB functional coverage = %0.1f%%", cg.get_coverage()), UVM_NONE)
    endfunction
  endclass

  // =====================================================================
  //  Environment
  // =====================================================================
  class apb_env extends uvm_env;
    `uvm_component_utils(apb_env)
    apb_agent agt; apb_scoreboard sb; apb_coverage cov;
    apb_reg_block regmodel; apb_reg_adapter adapter;
    uvm_reg_predictor #(apb_item) predictor;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      agt = apb_agent::type_id::create("agt", this);
      sb  = apb_scoreboard::type_id::create("sb", this);
      cov = apb_coverage::type_id::create("cov", this);
      regmodel = apb_reg_block::type_id::create("regmodel");
      regmodel.build();
      adapter   = apb_reg_adapter::type_id::create("adapter");
      predictor = uvm_reg_predictor #(apb_item)::type_id::create("predictor", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      regmodel.map.set_sequencer(agt.sqr, adapter);
      regmodel.map.set_auto_predict(0);              // explicit prediction from the monitor
      predictor.map = regmodel.map;
      predictor.adapter = adapter;
      agt.mon.ap.connect(predictor.bus_in);
      agt.mon.ap.connect(sb.imp);
      agt.mon.ap.connect(cov.analysis_export);
    endfunction
  endclass

  // =====================================================================
  //  Sequences
  // =====================================================================
  class apb_base_reg_seq extends uvm_sequence #(apb_item);
    `uvm_object_utils(apb_base_reg_seq)
    apb_reg_block rm;
    function new(string name = "apb_base_reg_seq"); super.new(name); endfunction
  endclass

  // random writes then mirror(CHECK) on every register
  class apb_random_rw_seq extends apb_base_reg_seq;
    `uvm_object_utils(apb_random_rw_seq)
    function new(string name = "apb_random_rw_seq"); super.new(name); endfunction
    task body();
      uvm_status_e st; uvm_reg regs[$];
      rm.get_registers(regs);
      repeat (200) begin
        uvm_reg r = regs[$urandom_range(0, regs.size() - 1)];
        if (r.get_name() inside {"STATUS", "INT_STATUS", "VERSION"}) continue;
        r.write(st, $urandom);
        if (r.get_name() != "CMD") r.mirror(st, UVM_CHECK);
      end
    endtask
  endclass

  // W1C: hardware sets bits (driven from top through hw_event), software clears them
  class apb_w1c_seq extends apb_base_reg_seq;
    `uvm_object_utils(apb_w1c_seq)
    virtual apb_if vif;
    function new(string name = "apb_w1c_seq"); super.new(name); endfunction
    task body();
      uvm_status_e st; uvm_reg_data_t v;
      repeat (20) begin
        bit [31:0] ev = 32'h1 << $urandom_range(0, 31);
        @(posedge vif.pclk); vif.hw_event <= ev; @(posedge vif.pclk); vif.hw_event <= 0;
        void'(rm.INT_STATUS.predict(rm.INT_STATUS.get_mirrored_value() | ev));
        rm.INT_STATUS.mirror(st, UVM_CHECK);
        rm.INT_STATUS.write(st, ev);                      // write 1 to clear
        rm.INT_STATUS.read(st, v);
        if (v & ev) `uvm_error("W1C", $sformatf("bit not cleared: %h", v))
      end
    endtask
  endclass

  // raw bus items to addresses with no register: expect PSLVERR (checked by the scoreboard)
  class apb_bad_addr_seq extends uvm_sequence #(apb_item);
    `uvm_object_utils(apb_bad_addr_seq)
    function new(string name = "apb_bad_addr_seq"); super.new(name); endfunction
    task body();
      repeat (50) begin
        apb_item t = apb_item::type_id::create("t");
        start_item(t);
        if (!t.randomize() with { addr > 8'h1C || addr[1:0] != 0; }) `uvm_fatal("RAND", "")
        finish_item(t);
      end
    endtask
  endclass

  // =====================================================================
  //  Tests
  // =====================================================================
  class apb_base_test extends uvm_test;
    `uvm_component_utils(apb_base_test)
    apb_env env; apb_config cfg;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      cfg = apb_config::type_id::create("cfg");
      if (!uvm_config_db #(virtual apb_if)::get(this, "", "vif", cfg.vif)) `uvm_fatal("VIF", "no vif")
      uvm_config_db #(apb_config)::set(this, "env.agt*", "cfg", cfg);
      env = apb_env::type_id::create("env", this);
    endfunction
    virtual task run_seq(); endtask
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      run_seq();
      #100;
      phase.drop_objection(this);
    endtask
  endclass

  class apb_reset_test extends apb_base_test;
    `uvm_component_utils(apb_reset_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_seq();
      uvm_reg_hw_reset_seq s = uvm_reg_hw_reset_seq::type_id::create("s");
      s.model = env.regmodel; s.start(null);
    endtask
  endclass

  class apb_bitbash_test extends apb_base_test;
    `uvm_component_utils(apb_bitbash_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_seq();
      uvm_reg_bit_bash_seq s = uvm_reg_bit_bash_seq::type_id::create("s");
      s.model = env.regmodel; s.start(null);
    endtask
  endclass

  class apb_random_test extends apb_base_test;
    `uvm_component_utils(apb_random_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_seq();
      apb_random_rw_seq s = apb_random_rw_seq::type_id::create("s");
      s.rm = env.regmodel; s.start(env.agt.sqr);
    endtask
  endclass

  class apb_w1c_test extends apb_base_test;
    `uvm_component_utils(apb_w1c_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_seq();
      apb_w1c_seq s = apb_w1c_seq::type_id::create("s");
      s.rm = env.regmodel; s.vif = cfg.vif; s.start(env.agt.sqr);
    endtask
  endclass

  class apb_bad_addr_test extends apb_base_test;
    `uvm_component_utils(apb_bad_addr_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_seq();
      apb_bad_addr_seq s = apb_bad_addr_seq::type_id::create("s");
      s.start(env.agt.sqr);
    endtask
  endclass

  // same random traffic; the top picks WAIT_STATES from +WAIT=<n> (see top.sv)
  class apb_wait_stress_test extends apb_random_test;
    `uvm_component_utils(apb_wait_stress_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
endpackage
