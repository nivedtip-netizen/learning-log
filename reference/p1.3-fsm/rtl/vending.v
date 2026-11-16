// Vending machine: item costs 15. coin: 2'b01 = 5, 2'b10 = 10, else none.
// When the total reaches 15 or more: dispense pulses and change (0 or 5) is
// returned in the same registered cycle, then the credit goes back to 0.
module vending (input wire clk, rst_n, input wire [1:0] coin,
                output reg dispense, output reg [3:0] change, output reg [1:0] credit);
  localparam C0 = 2'd0, C5 = 2'd1, C10 = 2'd2;   // credit state = 0, 5, 10
  wire [4:0] add  = (coin == 2'b01) ? 5'd5 : (coin == 2'b10) ? 5'd10 : 5'd0;
  wire [4:0] tot  = {credit, 2'b00} + {3'b0, credit} + add;   // credit*5 + coin
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin credit <= C0; dispense <= 0; change <= 0; end
    else if (tot >= 15) begin
      credit <= C0; dispense <= 1'b1; change <= (tot == 5'd20) ? 4'd5 : 4'd0;   // tot is 15 or 20 here
    end else begin
      credit <= (tot == 5'd10) ? C10 : (tot == 5'd5) ? C5 : C0; dispense <= 1'b0; change <= 0;
    end
endmodule
