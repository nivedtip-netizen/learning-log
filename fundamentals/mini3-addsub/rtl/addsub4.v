`timescale 1ns/1ps
// 4-bit ripple-carry adder/subtractor.
//
//   sub = 0 : y = a + b
//   sub = 1 : y = a - b  =  a + (~b) + 1   (two's complement: invert and add one)
//
// Trick: XOR each bit of b with sub. XOR with 0 passes b through, XOR with 1 inverts it.
// The "+1" comes for free by feeding sub into the carry-in of bit 0.
//
// Flags:
//   carry    = carry out of bit 3. Unsigned view: add -> result did not fit in 4 bits;
//              subtract -> 1 means NO borrow (a >= b unsigned).
//   overflow = carry into bit 3 XOR carry out of bit 3. Signed view: the answer is
//              outside -8..+7, so the sign bit of y is wrong.
module addsub4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       sub,
    output wire [3:0] y,
    output wire       carry,
    output wire       overflow
);
    wire [3:0] b_x;   // b after the optional inversion
    wire [4:0] c;     // c[i] = carry INTO bit i, c[4] = carry out of the top bit

    assign c[0] = sub;

    // Invert b when subtracting (one XOR gate per bit)
    xor x0 (b_x[0], b[0], sub);
    xor x1 (b_x[1], b[1], sub);
    xor x2 (b_x[2], b[2], sub);
    xor x3 (b_x[3], b[3], sub);

    // The ripple chain: each full adder waits for the carry from the one before it
    full_adder fa0 (.a(a[0]), .b(b_x[0]), .cin(c[0]), .sum(y[0]), .cout(c[1]));
    full_adder fa1 (.a(a[1]), .b(b_x[1]), .cin(c[1]), .sum(y[1]), .cout(c[2]));
    full_adder fa2 (.a(a[2]), .b(b_x[2]), .cin(c[2]), .sum(y[2]), .cout(c[3]));
    full_adder fa3 (.a(a[3]), .b(b_x[3]), .cin(c[3]), .sum(y[3]), .cout(c[4]));

    assign carry = c[4];
    xor g_ovf (overflow, c[3], c[4]);
endmodule
