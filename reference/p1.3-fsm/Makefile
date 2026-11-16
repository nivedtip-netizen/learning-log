sim:
	iverilog -g2012 -o fsm.out rtl/*.v tb/tb_fsm.v && vvp -n fsm.out
lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-MULTITOP rtl/*.v
synth:
	yosys -q -p "read_verilog rtl/det1011.v; chparam -set ONEHOT 0 det_mealy_ov; synth -top det_mealy_ov; tee -o bin.stat stat"
	yosys -q -p "read_verilog rtl/det1011.v; chparam -set ONEHOT 1 det_mealy_ov; synth -top det_mealy_ov -nofsm; tee -o onehot.stat stat"
	@grep -H "Number of cells\|DFF" *.stat
clean:
	rm -f *.out *.vcd *.stat
.PHONY: sim lint synth clean
