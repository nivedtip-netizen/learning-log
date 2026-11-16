# Hazard tests for the 5-stage pipeline. Each case checks the result (so a
# missing forward or stall fails the test); stall and flush counts are printed
# by the testbench. Case number in x28, result checked against x29.
  .section .text.init
  .globl _start
_start:
  # case 1: RAW at distance 1 (EX/MEM -> EX forward)
  li x28, 1
  li x1, 5
  addi x2, x1, 3          # needs x1 from the previous instruction
  li x29, 8
  bne x2, x29, fail
  # case 2: RAW at distance 2 (MEM/WB -> EX forward)
  li x28, 2
  li x1, 7
  nop
  addi x2, x1, 3
  li x29, 10
  bne x2, x29, fail
  # case 3: RAW at distance 3 (register-file write-through)
  li x28, 3
  li x1, 9
  nop
  nop
  addi x2, x1, 3
  li x29, 12
  bne x2, x29, fail
  # case 4: both operands forwarded from different stages
  li x28, 4
  li x1, 100
  li x2, 23
  sub x3, x1, x2          # x1 from MEM/WB, x2 from EX/MEM
  li x29, 77
  bne x3, x29, fail
  # case 5: a chain, every instruction uses the one before
  li x28, 5
  li x1, 1
  add x1, x1, x1
  add x1, x1, x1
  add x1, x1, x1
  add x1, x1, x1
  li x29, 16
  bne x1, x29, fail
  # case 6: load-use (1 stall), then a load followed by an independent instruction (no stall)
  li x28, 6
  la x10, data
  lw x1, 0(x10)
  addi x2, x1, 1          # load-use: one bubble
  lw x3, 4(x10)
  addi x4, x0, 2          # independent: no stall
  add x5, x3, x4          # x3 two instructions after the load: forward, no stall
  li x29, 0x1235
  bne x2, x29, fail
  li x29, 0x2002
  bne x5, x29, fail
  # case 7: load then store of the loaded value (store data is a source too)
  li x28, 7
  lw x1, 0(x10)
  sw x1, 8(x10)
  lw x2, 8(x10)
  li x29, 0x1234
  bne x2, x29, fail
  # case 8: branch right after the compare that feeds it (forward into the branch unit)
  li x28, 8
  li x1, 3
  li x2, 3
  slt x3, x1, x2          # 0
  beqz x3, 1f             # taken: the two younger instructions are flushed
  li x28, 99              # must not execute
  j fail
1:
  # case 9: jal/jalr return address forwarded immediately
  li x28, 9
  jal x1, 2f
  j 3f
2:
  addi x5, x1, 0          # x1 from JAL at distance 1
  jalr x0, 0(x1)
3:
  la x6, 2b
  addi x6, x6, -4         # address of 'j 3f' = return address
  bne x5, x6, fail
  # case 10: x0 is never forwarded
  li x28, 10
  addi x0, x0, 5
  addi x2, x0, 1
  li x29, 1
  bne x2, x29, fail
pass:
  li x30, 1
  la x31, tohost
  sw x30, 0(x31)
4: j 4b
fail:
  slli x30, x28, 1
  ori x30, x30, 1
  la x31, tohost
  sw x30, 0(x31)
5: j 5b
  .data
  .align 4
data: .word 0x1234, 0x2000, 0
  .section .tohost, "aw"
  .globl tohost
tohost: .word 0
