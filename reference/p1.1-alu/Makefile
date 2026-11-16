RTL = rtl/mux4.v rtl/dec_enc.v rtl/adders.v rtl/cmp_shift.v rtl/alu8.v
sim:
	iverilog -g2012 -o comb.out $(RTL) tb/tb_comb.v && vvp -n comb.out
	iverilog -g2012 -o alu.out  $(RTL) tb/tb_alu8.v && vvp -n alu.out
lint:
	verilator --lint-only -Wall rtl/alu8.v
synth:
	yosys -q -p "read_verilog rtl/adders.v; synth -top rca; tee -o rca.stat stat"
	yosys -q -p "read_verilog rtl/adders.v; synth -top cla4; tee -o cla.stat stat"
	yosys -q -p "read_verilog rtl/latch_demo.v; synth -top latch_bad; tee -o latch_bad.stat stat"
	yosys -q -p "read_verilog rtl/latch_demo.v; synth -top latch_fixed; tee -o latch_fixed.stat stat"
	@grep -H "Number of cells\|LATCH\|DLATCH" *.stat
clean:
	rm -f *.out *.stat *.vcd
.PHONY: sim lint synth clean
