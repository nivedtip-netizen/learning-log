`timescale 1ns/1ps
// Self-checking APB testbench (plain Verilog: runs on Icarus and Verilator).
//   +SEED=<n>   random seed        +N=<n>   number of transfers
//   -P/-G WAIT=<n>  wait states    Prints "COVERAGE: x%" and "RESULT: PASS|FAIL" for the regression scripts.
module tb_apb;
  parameter WAIT = 1;
  reg pclk = 0, presetn = 0; always #5 pclk = ~pclk;
  reg psel = 0, penable = 0, pwrite = 0; reg [7:0] paddr = 0; reg [31:0] pwdata = 0; reg [3:0] pstrb = 0;
  wire [31:0] prdata, cmd_data, ctrl_o; wire pready, pslverr, irq, cmd_valid;
  reg [31:0] hw_status = 0, hw_event = 0;
  apb_regs #(.WAIT_STATES(WAIT)) dut (pclk, presetn, psel, penable, pwrite, paddr, pwdata, pstrb, prdata, pready, pslverr,
                                      hw_status, hw_event, irq, cmd_valid, cmd_data, ctrl_o);
  // ---------------- reference model ----------------
  reg [31:0] m_ctrl = 0, m_int = 0, m_en = 0, m_scr = 0; reg [7:0] m_cfg = 8'hFF;
  reg [31:0] clr_now = 0;                       // W1C clear applied at this edge
  integer errors = 0, seed = 1, seed0 = 1, N = 3000, i, n_err = 0, n_cmd = 0, exp_cmd = 0;
  function [31:0] merge(input [31:0] o, input [31:0] n, input [3:0] s);
    integer b; begin for (b = 0; b < 4; b = b + 1) merge[b*8 +: 8] = s[b] ? n[b*8 +: 8] : o[b*8 +: 8]; end endfunction
  always @(posedge pclk) if (presetn) begin m_int = (m_int & ~clr_now) | hw_event; clr_now = 0; end
  always @(posedge pclk) if (cmd_valid) n_cmd = n_cmd + 1;
  function [31:0] model_read(input [7:0] a);
    case (a)
      8'h00: model_read = m_ctrl;  8'h04: model_read = hw_status; 8'h08: model_read = m_int;
      8'h0C: model_read = m_en;    8'h10: model_read = 0;         8'h14: model_read = m_scr;
      8'h18: model_read = 32'h0001_0200; 8'h1C: model_read = {24'h0, m_cfg};
      default: model_read = 0;
    endcase endfunction

  // ---------------- coverage lite ----------------
  // bins: 8 registers x {read, write} = 16, bad address read/write = 2, strobe patterns {0001,0011,1111,other} = 4,
  //       irq seen 0->1 = 1, W1C clear of a set bit = 1. Total 24.
  reg [23:0] cov = 0; reg irq_q = 0;
  always @(posedge pclk) begin if (irq && !irq_q) cov[22] = 1; irq_q <= irq; end
  function integer popc(input [23:0] v); integer k; begin popc = 0; for (k = 0; k < 24; k = k + 1) popc = popc + v[k]; end endfunction

  // ---------------- protocol checks (same rules as the SVA checker) ----------------
  reg pen_q = 0, psel_q = 0, acc_q = 0; reg [7:0] pa_q; reg [31:0] pw_q;
  always @(posedge pclk) begin
    if (presetn) begin
      if (penable && !pen_q && !(psel_q && !pen_q)) begin errors = errors + 1; $display("PROTO ERR: PENABLE without setup phase"); end
      if (acc_q && (paddr !== pa_q || pwdata !== pw_q)) begin errors = errors + 1; $display("PROTO ERR: address/data changed in access phase"); end
    end
    pen_q <= penable; psel_q <= psel; acc_q <= psel && penable && !pready; pa_q <= paddr; pw_q <= pwdata;
  end

  // ---------------- APB master tasks ----------------
  task apb_xfer(input wr, input [7:0] a, input [31:0] d, input [3:0] s, output [31:0] rd, output err);
    begin
      @(posedge pclk); #1 psel = 1; penable = 0; pwrite = wr; paddr = a; pwdata = d; pstrb = wr ? s : 4'b0;   // setup
      @(posedge pclk); #1 penable = 1;                                                                    // access
`ifdef BAD_MASTER
      if (!pready) begin @(posedge pclk); #1 paddr = paddr ^ 8'h04; end   // protocol bug: address moves in a wait state
