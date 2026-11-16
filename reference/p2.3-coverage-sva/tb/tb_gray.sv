// Binds the one-bit-change assertion to both pointer crossings of the P1.4 async FIFO.
// Clean design: passes. -GBUG=1 (binary pointers cross): the assertion fires.
module tb_gray #(parameter int BUG = 0);
  logic wclk = 0, rclk = 0, wrst_n = 0, rrst_n = 0, push = 0, pop = 0, full, empty;
  logic [7:0] din = 0, dout; logic [3:0] rcount;
  always #5    wclk = ~wclk;
  always #13.5 rclk = ~rclk;
  async_fifo #(.W(8), .DEPTH(8), .BUG_BIN(BUG)) dut (.*);
  bind async_fifo gray_checker #(.W(4)) chk_w2r (.clk(wclk), .rst_n(wrst_n), .bus(BUG_BIN ? wbin : wgray));
  bind async_fifo gray_checker #(.W(4)) chk_r2w (.clk(rclk), .rst_n(rrst_n), .bus(BUG_BIN ? rbin : rgray));
  initial begin
    #40 wrst_n = 1; rrst_n = 1;
    repeat (3000) begin
      @(negedge wclk); push = $urandom_range(0, 1); din = $urandom;
      pop = $urandom_range(0, 1);
    end
    $display("tb_gray BUG=%0d: no assertion fired", BUG);
    $finish;
  end
endmodule
