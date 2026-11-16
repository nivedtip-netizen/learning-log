interface alu_if (input logic clk);
  logic rst_n, start, done; logic [2:0] op; logic [7:0] a, b; logic [15:0] result;
endinterface
