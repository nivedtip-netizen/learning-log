// Assertions for the sync FIFO, kept out of the RTL and attached with bind.
// Port names match the FIFO's internal names, so `bind fifo fifo_checker chk (.*);` works.
module fifo_checker #(parameter int DEPTH = 16, A = $clog2(DEPTH)) (
  input logic clk, rst_n, push, pop, full, empty,
  input logic [A:0] wptr, rptr, count
);
  // (each property spells out its clock and reset so it also runs on Verilator 5.020,
  //  which does not support 'default disable iff')

  // 1. never full and empty together
  a_not_full_and_empty: assert property (@(posedge clk) disable iff (!rst_n) !(full && empty))
    else $error("full and empty both high");
  // 2. a push while full must not move the write pointer (memory is not written)
  a_no_write_when_full: assert property (@(posedge clk) disable iff (!rst_n) full && push && !pop |=> $stable(wptr))
    else $error("write pointer moved on a push while full");
  // 3. no push and no pop: the fill level must not change
  a_idle_count_stable:  assert property (@(posedge clk) disable iff (!rst_n) !push && !pop |=> $stable(count))
    else $error("count changed while idle");
  // 4. the fill level never goes above DEPTH
  a_count_in_range:     assert property (@(posedge clk) disable iff (!rst_n) count <= DEPTH)
    else $error("count out of range");
  // 5. flags agree with the fill level
  a_flags_match_count:  assert property (@(posedge clk) disable iff (!rst_n) (full == (count == DEPTH)) && (empty == (count == 0)))
    else $error("flags disagree with count");

  // cover: the interesting moments really happen
  c_full:          cover property (@(posedge clk) full);
  c_push_pop_full: cover property (@(posedge clk) full && push && pop);
`ifndef VERILATOR
  c_full_to_empty: cover property (@(posedge clk) full ##[1:$] empty);
`endif
endmodule

// Gray-pointer crossing check for the P1.4 async FIFO: the bus that crosses
// clock domains may change at most one bit per source clock.
module gray_checker #(parameter int W = 5) (input logic clk, rst_n, input logic [W-1:0] bus);
  a_one_bit_change: assert property (@(posedge clk) disable iff (!rst_n) $onehot0(bus ^ $past(bus)))
    else $error("crossing bus changed more than one bit: %b -> %b", $past(bus), bus);
endmodule
