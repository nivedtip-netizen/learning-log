sim:
	iverilog -g2012 -o axi4.out rtl/axi4_mem.v tb/tb_axi4.v && for s in 1 2 3 4 5; do vvp -n axi4.out +SEED=$$s | grep RESULT; done
lint:
	verilator --lint-only -Wall -Wno-BLKSEQ -Wno-UNUSEDPARAM rtl/axi4_mem.v
clean:
	rm -f axi4.out
.PHONY: sim lint clean
