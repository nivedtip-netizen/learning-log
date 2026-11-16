# P5.5: eight classic interview RTL questions

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

Round-robin arbiter, glitch-free clock mux, skid buffer, Gray counter, pattern detector,
FIFO, edge detector and divide-by-N with 50 % duty, all in one self-checking testbench.

## Run
```
make sim       # 3 seeds
make bad_mux   # the naive 'sel ? clk1 : clk0' mux: expected FAIL
make synth
make lint
```

## Results
- All eight PASS on 3 seeds: arbiter matches a round-robin model and no requester waits more than N-1 cycles; the clock mux's shortest output phase is 5.0 ns (no glitch) over about 270 switches; skid buffer keeps order with random stalls and holds its output while stalled; Gray counter changes exactly one bit per count; pattern detector matches a shift-register model; FIFO matches a queue; edge detector matches; dividers /2../7 have period N x T and 50 % duty.
- The naive mux fails with 63 glitches.
- Cells: arbiter 42, clock mux 11, skid buffer 34, Gray counter 17, pattern detector 19, FIFO 173, edge detector 4, divider 19.

## Bugs found while building
- `$countones` gave wrong results in Icarus 12 inside this expression; replaced with a small function.
- The testbench scoreboards overflowed their arrays after 4,096 words; indexes now wrap.

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Write each one on paper first (that is the actual drill), then simulate my version.
- Daily mocks, the recorded walkthrough and mock interviews are mine.
