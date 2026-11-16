// Step 8: latch on purpose (no else) and the fix.
module latch_bad  (input wire en, d, output reg q);
  always @(*) if (en) q = d;          // q must remember -> latch inferred
endmodule
module latch_fixed (input wire en, d, output reg q);
  always @(*) if (en) q = d; else q = 1'b0;
endmodule
