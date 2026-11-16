# P3.1: UVM fundamentals on a small ALU

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

A small ALU with start/done and a 3-cycle multiply (my own design, not the UVM Primer's code),
and a full UVM bench: sequence item, corner-case item, sequence, sequencer, driver, monitor, agent,
scoreboard, environment, a random test and a factory-override test that swaps in the corner item.

## Run
```
iverilog -g2012 -o smoke.out rtl/small_alu.sv tb/tb_smoke.v && vvp smoke.out   # RTL smoke test
<UVM 1.2 simulator> tb/alu_if.sv tb/alu_pkg.sv tb/top.sv +UVM_TESTNAME=alu_random_test
```

## Results
- RTL smoke test PASS (5,000 operations, Icarus).
- **The UVM bench was not run here** (needs a UVM simulator, e.g. EDA Playground).

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Step 1 (type in the book's examples) and step 4 (rewrite the bench from a blank file) are mine.
