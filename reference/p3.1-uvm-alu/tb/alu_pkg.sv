// UVM bench for small_alu: top -> test -> env -> agent (sequencer, driver, monitor) -> scoreboard.
// Needs a simulator with UVM 1.2 (EDA Playground: Riviera-PRO / Questa / VCS, "UVM 1.2" library).
package alu_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum bit [2:0] {NOP = 0, ADD = 1, AND = 2, XOR = 3, MUL = 4} op_e;

  // ---------- sequence item ----------
  class alu_item extends uvm_sequence_item;
    rand op_e      op;
    rand bit [7:0] a, b;
    bit     [15:0] result;
    constraint c_ops { op dist {ADD := 3, AND := 2, XOR := 2, MUL := 3, NOP := 1}; }
    `uvm_object_utils_begin(alu_item)
      `uvm_field_enum(op_e, op, UVM_ALL_ON)
      `uvm_field_int(a, UVM_ALL_ON)
      `uvm_field_int(b, UVM_ALL_ON)
      `uvm_field_int(result, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "alu_item"); super.new(name); endfunction
  endclass

  // corner-value item: used through a factory override (step 3)
  class alu_corner_item extends alu_item;
    constraint c_corner { a inside {8'h00, 8'h01, 8'h7F, 8'h80, 8'hFF}; b inside {8'h00, 8'h01, 8'h7F, 8'h80, 8'hFF}; }
    `uvm_object_utils(alu_corner_item)
    function new(string name = "alu_corner_item"); super.new(name); endfunction
  endclass

  // ---------- sequence ----------
  class alu_random_seq extends uvm_sequence #(alu_item);
    `uvm_object_utils(alu_random_seq)
    int unsigned n = 500;
    function new(string name = "alu_random_seq"); super.new(name); endfunction
    task body();
      repeat (n) begin
        alu_item it = alu_item::type_id::create("it");   // factory: overrides apply here
        start_item(it);
        if (!it.randomize()) `uvm_fatal("RAND", "randomize failed")
        finish_item(it);
      end
    endtask
  endclass

  typedef uvm_sequencer #(alu_item) alu_sequencer;

  // ---------- driver ----------
  class alu_driver extends uvm_driver #(alu_item);
    `uvm_component_utils(alu_driver)
    virtual alu_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual alu_if)::get(this, "", "vif", vif)) `uvm_fatal("NOVIF", "no vif")
    endfunction
    task run_phase(uvm_phase phase);
      vif.start <= 0;
      @(posedge vif.rst_n);
      forever begin
        seq_item_port.get_next_item(req);
        @(posedge vif.clk);
        vif.start <= 1; vif.op <= req.op; vif.a <= req.a; vif.b <= req.b;
        @(posedge vif.clk); vif.start <= 0;
        while (!vif.done) @(posedge vif.clk);
        seq_item_port.item_done();
      end
    endtask
  endclass

  // ---------- monitor: one item per completed operation ----------
  class alu_monitor extends uvm_monitor;
    `uvm_component_utils(alu_monitor)
    virtual alu_if vif;
    uvm_analysis_port #(alu_item) ap;
    function new(string name, uvm_component parent); super.new(name, parent); ap = new("ap", this); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual alu_if)::get(this, "", "vif", vif)) `uvm_fatal("NOVIF", "no vif")
    endfunction
    task run_phase(uvm_phase phase);
      alu_item cmd;
      forever begin
        @(posedge vif.clk);
        if (vif.start) begin
          cmd = alu_item::type_id::create("cmd");
          cmd.op = op_e'(vif.op); cmd.a = vif.a; cmd.b = vif.b;
          do @(posedge vif.clk); while (!vif.done);
          cmd.result = vif.result;            // sampled at the edge where done is seen
          ap.write(cmd);
        end
      end
    endtask
  endclass

  // ---------- agent ----------
  class alu_agent extends uvm_agent;
    `uvm_component_utils(alu_agent)
    alu_sequencer sqr; alu_driver drv; alu_monitor mon;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      sqr = alu_sequencer::type_id::create("sqr", this);
      drv = alu_driver::type_id::create("drv", this);
      mon = alu_monitor::type_id::create("mon", this);
    endfunction
    function void connect_phase(uvm_phase phase); drv.seq_item_port.connect(sqr.seq_item_export); endfunction
  endclass

  // ---------- scoreboard: predicts the result and compares ----------
  class alu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_scoreboard)
    uvm_analysis_imp #(alu_item, alu_scoreboard) imp;
    bit [15:0] last = 0; int n = 0, errs = 0;
    function new(string name, uvm_component parent); super.new(name, parent); imp = new("imp", this); endfunction
    function void write(alu_item t);
      bit [15:0] exp;
      case (t.op)
        ADD: exp = t.a + t.b;  AND: exp = t.a & t.b;  XOR: exp = t.a ^ t.b;
        MUL: exp = t.a * t.b;  default: exp = last;
      endcase
      n++;
      if (t.result !== exp) begin errs++; `uvm_error("SB", $sformatf("%s a=%0h b=%0h got %0h exp %0h", t.op.name(), t.a, t.b, t.result, exp)) end
      last = t.result;
    endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("SB", $sformatf("checked %0d operations, %0d errors", n, errs), UVM_NONE)
    endfunction
  endclass

  // ---------- env and tests ----------
  class alu_env extends uvm_env;
    `uvm_component_utils(alu_env)
    alu_agent agt; alu_scoreboard sb;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      agt = alu_agent::type_id::create("agt", this);
      sb  = alu_scoreboard::type_id::create("sb", this);
    endfunction
    function void connect_phase(uvm_phase phase); agt.mon.ap.connect(sb.imp); endfunction
  endclass

  class alu_random_test extends uvm_test;
    `uvm_component_utils(alu_random_test)
    alu_env env;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase); env = alu_env::type_id::create("env", this); endfunction
    task run_phase(uvm_phase phase);
      alu_random_seq seq = alu_random_seq::type_id::create("seq");
      phase.raise_objection(this);
      seq.start(env.agt.sqr);
      #100;
      phase.drop_objection(this);
    endtask
  endclass

  // Step 3: same test, but every alu_item the factory makes becomes an alu_corner_item
  class alu_corner_test extends alu_random_test;
    `uvm_component_utils(alu_corner_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      alu_item::type_id::set_type_override(alu_corner_item::get_type());
      super.build_phase(phase);
    endfunction
  endclass
endpackage
