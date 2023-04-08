// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package axi_llc_reg_pkg;

  // Address widths within the block
  parameter int BlockAw = 7;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_cfg_spm_low_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_cfg_spm_high_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_cfg_flush_low_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_cfg_flush_high_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_cfg_flush_set0_low_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_cfg_flush_set0_high_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_cfg_set_partition0_low_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_cfg_set_partition0_high_reg_t;

  typedef struct packed {
    logic        q;
  } axi_llc_reg2hw_commit_cfg_reg_t;

  typedef struct packed {
    logic        q;
  } axi_llc_reg2hw_commit_partition_cfg_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_flushed_low_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_flushed_high_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_flushed_set0_low_reg_t;

  typedef struct packed {
    logic [31:0] q;
  } axi_llc_reg2hw_flushed_set0_high_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_cfg_spm_low_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_cfg_spm_high_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_cfg_flush_low_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_cfg_flush_high_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_cfg_flush_set0_low_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_cfg_flush_set0_high_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_cfg_set_partition0_low_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_cfg_set_partition0_high_reg_t;

  typedef struct packed {
    logic        d;
    logic        de;
  } axi_llc_hw2reg_commit_cfg_reg_t;

  typedef struct packed {
    logic        d;
    logic        de;
  } axi_llc_hw2reg_commit_partition_cfg_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_flushed_low_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_flushed_high_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_bist_out_low_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_bist_out_high_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_set_asso_low_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_set_asso_high_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_num_lines_low_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_num_lines_high_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_num_blocks_low_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_num_blocks_high_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_version_low_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_version_high_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_flushed_set0_low_reg_t;

  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } axi_llc_hw2reg_flushed_set0_high_reg_t;

  // Register -> HW type
  typedef struct packed {
    axi_llc_reg2hw_cfg_spm_low_reg_t cfg_spm_low; // [385:354]
    axi_llc_reg2hw_cfg_spm_high_reg_t cfg_spm_high; // [353:322]
    axi_llc_reg2hw_cfg_flush_low_reg_t cfg_flush_low; // [321:290]
    axi_llc_reg2hw_cfg_flush_high_reg_t cfg_flush_high; // [289:258]
    axi_llc_reg2hw_cfg_flush_set0_low_reg_t cfg_flush_set0_low; // [257:226]
    axi_llc_reg2hw_cfg_flush_set0_high_reg_t cfg_flush_set0_high; // [225:194]
    axi_llc_reg2hw_cfg_set_partition0_low_reg_t cfg_set_partition0_low; // [193:162]
    axi_llc_reg2hw_cfg_set_partition0_high_reg_t cfg_set_partition0_high; // [161:130]
    axi_llc_reg2hw_commit_cfg_reg_t commit_cfg; // [129:129]
    axi_llc_reg2hw_commit_partition_cfg_reg_t commit_partition_cfg; // [128:128]
    axi_llc_reg2hw_flushed_low_reg_t flushed_low; // [127:96]
    axi_llc_reg2hw_flushed_high_reg_t flushed_high; // [95:64]
    axi_llc_reg2hw_flushed_set0_low_reg_t flushed_set0_low; // [63:32]
    axi_llc_reg2hw_flushed_set0_high_reg_t flushed_set0_high; // [31:0]
  } axi_llc_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    axi_llc_hw2reg_cfg_spm_low_reg_t cfg_spm_low; // [729:697]
    axi_llc_hw2reg_cfg_spm_high_reg_t cfg_spm_high; // [696:664]
    axi_llc_hw2reg_cfg_flush_low_reg_t cfg_flush_low; // [663:631]
    axi_llc_hw2reg_cfg_flush_high_reg_t cfg_flush_high; // [630:598]
    axi_llc_hw2reg_cfg_flush_set0_low_reg_t cfg_flush_set0_low; // [597:565]
    axi_llc_hw2reg_cfg_flush_set0_high_reg_t cfg_flush_set0_high; // [564:532]
    axi_llc_hw2reg_cfg_set_partition0_low_reg_t cfg_set_partition0_low; // [531:499]
    axi_llc_hw2reg_cfg_set_partition0_high_reg_t cfg_set_partition0_high; // [498:466]
    axi_llc_hw2reg_commit_cfg_reg_t commit_cfg; // [465:464]
    axi_llc_hw2reg_commit_partition_cfg_reg_t commit_partition_cfg; // [463:462]
    axi_llc_hw2reg_flushed_low_reg_t flushed_low; // [461:429]
    axi_llc_hw2reg_flushed_high_reg_t flushed_high; // [428:396]
    axi_llc_hw2reg_bist_out_low_reg_t bist_out_low; // [395:363]
    axi_llc_hw2reg_bist_out_high_reg_t bist_out_high; // [362:330]
    axi_llc_hw2reg_set_asso_low_reg_t set_asso_low; // [329:297]
    axi_llc_hw2reg_set_asso_high_reg_t set_asso_high; // [296:264]
    axi_llc_hw2reg_num_lines_low_reg_t num_lines_low; // [263:231]
    axi_llc_hw2reg_num_lines_high_reg_t num_lines_high; // [230:198]
    axi_llc_hw2reg_num_blocks_low_reg_t num_blocks_low; // [197:165]
    axi_llc_hw2reg_num_blocks_high_reg_t num_blocks_high; // [164:132]
    axi_llc_hw2reg_version_low_reg_t version_low; // [131:99]
    axi_llc_hw2reg_version_high_reg_t version_high; // [98:66]
    axi_llc_hw2reg_flushed_set0_low_reg_t flushed_set0_low; // [65:33]
    axi_llc_hw2reg_flushed_set0_high_reg_t flushed_set0_high; // [32:0]
  } axi_llc_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] AXI_LLC_CFG_SPM_LOW_OFFSET = 7'h 0;
  parameter logic [BlockAw-1:0] AXI_LLC_CFG_SPM_HIGH_OFFSET = 7'h 4;
  parameter logic [BlockAw-1:0] AXI_LLC_CFG_FLUSH_LOW_OFFSET = 7'h 8;
  parameter logic [BlockAw-1:0] AXI_LLC_CFG_FLUSH_HIGH_OFFSET = 7'h c;
  parameter logic [BlockAw-1:0] AXI_LLC_CFG_FLUSH_SET0_LOW_OFFSET = 7'h 10;
  parameter logic [BlockAw-1:0] AXI_LLC_CFG_FLUSH_SET0_HIGH_OFFSET = 7'h 14;
  parameter logic [BlockAw-1:0] AXI_LLC_CFG_SET_PARTITION0_LOW_OFFSET = 7'h 18;
  parameter logic [BlockAw-1:0] AXI_LLC_CFG_SET_PARTITION0_HIGH_OFFSET = 7'h 1c;
  parameter logic [BlockAw-1:0] AXI_LLC_COMMIT_CFG_OFFSET = 7'h 20;
  parameter logic [BlockAw-1:0] AXI_LLC_COMMIT_PARTITION_CFG_OFFSET = 7'h 28;
  parameter logic [BlockAw-1:0] AXI_LLC_FLUSHED_LOW_OFFSET = 7'h 30;
  parameter logic [BlockAw-1:0] AXI_LLC_FLUSHED_HIGH_OFFSET = 7'h 34;
  parameter logic [BlockAw-1:0] AXI_LLC_BIST_OUT_LOW_OFFSET = 7'h 38;
  parameter logic [BlockAw-1:0] AXI_LLC_BIST_OUT_HIGH_OFFSET = 7'h 3c;
  parameter logic [BlockAw-1:0] AXI_LLC_SET_ASSO_LOW_OFFSET = 7'h 40;
  parameter logic [BlockAw-1:0] AXI_LLC_SET_ASSO_HIGH_OFFSET = 7'h 44;
  parameter logic [BlockAw-1:0] AXI_LLC_NUM_LINES_LOW_OFFSET = 7'h 48;
  parameter logic [BlockAw-1:0] AXI_LLC_NUM_LINES_HIGH_OFFSET = 7'h 4c;
  parameter logic [BlockAw-1:0] AXI_LLC_NUM_BLOCKS_LOW_OFFSET = 7'h 50;
  parameter logic [BlockAw-1:0] AXI_LLC_NUM_BLOCKS_HIGH_OFFSET = 7'h 54;
  parameter logic [BlockAw-1:0] AXI_LLC_VERSION_LOW_OFFSET = 7'h 58;
  parameter logic [BlockAw-1:0] AXI_LLC_VERSION_HIGH_OFFSET = 7'h 5c;
  parameter logic [BlockAw-1:0] AXI_LLC_FLUSHED_SET0_LOW_OFFSET = 7'h 60;
  parameter logic [BlockAw-1:0] AXI_LLC_FLUSHED_SET0_HIGH_OFFSET = 7'h 64;

  // Register index
  typedef enum int {
    AXI_LLC_CFG_SPM_LOW,
    AXI_LLC_CFG_SPM_HIGH,
    AXI_LLC_CFG_FLUSH_LOW,
    AXI_LLC_CFG_FLUSH_HIGH,
    AXI_LLC_CFG_FLUSH_SET0_LOW,
    AXI_LLC_CFG_FLUSH_SET0_HIGH,
    AXI_LLC_CFG_SET_PARTITION0_LOW,
    AXI_LLC_CFG_SET_PARTITION0_HIGH,
    AXI_LLC_COMMIT_CFG,
    AXI_LLC_COMMIT_PARTITION_CFG,
    AXI_LLC_FLUSHED_LOW,
    AXI_LLC_FLUSHED_HIGH,
    AXI_LLC_BIST_OUT_LOW,
    AXI_LLC_BIST_OUT_HIGH,
    AXI_LLC_SET_ASSO_LOW,
    AXI_LLC_SET_ASSO_HIGH,
    AXI_LLC_NUM_LINES_LOW,
    AXI_LLC_NUM_LINES_HIGH,
    AXI_LLC_NUM_BLOCKS_LOW,
    AXI_LLC_NUM_BLOCKS_HIGH,
    AXI_LLC_VERSION_LOW,
    AXI_LLC_VERSION_HIGH,
    AXI_LLC_FLUSHED_SET0_LOW,
    AXI_LLC_FLUSHED_SET0_HIGH
  } axi_llc_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] AXI_LLC_PERMIT [24] = '{
    4'b 1111, // index[ 0] AXI_LLC_CFG_SPM_LOW
    4'b 1111, // index[ 1] AXI_LLC_CFG_SPM_HIGH
    4'b 1111, // index[ 2] AXI_LLC_CFG_FLUSH_LOW
    4'b 1111, // index[ 3] AXI_LLC_CFG_FLUSH_HIGH
    4'b 1111, // index[ 4] AXI_LLC_CFG_FLUSH_SET0_LOW
    4'b 1111, // index[ 5] AXI_LLC_CFG_FLUSH_SET0_HIGH
    4'b 1111, // index[ 6] AXI_LLC_CFG_SET_PARTITION0_LOW
    4'b 1111, // index[ 7] AXI_LLC_CFG_SET_PARTITION0_HIGH
    4'b 0001, // index[ 8] AXI_LLC_COMMIT_CFG
    4'b 0001, // index[ 9] AXI_LLC_COMMIT_PARTITION_CFG
    4'b 1111, // index[10] AXI_LLC_FLUSHED_LOW
    4'b 1111, // index[11] AXI_LLC_FLUSHED_HIGH
    4'b 1111, // index[12] AXI_LLC_BIST_OUT_LOW
    4'b 1111, // index[13] AXI_LLC_BIST_OUT_HIGH
    4'b 1111, // index[14] AXI_LLC_SET_ASSO_LOW
    4'b 1111, // index[15] AXI_LLC_SET_ASSO_HIGH
    4'b 1111, // index[16] AXI_LLC_NUM_LINES_LOW
    4'b 1111, // index[17] AXI_LLC_NUM_LINES_HIGH
    4'b 1111, // index[18] AXI_LLC_NUM_BLOCKS_LOW
    4'b 1111, // index[19] AXI_LLC_NUM_BLOCKS_HIGH
    4'b 1111, // index[20] AXI_LLC_VERSION_LOW
    4'b 1111, // index[21] AXI_LLC_VERSION_HIGH
    4'b 1111, // index[22] AXI_LLC_FLUSHED_SET0_LOW
    4'b 1111  // index[23] AXI_LLC_FLUSHED_SET0_HIGH
  };

endpackage

