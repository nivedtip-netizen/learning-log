# P4 RV32I: single-cycle and 5-stage pipelined cores.
#   make isa       directed ISA test (1,062 checks) on both cores + trace diff vs the C model
#   make hazards   10 hazard cases on the pipeline (forwarding, load-use, flushes)
#   make random    random-instruction regression (default 20 programs x 2000 instructions) + coverage
#   make bugs      the seeded pipeline bugs (BUG_FWD2, BUG_NOSTALL) against isa / hazards
#   make dpi       Verilator lockstep: the C model runs inside the simulation via DPI-C
#   make sva       Verilator: pipeline assertions bound to the core
#   make synth     Yosys cell counts for both cores
RTL_COMMON = rtl/rv_alu.v rtl/rv_regfile.v rtl/rv_immgen.v rtl/rv_branch.v rtl/rv_decoder.v rtl/rv_lsu.v
SEEDS ?= 20
LEN   ?= 2000
CC_RV = riscv64-unknown-elf-gcc

all: isa hazards random bugs

sw/isa_test.hex:
	./sw/build.sh isa_test
sw/hazards.hex: sw/hazards.S
	./sw/build.sh hazards
ref/rv32i_ref: ref/rv32i_ref.c
	gcc -O2 -o $@ $<

single.out: $(RTL_COMMON) rtl/rv32i_single.v tb/mem.v tb/tb_core.v
	iverilog -g2012 -I rtl -o $@ $(RTL_COMMON) rtl/rv32i_single.v tb/mem.v tb/tb_core.v
pipe.out: $(RTL_COMMON) rtl/rv32i_pipe.v tb/mem.v tb/tb_core.v
	iverilog -g2012 -DPIPE -I rtl -o $@ $(RTL_COMMON) rtl/rv32i_pipe.v tb/mem.v tb/tb_core.v

isa: sw/isa_test.hex ref/rv32i_ref single.out pipe.out
	@mkdir -p logs
	./ref/rv32i_ref sw/isa_test.hex logs/isa.ref
	@for c in single pipe; do printf "%-6s " $$c; vvp -n $$c.out +HEX=sw/isa_test.hex +TRACE=logs/isa.$$c | grep -E "RESULT|CPI" | tr '\n' ' '; \
	  cmp -s logs/isa.ref logs/isa.$$c && echo " trace == C model" || echo " TRACE DIFFERS"; done

hazards: sw/hazards.hex pipe.out
	@printf "pipe   "; vvp -n pipe.out +HEX=sw/hazards.hex | grep -E "RESULT|stall" | tr '\n' ' '; echo

random:
	rm -rf rand
	./rand_regress.sh 1 $(SEEDS) $(LEN)
	python3 tb/cov_trace.py rand/*.pipe

bugs: sw/isa_test.hex sw/hazards.hex
	@for b in BUG_FWD2 BUG_NOSTALL; do \
	  iverilog -g2012 -DPIPE -D$$b -I rtl -o bug.out $(RTL_COMMON) rtl/rv32i_pipe.v tb/mem.v tb/tb_core.v || exit 1; \
	  for t in isa_test hazards; do printf "%-12s %-9s " $$b $$t; vvp -n bug.out +HEX=sw/$$t.hex | grep RESULT; done; done

dpi: sw/isa_test.hex
	verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style -Irtl -DPIPE -DDPI -CFLAGS -DDPI \
	  $(RTL_COMMON) rtl/rv32i_pipe.v tb/mem.v tb/tb_core.v ref/rv32i_ref.c --top-module tb_core --Mdir obj_dpi -o sim > logs_dpi.log 2>&1
	./obj_dpi/sim +HEX=sw/isa_test.hex | grep -E "RESULT|mismatch"

sva: sw/isa_test.hex sw/hazards.hex
	verilator --binary --timing --assert -Wno-fatal -Wno-lint -Wno-style -Irtl -DPIPE \
	  $(RTL_COMMON) rtl/rv32i_pipe.v tb/mem.v tb/tb_core.v tb/core_sva.sv tb/tb_core_sva.sv --top-module tb_core_sva --Mdir obj_sva -o sim > logs_sva.log 2>&1
	./obj_sva/sim +HEX=sw/isa_test.hex | grep -E "RESULT|Assertion"
	./obj_sva/sim +HEX=sw/hazards.hex  | grep -E "RESULT|Assertion"

synth:
	@for c in single pipe; do yosys -q -p "read_verilog -I rtl $(RTL_COMMON) rtl/rv32i_$$c.v; synth -flatten -top rv32i_$$c; tee -o $$c.stat stat"; \
	  printf "%-6s " $$c; grep "Number of cells" $$c.stat | tail -1; done

lint:
	verilator --lint-only -Wall -Irtl $(RTL_COMMON) rtl/rv32i_pipe.v --top-module rv32i_pipe

clean:
	rm -f *.out *.stat logs_*.log
	rm -rf logs rand obj_dpi obj_sva
	rm -f sw/*.elf sw/*.bin sw/*.dis ref/rv32i_ref

.PHONY: all isa hazards random bugs dpi sva synth lint clean
