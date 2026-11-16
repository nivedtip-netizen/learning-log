`timescale 1ns/1ps
// Exhaustive checks for mux, decoder, encoder, adders, comparator, barrel shifter.
module tb_comb;
  integer errors = 0, i, j, k;
  reg [3:0] d; reg [1:0] sel; wire y1, y2, y3;
  mux4_tern m1 (d, sel, y1); mux4_case m2 (d, sel, y2); mux4_gate m3 (d, sel, y3);

  reg [2:0] din; reg en; wire [7:0] dec;
  dec3to8 u_dec (din, en, dec);
  reg [7:0] ein; wire [2:0] eout; wire valid;
  prio_enc8 u_enc (ein, eout, valid);

  reg [3:0] a4, b4; reg c0; wire [3:0] s_r, s_c; wire co_r, co_c;
  rca #(4) u_rca (a4, b4, c0, s_r, co_r);
  cla4     u_cla (a4, b4, c0, s_c, co_c);

  reg [7:0] a8, b8; wire eq, lt, gt;
  cmp #(8) u_cmp (a8, b8, eq, lt, gt);
  reg [2:0] sh; reg dir, ar; wire [7:0] bs;
  barrel8 u_bs (a8, sh, dir, ar, bs);

  reg [7:0] exp8; integer hi;
  initial begin
    for (i = 0; i < 64; i = i + 1) begin
      {sel, d} = i; #1;
      if (y1 !== d[sel] || y2 !== d[sel] || y3 !== d[sel]) errors = errors + 1;
    end
    for (i = 0; i < 16; i = i + 1) begin
      {en, din} = i; #1;
      if (dec !== (en ? (8'd1 << din) : 8'd0)) errors = errors + 1;
    end
    for (i = 0; i < 256; i = i + 1) begin
      ein = i; #1; hi = -1;
      for (j = 0; j < 8; j = j + 1) if (ein[j]) hi = j;
      if (valid !== (hi >= 0) || (hi >= 0 && eout !== hi)) errors = errors + 1;
    end
    for (i = 0; i < 512; i = i + 1) begin
      {c0, a4, b4} = i; #1;
      if ({co_r, s_r} !== a4 + b4 + c0 || {co_c, s_c} !== a4 + b4 + c0) errors = errors + 1;
    end
    for (i = 0; i < 256; i = i + 1)
      for (j = 0; j < 256; j = j + 1) begin
        a8 = i; b8 = j; #1;
        if (eq !== (i == j) || lt !== (i < j) || gt !== (i > j)) errors = errors + 1;
        if (j < 32) begin
          {ar, dir, sh} = j[4:0]; #1;
          if (!dir)    exp8 = a8 << sh;
          else if (ar) exp8 = $signed(a8) >>> sh;   // separate statement keeps it signed
          else         exp8 = a8 >> sh;
          if (bs !== exp8) errors = errors + 1;
        end
      end
    if (errors == 0) $display("tb_comb PASS"); else $display("tb_comb FAIL errors=%0d", errors);
    $finish;
  end
endmodule
