`timescale 1ns/1ps
// Segment e using NAND gates only.
// e = C D' + B' D'.  Double inversion + De Morgan:
//   e = ((C D')' . (B' D')')'   -> NAND of two NANDs.
// A NOT is a NAND with both inputs tied together.
// Gate count: 2 NOT-as-NAND (D', B') + 2 NAND + 1 NAND = 5 NANDs.
module seg7_nand_e (
    input  B, C, D,
    output e
);
    wire nd, nb, t1, t2;
    nand g_nd (nd, D, D);       // D'
    nand g_nb (nb, B, B);       // B'
    nand g_t1 (t1, C, nd);      // (C D')'
    nand g_t2 (t2, nb, nd);     // (B' D')'
    nand g_e  (e,  t1, t2);     // e
endmodule
