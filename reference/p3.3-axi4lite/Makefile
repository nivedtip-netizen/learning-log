# make sim        one random run (Icarus)          SEED=<n> MODE=0|1|2 N=<n>
# make sva        same run with the bound SVA checker (Verilator)
# make bugs       every seeded bug, first error + result
# make regress    bash regression: 3 modes x SEEDS seeds
# make dashboard  Python regression -> dashboard.html (+ dashboard_bugs.html)
SEED  ?= 1
MODE  ?= 0
N     ?= 500
SEEDS ?= 10
RTL = rtl/axil_regs.v
BUGS = BUG_WSTRB BUG_EARLY_B BUG_RRESP BUG_B_DROP BUG_RDATA

sim:
	iverilog -g2012 -o axil.out $(RTL) tb/tb_axil.v && vvp -n axil.out +SEED=$(SEED) +MODE=$(MODE) +N=$(N) | grep -v finish
sva:
	verilator --binary --timing --assert -Wno-fatal -Wno-lint -Wno-style $(RTL) tb/tb_axil.v tb/axil_sva.sv tb/tb_axil_sva.sv \
	  --top-module tb_axil_sva --Mdir obj_sva -o sim > /dev/null && ./obj_sva/sim +SEED=$(SEED) +MODE=$(MODE)
bugs:
	@for b in $(BUGS); do iverilog -g2012 -D$$b -o bug.out $(RTL) tb/tb_axil.v && \
	  echo "$$b: $$(vvp -n bug.out +SEED=$(SEED) | grep -m1 ERR) | $$(vvp -n bug.out +SEED=$(SEED) | grep RESULT)"; done
regress:
	./regress.sh $(SEEDS)
dashboard:
	python3 ../tools/regress.py regress.json --seeds $(SEEDS)
	-python3 ../tools/regress.py regress_bugs.json
lint:
	verilator --lint-only -Wall $(RTL)
clean:
	rm -f *.out
	rm -rf obj_sva logs logs_bugs
.PHONY: sim sva bugs regress dashboard lint clean
