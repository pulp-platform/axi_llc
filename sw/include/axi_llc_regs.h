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

// Index-based Flush Configuration [159:128] (lower 32 bit)
#define AXI_LLC_CFG_FLUSH_SET2_LOW_REG_OFFSET 0x20

// Index-based Flush Configuration [191:160] (upper 32 bit)
#define AXI_LLC_CFG_FLUSH_SET2_HIGH_REG_OFFSET 0x24

// Index-based Flush Configuration [223:192] (lower 32 bit)
#define AXI_LLC_CFG_FLUSH_SET3_LOW_REG_OFFSET 0x28

// Index-based Flush Configuration [255:224] (upper 32 bit)
#define AXI_LLC_CFG_FLUSH_SET3_HIGH_REG_OFFSET 0x2c

// Index-based Flush Configuration [287:256] (lower 32 bit)
#define AXI_LLC_CFG_FLUSH_SET4_LOW_REG_OFFSET 0x30

// Index-based Flush Configuration [319:288] (upper 32 bit)
#define AXI_LLC_CFG_FLUSH_SET4_HIGH_REG_OFFSET 0x34

// Index-based Flush Configuration [351:320] (lower 32 bit)
#define AXI_LLC_CFG_FLUSH_SET5_LOW_REG_OFFSET 0x38

// Index-based Flush Configuration [383:352] (upper 32 bit)
#define AXI_LLC_CFG_FLUSH_SET5_HIGH_REG_OFFSET 0x3c

// Index-based Flush Configuration [415:384] (lower 32 bit)
#define AXI_LLC_CFG_FLUSH_SET6_LOW_REG_OFFSET 0x40

// Index-based Flush Configuration [447:416] (upper 32 bit)
#define AXI_LLC_CFG_FLUSH_SET6_HIGH_REG_OFFSET 0x44

// Index-based Flush Configuration [479:448] (lower 32 bit)
#define AXI_LLC_CFG_FLUSH_SET7_LOW_REG_OFFSET 0x48

