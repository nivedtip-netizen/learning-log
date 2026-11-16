/* RV32I instruction-set reference model (about 170 lines).
 *
 * Standalone:  ./rv32i_ref prog.hex trace.txt [max_instructions]
 *   writes one line per retired instruction in the same format as tb_core.v:
 *   pc insn rd rd_wdata mem_addr mem_wdata byte_enables
 *   Stops after a store to TOHOST (0xFFF0), or at ECALL/EBREAK/illegal (not logged).
 *
 * DPI-C (compile with -DDPI): rv_ref_init(hexfile) once, then rv_ref_step(...)
 *   for every instruction the core retires; the testbench compares the outputs.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MEM_WORDS 16384u
#define TOHOST    0xFFF0u

typedef struct {
  uint32_t pc, insn, rd, rd_wdata, mem_addr, mem_wdata, be;
  int stop;   /* 1 = TOHOST store (logged), 2 = halt/illegal (not logged) */
} retire_t;

static uint32_t x[32];
static uint32_t mem[MEM_WORDS];
static uint32_t pc;

static int load_hex(const char *path) {
  FILE *f = fopen(path, "r");
  char line[64];
  uint32_t i = 0;
  if (!f) return -1;
  memset(mem, 0, sizeof mem);
  while (fgets(line, sizeof line, f) && i < MEM_WORDS) {
    if (line[0] == '\n' || line[0] == '/') continue;
    mem[i++] = (uint32_t)strtoul(line, NULL, 16);
  }
  fclose(f);
  return 0;
}

static uint32_t sext(uint32_t v, int bits) { uint32_t m = 1u << (bits - 1); v &= (1u << bits) - 1; return (v ^ m) - m; }

static uint32_t imm_i(uint32_t i) { return sext(i >> 20, 12); }
static uint32_t imm_s(uint32_t i) { return sext(((i >> 25) << 5) | ((i >> 7) & 0x1F), 12); }
static uint32_t imm_b(uint32_t i) {
  return sext(((i >> 31) << 12) | (((i >> 7) & 1) << 11) | (((i >> 25) & 0x3F) << 5) | (((i >> 8) & 0xF) << 1), 13);
}
static uint32_t imm_u(uint32_t i) { return i & 0xFFFFF000u; }
static uint32_t imm_j(uint32_t i) {
  return sext(((i >> 31) << 20) | (((i >> 12) & 0xFF) << 12) | (((i >> 20) & 1) << 11) | (((i >> 21) & 0x3FF) << 1), 21);
}

static uint32_t alu(uint32_t f3, int alt, uint32_t a, uint32_t b) {
  switch (f3) {
    case 0: return alt ? a - b : a + b;
    case 1: return a << (b & 31);
    case 2: return (int32_t)a < (int32_t)b;
    case 3: return a < b;
    case 4: return a ^ b;
    case 5: return alt ? (uint32_t)((int32_t)a >> (b & 31)) : a >> (b & 31);
    case 6: return a | b;
    default: return a & b;
  }
}

static void ref_reset(void) { memset(x, 0, sizeof x); pc = 0; }

