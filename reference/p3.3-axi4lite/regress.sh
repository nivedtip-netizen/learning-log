#!/usr/bin/env bash
# Bash regression for the AXI4-Lite slave: 3 traffic modes x N seeds, plus the
# bug hunt (every seeded bug must FAIL). Usage: ./regress.sh [seeds]
set -u
SEEDS=${1:-10}
mkdir -p logs
iverilog -g2012 -o logs/axil.out rtl/axil_regs.v tb/tb_axil.v || exit 1
pass=0; fail=0
printf "%-14s %-5s %-6s %-9s\n" MODE SEED RESULT COVERAGE
for mode in 0 1 2; do
  name=$( [ $mode = 0 ] && echo random || ([ $mode = 1 ] && echo back_to_back || echo backpressure) )
  for s in $(seq 1 "$SEEDS"); do
    log=logs/${name}_s${s}.log
    vvp -n logs/axil.out +SEED=$s +MODE=$mode +N=400 > "$log" 2>&1
    res=$(grep -o "RESULT: [A-Z]*" "$log" | awk '{print $2}'); res=${res:-CRASH}
    cov=$(grep -o "COVERAGE: [0-9.]*%" "$log" | awk '{print $2}')
    printf "%-14s %-5s %-6s %-9s\n" "$name" "$s" "$res" "$cov"
    if [ "$res" = PASS ]; then pass=$((pass+1)); else fail=$((fail+1)); fi
  done
done
echo "clean design: passed=$pass failed=$fail"

caught=0
for b in BUG_WSTRB BUG_EARLY_B BUG_RRESP BUG_B_DROP BUG_RDATA; do
  iverilog -g2012 -D$b -o logs/$b.out rtl/axil_regs.v tb/tb_axil.v || exit 1
  if vvp -n logs/$b.out +SEED=1 +N=200 | grep -q "RESULT: FAIL"; then echo "$b: caught"; caught=$((caught+1)); else echo "$b: MISSED"; fi
done
echo "bug hunt: $caught/5 seeded bugs caught"
[ "$fail" -eq 0 ] && [ "$caught" -eq 5 ]
