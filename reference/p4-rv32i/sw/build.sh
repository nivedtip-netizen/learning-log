#!/usr/bin/env bash
# Assemble a .S (or the generated ISA test) into a $readmemh image.  ./build.sh isa_test
set -e
cd "$(dirname "$0")"
[ "$1" = isa_test ] && python3 gen_isa_test.py
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Wl,--no-warn-rwx-segments -T link.ld -o "$1.elf" "$1.S"
riscv64-unknown-elf-objcopy -O binary "$1.elf" "$1.bin"
python3 bin2hex.py "$1.bin" "$1.hex"
riscv64-unknown-elf-objdump -d "$1.elf" > "$1.dis"
