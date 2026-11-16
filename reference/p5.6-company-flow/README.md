# P5.6: how DV runs inside a company

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

- **Regression with sorting:** `../tools/regress.py` runs test x seed in parallel, judges each log by its RESULT line or the UVM report summary, reads coverage, buckets failures by their first error line (numbers masked) and writes an HTML dashboard. Configs: `../p2.4-apb-regblock/regress.json`, `../p3.3-axi4lite/regress.json`.
- **TCL for Yosys:** `../tools/synth_all.tcl` synthesizes 24 designs from this repo and prints one cell/flop table (`cd .. && yosys -c tools/synth_all.tcl`).
- **One-page note:** [rf-beamformer-dv-note.md](rf-beamformer-dv-note.md), how I would verify the digital control of an RF beamformer, using what I know from ATE.

## Cell table (Yosys generic gates)
```
design            cells    flops    logic
stopwatch           132       14      118
counter              10        4        6
alu8                298        0      298
rca4                 20        0       20
cla4                 38        0       38
lfsr8                26        8       18
debounce             23        7       16
det1011_bin          14        2       12
det1011_1hot         31        4       27
traffic             175       12      163
vending              42        4       38
sync_fifo16         369      140      229
async_fifo16        402      166      236
uart_top            965      334      631
spi_slave           340       99      241
i2c_master          307       36      271
apb_regs            775      177      598
axil_regs          1763      592     1171
axi4_mem          27305     8313    18992
rv32i_single       6131     1025     5106
rv32i_pipe         7189     1584     5605
cdc_handshake        77       71        6
rr_arbiter4          42        4       38
skid_buffer          34       18       16
systolic_4x4      13312      873    12439
```

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Step 1: run one flagship bench on EDA Playground with two commercial simulators and write down the differences (mine).
- Thinking drill: explain how a 5,000-test nightly regression gets from red seeds to filed bugs.
