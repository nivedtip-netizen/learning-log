# Zero-delay gate-level simulation (GLS) of the P1.5 UART.
# 1) synthesize uart_top with the testbench's parameters baked in (DIVISOR=2, even parity)
# 2) simulate the netlist + Yosys cell models with the unchanged RTL testbench
# 3) the same test on the RTL, for comparison
U    = ../../p1.5-uart
RTL  = $(U)/rtl/baud_gen.v $(U)/rtl/uart_tx.v $(U)/rtl/uart_rx.v $(U)/rtl/sync_fifo.v $(U)/rtl/uart_top.v
CELLS = $(shell ls /usr/share/yosys/simcells.v /usr/local/share/yosys/simcells.v 2>/dev/null | head -1)

all: rtl gls

uart_netlist.v: $(RTL)
	yosys -q -l synth.log -p "read_verilog $(RTL); chparam -set DIVISOR 2 -set PAR_EN 1 -set PAR_ODD 0 uart_top; \
	  synth -top uart_top -flatten; abc -g AND,NAND,OR,NOR,XOR,XNOR,MUX; opt_clean; stat; rename uart_top uart_top_gl; write_verilog -noattr uart_netlist.v"
	@grep -E "Number of cells" synth.log | tail -1

rtl:
	@iverilog -g2012 -o rtl.out $(RTL) $(U)/tb/tb_uart.v && printf "RTL: " && vvp -n rtl.out | grep -E "PASS|FAIL|bytes sent|expect"

gls: uart_netlist.v
	@iverilog -g2012 -o gls.out uart_netlist.v uart_top_shim.v $(CELLS) $(U)/tb/tb_uart.v 2> gls_compile.log; \
	  grep -iE "error" gls_compile.log; printf "GLS: " && vvp -n gls.out | grep -E "PASS|FAIL|bytes sent|expect"

clean:
	rm -f *.out *.log uart_netlist.v

.PHONY: all rtl gls clean
