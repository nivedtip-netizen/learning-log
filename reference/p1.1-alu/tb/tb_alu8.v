`timescale 1ns/1ps
// Exhaustive: every a, b and op (256*256*9 = 589,824 vectors) vs a behavioral model.
module tb_alu8;
  reg [7:0] a, b; reg [3:0] op;
  wire [7:0] y; wire z, n, c, v;
  alu8 dut (.a(a), .b(b), .op(op), .y(y), .z(z), .n(n), .c(c), .v(v));

  integer errors = 0, i, j, k, sa, sb, full;
  reg [7:0] ey; reg ec, ev;
  initial begin
    for (k = 0; k < 9; k = k + 1)
      for (i = 0; i < 256; i = i + 1)
        for (j = 0; j < 256; j = j + 1) begin
          a = i; b = j; op = k; #1;
          sa = (i > 127) ? i - 256 : i;  sb = (j > 127) ? j - 256 : j;
          ec = 0; ev = 0;
          case (k)
            0: begin ey = i + j; ec = (i + j) > 255; full = sa + sb; ev = (full > 127 || full < -128); end
            1: begin ey = i - j; ec = (i < j);       full = sa - sb; ev = (full > 127 || full < -128); end
            2: ey = a & b;  3: ey = a | b;  4: ey = a ^ b;
            5: ey = (sa < sb) ? 8'd1 : 8'd0;
            6: ey = a << b[2:0];  7: ey = a >> b[2:0];
            8: ey = $signed(a) >>> b[2:0];
          endcase
          if (y !== ey || c !== ec || v !== ev || z !== (ey == 0) || n !== ey[7]) begin
            errors = errors + 1;
            if (errors <= 5) $display("ERR op=%0d a=%h b=%h y=%h/%h c=%b/%b v=%b/%b", k, a, b, y, ey, c, ec, v, ev);
          end
        end
    // thinking-drill corners
    a = 8'h7F; b = 8'h01; op = 0; #1; $display("0x7F+0x01 -> y=%h C=%b V=%b (expect 80 0 1)", y, c, v);
    a = 8'h80; b = 8'h01; op = 1; #1; $display("0x80-0x01 -> y=%h C=%b V=%b (expect 7f 0 1)", y, c, v);
    if (errors == 0) $display("tb_alu8 PASS (589824 vectors)"); else $display("tb_alu8 FAIL errors=%0d", errors);
    $finish;
  end
endmodule
