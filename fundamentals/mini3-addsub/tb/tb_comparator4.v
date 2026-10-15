// Exhaustive self-checking testbench for comparator4: all 256 (a, b) pairs.
`timescale 1ns/1ps
module tb_comparator4;
    reg  [3:0] a, b;
    wire       gt, eq, lt;

    comparator4 dut (.a(a), .b(b), .gt(gt), .eq(eq), .lt(lt));

    integer i, j, errors;

    initial begin
        $dumpfile("comparator4.vcd");
        $dumpvars(0, tb_comparator4);
        errors = 0;
        for (i = 0; i < 16; i = i + 1)
        for (j = 0; j < 16; j = j + 1) begin
            a = i; b = j;
            #1;
            if (gt !== (a > b) || eq !== (a == b) || lt !== (a < b)) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("FAIL a=%0d b=%0d : got gt=%b eq=%b lt=%b", a, b, gt, eq, lt);
            end
            if ((gt + eq + lt) !== 1) begin
                errors = errors + 1;
                $display("FAIL a=%0d b=%0d : exactly one output must be 1", a, b);
            end
        end
        if (errors == 0) $display("PASS: comparator4, all 256 cases correct");
        else             $display("FAIL: comparator4, %0d errors", errors);
        $finish;
    end
endmodule
