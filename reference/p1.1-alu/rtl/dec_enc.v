// 3:8 decoder with enable
module dec3to8 (input wire [2:0] in, input wire en, output wire [7:0] y);
  assign y = en ? (8'b1 << in) : 8'b0;
endmodule

// 8:3 priority encoder: highest set bit wins, valid=0 when no bit set
module prio_enc8 (input wire [7:0] in, output reg [2:0] y, output reg valid);
  always @(*) begin
    valid = 1'b1;
    casez (in)
      8'b1???????: y = 3'd7;
      8'b01??????: y = 3'd6;
      8'b001?????: y = 3'd5;
      8'b0001????: y = 3'd4;
      8'b00001???: y = 3'd3;
      8'b000001??: y = 3'd2;
      8'b0000001?: y = 3'd1;
      8'b00000001: y = 3'd0;
      default:     begin y = 3'd0; valid = 1'b0; end
    endcase
  end
endmodule
