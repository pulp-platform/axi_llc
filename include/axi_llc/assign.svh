// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Nicole Narr <narrn@ethz.ch>
// - Christopher Reinwardt <creinwar@ethz.ch>
// Date:   17.11.2022

// Macros to connect AXI_LLC config registers

`ifndef AXI_LLC_ASSIGN_SVH_
`define AXI_LLC_ASSIGN_SVH_

// Assign the regtool RegBus 32-bit HW2REG _low, _high and enable signals from the
// 64-bit d_struct member with the same name
`define AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, member) \
    assign regbus.member``_low.d = d_struct.member; \
    assign regbus.member``_low.de = d_struct.member``_en; \
    assign regbus.member``_high.d = d_struct.member >> 32; \
    assign regbus.member``_high.de = d_struct.member``_en;

// Assign the regtool RegBus HW2REG struct from a d_struct
`define AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D(regbus, d_struct)                     \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_spm)        \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush)      \
    assign regbus.commit_cfg.d = d_struct.commit_cfg;                           \
    assign regbus.commit_cfg.de = d_struct.commit_cfg_en;                       \
    assign regbus.commit_partition_cfg.d = d_struct.commit_partition_cfg;       \
    assign regbus.commit_partition_cfg.de = d_struct.commit_partition_cfg_en;   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed)        \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, bist_out)       \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, set_asso)       \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, num_lines)      \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, num_blocks)     \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, version)        \
    assign regbus.bist_status.d = d_struct.bist_status_done;                    \
    assign regbus.bist_status.de = d_struct.bist_status_en;                     \
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/  \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush_set0) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush_set1) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush_set2) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush_set3) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush_set4) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush_set5) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush_set6) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush_set7) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition0) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition1) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition2) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition3) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition4) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition5) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition6) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition7) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition8) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition9) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition10) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition11) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition12) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition13) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition14) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition15) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition16) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition17) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition18) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition19) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition20) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition21) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition22) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition23) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition24) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition25) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition26) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition27) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition28) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition29) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition30) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition31) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition32) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition33) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition34) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition35) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition36) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition37) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition38) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition39) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition40) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition41) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition42) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition43) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition44) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition45) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition46) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition47) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition48) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition49) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition50) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition51) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition52) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition53) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition54) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition55) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition56) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition57) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition58) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition59) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition60) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition61) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition62) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition63) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition64) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition65) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition66) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition67) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition68) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition69) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition70) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition71) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition72) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition73) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed_set0)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed_set1)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed_set2)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed_set3)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed_set4)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed_set5)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed_set6)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed_set7)
/******************************************************************************************************************************/  

