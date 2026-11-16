`timescale 1ns/1ps
// N x N grid of PEs. A enters on the left (one INT8 per row), B on the top (one per column).
// The caller supplies already-skewed inputs. acc_flat holds every C[i][j]:
// bits [32*(i*N+j) +: 32].
module systolic_array #(parameter N = 4, PIPE_MUL = 0) (
  input  wire              clk, rst_n, clear,
  input  wire [8*N-1:0]    a_left,      // a_left[8*i +: 8] = row i
  input  wire [8*N-1:0]    b_top,       // b_top [8*j +: 8] = column j
  output wire [32*N*N-1:0] acc_flat
);
  wire [7:0] a_h [0:N-1][0:N];          // a_h[i][j] = A value entering PE(i,j) from the left
  wire [7:0] b_v [0:N][0:N-1];          // b_v[i][j] = B value entering PE(i,j) from above
  genvar i, j;
  generate
    for (i = 0; i < N; i = i + 1) begin : g_edge
      assign a_h[i][0] = a_left[8*i +: 8];
      assign b_v[0][i] = b_top[8*i +: 8];
    end
    for (i = 0; i < N; i = i + 1) begin : g_row
      for (j = 0; j < N; j = j + 1) begin : g_col
        pe #(.PIPE_MUL(PIPE_MUL)) u_pe (
          .clk(clk), .rst_n(rst_n), .clear(clear),
          .a_in(a_h[i][j]), .b_in(b_v[i][j]),
          .a_out(a_h[i][j+1]), .b_out(b_v[i+1][j]),
          .acc(acc_flat[32*(i*N+j) +: 32]));
      end
    end
  endgenerate
endmodule
