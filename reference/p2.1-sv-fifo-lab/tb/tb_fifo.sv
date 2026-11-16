// P2.1 testbench: package + interface + clocking block + queue model + tasks.
// Run with a full SystemVerilog simulator (EDA Playground: Riviera-PRO, Questa, VCS, Xcelium).
//   +define+NO_CB  drives the DUT directly at the clock edge with blocking
//                  assignments (step 5: the race), instead of through the clocking block.
module tb_fifo;
  import fifo_pkg::*;
  logic clk = 0;
  always #5 clk = ~clk;

  fifo_if bus (clk);
  fifo dut (.clk(clk), .rst_n(bus.rst_n), .push(bus.push), .pop(bus.pop), .din(bus.din),
            .dout(bus.dout), .full(bus.full), .empty(bus.empty), .count(bus.count));

  data_t model_q [$];
  int    errors = 0, n_push = 0, n_pop = 0;

  // push one word (if not full) through the clocking block
  task automatic push(data_t d);
    @(bus.cb);
    bus.cb.push <= 1; bus.cb.din <= d;
    if (!bus.cb.full) begin model_q.push_back(d); n_push++; end
    @(bus.cb);
    bus.cb.push <= 0;
  endtask

  // pop one word and compare it with the model's oldest word
  task automatic pop();
    data_t exp;
    @(bus.cb);
    if (bus.cb.empty) return;
    exp = model_q.pop_front();
    if (bus.cb.dout !== exp) begin
      errors++;
      $error("pop: got %0h expected %0h", bus.cb.dout, exp);
    end
    bus.cb.pop <= 1; n_pop++;
    @(bus.cb);
    bus.cb.pop <= 0;
  endtask

`ifdef NO_CB
  // Step 5: drive at the same edge the DUT samples on. Whether the DUT sees the
  // old or the new 'push' depends on scheduling order: a race.
  task automatic push_racy(data_t d);
    @(posedge clk);
    bus.push = 1; bus.din = d;
    @(posedge clk);
    bus.push = 0;
  endtask
`endif

  initial begin
    bus.rst_n = 0;
    bus.cb.push <= 0; bus.cb.pop <= 0; bus.cb.din <= '0;
    repeat (3) @(posedge clk);
    bus.rst_n = 1;

`ifdef NO_CB
    push_racy(8'hAA);
    $display("NO_CB: count after racy push = %0d (look at the waveform: push and clk change in the same timestep)", bus.count);
`else
    // fill to full, one more push (dropped), drain to empty, one more pop (ignored)
    repeat (DEPTH + 1) push($urandom);
    if (!bus.full) begin errors++; $error("not full after %0d pushes", DEPTH); end
    repeat (DEPTH + 1) pop();
    if (!bus.empty) begin errors++; $error("not empty after drain"); end
    // random mix
    repeat (2000) begin
      if ($urandom_range(0, 1)) push($urandom); else pop();
    end
    while (model_q.size() > 0) pop();
    $display("pushes=%0d pops=%0d errors=%0d -> %s", n_push, n_pop, errors, errors ? "FAIL" : "PASS");
`endif
    $finish;
  end
endmodule
