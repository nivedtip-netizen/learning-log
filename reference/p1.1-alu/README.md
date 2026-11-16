# P1.1: combinational toolkit -> 8-bit ALU

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

Muxes three ways (ternary, case, gates), decoder and priority encoder, full adder, ripple-carry
adder (generate loop), 4-bit carry-lookahead adder, comparator, barrel shifter, and an 8-bit ALU
built from them. `latch_demo.v` shows how an incomplete `always @(*)` makes a latch.

## Run
```
make sim     # tb_comb (exhaustive) + tb_alu8 (589,824 vectors)
make synth   # RCA4 vs CLA4 cells, latch check
make lint
```

## Results
- Every combinational block checked exhaustively; ALU checked on all 256 x 256 operands x every op (589,824 vectors). PASS.
- Yosys: RCA4 = 20 cells, CLA4 = 38-40 cells (faster carry costs area). `latch_bad` synthesizes to a `$_DLATCH_P_`; the fixed version has no latch.

## Bugs found while building
- The testbench's own model was wrong: mixing signed and unsigned in a `?:` made the expected SRA result a logical shift. Fixed in the testbench (split into separate statements).

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Draw the CLA carry equations by hand and explain why the cell count goes up.
