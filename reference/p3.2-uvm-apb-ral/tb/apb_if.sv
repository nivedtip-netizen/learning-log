interface apb_if (input logic pclk);
  logic presetn, psel, penable, pwrite, pready, pslverr;
  logic [7:0] paddr; logic [31:0] pwdata, prdata; logic [3:0] pstrb;
  logic [31:0] hw_status, hw_event;
endinterface
