# This file is used to automatecally generate 'assign.svh'

import math
import sys
# all variables below are just for verification
RegWidth    = int(sys.argv[1]) # 64 Same as "RegWidth" in sv
NumLines    = int(sys.argv[2]) # 256 Same as "Sfg.NumLines in sv
MaxThread   = int(sys.argv[3]) # 256 Same as "MaxThread" in sv
IndexLength = math.ceil(math.log2(NumLines))  # Same as "Cfg.IndexLength" in sv
num_setflushreg = math.ceil(NumLines / RegWidth)
num_parreg  = math.ceil(MaxThread / math.floor(RegWidth / IndexLength))  # The number of configuration registers used for set partitioning.
valid_reg_bit = math.floor(RegWidth / IndexLength) * IndexLength

with open('include/axi_llc/assign.svh', 'w') as f:
    f.write("// Copyright 2022 ETH Zurich and University of Bologna.\n\
// Solderpad Hardware License, Version 0.51, see LICENSE for details.\n\
// SPDX-License-Identifier: SHL-0.51\n\
//\n\
// Authors:\n\
// - Nicole Narr <narrn@ethz.ch>\n\
// - Christopher Reinwardt <creinwar@ethz.ch>\n\
// Date:   17.11.2022\n\
\n\
// Macros to connect AXI_LLC config registers\n\
\n\
`ifndef AXI_LLC_ASSIGN_SVH_\n\
`define AXI_LLC_ASSIGN_SVH_\n\
\n\
// Assign the regtool RegBus 32-bit HW2REG _low, _high and enable signals from the\n\
// 64-bit d_struct member with the same name\n\
`define AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, member) \\\n\
    assign regbus.member``_low.d = d_struct.member; \\\n\
    assign regbus.member``_low.de = d_struct.member``_en; \\\n\
    assign regbus.member``_high.d = d_struct.member >> 32; \\\n\
    assign regbus.member``_high.de = d_struct.member``_en;\n\
\n\
// Assign the regtool RegBus HW2REG struct from a d_struct\n\
`define AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D(regbus, d_struct)                     \\\n\
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_spm)        \\\n\
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush)      \\\n\
    assign regbus.commit_cfg.d = d_struct.commit_cfg;                           \\\n\
    assign regbus.commit_cfg.de = d_struct.commit_cfg_en;                       \\\n\
    assign regbus.commit_partition_cfg.d = d_struct.commit_partition_cfg;       \\\n\
    assign regbus.commit_partition_cfg.de = d_struct.commit_partition_cfg_en;   \\\n\
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed)        \\\n\
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, bist_out)       \\\n\
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, set_asso)       \\\n\
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, num_lines)      \\\n\
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, num_blocks)     \\\n\
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, version)        \\\n\
    assign regbus.bist_status.d = d_struct.bist_status_done;                    \\\n\
    assign regbus.bist_status.de = d_struct.bist_status_en;                     \\\n\
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/  \\\n")

    for i in range(num_setflushreg):
        f.write(f'''    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush_set{i}) \\
''')

    for i in range(num_parreg):
        f.write(f'''    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition{i}) \\
''')

    for i in range(num_setflushreg):
        f.write(f'''    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed_set{i})''')
        if (i != num_setflushreg-1): 
            f.write('   \\\n')
        else: 
            f.write('\n')

    f.write("/******************************************************************************************************************************/  \n\
\n\
// Assign the 64-bit q_struct values from the corresponding 32-bit _low and _high\n\
// REG2HW signals\n\
`define AXI_LLC_ASSIGN_REGS_Q_FROM_REGBUS(q_struct, regbus)                         \\\n\
    assign q_struct.cfg_spm = {regbus.cfg_spm_high.q, regbus.cfg_spm_low.q};        \\\n\
    assign q_struct.cfg_flush = {regbus.cfg_flush_high.q, regbus.cfg_flush_low.q};  \\\n\
    assign q_struct.commit_cfg = regbus.commit_cfg.q;                               \\\n\
    assign q_struct.commit_partition_cfg = regbus.commit_partition_cfg.q;           \\\n\
    assign q_struct.flushed = {regbus.flushed_high.q, regbus.flushed_low.q};        \\\n\
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/  \\\n")

    for i in range(num_setflushreg):
        f.write(f'''    assign q_struct.flushed_set{i} = {{regbus.flushed_set{i}_high.q, regbus.flushed_set{i}_low.q}}; \\
''')
    for i in range(num_parreg):
        f.write(f'''    assign q_struct.cfg_set_partition{i} = {{regbus.cfg_set_partition{i}_high.q, regbus.cfg_set_partition{i}_low.q}}; \\
''')
    for i in range(num_setflushreg):
        f.write(f'''    assign q_struct.cfg_flush_set{i} = {{regbus.cfg_flush_set{i}_high.q, regbus.cfg_flush_set{i}_low.q}};''')
        if (i != num_setflushreg-1): 
            f.write(' \\\n')
        else: 
            f.write('\n')

    f.write("/******************************************************************************************************************************/  \n\
\n\
`endif")