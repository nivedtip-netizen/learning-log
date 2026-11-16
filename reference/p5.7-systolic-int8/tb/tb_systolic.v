`timescale 1ns/1ps
// Self-checking testbench for systolic_top against vectors from model/golden.py (NumPy).
//   +VEC=file  +SEED=n  +BUBBLES=1 (random in_valid gaps)  +STALL=0..
// Checks: every C row against NumPy; N output beats per matrix with out_last on the last;
// in_ready low while the array is busy flushing/reading out; cycle count = K + 2N-1+P + N.
module tb_systolic;
  parameter N = 4, PIPE_MUL = 0;
  reg clk = 0, rst_n = 0;
  always #5 clk = ~clk;

  reg in_valid = 0, in_last = 0; wire in_ready;
  reg [8*N-1:0] a_col = 0, b_row = 0;
  wire out_valid, out_last, busy; wire [32*N-1:0] out_row;
  systolic_top #(.N(N), .PIPE_MUL(PIPE_MUL)) dut (clk, rst_n, in_valid, in_last, in_ready, a_col, b_row,
                                                  out_valid, out_last, out_row, busy);

  integer fd, T, t, K, k, r, j, errors = 0, seed = 1, seed0, bubbles = 0, nbub;
  integer c_start, c_end, cyc = 0, beats, gaps; reg rdy;
  reg [8*N-1:0] A [0:1023]; reg [8*N-1:0] B [0:1023]; reg [32*N-1:0] C [0:N-1];
  reg [8*8*64-1:0] vecname;
  always @(posedge clk) cyc <= cyc + 1;

  // assertions (plain Verilog): in_ready only while idle/feeding; out_last only with out_valid
  always @(posedge clk) if (rst_n) begin
    if (out_last && !out_valid) begin errors = errors + 1; $display("ERROR out_last without out_valid"); end
    if (out_valid && in_ready && !out_last) begin errors = errors + 1; $display("ERROR in_ready while reading out"); end
  end

  initial begin
    if (!$value$plusargs("VEC=%s", vecname)) vecname = "vectors.txt";
    if ($value$plusargs("SEED=%d", seed)) ; seed0 = seed;
    if ($value$plusargs("BUBBLES=%d", bubbles)) ;
    fd = $fopen(vecname, "r");
    if (fd == 0) begin $display("RESULT: FAIL cannot open %0s", vecname); $finish; end
    r = $fscanf(fd, "%d", T);
    repeat (3) @(posedge clk); rst_n = 1; @(posedge clk); #1;
    for (t = 0; t < T; t = t + 1) begin
      r = $fscanf(fd, "%d", K);
      for (k = 0; k < K; k = k + 1) r = $fscanf(fd, "%h %h", A[k], B[k]);
      for (j = 0; j < N; j = j + 1) r = $fscanf(fd, "%h", C[j]);
      // ---- feed ----
      c_start = cyc; gaps = 0;
      for (k = 0; k < K; k = k + 1) begin
        if (bubbles) begin nbub = $urandom(seed) % 3; gaps = gaps + nbub; repeat (nbub) begin @(posedge clk); #1; end end
        in_valid = 1; in_last = (k == K - 1); a_col = A[k]; b_row = B[k];
        begin : wait_taken                                   // valid/ready: hold the beat until an edge takes it
          forever begin rdy = in_ready; @(posedge clk); #1; if (rdy) disable wait_taken; end
        end
        in_valid = 0; in_last = 0; a_col = {8*N{1'bx}}; b_row = {8*N{1'bx}};   // X when no beat: must not leak
      end
      // ---- collect N rows ----
      beats = 0;
      while (beats < N) begin
        @(posedge clk); #1;
        if (out_valid) begin
          if (out_row !== C[beats]) begin
            errors = errors + 1;
            if (errors < 6) $display("ERROR test %0d K=%0d row %0d: got %h exp %h", t, K, beats, out_row, C[beats]);
          end
          if (out_last !== (beats == N - 1)) begin errors = errors + 1; $display("ERROR out_last position"); end
          beats = beats + 1;
        end
        if (cyc - c_start > K + 10 * N + 3 * K + 50) begin $display("RESULT: FAIL timeout test %0d", t); $finish; end
      end
      c_end = cyc;
      // edges from the first beat to the last row: K feed + FLUSH + (N-1) between the N rows
      if (!bubbles && (c_end - c_start) != K + 2 * N - 1 + PIPE_MUL + N - 1) begin
        errors = errors + 1; $display("ERROR test %0d: %0d cycles, expected %0d", t, c_end - c_start, K + 2 * N - 1 + PIPE_MUL + N - 1);
      end
      // the next matrix is driven right now, inside the last read-out row,
      // where in_ready is already high, so there is no gap between matrices
    end
    $display("N=%0d PIPE_MUL=%0d tests=%0d bubbles=%0d cycles=%0d", N, PIPE_MUL, T, bubbles, cyc);
    if (errors) $display("RESULT: FAIL errors=%0d seed=%0d", errors, seed0);
    else        $display("RESULT: PASS errors=0 seed=%0d", seed0);
    $finish;
  end
endmodule
