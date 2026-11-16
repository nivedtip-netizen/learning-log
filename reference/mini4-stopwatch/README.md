# Mini 4: digital stopwatch (counter, FSM, 7-segment)

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

00-59 stopwatch: a tick divider, a mod-10 and a mod-6 counter, an IDLE/RUN/PAUSE FSM driven
by start/stop and reset buttons, and a 7-segment decoder for both digits.

## Run
```
make sim     # testbench with a reference model of the expected display
make lint    # Verilator -Wall
make synth   # Yosys cell count
```

## Results
- PASS against the reference model (start, pause, resume, reset, wrap 59 -> 00). Lint clean.
- 132 cells, 14 flops (Yosys generic gates).

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- My Mini 2 decoder (fundamentals/mini2-7seg) should replace `seg7.v` here once I rebuild this.