// Index-based Flush Configuration [511:480] (upper 32 bit)
#define AXI_LLC_CFG_FLUSH_SET7_HIGH_REG_OFFSET 0x4c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION0_LOW_REG_OFFSET 0x50

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION0_HIGH_REG_OFFSET 0x54

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION1_LOW_REG_OFFSET 0x58

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION1_HIGH_REG_OFFSET 0x5c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION2_LOW_REG_OFFSET 0x60

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION2_HIGH_REG_OFFSET 0x64

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION3_LOW_REG_OFFSET 0x68

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION3_HIGH_REG_OFFSET 0x6c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION4_LOW_REG_OFFSET 0x70

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION4_HIGH_REG_OFFSET 0x74

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION5_LOW_REG_OFFSET 0x78

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION5_HIGH_REG_OFFSET 0x7c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION6_LOW_REG_OFFSET 0x80

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION6_HIGH_REG_OFFSET 0x84

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION7_LOW_REG_OFFSET 0x88

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION7_HIGH_REG_OFFSET 0x8c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION8_LOW_REG_OFFSET 0x90

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION8_HIGH_REG_OFFSET 0x94

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION9_LOW_REG_OFFSET 0x98

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION9_HIGH_REG_OFFSET 0x9c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION10_LOW_REG_OFFSET 0xa0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION10_HIGH_REG_OFFSET 0xa4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION11_LOW_REG_OFFSET 0xa8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION11_HIGH_REG_OFFSET 0xac

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION12_LOW_REG_OFFSET 0xb0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION12_HIGH_REG_OFFSET 0xb4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION13_LOW_REG_OFFSET 0xb8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION13_HIGH_REG_OFFSET 0xbc

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION14_LOW_REG_OFFSET 0xc0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION14_HIGH_REG_OFFSET 0xc4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION15_LOW_REG_OFFSET 0xc8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION15_HIGH_REG_OFFSET 0xcc

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION16_LOW_REG_OFFSET 0xd0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION16_HIGH_REG_OFFSET 0xd4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION17_LOW_REG_OFFSET 0xd8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION17_HIGH_REG_OFFSET 0xdc

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION18_LOW_REG_OFFSET 0xe0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION18_HIGH_REG_OFFSET 0xe4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION19_LOW_REG_OFFSET 0xe8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION19_HIGH_REG_OFFSET 0xec

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION20_LOW_REG_OFFSET 0xf0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION20_HIGH_REG_OFFSET 0xf4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION21_LOW_REG_OFFSET 0xf8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION21_HIGH_REG_OFFSET 0xfc

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION22_LOW_REG_OFFSET 0x100

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION22_HIGH_REG_OFFSET 0x104

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION23_LOW_REG_OFFSET 0x108

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION23_HIGH_REG_OFFSET 0x10c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION24_LOW_REG_OFFSET 0x110

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION24_HIGH_REG_OFFSET 0x114

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION25_LOW_REG_OFFSET 0x118

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION25_HIGH_REG_OFFSET 0x11c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION26_LOW_REG_OFFSET 0x120

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION26_HIGH_REG_OFFSET 0x124

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION27_LOW_REG_OFFSET 0x128

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION27_HIGH_REG_OFFSET 0x12c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION28_LOW_REG_OFFSET 0x130

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION28_HIGH_REG_OFFSET 0x134

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION29_LOW_REG_OFFSET 0x138

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION29_HIGH_REG_OFFSET 0x13c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION30_LOW_REG_OFFSET 0x140

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION30_HIGH_REG_OFFSET 0x144

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION31_LOW_REG_OFFSET 0x148

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION31_HIGH_REG_OFFSET 0x14c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION32_LOW_REG_OFFSET 0x150

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION32_HIGH_REG_OFFSET 0x154

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION33_LOW_REG_OFFSET 0x158

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION33_HIGH_REG_OFFSET 0x15c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION34_LOW_REG_OFFSET 0x160

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION34_HIGH_REG_OFFSET 0x164

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION35_LOW_REG_OFFSET 0x168

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION35_HIGH_REG_OFFSET 0x16c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION36_LOW_REG_OFFSET 0x170

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION36_HIGH_REG_OFFSET 0x174

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION37_LOW_REG_OFFSET 0x178

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION37_HIGH_REG_OFFSET 0x17c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION38_LOW_REG_OFFSET 0x180

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION38_HIGH_REG_OFFSET 0x184

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION39_LOW_REG_OFFSET 0x188

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION39_HIGH_REG_OFFSET 0x18c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION40_LOW_REG_OFFSET 0x190

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION40_HIGH_REG_OFFSET 0x194

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION41_LOW_REG_OFFSET 0x198

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION41_HIGH_REG_OFFSET 0x19c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION42_LOW_REG_OFFSET 0x1a0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION42_HIGH_REG_OFFSET 0x1a4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION43_LOW_REG_OFFSET 0x1a8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION43_HIGH_REG_OFFSET 0x1ac

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION44_LOW_REG_OFFSET 0x1b0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION44_HIGH_REG_OFFSET 0x1b4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION45_LOW_REG_OFFSET 0x1b8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION45_HIGH_REG_OFFSET 0x1bc

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION46_LOW_REG_OFFSET 0x1c0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION46_HIGH_REG_OFFSET 0x1c4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION47_LOW_REG_OFFSET 0x1c8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION47_HIGH_REG_OFFSET 0x1cc

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION48_LOW_REG_OFFSET 0x1d0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION48_HIGH_REG_OFFSET 0x1d4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION49_LOW_REG_OFFSET 0x1d8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION49_HIGH_REG_OFFSET 0x1dc

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION50_LOW_REG_OFFSET 0x1e0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION50_HIGH_REG_OFFSET 0x1e4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION51_LOW_REG_OFFSET 0x1e8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION51_HIGH_REG_OFFSET 0x1ec

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION52_LOW_REG_OFFSET 0x1f0

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION52_HIGH_REG_OFFSET 0x1f4

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION53_LOW_REG_OFFSET 0x1f8

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION53_HIGH_REG_OFFSET 0x1fc

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION54_LOW_REG_OFFSET 0x200

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION54_HIGH_REG_OFFSET 0x204

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION55_LOW_REG_OFFSET 0x208

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION55_HIGH_REG_OFFSET 0x20c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION56_LOW_REG_OFFSET 0x210

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION56_HIGH_REG_OFFSET 0x214

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION57_LOW_REG_OFFSET 0x218

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION57_HIGH_REG_OFFSET 0x21c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION58_LOW_REG_OFFSET 0x220

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION58_HIGH_REG_OFFSET 0x224

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION59_LOW_REG_OFFSET 0x228

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION59_HIGH_REG_OFFSET 0x22c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION60_LOW_REG_OFFSET 0x230

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION60_HIGH_REG_OFFSET 0x234

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION61_LOW_REG_OFFSET 0x238

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION61_HIGH_REG_OFFSET 0x23c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION62_LOW_REG_OFFSET 0x240

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION62_HIGH_REG_OFFSET 0x244

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION63_LOW_REG_OFFSET 0x248

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION63_HIGH_REG_OFFSET 0x24c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION64_LOW_REG_OFFSET 0x250

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION64_HIGH_REG_OFFSET 0x254

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION65_LOW_REG_OFFSET 0x258

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION65_HIGH_REG_OFFSET 0x25c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION66_LOW_REG_OFFSET 0x260

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION66_HIGH_REG_OFFSET 0x264

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION67_LOW_REG_OFFSET 0x268

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION67_HIGH_REG_OFFSET 0x26c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION68_LOW_REG_OFFSET 0x270

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION68_HIGH_REG_OFFSET 0x274

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION69_LOW_REG_OFFSET 0x278

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION69_HIGH_REG_OFFSET 0x27c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION70_LOW_REG_OFFSET 0x280

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION70_HIGH_REG_OFFSET 0x284

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION71_LOW_REG_OFFSET 0x288

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION71_HIGH_REG_OFFSET 0x28c

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION72_LOW_REG_OFFSET 0x290

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION72_HIGH_REG_OFFSET 0x294

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION73_LOW_REG_OFFSET 0x298

