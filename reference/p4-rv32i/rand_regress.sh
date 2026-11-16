#!/usr/bin/env bash
# P4.3 random-instruction regression: for each seed, generate a program, run it on
# both cores, and diff each core's retirement trace against the C reference model.
# Usage: ./rand_regress.sh <first_seed> <num_seeds> <instructions_per_program>
set -u
first=${1:-1}; count=${2:-20}; len=${3:-2000}
mkdir -p rand
gcc -O2 -o ref/rv32i_ref ref/rv32i_ref.c || exit 1
iverilog -g2012 -I rtl -o rand/single.out rtl/rv_*.v rtl/rv32i_single.v tb/mem.v tb/tb_core.v || exit 1
iverilog -g2012 -DPIPE -I rtl -o rand/pipe.out rtl/rv_*.v rtl/rv32i_pipe.v tb/mem.v tb/tb_core.v || exit 1
fails=0; total=0
for s in $(seq "$first" $((first + count - 1))); do
  p=rand/r$s
  python3 sw/gen_random.py "$s" "$len" "$p.S"
  riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Wl,--no-warn-rwx-segments -T sw/link.ld -o "$p.elf" "$p.S" || { echo "seed $s: assemble failed"; fails=$((fails+1)); continue; }
  riscv64-unknown-elf-objcopy -O binary "$p.elf" "$p.bin"; python3 sw/bin2hex.py "$p.bin" "$p.hex"
  ./ref/rv32i_ref "$p.hex" "$p.ref" 200000
  for c in single pipe; do
    vvp -n rand/$c.out +HEX="$p.hex" +TRACE="$p.$c" +MAXCYC=400000 > "$p.$c.log" 2>&1
    if cmp -s "$p.ref" "$p.$c"; then :; else
      fails=$((fails+1))
      echo "seed $s $c: MISMATCH, first difference:"; diff "$p.ref" "$p.$c" | head -4
    fi
  done
  total=$((total + $(wc -l < "$p.ref")))
done
echo "programs=$count retired_per_core=$total mismatches=$fails"
[ "$fails" -eq 0 ]
