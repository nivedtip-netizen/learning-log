// Step 9: swap with blocking vs non-blocking
module swap_blocking    (input wire clk, rst_n, output reg [3:0] a, b);
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin a = 1; b = 2; end
    else begin a = b; b = a; end        // b gets the NEW a -> both become 2, no swap
endmodule
module swap_nonblocking (input wire clk, rst_n, output reg [3:0] a, b);
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin a <= 1; b <= 2; end
    else begin a <= b; b <= a; end      // both read old values -> real swap
endmodule
