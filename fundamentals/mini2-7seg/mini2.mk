# Mini 2: BCD to 7-segment decoder
# make sim    -> run the exhaustive testbench (must print PASS)
# make bug    -> same test with a planted bug in segment e (must print FAIL)
# make py     -> Python golden-model check, including the planted-bug demo
# make synth  -> count gates with Yosys (SOP vs case/lookup-table version)
# make clean  -> delete generated files

RTL = rtl/seg7_sop.v rtl/seg7_case.v rtl/seg7_nand_e.v

sim:
	iverilog -g2005 -Wall -o seg7.vvp $(RTL) tb/tb_seg7.v
	vvp seg7.vvp

bug:
	iverilog -g2005 -Wall -DPLANT_BUG -o seg7_bug.vvp $(RTL) tb/tb_seg7.v
	-vvp seg7_bug.vvp

py:
	python3 python/seg7_check.py
	-python3 python/seg7_check.py --bug

synth:
	yosys -q -p "read_verilog rtl/seg7_sop.v; synth -flatten -top seg7_sop; abc -g gates; opt_clean; tee -o synth_sop.txt stat"
	yosys -q -p "read_verilog rtl/seg7_case.v; synth -flatten -top seg7_case; abc -g gates; opt_clean; tee -o synth_case.txt stat"
	@echo "--- hand-minimized SOP ---"; grep -A12 "Number of cells" synth_sop.txt
	@echo "--- case / lookup table ---"; grep -A12 "Number of cells" synth_case.txt

clean:
	rm -f *.vvp *.vcd synth_*.txt

.PHONY: sim bug py synth clean