// Index-based Partition Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_SET_PARTITION73_HIGH_REG_OFFSET 0x29c

// Commit the configuration
#define AXI_LLC_COMMIT_CFG_REG_OFFSET 0x2a0
#define AXI_LLC_COMMIT_CFG_COMMIT_BIT 0

// Commit the set partition configuration
#define AXI_LLC_COMMIT_PARTITION_CFG_REG_OFFSET 0x2a8
#define AXI_LLC_COMMIT_PARTITION_CFG_COMMIT_BIT 0

// Flushed Flag (lower 32 bit)
#define AXI_LLC_FLUSHED_LOW_REG_OFFSET 0x2b0

// Flushed Flag (upper 32 bit)
#define AXI_LLC_FLUSHED_HIGH_REG_OFFSET 0x2b4

// Tag Storage BIST Result (lower 32 bit)
#define AXI_LLC_BIST_OUT_LOW_REG_OFFSET 0x2b8

// Tag Storage BIST Result (upper 32 bit)
#define AXI_LLC_BIST_OUT_HIGH_REG_OFFSET 0x2bc

// Instantiated Set-Associativity (lower 32 bit)
#define AXI_LLC_SET_ASSO_LOW_REG_OFFSET 0x2c0

// Instantiated Set-Associativity (upper 32 bit)
#define AXI_LLC_SET_ASSO_HIGH_REG_OFFSET 0x2c4

