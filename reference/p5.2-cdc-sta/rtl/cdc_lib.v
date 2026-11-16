`timescale 1ns/1ps
// Small CDC library: 2-flop synchronizer, pulse (toggle) synchronizer,
// req/ack handshake synchronizer for a multi-bit bus, reset synchronizer.

// ---- 2-flop synchronizer for one level signal ----
module cdc_sync2 #(parameter RST_VAL = 1'b0) (
  input wire clk, rst_n, d, output wire q
);
  (* ASYNC_REG = "TRUE" *) reg s1, s2;
`ifdef META
  // simulation-only metastability model: if d changed less than WIN_NS before the
  // edge, the first flop resolves to a random value (old or new). A correct design
  // must work for either outcome; this only shifts arrival by one cycle.
  realtime t_d = 0; integer seed = 7;
  always @(d) t_d = $realtime;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) {s1, s2} <= {2{RST_VAL}};
    else begin
      s1 <= ($realtime - t_d < `WIN_NS) ? ($random(seed) & 1) : d;
      s2 <= s1;
    end
`else
  always @(posedge clk or negedge rst_n)
    if (!rst_n) {s1, s2} <= {2{RST_VAL}};
    else        {s1, s2} <= {d, s1};
`endif
  assign q = s2;
endmodule

// ---- pulse synchronizer (toggle based) ----
// A 1-cycle pulse in clk_a becomes a 1-cycle pulse in clk_b.
// Breaks if two pulses arrive closer than about 3 clk_b cycles: the toggle
// flips twice before clk_b samples it and both pulses vanish. 'busy' tells the
// source to wait; 'drop' (simulation check) flags a pulse sent while busy.
module cdc_pulse (
  input  wire clk_a, rst_a_n, pulse_a,
  output wire busy_a,
  input  wire clk_b, rst_b_n,
  output wire pulse_b
);
  reg tog_a;
  always @(posedge clk_a or negedge rst_a_n)
    if (!rst_a_n) tog_a <= 1'b0; else if (pulse_a) tog_a <= ~tog_a;

  wire tog_b; reg tog_b_d;
  cdc_sync2 s_ab (.clk(clk_b), .rst_n(rst_b_n), .d(tog_a), .q(tog_b));
  always @(posedge clk_b or negedge rst_b_n)
    if (!rst_b_n) tog_b_d <= 1'b0; else tog_b_d <= tog_b;
  assign pulse_b = tog_b ^ tog_b_d;

  // feedback: busy until the toggle has come back into clk_a
  wire tog_back;
  cdc_sync2 s_ba (.clk(clk_a), .rst_n(rst_a_n), .d(tog_b_d), .q(tog_back));
  assign busy_a = tog_a ^ tog_back;
endmodule

// ---- req/ack handshake for a W-bit bus (4-phase) ----
// Source: when idle and send=1, latch data, raise req. Hold data stable.
// Dest:   sees req (synced), captures data (stable for >= 2 cycles), pulses valid, raises ack.
// Source: sees ack (synced), drops req.  Dest: sees req low, drops ack.  Source: sees ack low -> idle.
module cdc_handshake #(parameter W = 32) (
  input  wire         clk_a, rst_a_n,
  input  wire         send_a,             // request a transfer (ignored while busy)
  input  wire [W-1:0] data_a,
  output wire         busy_a,
  input  wire         clk_b, rst_b_n,
  output reg          valid_b,            // 1-cycle pulse with data_b
  output reg  [W-1:0] data_b
);
  reg req_a; reg [W-1:0] hold_a; wire ack_in_a;
  reg ack_b; wire req_in_b;
  cdc_sync2 s_req (.clk(clk_b), .rst_n(rst_b_n), .d(req_a), .q(req_in_b));
  cdc_sync2 s_ack (.clk(clk_a), .rst_n(rst_a_n), .d(ack_b), .q(ack_in_a));

  // source FSM: busy from send until ack has gone low again
  always @(posedge clk_a or negedge rst_a_n)
    if (!rst_a_n) begin req_a <= 1'b0; hold_a <= {W{1'b0}}; end
    else if (!req_a && !ack_in_a && send_a) begin req_a <= 1'b1; hold_a <= data_a; end
    else if (req_a && ack_in_a) req_a <= 1'b0;
  assign busy_a = req_a || ack_in_a;

  // destination: capture on the rising edge of the synced req
  always @(posedge clk_b or negedge rst_b_n)
    if (!rst_b_n) begin ack_b <= 1'b0; valid_b <= 1'b0; data_b <= {W{1'b0}}; end
    else begin
      valid_b <= 1'b0;
      if (req_in_b && !ack_b) begin data_b <= hold_a; valid_b <= 1'b1; ack_b <= 1'b1; end  // hold_a stable here
      else if (!req_in_b && ack_b) ack_b <= 1'b0;
    end
endmodule

// ---- reset synchronizer: asynchronous assert, synchronous deassert ----
module cdc_reset_sync (
  input wire clk, arst_n, output wire rst_n
);
  (* ASYNC_REG = "TRUE" *) reg r1, r2;
  always @(posedge clk or negedge arst_n)
    if (!arst_n) {r1, r2} <= 2'b00;
    else         {r1, r2} <= {1'b1, r1};
  assign rst_n = r2;
endmodule
