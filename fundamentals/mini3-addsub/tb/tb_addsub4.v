// Exhaustive self-checking testbench for addsub4.
// 16 values of a x 16 values of b x 2 operations = 512 cases, every one checked
// against a "golden" answer computed with plain integer maths.
`timescale 1ns/1ps
module tb_addsub4;
    reg  [3:0] a, b;
    reg        sub;
    wire [3:0] y;
    wire       carry, overflow;

    addsub4 dut (.a(a), .b(b), .sub(sub), .y(y), .carry(carry), .overflow(overflow));

    integer i, j, k, errors, sa, sb, sres;
    reg [4:0] wide;          // 5-bit unsigned result: bit 4 is the expected carry
    reg [3:0] exp_y;
    reg       exp_c, exp_v;

    initial begin
        $dumpfile("addsub4.vcd");
        $dumpvars(0, tb_addsub4);
        errors = 0;

        for (k = 0; k < 2; k = k + 1)
        for (i = 0; i < 16; i = i + 1)
        for (j = 0; j < 16; j = j + 1) begin
            a = i; b = j; sub = k;
            #1;  // let the gates settle (combinational, no clock)

            // Golden model, unsigned view: carry
            if (sub) wide = {1'b0, a} + {1'b0, ~b} + 5'd1;
            else     wide = {1'b0, a} + {1'b0, b};
            exp_y = wide[3:0];
            exp_c = wide[4];

            // Golden model, signed view: overflow if the true answer is outside -8..+7
            sa = (a > 7) ? a - 16 : a;
            sb = (b > 7) ? b - 16 : b;
            sres = sub ? sa - sb : sa + sb;
            exp_v = (sres > 7) || (sres < -8);

            if (y !== exp_y || carry !== exp_c || overflow !== exp_v) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("FAIL %s a=%0d b=%0d : got y=%0d c=%b v=%b, expected y=%0d c=%b v=%b",
                             sub ? "SUB" : "ADD", a, b, y, carry, overflow, exp_y, exp_c, exp_v);
            end
        end

        // A few famous cases printed so you can read them in the log
        a = 4'd7;  b = 4'd1; sub = 0; #1 $display("  7 + 1  -> y=%b c=%b v=%b  (signed +8 doesn't fit: overflow)", y, carry, overflow);
        a = 4'd8;  b = 4'd1; sub = 1; #1 $display(" -8 - 1  -> y=%b c=%b v=%b  (signed -9 doesn't fit: overflow)", y, carry, overflow);
        a = 4'd5;  b = 4'd3; sub = 1; #1 $display("  5 - 3  -> y=%b c=%b v=%b  (c=1: no borrow)", y, carry, overflow);
        a = 4'd15; b = 4'd1; sub = 0; #1 $display(" 15 + 1  -> y=%b c=%b v=%b  (unsigned 16 doesn't fit: carry)", y, carry, overflow);

        if (errors == 0) $display("PASS: addsub4, all 512 cases correct");
        else             $display("FAIL: addsub4, %0d of 512 cases wrong", errors);
        $finish;
    end
endmodule
