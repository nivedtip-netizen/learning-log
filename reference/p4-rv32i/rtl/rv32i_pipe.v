`timescale 1ns/1ps
`include "rv_defs.vh"
// 5-stage RV32I pipeline: IF | ID | EX | MEM | WB
//  * forwarding: EX/MEM and MEM/WB results into the EX operands
//    (the register file writes through, which covers WB -> ID)
//  * load-use: a load in EX whose rd is read by the instruction in ID stalls
//    PC and IF/ID for one cycle and puts a bubble into ID/EX
//  * branches and jumps resolve in EX; when the PC is redirected, the two
//    younger instructions (in IF/ID and ID/EX) are flushed: 2-cycle penalty
//  * ECALL/EBREAK/illegal: fetch stops once it leaves ID; the core halts when it reaches WB
// Same ports as rv32i_single, so the same testbench and checks run on both.
module rv32i_pipe #(parameter [31:0] RESET_PC = 32'h0) (
  input  wire        clk, rst_n,
  output wire [31:0] imem_addr, input wire [31:0] imem_rdata,
  output wire [31:0] dmem_addr, output wire [31:0] dmem_wdata, output wire [3:0] dmem_be,
  output wire        dmem_re,   input wire [31:0] dmem_rdata,
  output reg         halted,
  output wire        ret_valid, output wire [31:0] ret_pc, ret_insn,
  output wire [4:0]  ret_rd,    output wire [31:0] ret_rd_wdata,
  output wire [31:0] ret_mem_addr, ret_mem_wdata, output wire [3:0] ret_mem_be,
  // visible for the hazard tests, coverage and assertions
  output wire        stall, output wire flush
);
  // ======================= IF =======================
  reg  [31:0] pc;
  reg         halt_pending;
  assign imem_addr = pc;

  // IF/ID
  reg        d_v; reg [31:0] d_pc, d_ins;

  // ======================= ID =======================
  wire [3:0] d_alu_op; wire [1:0] d_a_sel, d_wb_sel; wire d_b_imm, d_rw, d_mr, d_mw, d_br, d_jal, d_jalr, d_halt, d_ill, d_u1, d_u2;
  wire [2:0] d_imm_sel;
  rv_decoder dec (.instr(d_ins), .alu_op(d_alu_op), .a_sel(d_a_sel), .b_imm(d_b_imm), .imm_sel(d_imm_sel),
                  .reg_write(d_rw), .wb_sel(d_wb_sel), .mem_read(d_mr), .mem_write(d_mw), .branch(d_br),
                  .jal(d_jal), .jalr(d_jalr), .halt(d_halt), .illegal(d_ill), .uses_rs1(d_u1), .uses_rs2(d_u2));
  wire [31:0] d_imm; rv_immgen ig (.instr(d_ins), .sel(d_imm_sel), .imm(d_imm));
  wire [4:0] d_rs1 = d_ins[19:15], d_rs2 = d_ins[24:20], d_rd = d_ins[11:7];
  wire [31:0] d_r1, d_r2;
  // WB-stage write port (declared below)
  reg        w_v, w_rw; reg [4:0] w_rd; reg [31:0] w_data;
  rv_regfile #(.BYPASS(1)) rf (.clk(clk), .ra1(d_rs1), .ra2(d_rs2), .wa(w_rd), .we(w_v && w_rw),
                               .wd(w_data), .rd1(d_r1), .rd2(d_r2));

  // ID/EX
  reg        e_v, e_rw, e_mr, e_mw, e_br, e_jal, e_jalr, e_halt, e_b_imm;
  reg [3:0]  e_alu_op; reg [1:0] e_a_sel, e_wb_sel; reg [2:0] e_f3;
  reg [4:0]  e_rs1, e_rs2, e_rd; reg [31:0] e_pc, e_ins, e_imm, e_r1, e_r2;

  // load-use hazard: load in EX, its rd is a source of the instruction in ID
`ifdef BUG_NOSTALL
  assign stall = 1'b0;                                  // seeded bug: load-use not detected
`else
  assign stall = d_v && e_v && e_mr && (e_rd != 5'd0) &&
                 ((d_u1 && d_rs1 == e_rd) || (d_u2 && d_rs2 == e_rd));
`endif

  // ======================= EX =======================
  // EX/MEM
  reg        m_v, m_rw, m_mr, m_mw, m_halt; reg [1:0] m_wb_sel; reg [2:0] m_f3;
  reg [4:0]  m_rd; reg [31:0] m_pc, m_ins, m_alu, m_r2;

  wire [31:0] m_fwd = (m_wb_sel == `WB_PC4) ? m_pc + 32'd4 : m_alu;      // what EX/MEM can forward (not loads)
  wire fwd1_m = m_v && m_rw && !m_mr && (m_rd != 0) && (m_rd == e_rs1);
`ifdef BUG_FWD2
  wire fwd2_m = 1'b0;                                   // seeded bug: no EX/MEM forward for rs2
`else
  wire fwd2_m = m_v && m_rw && !m_mr && (m_rd != 0) && (m_rd == e_rs2);
