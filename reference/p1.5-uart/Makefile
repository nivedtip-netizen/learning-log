RTL = rtl/baud_gen.v rtl/uart_tx.v rtl/uart_rx.v rtl/sync_fifo.v rtl/uart_top.v
sim:
	iverilog -g2012 -o u.out $(RTL) tb/tb_uart.v && vvp -n u.out | grep -v finish
ppm:
	@for p in 2.0 -2.0 4.0 -4.0 6.0; do iverilog -g2012 -Ptb_uart_ppm.PCT=$$p -o p.out $(RTL) tb/tb_uart_ppm.v && vvp -n p.out | grep -v finish; done
lint:
	verilator --lint-only -Wall -Wno-PINCONNECTEMPTY $(RTL) --top-module uart_top
synth:
	yosys -q -p "read_verilog $(RTL); synth -top uart_top; tee -o uart.stat stat" && grep "Number of cells" uart.stat | tail -1
clean:
	rm -f *.out *.vcd *.stat
.PHONY: sim ppm lint synth clean
