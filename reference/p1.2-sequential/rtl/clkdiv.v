module div2 (input wire clk, rst_n, output reg o);
  always @(posedge clk or negedge rst_n) if (!rst_n) o <= 0; else o <= ~o;
endmodule

module div4 (input wire clk, rst_n, output reg o);
  reg c;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin c <= 0; o <= 0; end
    else begin c <= ~c; if (c) o <= ~o; end
endmodule

// divide by 3 with 50% duty: posedge mod-3 counter makes a 1/3-high wave (a),
// a negedge flop delays it by half a cycle (b); a|b is high 1.5 of 3 cycles.
module div3_50 (input wire clk, rst_n, output wire o);
  reg [1:0] cnt; reg a, b;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin cnt <= 0; a <= 0; end
    else begin
      cnt <= (cnt == 2) ? 0 : cnt + 1'b1;
      a   <= (cnt == 2);                    // high for 1 of every 3 cycles
    end
  always @(negedge clk or negedge rst_n)
    if (!rst_n) b <= 0; else b <= a;
  assign o = a | b;                          // a glitch-free OR of two flop outputs
endmodule
