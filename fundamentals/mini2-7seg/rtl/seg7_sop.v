`timescale 1ns/1ps
// Mini 2: BCD to 7-segment decoder, minimized SOP form (your K-map answers).
// Inputs A (MSB) .. D (LSB) = BCD digit 0..9. Outputs a..g, active high (1 = LED on).
// Digits 10..15 never occur, so they are don't-cares: the equations below use them
// to make the groups bigger. We do not care what the display shows there.
module seg7_sop (
    input  A, B, C, D,
    output a, b, c, d, e, f, g
);
    assign a = A | C | (~B & ~D) | (B & D);
    assign b = ~B | (~C & ~D) | (C & D);
    assign c = B | ~C | D;
    assign d = A | (~B & C) | (~B & ~D) | (B & ~C & D) | (C & ~D);
`ifdef PLANT_BUG
    // Planted bug for the verification demo: one literal changed (D' became D).
    assign e = (C & D) | (~B & ~D);
`else
    assign e = (C & ~D) | (~B & ~D);
`endif
    assign f = A | (B & ~C) | (B & ~D) | (~C & ~D);
    assign g = A | (B & ~C) | (~B & C) | (C & ~D);
endmodule
