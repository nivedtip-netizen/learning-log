// up/down counter with synchronous load and enable (load has priority)
module updown #(parameter W = 4) (input wire clk, rst_n, en, up, load,
                                   input wire [W-1:0] din, output reg [W-1:0] q);
  always @(posedge clk or negedge rst_n)
    if (!rst_n)    q <= 0;
    else if (load) q <= din;
    else if (en)   q <= up ? q + 1'b1 : q - 1'b1;
endmodule

// mod-N counter: 0..N-1 then back to 0
module modn #(parameter N = 6) (input wire clk, rst_n, en, output reg [$clog2(N)-1:0] q);
  always @(posedge clk or negedge rst_n)
    if (!rst_n)  q <= 0;
    else if (en) q <= (q == N-1) ? 0 : q + 1'b1;
endmodule

module ring4 (input wire clk, rst_n, output reg [3:0] q);
  always @(posedge clk or negedge rst_n)
    if (!rst_n) q <= 4'b0001; else q <= {q[2:0], q[3]};
endmodule

module johnson4 (input wire clk, rst_n, output reg [3:0] q);
  always @(posedge clk or negedge rst_n)
    if (!rst_n) q <= 4'b0000; else q <= {q[2:0], ~q[3]};
endmodule

// 8-bit Fibonacci LFSR, taps 8,6,5,4 (x^8+x^6+x^5+x^4+1): all 255 non-zero states
module lfsr8 (input wire clk, rst_n, input wire [7:0] seed, output reg [7:0] q);
  wire fb = q[7] ^ q[5] ^ q[4] ^ q[3];
  always @(posedge clk or negedge rst_n)
    if (!rst_n) q <= (seed == 0) ? 8'h01 : seed;   // never seed the lock-up state 0
    else        q <= {q[6:0], fb};
endmodule
