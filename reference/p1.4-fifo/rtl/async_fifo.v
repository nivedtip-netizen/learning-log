`timescale 1ns/1ps
// Dual-clock FIFO (Cummings style). Each side keeps a binary pointer for
// addressing and a Gray copy that crosses to the other clock through sync2.
//   full  is computed in the write domain: wgray == {~rgray_sync[A:A-1], rgray_sync[A-2:0]}
//   empty is computed in the read  domain: rgray == wgray_sync
// Both flags are pessimistic (late to clear), never wrong. BUG_BIN=1 is the
// seeded bug: binary pointers are synchronized instead of Gray.
module async_fifo #(parameter W = 8, DEPTH = 16, BUG_BIN = 0) (
  input  wire         wclk, wrst_n, push, input wire [W-1:0] din, output wire full,
  input  wire         rclk, rrst_n, pop,  output wire [W-1:0] dout, output wire empty,
  output wire [$clog2(DEPTH):0] rcount            // fill level as the read side sees it
);
  localparam A = $clog2(DEPTH);
  reg  [W-1:0] mem [0:DEPTH-1];
  reg  [A:0] wbin, rbin, wgray, rgray;
  wire [A:0] wq_r, rq_w;                       // synchronized copies

  function [A:0] b2g(input [A:0] b); b2g = b ^ (b >> 1); endfunction
  function [A:0] g2b(input [A:0] g); integer k; begin
    g2b[A] = g[A]; for (k = A-1; k >= 0; k = k - 1) g2b[k] = g2b[k+1] ^ g[k]; end endfunction

  // ---- write domain ----
  wire [A:0] rq_w_gray = BUG_BIN ? b2g(rq_w) : rq_w;   // what the read pointer looks like as Gray
  assign full = (wgray == {~rq_w_gray[A:A-1], rq_w_gray[A-2:0]});
  wire [A:0] wbin_n = wbin + {{A{1'b0}}, (push && !full)};
  always @(posedge wclk) if (push && !full) mem[wbin[A-1:0]] <= din;
  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n) begin wbin <= 0; wgray <= 0; end
    else begin wbin <= wbin_n; wgray <= b2g(wbin_n); end

  // ---- read domain ----
  wire [A:0] wq_r_gray = BUG_BIN ? b2g(wq_r) : wq_r;
  assign empty = (rgray == wq_r_gray);
  assign dout  = mem[rbin[A-1:0]];
  assign rcount = g2b(wq_r_gray) - rbin;
  wire [A:0] rbin_n = rbin + {{A{1'b0}}, (pop && !empty)};
  always @(posedge rclk or negedge rrst_n)
    if (!rrst_n) begin rbin <= 0; rgray <= 0; end
    else begin rbin <= rbin_n; rgray <= b2g(rbin_n); end

  // ---- crossings ----
  sync2 #(A+1) u_w2r (.clk(rclk), .rst_n(rrst_n), .d(BUG_BIN ? wbin : wgray), .q(wq_r));
  sync2 #(A+1) u_r2w (.clk(wclk), .rst_n(wrst_n), .d(BUG_BIN ? rbin : rgray), .q(rq_w));
endmodule