static retire_t step(void) {
  retire_t r = {0};
  uint32_t i = mem[(pc >> 2) % MEM_WORDS];
  uint32_t op = i & 0x7F, rd = (i >> 7) & 31, f3 = (i >> 12) & 7, rs1 = (i >> 15) & 31, rs2 = (i >> 20) & 31;
  uint32_t a = x[rs1], b = x[rs2], next = pc + 4, wb = 0;
  int wr = 0;
  r.pc = pc; r.insn = i;
  switch (op) {
    case 0x37: wb = imm_u(i); wr = 1; break;                                        /* LUI   */
    case 0x17: wb = pc + imm_u(i); wr = 1; break;                                   /* AUIPC */
    case 0x6F: wb = pc + 4; wr = 1; next = pc + imm_j(i); break;                    /* JAL   */
    case 0x67: if (f3) { r.stop = 2; return r; }                                    /* JALR  */
               wb = pc + 4; wr = 1; next = (a + imm_i(i)) & ~1u; break;
    case 0x63: {                                                                    /* BRANCH */
      int t;
      switch (f3) {
        case 0: t = a == b; break;                 case 1: t = a != b; break;
        case 4: t = (int32_t)a < (int32_t)b; break; case 5: t = (int32_t)a >= (int32_t)b; break;
        case 6: t = a < b; break;                  case 7: t = a >= b; break;
        default: r.stop = 2; return r;
      }
      if (t) next = pc + imm_b(i);
      break;
    }
    case 0x03: {                                                                    /* LOAD  */
      uint32_t ad = a + imm_i(i), w = mem[(ad >> 2) % MEM_WORDS], sh = 8 * (ad & 3);
      switch (f3) {
        case 0: wb = sext(w >> sh, 8); break;
        case 1: wb = sext(w >> (8 * (ad & 2)), 16); break;
        case 2: wb = w; break;
        case 4: wb = (w >> sh) & 0xFF; break;
        case 5: wb = (w >> (8 * (ad & 2))) & 0xFFFF; break;
        default: r.stop = 2; return r;
      }
      wr = 1; r.mem_addr = ad;
      break;
    }
    case 0x23: {                                                                    /* STORE */
      uint32_t ad = a + imm_s(i), be, wd, k, *m = &mem[(ad >> 2) % MEM_WORDS];
      switch (f3) {
        case 0: be = 1u << (ad & 3);           wd = (b & 0xFF) * 0x01010101u; break;
        case 1: be = (ad & 2) ? 0xC : 0x3;     wd = (b & 0xFFFF) * 0x00010001u; break;
        case 2: be = 0xF;                      wd = b; break;
        default: r.stop = 2; return r;
      }
      for (k = 0; k < 4; k++) if (be & (1u << k)) *m = (*m & ~(0xFFu << (8 * k))) | (wd & (0xFFu << (8 * k)));
      r.mem_addr = ad; r.mem_wdata = wd; r.be = be;
      if (ad == TOHOST) r.stop = 1;
      break;
    }
    case 0x13: {                                                                    /* OP-IMM */
      uint32_t im = imm_i(i);
      int alt = (f3 == 5) && ((i >> 30) & 1);
      wb = alu(f3, alt, a, (f3 == 1 || f3 == 5) ? (im & 31) : im); wr = 1;
      break;
    }
    case 0x33: wb = alu(f3, (i >> 30) & 1, a, b); wr = 1; break;                   /* OP    */
    case 0x0F: break;                                                               /* FENCE */
    default:   r.stop = 2; return r;                                                /* SYSTEM / illegal */
  }
  if (wr) { r.rd = rd; if (rd) { x[rd] = wb; r.rd_wdata = wb; } }
  pc = next;
  return r;
}

#ifdef DPI
/* SystemVerilog side:
 *   import "DPI-C" function int  rv_ref_init(input string hex);
 *   import "DPI-C" function void rv_ref_step(output int pc, output int insn, output int rd, output int rd_wdata,
 *                                            output int mem_addr, output int mem_wdata, output int be);       */
#ifdef __cplusplus
extern "C" {
#endif
int rv_ref_init(const char *hex) { ref_reset(); return load_hex(hex); }
void rv_ref_step(int *o_pc, int *o_insn, int *o_rd, int *o_wd, int *o_ma, int *o_mw, int *o_be) {
  retire_t r = step();
  *o_pc = r.pc; *o_insn = r.insn; *o_rd = r.rd; *o_wd = r.rd_wdata; *o_ma = r.mem_addr; *o_mw = r.mem_wdata; *o_be = r.be;
}
#ifdef __cplusplus
}
#endif
#else
int main(int argc, char **argv) {
  FILE *out;
  unsigned long n, max = 5000000;
  if (argc < 3) { fprintf(stderr, "usage: %s prog.hex trace.txt [max]\n", argv[0]); return 2; }
  if (argc > 3) max = strtoul(argv[3], NULL, 10);
  if (load_hex(argv[1])) { perror(argv[1]); return 2; }
  out = fopen(argv[2], "w");
  ref_reset();
  for (n = 0; n < max; n++) {
    retire_t r = step();
    if (r.stop == 2) break;
    fprintf(out, "%08x %08x %u %08x %08x %08x %x\n", r.pc, r.insn, r.rd, r.rd_wdata, r.mem_addr, r.mem_wdata, r.be);
    if (r.stop == 1) break;
  }
  fclose(out);
  return 0;
}
#endif
