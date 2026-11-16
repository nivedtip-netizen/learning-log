// A small ALU with a start/done handshake, in the spirit of the UVM Primer's
// TinyALU (this is an independent design, not the book's code).
// op: 0 no-op, 1 add, 2 and, 3 xor, 4 mul (mul takes 3 cycles, others 1).
module small_alu (
  input  logic        clk, rst_n, start,
  input  logic [2:0]  op,
  input  logic [7:0]  a, b,
  output logic        done,
  output logic [15:0] result
);
  logic [1:0] mcnt; logic busy_mul;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin done <= 0; result <= 0; mcnt <= 0; busy_mul <= 0; end
    else begin
      done <= 0;
      if (busy_mul) begin
        if (mcnt == 2) begin busy_mul <= 0; done <= 1; result <= a * b; end
        else mcnt <= mcnt + 1'b1;
      end else if (start) begin
        case (op)
          3'd1: begin result <= {8'h0, a} + {8'h0, b}; done <= 1; end
          3'd2: begin result <= {8'h0, a & b};  done <= 1; end
          3'd3: begin result <= {8'h0, a ^ b};  done <= 1; end
          3'd4: begin busy_mul <= 1; mcnt <= 0; end
          default: done <= 1;                    // no-op: done, result unchanged
        endcase
      end
    end
endmodule
