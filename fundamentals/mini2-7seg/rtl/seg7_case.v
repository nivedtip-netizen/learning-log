`timescale 1ns/1ps
// Same decoder written the way RTL engineers usually write it: a case statement
// (a lookup table). Digits 10..15 are 'x' = don't-care, so synthesis is free to
// shrink the logic exactly like your K-maps did.
// seg = {a, b, c, d, e, f, g}
module seg7_case (
    input      [3:0] bcd,
    output reg [6:0] seg
);
    always @* begin
        case (bcd)
            4'd0:    seg = 7'b1111110;
            4'd1:    seg = 7'b0110000;
            4'd2:    seg = 7'b1101101;
            4'd3:    seg = 7'b1111001;
            4'd4:    seg = 7'b0110011;
            4'd5:    seg = 7'b1011011;
            4'd6:    seg = 7'b1011111;
            4'd7:    seg = 7'b1110000;
            4'd8:    seg = 7'b1111111;
            4'd9:    seg = 7'b1111011;
            default: seg = 7'bxxxxxxx;   // 10..15 don't care
        endcase
    end
endmodule
