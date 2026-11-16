`timescale 1ns/1ps
`ifndef WIN_NS
`define WIN_NS 1.0
`endif
// CDC library testbench. Clock periods TA, TB (ns) are parameters so the same
// bench runs fast->slow, slow->fast and near-equal. +SEED=, +N=.
// BAD_PULSE: the source ignores busy and sends pulses back to back -> pulses lost (expected FAIL).
module tb_cdc;
  parameter real TA = 10.0, TB = 27.0;
  reg clk_a = 0, clk_b = 0, arst_n = 0;
  always #(TA/2) clk_a = ~clk_a;
  initial begin #(TB/3); forever #(TB/2) clk_b = ~clk_b; end   // unrelated phase

  wire rst_a_n, rst_b_n;
  cdc_reset_sync ra (.clk(clk_a), .arst_n(arst_n), .rst_n(rst_a_n));
  cdc_reset_sync rb (.clk(clk_b), .arst_n(arst_n), .rst_n(rst_b_n));

  // ---------- pulse ----------
  reg pulse_a = 0; wire busy_p, pulse_b;
  cdc_pulse up (.clk_a(clk_a), .rst_a_n(rst_a_n), .pulse_a(pulse_a), .busy_a(busy_p),
                .clk_b(clk_b), .rst_b_n(rst_b_n), .pulse_b(pulse_b));
  // ---------- handshake ----------
  reg send_a = 0; reg [31:0] data_a = 0; wire busy_h, valid_b; wire [31:0] data_b;
  cdc_handshake #(32) uh (.clk_a(clk_a), .rst_a_n(rst_a_n), .send_a(send_a), .data_a(data_a), .busy_a(busy_h),
                          .clk_b(clk_b), .rst_b_n(rst_b_n), .valid_b(valid_b), .data_b(data_b));

  integer seed = 1, seed0, N = 300, errors = 0;
  integer p_sent = 0, p_recv = 0, h_sent = 0, h_recv = 0;
  reg [31:0] q [0:4095];

  always @(posedge clk_b) if (rst_b_n && pulse_b) p_recv = p_recv + 1;
  always @(posedge clk_b) if (rst_b_n && valid_b) begin
    if (data_b !== q[h_recv]) begin
      errors = errors + 1; $display("ERROR handshake word %0d: got %h exp %h", h_recv, data_b, q[h_recv]);
    end
    h_recv = h_recv + 1;
  end
  // check: the source holds its data stable while req is high (what makes the bus safe)
  reg [31:0] hold_prev; reg req_prev = 0;
  always @(posedge clk_a) begin
    if (req_prev && uh.req_a && uh.hold_a !== hold_prev) begin errors = errors + 1; $display("ERROR hold_a changed while req"); end
    req_prev <= uh.req_a; hold_prev <= uh.hold_a;
  end
  // check: a pulse is never sent while the synchronizer is busy (the input condition that breaks it)
  integer p_viol = 0;
  always @(posedge clk_a) if (rst_a_n && pulse_a && busy_p) p_viol = p_viol + 1;

  // ---------- reset synchronizer checks ----------
  // assert: rst_n must fall at once (asynchronously); deassert: rst_n rises only on a clock edge
  realtime t_edge_b = 0;
  always @(posedge clk_b) t_edge_b = $realtime;
  always @(posedge rst_b_n) if ($realtime != t_edge_b) begin errors = errors + 1; $display("ERROR rst_b_n rose off a clock edge"); end
  always @(negedge arst_n) #0.01 if (rst_a_n !== 1'b0 || rst_b_n !== 1'b0) begin
    errors = errors + 1; $display("ERROR reset not asserted asynchronously");
  end

  integer i, k, rst_tests = 0;
  initial begin
    if ($value$plusargs("SEED=%d", seed)) ; if ($value$plusargs("N=%d", N)) ;
    seed0 = seed;
    // reset test: release at random times, count edges until the synced reset is high
    for (k = 0; k < 20; k = k + 1) begin
      arst_n = 0; #($urandom(seed) % 97 + 3.3);
      arst_n = 1; #(($urandom(seed) % 50) / 10.0);
      repeat (3) @(posedge clk_b); #0.1;
      if (rst_b_n !== 1'b1) begin errors = errors + 1; $display("ERROR rst_b_n not high 3 edges after release"); end
      rst_tests = rst_tests + 1;
      #($urandom(seed) % 40 + 0.7);
    end
    repeat (4) @(posedge clk_a); repeat (4) @(posedge clk_b);
    // pulse and handshake traffic, both from clk_a
    fork
      for (i = 0; i < N; i = i + 1) begin
`ifdef BAD_PULSE
        @(negedge clk_a); pulse_a = 1; @(negedge clk_a); pulse_a = 0;            // back to back, ignores busy
`else
        @(negedge clk_a); while (busy_p) @(negedge clk_a);
        pulse_a = 1; @(negedge clk_a); pulse_a = 0;
        repeat ($urandom(seed) % 3) @(negedge clk_a);
`endif
        p_sent = p_sent + 1;
      end
      for (k = 0; k < N; k = k + 1) begin
        @(negedge clk_a); while (busy_h) @(negedge clk_a);
        data_a = $urandom(seed); q[k] = data_a; send_a = 1; @(negedge clk_a); send_a = 0;
        data_a = $urandom(seed);                                                  // source changes its bus right away
        h_sent = h_sent + 1;
      end
    join
    repeat (12) @(posedge clk_b); repeat (12) @(posedge clk_a); repeat (6) @(posedge clk_b);
    if (p_recv != p_sent) begin errors = errors + 1; $display("ERROR pulses sent %0d received %0d (sent while busy: %0d)", p_sent, p_recv, p_viol); end
    if (p_viol)           begin errors = errors + 1; $display("ERROR %0d pulses sent while the synchronizer was busy", p_viol); end
    if (h_recv != h_sent) begin errors = errors + 1; $display("ERROR words sent %0d received %0d", h_sent, h_recv); end
    $display("TA=%0.1f TB=%0.1f reset_tests=%0d pulses=%0d/%0d words=%0d/%0d", TA, TB, rst_tests, p_recv, p_sent, h_recv, h_sent);
    if (errors) $display("RESULT: FAIL errors=%0d seed=%0d", errors, seed0);
    else        $display("RESULT: PASS errors=0 seed=%0d", seed0);
    $finish;
  end
  initial begin #50_000_000; $display("RESULT: FAIL timeout"); $finish; end
endmodule
