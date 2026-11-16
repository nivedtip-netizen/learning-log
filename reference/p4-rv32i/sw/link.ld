OUTPUT_ARCH(riscv)
ENTRY(_start)
SECTIONS {
  . = 0x0;
  .text : { *(.text.init) *(.text*) }
  . = ALIGN(4);
  .data : { *(.data*) *(.rodata*) *(.sdata*) *(.bss*) *(.sbss*) }
  . = 0xFFF0;
  .tohost : { *(.tohost) }
}
