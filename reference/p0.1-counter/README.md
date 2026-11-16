# P0.1: toolchain and first full loop (4-bit counter)

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

The first complete loop: RTL -> testbench -> waveform -> lint -> synthesis, on a 4-bit counter
with enable and synchronous clear. The testbench is the one from the P0.1 guide.

## Run
```
make sim     # Icarus
make wave    # GTKWave
make lint
make synth   # Yosys: 10 cells (4 flops with enable, 3 XOR, 2 AND, 1 NOT)
```

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Type it in again myself and get the same 10-cell result.
