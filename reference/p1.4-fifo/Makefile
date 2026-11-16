# 100/37 MHz = 10ns/27ns, 37/100 MHz = 27ns/10ns, equal = 10ns/10ns (offset phases by reset timing)
RATIOS = "10.0 27.0" "27.0 10.0" "10.0 10.0"
sim: sync async
sync:
	iverilog -g2012 -o s.out rtl/sync_fifo.v tb/tb_sync_fifo.v && vvp -n s.out
async:
	@for r in $(RATIOS); do set -- $$r; \
	  iverilog -g2012 -DMETA -Ptb_async_fifo.WPER=$$1 -Ptb_async_fifo.RPER=$$2 -o a.out rtl/sync2.v rtl/async_fifo.v tb/tb_async_fifo.v && vvp -n a.out | grep -v finish; done
bug:
	@for r in $(RATIOS); do set -- $$r; \
	  iverilog -g2012 -DMETA -Ptb_async_fifo.BUG_BIN=1 -Ptb_async_fifo.WPER=$$1 -Ptb_async_fifo.RPER=$$2 -o b.out rtl/sync2.v rtl/async_fifo.v tb/tb_async_fifo.v && vvp -n b.out | grep -v finish; done
lint:
	verilator --lint-only -Wall rtl/sync_fifo.v
	verilator --lint-only -Wall rtl/async_fifo.v rtl/sync2.v --top-module async_fifo
clean:
	rm -f *.out *.vcd
.PHONY: sim sync async bug lint clean
