// P4.3/P4.4: UVM environment for the RV32I pipeline. Needs UVM 1.2 + DPI-C
// (EDA Playground: Riviera-PRO / Questa / VCS; add ref/rv32i_ref.c compiled with -DDPI).
// NOT run here. What DID run here is the same idea without UVM:
//   tb/tb_core.v +define+DPI (lockstep against the C model through DPI-C, Verilator)
//   rand_regress.sh          (Python random programs, trace diff, 1M+ instructions)
//   tb/cov_trace.py          (the coverage plan below, computed from traces)
interface core_ret_if (input logic clk);
  logic rst_n, valid; logic [31:0] pc, insn, rd_wdata, mem_addr, mem_wdata; logic [4:0] rd; logic [3:0] be;
  logic stall, flush;
endinterface

package core_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import "DPI-C" function int  rv_ref_init(input string hex);
  import "DPI-C" function void rv_ref_step(output int pc, output int insn, output int rd, output int rd_wdata,
                                           output int mem_addr, output int mem_wdata, output int be);

  // ---------------- one retired instruction ----------------
  class ret_item extends uvm_sequence_item;
    bit [31:0] pc, insn, rd_wdata, mem_addr, mem_wdata; bit [4:0] rd; bit [3:0] be;
    `uvm_object_utils(ret_item)
    function new(string name = "ret_item"); super.new(name); endfunction
    function string convert2string();
      return $sformatf("pc=%08h insn=%08h rd=x%0d wd=%08h ma=%08h mw=%08h be=%h", pc, insn, rd, rd_wdata, mem_addr, mem_wdata, be);
    endfunction
  endclass

  // ---------------- random instruction (the generator as a sequence item) ----------------
  typedef enum {I_ALU_R, I_ALU_I, I_SHIFT, I_LOAD, I_STORE, I_BRANCH, I_LUI, I_AUIPC} iclass_e;
  class rv_instr extends uvm_sequence_item;
    rand iclass_e cls;
    rand bit [4:0] rd, rs1, rs2;
    rand bit [2:0] f3;
    rand bit       alt;
    rand bit [11:0] imm;
    rand bit [19:0] uimm;
    constraint c_mix  { cls dist { I_ALU_R := 35, I_ALU_I := 15, I_SHIFT := 5, I_LOAD := 10, I_STORE := 10,
                                   I_BRANCH := 10, I_LUI := 8, I_AUIPC := 7 }; }
    constraint c_regs { rd  dist { [1:4] :/ 70, [5:29] :/ 25, 0 :/ 5 };       // bias to x1-x4: hazards
                        rs1 dist { [1:4] :/ 70, [0:29] :/ 30 };
                        rs2 dist { [1:4] :/ 70, [0:29] :/ 30 }; }
    constraint c_mem  { cls inside {I_LOAD, I_STORE} -> rs1 == 31;            // x31 = data window base
                        cls == I_LOAD  -> f3 inside {0, 1, 2, 4, 5};
                        cls == I_STORE -> f3 inside {0, 1, 2};
                        cls inside {I_LOAD, I_STORE} -> imm < 256;
                        (cls inside {I_LOAD, I_STORE} && f3[1:0] == 2'd1) -> imm[0] == 0;
                        (cls inside {I_LOAD, I_STORE} && f3[1:0] == 2'd2) -> imm[1:0] == 0;
                        cls == I_LOAD -> rd != 31; }
    constraint c_br   { cls == I_BRANCH -> f3 inside {0, 1, 4, 5, 6, 7};
                        cls == I_BRANCH -> imm inside {[2:4]}; }            // forward skip of 1-3 instructions
    constraint c_alt  { cls == I_ALU_R -> (alt == 1 -> f3 inside {0, 5});
                        cls == I_SHIFT -> f3 inside {1, 5};
                        cls == I_SHIFT -> (alt == 1 -> f3 == 5); }
    constraint c_rd31 { rd != 31; rd != 30; }
    `uvm_object_utils(rv_instr)
    function new(string name = "rv_instr"); super.new(name); endfunction
    function bit [31:0] encode();
      bit [12:0] b = {imm, 1'b0} << 1;                                   // branch offset in bytes (imm * 4)
      case (cls)
        I_ALU_R:  return {1'b0, alt, 5'b0, rs2, rs1, f3, rd, 7'b0110011};
        I_ALU_I:  return {imm, rs1, (f3 == 1 || f3 == 5) ? 3'd0 : f3, rd, 7'b0010011};
        I_SHIFT:  return {1'b0, alt, 5'b0, imm[4:0], rs1, f3, rd, 7'b0010011};
        I_LOAD:   return {imm, rs1, f3, rd, 7'b0000011};
        I_STORE:  return {imm[11:5], rs2, rs1, f3, imm[4:0], 7'b0100011};
        I_BRANCH: return {b[12], b[10:5], rs2, rs1, f3, b[4:1], b[11], 7'b1100011};
        I_LUI:    return {uimm, rd, 7'b0110111};
        default:  return {uimm, rd, 7'b0010111};
      endcase
    endfunction
  endclass

  // ---------------- program loader: writes the program into memory before reset ends ----------------
  class program_builder extends uvm_object;
    `uvm_object_utils(program_builder)
    int unsigned n = 2000;
    bit [31:0] words[$];
    function new(string name = "program_builder"); super.new(name); endfunction
    function void build();
      words.delete();
      words.push_back(32'h0000_2f97);               // auipc x31, 2   (data window at pc + 0x2000)
      for (int r = 1; r <= 30; r++) words.push_back({12'(r * 37), 5'd0, 3'd0, 5'(r), 7'b0010011});   // addi xr, x0, r*37
      repeat (n) begin
        rv_instr it = rv_instr::type_id::create("it");
        if (!it.randomize()) `uvm_fatal("RAND", "instruction randomize failed")
        words.push_back(it.encode());
      end
      words.push_back(32'h0000_0073);               // ecall
    endfunction
    function void write_hex(string path);
      int fd = $fopen(path, "w");
      foreach (words[i]) $fdisplay(fd, "%08h", words[i]);
      $fclose(fd);
    endfunction
  endclass

  // ---------------- retirement monitor ----------------
  class ret_monitor extends uvm_monitor;
    `uvm_component_utils(ret_monitor)
    virtual core_ret_if vif;
    uvm_analysis_port #(ret_item) ap;
    function new(string name, uvm_component parent); super.new(name, parent); ap = new("ap", this); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual core_ret_if)::get(this, "", "ret_vif", vif)) `uvm_fatal("VIF", "no ret_vif")
    endfunction
    task run_phase(uvm_phase phase);
      forever begin
        @(posedge vif.clk);
        if (vif.rst_n && vif.valid) begin
          ret_item t = ret_item::type_id::create("t");
          t.pc = vif.pc; t.insn = vif.insn; t.rd = vif.rd; t.rd_wdata = vif.rd_wdata;
          t.mem_addr = vif.mem_addr; t.mem_wdata = vif.mem_wdata; t.be = vif.be;
          ap.write(t);
        end
      end
    endtask
  endclass

  // ---------------- scoreboard: step the C model once per retired instruction ----------------
  class ret_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ret_scoreboard)
    uvm_analysis_imp #(ret_item, ret_scoreboard) imp;
    int n = 0, errs = 0;
    function new(string name, uvm_component parent); super.new(name, parent); imp = new("imp", this); endfunction
    function void write(ret_item t);
      int pc, insn, rd, wd, ma, mw, be;
      rv_ref_step(pc, insn, rd, wd, ma, mw, be);
      n++;
      if (t.pc != pc || t.insn != insn || t.rd != rd || t.rd_wdata != wd || t.mem_addr != ma || t.mem_wdata != mw || t.be != be) begin
        errs++;
        // the FIRST mismatch is the one to debug; later ones are usually fallout
        if (errs == 1) `uvm_error("SB", $sformatf("first divergence at instruction %0d\n  core : %s\n  model: pc=%08h rd=x%0d wd=%08h ma=%08h mw=%08h be=%h",
                                                  n, t.convert2string(), pc, rd, wd, ma, mw, be))
      end
    endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("SB", $sformatf("%0d instructions compared, %0d mismatches", n, errs), UVM_NONE)
    endfunction
  endclass

  // ---------------- coverage (the plan cov_trace.py implements) ----------------
  class core_coverage extends uvm_subscriber #(ret_item);
    `uvm_component_utils(core_coverage)
    ret_item t; bit [4:0] last_rd[3]; bit last_load;
    int raw_dist; bit taken, backward;
    covergroup cg_instr;
      cp_opcode: coverpoint t.insn[6:0] { bins lui = {7'h37}; bins auipc = {7'h17}; bins jal = {7'h6F}; bins jalr = {7'h67};
                                          bins branch = {7'h63}; bins load = {7'h03}; bins store = {7'h23};
                                          bins op_imm = {7'h13}; bins op = {7'h33}; bins fence = {7'h0F}; }
      cp_funct3: coverpoint t.insn[14:12];
      x_op_f3: cross cp_opcode, cp_funct3 {
        ignore_bins no_f3 = binsof(cp_opcode) intersect {7'h37, 7'h17, 7'h6F, 7'h0F};
        ignore_bins bad_branch = binsof(cp_opcode) intersect {7'h63} && binsof(cp_funct3) intersect {2, 3};
        ignore_bins bad_load = binsof(cp_opcode) intersect {7'h03} && binsof(cp_funct3) intersect {3, 6, 7};
        ignore_bins bad_store = binsof(cp_opcode) intersect {7'h23} && binsof(cp_funct3) intersect {[3:7]};
        ignore_bins jalr_f3 = binsof(cp_opcode) intersect {7'h67} && binsof(cp_funct3) intersect {[1:7]}; }
      cp_rd:  coverpoint t.rd;                         // includes x0
      cp_rs1: coverpoint t.insn[19:15];
      cp_rs2: coverpoint t.insn[24:20];
      cp_imm: coverpoint t.insn[31:20] iff (t.insn[6:0] == 7'h13 && t.insn[14:12] inside {0, 2, 3, 4, 6, 7}) {
        bins zero = {12'h000}; bins max = {12'h7FF}; bins min = {12'h800}; bins other = default; }
    endgroup
    covergroup cg_hazard;
      cp_raw: coverpoint raw_dist { bins d1 = {1}; bins d2 = {2}; bins d3 = {3}; }
      cp_class: coverpoint t.insn[6:0] { bins alu = {7'h13, 7'h33}; bins load = {7'h03}; bins store = {7'h23};
                                         bins branch = {7'h63}; bins jalr = {7'h67}; }
      x_raw_class: cross cp_raw, cp_class;
      cp_load_use: coverpoint (last_load && raw_dist == 1) { bins hit = {1}; }
    endgroup
    function new(string name, uvm_component parent); super.new(name, parent); cg_instr = new(); cg_hazard = new(); endfunction
    function void write(ret_item x);
      bit [4:0] s1 = x.insn[19:15], s2 = x.insn[24:20];
      t = x; raw_dist = 0;
      for (int d = 0; d < 3; d++) if (last_rd[d] != 0 && (last_rd[d] == s1 || last_rd[d] == s2)) begin raw_dist = d + 1; break; end
      cg_instr.sample(); cg_hazard.sample();
      last_rd[2] = last_rd[1]; last_rd[1] = last_rd[0]; last_rd[0] = x.rd;
      last_load = (x.insn[6:0] == 7'h03);
    endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("COV", $sformatf("instruction coverage %0.1f%%, hazard coverage %0.1f%%",
                                  cg_instr.get_coverage(), cg_hazard.get_coverage()), UVM_NONE)
    endfunction
  endclass

  class core_env extends uvm_env;
    `uvm_component_utils(core_env)
    ret_monitor mon; ret_scoreboard sb; core_coverage cov;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      mon = ret_monitor::type_id::create("mon", this);
      sb  = ret_scoreboard::type_id::create("sb", this);
      cov = core_coverage::type_id::create("cov", this);
    endfunction
    function void connect_phase(uvm_phase phase); mon.ap.connect(sb.imp); mon.ap.connect(cov.analysis_export); endfunction
  endclass

  // random program: build it, write the hex, preload memory and the C model, release reset
  class core_random_test extends uvm_test;
    `uvm_component_utils(core_random_test)
    core_env env; virtual core_ret_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      env = core_env::type_id::create("env", this);
      if (!uvm_config_db #(virtual core_ret_if)::get(this, "", "ret_vif", vif)) `uvm_fatal("VIF", "no ret_vif")
    endfunction
    task run_phase(uvm_phase phase);
      program_builder pb = program_builder::type_id::create("pb");
      string hex = $sformatf("prog_%0d.hex", $urandom);
      phase.raise_objection(this);
      pb.build(); pb.write_hex(hex);
      $readmemh(hex, top.memory.m);                 // backdoor program load
      void'(rv_ref_init(hex));
      vif.rst_n <= 1;
      wait (top.cpu.halted);
      repeat (5) @(posedge vif.clk);
      phase.drop_objection(this);
    endtask
  endclass
endpackage

module top;
  import uvm_pkg::*;
  import core_uvm_pkg::*;
  logic clk = 0; always #5 clk = ~clk;
  core_ret_if r (clk);
  wire [31:0] iaddr, idata, daddr, dwdata, drdata; wire [3:0] dbe; wire dre, halted;
  rv32i_pipe cpu (.clk(clk), .rst_n(r.rst_n), .imem_addr(iaddr), .imem_rdata(idata), .dmem_addr(daddr), .dmem_wdata(dwdata),
    .dmem_be(dbe), .dmem_re(dre), .dmem_rdata(drdata), .halted(halted),
    .ret_valid(r.valid), .ret_pc(r.pc), .ret_insn(r.insn), .ret_rd(r.rd), .ret_rd_wdata(r.rd_wdata),
    .ret_mem_addr(r.mem_addr), .ret_mem_wdata(r.mem_wdata), .ret_mem_be(r.be), .stall(r.stall), .flush(r.flush));
  mem memory (.clk(clk), .iaddr(iaddr), .idata(idata), .daddr(daddr), .dwdata(dwdata), .dbe(dbe), .drdata(drdata));
  bind rv32i_pipe core_sva chk (.*);
  initial begin
    r.rst_n = 0;
    uvm_config_db #(virtual core_ret_if)::set(null, "*", "ret_vif", r);
    run_test("core_random_test");
  end
endmodule
