# Mini 3: 4-bit adder/subtractor + comparator (gate level)

Fundamentals mini-project from the DV & RTL Mastery Map (F0, module M0.3 Combinational circuits).
Everything here is built from real gates (`and`, `or`, `xor`, `not`, `xnor`, `nor`), not from `+` or `>`,
so every line of Verilog maps to something you could draw on paper.

**Result:** both blocks pass exhaustive tests (512/512 and 256/256 cases).
The adder/subtractor synthesizes to about 23 gates and the comparator to about 18 (exact numbers vary a little between Yosys versions).

## 1. What it is and where it goes

The heart of every CPU is an ALU, and the heart of an ALU is an adder that can also subtract.
This mini-project is that heart, at 4 bits. In P1.1 you'll grow it to 8 bits with more operations.
Later it becomes the EX stage of your RV32I CPU.

```
addsub4:
   b[i] --XOR-- sub          (sub=1 inverts b)
            |
   a[3],bx[3]  a[2],bx[2]  a[1],bx[1]  a[0],bx[0]
       |           |           |           |
   c4<-[FA3]<-c3--[FA2]<-c2--[FA1]<-c1--[FA0]<-- c0 = sub (the "+1")
       |           |           |           |
     y[3]        y[2]        y[1]        y[0]

   carry = c4        overflow = c3 XOR c4

comparator4:  a[3:0], b[3:0] --> gates --> gt, eq, lt   (exactly one is 1)
```

## 2. Concept → file map (learn the concept, then read the file)

| Concept (M0.x topic) | Where it lives | What to look for |
|---|---|---|
| Binary addition, 1+1 = 10 | `rtl/half_adder.v` | sum is XOR, carry is AND |
| Full adder from half adders | `rtl/full_adder.v` | two half adders + one OR |
| Ripple carry | `rtl/addsub4.v` | `c[i]` passes from bit to bit, so bit 3 waits for bit 0 |
| Two's complement subtraction | `rtl/addsub4.v` | a − b = a + ~b + 1: XOR inverts b, carry-in gives the +1 |
| Carry (unsigned) vs overflow (signed) | `rtl/addsub4.v` | carry = c4; overflow = c3 XOR c4 |
| Boolean algebra, XNOR as "equal" | `rtl/comparator4.v` | e[i] = a[i] XNOR b[i] |
| Magnitude comparison, MSB first | `rtl/comparator4.v` | the gt equation scans from bit 3 down |
| Self-checking, exhaustive testing | `tb/*.v` | every input combination vs a golden model |
| Synthesis = counting real gates | `make synth` | the Yosys cell report |

## 3. The four ideas to really own

**a) Subtraction is addition.** In two's complement, −b = ~b + 1. So the same adder subtracts if you
invert b and set carry-in to 1. One `sub` wire does both jobs. That's why CPUs have no separate subtractor.

**b) Carry and overflow are different questions.**
- Carry asks "did the *unsigned* answer fit in 4 bits?" Example: 15 + 1 = 16, which doesn't fit, so carry = 1.
- Overflow asks "did the *signed* answer fit in −8..+7?" Example: 7 + 1 = +8, which doesn't fit, so overflow = 1.
- The same bits give two answers because the meaning (signed or unsigned) is your choice, not the hardware's.
- When subtracting, carry = 1 means **no borrow** (a ≥ b, unsigned). This trips up many people in interviews.

**c) Why overflow = c3 XOR c4.** Overflow happens only when two numbers of the same sign give a result
of the other sign. That is exactly when the carry into the sign bit differs from the carry out of it.

**d) Ripple carry is slow.** The carry passes through about 2 gate levels per bit. For 4 bits that's
fine; for 32 bits the last bit waits for ~64 gate delays. That's the reason carry-lookahead adders
exist (P1.1 step 4), and the first example of *timing* limiting a design.

## 4. Run it (WSL Ubuntu terminal)

```bash
cd /mnt/c/Users/l/learning-log/fundamentals/mini3-addsub
make sim     # runs both exhaustive testbenches, prints PASS/FAIL
make wave    # opens addsub4.vcd in GTKWave
make synth   # Yosys gate count
make clean
```

Expected output:
```
  7 + 1  -> y=1000 c=0 v=1  (signed +8 doesn't fit: overflow)
 -8 - 1  -> y=0111 c=1 v=1  (signed -9 doesn't fit: overflow)
  5 - 3  -> y=0010 c=1 v=0  (c=1: no borrow)
 15 + 1  -> y=0000 c=1 v=0  (unsigned 16 doesn't fit: carry)
PASS: addsub4, all 512 cases correct
PASS: comparator4, all 256 cases correct
```

In GTKWave, add `a`, `b`, `sub`, `y`, `carry`, `overflow` and the internal `dut.c[4:0]`.
Watch how `c` changes when you go from 7+1 to 15+1.

## 5. How the testbench proves it works

A 4-bit adder with a `sub` input has only 16 × 16 × 2 = 512 possible inputs, so the testbench tries **all**
of them. For each one it computes the right answer with ordinary integer maths (the "golden model")
and compares. This is the core idea of design verification: *the design and the checker are
written differently, so the same mistake is unlikely in both.*

To confirm the testbench can actually catch bugs, a deliberate bug was planted during development:
`xor g_ovf` was changed to `and g_ovf`. The testbench reported `FAIL: addsub4, 320 of 512 cases wrong`.
Then it was restored. **Always prove your checker can fail.**

## 6. Your exercises (do these yourself, no solutions here)

1. Predict on paper `y`, carry and overflow for: 6+5, 4−6, −3−5 (as 4-bit patterns). Then check with the sim.
2. In GTKWave, find a case where carry=1 and overflow=0, and one where carry=0 and overflow=1. Explain each in one line.
3. Plant your own bug (for example, swap `c1` and `c2` in `full_adder.v`) and see which cases fail. Write it in `bugs.md`.
4. Add a zero flag `z` (1 when y = 0) and a negative flag `n` using gates only, and extend the testbench to check them.
5. Make an 8-bit version using a `generate` loop instead of copying lines, and run the testbench for all 131,072 cases.
6. Write `assign {carry, y} = sub ? a - b : a + b;` in a new module, synthesize both, and compare gate counts. Which is smaller, and why might the tool beat you?

Interview check (answer out loud):
- "How do you build a subtractor from an adder?"
- "What's the difference between carry and overflow? Give one example of each."
- "Why is a ripple-carry adder slow, and what fixes it?"
