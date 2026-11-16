> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

# RV32I cores: micro-architecture spec

## Scope

- ISA: RV32I base, 37 instructions + FENCE (as a no-op). ECALL/EBREAK and any illegal encoding halt the core. No CSRs, no interrupts, no misaligned-access traps (loads/stores are assumed aligned; the generator only makes aligned ones).
- Two implementations with the **same ports**, so one testbench checks both:
  - `rv32i_single`: every instruction in one clock (CPI = 1, long critical path).
  - `rv32i_pipe`: 5 stages IF | ID | EX | MEM | WB with forwarding, a load-use stall and branch resolution in EX.
- Memory: Harvard ports (`imem_*`, `dmem_*`) onto one 64 KB array in the testbench, combinational read, byte enables on write. A store to `0xFFF0` (TOHOST) ends a test.
- **Retirement port** (`ret_valid, ret_pc, ret_insn, ret_rd, ret_rd_wdata, ret_mem_addr, ret_mem_wdata, ret_mem_be`): one line per finished instruction, in program order. This is what the reference model is compared against.

## Shared blocks

| Block | Job |
|---|---|
| `rv_decoder` | opcode/funct3/funct7 -> control word (ALU op, operand selects, write-back select, mem read/write, branch/jal/jalr, halt, illegal, uses_rs1/uses_rs2) |
| `rv_immgen` | I/S/B/U/J immediates, sign-extended |
| `rv_alu` | add, sub, sll, slt, sltu, xor, srl, sra, or, and, pass-B (for LUI) |
| `rv_branch` | beq/bne/blt/bge/bltu/bgeu compare |
| `rv_lsu` | byte enables and store-data replication; load alignment and sign/zero extension |
| `rv_regfile` | 32 x 32, x0 hard-wired to 0, 2 read + 1 write port. `BYPASS=1` makes a same-cycle write visible to the read (WB -> ID); the single-cycle core uses `BYPASS=0` because there the bypass forms a combinational loop |

## Pipeline

```
        IF            ID                 EX                       MEM               WB
 PC -> imem -> [IF/ID] -> decode, regs -> [ID/EX] -> ALU, branch -> [EX/MEM] -> dmem -> [MEM/WB] -> regfile
                                   ^                 |   ^   ^                |                 |
                                   |                 |   |   +---- EX/MEM fwd -+                 |
                                   |                 |   +-------- MEM/WB fwd -------------------+
                                   +-- write-through (WB -> ID, same cycle)
          redirect (taken branch / jal / jalr) from EX -> PC, flush IF/ID and ID/EX
```

**Forwarding** (into the EX operands, priority EX/MEM over MEM/WB):
`fwd1_m = m_v && m_rw && !m_mr && m_rd != 0 && m_rd == e_rs1` (same for rs2 and for MEM/WB).
A load in EX/MEM cannot forward (its data arrives in MEM), which is why the load-use stall exists.
`e_rs1/e_rs2` are forced to 0 when the instruction does not use that source, so a stray field never matches.

**Load-use stall**: `stall = d_v && e_v && e_mr && e_rd != 0 && ((uses_rs1 && d_rs1 == e_rd) || (uses_rs2 && d_rs2 == e_rd))`.
PC and IF/ID hold, ID/EX gets a bubble, and the load moves on to MEM. One cycle later the value is forwarded from MEM/WB.

**Branches and jumps** resolve in EX. On a redirect, the instruction in IF/ID and the one being fetched are flushed: 2-cycle penalty, no prediction (always not taken).

**Halt**: ECALL/illegal sets `halt_pending` when it leaves ID (fetch stops), and the core halts when it reaches WB, so all older instructions retire first.

### Load-use, cycle by cycle

```
cycle         1     2     3     4     5     6     7
lw  x1,0(x2)  IF    ID    EX    MEM   WB
add x3,x1,x4        IF    ID    ID*   EX    MEM   WB      * stall: held in ID one cycle
and x5,x6,x7              IF    IF*   ID    EX    MEM
                                 ^ bubble in EX in cycle 4; in cycle 5 x1 is forwarded MEM/WB -> EX
```

### Taken branch

```
cycle          1     2     3     4     5     6
beq x1,x2,L    IF    ID    EX    MEM   WB
next (+4)            IF    ID    --                     flushed
next (+8)                  IF    --                     flushed
L:                               IF    ID    EX ...     2 cycles lost
```

## Verification

| Level | What | Result |
|---|---|---|
| Directed | `gen_isa_test.py`: 1,062 self-checking cases, every instruction with corner operands (0, 1, -1, INT_MIN, INT_MAX, shift 0/31, sign extension of every load size, x0 as destination) | PASS on both cores, retirement trace identical to the C model |
| Hazards | `hazards.S`: 10 cases (forward distance 1/2/3, both operands, chains, load-use, load->store, compare->branch, jal/jalr link use, x0 never forwarded) | PASS: 2 stalls, 5 flushes as expected |
| Reference model | `ref/rv32i_ref.c`: ~170-line ISA model; standalone trace diff, or lock-step inside the simulation via DPI-C (Verilator) | 0 mismatches |
| Random | `gen_random.py`: constrained-random programs (mix, register bias for hazards, bounded loops, aligned memory window) | 500 programs, 1,128,302 instructions per core, 0 mismatches |
| Coverage | `cov_trace.py`, 161 bins from the retirement trace (every instruction, rd/rs1/rs2 x 32, immediates at extremes, add/sub overflow, RAW distance x consumer, load-use, branch taken/not x direction) | 100 % |
| Assertions | `core_sva.sv` bound to the pipeline: x0 never written, PC aligned, no stall and flush together, quiet after halt | PASS |
| Mutants | `BUG_FWD2` (no EX/MEM forward for rs2), `BUG_NOSTALL` (no load-use stall) | FWD2 caught by every test; NOSTALL passes the ISA test (no back-to-back load-use in it) and is caught by hazard case 6 and by random programs |

## Synthesis (Yosys generic gates, memories outside the core)

| Core | Cells | Flops | Longest path (gate levels) | CPI on the ISA test |
|---|---|---|---|---|
| single-cycle | ~6,100 | 1,025 | 41 | 1.000 |
| 5-stage pipe | ~7,200 | 1,584 | 33 | 1.297 |

Cell counts move by about 1 % between Yosys runs (ABC optimisation order). Gate levels are a rough stand-in for timing; a real comparison needs a standard-cell library and STA. In the pipeline the longest path should be the EX stage (forward mux -> ALU -> branch compare -> PC redirect mux); confirming that is a job for STA (not run here).
