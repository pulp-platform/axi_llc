// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Nicole Narr <narrn@ethz.ch>
// - Christopher Reinwardt <creinwar@ethz.ch>
// Date:   17.11.2022

// Macros to define AXI_LLC types and structs

`ifndef AXI_LLC_TYPEDEF_SVH_
`define AXI_LLC_TYPEDEF_SVH_

////////////////////////////////////////////////////////////////////////////////////////////////////
// Configuration registers type definitions
//
// HW -> Registers
//
// Fields
// * cfg_spm:       Data to be written into the SPM config register
// * cfg_spm_en:    SPM config register write enable
// * cfg_flush:     Data to be written into the flush config register
// * cfg_flush_en:  Flush config register write enable
// * commit_cfg:    Configuration commit register - Cleared by hardware
// * commit_cfg_en: Configuration commit register write enable
// * flushed:       Flush completion info register
// * flushed_en:    Flush completion info register write enable
// * bist_out:      Result of the BIST
// * bist_out_en:   BIST info write enable
// * set_asso:      Set associativity info register
// * set_asso_en:   Set associativity info register write enable
// * num_lines:     Amount of lines info register
// * num_lines_en:  Amount of lines info register write enable
// * num_blocks:    Amount of blocks info register
// * num_blocks_en: Amount of blocks info register write enable
// * version:       Version register
// * version_en:    Version register write enable
`define AXI_LLC_TYPEDEF_REGS_D_T(cfg_regs_d_t, reg_data_t, set_asso_t)  \
  typedef struct packed {                                               \
    set_asso_t  cfg_spm;                                                \
    logic       cfg_spm_en;                                             \
    set_asso_t  cfg_flush;                                              \
    logic       cfg_flush_en;                                           \
    logic       commit_cfg;                                             \
    logic       commit_cfg_en;                                          \
    logic       commit_partition_cfg;                                   \
    logic       commit_partition_cfg_en;                                \
    set_asso_t  flushed;                                                \
    logic       flushed_en;                                             \
    set_asso_t  bist_out;                                               \
    logic       bist_out_en;                                            \
    reg_data_t  set_asso;                                               \
    logic       set_asso_en;                                            \
    reg_data_t  num_lines;                                              \
    logic       num_lines_en;                                           \
    reg_data_t  num_blocks;                                             \
    logic       num_blocks_en;                                          \
    reg_data_t  version;                                                \
    logic       version_en;                                             \
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/  \
    reg_data_t  cfg_flush_set0;                                         \
    logic       cfg_flush_set0_en;                                      \
    reg_data_t  cfg_flush_set1;                                         \
    logic       cfg_flush_set1_en;                                      \
    reg_data_t  cfg_flush_set2;                                         \
    logic       cfg_flush_set2_en;                                      \
    reg_data_t  cfg_flush_set3;                                         \
    logic       cfg_flush_set3_en;                                      \
    reg_data_t  cfg_set_partition0;                                     \
    logic       cfg_set_partition0_en;                                  \
    reg_data_t  cfg_set_partition1;                                     \
    logic       cfg_set_partition1_en;                                  \
    reg_data_t  cfg_set_partition2;                                     \
    logic       cfg_set_partition2_en;                                  \
    reg_data_t  cfg_set_partition3;                                     \
    logic       cfg_set_partition3_en;                                  \
    reg_data_t  cfg_set_partition4;                                     \
    logic       cfg_set_partition4_en;                                  \
    reg_data_t  cfg_set_partition5;                                     \
    logic       cfg_set_partition5_en;                                  \
    reg_data_t  cfg_set_partition6;                                     \
    logic       cfg_set_partition6_en;                                  \
    reg_data_t  cfg_set_partition7;                                     \
    logic       cfg_set_partition7_en;                                  \
    reg_data_t  cfg_set_partition8;                                     \
    logic       cfg_set_partition8_en;                                  \
    reg_data_t  cfg_set_partition9;                                     \
    logic       cfg_set_partition9_en;                                  \
    reg_data_t  cfg_set_partition10;                                     \
    logic       cfg_set_partition10_en;                                  \
    reg_data_t  cfg_set_partition11;                                     \
    logic       cfg_set_partition11_en;                                  \
    reg_data_t  cfg_set_partition12;                                     \
    logic       cfg_set_partition12_en;                                  \
    reg_data_t  cfg_set_partition13;                                     \
    logic       cfg_set_partition13_en;                                  \
    reg_data_t  cfg_set_partition14;                                     \
    logic       cfg_set_partition14_en;                                  \
    reg_data_t  cfg_set_partition15;                                     \
    logic       cfg_set_partition15_en;                                  \
    reg_data_t  cfg_set_partition16;                                     \
    logic       cfg_set_partition16_en;                                  \
    reg_data_t  cfg_set_partition17;                                     \
    logic       cfg_set_partition17_en;                                  \
    reg_data_t  cfg_set_partition18;                                     \
    logic       cfg_set_partition18_en;                                  \
    reg_data_t  cfg_set_partition19;                                     \
    logic       cfg_set_partition19_en;                                  \
    reg_data_t  cfg_set_partition20;                                     \
    logic       cfg_set_partition20_en;                                  \
    reg_data_t  cfg_set_partition21;                                     \
    logic       cfg_set_partition21_en;                                  \
    reg_data_t  cfg_set_partition22;                                     \
    logic       cfg_set_partition22_en;                                  \
    reg_data_t  cfg_set_partition23;                                     \
    logic       cfg_set_partition23_en;                                  \
    reg_data_t  cfg_set_partition24;                                     \
    logic       cfg_set_partition24_en;                                  \
    reg_data_t  cfg_set_partition25;                                     \
    logic       cfg_set_partition25_en;                                  \
    reg_data_t  cfg_set_partition26;                                     \
    logic       cfg_set_partition26_en;                                  \
    reg_data_t  cfg_set_partition27;                                     \
    logic       cfg_set_partition27_en;                                  \
    reg_data_t  cfg_set_partition28;                                     \
    logic       cfg_set_partition28_en;                                  \
    reg_data_t  cfg_set_partition29;                                     \
    logic       cfg_set_partition29_en;                                  \
    reg_data_t  cfg_set_partition30;                                     \
    logic       cfg_set_partition30_en;                                  \
    reg_data_t  cfg_set_partition31;                                     \
    logic       cfg_set_partition31_en;                                  \
    reg_data_t  flushed_set0;                                           \
    logic       flushed_set0_en;                                        \
    reg_data_t  flushed_set1;                                           \
    logic       flushed_set1_en;                                        \
    reg_data_t  flushed_set2;                                           \
    logic       flushed_set2_en;                                        \
    reg_data_t  flushed_set3;                                           \
    logic       flushed_set3_en;                                        \
/******************************************************************************************************************************/  \
  } cfg_regs_d_t;

// Registers -> HW
//
// Fields
// * cfg_spm:       Data from the SPM config register
// * cfg_flush:     Data from the flush config register
// * commit_cfg:    Bit from the configuration commit register - Set by SW
// * flushed:       Data from flush completion register
`define AXI_LLC_TYPEDEF_REGS_Q_T(cfg_regs_q_t, reg_data_t, set_asso_t)  \
  typedef struct packed {                                               \
    set_asso_t  cfg_spm;                                                \
    set_asso_t  cfg_flush;                                              \
    logic       commit_cfg;                                             \
    logic       commit_partition_cfg;                                   \
    set_asso_t  flushed;                                                \
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/  \
    reg_data_t  cfg_flush_set0;                                         \
    reg_data_t  cfg_flush_set1;                                         \
    reg_data_t  cfg_flush_set2;                                         \
    reg_data_t  cfg_flush_set3;                                         \
    reg_data_t  cfg_set_partition0;                                     \
    reg_data_t  cfg_set_partition1;                                     \
    reg_data_t  cfg_set_partition2;                                     \
    reg_data_t  cfg_set_partition3;                                     \
    reg_data_t  cfg_set_partition4;                                     \
    reg_data_t  cfg_set_partition5;                                     \
    reg_data_t  cfg_set_partition6;                                     \
    reg_data_t  cfg_set_partition7;                                     \
    reg_data_t  cfg_set_partition8;                                     \
    reg_data_t  cfg_set_partition9;                                     \
    reg_data_t  cfg_set_partition10;                                     \
    reg_data_t  cfg_set_partition11;                                     \
    reg_data_t  cfg_set_partition12;                                     \
    reg_data_t  cfg_set_partition13;                                     \
    reg_data_t  cfg_set_partition14;                                     \
    reg_data_t  cfg_set_partition15;                                     \
    reg_data_t  cfg_set_partition16;                                     \
    reg_data_t  cfg_set_partition17;                                     \
    reg_data_t  cfg_set_partition18;                                     \
    reg_data_t  cfg_set_partition19;                                     \
    reg_data_t  cfg_set_partition20;                                     \
    reg_data_t  cfg_set_partition21;                                     \
    reg_data_t  cfg_set_partition22;                                     \
    reg_data_t  cfg_set_partition23;                                     \
    reg_data_t  cfg_set_partition24;                                     \
    reg_data_t  cfg_set_partition25;                                     \
    reg_data_t  cfg_set_partition26;                                     \
    reg_data_t  cfg_set_partition27;                                     \
    reg_data_t  cfg_set_partition28;                                     \
    reg_data_t  cfg_set_partition29;                                     \
    reg_data_t  cfg_set_partition30;                                     \
    reg_data_t  cfg_set_partition31;                                     \
    reg_data_t  flushed_set0;                                           \
    reg_data_t  flushed_set1;                                           \
    reg_data_t  flushed_set2;                                           \
    reg_data_t  flushed_set3;                                           \
/******************************************************************************************************************************/  \
  } cfg_regs_q_t;

////////////////////////////////////////////////////////////////////////////////////////////////////

`define AXI_LLC_TYPEDEF_ALL(__name, __reg_data_t, __set_asso_t) \
  `AXI_LLC_TYPEDEF_REGS_D_T(__name``_cfg_regs_d_t, __reg_data_t, __set_asso_t) \
  `AXI_LLC_TYPEDEF_REGS_Q_T(__name``_cfg_regs_q_t, __reg_data_t, __set_asso_t)

`endif