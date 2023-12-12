// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author:
// - Hong Pang <hongpang@ethz.ch>
// Date:   25.07.2023

/// This module acts as a second part of the `TruncDual` index remapping hash function
/// The first part of it is written in `index_assigner` module, which is instantiated in
/// `burst_cutter` module. The reason behind splitting `TruncDual` is to balance logic amount
/// between the two pipeline stages for a higher operating ferquency.

module axi_llc_trdl_index #(
  /// LLC configuration struct, with static parameters.
  parameter axi_llc_pkg::llc_cfg_t  Cfg = axi_llc_pkg::llc_cfg_t'{default: '0},
  /// LLC descriptor type
  parameter type desc_t                 = logic
) (
  /// Cache-Partition
  input  desc_t desc_i,
  output desc_t desc_o
);

  localparam int unsigned IndexBase = Cfg.ByteOffsetLength + Cfg.BlockOffsetLength;

  always_comb begin
    desc_o = desc_i;
    if ((!desc_i.spm) && desc_i.tcdl_overflow && desc_i.a_x_addr[IndexBase+Cfg.IndexLength-1] && (!desc_i.pat_size[Cfg.IndexLength-1])) begin
      desc_o.index_partition = (desc_i.pat_size << 1) - 1'b1 + desc_i.index_partition - desc_i.max_tcdl_offset;
    end
  end
endmodule