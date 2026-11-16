# P1.3: FSMs (sequence detector, traffic light, vending machine)

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

1011 detector in four styles (Mealy/Moore x overlapping/non-overlapping, plus a one-hot copy),
a traffic light with a pedestrian request and safety rules, and a vending machine with change.

## Run
```
make sim
make synth   # binary vs one-hot encoding of the Mealy detector
make lint
```

## Results
- Detectors vs a shift-register model on 100,000 random bits (8,327 matches): PASS.
- Traffic light: safety rules checked every cycle, 1,439 walk requests served, worst wait 24 cycles.
- Vending machine: 100,000 random coins vs a model (22,143 items sold): PASS.
- Mealy overlapping detector: binary 14 cells / 2 flops, one-hot 31 cells / 4 flops.

## Bugs found while building
- `matches` is a reserved word in SystemVerilog; a testbench variable had that name (renamed).

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Draw each state diagram before reading the code.
