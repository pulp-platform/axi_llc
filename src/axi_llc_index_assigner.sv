// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Hong Pang <hongpang@ethz.ch>
// - Diyou Shen <dishen@ethz.ch>
// Date:   17.04.2023

module axi_llc_index_assigner #(
  /// LLC configuration struct, with static parameters.
  parameter axi_llc_pkg::llc_cfg_t  Cfg = axi_llc_pkg::llc_cfg_t'{default: '0},
  /// Type for pat_size_i and share_size_i
  parameter type partision_size_t = logic,
  /// Tyoe for start_index_i, share_index_i and index_partition_o
  parameter type index_t = logic,
  /// AXI AW or AR channel struct definition.
  parameter type addr_t = logic
) (
  /// Cache-Partition
  input partision_size_t pat_size_i,
  input partision_size_t share_size_i,
  input index_t start_index_i,
  input index_t share_index_i,
  /// The current AW or AR channel. This is the whole AXI transaction.
  /// It is split into a descriptor and a next channel, which is a smaller transfer if it accesses
  /// another cache line.
  input  addr_t addr_i,
  output index_t index_partition_o
);
  // The starting bit of index number inside an address number
  localparam int unsigned LineOffset     = Cfg.ByteOffsetLength + Cfg.BlockOffsetLength;

  // Use Modulo for index remapping
  assign index_partition_o = (pat_size_i != 0) ? start_index_i + (addr_i[LineOffset+:Cfg.IndexLength] % pat_size_i) : 
                             share_index_i + (addr_i[LineOffset+:Cfg.IndexLength] % share_size_i);

endmodule