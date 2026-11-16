// Mini 4: 00-59 stopwatch.
//   btn_ss  : one-cycle pulse, start/stop (IDLE->RUN, RUN<->PAUSE)
//   btn_clr : one-cycle pulse, back to IDLE with 00 (works in any state)
//   TICK_DIV: clock cycles per second (small in simulation)
module stopwatch #(parameter TICK_DIV = 10) (
  input  wire       clk, rst_n,
  input  wire       btn_ss, btn_clr,
  output reg  [3:0] ones, tens,
  output wire [6:0] seg_ones, seg_tens,
  output reg  [1:0] state
);
  localparam IDLE = 2'd0, RUN = 2'd1, PAUSE = 2'd2;

  // ---- control: FSM --------------------------------------------------
  reg [1:0] nxt;
  always @(*) begin
    nxt = state;
    if (btn_clr) nxt = IDLE;
    else if (btn_ss)
      case (state)
        IDLE:  nxt = RUN;
        RUN:   nxt = PAUSE;
        PAUSE: nxt = RUN;
        default: nxt = IDLE;
      endcase
  end
  always @(posedge clk or negedge rst_n)
    if (!rst_n) state <= IDLE; else state <= nxt;

  // ---- 1 Hz enable (tick), only counts while RUN ------------------------
  localparam CW = (TICK_DIV > 1) ? $clog2(TICK_DIV) : 1;
  reg [CW-1:0] div;
  wire tick = (state == RUN) && (div == TICK_DIV-1);
  always @(posedge clk or negedge rst_n)
    if (!rst_n)                 div <= 0;
    else if (state != RUN)      div <= (nxt == IDLE) ? 0 : div; // PAUSE keeps phase
    else if (div == TICK_DIV-1) div <= 0;
    else                        div <= div + 1'b1;

  // ---- datapath: mod-10 ones, mod-6 tens --------------------------------
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin ones <= 0; tens <= 0; end
    else if (btn_clr) begin ones <= 0; tens <= 0; end
    else if (tick) begin
      if (ones == 4'd9) begin
        ones <= 0;
        tens <= (tens == 4'd5) ? 4'd0 : tens + 1'b1;   // 59 -> 00
      end else ones <= ones + 1'b1;
    end

  seg7 u_o (.d(ones), .seg(seg_ones));
  seg7 u_t (.d(tens), .seg(seg_tens));
endmodule
