// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Wolfgang Roenninger <wroennin@iis.ee.ethz.ch>
// - Nicole Narr <narrn@ethz.ch>
// - Christopher Reinwardt <creinwar@ethz.ch>
// - Hong Pang <hongpang@ethz.ch>
// - Diyou Shen <dishen@ethz.ch>
// Date:   17.06.2019
// Last changed: 03.04.2023

/// # Configuration of `axi_llc`
///
/// Consumes the configuration registers of the `axi_llc`.
///
/// ## Register Map
///
/// Detailed descriptions of the individual registers can be found below.
///
/// | Name        | read/write | Description                                      |
/// |:-----------:|:----------:|:------------------------------------------------:|
/// | `CfgSpm`    | read-write | [SPM Configuration](###CfgSpm)                   |
/// | `CfgFlush`  | read-write | [Flush Configuration](###CfgFlush)               |
/// | `CommitCfg` | read-write | [Configuration Commit](###CommitCfg)             |
/// | `Flushed`   | read-only  | [Flushed Flag](###Flushed)                       |
/// | `BistOut`   | read-only  | [Tag Storage BIST Result](###BistOut)            |
/// | `SetAsso`   | read-only  | [Instantiated Set-Associativity](###SetAsso)     |
/// | `NumLines`  | read-only  | [Instantiated Number of Cache-Lines](###NumLines)|
/// | `NumBlocks` | read-only  | [Instantiated Number of Blocks](###NumBlocks)    |
/// | `Version`   | read-only  | [AXI LLC Version](###Version)                    |
///
/// ### CfgSpm
///
/// The scratch-pad-memory configuration register.
/// This register is read and writable from software.
///
/// Register Bit Map:
/// | Bits                    | Reset Value | Function                |
/// |:-----------------------:|:-----------:|:-----------------------:|
/// | `[0]`                   | `1'b0`      | SPM Configuration Set-0 |
/// | ...                     | ...         | ...                     |
/// | `[SetAssociativity-1]`  | `1'b0`      | SPM Configuration Set-X |
///
///
/// ### CfgFlush
///
/// Flush configuration register.
/// This register is read and writable from software.
///
/// This register enables flushing of individual cache sets.
///
/// Register Bit Map:
/// | Bits                    | Reset Value | Function            |
/// |:-----------------------:|:-----------:|:-------------------:|
/// | `[0]`                   | `1'b0`      | Flush Trigger Set-0 |
/// | ...                     | ...         | ...                 |
/// | `[SetAssociativity-1]`  | `1'b0`      | Flush Trigger Set-X |
/// | `[63:SetAssociativity]` | `'0`        | Reserved            |
///
///
/// ### CommitCfg
///
/// Commit configuration registers
/// This register is read and writable from software.
///
/// This register notifies the hardware that the configuration registers
/// now hold their intended value. This register must be written once after
/// writing to CfgFlush or CfgSpm.
///
/// Register Bit Map:
/// | Bits                    | Reset Value | Function             |
/// |:-----------------------:|:-----------:|:--------------------:|
/// | `[0]`                   | `1'b0`      | Commit configuration |
///
///
/// ### Flushed
///
/// Flushed status of the individual cache sets.
/// This register is read only for software.
///
/// These bits are set, if the corresponding set is in a flushed state.
/// Sets configured as SPM will have the corresponding bits set.
///
/// Register Bit Map:
/// | Bits                    | Reset Value | Function               |
/// |:-----------------------:|:-----------:|:----------------------:|
/// | `[0]`                   | `1'b0`      | Flushed Status Set-0   |
/// | ...                     | ...         | ...                    |
/// | `[SetAssociativity-1]`  | `1'b0`      | Flushed Status Set-X   |
///
///
/// ### BistOut
///
/// Build-in self-test result of the tag-storage macros.
/// This register is read only for software.
///
/// When bits are set in this register the corresponding BIST failed
/// and the associated memory seems faulty. 
///
/// Register Bit Map:
/// | Bits                    | Reset Value | Function         |
/// |:-----------------------:|:-----------:|:----------------:|
/// | `[0]`                   | `1'b0`      | BIST Error Set-0 |
/// | ...                     | ...         | ...              |
/// | `[SetAssociativity-1]`  | `1'b0`      | BIST Error Set-X |
///
///
/// ### SetAsso
///
/// Register showing the instantiated cache set-associativity.
/// This register is read only for software.
///
/// Equal to the parameter of `axi_llc_top` `SetAssociativity`.
///
/// Register Bit Map:
/// | Bits     | Reset Value        | Function          |
/// |:--------:|:------------------:|:-----------------:|
/// | `[63:0]` | `SetAssociativity` | Set-Associativity |
///
///
/// ### NumLines
///
/// Register showing the instantiated number of cache lines per set.
/// This register is read only for software.
///
/// Equal to the parameter of `axi_llc_top` `NumLines`.
///
/// Register Bit Map:
/// | Bits     | Reset Value | Function        |
/// |:--------:|:-----------:|:---------------:|
/// | `[63:0]` | `NumLines`  | Number of Lines |
///
///
/// ### `NumBlocks`
///
/// Register showing the instantiated number of blocks per cache-line.
/// This register is read only for software.
///
/// Equal to the parameter of `axi_llc_top` `NumBlocks`.
///
/// Register Bit Map:
/// | Bits     | Reset Value | Function         |
/// |:--------:|:-----------:|:----------------:|
/// | `[63:0]` | `NumBlocks` | Number of Blocks |
///
///
/// ### `Version`
///
/// Register showing the instantiated version of the module `axi_llc`.
/// This register is read only for software.
///
/// This value is defined by `axi_llc_pkg::AxiLlcVersion`.
///
/// Register Bit Map:
/// | Bits     | Reset Value                   | Function                    |
/// |:--------:|:-----------------------------:|:---------------------------:|
/// | `[63:0]` | `axi_llc_pkg::AxiLlcVersion`  | Shows the `axi_llc_version` |
///
module axi_llc_config #(
  /// Static AXI LLC configuration.
  parameter axi_llc_pkg::llc_cfg_t Cfg = axi_llc_pkg::llc_cfg_t'{default: '0},
  /// Give the exact AXI parameters in struct form. This is passed down from
  /// [`axi_llc_top`](module.axi_llc_top).
  ///
  /// Required struct definition in: `axi_llc_pkg`.
  parameter axi_llc_pkg::llc_axi_cfg_t AxiCfg = axi_llc_pkg::llc_axi_cfg_t'{default: '0},
  /// Register Width
  parameter int unsigned RegWidth = 64,
  /// Max. number of threads supported for partitioning
  parameter int unsigned MaxThread = 32,
  /// Register type for HW -> Register direction
  parameter type conf_regs_d_t  = logic,
  /// Register type for Register -> HW direction
  parameter type conf_regs_q_t  = logic,
  /// Descriptor type. This is requires as this module emits the flush descriptors.
  /// Struct definition is in [`axi_llc_top`](module.axi_llc_top).
  parameter type desc_t = logic,
  /// Address rule struct for `common_cells/addr_decode`. Is used for bypass `axi_demux`
  /// steering.
  parameter type rule_full_t = logic,
  /// Type for indicating the set associativity, same as way_ind_t in `axi_llc_top`.
  parameter type set_asso_t = logic,
  /// Type for indicating the set index, same as set_ind_t in `axi_llc_top`.
  parameter type set_t = logic,
  /// Address type for the memory regions defined for caching and SPM. The same width as
  /// the address field of the AXI4+ATOP slave and master port.
  parameter type addr_full_t = logic,
  parameter type thread_id_t = logic,
  /// Type for partition table
  parameter type partition_table_t = logic
) (
  /// Rising-edge clock
  input logic clk_i,
  /// Asynchronous reset, active low
  input logic rst_ni,
  /// Configuration registers Reg -> HW
  input  conf_regs_q_t conf_regs_i,
  /// Configuration registers HW -> Reg
  output conf_regs_d_t conf_regs_o,
  /// SPM lock.
  ///
  /// The cache only stores new tags in ways which are not SPM locked.
  output set_asso_t spm_lock_o,
  /// Flushed way flag.
  ///
  /// This signal defines all ways which are flushed and have no valid tags in them.
  /// Tags are not looked up in the ways which are flushed.
  output set_asso_t flushed_o,
  /// Flushed set flag.
  output set_t flushed_set_o,
  /// Flush descriptor output.
  ///
  /// Payload data for flush descriptors. These descriptors are generated either by configuring
  /// cache ways to SPM or when an explicit flush was triggered.
  output desc_t desc_o,
  /// Flush descriptor handshake, valid
  output logic desc_valid_o,
  /// Flush descriptor handshake, ready
  input logic desc_ready_i,
  /// AXI4 AW address from AXI4 slave port.
  ///
  /// This is for controlling the bypass multiplexer.
  input addr_full_t slv_aw_addr_i,
  /// This is for controlling the bypass multiplexer.
  input thread_id_t slv_aw_thread_id_i,
  /// AXI4 AR address from AXI4 slave port.
  ///
  /// This is for controlling the bypass multiplexer.
  input addr_full_t slv_ar_addr_i,
  /// This is for controlling the bypass multiplexer.
  input thread_id_t slv_ar_thread_id_i,
  /// Bypass selection for the AXI AW channel.
  output logic mst_aw_bypass_o,
  /// Bypass selection for the AXI AR channel.
  output logic mst_ar_bypass_o,
  /// Isolate the AXI slave port.
  ///
  /// Flush control sets this signal to prevent active cache accesses during flushing.
  /// This is to preserve data integrity when a cache flush is underway.
  output logic llc_isolate_o,
  /// The AXI salve port is isolated.
  ///
  /// This signals the flush FSM that it can safely perform the flush.
  input logic llc_isolated_i,
  /// The AW descriptor generation unit is busy.
  ///
  /// This signal is needed for the flush control so that no active functional descriptors
  /// interfere with the flush operation.
  input logic aw_unit_busy_i,
  /// The AR descriptor generation unit is busy.
  ///
  /// This signal is needed for the flush control so that no active functional descriptors
  /// interfere with the flush operation.
  input logic ar_unit_busy_i,
  /// A flush descriptor is finished flushing its cache line.
  ///
  /// This is for controlling the counters which keep track of how many flush descriptors are
  /// underway.
  input logic flush_desc_recv_i,
  /// Result data of the BIST from the tag storage macros.
  input set_asso_t bist_res_i,
  /// Result data of the BIST from the tag storage macros is valid.
  input logic bist_valid_i,
  /// Address rule for the AXI memory region which maps onto the cache.
  ///
  /// This rule is used to set the AXI LLC bypass.
  /// If all cache ways are flushed, accesses onto this address region take the bypass directly
  /// to main memory.
  input  rule_full_t axi_cached_rule_i,
  /// Address rule for the AXI memory region which maps to the scratch pad memory region.
  ///
  /// Accesses are only successful, if the corresponding way is mapped as SPM
  input  rule_full_t axi_spm_rule_i,
  /// Partition table which tells the range of index assigned to each thread:
  /// The number of entry in partition_table is one more than Maxthread because it needs to hold 
  /// the remaining part as shared region for any other thread that has not been allocated.
  /// if the corresponding entry for PID_x is 0, then it means that that thread uses the shared 
  /// region of cache. When we process data access of such thread, we should turn to 
  /// partition_table_o[MaxThread] for hit/miss information.
  output partition_table_t [MaxThread:0] partition_table_o
);
  // register macros from `common_cells`
  `include "common_cells/registers.svh"

  // Type for the Set Associativity puls padding
  localparam int unsigned SetAssoPadWidth = RegWidth - Cfg.SetAssociativity;
   
  localparam int unsigned FlushIdxWidth = cf_math_pkg::idx_width(Cfg.SetAssociativity);
  localparam int unsigned FlushSetIdxWidth = cf_math_pkg::idx_width(Cfg.NumLines);
  typedef logic [FlushIdxWidth-1:0] flush_idx_t;
  typedef logic [FlushSetIdxWidth-1:0] flush_set_idx_t;

  // Counter signals for flush control
  logic                       clear_cnt, clear_cnt_set;
  logic                       en_send_cnt, en_send_cnt_set, en_recv_cnt, en_recv_cnt_set;
  logic                       load_cnt, load_cnt_set;
  logic [Cfg.IndexLength-1:0] flush_addr,  to_recieve;
  logic [FlushIdxWidth-1:0]   flush_way,   to_recieve_set; // this is the way that is to be flushed, which corresponds to the ine index that is about to be flushed in the way-based flush
  // Trailing zero counter signals, for flush descriptor generation.
  flush_idx_t                 to_flush_nub;
  flush_set_idx_t             to_flush_set_nub;
  logic                       lzc_empty, lzc_empty_set;
  set_asso_t                  flush_way_ind;
  set_t                       flush_set_ind;

  ////////////////////////
  // AXI Bypass control //
  ////////////////////////
  // local address maps for bypass 1:Bypass 0:LLC
  rule_full_t [1:0] axi_addr_map_ar, axi_addr_map_aw;
  localparam int unsigned num_set_flush_reg = ((Cfg.NumLines/RegWidth)==0) ? 1 : $ceil(Cfg.NumLines / RegWidth);
  localparam int unsigned flushed_set_length = num_set_flush_reg * RegWidth;
  logic       [flushed_set_length-1:0] conf_regs_i_flushed_set;
  logic       [flushed_set_length-1:0] conf_regs_i_cfg_flush_set;
  logic       [Cfg.IndexLength-1:0] num_unvalid_bit_flush_set;
  assign num_unvalid_bit_flush_set = flushed_set_length - Cfg.NumLines;
  logic       [flushed_set_length-1:0] raw_flushed_set, mask_flush_set;
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/
  assign raw_flushed_set = {conf_regs_i.flushed_set3,
                            conf_regs_i.flushed_set2,
                            conf_regs_i.flushed_set1,
                            conf_regs_i.flushed_set0};
// If the user set the flush bit position of conf_regs_i.flushed_set* which is beyond the number of cache lines, those bits are ignored
  always_comb begin
    conf_regs_i_cfg_flush_set = '0;
    if (conf_regs_i.cfg_flush_thread == (MaxThread + 1)) begin
      conf_regs_i_cfg_flush_set = {Cfg.NumLines{1'b1}};
    end else if (partition_table_o[conf_regs_i.cfg_flush_thread].NumIndex) begin
      for (int unsigned k=0; k < Cfg.NumLines; k++) begin
        if ((k >= partition_table_o[conf_regs_i.cfg_flush_thread].StartIndex) && (k < (partition_table_o[conf_regs_i.cfg_flush_thread].StartIndex + partition_table_o[conf_regs_i.cfg_flush_thread].NumIndex))) begin
          conf_regs_i_cfg_flush_set[k] = 1'b1;
        end
      end
    end else if (partition_table_o[conf_regs_i.cfg_flush_thread].NumIndex == 0) begin
      for (int unsigned k=0; k < Cfg.NumLines; k++) begin
        if ((k >= partition_table_o[MaxThread].StartIndex) && (k < (partition_table_o[MaxThread].StartIndex + partition_table_o[MaxThread].NumIndex))) begin
          conf_regs_i_cfg_flush_set[k] = 1'b1;
        end
      end
    end
  end
/******************************************************************************************************************************/

  assign mask_flush_set = {Cfg.NumLines{1'b1}};
  assign conf_regs_i_flushed_set = raw_flushed_set & mask_flush_set;

  localparam int unsigned IndexBase = Cfg.ByteOffsetLength + Cfg.BlockOffsetLength;

  // "index_based_flush_d" tells whether the flush operation is index-based or way-based (1: index-based   0: way-based) 
  logic       index_based_flush_d, index_based_flush_q;
  logic       load_index_based_flush;

  assign load_index_based_flush = (index_based_flush_d != index_based_flush_q);

  `FFLARN(index_based_flush_q, index_based_flush_d, load_index_based_flush, '0, clk_i, rst_ni)
  
  localparam int unsigned valid_reg_bit = $floor(RegWidth / Cfg.IndexLength) * Cfg.IndexLength;

  logic [MaxThread * Cfg.IndexLength - 1 : 0] conf_regs_i_cfg_set_partition;

/********************************************     SET BASED CACHE PARTITIONING     ********************************************/
  assign conf_regs_i_cfg_set_partition = {conf_regs_i.cfg_set_partition31[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition30[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition29[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition28[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition27[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition26[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition25[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition24[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition23[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition22[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition21[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition20[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition19[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition18[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition17[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition16[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition15[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition14[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition13[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition12[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition11[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition10[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition9[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition8[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition7[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition6[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition5[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition4[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition3[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition2[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition1[valid_reg_bit-1:0], 
                                          conf_regs_i.cfg_set_partition0[valid_reg_bit-1:0]};
/******************************************************************************************************************************/

  logic partition_table_valid_d, partition_table_valid_q;
  `FFLARN(partition_table_valid_q, partition_table_valid_d, 1'b1, 1'b0, clk_i, rst_ni)

  logic [$clog2(MaxThread):0] flush_set_thread_d, flush_set_thread_q; 
  logic load_flush_set_thread;
  `FFLARN(flush_set_thread_q, flush_set_thread_d, load_flush_set_thread, -1, clk_i, rst_ni)
  assign load_flush_set_thread = (flush_set_thread_d != flush_set_thread_q);

  logic start_addr_valid;

  logic ar_bypass, aw_bypass;
  assign aw_bypass = (slv_aw_thread_id_i == flush_set_thread_q) || 
                    ((!partition_table_o[slv_aw_thread_id_i].NumIndex) && (flush_set_thread_q == MaxThread)) ||
                    (flush_set_thread_q == (MaxThread + 1));
  assign ar_bypass = (slv_ar_thread_id_i == flush_set_thread_q) || 
                    ((!partition_table_o[slv_ar_thread_id_i].NumIndex) && (flush_set_thread_q == MaxThread)) || 
                    (flush_set_thread_q == (MaxThread + 1));

  always_comb begin : proc_partition_table
    conf_regs_o.commit_partition_cfg_en = 1'b0;
    partition_table_valid_d = partition_table_valid_q;
    if (conf_regs_i.commit_partition_cfg) begin
      partition_table_valid_d = 0;
      conf_regs_o.commit_partition_cfg      = 1'b0;   // Clear the commit configuration flag
      conf_regs_o.commit_partition_cfg_en   = 1'b1;

/*1 For loop****************************************************************************************************/
      // partition_table_o[0].NumIndex = conf_regs_i_cfg_set_partition[Cfg.IndexLength-1:0];
      // partition_table_o[0].StartIndex = 0;

      // // if (partition_table_o[0].NumIndex >= Cfg.NumLines) begin
      // //   $error("The partition size must not be larger than number of cache lines!");
      // // end

      // for (int unsigned i = 1; i < MaxThread; i++) begin : gen_partition_table
      //   partition_table_o[i].StartIndex = partition_table_o[i-1].StartIndex + partition_table_o[i-1].NumIndex;
      //   partition_table_o[i].NumIndex = conf_regs_i_cfg_set_partition[(i+1)*Cfg.IndexLength-1 -: Cfg.IndexLength];

      //   // if ((partition_table_o[i].NumIndex >= Cfg.NumLines) || (partition_table_o[i].StartIndex >= Cfg.NumLines)) begin
      //   //   $error("The set partition configuration overflows the total cache size!");
      //   // end
      // end

      // partition_table_o[MaxThread].StartIndex = partition_table_o[MaxThread-1].StartIndex + partition_table_o[MaxThread-1].NumIndex;
      // partition_table_o[MaxThread].NumIndex = Cfg.NumLines - partition_table_o[MaxThread].StartIndex;

      // // if (partition_table_o[MaxThread].StartIndex >= Cfg.NumLines) begin
      // //   $error("Partition Configuration Error!");
      // // end
/*********************************************************************************************************/





/*2 For loop****************************************************************************************************/
      partition_table_o[0].NumIndex = conf_regs_i_cfg_set_partition[Cfg.IndexLength-1:0];
      partition_table_o[0].StartIndex = 0;

      // if (partition_table_o[0].NumIndex >= Cfg.NumLines) begin
      //   $error("The partition size must not be larger than number of cache lines!");
      // end

      start_addr_valid = conf_regs_i_cfg_set_partition[(Cfg.IndexLength<<1)-1:Cfg.IndexLength] ? 1 : 0;
      partition_table_o[1].NumIndex = conf_regs_i_cfg_set_partition[(Cfg.IndexLength<<1)-1:Cfg.IndexLength];
      partition_table_o[1].StartIndex = conf_regs_i_cfg_set_partition[(Cfg.IndexLength<<1)-1:Cfg.IndexLength] ? 
                                        (Cfg.NumLines-conf_regs_i_cfg_set_partition[(Cfg.IndexLength<<1)-1:Cfg.IndexLength]) : (Cfg.NumLines-1);

      // if (partition_table_o[1].NumIndex >= Cfg.NumLines) begin
      //   $error("The partition size must not be larger than number of cache lines!");
      // end

      for (int unsigned i = 1; i < (MaxThread>>1); i++) begin : gen_partition_table_odd_number
        partition_table_o[i<<1].StartIndex = partition_table_o[(i<<1)-2].StartIndex + partition_table_o[(i<<1)-2].NumIndex;
        partition_table_o[i<<1].NumIndex = conf_regs_i_cfg_set_partition[((i<<1)+1)*Cfg.IndexLength-1 -: Cfg.IndexLength];

        // if ((partition_table_o[i].NumIndex >= Cfg.NumLines) || (partition_table_o[i].StartIndex >= Cfg.NumLines)) begin
        //   $error("The set partition configuration overflows the total cache size! ---odd");
        // end
      end

      for (int unsigned j = 1; j < (MaxThread>>1); j++) begin : gen_partition_table_even_number
        partition_table_o[(j<<1)+1].StartIndex = start_addr_valid ? 
                                                 partition_table_o[(j<<1)-1].StartIndex - conf_regs_i_cfg_set_partition[((j<<1)+2)*Cfg.IndexLength-1 -: Cfg.IndexLength] : 
                                                 (conf_regs_i_cfg_set_partition[((j<<1)+2)*Cfg.IndexLength-1 -: Cfg.IndexLength] == 0 ? (Cfg.NumLines-1) : 
                                                  partition_table_o[(j<<1)-1].StartIndex - conf_regs_i_cfg_set_partition[((j<<1)+2)*Cfg.IndexLength-1 -: Cfg.IndexLength] + 1);
        partition_table_o[(j<<1)+1].NumIndex = conf_regs_i_cfg_set_partition[((j<<1)+2)*Cfg.IndexLength-1 -: Cfg.IndexLength];

        start_addr_valid |= (conf_regs_i_cfg_set_partition[((j<<1)+2)*Cfg.IndexLength-1 -: Cfg.IndexLength] != 0);
        // if ((partition_table_o[j].NumIndex >= Cfg.NumLines) || (partition_table_o[j].StartIndex >= Cfg.NumLines)) begin
        //   $error("The set partition configuration overflows the total cache size! ---even");
        // end
      end

      partition_table_o[MaxThread].StartIndex = partition_table_o[MaxThread-2].StartIndex + partition_table_o[MaxThread-2].NumIndex;
      partition_table_o[MaxThread].NumIndex = start_addr_valid ? partition_table_o[MaxThread-1].StartIndex - partition_table_o[MaxThread].StartIndex : 
                                              partition_table_o[MaxThread-1].StartIndex - partition_table_o[MaxThread].StartIndex + 1;

      // if (partition_table_o[MaxThread].StartIndex >= Cfg.NumLines) begin
      //   $error("Partition Configuration Error!");
      // end
/*********************************************************************************************************/

      partition_table_valid_d = 1'b1;
    end

    if (!partition_table_valid_d) begin // default partition table when not configued
      partition_table_o = '0;
      partition_table_o[MaxThread].StartIndex = partition_table_o[MaxThread-1].StartIndex + partition_table_o[MaxThread-1].NumIndex;
      partition_table_o[MaxThread].NumIndex = Cfg.NumLines - partition_table_o[MaxThread].StartIndex;
    end

    axi_addr_map_aw[0] = axi_spm_rule_i;
    axi_addr_map_aw[1] = axi_cached_rule_i;
    // Define that accesses to the SPM region always go into the `axi_llc`.
    axi_addr_map_aw[0].idx    = 32'd0;
    // define that all burst go to the bypass, if flushed is completely set
    axi_addr_map_aw[1].idx    = 32'd0;

    axi_addr_map_aw[1].idx[0] = index_based_flush_q ? aw_bypass : (&conf_regs_i.flushed); 

    // for ar channel input
    axi_addr_map_ar[0] = axi_spm_rule_i;
    axi_addr_map_ar[1] = axi_cached_rule_i;
    // Define that accesses to the SPM region always go into the `axi_llc`.
    axi_addr_map_ar[0].idx    = 32'd0;
    // define that all burst go to the bypass, if flushed is completely set
    axi_addr_map_ar[1].idx    = 32'd0;

    axi_addr_map_ar[1].idx[0] = index_based_flush_q ? ar_bypass : (&conf_regs_i.flushed);  
  end

  addr_decode #(
    .NoIndices ( 32'd2       ),
    .NoRules   ( 32'd2       ),
    .addr_t    ( addr_full_t ),
    .rule_t    ( rule_full_t )
  ) i_aw_addr_decode (
    .addr_i           ( slv_aw_addr_i   ),
    .addr_map_i       ( axi_addr_map_aw ),
    .idx_o            ( mst_aw_bypass_o ),
    .dec_valid_o      ( /*not used*/    ),
    .dec_error_o      ( /*not used*/    ),
    .en_default_idx_i ( 1'b1            ),
    .default_idx_i    ( 1'b1            )  // on decerror go through bypass
  );

  addr_decode #(
    .NoIndices ( 32'd2       ),
    .NoRules   ( 32'd2       ),
    .addr_t    ( addr_full_t ),
    .rule_t    ( rule_full_t )
  ) i_ar_addr_decode (
    .addr_i           ( slv_ar_addr_i   ),
    .addr_map_i       ( axi_addr_map_ar ),
    .idx_o            ( mst_ar_bypass_o ),
    .dec_valid_o      ( /*not used*/    ),
    .dec_error_o      ( /*not used*/    ),
    .en_default_idx_i ( 1'b1            ), // on decerror go through bypass
    .default_idx_i    ( 1'b1            )
  );

  //////////////////////////////////////////////////////////////////
  // Configuration registers: Flush Control, Performance Counters //
  //////////////////////////////////////////////////////////////////
  // States for the control FSM
  typedef enum logic [3:0] {
    FsmIdle,
    FsmWaitAx,
    FsmWaitSplitter,
    FsmInitFlush,
    FsmSendFlush,
    FsmWaitFlush,
    FsmEndFlush,
    FsmPreInit
  } flush_fsm_e;
  flush_fsm_e flush_state_d, flush_state_q;
  logic       switch_state;
  set_asso_t  to_flush_d,    to_flush_q;
  set_t       to_flush_set_d, to_flush_set_q;
  logic       load_to_flush,  load_to_flush_set;

  `FFLARN(flush_state_q, flush_state_d, switch_state, FsmPreInit, clk_i, rst_ni)
  `FFLARN(to_flush_q, to_flush_d, load_to_flush, '0, clk_i, rst_ni)
  `FFLARN(to_flush_set_q, to_flush_set_d, load_to_flush_set, '0, clk_i, rst_ni)

  // Load enable signals, so that the FF is only active when needed.
  assign switch_state  = (flush_state_d != flush_state_q);
  assign load_to_flush = (to_flush_d    != to_flush_q);
  assign load_to_flush_set = (to_flush_set_d != to_flush_set_q);

  // Constant hardware registers
  assign conf_regs_o.bist_out       = bist_res_i;
  assign conf_regs_o.set_asso       = Cfg.SetAssociativity;
  assign conf_regs_o.num_lines      = Cfg.NumBlocks;
  assign conf_regs_o.num_blocks     = Cfg.NumBlocks;
  assign conf_regs_o.version        = axi_llc_pkg::AxiLlcVersion;

  // Constant register write enables
  assign conf_regs_o.bist_out_en    = bist_valid_i;
  assign conf_regs_o.set_asso_en    = 1'b1;
  assign conf_regs_o.num_lines_en   = 1'b1;
  assign conf_regs_o.num_blocks_en  = 1'b1;
  assign conf_regs_o.version_en     = 1'b1;

  logic [flushed_set_length-1:0] conf_regs_o_flushed_set;

  always_comb begin : proc_axi_llc_cfg
    // Default assignments
    // Registers
    conf_regs_o.cfg_spm       = conf_regs_i.cfg_spm;
    conf_regs_o.cfg_flush     = conf_regs_i.cfg_flush;
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/
    conf_regs_o.cfg_flush_thread = conf_regs_i.cfg_flush_thread;
    conf_regs_o.commit_cfg    = conf_regs_i.commit_cfg;
    conf_regs_o.flushed       = conf_regs_i.flushed;
    conf_regs_o.flushed_set0   = conf_regs_i.flushed_set0;
    conf_regs_o.flushed_set1   = conf_regs_i.flushed_set1;
    conf_regs_o.flushed_set2   = conf_regs_i.flushed_set2;
    conf_regs_o.flushed_set3   = conf_regs_i.flushed_set3;
    // Register enables
    conf_regs_o.cfg_spm_en    = 1'b1;   // default one
    conf_regs_o.cfg_flush_en  = 1'b1;   // default one
    conf_regs_o.cfg_flush_thread_en = 1'b1;
    conf_regs_o.commit_cfg_en = 1'b0;   // default disabled
    conf_regs_o.flushed_en    = 1'b0;   // default disabled
    conf_regs_o.flushed_set0_en  = 1'b0;
    conf_regs_o.flushed_set1_en  = 1'b0;
    conf_regs_o.flushed_set2_en  = 1'b0;
    conf_regs_o.flushed_set3_en  = 1'b0;
/******************************************************************************************************************************/

    // Flush state machine
    flush_state_d  = flush_state_q;
    // Slave port is isolated during flush.
    llc_isolate_o  = 1'b1;
    // To flush register, holds the ways which have to be flushed.
    to_flush_d     = to_flush_q;
    to_flush_set_d = to_flush_set_q;
    index_based_flush_d = index_based_flush_q;
    flush_set_thread_d = flush_set_thread_q;
    // Emit flush descriptors.
    desc_valid_o   = 1'b0;
    // Default signal definitions for the descriptor send and receive counter control.
    clear_cnt      = 1'b0;
    en_send_cnt    = 1'b0;
    en_recv_cnt    = 1'b0;
    load_cnt       = 1'b0;
    clear_cnt_set      = 1'b0;
    en_send_cnt_set    = 1'b0;
    en_recv_cnt_set    = 1'b0;
    load_cnt_set       = 1'b0;

    // FSM for controlling the AW AR input to the cache and flush control
    unique case (flush_state_q)
      FsmIdle:  begin
        // this state is normal operation, allow Cfg editing of the fields `CfgSpm` and `CfgFlush`
        // and do not isolate main AXI
        conf_regs_o.cfg_spm_en    = 1'b0;
        conf_regs_o.cfg_flush_en  = 1'b0;
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/
        conf_regs_o.cfg_flush_thread_en = 1'b0;
/******************************************************************************************************************************/
        llc_isolate_o             = 1'b0;
        flush_set_thread_d        = -1;
        // Change state, if there is a flush request, i.e. CommitCfg was set
        if (conf_regs_i.commit_cfg) begin
          conf_regs_o.commit_cfg      = 1'b0;   // Clear the commit configuration flag
          conf_regs_o.commit_cfg_en   = 1'b1;
          flush_state_d               = FsmWaitAx;
        end
      end
      FsmWaitAx: begin
        // wait until main AXI is free
        if (llc_isolated_i) begin
          flush_state_d = FsmWaitSplitter;
        end
      end
      FsmWaitSplitter: begin
        // wait till none of the splitter units still have vectors in them
        if (!aw_unit_busy_i && !ar_unit_busy_i) begin
          flush_state_d = FsmInitFlush;
        end
      end
      FsmInitFlush: begin
        // this state determines which cache line should be flushed
        if (conf_regs_i.cfg_flush_thread != -1) begin
          to_flush_set_d          = conf_regs_i_cfg_flush_set & ~conf_regs_i_flushed_set;
          index_based_flush_d = 1'b1; //meaning that the current flush operation is index-based
          flush_set_thread_d  = partition_table_o[conf_regs_i.cfg_flush_thread].NumIndex ? conf_regs_i.cfg_flush_thread : MaxThread;
          if (to_flush_set_d == '0) begin
            // nothing to flush, go to idle
            flush_state_d = FsmIdle;
            index_based_flush_d = 1'b0;
            flush_set_thread_d = -1;

/********************************************     SET BASED CACHE PARTITIONING     ********************************************/
            conf_regs_o.cfg_flush_thread = -1;
/******************************************************************************************************************************/
          end else begin
            flush_state_d = FsmSendFlush;
            load_cnt_set      = 1'b1;
          end
        // this state determines which cache way should be flushed
        // it also sets up the counters for state-keeping how far
        // the flush operation has progressed
        // define if the user requested a flush       
        end else if (|conf_regs_i.cfg_flush) begin
          to_flush_d              = conf_regs_i.cfg_flush & ~conf_regs_i.flushed;
          index_based_flush_d = 1'b0; //meaning that the current flush operation is way-based
          if (to_flush_d == '0) begin
            // nothing to flush, go to idle
            flush_state_d = FsmIdle;
            
            conf_regs_o.cfg_flush = set_asso_t'(1'b0);
          end else begin
            flush_state_d = FsmSendFlush;
            load_cnt      = 1'b1;
          end
        end else begin
          to_flush_d              = conf_regs_i.cfg_spm & ~conf_regs_i.flushed;
          conf_regs_o.flushed     = conf_regs_i.cfg_spm & conf_regs_i.flushed;
          conf_regs_o.flushed_en  = 1'b1;
          index_based_flush_d = 1'b0; //meaning that the current flush operation is way-based
          if (to_flush_d == '0) begin
            // nothing to flush, go to idle
            flush_state_d = FsmIdle;
            
            conf_regs_o.cfg_flush = set_asso_t'(1'b0);
          end else begin
            flush_state_d = FsmSendFlush;
            load_cnt      = 1'b1;
          end
        end
      end
      FsmSendFlush: begin
        // this state sends all required flush descriptors to the specified way
        desc_valid_o = 1'b1;
        // transaction
        if (desc_ready_i) begin
          // determine the type of flush operation (index-based or way-based)
          // index-based flush
          if (index_based_flush_q == 1'b1) begin
            // last flush descriptor for this cache line?
            if (flush_way == {FlushIdxWidth{1'b1}}) begin
              flush_state_d = FsmWaitFlush;
            end else begin
              en_send_cnt_set = 1'b1;
            end
          //way-based operation
          end else begin
            // last flush descriptor for this way?
            if (flush_addr == {Cfg.IndexLength{1'b1}}) begin
              flush_state_d = FsmWaitFlush;
            end else begin
              en_send_cnt = 1'b1;
            end
          end
        end
        // further enable the receive counter if the input signal is high
        if (flush_desc_recv_i) begin
          if (index_based_flush_q == 1'b1) begin
            en_recv_cnt_set = 1'b1;
          end else begin
            en_recv_cnt = 1'b1;
          end
        end
      end
      FsmWaitFlush : begin
        // this state waits till all flush operations have exited the cache, then `FsmEndFlush`
        if (flush_desc_recv_i) begin
          if (index_based_flush_q == 1'b1) begin
            if(to_recieve_set == {FlushIdxWidth{1'b0}}) begin
              flush_state_d = FsmEndFlush;
            end else begin
              en_recv_cnt_set = 1'b1;
            end
          end else begin
            if(to_recieve == {Cfg.IndexLength{1'b0}}) begin
              flush_state_d = FsmEndFlush;
            end else begin
              en_recv_cnt = 1'b1;
            end
          end
        end
      end
      FsmEndFlush: begin
        // this state decides, if we have other ways to flush, or if we can go back to idle
        if (index_based_flush_q == 1'b1) begin
          clear_cnt_set = 1'b1;
          if (to_flush_set_q == flush_set_ind) begin
            flush_state_d = FsmIdle;
            // index_based_flush_d = 1'b0; // reset flush type
            // reset the flushed register to SPM as new requests can enter the cache
/********************************************     SET BASED CACHE PARTITIONING     ********************************************/
            conf_regs_o.flushed_set0    = 64'b0; /**************** temperarily not used since SPM is way-based ****************/ 
            conf_regs_o.flushed_set1    = 64'b0; /**************** temperarily not used since SPM is way-based ****************/ 
            conf_regs_o.flushed_set2    = 64'b0; /**************** temperarily not used since SPM is way-based ****************/ 
            conf_regs_o.flushed_set3    = 64'b0; /**************** temperarily not used since SPM is way-based ****************/ 
            conf_regs_o.flushed_set0_en = 1'b1; 
            conf_regs_o.flushed_set1_en = 1'b1; 
            conf_regs_o.flushed_set2_en = 1'b1; 
            conf_regs_o.flushed_set3_en = 1'b1; 
            to_flush_set_d              = set_t'(1'b0);
            // Reset the `CfgFlushTherad` register, load enable is default '1
            conf_regs_o.cfg_flush_thread  = -1;
          end else begin
            // there are still cache lines to flush
            flush_state_d = FsmInitFlush;
            conf_regs_o_flushed_set = conf_regs_i_flushed_set | flush_set_ind;
            conf_regs_o.flushed_set0 = conf_regs_o_flushed_set[1*RegWidth-1:0*RegWidth];
            conf_regs_o.flushed_set1 = conf_regs_o_flushed_set[2*RegWidth-1:1*RegWidth];
            conf_regs_o.flushed_set2 = conf_regs_o_flushed_set[3*RegWidth-1:2*RegWidth];
            conf_regs_o.flushed_set3 = conf_regs_o_flushed_set[4*RegWidth-1:3*RegWidth];
            conf_regs_o.flushed_set0_en = 1'b1;
            conf_regs_o.flushed_set1_en = 1'b1;
            conf_regs_o.flushed_set2_en = 1'b1;
            conf_regs_o.flushed_set3_en = 1'b1;
/******************************************************************************************************************************/
          end
        end else begin
          clear_cnt = 1'b1;
          if (to_flush_q == flush_way_ind) begin
            flush_state_d = FsmIdle;
            // reset the flushed register to SPM as new requests can enter the cache
            conf_regs_o.flushed     = conf_regs_i.cfg_spm;
            conf_regs_o.flushed_en  = 1'b1;
            to_flush_d    = set_asso_t'(1'b0);
            // Clear the `CfgFlush` register, load enable is default '1
            conf_regs_o.cfg_flush = set_asso_t'(1'b0);
          end else begin
            // there are still ways to flush
            flush_state_d = FsmInitFlush;
            conf_regs_o.flushed     = conf_regs_i.flushed | flush_way_ind;
            conf_regs_o.flushed_en  = 1'b1;
          end
        end
      end
      FsmPreInit: begin
        // The state machine starts in this state. It remains in this state until the
        // BIST of the tag storage macros is finished.
        // When the result of the BIST comes in, it is also written to the SPM configuration.
        // However does not trigger a flush. This is to have per default tag-macros with errors
        // to be mapped as SPM, so that they are not used. However they can be enabled using
        // the normal SPM configuration.
        if (bist_valid_i) begin
          flush_state_d = FsmIdle;
          conf_regs_o.cfg_spm     = bist_res_i;
          // No load specified for CfgSpm, as per default the reg is loaded anyway.
          conf_regs_o.flushed     = bist_res_i;
          conf_regs_o.flushed_en  = 1'b1;
        end
      end
      default: /*do nothing*/;
    endcase
  end

  ////////////////////////
  // Output assignments //
  ////////////////////////
  // Flush descriptor output is static, except for the fields defined here.
  localparam int unsigned FlushAddrShift = Cfg.BlockOffsetLength + Cfg.ByteOffsetLength;
  set_asso_t flush_way_onehot;
  assign flush_way_onehot = set_asso_t'(8'd1) << flush_way;

  always_comb begin
    if (index_based_flush_q == 1'b1) begin
      desc_o           = '0;
      desc_o.a_x_addr  = addr_full_t'(to_flush_set_nub) << FlushAddrShift;
      desc_o.a_x_len   = axi_pkg::len_t'(Cfg.NumBlocks - 32'd1);
      desc_o.a_x_size  = axi_pkg::size_t'($clog2(Cfg.BlockSize / 32'd8));
      desc_o.a_x_burst = axi_pkg::BURST_INCR;
      desc_o.x_resp    = axi_pkg::RESP_OKAY;
      desc_o.way_ind   = flush_way_onehot;
      desc_o.flush     = 1'b1;
    end else begin
      desc_o           = '0;
      desc_o.a_x_addr  = addr_full_t'(flush_addr) << FlushAddrShift;
      desc_o.a_x_len   = axi_pkg::len_t'(Cfg.NumBlocks - 32'd1);
      desc_o.a_x_size  = axi_pkg::size_t'($clog2(Cfg.BlockSize / 32'd8));
      desc_o.a_x_burst = axi_pkg::BURST_INCR;
      desc_o.x_resp    = axi_pkg::RESP_OKAY;
      desc_o.way_ind   = flush_way_ind;
      desc_o.flush     = 1'b1;
    end
  end

  // Configuration registers which are used in other modules.
  assign spm_lock_o = conf_regs_i.cfg_spm;
  assign flushed_o  = conf_regs_i.flushed;
  assign flushed_set_o = conf_regs_i_flushed_set;

  // This trailing zero counter determines which way should be flushed next.
  // Dtermining next cache line to flush (for index-based flush)
   lzc #(
    .WIDTH ( Cfg.NumLines ),
    .MODE  ( 1'b0         )
  ) i_lzc_flush_set (
    .in_i    ( to_flush_set_q   ),
    .cnt_o   ( to_flush_set_nub ),
    .empty_o ( lzc_empty_set    )
  );

  // Dtermining next way to flush (for way-based flush)
  lzc #(
    .WIDTH ( Cfg.SetAssociativity ),
    .MODE  ( 1'b0                 )
  ) i_lzc_flush (
    .in_i    ( to_flush_q   ),
    .cnt_o   ( to_flush_nub ),
    .empty_o ( lzc_empty    )
  );
  // Decode flush way indicator from binary to one-hot signal.
  assign flush_way_ind = (lzc_empty) ? set_asso_t'(1'b0) : set_asso_t'(64'd1) << to_flush_nub;
  assign flush_set_ind = (lzc_empty_set) ? set_t'(1'b0) : set_t'(256'd1) << to_flush_set_nub;

  ///////////////////////////////
  // Counter for flush control //
  ///////////////////////////////
  // This counts how many flush descriptors have been sent.
  counter #(
    .WIDTH ( Cfg.IndexLength )
  ) i_flush_send_counter (
    .clk_i      ( clk_i                   ),
    .rst_ni     ( rst_ni                  ),
    .clear_i    ( clear_cnt               ),
    .en_i       ( en_send_cnt             ),
    .load_i     ( load_cnt                ),
    .down_i     ( 1'b0                    ),
    .d_i        ( {Cfg.IndexLength{1'b0}} ),
    .q_o        ( flush_addr              ),
    .overflow_o ( /*not used*/            )
  );

  // This counts how many flush descriptors are not done flushing.
  counter #(
    .WIDTH ( Cfg.IndexLength )
  ) i_flush_recv_counter (
    .clk_i      ( clk_i                   ),
    .rst_ni     ( rst_ni                  ),
    .clear_i    ( clear_cnt               ),
    .en_i       ( en_recv_cnt             ),
    .load_i     ( load_cnt                ),
    .down_i     ( 1'b1                    ),
    .d_i        ( {Cfg.IndexLength{1'b1}} ),
    .q_o        ( to_recieve              ),
    .overflow_o ( /*not used*/            )
  );
  counter #(
    .WIDTH ( FlushIdxWidth )
  ) i_flush_set_send_counter (
    .clk_i      ( clk_i                   ),
    .rst_ni     ( rst_ni                  ),
    .clear_i    ( clear_cnt_set           ),
    .en_i       ( en_send_cnt_set         ),
    .load_i     ( load_cnt_set            ),
    .down_i     ( 1'b0                    ),
    .d_i        ( {FlushIdxWidth{1'b0}}   ),
    .q_o        ( flush_way               ),
    .overflow_o ( /*not used*/            )
  );

  // This counts how many flush descriptors are not done flushing.
  counter #(
    .WIDTH ( FlushIdxWidth )
  ) i_flush_set_recv_counter (
    .clk_i      ( clk_i                   ),
    .rst_ni     ( rst_ni                  ),
    .clear_i    ( clear_cnt_set           ),
    .en_i       ( en_recv_cnt_set         ),
    .load_i     ( load_cnt_set            ),
    .down_i     ( 1'b1                    ),
    .d_i        ( {FlushIdxWidth{1'b1}}   ),
    .q_o        ( to_recieve_set          ),
    .overflow_o ( /*not used*/            )
  );

// pragma translate_off
`ifndef VERILATOR
  initial begin : proc_check_params
    set_asso      : assert (Cfg.SetAssociativity <= RegWidth) else
        $fatal(1, $sformatf("LlcCfg: The maximum set associativity (%0d) has to be smaller than \
                             or equal to the the configuration register width in bits: %0d (dec).\n \
                             Reason: Set associativity has to fit inside one register.",
                             Cfg.SetAssociativity, RegWidth));
  end

  initial begin : proc_llc_hello
    @(posedge rst_ni);
    $display("###############################################################################");
    $display("###############################################################################");
    $display("AXI LLC module instantiated:");
    $display("%m");
    $display("###############################################################################");
    $display("Cache Size parameters:");
    $display("Max Cache/SPM size:                (decimal): %d KiB", Cfg.SPMLength/1024);
    $display("SetAssociativity (Number of Ways)  (decimal): %d", Cfg.SetAssociativity  );
    $display("Number of Cache Lines per Set      (decimal): %d", Cfg.NumLines          );
    $display("Number of Blocks per Cache Line    (decimal): %d", Cfg.NumBlocks         );
    $display("Block Size in Bits                 (decimal): %d", Cfg.BlockSize         );
    $display("Tag Length of AXI Address          (decimal): %d", Cfg.TagLength         );
    $display("Index Length of AXI Address        (decimal): %d", Cfg.IndexLength       );
    $display("Block Offset Length of AXI Address (decimal): %d", Cfg.BlockOffsetLength );
    $display("Byte Offset Length of AXI Address  (decimal): %d", Cfg.ByteOffsetLength  );
    $display("###############################################################################");
    $display("AXI4 Port parameters:");
    $display("Slave port (CPU):");
    $display("ID   width (decimal): %d", AxiCfg.SlvPortIdWidth );
    $display("ADDR width (decimal): %d", AxiCfg.AddrWidthFull  );
    $display("DATA width (decimal): %d", AxiCfg.DataWidthFull  );
    $display("STRB width (decimal): %d", AxiCfg.DataWidthFull/8);
    $display("Master port (memory):");
    $display("ID   width (decimal): %d", AxiCfg.SlvPortIdWidth + 1);
    $display("ADDR width (decimal): %d", AxiCfg.AddrWidthFull     );
    $display("DATA width (decimal): %d", AxiCfg.DataWidthFull     );
    $display("STRB width (decimal): %d", AxiCfg.DataWidthFull/8   );
    $display("Address mapping information:");
    $display("Cached region Start address (hex): %h", axi_cached_rule_i.start_addr );
    $display("Cached region End   address (hex): %h", axi_cached_rule_i.end_addr   );
    $display("SPM    region Start address (hex): %h", axi_spm_rule_i.start_addr    );
    $display("SPM    region End   address (hex): %h", axi_spm_rule_i.end_addr      );
    $display("###############################################################################");
    $display("###############################################################################");
  end
`endif
// pragma translate_on
endmodule
