sim: spi i2c
spi:
	@for m in "0 0" "0 1" "1 0" "1 1"; do set -- $$m; \
	  iverilog -g2012 -Ptb_spi.CPOL=$$1 -Ptb_spi.CPHA=$$2 -o s.out rtl/spi_slave.v tb/tb_spi.v && vvp -n s.out | grep -v finish; done
i2c:
	iverilog -g2012 -o i.out rtl/i2c_master.v tb/eeprom_model.v tb/tb_i2c.v && vvp -n i.out | grep -v finish
lint:
	verilator --lint-only -Wall -Wno-UNUSEDSIGNAL rtl/spi_slave.v
	verilator --lint-only -Wall -Wno-UNUSEDSIGNAL rtl/i2c_master.v
clean:
	rm -f *.out *.vcd
.PHONY: sim spi i2c lint clean
