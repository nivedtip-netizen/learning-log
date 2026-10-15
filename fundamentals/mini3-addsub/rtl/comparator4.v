`timescale 1ns/1ps
// 4-bit unsigned magnitude comparator, built from gates.
//
// Bit i is "equal" when a[i] XNOR b[i] = 1.
// a > b if, scanning from the MSB down, the first bit that differs has a=1, b=0:
//   gt = a3 b3'
//      + e3 a2 b2'
//      + e3 e2 a1 b1'
//      + e3 e2 e1 a0 b0'
// a == b when every bit is equal; a < b when neither of the others is true.
module comparator4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire       gt,
    output wire       eq,
    output wire       lt
);
    wire [3:0] e;     // per-bit equal
    wire [3:0] nb;    // inverted b
    wire t3, t2, t1, t0;

    xnor e0 (e[0], a[0], b[0]);
    xnor e1 (e[1], a[1], b[1]);
    xnor e2 (e[2], a[2], b[2]);
    xnor e3 (e[3], a[3], b[3]);

    not n0 (nb[0], b[0]);
    not n1 (nb[1], b[1]);
    not n2 (nb[2], b[2]);
    not n3 (nb[3], b[3]);

    and a3g (t3, a[3], nb[3]);
    and a2g (t2, e[3], a[2], nb[2]);
    and a1g (t1, e[3], e[2], a[1], nb[1]);
    and a0g (t0, e[3], e[2], e[1], a[0], nb[0]);

    or  g_gt (gt, t3, t2, t1, t0);
    and g_eq (eq, e[3], e[2], e[1], e[0]);
    nor g_lt (lt, gt, eq);
endmodule
