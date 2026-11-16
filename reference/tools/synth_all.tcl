# Synthesize every reference design with Yosys and print one cell-count table.
#   cd reference && yosys -c tools/synth_all.tcl          (writes logs/synth_table.txt too)
# Generic gates (Yosys internal cell library), not a real standard-cell library:
# compare designs with each other, not with a foundry area report.
yosys -import

# name  top  {files}  {chparam settings}
set designs {
  {stopwatch     stopwatch     {mini4-stopwatch/rtl/seg7.v mini4-stopwatch/rtl/stopwatch.v} {}}
  {counter       counter       {p0.1-counter/counter.v} {}}
  {alu8          alu8          {p1.1-alu/rtl/adders.v p1.1-alu/rtl/cmp_shift.v p1.1-alu/rtl/alu8.v} {}}
  {rca4          rca           {p1.1-alu/rtl/adders.v} {N 4}}
  {cla4          cla4          {p1.1-alu/rtl/adders.v} {}}
  {lfsr8         lfsr8         {p1.2-sequential/rtl/counters.v} {}}
  {debounce      debounce      {p1.2-sequential/rtl/debounce.v} {}}
  {det1011_bin   det_mealy_ov  {p1.3-fsm/rtl/det1011.v} {ONEHOT 0}}
  {det1011_1hot  det_mealy_ov  {p1.3-fsm/rtl/det1011.v} {ONEHOT 1}}
  {traffic       traffic       {p1.3-fsm/rtl/traffic.v} {}}
  {vending       vending       {p1.3-fsm/rtl/vending.v} {}}
  {sync_fifo16   sync_fifo     {p1.4-fifo/rtl/sync_fifo.v} {}}
  {async_fifo16  async_fifo    {p1.4-fifo/rtl/sync2.v p1.4-fifo/rtl/async_fifo.v} {}}
  {uart_top      uart_top      {p1.5-uart/rtl/baud_gen.v p1.5-uart/rtl/uart_tx.v p1.5-uart/rtl/uart_rx.v p1.5-uart/rtl/sync_fifo.v p1.5-uart/rtl/uart_top.v} {}}
  {spi_slave     spi_slave     {p1.6-spi-i2c/rtl/spi_slave.v} {}}
  {i2c_master    i2c_master    {p1.6-spi-i2c/rtl/i2c_master.v} {}}
  {apb_regs      apb_regs      {p2.4-apb-regblock/rtl/apb_regs.v} {}}
  {axil_regs     axil_regs     {p3.3-axi4lite/rtl/axil_regs.v} {}}
  {axi4_mem      axi4_mem      {p3.3-axi4lite/axi4-bursts/rtl/axi4_mem.v} {}}
  {rv32i_single  rv32i_single  {p4-rv32i/rtl/rv_alu.v p4-rv32i/rtl/rv_regfile.v p4-rv32i/rtl/rv_immgen.v p4-rv32i/rtl/rv_branch.v p4-rv32i/rtl/rv_decoder.v p4-rv32i/rtl/rv_lsu.v p4-rv32i/rtl/rv32i_single.v} {}}
  {rv32i_pipe    rv32i_pipe    {p4-rv32i/rtl/rv_alu.v p4-rv32i/rtl/rv_regfile.v p4-rv32i/rtl/rv_immgen.v p4-rv32i/rtl/rv_branch.v p4-rv32i/rtl/rv_decoder.v p4-rv32i/rtl/rv_lsu.v p4-rv32i/rtl/rv32i_pipe.v} {}}
  {cdc_handshake cdc_handshake {p5.2-cdc-sta/rtl/cdc_lib.v} {}}
  {rr_arbiter4   rr_arbiter    {p5.5-interview-rtl/rtl/rr_arbiter.v} {}}
  {skid_buffer   skid_buffer   {p5.5-interview-rtl/rtl/skid_buffer.v} {}}
  {systolic_4x4  systolic_top  {p5.7-systolic-int8/rtl/pe.v p5.7-systolic-int8/rtl/systolic_array.v p5.7-systolic-int8/rtl/systolic_top.v} {N 4}}
}

file mkdir logs
set out [open logs/synth_table.txt w]
set hdr [format "%-14s %8s %8s %8s" design cells flops "logic"]
puts $hdr; puts $out $hdr

foreach d $designs {
  lassign $d name top files params
  set missing 0
  foreach f $files { if {![file exists $f]} { set missing 1 } }
  if {$missing} { puts [format "%-14s %s" $name "(files not found, skipped)"]; continue }
  design -reset
  foreach f $files { read_verilog -I p4-rv32i/rtl $f }
  foreach {p v} $params { chparam -set $p $v $top }
  synth -flatten -top $top
  tee -q -o logs/synth_$name.stat stat
  # pull totals out of the stat report
  set fh [open logs/synth_$name.stat r]; set txt [read $fh]; close $fh
  regexp {Number of cells:\s+(\d+)} $txt -> cells
  set flops 0
  foreach {m n} [regexp -all -inline {\$_[A-Z]*DFF[A-Z0-9_]*\s+(\d+)} $txt] { incr flops $n }
  set line [format "%-14s %8d %8d %8d" $name $cells $flops [expr {$cells - $flops}]]
  puts $line; puts $out $line
}
close $out
