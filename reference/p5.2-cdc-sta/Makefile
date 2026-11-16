# P5.2 CDC library across clock ratios, with and without the metastability model,
# plus the BAD_PULSE source that ignores busy (expected to FAIL when the check sees it).
RATIOS = 10:27 27:10 10:10.3 7:50 50:7
SEEDS ?= 1 2 3

all: cdc bad gls

cdc:
	@mkdir -p logs
	@for r in $(RATIOS); do a=$${r%%:*}; b=$${r##*:}; for m in "" "-DMETA -DWIN_NS=1.0"; do \
	  iverilog -g2012 $$m -P tb_cdc.TA=$$a -P tb_cdc.TB=$$b -o logs/cdc.out tb/tb_cdc.v rtl/cdc_lib.v || exit 1; \
	  for s in $(SEEDS); do printf "TA=%-4s TB=%-5s %-5s seed=%s  " $$a $$b "$${m:+META}" $$s; vvp -n logs/cdc.out +SEED=$$s | grep RESULT; done; done; done

bad:
	@mkdir -p logs
	@for r in $(RATIOS); do a=$${r%%:*}; b=$${r##*:}; \
	  iverilog -g2012 -DBAD_PULSE -P tb_cdc.TA=$$a -P tb_cdc.TB=$$b -o logs/bad.out tb/tb_cdc.v rtl/cdc_lib.v || exit 1; \
	  printf "BAD_PULSE TA=%-4s TB=%-5s " $$a $$b; vvp -n logs/bad.out | grep -E "pulses=|RESULT" | tr '\n' ' '; echo; done

# zero-delay gate-level simulation of the P1.5 UART
gls:
	@$(MAKE) -s -C gls

clean:
	rm -rf logs
	@$(MAKE) -s -C gls clean

.PHONY: all cdc bad gls clean
