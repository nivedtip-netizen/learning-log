`timescale 1ns/1ps
`include "rv_defs.vh"
// Main decoder: instruction -> control signals (datapath vs control split).
module rv_decoder (
  input  wire [31:0] instr,
  output reg  [3:0]  alu_op,
  output reg  [1:0]  a_sel,      // 0 rs1, 1 pc, 2 zero
  output reg         b_imm,      // 1: ALU b = immediate
  output reg  [2:0]  imm_sel,
  output reg         reg_write,
  output reg  [1:0]  wb_sel,
  output reg         mem_read, mem_write,
  output reg         branch, jal, jalr,
  output reg         halt,       // ECALL / EBREAK: stop the simulation
  output reg         illegal,
  output wire        uses_rs1, uses_rs2
);
  wire [6:0] opc = instr[6:0];
  wire [2:0] f3  = instr[14:12];
  wire       f7  = instr[30];
  always @(*) begin
    alu_op = `ALU_ADD; a_sel = 2'd0; b_imm = 1'b0; imm_sel = `IMM_I; reg_write = 1'b0; wb_sel = `WB_ALU;
    mem_read = 1'b0; mem_write = 1'b0; branch = 1'b0; jal = 1'b0; jalr = 1'b0; halt = 1'b0; illegal = 1'b0;
    case (opc)
      `OP_LUI:    begin a_sel = 2'd2; b_imm = 1; imm_sel = `IMM_U; reg_write = 1; end
      `OP_AUIPC:  begin a_sel = 2'd1; b_imm = 1; imm_sel = `IMM_U; reg_write = 1; end
      `OP_JAL:    begin jal = 1; imm_sel = `IMM_J; reg_write = 1; wb_sel = `WB_PC4; end
      `OP_JALR:   begin jalr = 1; b_imm = 1; imm_sel = `IMM_I; reg_write = 1; wb_sel = `WB_PC4; illegal = (f3 != 3'b000); end
      `OP_BRANCH: begin branch = 1; imm_sel = `IMM_B; illegal = (f3 == 3'b010 || f3 == 3'b011); end
      `OP_LOAD:   begin mem_read = 1; b_imm = 1; imm_sel = `IMM_I; reg_write = 1; wb_sel = `WB_MEM;
                        illegal = (f3 == 3'b011 || f3 == 3'b110 || f3 == 3'b111); end
      `OP_STORE:  begin mem_write = 1; b_imm = 1; imm_sel = `IMM_S; illegal = (f3 > 3'b010); end
      `OP_IMM:    begin b_imm = 1; imm_sel = `IMM_I; reg_write = 1;
                    case (f3)
                      3'b000: alu_op = `ALU_ADD;  3'b010: alu_op = `ALU_SLT;  3'b011: alu_op = `ALU_SLTU;
                      3'b100: alu_op = `ALU_XOR;  3'b110: alu_op = `ALU_OR;   3'b111: alu_op = `ALU_AND;
                      3'b001: alu_op = `ALU_SLL;
                      3'b101: alu_op = f7 ? `ALU_SRA : `ALU_SRL;
                    endcase
                  end
      `OP_REG:    begin reg_write = 1;
                    case (f3)
                      3'b000: alu_op = f7 ? `ALU_SUB : `ALU_ADD;
                      3'b001: alu_op = `ALU_SLL;  3'b010: alu_op = `ALU_SLT;  3'b011: alu_op = `ALU_SLTU;
                      3'b100: alu_op = `ALU_XOR;  3'b101: alu_op = f7 ? `ALU_SRA : `ALU_SRL;
                      3'b110: alu_op = `ALU_OR;   3'b111: alu_op = `ALU_AND;
                    endcase
                  end
      `OP_FENCE:  ;                                                   // no caches: a no-op
      `OP_SYSTEM: halt = 1;                                           // ECALL / EBREAK
      default:    illegal = 1;
    endcase
  end
  assign uses_rs1 = !(opc == `OP_LUI || opc == `OP_AUIPC || opc == `OP_JAL);
  assign uses_rs2 = (opc == `OP_BRANCH || opc == `OP_STORE || opc == `OP_REG);
endmodule
