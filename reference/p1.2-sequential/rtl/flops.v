module dff_sync  (input wire clk, rst_n, d, output reg q);
  always @(posedge clk) if (!rst_n) q <= 1'b0; else q <= d;           // reset seen only at an edge
endmodule
module dff_async (input wire clk, rst_n, d, output reg q);
  always @(posedge clk or negedge rst_n) if (!rst_n) q <= 1'b0; else q <= d;
endmodule
module dff_en    (input wire clk, rst_n, en, d, output reg q);
  always @(posedge clk or negedge rst_n) if (!rst_n) q <= 1'b0; else if (en) q <= d;
endmodule