// Instantiated Number of Cache-Lines (lower 32 bit)
#define AXI_LLC_NUM_LINES_LOW_REG_OFFSET 0x2c8

// Instantiated Number of Cache-Lines (upper 32 bit)
#define AXI_LLC_NUM_LINES_HIGH_REG_OFFSET 0x2cc

// Instantiated Number of Blocks (lower 32 bit)
#define AXI_LLC_NUM_BLOCKS_LOW_REG_OFFSET 0x2d0

// Instantiated Number of Blocks (upper 32 bit)
#define AXI_LLC_NUM_BLOCKS_HIGH_REG_OFFSET 0x2d4

// AXI LLC Version (lower 32 bit)
#define AXI_LLC_VERSION_LOW_REG_OFFSET 0x2d8

// AXI LLC Version (upper 32 bit)
#define AXI_LLC_VERSION_HIGH_REG_OFFSET 0x2dc

// Status register of the BIST
#define AXI_LLC_BIST_STATUS_REG_OFFSET 0x2e0
#define AXI_LLC_BIST_STATUS_DONE_BIT 0

// Index-based Flushed Flag [31:0] (lower 32 bit)
#define AXI_LLC_FLUSHED_SET0_LOW_REG_OFFSET 0x2e4

// Index-based Flushed Flag [63:32] (upper 32 bit)
#define AXI_LLC_FLUSHED_SET0_HIGH_REG_OFFSET 0x2e8

// Index-based Flushed Flag [95:64] (lower 32 bit)
#define AXI_LLC_FLUSHED_SET1_LOW_REG_OFFSET 0x2ec

// Index-based Flushed Flag [127:96] (upper 32 bit)
#define AXI_LLC_FLUSHED_SET1_HIGH_REG_OFFSET 0x2f0

// Index-based Flushed Flag [159:128] (lower 32 bit)
#define AXI_LLC_FLUSHED_SET2_LOW_REG_OFFSET 0x2f4

// Index-based Flushed Flag [191:160] (upper 32 bit)
#define AXI_LLC_FLUSHED_SET2_HIGH_REG_OFFSET 0x2f8

// Index-based Flushed Flag [223:192] (lower 32 bit)
#define AXI_LLC_FLUSHED_SET3_LOW_REG_OFFSET 0x2fc

// Index-based Flushed Flag [255:224] (upper 32 bit)
#define AXI_LLC_FLUSHED_SET3_HIGH_REG_OFFSET 0x300

// Index-based Flushed Flag [287:256] (lower 32 bit)
#define AXI_LLC_FLUSHED_SET4_LOW_REG_OFFSET 0x304

// Index-based Flushed Flag [319:288] (upper 32 bit)
#define AXI_LLC_FLUSHED_SET4_HIGH_REG_OFFSET 0x308

// Index-based Flushed Flag [351:320] (lower 32 bit)
#define AXI_LLC_FLUSHED_SET5_LOW_REG_OFFSET 0x30c

// Index-based Flushed Flag [383:352] (upper 32 bit)
#define AXI_LLC_FLUSHED_SET5_HIGH_REG_OFFSET 0x310

// Index-based Flushed Flag [415:384] (lower 32 bit)
#define AXI_LLC_FLUSHED_SET6_LOW_REG_OFFSET 0x314

// Index-based Flushed Flag [447:416] (upper 32 bit)
#define AXI_LLC_FLUSHED_SET6_HIGH_REG_OFFSET 0x318

// Index-based Flushed Flag [479:448] (lower 32 bit)
#define AXI_LLC_FLUSHED_SET7_LOW_REG_OFFSET 0x31c

// Index-based Flushed Flag [511:480] (upper 32 bit)
#define AXI_LLC_FLUSHED_SET7_HIGH_REG_OFFSET 0x320

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _AXI_LLC_REG_DEFS_
// End generated register defines for axi_llc