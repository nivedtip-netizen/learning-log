#!/usr/bin/env python3
"""Generates isa_test.S: a self-checking test for every RV32I instruction,
in the style of riscv-tests rv32ui (one numbered case per check, case number in x28; on a mismatch
the test number is written to TOHOST as (n << 1) | 1, on success 1 is written).
Expected values come from the small Python semantics below."""
M = 0xFFFFFFFF
def s32(x): x &= M; return x - (1 << 32) if x >> 31 else x
OPS = {
    "add": lambda a, b: a + b, "sub": lambda a, b: a - b,
    "sll": lambda a, b: a << (b & 31), "srl": lambda a, b: (a & M) >> (b & 31),
    "sra": lambda a, b: s32(a) >> (b & 31),
    "slt": lambda a, b: int(s32(a) < s32(b)), "sltu": lambda a, b: int((a & M) < (b & M)),
    "xor": lambda a, b: a ^ b, "or": lambda a, b: a | b, "and": lambda a, b: a & b,
}
IMM = {"addi": "add", "slti": "slt", "sltiu": "sltu", "xori": "xor", "ori": "or", "andi": "and",
       "slli": "sll", "srli": "srl", "srai": "sra"}
VALS = [0, 1, 2, 0x7FFFFFFF, 0x80000000, 0xFFFFFFFF, 0x12345678, 0xFEDCBA98, 31, 32, 0x0000FFFF]
IMMS = [0, 1, -1, 2047, -2048, 0x7F0, 31, 5]

out = []; n = 0
def case(lines, rd, exp):
    global n
    n += 1
    out.append(f"  # case {n}")
    out.append(f"  li x28, {n}")
    out.extend(f"  {l}" for l in lines)
    out.append(f"  li x29, {exp & M:#x}")
    out.append(f"  bne {rd}, x29, fail")

for op, f in OPS.items():
    for a in VALS[:8]:
        for b in [0, 1, 31, 0x80000000, 0xFFFFFFFF, 7]:
            case([f"li x1, {a:#x}", f"li x2, {b:#x}", f"{op} x3, x1, x2"], "x3", f(a, b))
    # rd == rs1 == rs2 and x0 as destination
    case([f"li x5, 0x55", f"{op} x5, x5, x5"], "x5", f(0x55, 0x55))
    case([f"li x1, 9", f"li x2, 3", f"{op} x0, x1, x2"], "x0", 0)
for op, base in IMM.items():
    f = OPS[base]
    imms = [i for i in IMMS if 0 <= i < 32] if op in ("slli", "srli", "srai") else IMMS
    for a in VALS[:8]:
        for i in imms:
            case([f"li x1, {a:#x}", f"{op} x3, x1, {i}"], "x3", f(a, i & M))
# LUI / AUIPC
for u in [0, 1, 0x80000, 0xFFFFF, 0x12345]:
    case([f"lui x3, {u:#x}"], "x3", u << 12)
case(["auipc x3, 0", "auipc x4, 0", "sub x3, x4, x3"], "x3", 4)
case(["auipc x3, 1", "auipc x4, 0", "sub x3, x3, x4"], "x3", 0x1000 - 4)
# loads and stores
out.append("  la x10, tdata")
for off, val in [(0, 0x00FF00FF), (4, 0xFF00FF00), (8, 0x0FF00FF0), (12, 0xF00FF00F)]:
    case([f"lw x3, {off}(x10)"], "x3", val)
for i, b in enumerate([0xFF, 0x00, 0xFF, 0x00]):
    case([f"lb x3, {i}(x10)"], "x3", (b - 256) if b & 0x80 else b)
    case([f"lbu x3, {i}(x10)"], "x3", b)
case(["lh x3, 0(x10)"], "x3", 0x00FF)
case(["lh x3, 2(x10)"], "x3", 0x00FF)
case(["lh x3, 4(x10)"], "x3", s32(0xFFFFFF00) & M)
case(["lhu x3, 6(x10)"], "x3", 0xFF00)
case(["lh x3, 6(x10)"], "x3", 0xFFFFFF00)
out.append("  la x11, sbuf")
case(["li x1, 0xAABBCCDD", "sw x1, 0(x11)", "lw x3, 0(x11)"], "x3", 0xAABBCCDD)
case(["li x1, 0x11", "sb x1, 1(x11)", "lw x3, 0(x11)"], "x3", 0xAABB11DD)
case(["li x1, 0x2233", "sh x1, 2(x11)", "lw x3, 0(x11)"], "x3", 0x223311DD)
case(["li x1, -1", "sw x1, -4(x11)", "lw x3, -4(x11)"], "x3", 0xFFFFFFFF)
case(["li x1, 0x80", "sb x1, 0(x11)", "lb x3, 0(x11)"], "x3", 0xFFFFFF80)
# branches: taken and not taken, signed and unsigned corners
BR = {"beq": lambda a, b: a == b, "bne": lambda a, b: a != b, "blt": lambda a, b: s32(a) < s32(b),
      "bge": lambda a, b: s32(a) >= s32(b), "bltu": lambda a, b: a < b, "bgeu": lambda a, b: a >= b}
for op, f in BR.items():
    for a, b in [(0, 0), (1, 0), (0, 1), (0x80000000, 1), (1, 0x80000000), (0xFFFFFFFF, 0), (0, 0xFFFFFFFF), (5, 5)]:
        lbl = f"L{n + 1}"
        case([f"li x1, {a:#x}", f"li x2, {b:#x}", "li x3, 0", f"{op} x1, x2, {lbl}t", "li x3, 2", f"j {lbl}e",
              f"{lbl}t: li x3, 1", f"{lbl}e: nop"], "x3", 1 if f(a, b) else 2)
# backward branch loop: sum 1..10
case(["li x1, 10", "li x3, 0", "Lloop: add x3, x3, x1", "addi x1, x1, -1", "bnez x1, Lloop"], "x3", 55)
# jal / jalr
case(["jal x1, Lj1", "Lj0: j Lj2", "Lj1: auipc x3, 0", "addi x3, x3, -4", "sub x3, x1, x3", "Lj2: nop"], "x3", 0)
case(["la x5, Lj3", "jalr x1, 0(x5)", "li x3, 99", "Lj3: li x3, 7"], "x3", 7)
case(["la x5, Lj4", "addi x5, x5, 1", "jalr x0, -1(x5)", "li x3, 99", "Lj4: li x3, 8"], "x3", 8)   # jalr clears bit 0
# x0 stays zero
case(["li x1, 5", "addi x0, x1, 5", "add x3, x0, x0"], "x3", 0)

asm = ["  .section .text.init", "  .globl _start", "_start:"] + out + [
    "pass:", "  li x30, 1", "  la x31, tohost", "  sw x30, 0(x31)", "1: j 1b",
    "fail:", "  slli x30, x28, 1", "  ori x30, x30, 1", "  la x31, tohost", "  sw x30, 0(x31)", "2: j 2b",
    "  .data", "  .align 4",
    "tdata: .word 0x00FF00FF, 0xFF00FF00, 0x0FF00FF0, 0xF00FF00F",
    "  .word 0", "sbuf: .word 0, 0",
    "  .section .tohost, \"aw\"", "  .globl tohost", "tohost: .word 0"]
open("isa_test.S", "w").write("\n".join(asm) + "\n")
print(f"isa_test.S: {n} checks")
