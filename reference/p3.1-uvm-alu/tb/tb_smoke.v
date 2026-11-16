`timescale 1ns/1ps
// Plain smoke test of the DUT (Icarus), so the RTL is proven before the UVM bench.
module tb_smoke;
  reg clk = 0, rst_n = 0, start = 0; reg [2:0] op; reg [7:0] a, b; wire done; wire [15:0] r;
  always #5 clk = ~clk;
  small_alu dut (clk, rst_n, start, op, a, b, done, r);
  integer i, errors = 0; reg [15:0] exp, last = 0;
  initial begin
    #22 rst_n = 1;
    for (i = 0; i < 5000; i = i + 1) begin
      @(posedge clk); #1 start = 1; op = $random % 5; if (op > 4) op = 1; a = $random; b = $random;
      @(posedge clk); #1 start = 0;
      while (!done) @(posedge clk);
      #1;
      case (op) 1: exp = a + b; 2: exp = a & b; 3: exp = a ^ b; 4: exp = a * b; default: exp = last; endcase
      if (r !== exp) begin errors = errors + 1; if (errors < 5) $display("ERR op=%0d a=%h b=%h r=%h exp=%h", op, a, b, r, exp); end
      last = r;
    end
    $display("small_alu smoke: %s (5000 ops)", errors ? "FAIL" : "PASS"); $finish;
  end
endmodule
