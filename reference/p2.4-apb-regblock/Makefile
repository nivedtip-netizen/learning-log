# make sim          one run (Icarus)           make sva      run with bound SVA (Verilator)
# make bugs         each seeded bug must FAIL  make regress  wait states x seeds (bash)
SEED ?= 1
WAIT ?= 1
N    ?= 3000
sim:
	iverilog -g2012 -Ptb_apb.WAIT=$(WAIT) -o apb.out rtl/apb_regs.v tb/tb_apb.v && vvp -n apb.out +SEED=$(SEED) +N=$(N) | grep -v finish
sva:
	verilator --binary --timing --assert -Wno-fatal -Wno-lint -Wno-style rtl/apb_regs.v tb/tb_apb.v tb/apb_sva.sv tb/tb_apb_sva.sv \
	  --top-module tb_apb_sva --Mdir obj_sva -o sim > /dev/null && ./obj_sva/sim +SEED=$(SEED)
bugs:
	@for b in BUG_W1C BUG_STRB BUG_SLVERR; do iverilog -g2012 -D$$b -o bug.out rtl/apb_regs.v tb/tb_apb.v && echo "$$b: $$(vvp -n bug.out +SEED=$(SEED) | grep RESULT)"; done
regress:
	./regress.sh 10
lint:
	verilator --lint-only -Wall rtl/apb_regs.v
clean:
	rm -f *.out
	rm -rf obj_sva logs
.PHONY: sim sva bugs regress lint clean
