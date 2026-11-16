#!/usr/bin/env python3
"""Mini 2 golden-model check for the BCD to 7-segment decoder.

Run:  python3 python/seg7_check.py          -> all checks must pass
      python3 python/seg7_check.py --bug    -> plants a bug in segment e; the check must FAIL

Idea (verification): the SPEC is the truth table from the display shapes. The DESIGN is
the minimized equations from the K-maps. A checker that only ever passes proves nothing,
so we also plant a bug and prove the checker can fail (mutation testing).
"""
import sys

# ---- SPEC: digit -> segments a b c d e f g (1 = on), from the display shapes ----
SPEC = {
    0: "1111110", 1: "0110000", 2: "1101101", 3: "1111001", 4: "0110011",
    5: "1011011", 6: "1011111", 7: "1110000", 8: "1111111", 9: "1111011",
}
SEGS = "abcdefg"

# ---- DESIGN: minimized SOP per segment. A term is a list of literals; "~X" = X' ----
EQ = {
    "a": [["A"], ["C"], ["~B", "~D"], ["B", "D"]],
    "b": [["~B"], ["~C", "~D"], ["C", "D"]],
    "c": [["B"], ["~C"], ["D"]],
    "d": [["A"], ["~B", "C"], ["~B", "~D"], ["B", "~C", "D"], ["C", "~D"]],
    "e": [["C", "~D"], ["~B", "~D"]],
    "f": [["A"], ["B", "~C"], ["B", "~D"], ["~C", "~D"]],
    "g": [["A"], ["B", "~C"], ["~B", "C"], ["C", "~D"]],
}


def bits(n):
    return {"A": (n >> 3) & 1, "B": (n >> 2) & 1, "C": (n >> 1) & 1, "D": n & 1}


def lit(v, name):
    return 1 - v[name[1]] if name.startswith("~") else v[name]


def seg_value(eq, seg, n):
    v = bits(n)
    # + is OR, adjacent letters are AND
    return int(any(all(lit(v, l) for l in term) for term in eq[seg]))


def check(eq):
    """Return a list of mismatches (digit, segment, got, expected) over digits 0..9."""
    bad = []
    for n in range(10):
        for i, s in enumerate(SEGS):
            got, exp = seg_value(eq, s, n), int(SPEC[n][i])
            if got != exp:
                bad.append((n, s, got, exp))
    return bad


def literals(eq):
    return sum(len(t) for terms in eq.values() for t in terms)


def main():
    eq = {s: [list(t) for t in terms] for s, terms in EQ.items()}
    if "--bug" in sys.argv:
        eq["e"][0][1] = "D"          # planted bug: D' became D in segment e
        print("planted bug: e = C D (instead of C D') ...")
    bad = check(eq)
    if bad:
        for n, s, got, exp in bad:
            print(f"FAIL digit {n} segment {s}: got {got}, expected {exp}")
        print(f"RESULT: FAIL ({len(bad)} mismatches)")
        sys.exit(1)
    print(f"PASS: 10 digits x 7 segments match the spec. Total literals: {literals(eq)}")

    # Mutation test: flip each literal once. A good checker must catch every mutant
    # that changes behaviour on digits 0..9.
    caught = total = 0
    for s in SEGS:
        for ti, term in enumerate(EQ[s]):
            for li, l in enumerate(term):
                mut = {k: [list(t) for t in v] for k, v in EQ.items()}
                mut[s][ti][li] = l[1:] if l.startswith("~") else "~" + l
                total += 1
                caught += 1 if check(mut) else 0
    print(f"Mutation test: checker caught {caught} of {total} single-literal bugs")


if __name__ == "__main__":
    main()
