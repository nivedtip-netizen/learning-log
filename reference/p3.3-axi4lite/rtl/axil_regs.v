`timescale 1ns/1ps
// AXI4-Lite slave: 16 x 32-bit register file at byte addresses 0x00-0x3C.
//  * write and read paths are independent
//  * AW and W are accepted in any order (each has a one-entry holding register);
//    the write happens once both are held and the B channel is free
//  * WSTRB selects which byte lanes are written
//  * addresses >= 0x40 answer SLVERR (writes ignored, reads return 0)
//  * one outstanding transaction per direction (no skid buffer: ~1 write per 2
//    cycles at best; see README for the throughput trade-off)
// Seeded bugs for the bug hunt (compile with +define+<name>):
//   BUG_WSTRB   ignore WSTRB          BUG_EARLY_B  BVALID before W arrived
//   BUG_RRESP   OKAY for bad address  BUG_B_DROP   BVALID dropped without BREADY
//   BUG_RDATA   RDATA changes while RVALID && !RREADY
module axil_regs (
  input  wire        aclk, aresetn,
  // write address
  input  wire        awvalid, input wire [7:0] awaddr, output wire awready,
  // write data
  input  wire        wvalid,  input wire [31:0] wdata, input wire [3:0] wstrb, output wire wready,
  // write response
  output reg         bvalid,  output reg [1:0] bresp, input wire bready,
  // read address
  input  wire        arvalid, input wire [7:0] araddr, output wire arready,
  // read data
  output reg         rvalid,  output reg [31:0] rdata, output reg [1:0] rresp, input wire rready
);
  localparam OKAY = 2'b00, SLVERR = 2'b10;
  reg [31:0] regs [0:15];

  // ---------------- write path ----------------
  reg        aw_full, w_full;
  reg [7:0]  aw_q;
  reg [31:0] w_q;
  reg [3:0]  s_q;
  assign awready = !aw_full;
  assign wready  = !w_full;
  wire aw_hs = awvalid && awready;
  wire w_hs  = wvalid  && wready;
  wire b_free = !bvalid || bready;
`ifdef BUG_EARLY_B
  wire do_write = aw_full && b_free;                       // does not wait for W
`else
  wire do_write = aw_full && w_full && b_free;
`endif
  wire wr_bad = (aw_q >= 8'h40);

  integer i, k;
  always @(posedge aclk or negedge aresetn)
    if (!aresetn) begin
      aw_full <= 0; w_full <= 0; aw_q <= 0; w_q <= 0; s_q <= 0; bvalid <= 0; bresp <= OKAY;
      for (i = 0; i < 16; i = i + 1) regs[i] <= 32'h0;
    end else begin
      if (aw_hs) begin aw_full <= 1'b1; aw_q <= awaddr; end
      if (w_hs)  begin w_full  <= 1'b1; w_q <= wdata; s_q <= wstrb; end
`ifdef BUG_B_DROP
      if (bvalid) bvalid <= 1'b0;                          // drops without waiting for BREADY
`else
      if (bvalid && bready) bvalid <= 1'b0;
`endif
      if (do_write) begin
        if (!wr_bad)
          for (k = 0; k < 4; k = k + 1)
`ifdef BUG_WSTRB
            regs[aw_q[5:2]][k*8 +: 8] <= w_q[k*8 +: 8];
`else
            if (s_q[k]) regs[aw_q[5:2]][k*8 +: 8] <= w_q[k*8 +: 8];
`endif
        bvalid  <= 1'b1;
        bresp   <= wr_bad ? SLVERR : OKAY;
        aw_full <= 1'b0;
        w_full  <= 1'b0;
      end
    end

  // ---------------- read path ----------------
  assign arready = !rvalid;
  wire ar_hs = arvalid && arready;
  always @(posedge aclk or negedge aresetn)
    if (!aresetn) begin rvalid <= 0; rdata <= 0; rresp <= OKAY; end
    else begin
      if (ar_hs) begin
        rvalid <= 1'b1;
        rdata  <= (araddr >= 8'h40) ? 32'h0 : regs[araddr[5:2]];
`ifdef BUG_RRESP
        rresp  <= OKAY;
`else
        rresp  <= (araddr >= 8'h40) ? SLVERR : OKAY;
`endif
      end else if (rvalid && rready) rvalid <= 1'b0;
`ifdef BUG_RDATA
      else if (rvalid) rdata <= rdata + 1;                 // payload not held
`endif
    end
endmodule
