// unsigned magnitude comparator
module cmp #(parameter N = 8) (input wire [N-1:0] a, b, output wire eq, lt, gt);
  assign eq = (a == b);
  assign lt = (a <  b);
  assign gt = (a >  b);
endmodule

// 8-bit barrel shifter: log2(8)=3 mux stages (shift by 1, 2, 4).
// dir=0 left, dir=1 right; arith=1 fills with the sign bit on right shifts.
module barrel8 (input wire [7:0] d, input wire [2:0] sh, input wire dir, arith,
                output wire [7:0] y);
  wire fill = arith & dir & d[7];
  wire [7:0] s0 = !sh[0] ? d  : dir ? {fill, d[7:1]}            : {d[6:0], 1'b0};
  wire [7:0] s1 = !sh[1] ? s0 : dir ? {{2{fill}}, s0[7:2]}      : {s0[5:0], 2'b0};
  assign     y  = !sh[2] ? s1 : dir ? {{4{fill}}, s1[7:4]}      : {s1[3:0], 4'b0};
endmodule
