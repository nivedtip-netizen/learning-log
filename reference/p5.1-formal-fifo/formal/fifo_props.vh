// Formal properties for sync_fifo, included inside the module under `ifdef FORMAL
// (SymbiYosys style: immediate assertions in always blocks, $past, past_valid).
// Top-level inputs (push, pop, din, rst_n) are free: the solver picks any value every cycle.

  reg f_past_valid = 1'b0;
  always @(posedge clk) f_past_valid <= 1'b1;

  // start in reset; after that rst_n is free (reset can come back at any time)
  always @(*) if (!f_past_valid) assume(!rst_n);

  // ---- state invariants (true in every reachable state) ----
  always @(*) if (f_past_valid && rst_n) begin
    a_count_range: assert(count <= DEPTH);
    a_full_flag:   assert(full  == (count == DEPTH));
    a_empty_flag:  assert(empty == (count == 0));
    a_not_both:    assert(!(full && empty));
  end

  // ---- step properties (what one clock edge may do) ----
  always @(posedge clk) if (f_past_valid && $past(rst_n) && rst_n) begin
    // no overflow: a push while full does not move the write pointer
    if ($past(push && full)) a_no_overflow:  assert(wptr == $past(wptr));
    // no underflow: a pop while empty does not move the read pointer
    if ($past(pop && empty)) a_no_underflow: assert(rptr == $past(rptr));
    // every accepted pop moves the read pointer by exactly one
    a_rptr_step: assert(rptr == $past(rptr) + ($past(pop && !empty) ? 1'b1 : 1'b0));
    a_wptr_step: assert(wptr == $past(wptr) + ($past(push && !full) ? 1'b1 : 1'b0));
    // flags come out of the right pulses
    a_ovf_flag: assert(overflow  == $past(push && full));
    a_udf_flag: assert(underflow == $past(pop && empty));
  end

`ifndef NO_COVER
  // ---- reachability: show me a trace where this happens ----
  reg f_was_full = 1'b0;
  always @(posedge clk) if (!rst_n) f_was_full <= 1'b0; else if (full) f_was_full <= 1'b1;
  always @(*) if (rst_n) begin
    c_full:          cover(full);
    c_full_to_empty: cover(f_was_full && empty);
  end
`endif
