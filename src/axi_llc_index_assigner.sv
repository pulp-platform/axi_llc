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
  parameter axi_llc_pkg::llc_cfg_t   Cfg       = axi_llc_pkg::llc_cfg_t'{default: '0},
  /// Type for pat_size_i and share_size_i
  parameter type partition_size_t              = logic,
  /// Index remapping hash function used in cache partitioning
  parameter axi_llc_pkg::algorithm_e RemapHash = axi_llc_pkg::Modulo,
  /// Type for start_index_i, share_index_i and index_partition_o
  parameter type index_t                       = logic,
  /// AXI AW or AR channel struct definition.
  parameter type addr_t                        = logic
) (
  /// Cache-Partition
  input partition_size_t  pat_size_i,
  input partition_size_t  share_size_i,
  input index_t           start_index_i,
  input index_t           share_index_i,
  /// The current AW or AR channel. This is the whole AXI transaction.
  /// It is split into a descriptor and a next channel, which is a smaller transfer if it accesses
  /// another cache line.
  input  addr_t           addr_i,
  /// In order to make LLC faster under TruncDual method, we balance logic depth between different pipeline stages
  /// the following `pat_size_o`, `tcdl_overflow_o`, `max_tcdl_offset_o` are fed to the `desc_o` in the upperstream 
  /// `burst_cutter` module to achieve logic depth balancing.
  output partition_size_t pat_size_o,        // partition size of the desc
  output logic            tcdl_overflow_o,   // signals overflowing situation of the desc
  output index_t          max_tcdl_offset_o, // the smallest (2^n-1) number that is larger than pat_size,
                                             // e.g. If pat_size = 85, max_tcdl_offset_o = 127.
  output index_t          index_partition_o  // remapped index result, the ouput is the determined value here if the 
                                             // remapping hash function is chosen as `Modulo` or `Mulsft`. If `TruncDual`
                                             // is used for remapping, this output value is just a intermediate result, which
                                             // is finally determined in `axi_llc_hit_miss` module due to logic balancing.
);
  // The starting bit of index number inside an address number
  localparam int unsigned LineOffset  = Cfg.ByteOffsetLength + Cfg.BlockOffsetLength;
  localparam int unsigned P           = $clog2(Cfg.NumLines);

  partition_size_t  size;
  // For Mulsft remapping hash function
  index_t           start_index, index_i, index_ror, index_remap;
  logic [2*P-1:0]   index_temp;
  // For TruncDual remapping hash function
  index_t           tcdl_offset_temp, tcdl_offset, max_index, max_tcdl_offset;
  logic             tcdl_overflow;

  assign index_i = addr_i[LineOffset+:Cfg.IndexLength];

  always_comb begin
    tcdl_overflow   = '0;
    max_tcdl_offset = '0;
    size        = (pat_size_i == 0) ? share_size_i  : pat_size_i;
    start_index = (pat_size_i == 0) ? share_index_i : start_index_i;

    case (RemapHash)
      axi_llc_pkg::Modulo: begin
        index_partition_o = index_i % size + start_index;
      end

      axi_llc_pkg::Mulsft: begin
        index_remap = index_i;
        if (index_i[0]) begin
          index_remap = ~index_i;
          index_remap[0] = 1;
        end
        index_ror = (index_remap >> (P/2)) | (index_remap << (P-P/2));
        index_temp = index_ror * size;
        index_temp = index_temp >> P;

        index_partition_o = index_temp[P-1:0] + start_index;
      end

      axi_llc_pkg::TruncDual: begin
        tcdl_overflow = 1'b0;
        max_tcdl_offset = -1;
        tcdl_offset_temp = index_i;

        for (int unsigned i = 0; i < $clog2(Cfg.NumLines); i++) begin
          if (size <= (1'b1 << i)) begin
            tcdl_offset_temp[i] = 0;
            max_tcdl_offset[i] = 0;
          end
        end

        if (tcdl_offset_temp < size) begin
          tcdl_offset = tcdl_offset_temp;
        end else begin
          tcdl_offset = tcdl_offset_temp - size;
          tcdl_overflow = 1'b1;
        end

        index_partition_o = start_index + tcdl_offset;
      end

      default: begin
        index_partition_o = index_i % size + start_index;
      end
    endcase
  end

  assign pat_size_o = size;
  assign tcdl_overflow_o = tcdl_overflow;
  assign max_tcdl_offset_o = max_tcdl_offset;

endmodule
