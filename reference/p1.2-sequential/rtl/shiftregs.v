module sipo #(parameter W = 8) (input wire clk, rst_n, sin, output reg [W-1:0] q);
  always @(posedge clk or negedge rst_n) if (!rst_n) q <= 0; else q <= {q[W-2:0], sin};
endmodule

module piso #(parameter W = 8) (input wire clk, rst_n, load, input wire [W-1:0] din,
                                 output wire sout);
  reg [W-1:0] r;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) r <= 0; else if (load) r <= din; else r <= {r[W-2:0], 1'b0};
  assign sout = r[W-1];                     // MSB first
endmodule

// mode: 0 hold, 1 shift left (sl in), 2 shift right (sr in), 3 load
module ushift #(parameter W = 8) (input wire clk, rst_n, input wire [1:0] mode,
                                   input wire sl, sr, input wire [W-1:0] din, output reg [W-1:0] q);
  always @(posedge clk or negedge rst_n)
    if (!rst_n) q <= 0;
    else case (mode)
      2'd1: q <= {q[W-2:0], sl};
      2'd2: q <= {sr, q[W-1:1]};
      2'd3: q <= din;
      default: q <= q;
    endcase
endmodule
