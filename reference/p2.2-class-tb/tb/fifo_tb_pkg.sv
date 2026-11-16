// P2.2: a layered, class-based testbench for the FIFO ("UVM by hand").
//   generator -> mailbox -> driver -> DUT pins -> monitor -> mailbox -> scoreboard
package fifo_tb_pkg;
  import fifo_pkg::*;

  // ---------------- transaction ----------------
  typedef enum {PAT_RANDOM, PAT_ZERO, PAT_ONES, PAT_ALT} pat_e;
  class fifo_txn;
    rand bit    push, pop;
    rand data_t data;
    rand pat_e  pat;
    int push_w = 70, pop_w = 50;            // knobs the tests turn
    constraint c_mix  { push dist {1 := push_w, 0 := 100 - push_w};
                        pop  dist {1 := pop_w,  0 := 100 - pop_w}; }
    constraint c_pat  { pat dist {PAT_RANDOM := 70, PAT_ZERO := 10, PAT_ONES := 10, PAT_ALT := 10}; }
    constraint c_data { pat == PAT_ZERO -> data == '0;
                        pat == PAT_ONES -> data == '1;
                        pat == PAT_ALT  -> data inside {8'h55, 8'hAA}; }
    function string sprint();
      return $sformatf("push=%0b pop=%0b data=%02h", push, pop, data);
    endfunction
  endclass

  // what the monitor saw in one clock
  class fifo_obs;
    bit push_ok, pop_ok; data_t din, dout; bit full, empty;
  endclass

  // ---------------- generator ----------------
  class generator;
    mailbox #(fifo_txn) gen2drv;
    int n = 1000, push_w = 70, pop_w = 50;
    event done;
    function new(mailbox #(fifo_txn) m); gen2drv = m; endfunction
    task run();
      repeat (n) begin
        fifo_txn t = new();
        t.push_w = push_w; t.pop_w = pop_w;
        if (!t.randomize()) $fatal(1, "randomize failed");
        gen2drv.put(t);
      end
      -> done;
    endtask
  endclass

  // ---------------- driver ----------------
  class driver;
    virtual fifo_if vif;
    mailbox #(fifo_txn) gen2drv;
    int driven = 0;
    function new(virtual fifo_if v, mailbox #(fifo_txn) m); vif = v; gen2drv = m; endfunction
    task run();
      fifo_txn t;
      forever begin
        gen2drv.get(t);
        @(vif.cb);
        vif.cb.push <= t.push; vif.cb.pop <= t.pop; vif.cb.din <= t.data;
        driven++;
      end
    endtask
  endclass

  // ---------------- monitor ----------------
  // Watches the pins only. A push/pop "happened" if it was requested and allowed.
  class monitor;
    virtual fifo_if vif;
    mailbox #(fifo_obs) mon2sb;
    function new(virtual fifo_if v, mailbox #(fifo_obs) m); vif = v; mon2sb = m; endfunction
    task run();
      forever begin
        fifo_obs o = new();
        @(posedge vif.clk);
        if (!vif.rst_n) continue;
        o.push_ok = vif.push && !vif.full;
        o.pop_ok  = vif.pop  && !vif.empty;
        o.din = vif.din; o.dout = vif.dout; o.full = vif.full; o.empty = vif.empty;
        mon2sb.put(o);
      end
    endtask
  endclass

  // ---------------- scoreboard ----------------
  // Its own queue model decides what full/empty/dout must be. It does not trust the DUT's flags.
  class scoreboard;
    mailbox #(fifo_obs) mon2sb;
    data_t q[$];
    int errors = 0, pops = 0, pushes = 0;
    function new(mailbox #(fifo_obs) m); mon2sb = m; endfunction
    function void reset(); q.delete(); endfunction
    task run();
      fifo_obs o;
      forever begin
        mon2sb.get(o);
        if (o.full  !== (q.size() == DEPTH)) report($sformatf("full=%0b but model holds %0d", o.full, q.size()));
        if (o.empty !== (q.size() == 0))     report($sformatf("empty=%0b but model holds %0d", o.empty, q.size()));
        if (o.pop_ok) begin
          data_t exp = q.pop_front();
          if (o.dout !== exp) report($sformatf("pop data %02h, expected %02h", o.dout, exp));
          pops++;
        end
        if (o.push_ok) begin q.push_back(o.din); pushes++; end
      end
    endtask
    function void report(string s);
      errors++;
      if (errors <= 10) $display("[%0t] SCOREBOARD MISMATCH: %s", $time, s);
    endfunction
  endclass

  // ---------------- environment ----------------
  class env;
    generator gen; driver drv; monitor mon; scoreboard sb;
    mailbox #(fifo_txn) g2d = new(1);       // size 1: generator runs in step with the driver
    mailbox #(fifo_obs) m2s = new();
    function new(virtual fifo_if vif);
      gen = new(g2d); drv = new(vif, g2d); mon = new(vif, m2s); sb = new(m2s);
    endfunction
    task run();
      fork drv.run(); mon.run(); sb.run(); join_none
      gen.run();
      repeat (5) @(drv.vif.cb);
    endtask
  endclass

  // ---------------- tests ----------------
  virtual class base_test;
    env e; string name;
    function new(virtual fifo_if vif, string n); e = new(vif); name = n; endfunction
    pure virtual function void configure();
    virtual task body(); e.run(); endtask
    task run();
      configure(); body();
      $display("%-14s pushes=%0d pops=%0d errors=%0d -> %s", name, e.sb.pushes, e.sb.pops, e.sb.errors,
               e.sb.errors ? "FAIL" : "PASS");
    endtask
  endclass

  // proves: full asserts at exactly DEPTH words and a push while full is dropped
  class test_fill   extends base_test; function new(virtual fifo_if v); super.new(v, "fill");   endfunction
    function void configure(); e.gen.n = 3*DEPTH; e.gen.push_w = 100; e.gen.pop_w = 0; endfunction endclass
  // proves: empty asserts after the last word and a pop while empty is ignored
  class test_drain  extends base_test; function new(virtual fifo_if v); super.new(v, "drain");  endfunction
    function void configure(); e.gen.n = 3*DEPTH; e.gen.push_w = 0; e.gen.pop_w = 100; endfunction endclass
  // proves: data order and flags survive a random mix
  class test_random extends base_test; function new(virtual fifo_if v); super.new(v, "random"); endfunction
    function void configure(); e.gen.n = 5000; e.gen.push_w = 55; e.gen.pop_w = 50; endfunction endclass
  // proves: push and pop in the same cycle every cycle (including at full and empty)
  class test_b2b    extends base_test; function new(virtual fifo_if v); super.new(v, "back2back"); endfunction
    function void configure(); e.gen.n = 2000; e.gen.push_w = 100; e.gen.pop_w = 100; endfunction endclass
endpackage
