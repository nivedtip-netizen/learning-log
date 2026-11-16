#!/usr/bin/env python3
"""NumPy golden model for the INT8 systolic array (P5.7).

  python3 model/golden.py vectors N OUT.txt [--seed S] [--count C]
      writes test vectors + expected results for the testbench
  python3 model/golden.py trace N [--k K]
      cycle-by-cycle printout of a small array (what every PE holds each cycle),
      using the same timing as the RTL: input register, skew, PE registers

Vector file format (text, read with $fscanf):
  T                              number of tests
  per test:  K                   inner dimension
             K lines "a_col b_row"   hex, element 0 in the low byte
             N lines "c_row"         hex, C[r][0] in the low 32 bits
"""
import argparse
import numpy as np


def matmul(a, b):
    return (a.astype(np.int64) @ b.astype(np.int64)).astype(np.int64)


def pack(vals, bits):
    v = 0
    for i, x in enumerate(vals):
        v |= (int(x) & ((1 << bits) - 1)) << (bits * i)
    return f"{v:0{(bits * len(vals) + 3) // 4}x}"


def make_tests(n, rnd, count):
    lo, hi = -128, 127
    # directed: extremes, identity, K = 1, long K, big accumulation
    tests = [(np.full((n, n), lo), np.full((n, n), lo)),          # -128 * -128: largest product
             (np.full((n, n), lo), np.full((n, n), hi)),          # most negative product
             (np.full((n, n), hi), np.full((n, n), hi)),
             (np.eye(n, dtype=int) * 1, rnd.integers(lo, hi + 1, (n, n))),   # identity
             (rnd.integers(lo, hi + 1, (n, 1)), rnd.integers(lo, hi + 1, (1, n))),  # K = 1 (outer product)
             (rnd.integers(lo, hi + 1, (n, 4 * n)), rnd.integers(lo, hi + 1, (4 * n, n))),  # long K
             (np.full((n, 64), lo), np.full((64, n), lo))]        # 64 x 16384 = 2^20: accumulator grows
    while len(tests) < count:
        k = int(rnd.integers(1, 3 * n + 1))
        tests.append((rnd.integers(lo, hi + 1, (n, k)), rnd.integers(lo, hi + 1, (k, n))))
    return tests


def write_vectors(n, path, seed, count):
    rnd = np.random.default_rng(seed)
    tests = make_tests(n, rnd, count)
    with open(path, "w") as f:
        f.write(f"{len(tests)}\n")
        for a, b in tests:
            k = a.shape[1]
            c = matmul(a, b)
            assert np.all(np.abs(c) < 2 ** 31)
            f.write(f"{k}\n")
            for kk in range(k):
                f.write(f"{pack(a[:, kk], 8)} {pack(b[kk, :], 8)}\n")
            for r in range(n):
                f.write(f"{pack(c[r, :], 32)}\n")
    print(f"wrote {len(tests)} tests for N={n} to {path}")


def trace(n, k, seed=1):
    """Cycle-accurate model of systolic_top's datapath (PIPE_MUL=0), printing every PE."""
    rnd = np.random.default_rng(seed)
    a = rnd.integers(-4, 5, (n, k))
    b = rnd.integers(-4, 5, (k, n))
    print("A =\n", a, "\nB =\n", b, "\nNumPy C = A @ B =\n", matmul(a, b), "\n")
    a_q = np.zeros(n, int); b_q = np.zeros(n, int)               # input register
    da = [[0] * i for i in range(n)]; db = [[0] * i for i in range(n)]   # skew registers
    a_out = np.zeros((n, n), int); b_out = np.zeros((n, n), int); acc = np.zeros((n, n), int)
    total = k + 2 * n - 1
    for cyc in range(total + 1):
        # values on the wires before this clock edge
        a_left = [a_q[0]] + [da[i][-1] for i in range(1, n)]
        b_top = [b_q[0]] + [db[i][-1] for i in range(1, n)]
        a_in = np.zeros((n, n), int); b_in = np.zeros((n, n), int)
        for i in range(n):
            for j in range(n):
                a_in[i, j] = a_left[i] if j == 0 else a_out[i, j - 1]
                b_in[i, j] = b_top[j] if i == 0 else b_out[i - 1, j]
        print(f"cycle {cyc:2d}: " + " | ".join(
            f"PE{i}{j} a={a_in[i, j]:+d} b={b_in[i, j]:+d} acc={acc[i, j]:+4d}" for i in range(n) for j in range(n)))
        # clock edge
        acc = acc + a_in * b_in
        a_out, b_out = a_in.copy(), b_in.copy()
        for i in range(1, n):
            da[i] = [a_q[i]] + da[i][:-1]; db[i] = [b_q[i]] + db[i][:-1]
        beat = cyc < k
        a_q = a[:, cyc].copy() if beat else np.zeros(n, int)
        b_q = b[cyc, :].copy() if beat else np.zeros(n, int)
    print("\narray C =\n", acc, "\nmatches NumPy:", bool(np.all(acc == matmul(a, b))))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["vectors", "trace"])
    ap.add_argument("n", type=int)
    ap.add_argument("out", nargs="?")
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--count", type=int, default=60)
    ap.add_argument("--k", type=int, default=2)
    args = ap.parse_args()
    if args.mode == "vectors":
        write_vectors(args.n, args.out, args.seed, args.count)
    else:
        trace(args.n, args.k, args.seed)
