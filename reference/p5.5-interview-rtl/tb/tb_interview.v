`timescale 1ns/1ps
// One self-checking bench for all eight interview blocks. Each block has its own
// reference model or rule in the testbench; the final line is RESULT: PASS|FAIL.
module tb_interview;
  reg clk = 0, rst_n = 0;
  always #5 clk = ~clk;
  integer seed = 1, seed0, errors = 0, i, r;
  task err(input [8*48-1:0] what); begin errors = errors + 1; if (errors < 4 || errors % 4000 == 0) $display("ERROR %0s at %0t", what, $time); end endtask

  // ---------------- 1. round-robin arbiter ----------------
  reg [3:0] req = 0; wire [3:0] gnt;
  rr_arbiter #(4) u_arb (clk, rst_n, req, gnt);
  integer last = 3, k, exp_i, wait_max = 0; integer waitc [0:3];
  always @(posedge clk) if (rst_n) begin
    exp_i = -1;
    for (k = 1; k <= 4; k = k + 1) if (exp_i < 0 && req[(last + k) % 4]) exp_i = (last + k) % 4;
    if (exp_i < 0 ? (gnt != 0) : (gnt != (4'b1 << exp_i))) err("arbiter grant");
    if (exp_i >= 0) last = exp_i;
    for (k = 0; k < 4; k = k + 1) begin
      waitc[k] = (req[k] && !gnt[k]) ? waitc[k] + 1 : 0;
      if (waitc[k] > wait_max) wait_max = waitc[k];
    end
  end

  // ---------------- 2. glitch-free clock mux ----------------
  reg c0 = 0, c1 = 0, sel = 0; wire cm;
  always #5   c0 = ~c0;                     // 100 MHz
  always #8.5 c1 = ~c1;                     // ~58.8 MHz
`ifdef BAD_MUX
  assign cm = sel ? c1 : c0;                // the naive mux: glitches when sel changes mid-phase
