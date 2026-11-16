module full_adder (input wire a, b, cin, output wire s, cout);
  assign s    = a ^ b ^ cin;
  assign cout = (a & b) | (cin & (a ^ b));
endmodule

// N-bit ripple-carry adder: N full adders chained with generate
module rca #(parameter N = 4) (
  input wire [N-1:0] a, b, input wire cin, output wire [N-1:0] s, output wire cout);
  wire [N:0] c;
  assign c[0] = cin;
  genvar i;
  generate for (i = 0; i < N; i = i + 1) begin : g_fa
    full_adder fa (.a(a[i]), .b(b[i]), .cin(c[i]), .s(s[i]), .cout(c[i+1]));
  end endgenerate
  assign cout = c[N];
endmodule

// 4-bit carry-lookahead adder: every carry is computed directly from g, p, c0
module cla4 (input wire [3:0] a, b, input wire cin, output wire [3:0] s, output wire cout);
  wire [3:0] g = a & b;   // generate
  wire [3:0] p = a ^ b;   // propagate
  wire c1 = g[0] | (p[0] & cin);
  wire c2 = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
  wire c3 = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & cin);
  assign cout = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0])
              | (p[3] & p[2] & p[1] & p[0] & cin);
  assign s = p ^ {c3, c2, c1, cin};
endmodule
