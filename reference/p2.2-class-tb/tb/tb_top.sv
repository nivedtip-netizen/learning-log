// Top: clock, reset, DUT, interface, and test selection with +TEST=<name>.
// reset_mid: asserts reset in the middle of traffic; DUT and scoreboard must both start over.
module tb_top;
  import fifo_pkg::*;
  import fifo_tb_pkg::*;
  logic clk = 0; always #5 clk = ~clk;
  fifo_if bus (clk);
  fifo dut (.clk(clk), .rst_n(bus.rst_n), .push(bus.push), .pop(bus.pop), .din(bus.din),
            .dout(bus.dout), .full(bus.full), .empty(bus.empty), .count(bus.count));

  initial begin
    string tname;
    base_test t;
    if (!$value$plusargs("TEST=%s", tname)) tname = "random";
    bus.rst_n = 0; bus.push = 0; bus.pop = 0; bus.din = 0;
    repeat (3) @(posedge clk); bus.rst_n = 1;
    case (tname)
      "fill":      begin test_fill   x = new(bus); t = x; end
      "drain":     begin test_drain  x = new(bus); t = x; end
      "back2back": begin test_b2b    x = new(bus); t = x; end
      "reset_mid": begin
        test_random x = new(bus); t = x;
        fork
          t.run();
          begin
            repeat (2000) @(posedge clk);
            bus.rst_n = 0; t.e.sb.reset();      // reset the model with the DUT
            @(posedge clk); bus.rst_n = 1;
          end
        join
        $finish;
      end
      default:     begin test_random x = new(bus); t = x; end
    endcase
    t.run();
    $finish;
  end
endmodule
