# Reference implementations of my RTL/DV study plan

> **Reference implementation, built with AI help.** Everything under `reference/` was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding each project myself, step by step, and my own version will replace the one here. None of it is my solo work yet, and I do not present it as such.

Every folder has a README with what it is, the one-line command to run it, the results, the bugs
found while building it, and what was **not** run (some benches need a commercial simulator or tools
that were not available).

## Flagships

| Project | What it shows | Headline result |
|---|---|---|
| [p1.5-uart](p1.5-uart) | UART TX/RX, 16x oversampling, FIFOs | 10,000 bytes in loopback, 0 errors; +-4 % clock tolerance |
| [p2.4-apb-regblock](p2.4-apb-regblock) | APB4 register block, verification plan, SVA, bash + Python regression | 100 % coverage bins; 3/3 seeded bugs caught |
| [p3.3-axi4lite](p3.3-axi4lite) | AXI4-Lite slave, protocol checker, full AXI4 bursts | 5/5 seeded bugs caught; bursts FIXED/INCR/WRAP |
| [p4-rv32i](p4-rv32i) | RV32I single-cycle + 5-stage pipeline, C reference model, DPI-C, random programs | 1,128,302 random instructions per core, 0 mismatches, 161/161 coverage bins |
| [p5.7-systolic-int8](p5.7-systolic-int8) | INT8 systolic array, NumPy golden model | bit-exact at 2x2, 4x4, 8x8; area and gate-depth scaling |

## All projects

| Folder | Topic |
|---|---|
| [mini1-number-flags](mini1-number-flags) | number formats and Z/N/C/V flags (Python) |
| [mini4-stopwatch](mini4-stopwatch) | counter + FSM + 7-segment stopwatch |
| [p0.1-counter](p0.1-counter) | first full loop: RTL, testbench, waves, lint, synthesis |
| [p1.1-alu](p1.1-alu) | combinational blocks, RCA vs CLA, 8-bit ALU |
| [p1.2-sequential](p1.2-sequential) | flops, counters, LFSR, shift registers, clock dividers |
| [p1.3-fsm](p1.3-fsm) | sequence detectors, traffic light, vending machine |
| [p1.4-fifo](p1.4-fifo) | sync FIFO, async FIFO with Gray pointers and a metastability model |
| [p1.5-uart](p1.5-uart) | UART with FIFOs |
| [p1.6-spi-i2c](p1.6-spi-i2c) | SPI slave (4 modes), I2C master vs EEPROM model |
| [p2.1-sv-fifo-lab](p2.1-sv-fifo-lab) | SystemVerilog features on the FIFO (not run here) |
| [p2.2-class-tb](p2.2-class-tb) | class-based layered testbench (not run here) |
| [p2.3-coverage-sva](p2.3-coverage-sva) | assertions and coverage on the FIFO |
| [p2.4-apb-regblock](p2.4-apb-regblock) | APB register block + verification plan |
| [p3.1-uvm-alu](p3.1-uvm-alu) | UVM basics (UVM not run here) |
| [p3.2-uvm-apb-ral](p3.2-uvm-apb-ral) | UVM + RAL for the APB block (not run here) |
| [p3.3-axi4lite](p3.3-axi4lite) | AXI4-Lite slave + AXI4 bursts |
| [p4-rv32i](p4-rv32i) | RISC-V cores |
| [p5.1-formal-fifo](p5.1-formal-fifo) | BMC and k-induction; formal vs random on a rare bug |
| [p5.2-cdc-sta](p5.2-cdc-sta) | CDC library, SDC, gate-level simulation |
| [p5.3-cocotb-uart](p5.3-cocotb-uart) | cocotb version of the UART test |
| [p5.5-interview-rtl](p5.5-interview-rtl) | 8 classic interview designs |
| [p5.6-company-flow](p5.6-company-flow) | regression, Yosys TCL cell table, beamformer DV note |
| [p5.7-systolic-int8](p5.7-systolic-int8) | INT8 systolic array |
| [tools](tools) | `regress.py` (parallel regression + HTML dashboard), `synth_all.tcl` |
| [issues](issues) | the bugs found while building, filed as GitHub issues |

## Run everything

```
bash reference/ci/smoke.sh                     # every must-pass simulation (about 3 minutes)
WITH_VERILATOR=1 bash reference/ci/smoke.sh    # plus the Verilator SVA benches
cd reference && yosys -c tools/synth_all.tcl   # one cell-count table for all designs
```

Tools: Icarus Verilog 12, Verilator 5.020, Yosys 0.33, Python 3 with NumPy, cocotb 2.1, a RISC-V gcc.
The same smoke run is in `.github/workflows/ci.yml`.

## What was not run

- UVM benches (P3.1, P3.2, P3.3 `uvm/`, P4 `uvm/`) and the class-based benches of P2.1/P2.2: they need a simulator with full SystemVerilog/UVM support (EDA Playground).
- SymbiYosys (P5.1 uses plain Yosys `sat` instead), OpenSTA and OpenLane (P5.2 SDC, P5.7 layout).
