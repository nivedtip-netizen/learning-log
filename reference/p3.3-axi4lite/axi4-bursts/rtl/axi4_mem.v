`timescale 1ns/1ps
// AXI4 (full) memory slave with bursts: 1 KB (256 x 32-bit), data width 32.
//  * burst types FIXED (00), INCR (01), WRAP (10); AxLEN 0-255 (WRAP: 1, 3, 7, 15)
//  * AxSIZE must be 2 (4 bytes); other sizes are answered with SLVERR
//  * IDs are echoed on B and R; one outstanding burst per direction
//  * WSTRB per beat; WLAST is checked (a missing/extra WLAST gives SLVERR)
//  * a burst touching an address >= 0x400 answers SLVERR (writes ignored, reads 0)
// Not handled (documented): 4 KB boundary errors, narrow transfers, exclusive access, interleaving.
module axi4_mem #(parameter IDW = 4) (
  input  wire aclk, aresetn,
  input  wire           awvalid, input wire [IDW-1:0] awid, input wire [15:0] awaddr, input wire [7:0] awlen,
  input  wire [2:0]     awsize,  input wire [1:0] awburst, output wire awready,
  input  wire           wvalid,  input wire [31:0] wdata, input wire [3:0] wstrb, input wire wlast, output wire wready,
  output reg            bvalid,  output reg [IDW-1:0] bid, output reg [1:0] bresp, input wire bready,
  input  wire           arvalid, input wire [IDW-1:0] arid, input wire [15:0] araddr, input wire [7:0] arlen,
  input  wire [2:0]     arsize,  input wire [1:0] arburst, output wire arready,
  output reg            rvalid,  output reg [IDW-1:0] rid, output reg [31:0] rdata, output reg [1:0] rresp,
  output reg            rlast,   input wire rready
);
  localparam FIXED = 2'b00, INCR = 2'b01, WRAP = 2'b10;
  reg [31:0] mem [0:255];

  // next beat address for a 4-byte transfer
  function [15:0] next_addr(input [15:0] a, input [1:0] burst, input [7:0] len);
    reg [15:0] wrap_bytes, lower; begin
      wrap_bytes = ({8'h0, len} + 16'd1) << 2;
      lower      = a & ~(wrap_bytes - 16'd1);
      case (burst)
        FIXED:   next_addr = a;
        WRAP:    next_addr = (a + 16'd4 == lower + wrap_bytes) ? lower : a + 16'd4;
        default: next_addr = a + 16'd4;
      endcase
    end endfunction

  // ---------------- write burst ----------------
  reg        w_act; reg [15:0] w_addr; reg [7:0] w_len, w_cnt; reg [1:0] w_burst; reg w_err; reg [IDW-1:0] w_id;
  assign awready = !w_act && !bvalid;
  assign wready  = w_act;
  integer k;
  always @(posedge aclk or negedge aresetn)
    if (!aresetn) begin w_act <= 0; bvalid <= 0; bid <= 0; bresp <= 0; w_addr <= 0; w_len <= 0; w_cnt <= 0; w_burst <= 0; w_err <= 0; w_id <= 0; end
    else begin
      if (bvalid && bready) bvalid <= 0;
      if (awvalid && awready) begin
        w_act <= 1; w_addr <= awaddr; w_len <= awlen; w_cnt <= 0; w_burst <= awburst; w_id <= awid;
        w_err <= (awsize != 3'd2) || (awburst == 2'b11) ||
                 (awburst == WRAP && !(awlen == 1 || awlen == 3 || awlen == 7 || awlen == 15));
      end
      if (wvalid && wready) begin
        if (!w_err && w_addr < 16'h400)
          for (k = 0; k < 4; k = k + 1) if (wstrb[k]) mem[w_addr[9:2]][k*8 +: 8] <= wdata[k*8 +: 8];
        w_addr <= next_addr(w_addr, w_burst, w_len);
        w_cnt  <= w_cnt + 1'b1;
        if (w_addr >= 16'h400 || (wlast != (w_cnt == w_len))) w_err <= 1;
        if (wlast || w_cnt == w_len) begin
          w_act <= 0; bvalid <= 1; bid <= w_id;
          bresp <= (w_err || w_addr >= 16'h400 || (wlast != (w_cnt == w_len))) ? 2'b10 : 2'b00;
        end
      end
    end

  // ---------------- read burst ----------------
  reg        r_act; reg [15:0] r_addr; reg [7:0] r_len, r_cnt; reg [1:0] r_burst; reg r_err;
  assign arready = !r_act;
  wire [15:0] r_next = next_addr(r_addr, r_burst, r_len);
  always @(posedge aclk or negedge aresetn)
    if (!aresetn) begin r_act <= 0; rvalid <= 0; rid <= 0; rdata <= 0; rresp <= 0; rlast <= 0;
                        r_addr <= 0; r_len <= 0; r_cnt <= 0; r_burst <= 0; r_err <= 0; end
    else begin
      if (arvalid && arready) begin
        r_act <= 1; r_addr <= araddr; r_len <= arlen; r_cnt <= 0; r_burst <= arburst; rid <= arid;
        r_err <= (arsize != 3'd2) || (arburst == 2'b11) ||
                 (arburst == WRAP && !(arlen == 1 || arlen == 3 || arlen == 7 || arlen == 15));
        rvalid <= 0;
      end else if (r_act && (!rvalid || rready)) begin
        if (rvalid && rlast) begin r_act <= 0; rvalid <= 0; rlast <= 0; end     // last beat accepted
        else begin
          // present beat r_cnt
          rvalid <= 1;
          rdata  <= (r_err || r_addr >= 16'h400) ? 32'h0 : mem[r_addr[9:2]];
          rresp  <= (r_err || r_addr >= 16'h400) ? 2'b10 : 2'b00;
          rlast  <= (r_cnt == r_len);
          r_addr <= r_next;
          r_cnt  <= r_cnt + 1'b1;
        end
      end
    end
endmodule
