`timescale 1ns/1ps
// UART transmitter, 8 data bits LSB first, optional parity, 1 stop bit.
// Each bit lasts 16 ticks. 'start' is accepted only when !busy.
module uart_tx #(parameter PAR_EN = 1, PAR_ODD = 0) (
  input wire clk, rst_n, tick, start, input wire [7:0] data,
  output reg txd, output wire busy
);
  localparam IDLE = 3'd0, START = 3'd1, DATA = 3'd2, PAR = 3'd3, STOP = 3'd4;
  reg [2:0] st; reg [3:0] tcnt; reg [2:0] bitn; reg [7:0] sh; reg par;
  assign busy = (st != IDLE);
  wire bit_end = tick && (tcnt == 4'd15);
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin st <= IDLE; txd <= 1'b1; tcnt <= 0; bitn <= 0; sh <= 0; par <= 0; end
    else begin
      if (tick) tcnt <= tcnt + 1'b1;
      case (st)
        IDLE:  begin txd <= 1'b1;
                 if (start) begin st <= START; sh <= data; par <= ^data ^ PAR_ODD[0]; tcnt <= 0; txd <= 1'b0; end end
        START: if (bit_end) begin st <= DATA; bitn <= 0; txd <= sh[0]; end
        DATA:  if (bit_end) begin
                 if (bitn == 3'd7) begin st <= PAR_EN ? PAR : STOP; txd <= PAR_EN ? par : 1'b1; end
                 else begin bitn <= bitn + 1'b1; sh <= sh >> 1; txd <= sh[1]; end
               end
        PAR:   if (bit_end) begin st <= STOP; txd <= 1'b1; end
        STOP:  if (bit_end) begin st <= IDLE; txd <= 1'b1; end
        default: st <= IDLE;
      endcase
    end
endmodule
