`timescale 1ns/1ps
// The interview FIFO: power-of-2 depth, pointers one bit wider than the address.
module fifo_min #(parameter W = 8, DEPTH = 8) (
  input  wire clk, rst_n, wr, rd, input wire [W-1:0] wdata,
  output wire [W-1:0] rdata, output wire full, empty
);
  localparam A = $clog2(DEPTH);
  reg [W-1:0] mem [0:DEPTH-1]; reg [A:0] wp, rp;
  assign empty = (wp == rp);
  assign full  = (wp == {~rp[A], rp[A-1:0]});
  assign rdata = mem[rp[A-1:0]];                        // first-word fall-through
  always @(posedge clk) if (wr && !full) mem[wp[A-1:0]] <= wdata;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin wp <= 0; rp <= 0; end
    else begin
      if (wr && !full)  wp <= wp + 1'b1;
      if (rd && !empty) rp <= rp + 1'b1;
    end
endmodule
