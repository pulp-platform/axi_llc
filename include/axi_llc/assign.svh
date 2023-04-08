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
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/  \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush_set0) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition0) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition1) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_set_partition2) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed_set0)
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
    assign q_struct.cfg_set_partition0 = {regbus.cfg_set_partition0_high.q, regbus.cfg_set_partition0_low.q}; \
    assign q_struct.cfg_set_partition1 = {regbus.cfg_set_partition1_high.q, regbus.cfg_set_partition1_low.q}; \
    assign q_struct.cfg_set_partition2 = {regbus.cfg_set_partition2_high.q, regbus.cfg_set_partition2_low.q}; \
    assign q_struct.cfg_flush_set0 = {regbus.cfg_flush_set0_high.q, regbus.cfg_flush_set0_low.q};
/******************************************************************************************************************************/  

`endif