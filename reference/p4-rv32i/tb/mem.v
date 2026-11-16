`timescale 1ns/1ps
// Unified 64 KB memory: combinational instruction and data reads, byte-enable writes.
// A store to TOHOST (0xFFF0) ends the test: value 1 = pass, anything else = fail ((n << 1) | 1 = test n failed).
module mem #(parameter WORDS = 16384, parameter HEX = "prog.hex") (
  input  wire clk,
  input  wire [31:0] iaddr, output wire [31:0] idata,
  input  wire [31:0] daddr, input wire [31:0] dwdata, input wire [3:0] dbe, output wire [31:0] drdata
);
  reg [31:0] m [0:WORDS-1];
  integer i; reg [8*256-1:0] hexfile;
  initial begin
    for (i = 0; i < WORDS; i = i + 1) m[i] = 32'h0;
    if (!$value$plusargs("HEX=%s", hexfile)) hexfile = HEX;
    $readmemh(hexfile, m);
  end
  assign idata  = m[iaddr[15:2]];
  assign drdata = m[daddr[15:2]];
  always @(posedge clk) begin
    if (dbe[0]) m[daddr[15:2]][7:0]   <= dwdata[7:0];
    if (dbe[1]) m[daddr[15:2]][15:8]  <= dwdata[15:8];
    if (dbe[2]) m[daddr[15:2]][23:16] <= dwdata[23:16];
    if (dbe[3]) m[daddr[15:2]][31:24] <= dwdata[31:24];
  end
endmodule
