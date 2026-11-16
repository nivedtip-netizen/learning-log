# P5.7 INT8 systolic array.
#   make sim      NumPy vectors -> RTL, N = 2, 4, 8, PIPE_MUL = 0/1, with and without input bubbles
#   make bug      seeded skew bug (last row of A one cycle early): expected FAIL
#   make trace    cycle-by-cycle printout of a 2x2 array from the Python model
#   make synth    Yosys cells, flops and longest gate path at N = 2, 4, 8 (generic gates, not a real library)
SIZES ?= 2 4 8
RTL = rtl/pe.v rtl/systolic_array.v rtl/systolic_top.v

all: sim bug

logs/vec%.txt: model/golden.py
	@mkdir -p logs
	python3 model/golden.py vectors $* $@ --seed $*

sim: $(foreach n,$(SIZES),logs/vec$(n).txt)
	@for n in $(SIZES); do for p in 0 1; do \
	  iverilog -g2012 -P tb_systolic.N=$$n -P tb_systolic.PIPE_MUL=$$p -o logs/s.out tb/tb_systolic.v $(RTL) || exit 1; \
	  for b in 0 1; do vvp -n logs/s.out +VEC=logs/vec$$n.txt +BUBBLES=$$b | grep -E "^N=|RESULT" | tr '\n' ' '; echo; done; done; done

bug: logs/vec4.txt
	@iverilog -g2012 -DBUG_SKEW -P tb_systolic.N=4 -o logs/b.out tb/tb_systolic.v $(RTL)
	@printf "BUG_SKEW N=4: "; vvp -n logs/b.out +VEC=logs/vec4.txt | grep RESULT

trace:
	python3 model/golden.py trace 2 --k 2 --seed 3

synth:
	@mkdir -p logs
	@printf "%-4s %-8s %8s %7s %12s\n" N PIPE_MUL cells flops longest_path
	@for n in $(SIZES); do for p in 0 1; do \
	  yosys -q -l logs/syn_$${n}_$$p.log -p "read_verilog $(RTL); chparam -set N $$n -set PIPE_MUL $$p systolic_top; \
	    synth -flatten -top systolic_top; stat; ltp -noff" > /dev/null 2>&1; \
	  c=$$(grep 'Number of cells' logs/syn_$${n}_$$p.log | tail -1 | awk '{print $$4}'); \
	  f=$$(awk '/Printing statistics/{s=0} /\$$_[A-Z]*DFF/{s+=$$2} END{print s}' logs/syn_$${n}_$$p.log); \
	  l=$$(grep -oE 'length=[0-9]+' logs/syn_$${n}_$$p.log | tail -1); \
	  printf "%-4s %-8s %8s %7s %12s\n" $$n $$p $$c $$f $$l; done; done

lint:
	verilator --lint-only -Wall $(RTL) --top-module systolic_top

clean:
	rm -rf logs

.PHONY: all sim bug trace synth lint clean
