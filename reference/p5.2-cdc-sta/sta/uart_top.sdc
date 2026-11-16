# SDC for the P1.5 UART top (uart_top), default DIVISOR=27: 50 MHz / (16 x 27) = 115,740 baud (+0.47 % vs 115,200).
# Not run through OpenSTA in the cloud build (no Liberty library / OpenSTA there).
# To try it on your laptop: synthesize to a Sky130 netlist, then in OpenSTA:
#   read_liberty sky130_fd_sc_hd__tt_025C_1v80.lib; read_verilog uart_net.v; link_design uart_top
#   read_sdc uart_top.sdc; report_checks -path_delay min_max; report_tns; report_wns

# ---- clock: 50 MHz, with margin for jitter/skew before CTS ----
create_clock -name clk -period 20.0 [get_ports clk]
set_clock_uncertainty -setup 0.30 [get_clocks clk]
set_clock_uncertainty -hold  0.10 [get_clocks clk]
set_clock_transition 0.15 [get_clocks clk]

# ---- synchronous inputs: assume the driving logic uses 40 % of the period ----
set sync_in [list [get_ports tx_push] [get_ports tx_data*] [get_ports rx_pop] [get_ports loopback]]
set_input_delay  -max 8.0 -clock clk $sync_in
set_input_delay  -min 1.0 -clock clk $sync_in

# ---- outputs: the receiving logic needs 40 % of the period ----
set outs [list [get_ports tx_full] [get_ports rx_data*] [get_ports rx_empty] [get_ports txd] \
               [get_ports frame_err] [get_ports parity_err] [get_ports rx_overflow]]
set_output_delay -max 8.0 -clock clk $outs
set_output_delay -min 0.0 -clock clk $outs

# ---- asynchronous inputs ----
# rxd comes from another chip with its own clock: it has no timing relation to clk.
# It goes straight into the 2-flop synchronizer in uart_rx (r1, r2), so we tell STA
# not to time it. (Metastability is handled by the synchronizer, not by STA.)
set_false_path -from [get_ports rxd]
# rst_n: asserted asynchronously, so its assertion is not timed. Its deassertion
# should come from a reset synchronizer (P5.2 cdc_reset_sync); with one in place you
# would time recovery/removal on the synchronizer output instead of false-pathing it.
set_false_path -from [get_ports rst_n]

# ---- drive / load (typical values for a block-level run) ----
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 [all_inputs]
set_load 0.02 [all_outputs]
