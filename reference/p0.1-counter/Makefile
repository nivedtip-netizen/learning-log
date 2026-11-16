TOP  = counter
SRCS = counter.v tb_counter.v

sim:
	iverilog -g2012 -o sim $(SRCS)
	vvp sim

wave: sim
	gtkwave counter.vcd

lint:
	verilator --lint-only -Wall counter.v

synth:
	yosys -p "read_verilog counter.v; synth -top $(TOP); stat"

clean:
	rm -f sim *.vcd
.PHONY: sim wave lint synth clean
