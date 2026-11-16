# Runs on Verilator 5.020+ (assertions + "coverage lite"). The covergroup file
# tb/fifo_cov.sv needs a commercial simulator: add +define+WITH_COVERGROUPS there.
FIFO = ../p2.1-sv-fifo-lab/rtl/fifo_pkg.sv ../p2.1-sv-fifo-lab/rtl/fifo.sv
VFLAGS = --binary --timing --assert -Wno-fatal -Wno-lint -Wno-style
BUGS = BUG_FLAGS BUG_WRFULL BUG_IDLE BUG_FULL
sim:
	verilator $(VFLAGS) $(FIFO) tb/fifo_checker.sv tb/tb_sva.sv --top-module tb_sva --Mdir obj_clean -o sim && ./obj_clean/sim
bugs:
	@for b in $(BUGS); do echo "== $$b"; verilator $(VFLAGS) +define+$$b $(FIFO) tb/fifo_checker.sv tb/tb_sva.sv \
	  --top-module tb_sva --Mdir obj_$$b -o sim > /dev/null && ./obj_$$b/sim 2>&1 | grep "Assertion failed" | head -1; done
gray:
	@for b in 0 1; do verilator $(VFLAGS) -GBUG=$$b ../p1.4-fifo/rtl/sync2.v ../p1.4-fifo/rtl/async_fifo.v tb/fifo_checker.sv tb/tb_gray.sv \
	  --top-module tb_gray --Mdir obj_g$$b -o sim > /dev/null && ./obj_g$$b/sim 2>&1 | grep -E "fired|Assertion failed" | head -1; done
clean:
	rm -rf obj_* *.log
.PHONY: sim bugs gray clean
