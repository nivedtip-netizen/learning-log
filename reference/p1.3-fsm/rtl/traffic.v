// Two-road traffic light (NS main road, EW side road) with a pedestrian walk phase.
// Lights: 2'b00 red, 2'b01 yellow, 2'b10 green.
// ped_btn is latched; the walk phase runs after the next all-red following EW yellow.
// A pending request also cuts NS green short once T_MIN_G has passed.
module traffic #(parameter T_G = 12, T_MIN_G = 4, T_Y = 3, T_R = 1, T_WALK = 6) (
  input  wire       clk, rst_n, ped_btn,
  output reg  [1:0] ns, ew,
  output wire       walk,
  output reg  [2:0] st
);
  localparam NS_G = 3'd0, NS_Y = 3'd1, R1 = 3'd2, EW_G = 3'd3, EW_Y = 3'd4, R2 = 3'd5, WALK = 3'd6;
  reg [7:0] t;          // cycles spent in the current state
  reg       req;
  reg [2:0] nx;
  always @(*) begin
    nx = st;
    case (st)
      NS_G: if (t >= T_G-1 || (req && t >= T_MIN_G-1)) nx = NS_Y;
      NS_Y: if (t >= T_Y-1) nx = R1;
      R1:   if (t + 1 >= T_R) nx = EW_G;
      EW_G: if (t >= T_G-1) nx = EW_Y;
      EW_Y: if (t >= T_Y-1) nx = R2;
      R2:   if (t + 1 >= T_R) nx = req ? WALK : NS_G;
      WALK: if (t >= T_WALK-1) nx = NS_G;
      default: nx = NS_G;
    endcase
  end
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin st <= NS_G; t <= 0; req <= 0; end
    else begin
      st <= nx;
      t  <= (nx != st) ? 8'd0 : t + 1'b1;
      if (st == WALK)  req <= 1'b0;            // served
      else if (ped_btn) req <= 1'b1;
    end
  always @(*) begin
    ns = 2'b00; ew = 2'b00;
    case (st)
      NS_G: ns = 2'b10; NS_Y: ns = 2'b01;
      EW_G: ew = 2'b10; EW_Y: ew = 2'b01;
      default: ;
    endcase
  end
  assign walk = (st == WALK);
endmodule
