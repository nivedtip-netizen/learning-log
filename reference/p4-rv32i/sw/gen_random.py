#!/usr/bin/env python3
"""Constrained-random RV32I program generator (P4.3).

  python3 gen_random.py SEED N_INSTR out.S

Constraints, the same ideas a UVM sequence item would carry:
  * instruction mix: ALU reg/imm 55 %, loads/stores 20 %, branches 15 %, LUI/AUIPC/JAL 10 %
  * registers biased to x1-x4 (70 %) so back-to-back dependencies (hazards) are common
  * writes to x0 now and then
  * loads/stores stay inside a 256-byte data window (x31 = base, never written) and are aligned
  * forward branches skip 1-3 instructions; backward branches are bounded loops
    with their own counter register (x30, never used elsewhere)
  * the program ends with ECALL
"""
import random
import sys

seed, n, out = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
rnd = random.Random(seed)

def reg(dst=False):
    if dst and rnd.random() < 0.05:
        return "x0"
    if rnd.random() < 0.7:
        return f"x{rnd.randint(1, 4)}"
    return f"x{rnd.randint(1, 29)}"           # x30 = loop counter, x31 = data base

def imm12():
    return rnd.choice([0, 1, -1, 2047, -2048, rnd.randint(-2048, 2047)])

R = ["add", "sub", "sll", "slt", "sltu", "xor", "srl", "sra", "or", "and"]
I = ["addi", "slti", "sltiu", "xori", "ori", "andi"]
SH = ["slli", "srli", "srai"]
BR = ["beq", "bne", "blt", "bge", "bltu", "bgeu"]
LD = [("lw", 4), ("lh", 2), ("lhu", 2), ("lb", 1), ("lbu", 1)]
ST = [("sw", 4), ("sh", 2), ("sb", 1)]

lines = ["  .section .text.init", "  .globl _start", "_start:", "  la x31, data"]
for r in range(1, 31):              # every register gets a value: the core's register file has no reset (X otherwise)
    lines.append(f"  li x{r}, {rnd.getrandbits(32):#x}")
label = 0
i = 0
while i < n:
    p = rnd.random()
    if p < 0.35:
        lines.append(f"  {rnd.choice(R)} {reg(True)}, {reg()}, {reg()}")
    elif p < 0.50:
        lines.append(f"  {rnd.choice(I)} {reg(True)}, {reg()}, {imm12()}")
    elif p < 0.55:
        lines.append(f"  {rnd.choice(SH)} {reg(True)}, {reg()}, {rnd.randint(0, 31)}")
    elif p < 0.65:
        op, sz = rnd.choice(LD)
        lines.append(f"  {op} {reg(True)}, {rnd.randrange(0, 256, sz)}(x31)")
    elif p < 0.75:
        op, sz = rnd.choice(ST)
        lines.append(f"  {op} {reg()}, {rnd.randrange(0, 256, sz)}(x31)")
    elif p < 0.85:
        skip = rnd.randint(1, 3)
        label += 1
        lines.append(f"  {rnd.choice(BR)} {reg()}, {reg()}, F{label}")
        for _ in range(skip):
            lines.append(f"  addi {reg(True)}, {reg()}, {imm12()}")
        lines.append(f"F{label}:")
        i += skip
    elif p < 0.90:
        label += 1                                   # bounded backward loop
        lines += [f"  li x30, {rnd.randint(1, 4)}", f"B{label}:",
                  f"  {rnd.choice(R)} {reg(True)}, {reg()}, {reg()}",
                  f"  addi x30, x30, -1", f"  bnez x30, B{label}"]
        i += 3
    elif p < 0.94:
        lines.append(f"  lui {reg(True)}, {rnd.getrandbits(20):#x}")
    elif p < 0.97:
        lines.append(f"  auipc {reg(True)}, {rnd.getrandbits(20):#x}")
    elif p < 0.975:
        label += 1
        rd = rnd.choice(["x1", "x0", reg(True)])
        lines += [f"  jal {rd}, J{label}", f"  addi {reg(True)}, {reg()}, 1", f"J{label}:"]
    elif p < 0.983:                                  # JALR through a just-computed address (RAW -> jalr)
        label += 1
        r = f"x{rnd.randint(5, 9)}"
        lines += [f"  la {r}, J{label}", f"  jalr {rnd.choice(['x0', 'x1'])}, 0({r})", f"  addi {reg(True)}, {reg()}, 1", f"J{label}:"]
        i += 2
    elif p < 0.991:                                  # load/store through a freshly computed base (RAW -> load/store)
        r = f"x{rnd.randint(1, 4)}"
        op, sz = rnd.choice(LD + ST)
        off = rnd.randrange(0, 128, 4)
        lines += [f"  addi {r}, x31, {off}"] + rnd.choice([[], ["  nop"], ["  nop", "  nop"]]) + \
                 [f"  {op} {reg(True) if op[0] == 'l' else reg()}, {rnd.randrange(0, 64, sz)}({r})"]
        i += 1
    elif p < 0.995:
        lines.append(f"  sw {rnd.choice(['x30', 'x31'])}, {rnd.randrange(0, 256, 4)}(x31)")
    else:
        lines.append("  fence")
    i += 1
lines += ["  ecall", "  .data", "  .align 4", "data:"]
lines += [f"  .word {rnd.getrandbits(32):#x}" for _ in range(64)]
open(out, "w").write("\n".join(lines) + "\n")
