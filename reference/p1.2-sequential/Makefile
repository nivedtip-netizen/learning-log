sim:
	iverilog -g2012 -o seq.out rtl/*.v tb/tb_seq.v && vvp -n seq.out
lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-MULTITOP $(filter-out rtl/race_demo.v,$(wildcard rtl/*.v))
synth:
	yosys -q -p "read_verilog rtl/clkdiv.v; synth -top div3_50; tee -o div3.stat stat"
clean:
	rm -f *.out *.vcd *.stat
.PHONY: sim lint synth clean
