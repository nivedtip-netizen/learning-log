`timescale 1ns/1ps
// UART receiver with 16x oversampling. The start bit is confirmed at its middle
// (8 ticks after the falling edge); every later bit is sampled 16 ticks apart,
// i.e. in the middle of each bit. A glitch shorter than half a bit is ignored.
module uart_rx #(parameter PAR_EN = 1, PAR_ODD = 0) (
  input wire clk, rst_n, tick, rxd,
  output reg [7:0] data, output reg valid, output reg frame_err, output reg parity_err
);
  localparam IDLE = 3'd0, START = 3'd1, DATA = 3'd2, PAR = 3'd3, STOP = 3'd4, WAIT_HI = 3'd5;
  reg r1, r2;                                    // 2-flop synchronizer: rxd is asynchronous
  always @(posedge clk or negedge rst_n) if (!rst_n) {r1, r2} <= 2'b11; else {r1, r2} <= {rxd, r1};
  reg [2:0] st; reg [3:0] tcnt; reg [2:0] bitn; reg [7:0] sh; reg pbit;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin st <= IDLE; tcnt <= 0; bitn <= 0; sh <= 0; pbit <= 0;
                      data <= 0; valid <= 0; frame_err <= 0; parity_err <= 0; end
    else begin
      valid <= 1'b0; frame_err <= 1'b0; parity_err <= 1'b0;
      case (st)
        IDLE:  if (!r2) begin st <= START; tcnt <= 0; end
        START: if (tick) begin
                 if (tcnt == 4'd7) begin
                   if (!r2) begin st <= DATA; tcnt <= 0; bitn <= 0; end   // real start bit
                   else st <= IDLE;                                       // glitch
                 end else tcnt <= tcnt + 1'b1;
               end
        DATA:  if (tick) begin
                 tcnt <= tcnt + 1'b1;
                 if (tcnt == 4'd15) begin
                   sh <= {r2, sh[7:1]};
                   if (bitn == 3'd7) st <= PAR_EN ? PAR : STOP; else bitn <= bitn + 1'b1;
                 end
               end
        PAR:   if (tick) begin tcnt <= tcnt + 1'b1; if (tcnt == 4'd15) begin pbit <= r2; st <= STOP; end end
        STOP:  if (tick) begin
                 tcnt <= tcnt + 1'b1;
                 if (tcnt == 4'd15) begin
                   st <= r2 ? IDLE : WAIT_HI;   // after a bad stop bit, wait for the line to go idle
                   data <= sh; valid <= 1'b1;
                   frame_err  <= !r2;                                     // stop bit must be 1
                   parity_err <= PAR_EN && (pbit != (^sh ^ PAR_ODD[0]));
                 end
               end
        WAIT_HI: if (r2) st <= IDLE;   // a low line here is not a new start bit
        default: st <= IDLE;
      endcase
    end
endmodule
