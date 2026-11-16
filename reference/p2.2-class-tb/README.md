# P2.2: class-based layered testbench (UVM by hand)

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

Transaction, generator, driver, monitor, scoreboard, environment and four tests (fill, drain,
random, back-to-back), plus reset in the middle of a test, written with plain SystemVerilog
classes and mailboxes: the structure UVM automates.

## Run (needs a full SystemVerilog simulator)
```
<simulator> -f files.f +TEST=random
```

## Results
- **Not run here.** Verilator 5.020 ignores `rand` constraints and cannot drive through a clocking block in a virtual interface.

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Run on EDA Playground; then build my own version of each class before reading this one.
