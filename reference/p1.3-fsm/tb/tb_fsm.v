`timescale 1ns/1ps
// 1) 100,000 random bits into all four 1011 detectors, each checked every cycle
//    against a shift-register reference model.
// 2) traffic light: safety rules checked every cycle + every walk request served.
// 3) vending machine: 20,000 random coins against a running-total model.
module tb_fsm;
  reg clk = 0, rst_n = 0; always #5 clk = ~clk;
  integer errors = 0, i;
  reg x = 0;
  wire z_mo, z_mn, z_Mo, z_Mn, z_oh;
  det_mealy_ov  #(0) a (clk, rst_n, x, z_mo);
  det_mealy_ov  #(1) a1(clk, rst_n, x, z_oh);
  det_mealy_nov b (clk, rst_n, x, z_mn);
  det_moore_ov  c (clk, rst_n, x, z_Mo);
  det_moore_nov d (clk, rst_n, x, z_Mn);

  // reference models: history of bits since reset (ov) or since last match (nov)
  reg [3:0] h_ov = 0, h_nov = 0; integer n_ov = 0, n_nov = 0;
  reg moore_ov_exp = 0, moore_nov_exp = 0; integer n_match = 0;
  wire [3:0] nxt_ov  = {h_ov[2:0], x}, nxt_nov = {h_nov[2:0], x};
  wire mealy_ov_exp  = (n_ov  >= 3) && nxt_ov  == 4'b1011;
  wire mealy_nov_exp = (n_nov >= 3) && nxt_nov == 4'b1011;
  always @(negedge clk) if (rst_n) begin           // x is stable here; Mealy z valid
    if (z_mo !== mealy_ov_exp || z_oh !== mealy_ov_exp) begin errors = errors + 1; if (errors < 5) $display("mealy_ov ERR %0t", $time); end
    if (z_mn !== mealy_nov_exp) begin errors = errors + 1; if (errors < 5) $display("mealy_nov ERR %0t", $time); end
    if (z_Mo !== moore_ov_exp)  begin errors = errors + 1; if (errors < 5) $display("moore_ov ERR %0t", $time); end
    if (z_Mn !== moore_nov_exp) begin errors = errors + 1; if (errors < 5) $display("moore_nov ERR %0t", $time); end
  end
  always @(posedge clk) if (rst_n) begin
    moore_ov_exp  <= mealy_ov_exp;
    moore_nov_exp <= mealy_nov_exp;
    if (mealy_ov_exp) n_match = n_match + 1;
    h_ov <= nxt_ov; n_ov <= n_ov + 1;
    if (mealy_nov_exp) begin h_nov <= 0; n_nov <= 0; end
    else begin h_nov <= nxt_nov; n_nov <= n_nov + 1; end
  end

  // ---------------- traffic light ----------------
  reg ped = 0; wire [1:0] ns, ew; wire walk; wire [2:0] st;
  traffic #(.T_G(12), .T_MIN_G(4), .T_Y(3), .T_R(1), .T_WALK(6)) tl (clk, rst_n, ped, ns, ew, walk, st);
  integer wait_cyc = -1, max_wait = 0, walks = 0, g_len = 0; reg prev_ns_g = 0;
  always @(negedge clk) if (rst_n) begin
    if (ns != 2'b00 && ew != 2'b00) begin errors = errors + 1; $display("TL ERR: both roads not red"); end
    if (walk && (ns != 2'b00 || ew != 2'b00)) begin errors = errors + 1; $display("TL ERR: walk with traffic moving"); end
    if (ns == 2'b10) g_len = g_len + 1;
    else begin if (prev_ns_g && g_len < 4) begin errors = errors + 1; $display("TL ERR: green too short"); end g_len = 0; end
    prev_ns_g = (ns == 2'b10);
    if (walk) begin if (wait_cyc >= 0) walks = walks + 1; if (wait_cyc > max_wait) max_wait = wait_cyc; wait_cyc = -1; end
    else if (wait_cyc >= 0) wait_cyc = wait_cyc + 1;
    if (ped && wait_cyc < 0 && !walk) wait_cyc = 0;
    if (wait_cyc > 60) begin errors = errors + 1; $display("TL ERR: walk request starved"); wait_cyc = -1; end
  end

  // ---------------- vending machine ----------------
  reg [1:0] coin = 0; wire disp; wire [3:0] chg; wire [1:0] cr;
  vending vm (clk, rst_n, coin, disp, chg, cr);
  integer m_cr = 0, m_disp = 0, m_chg = 0, sold = 0, add;
  always @(posedge clk) if (rst_n) begin
    add = (coin == 1) ? 5 : (coin == 2) ? 10 : 0;
    if (m_cr + add >= 15) begin m_disp = 1; m_chg = m_cr + add - 15; m_cr = 0; sold = sold + 1; end
    else begin m_disp = 0; m_chg = 0; m_cr = m_cr + add; end
  end
  always @(negedge clk) if (rst_n)
    if (disp !== m_disp || chg !== m_chg || cr * 5 !== m_cr) begin errors = errors + 1; if (errors < 5) $display("VM ERR %0t", $time); end

  initial begin
    #22 rst_n = 1;
    for (i = 0; i < 100000; i = i + 1) begin
      @(posedge clk); #1;
      x = (i < 50000) ? $random : ($random % 4 != 0);   // second half biased to 1s
      ped = ($random % 50 == 0);
      coin = $random;
    end
    @(negedge clk);
    $display("detectors: %0d overlapping matches in 100000 bits", n_match);
    $display("traffic: %0d walk requests served, worst wait %0d cycles", walks, max_wait);
    $display("vending: %0d items sold", sold);
    if (errors == 0) $display("tb_fsm PASS"); else $display("tb_fsm FAIL errors=%0d", errors);
    $finish;
  end
endmodule