`endif
      @(negedge pclk); while (!pready) @(negedge pclk);
      rd = prdata; err = pslverr;
      if (wr && !err) begin
        case (a)
          8'h00: m_ctrl = merge(m_ctrl, d, s);  8'h0C: m_en = merge(m_en, d, s);
          8'h14: m_scr = merge(m_scr, d, s);    8'h1C: if (s[0]) m_cfg = d[7:0];
          8'h08: begin clr_now = merge(32'h0, d, s); if (|(clr_now & m_int)) cov[23] = 1; end
          8'h10: exp_cmd = exp_cmd + 1;
          default: ;
        endcase
      end
      @(posedge pclk); #1 psel = 0; penable = 0;
    end endtask

  reg [31:0] rd, d; reg err, wr, exp_err; reg [7:0] a; reg [3:0] s;
  initial begin
    if ($value$plusargs("SEED=%d", seed)) ; seed0 = seed; if ($value$plusargs("N=%d", N)) ;
    i = $random(seed);
    #22 presetn = 1;
    // reset values
    for (i = 0; i < 8; i = i + 1) begin
      apb_xfer(0, i*4, 0, 0, rd, err);
      if (rd !== model_read(i*4)) begin errors = errors + 1; $display("ERR reset value @%h got %h exp %h", i*4, rd, model_read(i*4)); end
    end
    for (i = 0; i < N; i = i + 1) begin
      wr = $random(seed);
      a  = ($random(seed) % 10 == 0) ? (($random(seed) & 1) ? 8'h20 + ($random(seed) & 8'h1C) : 8'h01 + ($random(seed) & 8'h1C))
                                     : ($random(seed) & 8'h1C);
      d  = $random(seed);
      case ($random(seed) & 3) 0: s = 4'b0001; 1: s = 4'b0011; 2: s = 4'b1111; default: s = $random(seed); endcase
      if (($random(seed) & 7) == 0) hw_event = 32'h1 << ($random(seed) & 31); else hw_event = 0;
      if (($random(seed) & 15) == 0) hw_status = $random(seed);
      exp_err = (a > 8'h1C) || (a[1:0] != 0);
      apb_xfer(wr, a, d, s, rd, err);
      hw_event = 0;
      if (err !== exp_err) begin errors = errors + 1; $display("ERR pslverr @%h got %b", a, err); end
      if (!wr && !exp_err && rd !== model_read(a)) begin errors = errors + 1; if (errors < 6) $display("ERR read @%h got %h exp %h", a, rd, model_read(a)); end
      if (exp_err) begin n_err = n_err + 1; cov[16 + wr] = 1; end else cov[{a[4:2], wr}] = 1;
      if (wr) cov[18 + ((s == 4'b0001) ? 0 : (s == 4'b0011) ? 1 : (s == 4'b1111) ? 2 : 3)] = 1;
      if (irq !== |(m_int & m_en)) begin errors = errors + 1; $display("ERR irq"); end
    end
    repeat (3) @(posedge pclk);
    if (n_cmd !== exp_cmd) begin errors = errors + 1; $display("ERR cmd pulses %0d expected %0d", n_cmd, exp_cmd); end
    $display("transfers=%0d slverr=%0d cmd=%0d wait=%0d", N + 8, n_err, n_cmd, WAIT);
    $display("COVERAGE: %0.1f%%", 100.0 * popc(cov) / 24.0);
    $display("RESULT: %s errors=%0d seed=%0d", errors ? "FAIL" : "PASS", errors, seed0);
    $finish;
  end
endmodule
