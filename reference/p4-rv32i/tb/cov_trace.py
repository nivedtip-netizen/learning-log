#!/usr/bin/env python3
"""Functional coverage from retirement traces (P4.4), for simulators without covergroups.

  python3 tb/cov_trace.py rand/*.pipe sw/... [--holes]

Rebuilds the register file from the trace (every write is in it), so operand
values are known. Bins (same plan as the covergroups in tb/core_cov.sv):
  * every RV32I instruction (37 + FENCE)
  * rd, rs1, rs2 = each of x0..x31 (96 bins)
  * immediates of I-type ALU ops at 0, +2047, -2048 (3)
  * ADD/SUB with signed overflow, and without (4)
  * RAW dependency at distance 1, 2, 3 x consumer class {alu, load, store, branch, jalr} (15)
  * load-use (load followed by a dependent instruction at distance 1) (1)
  * branch taken / not taken x forward / backward (4)
"""
import sys
from collections import Counter, deque

def s32(v): v &= 0xFFFFFFFF; return v - (1 << 32) if v >> 31 else v
def sext(v, b): m = 1 << (b - 1); v &= (1 << b) - 1; return (v ^ m) - m

def decode(i):
    op, f3, f7 = i & 0x7F, (i >> 12) & 7, (i >> 25)
    rd, rs1, rs2 = (i >> 7) & 31, (i >> 15) & 31, (i >> 20) & 31
    imm_i = sext(i >> 20, 12)
    alt = (i >> 30) & 1
    if op == 0x37: return "lui", "alu", rd, None, None, None
    if op == 0x17: return "auipc", "alu", rd, None, None, None
    if op == 0x6F: return "jal", "jump", rd, None, None, None
    if op == 0x67: return "jalr", "jalr", rd, rs1, None, imm_i
    if op == 0x63: return ["beq", "bne", "?", "?", "blt", "bge", "bltu", "bgeu"][f3], "branch", None, rs1, rs2, None
    if op == 0x03: return {0: "lb", 1: "lh", 2: "lw", 4: "lbu", 5: "lhu"}.get(f3, "?"), "load", rd, rs1, None, imm_i
    if op == 0x23: return ["sb", "sh", "sw"][f3] if f3 < 3 else "?", "store", None, rs1, rs2, None
    if op == 0x13:
        n = ["addi", "slli", "slti", "sltiu", "xori", "srai" if alt else "srli", "ori", "andi"][f3]
        return n, "alu", rd, rs1, None, imm_i
    if op == 0x33:
        n = ["sub" if alt else "add", "sll", "slt", "sltu", "xor", "sra" if alt else "srl", "or", "and"][f3]
        return n, "alu", rd, rs1, rs2, None
    if op == 0x0F: return "fence", "alu", None, None, None, None
    return "?", "other", None, None, None, None

ALL = ("lui auipc jal jalr beq bne blt bge bltu bgeu lb lh lw lbu lhu sb sh sw addi slti sltiu xori ori andi "
       "slli srli srai add sub sll slt sltu xor srl sra or and fence").split()

def main(paths, show_holes):
    hit = Counter()
    n = 0
    for p in paths:
        regs = [0] * 32
        hist = deque(maxlen=3)                     # (rd, class) of the last 3 retired instructions
        prev = None
        for line in open(p):
            f = line.split()
            if len(f) < 7: continue
            pc, ins, rd_t, wd = int(f[0], 16), int(f[1], 16), int(f[2]), int(f[3], 16)
            name, cls, rd, rs1, rs2, imm = decode(ins)
            n += 1
            hit["op:" + name] += 1
            if rd is not None: hit[f"rd:x{rd}"] += 1
            if rs1 is not None: hit[f"rs1:x{rs1}"] += 1
            if rs2 is not None: hit[f"rs2:x{rs2}"] += 1
            if cls == "alu" and imm is not None and name not in ("slli", "srli", "srai"):
                if imm == 0: hit["imm:0"] += 1
                if imm == 2047: hit["imm:max"] += 1
                if imm == -2048: hit["imm:min"] += 1
            if name in ("add", "sub"):
                a, b = s32(regs[rs1]), s32(regs[rs2])
                r = a + b if name == "add" else a - b
                hit[f"ovf:{name}:{'yes' if not -2**31 <= r < 2**31 else 'no'}"] += 1
            srcs = {r for r in (rs1, rs2) if r}
            for dist, (prd, pcls) in enumerate(reversed(hist), start=1):
                if prd and prd in srcs and cls in ("alu", "load", "store", "branch", "jalr"):
                    hit[f"raw:d{dist}:{cls}"] += 1
                    if dist == 1 and pcls == "load": hit["load_use"] += 1
            if prev is not None and prev[2] == "branch":
                taken = pc != prev[0] + 4
                back = sext(((prev[1] >> 31) << 12) | (((prev[1] >> 7) & 1) << 11) |
                            (((prev[1] >> 25) & 0x3F) << 5) | (((prev[1] >> 8) & 0xF) << 1), 13) < 0
                hit[f"br:{'taken' if taken else 'not'}:{'back' if back else 'fwd'}"] += 1
            if rd_t and rd is not None: regs[rd_t] = wd
            hist.append((rd if rd else 0, cls))
            prev = (pc, ins, cls)
    bins = (["op:" + o for o in ALL] + [f"{k}:x{r}" for k in ("rd", "rs1", "rs2") for r in range(32)] +
            ["imm:0", "imm:max", "imm:min"] + [f"ovf:{o}:{y}" for o in ("add", "sub") for y in ("yes", "no")] +
            [f"raw:d{d}:{c}" for d in (1, 2, 3) for c in ("alu", "load", "store", "branch", "jalr")] +
            ["load_use"] + [f"br:{t}:{d}" for t in ("taken", "not") for d in ("fwd", "back")])
    covered = [b for b in bins if hit[b]]
    print(f"instructions={n} bins={len(bins)} covered={len(covered)}")
    print(f"COVERAGE: {100.0 * len(covered) / len(bins):.1f}%")
    holes = [b for b in bins if not hit[b]]
    if holes and show_holes:
        print("holes:", " ".join(holes))

if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--holes"]
    main(args, "--holes" in sys.argv)
