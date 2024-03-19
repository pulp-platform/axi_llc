# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Michael Rogenmoser (michaero@iis.ee.ethz.ch)

# transcript quietly

set script_base_path [file dirname [file normalize [info script]]]/InjectaFault/scripts

set verbosity            0
set log_injections       1
set seed             12345
set print_statistics     1

# set inject_start_time 6500000ns
set inject_start_time 10000ns
set inject_stop_time 0
set injection_clock "/tb_axi_llc/clk"
set injection_clock_trigger 0
set fault_period 1
set rand_initial_injection_phase 0
set max_num_fault_inject 0
set signal_fault_duration 20ns
set register_fault_duration 0ns

set allow_multi_bit_upset 1
set use_bitwidth_as_weight 1
set check_core_output_modification 0
set check_core_next_state_modification 0
set reg_to_sig_ratio 1

source $script_base_path/../../extract_nets.tcl

set inject_register_netlist []
# set inject_signals_netlist [find nets -out [base_path 0]/*]
set inject_signals_netlist [get_core_state_nets]
set output_netlist [get_core_output_nets]
set next_state_netlist []
set assertion_disable_list []

source $script_base_path/inject_fault.tcl
