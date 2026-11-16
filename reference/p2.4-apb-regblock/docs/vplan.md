# Verification plan: APB register block

Written before the testbench. Each row ends in a check that runs, or a bin that must be hit.

| # | Feature (spec) | Stimulus | Check | Proof (test / bin) |
|---|---|---|---|---|
| 1 | Reset values of all 8 registers | read every address right after reset | read data == table value | `tb_apb` reset loop; cov bins reg x read |
| 2 | CTRL, INT_ENABLE, SCRATCH are RW with byte strobes | random writes with PSTRB 0001 / 0011 / 1111 / random, then reads | model merges per byte lane | cov bins strobe x 4; `BUG_STRB` caught |
| 3 | STATUS is RO from `hw_status` | change `hw_status`, write STATUS, read | read == `hw_status`, write has no effect | cov bin STATUS x write |
| 4 | INT_STATUS is W1C, set by `hw_event`, set wins | random single-bit events; writes of random masks | model `(st & ~clr) \| event`; cov bin "cleared a set bit" | `BUG_W1C` caught |
| 5 | `irq = \|(INT_STATUS & INT_ENABLE)` | events with random enables | irq checked after every transfer | cov bin irq 0->1 |
| 6 | CMD is WO: one `cmd_valid` pulse per write, reads 0 | random writes/reads to 0x10 | pulse count == write count; reads 0 | end-of-test count check |
| 7 | VERSION RO constant | reads and writes | always 0x0001_0200 | cov bin VERSION x write |
| 8 | CONFIG has only bits [7:0] | writes with all strobes | bits [31:8] read 0 | reads in the random test |
| 9 | PSLVERR for addr > 0x1C or unaligned; access has no effect | ~10 % bad addresses | PSLVERR == model; later reads unchanged | cov bins bad x read/write; `BUG_SLVERR` caught |
| 10 | Wait states: PREADY low for N cycles | WAIT = 0, 1, 2, 3 (regression) | transfer completes, data correct | `regress.sh` per WAIT |
| 11 | APB protocol | every transfer | SVA: setup before access, stable while waiting, PENABLE needs PSEL, PSLVERR only on completion | `apb_sva.sv`; `BAD_MASTER` fires `a_stable_in_wait` |

Coverage target: 100 % of the 24 "coverage lite" bins in `tb_apb.v`, and the covergroup in
`apb_class_tb.sv` (address x direction x wait x response, with impossible combinations removed by `ignore_bins`).
