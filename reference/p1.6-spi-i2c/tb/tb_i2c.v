`timescale 1ns/1ps
module tb_i2c;
  reg clk = 0, rst_n = 0; always #5 clk = ~clk;
  tri1 scl, sda;                                   // tri1 = pull-up
  reg start = 0, rw = 0; reg [6:0] dev = 7'h50; reg [7:0] ma = 0, wd = 0;
  wire [7:0] rd; wire busy, done, nack, scl_oe, sda_oe;
  i2c_master #(.QDIV(4)) dut (clk, rst_n, start, rw, dev, ma, wd, rd, busy, done, nack, scl_oe, sda_oe, scl, sda);
  assign scl = scl_oe ? 1'b0 : 1'bz;
  assign sda = sda_oe ? 1'b0 : 1'bz;
  eeprom_model #(7'h50) rom (scl, sda);

  reg [7:0] model [0:255]; integer i, errors = 0, nw = 0, nr = 0, nn = 0, nr_written = 0;
  task op(input r, input [6:0] d, input [7:0] a, input [7:0] w);
    begin
      @(posedge clk); rw = r; dev = d; ma = a; wd = w; start = 1; @(posedge clk); start = 0;
      @(posedge done); @(posedge clk);
    end endtask
  initial begin
    for (i = 0; i < 256; i = i + 1) model[i] = 8'hFF;
    #23 rst_n = 1;
    for (i = 0; i < 300; i = i + 1) begin
      ma = $random & 8'h1F; wd = $random;          // small address range so reads hit written cells
      if ($random % 7 == 0) begin                  // wrong device address -> must NACK
        op($random, 7'h51, ma, wd); nn = nn + 1;
        if (!nack) begin errors = errors + 1; $display("ERR no NACK for wrong address"); end
      end else if ($random & 1) begin
        op(0, 7'h50, ma, wd); model[ma] = wd; nw = nw + 1;
        if (nack) begin errors = errors + 1; $display("ERR unexpected NACK on write"); end
      end else begin
        op(1, 7'h50, ma, 0); nr = nr + 1; if (model[ma] !== 8'hFF) nr_written = nr_written + 1;
        if (nack || rd !== model[ma]) begin errors = errors + 1; if (errors < 5) $display("ERR read %h got %h exp %h nack=%b", ma, rd, model[ma], nack); end
      end
    end
    $display("I2C: %0d writes, %0d reads (%0d of written cells), %0d NACK cases -> %s", nw, nr, nr_written, nn, errors ? "FAIL" : "PASS");
    $finish;
  end
  initial begin #50000000; $display("I2C TIMEOUT"); $finish; end
endmodule
