# Mini 3: 4-bit adder/subtractor + comparator
# make sim    -> run both exhaustive testbenches
# make wave   -> open the adder waveform in GTKWave
# make synth  -> count gates with Yosys
# make clean  -> delete generated files

RTL = rtl/half_adder.v rtl/full_adder.v rtl/addsub4.v rtl/comparator4.v

sim:
	iverilog -g2005 -Wall -o addsub4.vvp rtl/half_adder.v rtl/full_adder.v rtl/addsub4.v tb/tb_addsub4.v
	vvp addsub4.vvp
	iverilog -g2005 -Wall -o comparator4.vvp rtl/comparator4.v tb/tb_comparator4.v
	vvp comparator4.vvp

wave: sim
	gtkwave addsub4.vcd &

synth:
	yosys -q -p "read_verilog $(RTL); synth -flatten -top addsub4; abc -g gates; opt_clean; tee -o synth_addsub4.txt stat"
	yosys -q -p "read_verilog $(RTL); synth -flatten -top comparator4; abc -g gates; opt_clean; tee -o synth_comparator4.txt stat"
	@echo "--- addsub4 ---";     grep -A10 "Number of cells" synth_addsub4.txt
	@echo "--- comparator4 ---"; grep -A10 "Number of cells" synth_comparator4.txt

clean:
	rm -f *.vvp *.vcd synth_*.txt

.PHONY: sim wave synth clean
