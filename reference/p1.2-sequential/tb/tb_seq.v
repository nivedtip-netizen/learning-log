`timescale 1ns/1ps
// One self-checking bench for every P1.2 block. Each block has its own
// reference model updated on the same clock edge; checks happen at negedge.
module tb_seq;
  reg clk = 0, rst_n = 0;
  always #5 clk = ~clk;
  integer errors = 0, cyc = 0, i;
  task chk(input cond, input [8*24-1:0] name);
    if (!cond) begin errors = errors + 1; if (errors < 10) $display("ERR %0s t=%0t", name, $time); end
  endtask

  // stimulus regs
  reg d = 0, en = 0, up = 1, load = 0, sin = 0, sig = 0, btn = 0, sl = 0, sr = 0;
  reg [3:0] din4 = 0; reg [7:0] din8 = 0; reg [1:0] mode = 0;

  wire qs, qa, qe; dff_sync u1(clk, rst_n, d, qs); dff_async u2(clk, rst_n, d, qa); dff_en u3(clk, rst_n, en, d, qe);
  wire [3:0] ud; updown #(4) u4(clk, rst_n, en, up, load, din4, ud);
  wire [2:0] m6; modn #(6) u5(clk, rst_n, en, m6);
  wire [3:0] rg, jn; ring4 u6(clk, rst_n, rg); johnson4 u7(clk, rst_n, jn);
  wire [7:0] lf; lfsr8 u8(clk, rst_n, 8'hA5, lf);
  wire [7:0] sp; sipo #(8) u9(clk, rst_n, sin, sp);
  wire so; piso #(8) u10(clk, rst_n, load, din8, so);
  wire [7:0] us; ushift #(8) u11(clk, rst_n, mode, sl, sr, din8, us);
  wire ri, fa, an; edge_det u12(clk, rst_n, sig, ri, fa, an);
  wire o2, o4, o3; div2 u13(clk, rst_n, o2); div4 u14(clk, rst_n, o4); div3_50 u15(clk, rst_n, o3);
  wire db; debounce #(8) u16(clk, rst_n, btn, db);
  wire [3:0] ba, bb, na, nb; swap_blocking u17(clk, rst_n, ba, bb); swap_nonblocking u18(clk, rst_n, na, nb);

  // ---- reference models ----
  reg m_q = 0, m_qe = 0, m_prev = 0, m_db = 0, m_s1 = 0, m_s2 = 0;
  reg [3:0] m_ud = 0, m_rg = 1, m_jn = 0; reg [2:0] m_m6 = 0;
  reg [7:0] m_sp = 0, m_pr = 0, m_us = 0; integer m_cnt = 0;
  always @(posedge clk) if (rst_n) begin
    m_q <= d; if (en) m_qe <= d;
    m_ud <= load ? din4 : en ? (up ? m_ud + 1 : m_ud - 1) : m_ud;
    if (en) m_m6 <= (m_m6 == 5) ? 0 : m_m6 + 1;
    m_rg <= {m_rg[2:0], m_rg[3]}; m_jn <= {m_jn[2:0], ~m_jn[3]};
    m_sp <= {m_sp[6:0], sin};
    m_pr <= load ? din8 : {m_pr[6:0], 1'b0};
    case (mode) 1: m_us <= {m_us[6:0], sl}; 2: m_us <= {sr, m_us[7:1]}; 3: m_us <= din8; default: ; endcase
    m_prev <= sig;
    m_s1 <= btn; m_s2 <= m_s1;
    if (m_s2 == m_db) m_cnt <= 0; else if (m_cnt == 7) begin m_db <= m_s2; m_cnt <= 0; end else m_cnt <= m_cnt + 1;
  end

  always @(negedge clk) if (rst_n) begin
    cyc = cyc + 1;
    chk(qs === m_q && qa === m_q, "dff"); chk(qe === m_qe, "dff_en");
    chk(ud === m_ud, "updown"); chk(m6 === m_m6, "modn");
    chk(rg === m_rg, "ring"); chk(jn === m_jn, "johnson");
    chk(sp === m_sp, "sipo"); chk(so === m_pr[7], "piso"); chk(us === m_us, "ushift");
    chk(ri === (sig & ~m_prev) && fa === (~sig & m_prev) && an === (sig ^ m_prev), "edge");
    chk(db === m_db, "debounce");
  end

  // ---- LFSR period: count cycles until seed returns, and distinct states ----
  reg [255:0] seen; integer lf_period = 0, lf_distinct = 0; reg lf_done = 0;
  initial seen = 0;
  always @(posedge clk) if (rst_n && !lf_done) begin
    #1;
    if (!seen[lf]) begin seen[lf] = 1; lf_distinct = lf_distinct + 1; end
    lf_period = lf_period + 1;
    if (lf == 8'hA5) lf_done = 1;
  end

  // ---- clock divider period / duty measurement (in ns) ----
  real r3, f3, p3, h3; integer n3 = 0;
  always @(posedge o3) begin if (n3 > 0) p3 = $realtime - r3; r3 = $realtime; n3 = n3 + 1; end
  always @(negedge o3) h3 = $realtime - r3;
  real r2, p2, r4, p4; integer n2 = 0, n4 = 0;
  always @(posedge o2) begin if (n2 > 0) p2 = $realtime - r2; r2 = $realtime; n2 = n2 + 1; end
  always @(posedge o4) begin if (n4 > 0) p4 = $realtime - r4; r4 = $realtime; n4 = n4 + 1; end

  initial begin
    $dumpfile("seq.vcd"); $dumpvars(0, tb_seq);
    #22 rst_n = 1;
    // check race demo after 3 clocks
    repeat (3) @(posedge clk); #1;
    $display("race demo after 3 clocks: blocking a=%0d b=%0d | nonblocking a=%0d b=%0d", ba, bb, na, nb);
    chk(ba == 2 && bb == 2, "blocking swap"); chk(na == 2 && nb == 1, "nb swap");
    for (i = 0; i < 3000; i = i + 1) begin
      @(posedge clk); #1;
      d = $random; en = ($random % 4 != 0); up = $random; load = ($random % 13 == 0);
      din4 = $random; din8 = $random; sin = $random; mode = $random; sl = $random; sr = $random;
      sig = $random;
      if (i % 40 < 20) btn = (i % 40 < 3) ? $random : 1; else btn = (i % 40 < 23) ? $random : 0; // bouncy edges
    end
    $display("LFSR: period=%0d distinct=%0d (expect 255 255)", lf_period, lf_distinct);
    chk(lf_period == 255 && lf_distinct == 255, "lfsr");
    $display("div2 period=%0.1f div4 period=%0.1f div3 period=%0.1f high=%0.1f (clk=10ns)", p2, p4, p3, h3);
    chk(p2 == 20 && p4 == 40 && p3 == 30 && h3 == 15, "clkdiv");
    if (errors == 0) $display("tb_seq PASS (%0d cycles)", cyc); else $display("tb_seq FAIL errors=%0d", errors);
    $finish;
  end
endmodule
