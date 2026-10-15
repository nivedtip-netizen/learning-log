`timescale 1ns/1ps
// Full adder: adds a, b and a carry-in from the bit to the right.
// Built from two half adders and one OR gate, exactly like the textbook diagram.
//   sum  = a ^ b ^ cin
//   cout = (a & b) | (cin & (a ^ b))
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    wire s1, c1, c2;

    half_adder ha1 (.a(a),  .b(b),   .sum(s1),  .carry(c1)); // a + b
    half_adder ha2 (.a(s1), .b(cin), .sum(sum), .carry(c2)); // (a + b) + cin
    or         g_cout (cout, c1, c2);                         // carry if either stage carried
endmodule
