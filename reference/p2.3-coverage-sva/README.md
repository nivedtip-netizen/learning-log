# P2.3: functional coverage and assertions (SVA)

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

Five assertions bound to the FIFO (`fifo_checker.sv`, one clock and `disable iff` per property),
a covergroup (`fifo_cov.sv`), a "coverage lite" counter version with the same 23 bins that runs
on Verilator, and a Gray-code checker for the async FIFO pointers.

## Run
```
make sim     # clean FIFO: assertions + coverage
make bugs    # each seeded bug should fire an assertion
make gray    # Gray checker on the P1.4 async FIFO
```

## Results
- Clean FIFO: all assertions pass over 20,000 random cycles; coverage lite 100 % (23/23).
- Seeded bugs: `BUG_FLAGS` -> `a_not_full_and_empty`; `BUG_WRFULL` -> `a_count_in_range` (and `a_no_write_when_full`); `BUG_IDLE` -> `a_idle_count_stable`; `BUG_FULL` -> `a_flags_match_count`.
- Gray checker passes on Gray pointers and fires (0001 -> 0010) on binary pointers.
- The covergroup file itself was not run (Verilator has no covergroups).

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Write each property in English first, then in SVA, then compare with mine.
