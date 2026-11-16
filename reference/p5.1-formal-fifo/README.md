# P5.1: formal verification of the FIFO

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

Properties for the sync FIFO (count range, full/empty flags, never both, no overflow, no
underflow, pointers move by exactly what was accepted, overflow/underflow flags) in
`formal/fifo_props.vh`, included inside the FIFO under `` `ifdef FORMAL `` so they can see the pointers.
`BUG_RARE` is a seeded corner-case bug: a pop is lost only when the FIFO is one short of full,
the write pointer is at its last value, and push and pop happen together.

## Run
```
make prove   # BMC + k-induction with Yosys 'sat -tempinduct', DEPTH 4 and 16
make bug     # the same on BUG_RARE: formal finds the shortest failing trace
make sim     # constrained-random simulation against the same bug
sby -f formal/fifo.sby     # SymbiYosys version (prove / cover / bug tasks), for my laptop
```

## Results
| Run | Result |
|---|---|
| Clean FIFO, DEPTH 4 and 16 | proven for all time by induction (k = 2), well under a second |
| BUG_RARE, formal | counterexample found at DEPTH 4 and 16 (34-step trace at DEPTH 16, about 18 s) |
| BUG_RARE, random sim DEPTH 4 | found in the 3rd run |
| BUG_RARE, random sim DEPTH 16, 1,000 runs x 20 cycles | **missed** (the bug needs at least 31 pushes after reset) |
| BUG_RARE, random sim DEPTH 16, runs of 200 cycles | found in run 31 |

The lesson: random simulation only finds what its run length and constraints can reach; formal searches every input sequence up to the depth and also proves the clean design.

## BMC vs induction
- **BMC** (bounded model check): from reset, try every input sequence up to N steps. Finds bugs, proves nothing beyond N.
- **k-induction**: if the properties hold for k steps in a row from *any* state, they hold in the next one too. If that step passes, the proof covers all time. When it fails on an unreachable state, add a helper assertion (an invariant) that rules that state out.

## Notes
- The first try put the properties in a separate wrapper module and reached the pointers with hierarchical names (`dut.wptr`). Yosys does not resolve those before flattening, so they became free signals and the "proof" failed on nonsense traces. Moving the properties inside the module under `` `ifdef FORMAL `` fixed it.
- Cover properties are in the file but only run with SymbiYosys (`sby` task `cover`); it was not available here.

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Write the properties myself from the FIFO spec, then run both tools on my version.