`else
  clk_mux_gf u_cm (c0, c1, rst_n, sel, cm);
`endif
  realtime t_last = 0, w, w_min = 1e9; integer switches = 0;
  always @(cm) if (rst_n) begin
    w = $realtime - t_last; t_last = $realtime;
    if (w < w_min) w_min = w;
    if (w < 4.99) err("clock mux glitch");  // shortest legal phase is 5 ns
  end

  // ---------------- 3. skid buffer ----------------
  reg iv = 0, ordy = 0; reg [7:0] id = 0; wire ir, ov; wire [7:0] od;
  skid_buffer #(8) u_skid (clk, rst_n, iv, ir, id, ov, ordy, od);
  reg [7:0] sq [0:4095]; integer s_in = 0, s_out = 0;
  always @(posedge clk) if (rst_n) begin
    if (ov && ordy) begin if (od !== sq[s_out % 4096]) err("skid data/order"); s_out = s_out + 1; end
    if (iv && ir) begin sq[s_in % 4096] = id; s_in = s_in + 1; end
  end
  // a stalled output must hold its word
  reg ov_q = 0, ordy_q = 0; reg [7:0] od_q;
  always @(posedge clk) begin
    if (rst_n && ov_q && !ordy_q && (!ov || od !== od_q)) err("skid output changed while stalled");
    ov_q <= ov; ordy_q <= ordy; od_q <= od;
  end

  // ---------------- 4. Gray counter ----------------
  function integer ones4(input [3:0] v); ones4 = v[0] + v[1] + v[2] + v[3]; endfunction
  reg gen = 0; wire [3:0] gray; reg [3:0] gray_q = 0, gbin = 0; integer gb;
  gray_counter #(4) u_gray (clk, rst_n, gen, gray);
  always @(posedge clk) if (rst_n) begin
    #1;
    if (gen_q) begin
      gbin = gbin + 1;
      if (ones4(gray ^ gray_q) != 1) begin err("gray: not exactly one bit changed"); if (errors < 3) $display("gray %b prev %b gbin %0d", gray, gray_q, gbin); end
      if (gray !== (gbin ^ (gbin >> 1))) err("gray value");
    end else if (gray !== gray_q) err("gray moved while disabled");
    gray_q = gray;
  end
  reg gen_q = 0; always @(posedge clk) gen_q <= gen;

  // ---------------- 5. pattern detector (10110, overlapping) ----------------
  reg pd = 0; wire hit; reg [4:0] ph = 0; integer pn = 0, hits = 0;
  pattern_det #(5, 5'b10110) u_pat (clk, rst_n, pd, hit);
  always @(posedge clk) if (rst_n) begin
    #1; ph = {ph[3:0], pd_q}; if (pn < 5) pn = pn + 1;
    if (hit !== (pn == 5 && ph == 5'b10110)) err("pattern detector");
    if (hit) hits = hits + 1;
  end
  reg pd_q = 0; always @(posedge clk) pd_q <= pd;

  // ---------------- 6. FIFO ----------------
  reg fw = 0, fr = 0; reg [7:0] fd = 0; wire [7:0] fq; wire ff, fe;
  fifo_min #(8, 8) u_fifo (clk, rst_n, fw, fr, fd, fq, ff, fe);
  reg [7:0] fm [0:8191]; integer fh = 0, ft = 0, fpops = 0;
  always @(posedge clk) if (rst_n) begin
    if (ff !== (ft - fh == 8) || fe !== (ft == fh)) err("fifo flags");
    if (fr && ft != fh) begin if (fq !== fm[fh % 8192]) err("fifo data"); fh = fh + 1; fpops = fpops + 1; end
    if (fw && ft - fh < 8 + (fr && !fe ? 1 : 0) && !ff) begin fm[ft % 8192] = fd; ft = ft + 1; end
  end

  // ---------------- 7. edge detector ----------------
  reg ed = 0; wire er, ef, ea; reg ed_q = 0;
  edge_detect u_edge (clk, rst_n, ed, er, ef, ea);
  always @(posedge clk) begin
    if (rst_n && (er !== (ed & !ed_q) || ef !== (!ed & ed_q) || ea !== (ed ^ ed_q))) err("edge detector");
    ed_q <= rst_n ? ed : 1'b0;
  end

  // ---------------- 8. clock dividers N = 2..7 ----------------
  wire [7:2] dclk;
  genvar g;
  generate for (g = 2; g <= 7; g = g + 1) begin : g_div
    clk_div_n #(g) u (clk, rst_n, dclk[g]);
    realtime tr = 0, tf = 0; integer nper = 0;
    always @(posedge dclk[g]) begin
      if (nper > 1 && ($realtime - tr) != g * 10.0) begin errors = errors + 1; $display("ERROR div%0d period %0.1f", g, $realtime - tr); end
      tr = $realtime; nper = nper + 1;
    end
    always @(negedge dclk[g]) if (nper > 1 && ($realtime - tr) != g * 5.0) begin
      errors = errors + 1; $display("ERROR div%0d high time %0.1f (want %0.1f)", g, $realtime - tr, g * 5.0);
    end
  end endgenerate

  // ---------------- stimulus ----------------
  initial begin
    if ($value$plusargs("SEED=%d", seed)) ;
    seed0 = seed;
    for (k = 0; k < 4; k = k + 1) waitc[k] = 0;
    #23 rst_n = 1;
    for (i = 0; i < 20000; i = i + 1) begin
      @(negedge clk);
      req = (i < 2000) ? 4'hF : $random(seed);             // first all-request (fairness), then random
      iv  = (i % 5000 < 500) ? 1'b1 : $random(seed); id = $random(seed);
      ordy = (i % 5000 < 500) ? 1'b1 : $random(seed);       // bursts at full rate, then random stalls
      gen = $random(seed); pd = $random(seed);
      fw = $random(seed); fr = $random(seed); fd = $random(seed);
      ed = $random(seed);
      if (i % 37 == 0) begin r = $random(seed) & 1; if (r != sel) switches = switches + 1; sel = r; end
    end
    repeat (5) @(negedge clk); iv = 0; ordy = 1; repeat (5) @(negedge clk);
    if (s_out != s_in) err("skid lost words");
    if (wait_max > 3) err("arbiter: a requester waited more than N-1 cycles");
    $display("arbiter max wait=%0d | clock mux %0d switches, shortest phase %0.1f ns | skid %0d words | pattern hits %0d | fifo %0d pops",
             wait_max, switches, w_min, s_out, hits, fpops);
    if (errors) $display("RESULT: FAIL errors=%0d seed=%0d", errors, seed0);
    else        $display("RESULT: PASS errors=0 seed=%0d", seed0);
    $finish;
  end
endmodule
