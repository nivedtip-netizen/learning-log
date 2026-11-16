`timescale 1ns/1ps
// Synchronous FIFO, first-word-fall-through (dout shows the oldest word while !empty).
// Pointers are one bit wider than the address: same address + different MSB = full.
// Push while full is dropped (overflow pulses), even if a pop happens the same
// cycle: a simple 'accepted = push && !full' contract for the producer, and no
// combinational path from pop to push acceptance. (Found in P1.5: the old
// 'full + pop accepts' rule made the UART testbench lose count of bytes.)
// Pop while empty is ignored (underflow pulses).
module sync_fifo #(parameter W = 8, DEPTH = 16, AF = DEPTH-2, AE = 2) (
  input  wire         clk, rst_n,
  input  wire         push, pop,
  input  wire [W-1:0] din,
  output wire [W-1:0] dout,
  output wire         full, empty, almost_full, almost_empty,
  output reg          overflow, underflow,
  output wire [$clog2(DEPTH):0] count
);
  localparam A = $clog2(DEPTH);
  reg [W-1:0] mem [0:DEPTH-1];
  reg [A:0]   wptr, rptr;

  assign count        = wptr - rptr;
  assign empty        = (wptr == rptr);
  assign full         = (wptr[A] != rptr[A]) && (wptr[A-1:0] == rptr[A-1:0]);
  assign almost_full  = (count >= AF);
  assign almost_empty = (count <= AE);
  assign dout         = mem[rptr[A-1:0]];

  wire do_pop  = pop  && !empty;
  wire do_push = push && !full;

  always @(posedge clk) if (do_push) mem[wptr[A-1:0]] <= din;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin wptr <= 0; rptr <= 0; overflow <= 0; underflow <= 0; end
    else begin
      if (do_push) wptr <= wptr + 1'b1;
      if (do_pop)  rptr <= rptr + 1'b1;
      overflow  <= push && !do_push;
      underflow <= pop  && empty;
    end
endmodule
