# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Philippe Sauter <phsauter@iis.ee.ethz.ch>

set regression_failed 0

proc run_id_width_test {name id_width lookup_bits} {
  global regression_failed

  puts "================================================================"
  puts "= Running AXI ID configuration: width=$id_width lookup=$lookup_bits"
  puts "================================================================"

  set transcript_name "logs/axi_llc.id_width_${name}.vsim.log"
  file delete -force $transcript_name
  transcript file $transcript_name

  vsim -t 1ps -voptargs=+acc -sv_seed 1 \
      -GTbAxiIdWidthFull=$id_width \
      -GTbAxiIdLookupBits=$lookup_bits \
      -wlf "logs/axi_llc.id_width_${name}.wlf" \
      tb_axi_llc

  onfinish stop
  set StdArithNoWarnings 1
  set NumericStdNoWarnings 1
  run 100 us
  quit -sim

  transcript file {}
  set transcript_fd [open $transcript_name r]
  set transcript_data [read $transcript_fd]
  close $transcript_fd
  if {[regexp -line {^# \*\* (Error|Fatal)( \([^)]*\))?:} $transcript_data]} {
    puts "Regression errors detected in $transcript_name"
    set regression_failed 1
  }
}

run_id_width_test width1_lookup1 1 1
run_id_width_test width2_lookup1 2 1
run_id_width_test width6_lookup2 6 2
run_id_width_test width6_lookup4 6 4

quit -code $regression_failed -f
