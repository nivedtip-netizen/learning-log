`timescale 1ns/1ps
// Random AXI4 bursts (FIXED / INCR / WRAP, lengths 1-16, random strobes and IDs)
// with random WVALID gaps and BREADY/RREADY backpressure, checked against a byte
// model. Every read burst checks data, RRESP, RID and that RLAST is on the last beat.
// Includes illegal requests (size != 4 bytes, bad WRAP length, out of range): expect SLVERR.
module tb_axi4;
  reg aclk = 0, aresetn = 0; always #5 aclk = ~aclk;
  reg awvalid = 0, wvalid = 0, wlast = 0, bready = 0, arvalid = 0, rready = 0;
  reg [3:0] awid = 0, arid = 0; reg [15:0] awaddr = 0, araddr = 0; reg [7:0] awlen = 0, arlen = 0;
  reg [2:0] awsize = 2, arsize = 2; reg [1:0] awburst = 1, arburst = 1;
  reg [31:0] wdata = 0; reg [3:0] wstrb = 0;
  wire awready, wready, bvalid, arready, rvalid, rlast; wire [3:0] bid, rid; wire [1:0] bresp, rresp; wire [31:0] rdata;
  axi4_mem dut (aclk, aresetn, awvalid, awid, awaddr, awlen, awsize, awburst, awready,
                wvalid, wdata, wstrb, wlast, wready, bvalid, bid, bresp, bready,
                arvalid, arid, araddr, arlen, arsize, arburst, arready,
                rvalid, rid, rdata, rresp, rlast, rready);

  integer seed = 1, seed0 = 1, errors = 0, i, nb_w = 0, nb_r = 0, beats = 0, nerr = 0;
  reg [31:0] model [0:255];
  task err(input [8*48-1:0] m); begin errors = errors + 1; if (errors <= 8) $display("ERR %0s t=%0t", m, $time); end endtask
  always @(posedge aclk) begin
    bready <= ($unsigned($random(seed)) % 4 != 0);
    rready <= ($unsigned($random(seed)) % 3 != 0);
  end

  // the same address sequence the slave must follow
  function [15:0] nxt(input [15:0] a, input [1:0] b, input [7:0] len);
    reg [15:0] wb, lo; begin
      wb = ({8'h0, len} + 1) * 4; lo = (a / wb) * wb;
      nxt = (b == 2'b00) ? a : (b == 2'b10 && a + 4 == lo + wb) ? lo : a + 4;
    end endfunction

  task wr_burst(input [3:0] id, input [15:0] a, input [7:0] len, input [1:0] b, input [2:0] sz, input expect_err);
    integer n, k; reg [15:0] ad; reg [31:0] d; reg [3:0] s; reg [31:0] m;
    begin
      @(posedge aclk); #1 awvalid = 1; awid = id; awaddr = a; awlen = len; awburst = b; awsize = sz;
      @(posedge aclk); while (!awready) @(posedge aclk); #1 awvalid = 0;
      ad = a;
      for (n = 0; n <= len; n = n + 1) begin
        if ($unsigned($random(seed)) % 4 == 0) begin @(posedge aclk); #1; end      // random WVALID gap
        d = $random(seed); s = ($unsigned($random(seed)) % 3 == 0) ? $random(seed) : 4'hF;
        wvalid = 1; wdata = d; wstrb = s; wlast = (n == len);
        @(posedge aclk); while (!wready) @(posedge aclk); #1 wvalid = 0; wlast = 0;
        if (!expect_err) begin
          m = model[ad[9:2]];
          for (k = 0; k < 4; k = k + 1) if (s[k]) m[k*8 +: 8] = d[k*8 +: 8];
          model[ad[9:2]] = m;
        end
        ad = nxt(ad, b, len); beats = beats + 1;
      end
      @(posedge aclk); while (!(bvalid && bready)) @(posedge aclk);
      if (bid !== id) err("BID mismatch");
      if (bresp !== (expect_err ? 2'b10 : 2'b00)) err("BRESP wrong");
      nb_w = nb_w + 1;
    end endtask

  task rd_burst(input [3:0] id, input [15:0] a, input [7:0] len, input [1:0] b, input [2:0] sz, input expect_err);
    integer n; reg [15:0] ad;
    begin
      @(posedge aclk); #1 arvalid = 1; arid = id; araddr = a; arlen = len; arburst = b; arsize = sz;
      @(posedge aclk); while (!arready) @(posedge aclk); #1 arvalid = 0;
      ad = a;
      for (n = 0; n <= len; n = n + 1) begin
        @(posedge aclk); while (!(rvalid && rready)) @(posedge aclk);
        if (rid !== id) err("RID mismatch");
        if (rlast !== (n == len)) err("RLAST on the wrong beat");
        if (expect_err) begin if (rresp !== 2'b10) err("RRESP should be SLVERR"); end
        else begin
          if (rresp !== 2'b00) err("RRESP should be OKAY");
          if (rdata !== model[ad[9:2]]) begin errors = errors + 1; if (errors <= 8) $display("ERR rd beat %0d @%h got %h exp %h burst=%0d len=%0d", n, ad, rdata, model[ad[9:2]], b, len); end
        end
        ad = nxt(ad, b, len); beats = beats + 1;
      end
      nb_r = nb_r + 1;
    end endtask

  reg [1:0] b; reg [7:0] len; reg [15:0] a; reg [3:0] id; integer c;
  initial begin
    if ($value$plusargs("SEED=%d", seed)) ; seed0 = seed;
    for (i = 0; i < 256; i = i + 1) begin model[i] = 0; dut.mem[i] = 0; end   // backdoor preload: RAM has no reset
    repeat (3) @(posedge aclk); #1 aresetn = 1;
    for (i = 0; i < 600; i = i + 1) begin
      c = $unsigned($random(seed)) % 3; b = (c == 0) ? 2'b00 : (c == 1) ? 2'b01 : 2'b10;
      if (b == 2'b10) begin c = $unsigned($random(seed)) % 4; len = (c == 0) ? 1 : (c == 1) ? 3 : (c == 2) ? 7 : 15; end
      else len = $unsigned($random(seed)) % 16;
      a = (($unsigned($random(seed)) % 200) << 2);            // stays below 0x400 for every burst type here
      id = $random(seed);
      if ($random(seed) & 1) wr_burst(id, a, len, b, 3'd2, 0); else rd_burst(id, a, len, b, 3'd2, 0);
      if ($unsigned($random(seed)) % 20 == 0) begin               // an illegal request now and then
        nerr = nerr + 1;
        case ($unsigned($random(seed)) % 3)
          0: rd_burst(id, a, 0, 2'b01, 3'd1, 1);                   // narrow size
          1: wr_burst(id, a, 2, 2'b10, 3'd2, 1);                   // WRAP length 3 beats
          2: rd_burst(id, 16'h0400, 0, 2'b01, 3'd2, 1);            // out of range
        endcase
      end
    end
    $display("write bursts=%0d read bursts=%0d beats=%0d illegal=%0d", nb_w, nb_r, beats, nerr);
    $display("RESULT: %s errors=%0d seed=%0d", errors ? "FAIL" : "PASS", errors, seed0);
    $finish;
  end
  initial begin #20000000; $display("RESULT: FAIL timeout"); $finish; end
endmodule
