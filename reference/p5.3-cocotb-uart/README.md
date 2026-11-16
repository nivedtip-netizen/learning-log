# P5.3: cocotb port of the UART test

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

The P1.5 UART tests rewritten in Python with cocotb 2.1: a 500-byte loopback with a Python
scoreboard, a bit-banged receiver test with good frames, bad parity and a bad stop bit, and a
glitch test. CI runs it on every push (`.github/workflows/ci.yml` at the repo root).

## Run
```
pip install cocotb==2.1.0
make                # Icarus
```

## Results
- 3/3 tests PASS on Icarus.
- Verilator: cocotb 2.1 needs Verilator 5.036 or newer; this environment has 5.020, so not run.

## Easier in cocotb vs UVM (my notes to write)

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Thinking drill: two things that were easier in cocotb, two easier in UVM.
