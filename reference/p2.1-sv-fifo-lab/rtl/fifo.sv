// The P1.4 synchronous FIFO, rewritten in SystemVerilog with the package types.
module fifo import fifo_pkg::*; (
  input  logic  clk, rst_n,
  input  logic  push, pop,
  input  data_t din,
  output data_t dout,
  output logic  full, empty,
  output logic [$clog2(DEPTH):0] count
);
  localparam int A = $clog2(DEPTH);
  data_t      mem [DEPTH];
  logic [A:0] wptr, rptr;

  assign count = wptr - rptr;
`ifdef BUG_FULL
  assign full  = (count >= DEPTH-1);   // seeded bug for P2.2/P2.3: full one entry early
`else
  assign full  = (wptr[A] != rptr[A]) && (wptr[A-1:0] == rptr[A-1:0]);
`endif
  // more seeded bugs for P2.3 (each one must make an assertion fire)
`ifdef BUG_FLAGS
  assign empty = (wptr[A-1:0] == rptr[A-1:0]);        // ignores the wrap bit: empty also high when full
`else
  assign empty = (wptr == rptr);
`endif
  assign dout  = mem[rptr[A-1:0]];

`ifdef BUG_WRFULL
  always_ff @(posedge clk) if (push) mem[wptr[A-1:0]] <= din;
`else
  always_ff @(posedge clk) if (push && !full) mem[wptr[A-1:0]] <= din;
`endif
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin wptr <= '0; rptr <= '0; end
    else begin
`ifdef BUG_WRFULL
      if (push)           wptr <= wptr + 1'b1;        // writes even when full
`else
      if (push && !full)  wptr <= wptr + 1'b1;
`endif
      if (pop  && !empty) rptr <= rptr + 1'b1;
`ifdef BUG_IDLE
      else if (!push && !pop && count == 5) rptr <= rptr + 1'b1;   // drifts while idle
`endif
    end
endmodule
