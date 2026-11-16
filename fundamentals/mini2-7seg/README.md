# Mini 2: BCD to 7-segment decoder (K-maps, NAND-only, Python check, Verilog)

Fundamentals mini-project from the DV & RTL Mastery Map (F0, M0.2 Boolean algebra, K-maps, don't-cares).
NIVED did the truth table, the K-maps, segment e (AND/OR and NAND circuits) and segment c in CircuitVerse; the other
segments follow the same recipe and are listed in section 8. The Python and Verilog parts were completed with Claude's help. Re-do them on a blank page
when revising: that is the point.

**Result:** 10 digits x 7 segments pass in Python and in Verilog (3 implementations), 42 literals in total,
the checker catches 42 of 42 single-literal bugs, and the planted bug makes both checkers fail as they should.

## 1. What the block is and why it exists

```
 A B C D  --->  [ decoder: 7 Boolean functions ]  --->  a b c d e f g  --->  7 LEDs
 BCD 0..9         combinational: no clock, no memory      1 = LED on
```
- A display cannot read a number. Something must turn a 4-bit code into 7 on/off lines. That translator is a **decoder**.
- Each output is its own Boolean function of A, B, C, D, so we solve the seven segments one at a time.
- Same pattern in real chips: CPU instruction decoders (opcode to control lines), SoC address decoders (address to chip select), display drivers.
- Mini 4 (stopwatch) reuses this block, so a bug here shows up on screen there.

## 2. The method (the same 7 steps for every segment)

| Step | What | Why |
|---|---|---|
| 1 Spec | which segments each digit lights | a picture is not usable by a chip |
| 2 Truth table, Σm list | exact 0/1 per digit; 10..15 marked X | removes all argument about "correct" |
| 3 K-map | group neighbouring 1s, use X where it helps | the smallest logic that gives the same table |
| 4 Equation | one product term per group | the recipe for the gates |
| 5 Circuit | NOT for primes, AND per term, OR for the + | logic becomes gates |
| 6 NAND-only | double inversion + De Morgan | NAND is the cheapest CMOS gate |
| 7 Check | compare against the truth table, plant a bug | "does it really work, and can my check fail?" |

### The minimized equations (with don't-cares 10..15)

| Seg | Equation | Literals | Without don't-cares |
|---|---|---|---|
| a | A + C + B'D' + BD | 6 | 11 |
| b | B' + C'D' + CD | 5 | |
| c | B + C' + D | 3 | |
| d | A + B'C + B'D' + BC'D + CD' | 10 | |
| e | CD' + B'D' | 4 | 6 |
| f | A + BC' + BD' + C'D' | 7 | |
| g | A + BC' + B'C + CD' | 7 | |

Total 42 literals. Don't-cares let groups grow: a drops from 11 to 6 literals and e from 6 to 4.
Remember: **+ is OR, so 1 + 1 = 1** (it is not arithmetic addition).

### Segment e, the full story
- Σm(0, 2, 6, 8), d(10..15). Groups: the four corners m0, m2, m8, m10 give B'D'. The column CD = 10 gives CD'.
- e = CD' + B'D'. Check: digit 6 (0110) gives CD' = 1 so e = 1. Digit 5 (0101) has D = 1 so both terms are 0.
- NAND-only: e = ((CD')' . (B'D')')'. A NOT is a NAND with its inputs tied. 5 NANDs in all (2 to invert D and B, 2 first-level, 1 output).
- Interview note: if D' and B' are available as inputs (flip-flops give Q and Q'), it is 3 NANDs. State the assumption.
- De Morgan trap: NAND(C', D) = C + D', an OR. It is not the AND we need.

## 3. Files

| File | What it is |
|---|---|
| `rtl/seg7_sop.v` | the 7 minimized equations as gates. `-DPLANT_BUG` changes one literal in e |
| `rtl/seg7_case.v` | the same decoder as a case statement (lookup table), digits 10..15 = x |
| `rtl/seg7_nand_e.v` | segment e using NAND gates only |
| `tb/tb_seg7.v` | exhaustive self-checking testbench, 3 implementations vs the spec table |
| `python/seg7_check.py` | golden model, spec vs equations, plus mutation test of every literal |
| `Makefile` | `make sim`, `make bug`, `make py`, `make synth` |

Run: `make sim` (must print PASS), `make bug` (must print FAIL), `make py`, `make synth`.

## 4. Verification story (say this in an interview)
- Only 16 inputs, so we test exhaustively. Don't-care inputs (10..15) are not checked.
- The spec (truth table from the display shapes) is separate from the design (the equations). The checker compares them.
- A checker that never fails proves nothing. We plant a bug (D' becomes D in e) and show it fails digits 3, 6 and 7.
- Mutation test: flip each of the 42 literals one at a time; the checker catches all 42.
- Debug method: find the first wrong value, then ask which term produced it. For the planted bug, digit 3 shows e on when it should be off, so look at the terms that are 1 for digit 3: C·D = 1.

## 5. Design choices and PPA
- **Hand-minimized SOP vs case statement.** Yosys gives about 20 cells for both (the SOP is not magically better). When the x values are written in the case statement, the tool uses the don't-cares itself. In practice, write the case table (readable, easy to change), let synthesis minimize, and keep the K-map skill for understanding and for checking the tool.
- **Two-level (SOP) vs multi-level.** Two-level is fast (2 gate delays) but needs many wide gates. Multi-level shares terms (the common D' here) to save area at the cost of depth. Synthesis picks based on the timing constraint.
- **Active-high vs active-low outputs.** A common-cathode display needs 1 to light a segment. A common-anode display needs 0. Same decoder, with the outputs inverted. Check the datasheet.
- **Area:** about 20 two-input-equivalent gates for seven outputs. **Power:** negligible, since it is combinational and only switches when the digit changes. **Timing:** at most a few gate delays, so it is never the critical path.
- **Glitches:** when the input changes, outputs may flicker for a moment (hazards). Harmless for a display, but you would not drive a clock or a reset from a decoder like this.
- **Risk:** the wrong values on 10..15 only matter if the source can ever send them. In a real design, say so in the spec or force a blank display for 10..15.

## 6. Interview questions with model answers

1. **Why do don't-cares reduce logic?** The K-map lets you treat X cells as 1 when it enlarges a group. A bigger group has fewer literals. For segment a, 11 literals became 6. The risk: the output on those inputs is undefined, so the spec must say they never occur.
2. **Design a BCD to 7-segment decoder.** Truth table, one K-map per segment with X for 10..15, minimize, share common terms, build with gates (or write a case statement and let synthesis do it). Then verify exhaustively against the table.
3. **Implement it with NAND only.** SOP, double inversion, De Morgan: each product term becomes a NAND and the OR becomes a NAND of the NANDs. Inverted inputs come from NAND with tied inputs.
4. **Why is it combinational?** The output depends only on the current input, with no state. If it had to remember the last digit, put a register in front of it. The decoder stays combinational.
5. **How would you verify it?** Exhaustive: 16 inputs. Check against a reference table independent of the design. Prove the checker can fail with a planted bug or a mutation test.
6. **What does + mean in an SOP, and what is 1 + 1?** OR, so 1. Not arithmetic.
7. **Why is NAND preferred in CMOS?** A 2-input NAND is 4 transistors and a single stage. An AND is a NAND followed by an inverter, so 6 transistors and two stages, slower.
8. **Hand SOP vs case statement: which would you write at work?** The case statement. It is readable and maintainable, synthesis does the minimization and uses the x values. Hand minimization is for understanding and for checking tool output.

## 7. Revise tomorrow (cold, no notes)
1. Write the truth table column for e from memory, then its K-map groups and the equation.
2. Convert e to NAND-NAND on paper.
3. Explain in 30 seconds what the block does and why it is combinational.
4. Name the two ways the planted bug is caught (testbench, Python) and what the mutation test proves.
5. State the 8 interview answers above in your own words.

## 8. Still to do by you (the project is yours)
- Finish building a, d, f, g in CircuitVerse (b and c are the pattern).
- Rewrite `seg7_sop.v` from your own notes without looking, then diff it against this one.
- AI-review step: ask an AI for its own decoder, then find its bugs with `tb_seg7.v`.
- Add a 10..15 blank-display version and decide what the testbench should check for it.
