#!/usr/bin/env python3
"""Mini 1: number converter and 8-bit flag checker.

Doubles as the golden model for the P1.1 ALU flags (Z, N, C, V).
Run:  python3 numflags.py            (self-test)
      python3 numflags.py 0x7F 0x01 add
"""
import sys

W = 8
MASK = (1 << W) - 1


def to_bin(x, w=W):
    return format(x & ((1 << w) - 1), f"0{w}b")


def to_hex(x, w=W):
    return format(x & ((1 << w) - 1), f"0{(w + 3) // 4}X")


def as_signed(x, w=W):
    """Two's complement view of a w-bit pattern."""
    x &= (1 << w) - 1
    return x - (1 << w) if x >> (w - 1) else x


def parse(s):
    s = s.strip().lower()
    if s.startswith("0b"):
        return int(s[2:], 2)
    if s.startswith("0x"):
        return int(s[2:], 16)
    return int(s, 10)


def add_sub(a, b, sub=False):
    """8-bit add or subtract. Returns (result, Z, N, C, V).

    C on SUB follows the RISC-V/ARM-free 'borrow-out' convention used in
    the P1.1 ALU: C = 1 means a borrow happened (a < b unsigned).
    """
    a &= MASK
    b &= MASK
    if sub:
        full = a - b
        res = full & MASK
        c = 1 if a < b else 0                       # borrow
        v = 1 if ((a ^ b) & (a ^ res)) >> 7 & 1 else 0
    else:
        full = a + b
        res = full & MASK
        c = full >> W & 1                            # carry out of bit 7
        v = 1 if (~(a ^ b) & (a ^ res)) >> 7 & 1 else 0
    z = 1 if res == 0 else 0
    n = res >> 7 & 1
    return res, z, n, c, v


def show(x):
    return f"dec={x & MASK:3d} signed={as_signed(x):4d} bin={to_bin(x)} hex=0x{to_hex(x)}"


def selftest():
    cases = [
        # a, b, sub, (res, Z, N, C, V)
        (0x7F, 0x01, False, (0x80, 0, 1, 0, 1)),   # +127 + 1 overflows
        (0xFF, 0x01, False, (0x00, 1, 0, 1, 0)),   # carry, no overflow
        (0x80, 0x01, True,  (0x7F, 0, 0, 0, 1)),   # -128 - 1 overflows
        (0x00, 0x01, True,  (0xFF, 0, 1, 1, 0)),   # borrow, -1, no overflow
        (0x80, 0x80, False, (0x00, 1, 0, 1, 1)),   # -128 + -128
        (0x05, 0x05, True,  (0x00, 1, 0, 0, 0)),
    ]
    fails = 0
    for a, b, sub, exp in cases:
        got = add_sub(a, b, sub)
        if got != exp:
            fails += 1
            print(f"FAIL {a:#04x} {'-' if sub else '+'} {b:#04x}: got {got} exp {exp}")
    # exhaustive cross-check of V against the signed-range definition
    for a in range(256):
        for b in range(256):
            for sub in (False, True):
                res, z, n, c, v = add_sub(a, b, sub)
                true_val = as_signed(a) - as_signed(b) if sub else as_signed(a) + as_signed(b)
                if v != (0 if -128 <= true_val <= 127 else 1):
                    fails += 1
                ures = a - b if sub else a + b
                if c != (1 if (ures < 0 or ures > 255) else 0):
                    fails += 1
    assert to_bin(0xA5) == "10100101" and as_signed(0xA5) == -91 and parse("0b1010") == 10
    print("PASS" if fails == 0 else f"FAIL errors={fails}")
    return fails


if __name__ == "__main__":
    if len(sys.argv) == 4:
        a, b = parse(sys.argv[1]), parse(sys.argv[2])
        r, z, n, c, v = add_sub(a, b, sys.argv[3] == "sub")
        print("a  :", show(a))
        print("b  :", show(b))
        print("res:", show(r))
        print(f"Z={z} N={n} C={c} V={v}")
    elif len(sys.argv) == 2:
        print(show(parse(sys.argv[1])))
    else:
        sys.exit(1 if selftest() else 0)
