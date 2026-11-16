# P5.5 eight classic interview RTL blocks, one self-checking bench.
RTL = rtl/rr_arbiter.v rtl/clk_mux_gf.v rtl/skid_buffer.v rtl/gray_counter.v rtl/pattern_det.v \
      rtl/fifo_min.v rtl/edge_detect.v rtl/clk_div_n.v
BLOCKS = rr_arbiter clk_mux_gf skid_buffer gray_counter pattern_det fifo_min edge_detect clk_div_n

sim:
	@iverilog -g2012 -o i.out tb/tb_interview.v $(RTL)
	@for s in 1 2 3; do vvp -n i.out +SEED=$$s | grep -E "arbiter|RESULT"; done

# the naive 'sel ? clk1 : clk0' mux in place of the glitch-free one: expected to FAIL
bad_mux:
	@iverilog -g2012 -DBAD_MUX -o bad.out tb/tb_interview.v $(RTL)
	@vvp -n bad.out | grep -E "ERROR|RESULT" | head -4

lint:
	@for m in $(BLOCKS); do verilator --lint-only -Wall $(RTL) --top-module $$m || exit 1; done

synth:
	@for m in $(BLOCKS); do yosys -q -p "read_verilog $(RTL); synth -top $$m; tee -q -o $$m.stat stat"; \
	  printf "%-14s %s\n" $$m "$$(grep 'Number of cells' $$m.stat | tail -1)"; done

clean:
	rm -f *.out *.stat

.PHONY: sim bad_mux lint synth clean
