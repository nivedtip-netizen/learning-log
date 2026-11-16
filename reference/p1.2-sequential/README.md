# P1.2: sequential blocks and clock dividers

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

Flops (sync/async reset, enable), up/down and mod-N counters, ring and Johnson counters, an
8-bit LFSR (taps 8,6,5,4), shift registers (SIPO, PISO, universal), edge detector, debouncer,
clock dividers (/2, /4, /3 with 50 % duty), and a blocking-vs-non-blocking race demo.

## Run
```
make sim     # 3,000 random cycles, 18 blocks against reference models
make lint    # race_demo.v is left out on purpose (it is meant to be wrong)
make synth
```

## Results
- PASS. LFSR period 255 with all states distinct; /2 = 20 ns, /4 = 40 ns, /3 = 30 ns with 15 ns high (50 %).
- Race demo: blocking assignments give a = b = 2, non-blocking ones swap the values.

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Rebuild the /3 divider from a blank page and explain why it needs the negedge flop.
