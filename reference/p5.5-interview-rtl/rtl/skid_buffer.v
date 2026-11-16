`timescale 1ns/1ps
// Skid buffer: a valid/ready pipeline stage whose in_ready comes straight from a flop
// (in_ready = !skid_v), so the long combinational ready path is cut.
// When the output stalls, the word already in flight "skids" into the spare register.
// Full throughput: one word per cycle while out_ready stays high.
module skid_buffer #(parameter W = 8) (
  input  wire         clk, rst_n,
  input  wire         in_valid,  output wire in_ready,
  input  wire [W-1:0] in_data,
  output reg          out_valid, input  wire out_ready,
  output reg  [W-1:0] out_data
);
  reg skid_v; reg [W-1:0] skid_d;
  assign in_ready = !skid_v;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin out_valid <= 1'b0; out_data <= {W{1'b0}}; skid_v <= 1'b0; skid_d <= {W{1'b0}}; end
    else if (!out_valid || out_ready) begin            // output register is free this cycle
      if (skid_v) begin out_data <= skid_d; out_valid <= 1'b1; skid_v <= 1'b0; end
      else begin out_valid <= in_valid; if (in_valid) out_data <= in_data; end
    end else if (in_valid && in_ready) begin            // output stalled: park the word
      skid_d <= in_data; skid_v <= 1'b1;
    end
endmodule
