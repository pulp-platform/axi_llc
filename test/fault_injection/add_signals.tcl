proc base_path {} {return "/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw"} 
# proc base_path {} {return "/tb_cheshire_soc/fix/dut/gen_llc/i_llc/i_axi_llc_top_raw"} 


for {set way 0} {$way < [regsub ".*'h" [examine sim:/tb_axi_llc/TbSetAssociativity] "0x"]} {incr way} {
    for {set bank_tag 0} {$bank_tag < [regsub ".*'h" [examine sim:[base_path]/gen_sram_macros\[${way}\]/i_tag_sram/NumBanks] "0x"]} {incr bank_tag} {

        eval "add wave -position insertpoint {sim:[base_path]/gen_sram_macros\\\[${way}\\\]/i_tag_sram/gen_ecc_sram/gen_data_split[$bank_tag]/i_ecc_sram/single_error_o}"

    }

    for {set bank_dat 0} {$bank_dat < [regsub ".*'h" [examine sim:[base_path]/gen_sram_macros\[${way}\]/i_data_sram/NumBanks] "0x"]} {incr bank_dat} {

        eval "add wave -position insertpoint {sim:[base_path]/gen_sram_macros\\\[${way}\\\]/i_data_sram/gen_ecc_sram/gen_data_split[$bank_dat]/i_ecc_sram/single_error_o}"

    }
}

for {set way 0} {$way < [regsub ".*'h" [examine sim:/tb_axi_llc/TbSetAssociativity] "0x"]} {incr way} {
    for {set bank_tag 0} {$bank_tag < [regsub ".*'h" [examine sim:[base_path]/gen_sram_macros\[${way}\]/i_tag_sram/NumBanks] "0x"]} {incr bank_tag} {

        eval "add wave -position insertpoint {sim:[base_path]/gen_sram_macros\\\[${way}\\\]/i_tag_sram/gen_ecc_sram/gen_data_split[$bank_tag]/i_ecc_sram/multi_error_o}"
        
    }

    for {set bank_dat 0} {$bank_dat < [regsub ".*'h" [examine sim:[base_path]/gen_sram_macros\[${way}\]/i_data_sram/NumBanks] "0x"]} {incr bank_dat} {

        eval "add wave -position insertpoint {sim:[base_path]/gen_sram_macros\\\[${way}\\\]/i_data_sram/gen_ecc_sram/gen_data_split[$bank_dat]/i_ecc_sram/multi_error_o}"

    }
}

# for {set way 0} {$way < [regsub ".*'h" [examine sim:/tb_axi_llc/TbSetAssociativity] "0x"]} {incr way} {
#     for {set bank_tag 0} {$bank_tag < [regsub ".*'h" [examine sim:[base_path]/gen_sram_macros\[${way}\]/i_tag_sram/NumBanks] "0x"]} {incr bank_tag} {
        
#         eval "add wave -position insertpoint {sim:[base_path]/gen_sram_macros\\\[${way}\\\]/i_tag_sram/gen_ecc_sram/gen_data_split[$bank_tag]/i_ecc_sram/scrub_uncorrectable_o}"

#     }

#     for {set bank_dat 0} {$bank_dat < [regsub ".*'h" [examine sim:[base_path]/gen_sram_macros\[${way}\]/i_data_sram/NumBanks] "0x"]} {incr bank_dat} {

#         eval "add wave -position insertpoint {sim:[base_path]/gen_sram_macros\\\[${way}\\\]/i_data_sram/gen_ecc_sram/gen_data_split[$bank_dat]/i_ecc_sram/scrub_uncorrectable_o}"

#     }
# }

# for {set way 0} {$way < [regsub ".*'h" [examine sim:/tb_axi_llc/TbSetAssociativity] "0x"]} {incr way} {
#     for {set bank_tag 0} {$bank_tag < [regsub ".*'h" [examine sim:[base_path]/gen_sram_macros\[${way}\]/i_tag_sram/NumBanks] "0x"]} {incr bank_tag} {
        
#         eval "add wave -position insertpoint {sim:[base_path]/gen_sram_macros\\\[${way}\\\]/i_tag_sram/gen_ecc_sram/gen_data_split[$bank_tag]/i_ecc_sram/scrubber_fix_o}"

#     }

#     for {set bank_dat 0} {$bank_dat < [regsub ".*'h" [examine sim:[base_path]/gen_sram_macros\[${way}\]/i_data_sram/NumBanks] "0x"]} {incr bank_dat} {

#         eval "add wave -position insertpoint {sim:[base_path]/gen_sram_macros\\\[${way}\\\]/i_data_sram/gen_ecc_sram/gen_data_split[$bank_dat]/i_ecc_sram/scrubber_fix_o}"
#     }
# }

add wave -position insertpoint sim:[base_path]/tag_ecc_info_o
add wave -position insertpoint sim:[base_path]/data_ecc_info_o
add wave -position insertpoint sim:[base_path]/axi_llc_events_o