// Assign the 64-bit q_struct values from the corresponding 32-bit _low and _high
// REG2HW signals
`define AXI_LLC_ASSIGN_REGS_Q_FROM_REGBUS(q_struct, regbus)                         \
    assign q_struct.cfg_spm = {regbus.cfg_spm_high.q, regbus.cfg_spm_low.q};        \
    assign q_struct.cfg_flush = {regbus.cfg_flush_high.q, regbus.cfg_flush_low.q};  \
    assign q_struct.commit_cfg = regbus.commit_cfg.q;                               \
    assign q_struct.commit_partition_cfg = regbus.commit_partition_cfg.q;           \
    assign q_struct.flushed = {regbus.flushed_high.q, regbus.flushed_low.q};        \
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/  \
    assign q_struct.flushed_set0 = {regbus.flushed_set0_high.q, regbus.flushed_set0_low.q}; \
    assign q_struct.flushed_set1 = {regbus.flushed_set1_high.q, regbus.flushed_set1_low.q}; \
    assign q_struct.flushed_set2 = {regbus.flushed_set2_high.q, regbus.flushed_set2_low.q}; \
    assign q_struct.flushed_set3 = {regbus.flushed_set3_high.q, regbus.flushed_set3_low.q}; \
    assign q_struct.flushed_set4 = {regbus.flushed_set4_high.q, regbus.flushed_set4_low.q}; \
    assign q_struct.flushed_set5 = {regbus.flushed_set5_high.q, regbus.flushed_set5_low.q}; \
    assign q_struct.flushed_set6 = {regbus.flushed_set6_high.q, regbus.flushed_set6_low.q}; \
    assign q_struct.flushed_set7 = {regbus.flushed_set7_high.q, regbus.flushed_set7_low.q}; \
    assign q_struct.cfg_set_partition0 = {regbus.cfg_set_partition0_high.q, regbus.cfg_set_partition0_low.q}; \
    assign q_struct.cfg_set_partition1 = {regbus.cfg_set_partition1_high.q, regbus.cfg_set_partition1_low.q}; \
    assign q_struct.cfg_set_partition2 = {regbus.cfg_set_partition2_high.q, regbus.cfg_set_partition2_low.q}; \
    assign q_struct.cfg_set_partition3 = {regbus.cfg_set_partition3_high.q, regbus.cfg_set_partition3_low.q}; \
    assign q_struct.cfg_set_partition4 = {regbus.cfg_set_partition4_high.q, regbus.cfg_set_partition4_low.q}; \
    assign q_struct.cfg_set_partition5 = {regbus.cfg_set_partition5_high.q, regbus.cfg_set_partition5_low.q}; \
    assign q_struct.cfg_set_partition6 = {regbus.cfg_set_partition6_high.q, regbus.cfg_set_partition6_low.q}; \
    assign q_struct.cfg_set_partition7 = {regbus.cfg_set_partition7_high.q, regbus.cfg_set_partition7_low.q}; \
    assign q_struct.cfg_set_partition8 = {regbus.cfg_set_partition8_high.q, regbus.cfg_set_partition8_low.q}; \
    assign q_struct.cfg_set_partition9 = {regbus.cfg_set_partition9_high.q, regbus.cfg_set_partition9_low.q}; \
    assign q_struct.cfg_set_partition10 = {regbus.cfg_set_partition10_high.q, regbus.cfg_set_partition10_low.q}; \
    assign q_struct.cfg_set_partition11 = {regbus.cfg_set_partition11_high.q, regbus.cfg_set_partition11_low.q}; \
    assign q_struct.cfg_set_partition12 = {regbus.cfg_set_partition12_high.q, regbus.cfg_set_partition12_low.q}; \
    assign q_struct.cfg_set_partition13 = {regbus.cfg_set_partition13_high.q, regbus.cfg_set_partition13_low.q}; \
    assign q_struct.cfg_set_partition14 = {regbus.cfg_set_partition14_high.q, regbus.cfg_set_partition14_low.q}; \
    assign q_struct.cfg_set_partition15 = {regbus.cfg_set_partition15_high.q, regbus.cfg_set_partition15_low.q}; \
    assign q_struct.cfg_set_partition16 = {regbus.cfg_set_partition16_high.q, regbus.cfg_set_partition16_low.q}; \
    assign q_struct.cfg_set_partition17 = {regbus.cfg_set_partition17_high.q, regbus.cfg_set_partition17_low.q}; \
    assign q_struct.cfg_set_partition18 = {regbus.cfg_set_partition18_high.q, regbus.cfg_set_partition18_low.q}; \
    assign q_struct.cfg_set_partition19 = {regbus.cfg_set_partition19_high.q, regbus.cfg_set_partition19_low.q}; \
    assign q_struct.cfg_set_partition20 = {regbus.cfg_set_partition20_high.q, regbus.cfg_set_partition20_low.q}; \
    assign q_struct.cfg_set_partition21 = {regbus.cfg_set_partition21_high.q, regbus.cfg_set_partition21_low.q}; \
    assign q_struct.cfg_set_partition22 = {regbus.cfg_set_partition22_high.q, regbus.cfg_set_partition22_low.q}; \
    assign q_struct.cfg_set_partition23 = {regbus.cfg_set_partition23_high.q, regbus.cfg_set_partition23_low.q}; \
    assign q_struct.cfg_set_partition24 = {regbus.cfg_set_partition24_high.q, regbus.cfg_set_partition24_low.q}; \
    assign q_struct.cfg_set_partition25 = {regbus.cfg_set_partition25_high.q, regbus.cfg_set_partition25_low.q}; \
    assign q_struct.cfg_set_partition26 = {regbus.cfg_set_partition26_high.q, regbus.cfg_set_partition26_low.q}; \
    assign q_struct.cfg_set_partition27 = {regbus.cfg_set_partition27_high.q, regbus.cfg_set_partition27_low.q}; \
    assign q_struct.cfg_set_partition28 = {regbus.cfg_set_partition28_high.q, regbus.cfg_set_partition28_low.q}; \
    assign q_struct.cfg_set_partition29 = {regbus.cfg_set_partition29_high.q, regbus.cfg_set_partition29_low.q}; \
    assign q_struct.cfg_set_partition30 = {regbus.cfg_set_partition30_high.q, regbus.cfg_set_partition30_low.q}; \
    assign q_struct.cfg_set_partition31 = {regbus.cfg_set_partition31_high.q, regbus.cfg_set_partition31_low.q}; \
    assign q_struct.cfg_set_partition32 = {regbus.cfg_set_partition32_high.q, regbus.cfg_set_partition32_low.q}; \
    assign q_struct.cfg_set_partition33 = {regbus.cfg_set_partition33_high.q, regbus.cfg_set_partition33_low.q}; \
    assign q_struct.cfg_set_partition34 = {regbus.cfg_set_partition34_high.q, regbus.cfg_set_partition34_low.q}; \
    assign q_struct.cfg_set_partition35 = {regbus.cfg_set_partition35_high.q, regbus.cfg_set_partition35_low.q}; \
    assign q_struct.cfg_set_partition36 = {regbus.cfg_set_partition36_high.q, regbus.cfg_set_partition36_low.q}; \
    assign q_struct.cfg_set_partition37 = {regbus.cfg_set_partition37_high.q, regbus.cfg_set_partition37_low.q}; \
    assign q_struct.cfg_set_partition38 = {regbus.cfg_set_partition38_high.q, regbus.cfg_set_partition38_low.q}; \
    assign q_struct.cfg_set_partition39 = {regbus.cfg_set_partition39_high.q, regbus.cfg_set_partition39_low.q}; \
    assign q_struct.cfg_set_partition40 = {regbus.cfg_set_partition40_high.q, regbus.cfg_set_partition40_low.q}; \
    assign q_struct.cfg_set_partition41 = {regbus.cfg_set_partition41_high.q, regbus.cfg_set_partition41_low.q}; \
    assign q_struct.cfg_set_partition42 = {regbus.cfg_set_partition42_high.q, regbus.cfg_set_partition42_low.q}; \
    assign q_struct.cfg_set_partition43 = {regbus.cfg_set_partition43_high.q, regbus.cfg_set_partition43_low.q}; \
    assign q_struct.cfg_set_partition44 = {regbus.cfg_set_partition44_high.q, regbus.cfg_set_partition44_low.q}; \
    assign q_struct.cfg_set_partition45 = {regbus.cfg_set_partition45_high.q, regbus.cfg_set_partition45_low.q}; \
    assign q_struct.cfg_set_partition46 = {regbus.cfg_set_partition46_high.q, regbus.cfg_set_partition46_low.q}; \
    assign q_struct.cfg_set_partition47 = {regbus.cfg_set_partition47_high.q, regbus.cfg_set_partition47_low.q}; \
    assign q_struct.cfg_set_partition48 = {regbus.cfg_set_partition48_high.q, regbus.cfg_set_partition48_low.q}; \
    assign q_struct.cfg_set_partition49 = {regbus.cfg_set_partition49_high.q, regbus.cfg_set_partition49_low.q}; \
    assign q_struct.cfg_set_partition50 = {regbus.cfg_set_partition50_high.q, regbus.cfg_set_partition50_low.q}; \
    assign q_struct.cfg_set_partition51 = {regbus.cfg_set_partition51_high.q, regbus.cfg_set_partition51_low.q}; \
    assign q_struct.cfg_set_partition52 = {regbus.cfg_set_partition52_high.q, regbus.cfg_set_partition52_low.q}; \
    assign q_struct.cfg_set_partition53 = {regbus.cfg_set_partition53_high.q, regbus.cfg_set_partition53_low.q}; \
    assign q_struct.cfg_set_partition54 = {regbus.cfg_set_partition54_high.q, regbus.cfg_set_partition54_low.q}; \
    assign q_struct.cfg_set_partition55 = {regbus.cfg_set_partition55_high.q, regbus.cfg_set_partition55_low.q}; \
    assign q_struct.cfg_set_partition56 = {regbus.cfg_set_partition56_high.q, regbus.cfg_set_partition56_low.q}; \
    assign q_struct.cfg_set_partition57 = {regbus.cfg_set_partition57_high.q, regbus.cfg_set_partition57_low.q}; \
    assign q_struct.cfg_set_partition58 = {regbus.cfg_set_partition58_high.q, regbus.cfg_set_partition58_low.q}; \
    assign q_struct.cfg_set_partition59 = {regbus.cfg_set_partition59_high.q, regbus.cfg_set_partition59_low.q}; \
    assign q_struct.cfg_set_partition60 = {regbus.cfg_set_partition60_high.q, regbus.cfg_set_partition60_low.q}; \
    assign q_struct.cfg_set_partition61 = {regbus.cfg_set_partition61_high.q, regbus.cfg_set_partition61_low.q}; \
    assign q_struct.cfg_set_partition62 = {regbus.cfg_set_partition62_high.q, regbus.cfg_set_partition62_low.q}; \
    assign q_struct.cfg_set_partition63 = {regbus.cfg_set_partition63_high.q, regbus.cfg_set_partition63_low.q}; \
    assign q_struct.cfg_set_partition64 = {regbus.cfg_set_partition64_high.q, regbus.cfg_set_partition64_low.q}; \
    assign q_struct.cfg_set_partition65 = {regbus.cfg_set_partition65_high.q, regbus.cfg_set_partition65_low.q}; \
    assign q_struct.cfg_set_partition66 = {regbus.cfg_set_partition66_high.q, regbus.cfg_set_partition66_low.q}; \
    assign q_struct.cfg_set_partition67 = {regbus.cfg_set_partition67_high.q, regbus.cfg_set_partition67_low.q}; \
    assign q_struct.cfg_set_partition68 = {regbus.cfg_set_partition68_high.q, regbus.cfg_set_partition68_low.q}; \
    assign q_struct.cfg_set_partition69 = {regbus.cfg_set_partition69_high.q, regbus.cfg_set_partition69_low.q}; \
    assign q_struct.cfg_set_partition70 = {regbus.cfg_set_partition70_high.q, regbus.cfg_set_partition70_low.q}; \
    assign q_struct.cfg_set_partition71 = {regbus.cfg_set_partition71_high.q, regbus.cfg_set_partition71_low.q}; \
    assign q_struct.cfg_set_partition72 = {regbus.cfg_set_partition72_high.q, regbus.cfg_set_partition72_low.q}; \
    assign q_struct.cfg_set_partition73 = {regbus.cfg_set_partition73_high.q, regbus.cfg_set_partition73_low.q}; \
    assign q_struct.cfg_flush_set0 = {regbus.cfg_flush_set0_high.q, regbus.cfg_flush_set0_low.q}; \
    assign q_struct.cfg_flush_set1 = {regbus.cfg_flush_set1_high.q, regbus.cfg_flush_set1_low.q}; \
    assign q_struct.cfg_flush_set2 = {regbus.cfg_flush_set2_high.q, regbus.cfg_flush_set2_low.q}; \
    assign q_struct.cfg_flush_set3 = {regbus.cfg_flush_set3_high.q, regbus.cfg_flush_set3_low.q}; \
    assign q_struct.cfg_flush_set4 = {regbus.cfg_flush_set4_high.q, regbus.cfg_flush_set4_low.q}; \
    assign q_struct.cfg_flush_set5 = {regbus.cfg_flush_set5_high.q, regbus.cfg_flush_set5_low.q}; \
    assign q_struct.cfg_flush_set6 = {regbus.cfg_flush_set6_high.q, regbus.cfg_flush_set6_low.q}; \
    assign q_struct.cfg_flush_set7 = {regbus.cfg_flush_set7_high.q, regbus.cfg_flush_set7_low.q};
/******************************************************************************************************************************/  

`endif