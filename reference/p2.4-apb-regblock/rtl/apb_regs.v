`timescale 1ns/1ps
// APB4 slave register block (32-bit data, byte addresses, 8 registers).
//
//  addr  name        type  reset        notes
//  0x00  CTRL        RW    0x0000_0000  all bits RW, PSTRB honoured
//  0x04  STATUS      RO    -            mirrors hw_status input; writes ignored
//  0x08  INT_STATUS  W1C   0x0000_0000  bit i set by hw_event[i]; write 1 clears; set wins over clear
//  0x0C  INT_ENABLE  RW    0x0000_0000  irq = |(INT_STATUS & INT_ENABLE)
//  0x10  CMD         WO    -            a write pulses cmd_valid for one cycle with cmd_data; reads 0
//  0x14  SCRATCH     RW    0x0000_0000
//  0x18  VERSION     RO    0x0001_0200
//  0x1C  CONFIG      RW    0x0000_00FF  only bits [7:0] exist; bits [31:8] read 0
//  PSLVERR = 1 for an address above 0x1C or not 4-byte aligned (the access has no effect).
//  WAIT_STATES = number of cycles PREADY is held low in each access phase.
module apb_regs #(parameter WAIT_STATES = 0) (
  input  wire        pclk, presetn,
  input  wire        psel, penable, pwrite,
  input  wire [7:0]  paddr,
  input  wire [31:0] pwdata,
  input  wire [3:0]  pstrb,
  output reg  [31:0] prdata,
  output wire        pready,
  output wire        pslverr,
  input  wire [31:0] hw_status,
  input  wire [31:0] hw_event,
  output wire        irq,
  output reg         cmd_valid,
  output reg  [31:0] cmd_data,
  output wire [31:0] ctrl_o
);
  localparam CTRL = 3'd0, STATUS = 3'd1, INT_ST = 3'd2, INT_EN = 3'd3,
             CMD = 3'd4, SCRATCH = 3'd5, VERSION = 3'd6, CONFIG = 3'd7;

  reg [31:0] ctrl, int_st, int_en, scratch;
  reg [7:0]  config_r;

  // ---- wait states: count cycles in the access phase ----
  reg [7:0] wcnt;
  wire access = psel && penable;
  assign pready = (wcnt == WAIT_STATES);
  always @(posedge pclk or negedge presetn)
    if (!presetn)                 wcnt <= 0;
    else if (access && !pready)   wcnt <= wcnt + 1'b1;
    else if (access && pready)    wcnt <= 0;

`ifdef BUG_SLVERR
  wire bad_addr = (paddr > 8'h1C);                              // seeded bug: unaligned accepted
`else
  wire bad_addr = (paddr > 8'h1C) || (paddr[1:0] != 2'b00);
`endif
  assign pslverr = access && pready && bad_addr;
  wire wr_en = access && pready && pwrite && !bad_addr;
  wire [2:0] idx = paddr[4:2];

  function [31:0] strb_merge(input [31:0] old, input [31:0] nw, input [3:0] s);
    integer b; begin
`ifdef BUG_STRB
      strb_merge = nw;                                          // seeded bug: PSTRB ignored
`else
      for (b = 0; b < 4; b = b + 1) strb_merge[b*8 +: 8] = s[b] ? nw[b*8 +: 8] : old[b*8 +: 8];
`endif
    end endfunction

  always @(posedge pclk or negedge presetn)
    if (!presetn) begin
      ctrl <= 0; int_st <= 0; int_en <= 0; scratch <= 0; config_r <= 8'hFF;
      cmd_valid <= 0; cmd_data <= 0;
    end else begin
      cmd_valid <= 1'b0;
      if (wr_en)
        case (idx)
          CTRL:    ctrl    <= strb_merge(ctrl, pwdata, pstrb);
          INT_EN:  int_en  <= strb_merge(int_en, pwdata, pstrb);
          SCRATCH: scratch <= strb_merge(scratch, pwdata, pstrb);
          CONFIG:  if (pstrb[0]) config_r <= pwdata[7:0];
          CMD:     begin cmd_valid <= 1'b1; cmd_data <= pwdata; end
          default: ;                                             // STATUS, VERSION: read-only
        endcase
      // W1C: clear bits written as 1 (byte lanes per PSTRB), then new events set bits (set wins)
`ifdef BUG_W1C
      int_st <= (wr_en && idx == INT_ST) ? (pwdata | hw_event) : (int_st | hw_event);   // seeded bug: RW not W1C
`else
      int_st <= (int_st & ~((wr_en && idx == INT_ST) ? strb_merge(32'h0, pwdata, pstrb) : 32'h0)) | hw_event;
`endif
    end

  always @(*) begin
    prdata = 32'h0;
    if (psel && !pwrite && !bad_addr)
      case (idx)
        CTRL:    prdata = ctrl;
        STATUS:  prdata = hw_status;
        INT_ST:  prdata = int_st;
        INT_EN:  prdata = int_en;
        CMD:     prdata = 32'h0;
        SCRATCH: prdata = scratch;
        VERSION: prdata = 32'h0001_0200;
        CONFIG:  prdata = {24'h0, config_r};
      endcase
  end

  assign irq    = |(int_st & int_en);
  assign ctrl_o = ctrl;
endmodule
