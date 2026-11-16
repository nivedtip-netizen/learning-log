// 4:1 mux, three ways. All three must match (checked in tb_comb.v).
module mux4_tern (input wire [3:0] d, input wire [1:0] sel, output wire y);
  assign y = sel[1] ? (sel[0] ? d[3] : d[2]) : (sel[0] ? d[1] : d[0]);
endmodule

module mux4_case (input wire [3:0] d, input wire [1:0] sel, output reg y);
  always @(*) case (sel)
    2'd0: y = d[0]; 2'd1: y = d[1]; 2'd2: y = d[2]; default: y = d[3];
  endcase
endmodule

module mux4_gate (input wire [3:0] d, input wire [1:0] sel, output wire y);
  wire ns0, ns1, t0, t1, t2, t3;
  not (ns0, sel[0]); not (ns1, sel[1]);
  and (t0, d[0], ns1, ns0); and (t1, d[1], ns1, sel[0]);
  and (t2, d[2], sel[1], ns0); and (t3, d[3], sel[1], sel[0]);
  or  (y, t0, t1, t2, t3);
endmodule
