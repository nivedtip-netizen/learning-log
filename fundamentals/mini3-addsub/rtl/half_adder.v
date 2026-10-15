`timescale 1ns/1ps
// Half adder: adds two 1-bit numbers.
// sum   = a XOR b  (1 when exactly one input is 1)
// carry = a AND b  (1 only when both are 1, i.e. 1+1 = 10 in binary)
module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);
    xor g_sum   (sum,   a, b);
    and g_carry (carry, a, b);
endmodule
