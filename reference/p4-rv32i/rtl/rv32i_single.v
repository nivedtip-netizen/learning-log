`timescale 1ns/1ps
`include "rv_defs.vh"
// Single-cycle RV32I core (Harvard ports onto one memory in the testbench).
// Every instruction finishes in one clock: fetch, decode, execute, memory and
// write-back all happen between two rising edges. Simple, slow (the critical
// path runs through instruction memory, ALU and data memory in one cycle).
// The retirement port reports every finished instruction for the reference-model check.
module rv32i_single #(parameter [31:0] RESET_PC = 32'h0) (
  input  wire        clk, rst_n,
  output wire [31:0] imem_addr, input wire [31:0] imem_rdata,
  output wire [31:0] dmem_addr, output wire [31:0] dmem_wdata, output wire [3:0] dmem_be,
  output wire        dmem_re,   input wire [31:0] dmem_rdata,
  output reg         halted,
  // retirement port
  output wire        ret_valid, output wire [31:0] ret_pc, ret_insn,
  output wire [4:0]  ret_rd,    output wire [31:0] ret_rd_wdata,
  output wire [31:0] ret_mem_addr, ret_mem_wdata, output wire [3:0] ret_mem_be
);
  reg [31:0] pc;
  wire [31:0] instr = imem_rdata;
  assign imem_addr = pc;

  // ---- decode ----
  wire [3:0] alu_op; wire [1:0] a_sel, wb_sel; wire b_imm, reg_write, mem_read, mem_write, branch, jal, jalr, halt, illegal;
  wire [2:0] imm_sel; wire u1, u2;
  rv_decoder dec (.instr(instr), .alu_op(alu_op), .a_sel(a_sel), .b_imm(b_imm), .imm_sel(imm_sel),
                  .reg_write(reg_write), .wb_sel(wb_sel), .mem_read(mem_read), .mem_write(mem_write),
                  .branch(branch), .jal(jal), .jalr(jalr), .halt(halt), .illegal(illegal), .uses_rs1(u1), .uses_rs2(u2));
  wire [31:0] imm; rv_immgen ig (.instr(instr), .sel(imm_sel), .imm(imm));
  wire [4:0] rs1 = instr[19:15], rs2 = instr[24:20], rd = instr[11:7];
  wire [31:0] r1, r2, wb_data;
  wire        we = reg_write && !halted && rst_n;
  rv_regfile rf (.clk(clk), .ra1(rs1), .ra2(rs2), .wa(rd), .we(we), .wd(wb_data), .rd1(r1), .rd2(r2));

  // ---- execute ----
  wire [31:0] alu_a = (a_sel == 2'd1) ? pc : (a_sel == 2'd2) ? 32'h0 : r1;
  wire [31:0] alu_b = b_imm ? imm : r2;
  wire [31:0] alu_y; rv_alu alu (.a(alu_a), .b(alu_b), .op(alu_op), .y(alu_y));
  wire taken; rv_branch bu (.a(r1), .b(r2), .funct3(instr[14:12]), .taken(taken));
  wire [31:0] pc4 = pc + 32'd4;
  wire [31:0] next_pc = jal ? pc + imm : jalr ? (alu_y & ~32'd1) : (branch && taken) ? pc + imm : pc4;

  // ---- memory ----
  wire [31:0] load_data; wire [3:0] be;
  rv_lsu lsu (.addr(alu_y), .store_data(r2), .mem_rdata(dmem_rdata), .funct3(instr[14:12]),
              .mem_write(mem_write && !halted), .be(be), .wdata(dmem_wdata), .load_data(load_data));
  assign dmem_addr = alu_y; assign dmem_be = be; assign dmem_re = mem_read;

  // ---- write-back ----
  assign wb_data = (wb_sel == `WB_MEM) ? load_data : (wb_sel == `WB_PC4) ? pc4 : alu_y;

  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin pc <= RESET_PC; halted <= 1'b0; end
    else if (!halted) begin
      if (halt || illegal) halted <= 1'b1;
      else pc <= next_pc;
    end

  // ---- retirement ----
  assign ret_valid     = rst_n && !halted && !halt && !illegal;
  assign ret_pc        = pc;
  assign ret_insn      = instr;
  assign ret_rd        = (reg_write) ? rd : 5'd0;
  assign ret_rd_wdata  = (reg_write && rd != 0) ? wb_data : 32'h0;
  assign ret_mem_addr  = (mem_read || mem_write) ? alu_y : 32'h0;
  assign ret_mem_wdata = mem_write ? dmem_wdata : 32'h0;
  assign ret_mem_be    = be;
endmodule
