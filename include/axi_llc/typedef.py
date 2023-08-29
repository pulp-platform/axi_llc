# This file is used to automatecally generate 'typedef.svh'

import math
import sys
# all variables below are just for verification
RegWidth    = int(sys.argv[1]) # 64 Same as "RegWidth" in sv
NumLines    = int(sys.argv[2]) # 256 Same as "Sfg.NumLines in sv
MaxThread   = int(sys.argv[3]) # 256 Same as "MaxThread" in sv
CachePartition = int(sys.argv[4]) # Signals whether cache partitioning is enabled or disabled, 1 means "enable"
IndexLength = math.ceil(math.log2(NumLines))  # Same as "Cfg.IndexLength" in sv
num_setflushreg = math.ceil(NumLines / RegWidth)
num_parreg  = math.ceil(MaxThread / math.floor(RegWidth / IndexLength))  # The number of configuration registers used for set partitioning.
valid_reg_bit = math.floor(RegWidth / IndexLength) * IndexLength

with open('include/axi_llc/typedef.svh', 'w') as f:
    f.write("// Copyright 2022 ETH Zurich and University of Bologna.\n\
// Solderpad Hardware License, Version 0.51, see LICENSE for details.\n\
// SPDX-License-Identifier: SHL-0.51\n\
//\n\
// Authors:\n\
// - Nicole Narr <narrn@ethz.ch>\n\
// - Christopher Reinwardt <creinwar@ethz.ch>\n\
// Date:   17.11.2022\n\
\n\
// Macros to define AXI_LLC types and structs\n\
\n\
`ifndef AXI_LLC_TYPEDEF_SVH_\n\
`define AXI_LLC_TYPEDEF_SVH_\n\
\n\
////////////////////////////////////////////////////////////////////////////////////////////////////\n\
// Configuration registers type definitions\n\
//\n\
// HW -> Registers\n\
//\n\
// Fields\n\
// * cfg_spm:       Data to be written into the SPM config register\n\
// * cfg_spm_en:    SPM config register write enable\n\
// * cfg_flush:     Data to be written into the flush config register\n\
// * cfg_flush_en:  Flush config register write enable\n\
// * commit_cfg:    Configuration commit register - Cleared by hardware\n\
// * commit_cfg_en: Configuration commit register write enable\n\
// * flushed:       Flush completion info register\n\
// * flushed_en:    Flush completion info register write enable\n\
// * bist_out:      Result of the BIST\n\
// * bist_out_en:   BIST info write enable\n\
// * set_asso:      Set associativity info register\n\
// * set_asso_en:   Set associativity info register write enable\n\
// * num_lines:     Amount of lines info register\n\
// * num_lines_en:  Amount of lines info register write enable\n\
// * num_blocks:    Amount of blocks info register\n\
// * num_blocks_en: Amount of blocks info register write enable\n\
// * version:       Version register\n\
// * version_en:    Version register write enable\n\
`define AXI_LLC_TYPEDEF_REGS_D_T(cfg_regs_d_t, reg_data_t, set_asso_t)  \\\n\
  typedef struct packed {                                               \\\n\
    set_asso_t  cfg_spm;                                                \\\n\
    logic       cfg_spm_en;                                             \\\n\
    set_asso_t  cfg_flush;                                              \\\n\
    logic       cfg_flush_en;                                           \\\n\
    logic       commit_cfg;                                             \\\n\
    logic       commit_cfg_en;                                          \\\n")

    if CachePartition != 0: 
        f.write("\
    logic       commit_partition_cfg;                                   \\\n\
    logic       commit_partition_cfg_en;                                \\\n")

    f.write("\
    set_asso_t  flushed;                                                \\\n\
    logic       flushed_en;                                             \\\n\
    set_asso_t  bist_out;                                               \\\n\
    logic       bist_out_en;                                            \\\n\
    logic       bist_status_done;                                       \\\n\
    logic       bist_status_en;                                         \\\n\
    reg_data_t  set_asso;                                               \\\n\
    logic       set_asso_en;                                            \\\n\
    reg_data_t  num_lines;                                              \\\n\
    logic       num_lines_en;                                           \\\n\
    reg_data_t  num_blocks;                                             \\\n\
    logic       num_blocks_en;                                          \\\n\
    reg_data_t  version;                                                \\\n\
    logic       version_en;                                             \\\n")

    if CachePartition != 0: 
        f.write("\
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/  \\\n\
    reg_data_t  cfg_flush_thread;                                       \\\n\
    logic       cfg_flush_thread_en;                                    \\\n\
")

        (f'''    reg_data_t [{num_parreg-1}:0] cfg_set_partition;                                     \\
    logic [{num_parreg-1}:0]      cfg_set_partition_en;                                  \\
''')

        f.write(f'''    reg_data_t [{num_setflushreg-1}:0] flushed_set;                                           \\
    logic [{num_setflushreg-1}:0]      flushed_set_en;                                        \\
''')

        f.write("/******************************************************************************************************************************/  \\\n")
    f.write("  } cfg_regs_d_t;\n\
\n\
// Registers -> HW\n\
//\n\
// Fields\n\
// * cfg_spm:       Data from the SPM config register\n\
// * cfg_flush:     Data from the flush config register\n\
// * commit_cfg:    Bit from the configuration commit register - Set by SW\n\
// * flushed:       Data from flush completion register\n\
`define AXI_LLC_TYPEDEF_REGS_Q_T(cfg_regs_q_t, reg_data_t, set_asso_t)  \\\n\
  typedef struct packed {                                               \\\n\
    set_asso_t  cfg_spm;                                                \\\n\
    set_asso_t  cfg_flush;                                              \\\n\
    logic       commit_cfg;                                             \\\n")

    if CachePartition != 0: 
        f.write("    logic       commit_partition_cfg;                                   \\\n")

    f.write("    set_asso_t  flushed;                                                \\\n")

    if CachePartition != 0: 
        f.write("\
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/  \\\n\
    reg_data_t  cfg_flush_thread;                                       \\\n")

        f.write(f'''    reg_data_t [{num_parreg-1}:0] cfg_set_partition;                                     \\
''')

        f.write(f'''    reg_data_t [{num_setflushreg-1}:0] flushed_set;                                           \\
''')

        f.write("/******************************************************************************************************************************/  \\\n")
    f.write("  } cfg_regs_q_t;\n\
\n\
////////////////////////////////////////////////////////////////////////////////////////////////////\n\
\n\
`define AXI_LLC_TYPEDEF_ALL(__name, __reg_data_t, __set_asso_t) \\\n\
  `AXI_LLC_TYPEDEF_REGS_D_T(__name``_cfg_regs_d_t, __reg_data_t, __set_asso_t) \\\n\
  `AXI_LLC_TYPEDEF_REGS_Q_T(__name``_cfg_regs_q_t, __reg_data_t, __set_asso_t)\n\
\n\
`endif")