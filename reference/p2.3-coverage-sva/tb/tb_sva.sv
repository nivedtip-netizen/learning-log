// Random traffic in phases (fill, drain, mixed, idle) with the checker bound in.
// Also counts the same bins as fifo_cov.sv by hand ("coverage lite"), so the
// coverage numbers can be printed even on simulators without covergroups (Verilator).
module tb_sva;
  import fifo_pkg::*;
  logic clk = 0, rst_n = 0, push = 0, pop = 0; data_t din = 0, dout;
  logic full, empty; logic [$clog2(DEPTH):0] count;
  always #5 clk = ~clk;
  fifo dut (.*);
  bind fifo fifo_checker #(.DEPTH(fifo_pkg::DEPTH)) chk (.*);
`ifdef WITH_COVERGROUPS
  bind fifo fifo_cov #(.DEPTH(fifo_pkg::DEPTH)) cov (.*);
`endif

  // ---- coverage lite: 5 count bins + 8 push/pop/full + 8 push/pop/empty + 2 transitions = 23 bins
  int hit_count[5], hit_ppf[8], hit_ppe[8], hit_exit = 0, hit_enter = 0;
  logic full_q = 0;
  always @(posedge clk) if (rst_n) begin
    hit_count[(count == 0) ? 0 : (count == 1) ? 1 : (count == DEPTH) ? 4 : (count == DEPTH-1) ? 3 : 2]++;
    hit_ppf[{push, pop, full}]++;
    hit_ppe[{push, pop, empty}]++;
    if (full_q && !full) hit_exit++;
    if (!full_q && full) hit_enter++;
    full_q <= full;
  end
  function automatic real coverage_pct();
    int covered = 0;
    foreach (hit_count[i]) covered += (hit_count[i] > 0);
    foreach (hit_ppf[i])   covered += (hit_ppf[i] > 0);
    foreach (hit_ppe[i])   covered += (hit_ppe[i] > 0);
    covered += (hit_exit > 0) + (hit_enter > 0);
    return 100.0 * covered / 23.0;
  endfunction

  initial begin
    int phase;
    repeat (3) @(posedge clk); rst_n = 1;
    for (int i = 0; i < 20000; i++) begin
      @(negedge clk);
      phase = (i / 300) % 4;
      case (phase)
        0: begin push = ($urandom_range(0, 9) < 8); pop = ($urandom_range(0, 9) < 2); end  // fill
        1: begin push = ($urandom_range(0, 9) < 2); pop = ($urandom_range(0, 9) < 8); end  // drain
        2: begin push = $urandom_range(0, 1);       pop = $urandom_range(0, 1);       end  // mixed
        3: begin push = ($urandom_range(0, 9) < 5); pop = 0; if (i % 7 == 0) push = 0; end // idle gaps
      endcase
      din = $urandom;
    end
    @(negedge clk); push = 0; pop = 0;
    $display("coverage lite = %0.1f%% (23 bins)", coverage_pct());
    foreach (hit_ppf[i]) if (hit_ppf[i] == 0) $display("  hole: push/pop/full = %03b", i[2:0]);
    foreach (hit_ppe[i]) if (hit_ppe[i] == 0) $display("  hole: push/pop/empty = %03b", i[2:0]);
    $display("tb_sva done"); $display("RESULT: PASS (no assertion fired)");
    $finish;
  end
endmodule
