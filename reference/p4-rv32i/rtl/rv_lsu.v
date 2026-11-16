`timescale 1ns/1ps
// Load/store alignment for a 32-bit word memory with byte enables.
// funct3: 000 LB/SB, 001 LH/SH, 010 LW/SW, 100 LBU, 101 LHU. Accesses are assumed naturally aligned.
module rv_lsu (
  input  wire [31:0] addr, store_data, mem_rdata,
  input  wire [2:0]  funct3,
  input  wire        mem_write,
  output reg  [3:0]  be,
  output reg  [31:0] wdata,
  output reg  [31:0] load_data
);
  wire [1:0] off = addr[1:0];
  wire [7:0]  byte_v = mem_rdata >> (8 * off);
  wire [15:0] half_v = mem_rdata >> (8 * {off[1], 1'b0});
  always @(*) begin
    case (funct3[1:0])
      2'b00:   begin be = 4'b0001 << off;               wdata = {4{store_data[7:0]}};  end
      2'b01:   begin be = off[1] ? 4'b1100 : 4'b0011;   wdata = {2{store_data[15:0]}}; end
      default: begin be = 4'b1111;                      wdata = store_data;            end
    endcase
    if (!mem_write) be = 4'b0000;
    case (funct3)
      3'b000:  load_data = {{24{byte_v[7]}}, byte_v};
      3'b001:  load_data = {{16{half_v[15]}}, half_v};
      3'b100:  load_data = {24'b0, byte_v};
      3'b101:  load_data = {16'b0, half_v};
      default: load_data = mem_rdata;
    endcase
  end
endmodule
