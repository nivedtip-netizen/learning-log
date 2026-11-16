#!/usr/bin/env bash
# Runs the quick, must-pass simulations of every reference project and fails if any
# of them prints FAIL (or no PASS). Used by .github/workflows/ci.yml; also fine on a laptop:
#   bash reference/ci/smoke.sh
# The seeded-bug targets ("make bugs") are left out on purpose: those are meant to FAIL.
set -u
cd "$(dirname "$0")/.."
fails=0
run() {                                   # run <dir> <make args...>
  local d=$1; shift
  local out rc; out=$(make -s -C "$d" "$@" 2>&1); rc=$?
  if [ $rc -ne 0 ] || echo "$out" | grep -qE "RESULT: FAIL|TRACE DIFFERS|%Error|Assertion failed|model found|FAIL=[1-9]" \
     || ! echo "$out" | grep -qE "PASS|SUCCESS"; then
    echo "FAIL  $d make $*"; echo "$out" | tail -8 | sed 's/^/      /'; fails=$((fails + 1))
  else
    echo "pass  $d make $*"
  fi
}
python3 mini1-number-flags/numflags.py | grep -q PASS && echo "pass  mini1 selftest" || { echo "FAIL  mini1"; fails=$((fails + 1)); }
run mini4-stopwatch sim
run p0.1-counter sim
run p1.1-alu sim
run p1.2-sequential sim
run p1.3-fsm sim
run p1.4-fifo sync
run p1.4-fifo async
run p1.5-uart sim
run p1.6-spi-i2c sim
run p2.4-apb-regblock sim
run p3.3-axi4lite sim
run p4-rv32i isa
run p4-rv32i hazards
run p5.1-formal-fifo prove
run p5.2-cdc-sta cdc
run p5.5-interview-rtl sim
run p5.7-systolic-int8 sim
[ "${WITH_VERILATOR:-0}" = 1 ] && { run p2.3-coverage-sva sim; run p2.4-apb-regblock sva; run p3.3-axi4lite sva; }
[ "${WITH_COCOTB:-0}" = 1 ] && run p5.3-cocotb-uart
echo "smoke: $fails failing target(s)"
[ "$fails" -eq 0 ]
