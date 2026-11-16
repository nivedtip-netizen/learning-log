# P1.4: synchronous FIFO -> asynchronous FIFO

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

A first-word-fall-through sync FIFO (pointers one bit wider than the address), and a
Cummings-style async FIFO with Gray-code pointers crossing through 2-flop synchronizers.
`sync2.v` has a simulation-only metastability model (`+define+META`): a value that changes
too close to the clock edge resolves to a random old/new value.

## Run
```
make sync    # 20,000 random cycles vs a queue model
make async   # write/read clock periods 10/27, 27/10 and 10/10 ns, with the metastability model
make bug     # BUG_BIN: binary pointers synchronized instead of Gray
```

## Results
- Sync FIFO PASS (1,083 push+pop while full, 867 while empty, overflow/underflow flags checked).
- Async FIFO PASS at all three clock ratios with metastability on.
- Seeded bug: with binary pointers the data still arrives in order (single-cycle wrong values are hidden by the equality compares), but the check "the read side never thinks there is more data than was written" fires 172 / 663 times at the two unequal ratios. Equal-phase clocks never hit the window: a reminder that a clean run at one ratio proves little.

## Bugs found while building
- The testbench never applied reset (a `reg` that starts at 0 gives no negedge); fixed with an explicit reset after the clocks start.
- Missing `` `timescale `` made `$realtime` count in seconds.
- `expect` is a SystemVerilog keyword (renamed).
- FIFO contract changed in P1.5 (see there): a push while full is dropped even if a pop happens in the same cycle.

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Rebuild the async FIFO from the Cummings paper, then run my version against this testbench.
