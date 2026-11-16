# cocotb port of the P1.5 UART loopback test.  make            (Icarus)
#                                              make SIM=verilator
SIM ?= icarus
TOPLEVEL_LANG = verilog
U = $(CURDIR)/../p1.5-uart/rtl
VERILOG_SOURCES = $(U)/baud_gen.v $(U)/uart_tx.v $(U)/uart_rx.v $(U)/sync_fifo.v $(U)/uart_top.v
COCOTB_TOPLEVEL = uart_top
COCOTB_TEST_MODULES = test_uart
export PYTHONPATH := $(CURDIR)/tests:$(PYTHONPATH)
# small divisor so the test is quick: 16 x 2 = 32 clocks per bit
ifeq ($(SIM),icarus)
  COMPILE_ARGS += -Puart_top.DIVISOR=2 -Puart_top.PAR_EN=1 -Puart_top.PAR_ODD=0
else
  EXTRA_ARGS += -GDIVISOR=2 -GPAR_EN=1 -GPAR_ODD=0
endif
include $(shell cocotb-config --makefiles)/Makefile.sim
