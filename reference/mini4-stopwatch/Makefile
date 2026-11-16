sim:
	iverilog -g2012 -o sim.out rtl/*.v tb/tb_stopwatch.v && vvp -n sim.out
lint:
	verilator --lint-only -Wall rtl/seg7.v rtl/stopwatch.v --top-module stopwatch
synth:
	yosys -q -p "read_verilog rtl/seg7.v rtl/stopwatch.v; synth -top stopwatch; stat"
clean:
	rm -f sim.out *.vcd
.PHONY: sim lint synth clean
