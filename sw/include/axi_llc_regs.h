// Generated register defines for axi_llc

// Copyright information found in source file:
// Copyright 2018-2021 ETH Zurich and University of Bologna.

// Licensing information found in source file:
// 
// SPDX-License-Identifier: SHL-0.51

#ifndef _AXI_LLC_REG_DEFS_
#define _AXI_LLC_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define AXI_LLC_PARAM_REG_WIDTH 32

// SPM Configuration (lower 32 bit)
#define AXI_LLC_CFG_SPM_LOW_REG_OFFSET 0x0

// SPM Configuration (upper 32 bit)
#define AXI_LLC_CFG_SPM_HIGH_REG_OFFSET 0x4

// Flush Configuration (lower 32 bit)
#define AXI_LLC_CFG_FLUSH_LOW_REG_OFFSET 0x8

// Flush Configuration (upper 32 bit)
#define AXI_LLC_CFG_FLUSH_HIGH_REG_OFFSET 0xc

// Index-based Flush Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_FLUSH_SET0_LOW_REG_OFFSET 0x10

// Index-based Flush Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_FLUSH_SET0_HIGH_REG_OFFSET 0x14

// Index-based Flush Configuration [95:64] (lower 32 bit)
#define AXI_LLC_CFG_FLUSH_SET1_LOW_REG_OFFSET 0x18

// Index-based Flush Configuration [127:96] (upper 32 bit)
#define AXI_LLC_CFG_FLUSH_SET1_HIGH_REG_OFFSET 0x1c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION0_LOW_REG_OFFSET 0x20

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION0_HIGH_REG_OFFSET 0x24

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION1_LOW_REG_OFFSET 0x28

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION1_HIGH_REG_OFFSET 0x2c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION2_LOW_REG_OFFSET 0x30

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION2_HIGH_REG_OFFSET 0x34

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION3_LOW_REG_OFFSET 0x38

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION3_HIGH_REG_OFFSET 0x3c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION4_LOW_REG_OFFSET 0x40

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION4_HIGH_REG_OFFSET 0x44

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION5_LOW_REG_OFFSET 0x48

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION5_HIGH_REG_OFFSET 0x4c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION6_LOW_REG_OFFSET 0x50

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION6_HIGH_REG_OFFSET 0x54

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION7_LOW_REG_OFFSET 0x58

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION7_HIGH_REG_OFFSET 0x5c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION8_LOW_REG_OFFSET 0x60

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION8_HIGH_REG_OFFSET 0x64

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION9_LOW_REG_OFFSET 0x68

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION9_HIGH_REG_OFFSET 0x6c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION10_LOW_REG_OFFSET 0x70

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION10_HIGH_REG_OFFSET 0x74

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION11_LOW_REG_OFFSET 0x78

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION11_HIGH_REG_OFFSET 0x7c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION12_LOW_REG_OFFSET 0x80

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION12_HIGH_REG_OFFSET 0x84

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION13_LOW_REG_OFFSET 0x88

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION13_HIGH_REG_OFFSET 0x8c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION14_LOW_REG_OFFSET 0x90

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION14_HIGH_REG_OFFSET 0x94

// Commit the configuration
#define AXI_LLC_COMMIT_CFG_REG_OFFSET 0x98
#define AXI_LLC_COMMIT_CFG_COMMIT_BIT 0

// Commit the set partition configuration
#define AXI_LLC_COMMIT_PARTITION_CFG_REG_OFFSET 0xa0
#define AXI_LLC_COMMIT_PARTITION_CFG_COMMIT_BIT 0

// Flushed Flag (lower 32 bit)
#define AXI_LLC_FLUSHED_LOW_REG_OFFSET 0xa8

// Flushed Flag (upper 32 bit)
#define AXI_LLC_FLUSHED_HIGH_REG_OFFSET 0xac

// Tag Storage BIST Result (lower 32 bit)
#define AXI_LLC_BIST_OUT_LOW_REG_OFFSET 0xb0

// Tag Storage BIST Result (upper 32 bit)
#define AXI_LLC_BIST_OUT_HIGH_REG_OFFSET 0xb4

// Instantiated Set-Associativity (lower 32 bit)
#define AXI_LLC_SET_ASSO_LOW_REG_OFFSET 0xb8

// Instantiated Set-Associativity (upper 32 bit)
#define AXI_LLC_SET_ASSO_HIGH_REG_OFFSET 0xbc

// Instantiated Number of Cache-Lines (lower 32 bit)
#define AXI_LLC_NUM_LINES_LOW_REG_OFFSET 0xc0

// Instantiated Number of Cache-Lines (upper 32 bit)
#define AXI_LLC_NUM_LINES_HIGH_REG_OFFSET 0xc4

// Instantiated Number of Blocks (lower 32 bit)
#define AXI_LLC_NUM_BLOCKS_LOW_REG_OFFSET 0xc8

// Instantiated Number of Blocks (upper 32 bit)
#define AXI_LLC_NUM_BLOCKS_HIGH_REG_OFFSET 0xcc

// AXI LLC Version (lower 32 bit)
#define AXI_LLC_VERSION_LOW_REG_OFFSET 0xd0

// AXI LLC Version (upper 32 bit)
#define AXI_LLC_VERSION_HIGH_REG_OFFSET 0xd4

// Index-based Flushed Flag [31:0] (lower 32 bit)
#define AXI_LLC_FLUSHED_SET0_LOW_REG_OFFSET 0xd8

// Index-based Flushed Flag [63:32] (upper 32 bit)
#define AXI_LLC_FLUSHED_SET0_HIGH_REG_OFFSET 0xdc

// Index-based Flushed Flag [95:64] (lower 32 bit)
#define AXI_LLC_FLUSHED_SET1_LOW_REG_OFFSET 0xe0

// Index-based Flushed Flag [127:96] (upper 32 bit)
#define AXI_LLC_FLUSHED_SET1_HIGH_REG_OFFSET 0xe4

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _AXI_LLC_REG_DEFS_
// End generated register defines for axi_llc