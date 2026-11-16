`timescale 1ns/1ps
// Self-checking AXI4-Lite testbench (plain Verilog: Icarus and Verilator --timing).
//  * a write stream and a read stream run in parallel (disjoint register sets per phase)
//  * random AW/W order and delays, random BREADY/RREADY backpressure
//  * memory reference model, response checks, payload-stability monitors
//  * "coverage lite": 20 bins, printed as COVERAGE: x%
//  +SEED=<n>  +N=<writes and reads per stream>  +MODE=0 random | 1 back-to-back | 2 heavy backpressure
module tb_axil;
  reg aclk = 0, aresetn = 0; always #5 aclk = ~aclk;
  reg awvalid = 0, wvalid = 0, arvalid = 0, bready = 0, rready = 0;
  reg [7:0] awaddr = 0, araddr = 0; reg [31:0] wdata = 0; reg [3:0] wstrb = 0;
  wire awready, wready, bvalid, arready, rvalid; wire [1:0] bresp, rresp; wire [31:0] rdata;
  axil_regs dut (aclk, aresetn, awvalid, awaddr, awready, wvalid, wdata, wstrb, wready,
                 bvalid, bresp, bready, arvalid, araddr, arready, rvalid, rdata, rresp, rready);

  integer seed = 1, seed0 = 1, N = 500, MODE = 0, errors = 0, nw = 0, nr = 0, phase = 0;
  reg [31:0] model [0:15];
  reg [19:0] cov = 0;
  integer i;
  function integer popc(input [19:0] v); integer k; begin popc = 0; for (k = 0; k < 20; k = k + 1) popc = popc + v[k]; end endfunction
  task err(input [8*64-1:0] msg); begin errors = errors + 1; if (errors <= 8) $display("ERR %0s t=%0t", msg, $time); end endtask

  // ---------------- random ready generators (backpressure) ----------------
  integer bstall = 0, rstall = 0;
  always @(posedge aclk) begin
    if (bstall > 0) begin bready <= 0; bstall = bstall - 1; end
    else begin bready <= 1; if ($random(seed) % ((MODE == 2) ? 2 : 5) == 0) bstall = $unsigned($random(seed)) % 8; end
    if (rstall > 0) begin rready <= 0; rstall = rstall - 1; end
    else begin rready <= 1; if ($random(seed) % ((MODE == 2) ? 2 : 5) == 0) rstall = $unsigned($random(seed)) % 8; end
  end

  // ---------------- protocol monitors (the SVA checker says the same in tb/axil_sva.sv) ----------------
  reg bv_q = 0, br_q = 0, rv_q = 0, rr_q = 0; reg [1:0] bresp_q; reg [31:0] rdata_q; reg [1:0] rresp_q;
  integer bwait = 0, rwait = 0;
  // a write response may only follow a write whose address AND data were both accepted
  integer n_aw = 0, n_w = 0, n_b = 0;
  always @(posedge aclk) if (aresetn) begin
    if (awvalid && awready) n_aw = n_aw + 1;
    if (wvalid && wready)   n_w  = n_w + 1;
    if (bvalid && !bv_q && (n_b + 1 > n_aw || n_b + 1 > n_w)) err("B channel: BVALID before AW and W were both accepted");
    if (bvalid && bready)   n_b  = n_b + 1;
  end
  always @(posedge aclk) if (aresetn) begin
    if (bv_q && !br_q && (!bvalid || bresp !== bresp_q)) err("B channel: BVALID/BRESP not held until BREADY");
    if (rv_q && !rr_q && (!rvalid || rdata !== rdata_q || rresp !== rresp_q)) err("R channel: RVALID/RDATA not held until RREADY");
    bv_q <= bvalid; br_q <= bready; bresp_q <= bresp; rv_q <= rvalid; rr_q <= rready; rdata_q <= rdata; rresp_q <= rresp;
  end

  // ---------------- write stream ----------------
  task axi_write(input [7:0] a, input [31:0] d, input [3:0] s, input integer daw, input integer dw);
    integer t_aw, t_w, cyc, k; reg [1:0] r; reg [31:0] m;
    begin
      t_aw = 0; t_w = 0;
      fork
        begin
          repeat (daw) @(posedge aclk); #1 awvalid = 1; awaddr = a; cyc = 0;
          @(posedge aclk); while (!awready) @(posedge aclk); t_aw = $time; #1 awvalid = 0;
        end
        begin
          repeat (dw) @(posedge aclk); #1 wvalid = 1; wdata = d; wstrb = s;
          @(posedge aclk); while (!wready) @(posedge aclk); t_w = $time; #1 wvalid = 0;
        end
      join
      cov[(t_aw < t_w) ? 10 : (t_w < t_aw) ? 11 : 12] = 1;
      bwait = 0;
      @(posedge aclk); while (!(bvalid && bready)) begin if (bvalid) bwait = bwait + 1; @(posedge aclk); end
      r = bresp;
      cov[(bwait == 0) ? 13 : (bwait < 4) ? 14 : 15] = 1;
      if (a >= 8'h40) begin if (r !== 2'b10) err("BRESP should be SLVERR"); cov[1] = 1; end
      else begin
        if (r !== 2'b00) err("BRESP should be OKAY");
        cov[0] = 1;
        m = model[a[5:2]];
        for (k = 0; k < 4; k = k + 1) if (s[k]) m[k*8 +: 8] = d[k*8 +: 8];
        model[a[5:2]] = m;
      end
      cov[(s == 4'hF) ? 4 : (s == 4'h1) ? 5 : (s == 4'h3) ? 6 : (s == 4'hC) ? 7 : (s == 4'h0) ? 8 : 9] = 1;
      if (daw == 0 && dw == 0) cov[19] = 1;
      nw = nw + 1;
    end
  endtask

  // ---------------- read stream ----------------
  task axi_read(input [7:0] a, input integer dar);
    reg [31:0] d; reg [1:0] r;
    begin
      repeat (dar) @(posedge aclk); #1 arvalid = 1; araddr = a;
      @(posedge aclk); while (!arready) @(posedge aclk); #1 arvalid = 0;
      rwait = 0;
      @(posedge aclk); while (!(rvalid && rready)) begin if (rvalid) rwait = rwait + 1; @(posedge aclk); end
      d = rdata; r = rresp;
      cov[(rwait == 0) ? 16 : (rwait < 4) ? 17 : 18] = 1;
      if (a >= 8'h40) begin if (r !== 2'b10) err("RRESP should be SLVERR"); cov[3] = 1; end
      else begin
        if (r !== 2'b00) err("RRESP should be OKAY");
        if (d !== model[a[5:2]]) begin errors = errors + 1; if (errors <= 8) $display("ERR read @%h got %h exp %h", a, d, model[a[5:2]]); end
        cov[2] = 1;
      end
      nr = nr + 1;
    end
  endtask

  function [7:0] pick_addr(input integer par);   // register with index parity 'par', or 10% out of range
    reg [7:0] x; begin
      if ($unsigned($random(seed)) % 10 == 0) pick_addr = 8'h40 + (($unsigned($random(seed)) % 48) << 2);
      else begin x = ($unsigned($random(seed)) % 8) * 2 + par; pick_addr = {x[3:0], 2'b00}; end
    end endfunction
  function [3:0] pick_strb(input integer dummy);
    integer c; begin
      c = $unsigned($random(seed)) % 10;
      pick_strb = (c < 5) ? 4'hF : (c == 5) ? 4'h1 : (c == 6) ? 4'h3 : (c == 7) ? 4'hC : (c == 8) ? 4'h0 : $random(seed);
    end endfunction
  function integer pick_delay(input integer dummy);
    pick_delay = (MODE == 1) ? 0 : (($unsigned($random(seed)) % 3 == 0) ? 0 : $unsigned($random(seed)) % 4);
  endfunction

  integer j;
  initial begin
    if ($value$plusargs("SEED=%d", seed)) ; seed0 = seed;
    if ($value$plusargs("N=%d", N)) ;
    if ($value$plusargs("MODE=%d", MODE)) ;
    for (i = 0; i < 16; i = i + 1) model[i] = 0;
    repeat (3) @(posedge aclk); #1 aresetn = 1;
    for (phase = 0; phase < 10; phase = phase + 1)
      fork
        for (i = 0; i < N / 10; i = i + 1)                        // writes: parity phase%2
          axi_write(pick_addr(phase % 2), $random(seed), pick_strb(0), pick_delay(0), pick_delay(0));
        for (j = 0; j < N / 10; j = j + 1)                        // reads: the other parity
          axi_read(pick_addr(1 - phase % 2), pick_delay(0));
      join
    repeat (5) @(posedge aclk);
    $display("writes=%0d reads=%0d mode=%0d", nw, nr, MODE);
    $display("COVERAGE: %0.1f%%", 100.0 * popc(cov) / 20.0);
    for (i = 0; i < 20; i = i + 1) if (!cov[i]) $display("  coverage hole: bin %0d", i);
    $display("RESULT: %s errors=%0d seed=%0d", errors ? "FAIL" : "PASS", errors, seed0);
    $finish;
  end
  initial begin #50000000; $display("RESULT: FAIL timeout (hang)"); $finish; end
endmodule
