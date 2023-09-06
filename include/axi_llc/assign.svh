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

`define AXI_LLC_ASSIGN_REGBUS_FROM_MREGS_D_MEMBER(regbus, d_struct, member, offset) \
    assign regbus.member``_low[offset].d = d_struct.member[offset]; \
    assign regbus.member``_low[offset].de = d_struct.member``_en[offset]; \
    assign regbus.member``_high[offset].d = d_struct.member[offset] >> 32; \
    assign regbus.member``_high[offset].de = d_struct.member``_en[offset];

// Assign the regtool RegBus HW2REG struct from a d_struct
`define AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D(regbus, d_struct)                     \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_spm)        \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush)      \
    assign regbus.commit_cfg.d = d_struct.commit_cfg;                           \
    assign regbus.commit_cfg.de = d_struct.commit_cfg_en;                       \
    assign regbus.bist_status.d = d_struct.bist_status_done;                    \
    assign regbus.bist_status.de = d_struct.bist_status_en;                     \
    assign regbus.commit_partition_cfg.d = d_struct.commit_partition_cfg;       \
    assign regbus.commit_partition_cfg.de = d_struct.commit_partition_cfg_en;   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, flushed)        \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, bist_out)       \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, set_asso)       \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, num_lines)      \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, num_blocks)     \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, version)        \
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/  \
    `AXI_LLC_ASSIGN_REGBUS_FROM_REGS_D_MEMBER(regbus, d_struct, cfg_flush_thread) \
    `AXI_LLC_ASSIGN_REGBUS_FROM_MREGS_D_MEMBER(regbus, d_struct, cfg_set_partition, 0)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_MREGS_D_MEMBER(regbus, d_struct, cfg_set_partition, 1)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_MREGS_D_MEMBER(regbus, d_struct, flushed_set, 0)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_MREGS_D_MEMBER(regbus, d_struct, flushed_set, 1)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_MREGS_D_MEMBER(regbus, d_struct, flushed_set, 2)   \
    `AXI_LLC_ASSIGN_REGBUS_FROM_MREGS_D_MEMBER(regbus, d_struct, flushed_set, 3)
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
    assign q_struct.flushed_set[0] = {regbus.flushed_set_high[0].q, regbus.flushed_set_low[0].q}; \
    assign q_struct.flushed_set[1] = {regbus.flushed_set_high[1].q, regbus.flushed_set_low[1].q}; \
    assign q_struct.flushed_set[2] = {regbus.flushed_set_high[2].q, regbus.flushed_set_low[2].q}; \
    assign q_struct.flushed_set[3] = {regbus.flushed_set_high[3].q, regbus.flushed_set_low[3].q}; \
    assign q_struct.cfg_set_partition[0] = {regbus.cfg_set_partition_high[0].q, regbus.cfg_set_partition_low[0].q}; \
    assign q_struct.cfg_set_partition[1] = {regbus.cfg_set_partition_high[1].q, regbus.cfg_set_partition_low[1].q}; \
    assign q_struct.cfg_flush_thread = {regbus.cfg_flush_thread_high.q, regbus.cfg_flush_thread_low.q};
/******************************************************************************************************************************/  

`endif