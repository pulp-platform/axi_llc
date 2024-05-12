# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Michael Rogenmoser (michaero@iis.ee.ethz.ch)

# Description: This file is used to extract specific groups of nets from
#              Snitch, so they can be used in the fault injection script

# Source generic netlist extraction procs
source $script_base_path/extract_nets.tcl

# == Base Path of a Cluster Core ==
proc base_path {} {return "/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw"} 

# nets that would crash the simulation if flipped
lappend core_netlist_ignore *clk_i
lappend core_netlist_ignore *Clk_CI
lappend core_netlist_ignore *clk
lappend core_netlist_ignore *clk_ungated_i
lappend core_netlist_ignore *rst_ni
lappend core_netlist_ignore *rst_i
lappend core_netlist_ignore *rst_n
lappend core_netlist_ignore *rst
lappend core_netlist_ignore *Rst_RBI
lappend core_netlist_ignore *scan_cg_en_i
lappend core_netlist_ignore *testmode_i

# registers/memories:
# lappend core_netlist_ignore *_q
# lappend core_netlist_ignore *obi_pulp_adapter/ps TODOs

# debug
lappend core_netlist_ignore *tracer_i*

######################
#  Core Output Nets  #
######################
proc get_core_output_nets {} {
  set core_output_netlist [get_output_netlist [base_path]]
  lappend core_output_netlist [base_path]/mst_req_o
  lappend core_output_netlist [base_path]/slv_resp_o
  return [concat $core_output_netlist]
}


####################
#  State Netlists  #
####################

proc get_core_state_nets {} {
  set state_list []

  for {set way 0} {$way < [regsub ".*'h" [examine sim:/tb_axi_llc/TbSetAssociativity] "0x"]} {incr way} {
    for {set bank_tag 0} {$bank_tag < [regsub ".*'h" [examine sim:[base_path]/gen_sram_macros\[${way}\]/i_tag_sram/NumBanks] "0x"]} {incr bank_tag} {

      # for {set i 0} {$i < [regsub ".*'h" [examine sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros\[${way}\]/i_tag_store/gen_data_split\[${bank_tag}\]/i_ecc_sram/BankSize] "0x"]} {incr i} {
        
        lappend state_list [base_path]/gen_sram_macros\\\[${way}\\\]/i_tag_sram/gen_ecc_sram/gen_data_split\\\[${bank_tag}\\\]/i_ecc_sram/i_bank/sram

      # }
    }


    for {set bank_dat 0} {$bank_dat < [regsub ".*'h" [examine sim:[base_path]/gen_sram_macros\[${way}\]/i_data_sram/NumBanks] "0x"]} {incr bank_dat} {

      # for {set i 0} {$i < [regsub ".*'h" [examine sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_llc_ways/gen_data_ways\[${way}\]/i_data_way/i_data_sram/gen_data_split\[${bank_dat}\]/i_ecc_sram/BankSize] "0x"]} {incr i} {

        lappend state_list [base_path]/gen_sram_macros\\\[${way}\\\]/i_data_sram/gen_ecc_sram/gen_data_split\\\[${bank_dat}\\\]/i_ecc_sram/i_bank/sram

      # }
    }
  }

  return [extract_netlists [subst $state_list] 1]
}

##############################
#  Get all nets from a core  #
##############################

proc get_all_core_nets {} {
  set core_path [base_path]
  # set core_netlist_ignore_full [concat $::core_netlist_ignore [get_core_state_nets]]
  set all_signals [extract_all_nets_recursive_filtered $core_path $::core_netlist_ignore]
  # set state_signals [get_core_state_nets]
  # set netlist_filtered {}
  # foreach signal $all_signals {
  #   set sig_unpacked [lindex $signal 0]
  #   # echo $sig_unpacked
  #   foreach state_sig $state_signals {
  #     if {[string first $state_sig $sig_unpacked] == -1} {
  #       lappend netlist_filtered $sig_unpacked
  #     }  
  #   }
  # }
  return $all_signals
}