`timescale 1ns/1ps
// Runs a program on the single-cycle core (default) or the 5-stage pipeline (+define+PIPE).
//   +HEX=<file>     program image (one 32-bit word per line)
//   +TRACE=<file>   write the retirement trace (compared against the C reference model)
//   +MAXCYC=<n>     timeout
// Ends when the program stores to TOHOST (0xFFF0): 1 = pass, (n<<1)|1 = case n failed,
// or when the core halts (ECALL/EBREAK/illegal) for the random programs.
module tb_core;
  reg clk = 0, rst_n = 0; always #5 clk = ~clk;
  wire [31:0] iaddr, idata, daddr, dwdata, drdata; wire [3:0] dbe; wire dre, halted;
  wire rv; wire [31:0] rpc, rinsn, rwd, rma, rmw; wire [4:0] rrd; wire [3:0] rbe;
`ifdef PIPE
  rv32i_pipe cpu (
`else
  rv32i_single cpu (
`endif
    .clk(clk), .rst_n(rst_n), .imem_addr(iaddr), .imem_rdata(idata), .dmem_addr(daddr), .dmem_wdata(dwdata),
    .dmem_be(dbe), .dmem_re(dre), .dmem_rdata(drdata), .halted(halted),
    .ret_valid(rv), .ret_pc(rpc), .ret_insn(rinsn), .ret_rd(rrd), .ret_rd_wdata(rwd),
    .ret_mem_addr(rma), .ret_mem_wdata(rmw), .ret_mem_be(rbe));
  mem #(.HEX("sw/isa_test.hex")) memory (.clk(clk), .iaddr(iaddr), .idata(idata), .daddr(daddr), .dwdata(dwdata), .dbe(dbe), .drdata(drdata));

`ifdef DPI
  // lockstep against the C model through DPI-C (Verilator / commercial simulators)
  import "DPI-C" function int  rv_ref_init(input string hex);
  import "DPI-C" function void rv_ref_step(output int pc, output int insn, output int rd, output int rd_wdata,
                                           output int mem_addr, output int mem_wdata, output int be);
  int e_pc, e_insn, e_rd, e_wd, e_ma, e_mw, e_be, dpi_errors = 0;
  string hexname;
  initial begin
    if (!$value$plusargs("HEX=%s", hexname)) hexname = "sw/isa_test.hex";
    if (rv_ref_init(hexname) != 0) $fatal(1, "C model could not read %s", hexname);
  end
  always @(posedge clk) if (rst_n && rv) begin
    rv_ref_step(e_pc, e_insn, e_rd, e_wd, e_ma, e_mw, e_be);
    if (rpc !== e_pc || rinsn !== e_insn || rrd !== e_rd[4:0] || rwd !== e_wd || rma !== e_ma || rmw !== e_mw || rbe !== e_be[3:0]) begin
      dpi_errors++;
      if (dpi_errors <= 3) $display("DPI MISMATCH pc=%08x insn=%08x: core rd=%0d wd=%08x  model pc=%08x rd=%0d wd=%08x",
                                    rpc, rinsn, rrd, rwd, e_pc, e_rd, e_wd);
    end
  end
`endif
  integer fd = 0, cycles = 0, retired = 0, maxcyc = 2000000, stalls = 0, flushes = 0;
  reg [8*256-1:0] tracefile;
  initial begin
    if ($value$plusargs("TRACE=%s", tracefile)) fd = $fopen(tracefile, "w");
    if ($value$plusargs("MAXCYC=%d", maxcyc)) ;
    #22 rst_n = 1;
  end
  always @(posedge clk) if (rst_n) begin
    cycles = cycles + 1;
`ifdef PIPE
    if (cpu.stall) stalls = stalls + 1;
    if (cpu.flush) flushes = flushes + 1;
`endif
    if (rv) begin
      retired = retired + 1;
      if (fd) $fdisplay(fd, "%08x %08x %0d %08x %08x %08x %x", rpc, rinsn, rrd, rwd, rma, rmw, rbe);
    end
    if (rv && rbe != 0 && rma == 32'hFFF0) begin          // the TOHOST store has retired
      if (rmw == 1) $display("TOHOST: pass");
      else $display("TOHOST: case %0d failed", rmw >> 1);
      finish(rmw == 1);
    end
    if (halted) begin $display("halted at pc=%08x", iaddr); finish(1); end
    if (cycles >= maxcyc) begin $display("timeout"); finish(0); end
  end
  task finish(input reg ok_in);
    reg ok;
    begin
      ok = ok_in;
      $display("cycles=%0d retired=%0d CPI=%0.3f stalls=%0d flushes=%0d", cycles, retired, retired ? 1.0 * cycles / retired : 0.0, stalls, flushes);
`ifdef DPI
      $display("DPI lockstep: %0d mismatches", dpi_errors);
      if (dpi_errors) ok = 0;
`endif
      $display("RESULT: %s", ok ? "PASS" : "FAIL");
      if (fd) $fclose(fd);
      $finish;
    end
  endtask
endmodule