`endif
  wire fwd1_w = w_v && w_rw && (w_rd != 0) && (w_rd == e_rs1);
  wire fwd2_w = w_v && w_rw && (w_rd != 0) && (w_rd == e_rs2);
  wire [31:0] e_op1 = fwd1_m ? m_fwd : fwd1_w ? w_data : e_r1;
  wire [31:0] e_op2 = fwd2_m ? m_fwd : fwd2_w ? w_data : e_r2;

  wire [31:0] alu_a = (e_a_sel == 2'd1) ? e_pc : (e_a_sel == 2'd2) ? 32'h0 : e_op1;
  wire [31:0] alu_b = e_b_imm ? e_imm : e_op2;
  wire [31:0] e_alu; rv_alu alu (.a(alu_a), .b(alu_b), .op(e_alu_op), .y(e_alu));
  wire e_taken; rv_branch bu (.a(e_op1), .b(e_op2), .funct3(e_f3), .taken(e_taken));
  wire redirect = e_v && (e_jal || e_jalr || (e_br && e_taken));
  wire [31:0] target = e_jalr ? (e_alu & ~32'd1) : e_pc + e_imm;
  assign flush = redirect;

  // ======================= MEM =======================
  wire [31:0] m_load; wire [3:0] m_be; wire [31:0] m_wdata;
  rv_lsu lsu (.addr(m_alu), .store_data(m_r2), .mem_rdata(dmem_rdata), .funct3(m_f3),
              .mem_write(m_v && m_mw), .be(m_be), .wdata(m_wdata), .load_data(m_load));
  assign dmem_addr = m_alu; assign dmem_wdata = m_wdata; assign dmem_be = m_be; assign dmem_re = m_v && m_mr;
  wire [31:0] m_wb = (m_wb_sel == `WB_MEM) ? m_load : (m_wb_sel == `WB_PC4) ? m_pc + 32'd4 : m_alu;

  // MEM/WB (w_v, w_rw, w_rd, w_data declared above)
  reg        w_halt; reg [31:0] w_pc, w_ins, w_ma, w_mw; reg [3:0] w_be; reg w_mem;

  // ======================= pipeline registers =======================
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      pc <= RESET_PC; halt_pending <= 0; halted <= 0;
      d_v <= 0; d_pc <= 0; d_ins <= 32'h13;
      e_v <= 0; e_rw <= 0; e_mr <= 0; e_mw <= 0; e_br <= 0; e_jal <= 0; e_jalr <= 0; e_halt <= 0; e_b_imm <= 0;
      e_alu_op <= 0; e_a_sel <= 0; e_wb_sel <= 0; e_f3 <= 0; e_rs1 <= 0; e_rs2 <= 0; e_rd <= 0;
      e_pc <= 0; e_ins <= 0; e_imm <= 0; e_r1 <= 0; e_r2 <= 0;
      m_v <= 0; m_rw <= 0; m_mr <= 0; m_mw <= 0; m_halt <= 0; m_wb_sel <= 0; m_f3 <= 0; m_rd <= 0;
      m_pc <= 0; m_ins <= 0; m_alu <= 0; m_r2 <= 0;
      w_v <= 0; w_rw <= 0; w_rd <= 0; w_data <= 0; w_halt <= 0; w_pc <= 0; w_ins <= 0; w_ma <= 0; w_mw <= 0; w_be <= 0; w_mem <= 0;
    end else if (!halted) begin
      // ---- IF and IF/ID ----
      if (redirect) begin
        pc <= target; d_v <= 0;                                   // flush the instruction in IF
      end else if (!stall && !halt_pending) begin
        pc <= pc + 32'd4; d_v <= 1; d_pc <= pc; d_ins <= imem_rdata;
      end else if (halt_pending) d_v <= 0;
      // ---- ID/EX ----
      if (redirect || stall || !d_v) e_v <= 0;                    // flush / bubble
      else e_v <= 1;
      if (d_v && !redirect && !stall && (d_halt || d_ill)) halt_pending <= 1;
      e_rw <= d_rw; e_mr <= d_mr; e_mw <= d_mw; e_br <= d_br; e_jal <= d_jal; e_jalr <= d_jalr;
      e_halt <= d_halt || d_ill; e_b_imm <= d_b_imm; e_alu_op <= d_alu_op; e_a_sel <= d_a_sel; e_wb_sel <= d_wb_sel;
      e_f3 <= d_ins[14:12]; e_rs1 <= d_u1 ? d_rs1 : 5'd0; e_rs2 <= d_u2 ? d_rs2 : 5'd0; e_rd <= d_rd;
      e_pc <= d_pc; e_ins <= d_ins; e_imm <= d_imm; e_r1 <= d_r1; e_r2 <= d_r2;
      // ---- EX/MEM ----
      m_v <= e_v; m_rw <= e_rw; m_mr <= e_mr; m_mw <= e_mw; m_halt <= e_halt; m_wb_sel <= e_wb_sel; m_f3 <= e_f3;
      m_rd <= e_rd; m_pc <= e_pc; m_ins <= e_ins; m_alu <= e_alu; m_r2 <= e_op2;
      // ---- MEM/WB ----
      w_v <= m_v; w_rw <= m_rw && !m_halt; w_rd <= m_rd; w_data <= m_wb; w_halt <= m_halt;
      w_pc <= m_pc; w_ins <= m_ins; w_ma <= (m_mr || m_mw) ? m_alu : 32'h0; w_mw <= m_mw ? m_wdata : 32'h0;
      w_be <= m_be; w_mem <= m_mr || m_mw;
      // ---- halt when the ECALL/illegal reaches WB ----
      if (w_v && w_halt) halted <= 1;
    end

  // ======================= retirement (WB) =======================
  assign ret_valid     = w_v && !w_halt && !halted;
  assign ret_pc        = w_pc;
  assign ret_insn      = w_ins;
  assign ret_rd        = w_rw ? w_rd : 5'd0;
  assign ret_rd_wdata  = (w_rw && w_rd != 0) ? w_data : 32'h0;
  assign ret_mem_addr  = w_ma;
  assign ret_mem_wdata = w_mw;
  assign ret_mem_be    = w_be;
endmodule
