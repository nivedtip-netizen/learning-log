// Shared types and parameters for the FIFO, its testbench and later projects.
package fifo_pkg;
  parameter int DEPTH = 16;
  parameter int W     = 8;
  typedef logic [W-1:0] data_t;
endpackage
