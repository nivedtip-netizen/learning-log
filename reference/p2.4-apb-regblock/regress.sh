#!/usr/bin/env bash
# Bash regression: every wait-state setting x N seeds. Usage: ./regress.sh [seeds]
set -u
SEEDS=${1:-10}
mkdir -p logs
pass=0; fail=0
printf "%-6s %-6s %-6s %-9s\n" WAIT SEED RESULT COVERAGE
for w in 0 1 2 3; do
  iverilog -g2012 -Ptb_apb.WAIT=$w -o logs/apb_w$w.out rtl/apb_regs.v tb/tb_apb.v || exit 1
  for s in $(seq 1 "$SEEDS"); do
    log=logs/w${w}_s${s}.log
    vvp -n logs/apb_w$w.out +SEED=$s > "$log" 2>&1
    res=$(grep -o "RESULT: [A-Z]*" "$log" | awk '{print $2}'); res=${res:-CRASH}
    cov=$(grep -o "COVERAGE: [0-9.]*%" "$log" | awk '{print $2}')
    printf "%-6s %-6s %-6s %-9s\n" "$w" "$s" "$res" "$cov"
    if [ "$res" = PASS ]; then pass=$((pass+1)); else fail=$((fail+1)); fi
  done
done
echo "passed=$pass failed=$fail"
[ "$fail" -eq 0 ]
