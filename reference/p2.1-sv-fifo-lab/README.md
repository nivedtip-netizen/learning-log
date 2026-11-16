# P2.1: SystemVerilog language lab on the FIFO

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

The FIFO rewritten with SystemVerilog features: a package with types, `logic`, `always_ff` /
`always_comb`, an interface with a clocking block and modports, and four seeded bugs
(`BUG_FULL`, `BUG_FLAGS`, `BUG_WRFULL`, `BUG_IDLE`). `+define+NO_CB` shows the race you get
without the clocking block.

## Run (needs a full SystemVerilog simulator, e.g. on EDA Playground)
```
<simulator> -f files.f              # files listed in files.f
```

## Results
- RTL is lint-clean in Verilator.
- **The testbench was not run here.** Verilator 5.020 does not support `modport clocking` or a clocking block through a virtual interface.

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Run it on EDA Playground (two simulators), then try each `BUG_*` define and write down which check catches it.
