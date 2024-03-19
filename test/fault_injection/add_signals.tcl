for {set way 0} {$way < [regsub ".*'h" [examine sim:/tb_axi_llc/TbSetAssociativity] "0x"]} {incr way} {
    for {set bank_tag 0} {$bank_tag < [regsub ".*'h" [examine sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros[$way]/i_tag_store/NumBanks] "0x"]} {incr bank_tag} {

        eval "add wave -position insertpoint {sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros[$way]/i_tag_store/gen_data_split[$bank_tag]/i_ecc_sram/single_error_o}"

    }

    for {set bank_dat 0} {$bank_dat < [regsub ".*'h" [examine sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_llc_ways/gen_data_ways[$way]/i_data_way/i_data_sram/NumBanks] "0x"]} {incr bank_dat} {

        eval "add wave -position insertpoint {sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_llc_ways/gen_data_ways[$way]/i_data_way/i_data_sram/gen_data_split[$bank_dat]/i_ecc_sram/single_error_o}"

    }
}

for {set way 0} {$way < [regsub ".*'h" [examine sim:/tb_axi_llc/TbSetAssociativity] "0x"]} {incr way} {
    for {set bank_tag 0} {$bank_tag < [regsub ".*'h" [examine sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros[$way]/i_tag_store/NumBanks] "0x"]} {incr bank_tag} {

        eval "add wave -position insertpoint {sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros[$way]/i_tag_store/gen_data_split[$bank_tag]/i_ecc_sram/multi_error_o}"
        
    }

    for {set bank_dat 0} {$bank_dat < [regsub ".*'h" [examine sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_llc_ways/gen_data_ways[$way]/i_data_way/i_data_sram/NumBanks] "0x"]} {incr bank_dat} {

        eval "add wave -position insertpoint {sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_llc_ways/gen_data_ways[$way]/i_data_way/i_data_sram/gen_data_split[$bank_dat]/i_ecc_sram/multi_error_o}"

    }
}

for {set way 0} {$way < [regsub ".*'h" [examine sim:/tb_axi_llc/TbSetAssociativity] "0x"]} {incr way} {
    for {set bank_tag 0} {$bank_tag < [regsub ".*'h" [examine sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros[$way]/i_tag_store/NumBanks] "0x"]} {incr bank_tag} {
        
        eval "add wave -position insertpoint {sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros[$way]/i_tag_store/gen_data_split[$bank_tag]/i_ecc_sram/scrub_uncorrectable_o}"

    }

    for {set bank_dat 0} {$bank_dat < [regsub ".*'h" [examine sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_llc_ways/gen_data_ways[$way]/i_data_way/i_data_sram/NumBanks] "0x"]} {incr bank_dat} {

        eval "add wave -position insertpoint {sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_llc_ways/gen_data_ways[$way]/i_data_way/i_data_sram/gen_data_split[$bank_dat]/i_ecc_sram/scrub_uncorrectable_o}"

    }
}

for {set way 0} {$way < [regsub ".*'h" [examine sim:/tb_axi_llc/TbSetAssociativity] "0x"]} {incr way} {
    for {set bank_tag 0} {$bank_tag < [regsub ".*'h" [examine sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros[$way]/i_tag_store/NumBanks] "0x"]} {incr bank_tag} {
        
        eval "add wave -position insertpoint {sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_hit_miss_unit/i_tag_store/gen_tag_macros[$way]/i_tag_store/gen_data_split[$bank_tag]/i_ecc_sram/scrubber_fix_o}"

    }

    for {set bank_dat 0} {$bank_dat < [regsub ".*'h" [examine sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_llc_ways/gen_data_ways[$way]/i_data_way/i_data_sram/NumBanks] "0x"]} {incr bank_dat} {

        eval "add wave -position insertpoint {sim:/tb_axi_llc/i_axi_llc_dut/i_axi_llc_top_raw/i_llc_ways/gen_data_ways[$way]/i_data_way/i_data_sram/gen_data_split[$bank_dat]/i_ecc_sram/scrubber_fix_o}"
    }
}
