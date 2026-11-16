# Mini 1: number converter and flag checker (Python)

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

Converts numbers between decimal, hex, binary and two's complement, and computes the
8-bit add/sub flags Z, N, C, V the way a CPU does (C on subtract = borrow).

## Run
```
python3 numflags.py                 # self-test: exhaustive check of all 65,536 add and sub pairs
python3 numflags.py 0x7F 1 add      # one calculation with flags
python3 numflags.py -5              # show one number in every format
```

## Results
- Self-test PASS: V is checked against the signed-range definition and C against the unsigned one for every pair.

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Rebuild it from a blank file, then explain out loud why V = carry into MSB XOR carry out of MSB.
