// 2-flop synchronizer + stable-time counter. Output changes only after the
// synchronized input has held a new value for STABLE consecutive cycles.
module debounce #(parameter STABLE = 8) (input wire clk, rst_n, btn, output reg out);
  reg s1, s2;
  reg [$clog2(STABLE+1)-1:0] cnt;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin s1 <= 0; s2 <= 0; cnt <= 0; out <= 0; end
    else begin
      s1 <= btn; s2 <= s1;
      if (s2 == out)            cnt <= 0;            // no change pending
      else if (cnt == STABLE-1) begin out <= s2; cnt <= 0; end
      else                      cnt <= cnt + 1'b1;
    end
endmodule
