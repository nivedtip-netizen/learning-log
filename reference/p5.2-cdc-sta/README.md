# P5.2: CDC library, reset synchronizer, SDC and gate-level simulation

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

`rtl/cdc_lib.v`: 2-flop synchronizer (with a simulation-only metastability model), toggle-based
pulse synchronizer with a busy output, 4-phase req/ack handshake for a 32-bit bus, and a reset
synchronizer (asynchronous assert, synchronous deassert). `sta/uart_top.sdc` constrains the P1.5
UART. `gls/` simulates the Yosys netlist of the UART with the unchanged RTL testbench.

## Run
```
make cdc     # 5 clock ratios x 3 seeds x (plain, metastability model)
make bad     # a source that ignores busy: expected FAIL
make gls     # zero-delay gate-level simulation of the UART
```

## Results
- All 30 CDC runs PASS at clock ratios 10:27, 27:10, 10:10.3, 7:50 and 50:7 ns: every pulse arrives once, every 32-bit word arrives in order and intact, the source never changes its held data while req is high, the reset is asserted at once and released only on a clock edge.
- Breaking condition (thinking drill): pulses closer than the busy window. With the source ignoring busy, 156 of 300 pulses are lost at 10:27 ns and 264 of 300 at 7:50 ns; the busy check fires at every ratio, even where no pulse happened to be lost.
- GLS: the UART netlist (about 1,075 generic gates) passes the same 10,000-byte test as the RTL. Two differences: the netlist has no parameters (a small shim keeps the testbench unchanged), and it runs about 8x slower (11.8 s vs 1.5 s for 1,000 bytes).

## SDC (not run)
`sta/uart_top.sdc`: 50 MHz clock with uncertainty, input/output delays at 40 % of the period, `rxd` and `rst_n` as false paths (both are asynchronous; `rxd` goes through the receiver's 2-flop synchronizer). Not run through OpenSTA here: no Liberty library in this environment.

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Step 4: 10 setup/hold slack problems on paper (mine).
- Run the SDC through OpenSTA with a Sky130 netlist on my laptop.
