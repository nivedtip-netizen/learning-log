// "1011" sequence detectors, 3-block style (state reg / next-state / output).
// Mealy: z is high in the SAME cycle the last '1' is on x.
// Moore: z is high in the cycle AFTER (it comes from a state).
// ONEHOT=1 switches the state encoding (for the Yosys comparison).

module det_mealy_ov #(parameter ONEHOT = 0) (input wire clk, rst_n, x, output reg z);
  localparam W = ONEHOT ? 4 : 2;
  localparam [3:0] E0 = ONEHOT ? 4'b0001 : 4'd0, E1 = ONEHOT ? 4'b0010 : 4'd1,
                   E2 = ONEHOT ? 4'b0100 : 4'd2, E3 = ONEHOT ? 4'b1000 : 4'd3;
  localparam [W-1:0] S0 = E0[W-1:0], S1 = E1[W-1:0], S2 = E2[W-1:0], S3 = E3[W-1:0];
  reg [W-1:0] s, ns;
  always @(posedge clk or negedge rst_n) if (!rst_n) s <= S0; else s <= ns;
  always @(*) begin
    ns = S0; z = 1'b0;
    case (s)
      S0: ns = x ? S1 : S0;                       // seen ""
      S1: ns = x ? S1 : S2;                       // seen "1"
      S2: ns = x ? S3 : S0;                       // seen "10"
      S3: begin ns = x ? S1 : S2; z = x; end      // seen "101": 1 -> match, keep "1"
      default: ns = S0;
    endcase
  end
endmodule

module det_mealy_nov (input wire clk, rst_n, x, output reg z);
  localparam S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3;
  reg [1:0] s, ns;
  always @(posedge clk or negedge rst_n) if (!rst_n) s <= S0; else s <= ns;
  always @(*) begin
    ns = S0; z = 1'b0;
    case (s)
      S0: ns = x ? S1 : S0;
      S1: ns = x ? S1 : S2;
      S2: ns = x ? S3 : S0;
      S3: begin ns = x ? S0 : S2; z = x; end      // match -> start from scratch
      default: ns = S0;
    endcase
  end
endmodule

module det_moore_ov (input wire clk, rst_n, x, output wire z);
  localparam S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4;
  reg [2:0] s, ns;
  always @(posedge clk or negedge rst_n) if (!rst_n) s <= S0; else s <= ns;
  always @(*) case (s)
    S0: ns = x ? S1 : S0;
    S1: ns = x ? S1 : S2;
    S2: ns = x ? S3 : S0;
    S3: ns = x ? S4 : S2;
    S4: ns = x ? S1 : S2;                         // "1011" + 1 -> "1"; + 0 -> "10"
    default: ns = S0;
  endcase
  assign z = (s == S4);
endmodule

module det_moore_nov (input wire clk, rst_n, x, output wire z);
  localparam S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4;
  reg [2:0] s, ns;
  always @(posedge clk or negedge rst_n) if (!rst_n) s <= S0; else s <= ns;
  always @(*) case (s)
    S0: ns = x ? S1 : S0;
    S1: ns = x ? S1 : S2;
    S2: ns = x ? S3 : S0;
    S3: ns = x ? S4 : S2;
    S4: ns = x ? S1 : S0;                         // fresh start: only the new bit counts
    default: ns = S0;
  endcase
  assign z = (s == S4);
endmodule
