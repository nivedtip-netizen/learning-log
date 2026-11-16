`timescale 1ns/1ps
// INT8 matrix multiply C[N x N] = A[N x K] * B[K x N] on an N x N systolic array.
//
// Input stream: one beat per k (k = 0..K-1). Each beat carries column k of A
// (a_col[8*i +: 8] = A[i][k]) and row k of B (b_row[8*j +: 8] = B[k][j]).
// in_valid/in_ready handshake, in_last on beat K-1. Bubbles (in_valid low) are allowed.
// Output stream: N beats, beat r = row r of C (out_row[32*j +: 32] = C[r][j]), out_last on row N-1.
//
// Skew: row i of A is delayed i cycles and column j of B is delayed j cycles, so
// A[i][k] and B[k][j] meet in PE(i,j) on the same cycle. Bubbles feed zeros into both
// at once, so they keep the alignment and add 0 to every sum.
//
// Cycles for one matrix: K (feed) + 2N-1+PIPE_MUL (flush) + N (read out).
module systolic_top #(parameter N = 4, PIPE_MUL = 0) (
  input  wire            clk, rst_n,
  input  wire            in_valid, in_last,
  output wire            in_ready,
  input  wire [8*N-1:0]  a_col, b_row,
  output wire            out_valid, out_last,
  output wire [32*N-1:0] out_row,
  output reg             busy
);
  localparam S_IDLE = 2'd0, S_FEED = 2'd1, S_FLUSH = 2'd2, S_OUT = 2'd3;
  localparam FLUSH = 2*N - 1 + PIPE_MUL;
  reg [1:0] state;
  reg [$clog2(FLUSH+N+1)-1:0] cnt;

  // ready while idle or feeding, and on the last read-out row, so matrices can follow with no gap
  assign in_ready = (state == S_IDLE) || (state == S_FEED) || (state == S_OUT && cnt == N - 1);
  wire take = in_valid && in_ready;

  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin state <= S_IDLE; cnt <= 0; busy <= 1'b0; end
    else case (state)
      S_IDLE:  if (take) begin state <= in_last ? S_FLUSH : S_FEED; cnt <= 0; busy <= 1'b1; end
      S_FEED:  if (take && in_last) begin state <= S_FLUSH; cnt <= 0; end
      S_FLUSH: if (cnt == FLUSH - 1) begin state <= S_OUT; cnt <= 0; end else cnt <= cnt + 1'b1;
      S_OUT:   if (cnt == N - 1) begin
                 cnt <= 0;
                 if (take) state <= in_last ? S_FLUSH : S_FEED;      // next matrix, back to back
                 else begin state <= S_IDLE; busy <= 1'b0; end
               end else cnt <= cnt + 1'b1;
    endcase

  // accumulators are cleared while idle, and on the last read-out row so that a new
  // matrix may start on the very next cycle (back to back)
  wire clear = ((state == S_IDLE) && !take) || out_last;

  // ---- input register + skew ----
  // registered beat (zeros when there is no beat), then row i / column j delayed by i / j more cycles
  reg [8*N-1:0] a_q, b_q;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin a_q <= 0; b_q <= 0; end
    else begin a_q <= take ? a_col : {8*N{1'b0}}; b_q <= take ? b_row : {8*N{1'b0}}; end

  wire [8*N-1:0] a_left, b_top;
  genvar i;
  generate for (i = 0; i < N; i = i + 1) begin : g_skew
    if (i == 0) begin : g0
      assign a_left[7:0] = a_q[7:0];
      assign b_top[7:0]  = b_q[7:0];
    end else begin : gd
      reg [7:0] da [0:i-1], db [0:i-1];
      integer k;
      always @(posedge clk or negedge rst_n)
        if (!rst_n) for (k = 0; k < i; k = k + 1) begin da[k] <= 8'd0; db[k] <= 8'd0; end
        else begin
          da[0] <= a_q[8*i +: 8]; db[0] <= b_q[8*i +: 8];
          for (k = 1; k < i; k = k + 1) begin da[k] <= da[k-1]; db[k] <= db[k-1]; end
        end
`ifdef BUG_SKEW
      if (i == N-1 && i > 1) begin : g_bug
        assign a_left[8*i +: 8] = da[i-2];             // seeded bug: last row of A one cycle early
      end else begin : g_ok
        assign a_left[8*i +: 8] = da[i-1];
      end
`else
      assign a_left[8*i +: 8] = da[i-1];
`endif
      assign b_top[8*i +: 8]  = db[i-1];
    end
  end endgenerate

  // ---- the array ----
  wire [32*N*N-1:0] acc_flat;
  systolic_array #(.N(N), .PIPE_MUL(PIPE_MUL)) u_arr (.clk(clk), .rst_n(rst_n), .clear(clear),
                                                       .a_left(a_left), .b_top(b_top), .acc_flat(acc_flat));

  // ---- read out one row per cycle ----
  assign out_valid = (state == S_OUT);
  assign out_last  = out_valid && (cnt == N - 1);
  assign out_row   = acc_flat[32*N*cnt +: 32*N];
endmodule
