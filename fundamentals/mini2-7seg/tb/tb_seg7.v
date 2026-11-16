// Exhaustive self-checking testbench for the BCD to 7-segment decoder.
// Only 16 inputs exist, so we test all of them. For digits 0..9 every output must
// match the spec table. Digits 10..15 are don't-care and are not checked.
`timescale 1ns/1ps
module tb_seg7;
    reg  [3:0] bcd;
    wire a, b, c, d, e, f, g;
    wire [6:0] seg_case;
    wire e_nand;

    seg7_sop     dut_sop  (.A(bcd[3]), .B(bcd[2]), .C(bcd[1]), .D(bcd[0]),
                           .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g));
    seg7_case    dut_case (.bcd(bcd), .seg(seg_case));
    seg7_nand_e  dut_nand (.B(bcd[2]), .C(bcd[1]), .D(bcd[0]), .e(e_nand));

    // Spec: {a,b,c,d,e,f,g} for digits 0..9 (from the truth table)
    reg [6:0] spec [0:9];
    initial begin
        spec[0] = 7'b1111110;  spec[1] = 7'b0110000;  spec[2] = 7'b1101101;
        spec[3] = 7'b1111001;  spec[4] = 7'b0110011;  spec[5] = 7'b1011011;
        spec[6] = 7'b1011111;  spec[7] = 7'b1110000;  spec[8] = 7'b1111111;
        spec[9] = 7'b1111011;
    end

    integer i, errors;
    reg [6:0] seg_sop;
    initial begin
        errors = 0;
        for (i = 0; i < 10; i = i + 1) begin
            bcd = i[3:0];
            #1;
            seg_sop = {a, b, c, d, e, f, g};
            if (seg_sop !== spec[i]) begin
                errors = errors + 1;
                $display("FAIL sop  digit %0d: got %b expected %b", i, seg_sop, spec[i]);
            end
            if (seg_case !== spec[i]) begin
                errors = errors + 1;
                $display("FAIL case digit %0d: got %b expected %b", i, seg_case, spec[i]);
            end
            if (e_nand !== spec[i][2]) begin
                errors = errors + 1;
                $display("FAIL nand_e digit %0d: got %b expected %b", i, e_nand, spec[i][2]);
            end
        end
        // Digits 10..15: don't-care, just show what the SOP version does.
        for (i = 10; i < 16; i = i + 1) begin
            bcd = i[3:0];
            #1;
            $display("info  digit %0d (don't care): sop shows %b", i, {a, b, c, d, e, f, g});
        end
        if (errors == 0) $display("PASS: all 10 digits x 3 implementations match the spec");
        else             $display("FAIL: %0d mismatches", errors);
        $finish;
    end
endmodule
