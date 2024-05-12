// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Wolfgang Roenninger <wroennin@iis.ee.ethz.ch>
// - Hong Pang <hongpang@ethz.ch>
// - Diyou Shen <dishen@ethz.ch>
// Date:   30.04.2019

/// Contains the top_level of the axi_llc with structs as AXI connections.
/// The standard configuration is a cache size of 512KByte with a set-associativity
/// of 8, and line length of 8 blocks, one block equals the AXI data width of the
/// master port. Each set, also called way, can be configured to be directly
/// accessible as scratch pad memory. This can be done by setting the corresponding
/// register.
///
/// AXI ports: The FULL AXI ports, have different ID widths. The master ports ID is
///            one bit wider than the slave port. The reason is the `axi_mux` which
///            controls the AXI bypass.
///
/// # AXI4+ATOP Last Level Cache (LLC)
///
/// This is the top-level module of `axi_llc`.
///
/// ## Overview
///
/// Features:
/// * Write-back last level cache.
/// * Multiple outstanding transactions, priority for cache hits.
/// * Hot configurable scratch-pad memory.
///   * Individual cache sets can be configured to be direct addressable scratch pad while
///     cache is in operation.
///   * Contend of set is flushed back to memory.
/// * Bypass for non-cached memory accesses. (Bypass active when all sets are configured as SPM.)
/// * User configurable cache flush: See [`axi_llc_config`](module.axi_llc_config)
/// * Performance counters: See [`axi_llc_config`](module.axi_llc_config)
///
/// ![Block-diagram he Top Level of the LLC.](axi_llc_top.svg "Block-diagram of the Top Level of the LLC.")
///
///
/// It is required to provide the detailed AXI4+ATOP and configuration register structs as parameters.
/// The structs follow the naming scheme *port*\_*xx*\_chan_t. Where *port* stands for the
/// respective port and have the values *slv* and *mst*. In addition the respective request
/// and response structs have to be given. The address rule struct from the
/// `common_cells/addr_decode` has to be specified for the AXI4+ATOP ports as they are
/// used internally to provide address mapping for the AXI transfers onto the different SPM and
/// cache regions.
///
/// The overall size in bytes of the LLC in byte can be calculated with:
///
/// ![Equation axi_llc size](axi_llc_size_equ.gif "Equation axi_llc size")
///
/// ## Operation principle
///
/// The AXI4 protocol issues its transfers in a bursted fashion. The architecture of the LLC uses
/// most of the control information provided by the protocol to implement the cache control in a
/// decentralized way. For this it uses a data-flow driven control scheme.
///
/// The premise is that an AXI transfer gets translated into a number of descriptors which then flow
/// through a pipeline. Each descriptor maps the specific operation onto a cache line and basically
/// translates long bursts onto shorter ones which exactly map onto a single cache line.
/// For example when an AXI4+ATOP burst wants to write on three cache-lines, the control beat gets
/// translated into three descriptors which then flow through the pipeline.
///
/// Example of a write transfer when it accesses the cache:
/// * AW beat is valid on the slave port of the LLC.
/// * AW address gets decoded in the configuration module.
/// * AW enters the split unit and first descriptor enters the spill register.
/// * Request gets issued to the tag-storage (comprised of one SRAM block per set of the cache).
/// * Hit or miss and exact cacheline location (set) is determined. The dirty flag is set.
///   Cache line is locked for other following descriptors. Lock is taken away when descriptor
///   is finished with operation on this cache line.
/// * On hit:
///   * Descriptor goes directly to the write unit, takes hit bypass.
///   * Allows hits to overtake misses, if the AXI ID is different.
/// * On miss:
///   * Descriptor goes to the eviction/refill pipeline.
///   * If the cache-line is dirty it gets evicted by issuing a write request on the AXI4+ATOP
///     master port.
///   * Cache line is refilled from main memory.
///   * Descriptor is transferred into the write unit.
///  * Write unit sends the W beats from the CPU towards the data storage.
///  * Write unit issues a B beat back to the CPU, when the last W beat of the AXI4+ATOP
///    transfer is sent to the LLC data storage.
///
/// Reads are analogous to writes and use the same pipeline.
///
/// The hit bypass allows AXI4+ATOP transaction hitting onto the cache to overtake ones that are in
/// the miss pipeline.
/// Example: This has the advantage that a short write transaction from a CPU can overtake a long
///          read transactions (DMA). The feature requires that the AXI4+ATOP IDs of the transfers
///          are different.
///
/// Following table shows the internal struct which is used to define a
/// [cache descriptor](type llc_desc_t).
/// Part of the descriptor uses directly types defined in `axi_pkg`.
/// The other fields get defined when instantiating the design.
///
/// | Name              | Type               | Function |
/// |:----------------- |:------------------ |:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
/// | `a_x_id`          | `axi_slv_id_t`     | The AXI4+ATOP ID of the burst entering through the slave port of the design. It has the same width as the slave port AXI ID.                                                                                                                                                                                |
/// | `a_x_addr`        | `axi_addr_t`       | The address of the descriptor. Aligned to the corresponding cache block.                                                                                                                                                                                                                                    |
/// | `a_x_len`         | `axi_pkg::len_t`   | AXI4+ATOP burst length field. Corresponds to the number of beats which map onto the cache line accessed by this descriptor. Gets set in the splitting unit which does the mapping onto the cache line.                                                                                                      |
/// | `a_x_size`        | `axi_pkg::size_t`  | AXI4+ATOP size field. This is important for the write and read unit to find the exact block and byte offset. Used for calculating the block location in the data storage.                                                                                                                                   |
/// | `a_x_burst`       | `axi_pkg::burst_t` | AXI4+ATOP burst type. This is important for the splitter unit as well as the read and write unit. It determines the descriptor field `a_x_addr`.                                                                                                                                                            |
/// | `a_x_lock`        | `logic`            | AXI4+ATOP lock signal. Passed further in the miss pipeline when the line gets evicted or refilled.                                                                                                                                                                                                          |
/// | `a_x_cache`       | `axi_pkg::cache_t` | AXI4+ATOP cache signal. The cache only supports write back mode.                                                                                                                                                                                                                                            |
/// | `a_x_prot`        | `axi_pkg::prot_t`  | AXI4+ATOP protection signal. Passed further in the miss pipeline.                                                                                                                                                                                                                                           |
/// | `x_resp`          | `axi_pkg::resp_t`  | AXI4+ATOP response signal. This tells if we try to make un-allowed accesses onto address regions which are not mapped to either SPM nor cache. When this signal gets set somewhere in the pipeline, all following modules will pass the descriptor along and absorb the corresponding beats from the ports. |
/// | `x_last`          | `logic`            | AXI4+ATOP last flag. Defines if the read or write unit send back the response.                                                                                                                                                                                                                              |
/// | `spm`             | `logic`            | This field signals that the descriptor is of type SPM. It will not make a lookup in the hit/miss detection and utilize the hit bypass if applicable.                                                                                                                                                        |
/// | `rw`              | `logic`            | This field determines if the descriptor makes a write access `1'b1` or read access `1'b0`.                                                                                                                                                                                                                  |
/// | `way_ind`         | `logic`            | The way indicator. Is a vector of width equal of the set-associativity. Decodes the index of the cache set where the descriptor should make an access.                                                                                                                                                      |
/// | `evict`           | `logic`            | The eviction flag. The descriptor missed and the line at the position was determined dirty by the detection. The evict unit will write back the dirty cache-line to the main memory.                                                                                                                        |
/// | `evict_tag`       | `logic`            | The eviction tag. As the field `a_x_addr` has the new tag in it, it is used to send back the right address to the main memory during eviction.                                                                                                                                                              |
/// | `refill`          | `logic`            | The refill flag. The descriptor will trigger a read transaction to the main memory, refilling the cache-line.                                                                                                                                                                                               |
/// | `flush`           | `logic`            | The flush flag. This only gets set when a way should be flushed. It gets only set by descriptors coming from the configuration module.                                                                                                                                                                      |
/// | `patid`           | `logic`            | The partition ID. This indicates the current visited partition. It gets filled in burst cutter by reading from the AXI AW/AR user signals.                                                                                                                                                                  |
/// | `index_partition` | `logic`            | The remapped index for cache partitioning. This will be calculated based on index bits from input address and partition's information.                                                                                                                                                                      |
/// | `pat_size`        | `logic`            | This field is used when `TruncDual` remapping hash function is activated. It signals the size of the partition region which should be accessed, used for remapped index calculation when employing `TruncDual` hash function for index remapping                                                            |
/// | `tcdl_overflow`   | `logic`            | This field is used when `TruncDual` remapping hash function is activated. It signals whether the remapped index from the first part (in `index_assigner` module) faces an overlapping situation                                                                                                             |
/// | `max_tcdl_offset` | `logic`            | This field is used when `TruncDual` remapping hash function is activated. It signals the smallest (2^n-1) number that is larger than pat_size, e.g. If pat_size = 85, max_tcdl_offset_o = 127.                                                                                                              |
module axi_llc_top #(
  /// The set-associativity of the LLC.
  ///
  /// This parameter determines how many ways/sets will be instantiated.
  ///
  /// Restrictions:
  /// * Minimum value: `32'd1`
  /// * Maximum value: `32'd63`
  /// The maximum value depends on the internal register width
  parameter int unsigned SetAssociativity = 32'd0,
  /// Number of cache lines per way.
  ///
  /// Restrictions:
  /// * Minimum value: `32'd2`
  /// * Has to be a power of two.
  ///
  /// Note on restrictions:
  /// The reason is that in the address, at least one bit has to be mapped onto a cache-line index.
  /// This is a limitation of the *system verilog* language, which requires at least one bit wide
  /// fields inside of a struct. Further this value has to be a power of 2. This has to do with the
  /// requirement that the address mapping from the address onto the cache-line index has to be
  /// continuous.
  parameter int unsigned NumLines        = 32'd0,
  /// Number of blocks (words) in a cache line.
  ///
  /// The width of a block is the same as the data width of the AXI4+ATOP ports. Defined with
  /// parameter `AxiCfg.DataWidthFull` in bits.
  ///
  /// Restrictions:
  /// * Minimum value: 32'd2
  /// * Has to be a power of two.
  ///
  /// Note on restrictions:
  /// The same restriction as of parameter `NumLines` applies.
  parameter int unsigned NumBlocks       = 32'd0,
  /// Tag & data sram ECC enabling parameter, bool type
  parameter bit          EnableEcc       = 0,
  /// Cache partitioning enabling parameter, bool type.
  parameter logic        CachePartition  = 1,
  /// Max. number of partitions supported for partitioning.
  ///
  /// Restrictions:
  /// * Minimum value: 32'd2
  ///
  /// Note on restrictions:
  /// The reason is the doubld-sided calculation for filling the partition table. The calculation needs
  /// two partition: one on each side to correctly configure the partitions.
  parameter int unsigned MaxPartition    = 32'd0,
  /// Index remapping hash function used in cache partitioning
  parameter axi_llc_pkg::algorithm_e RemapHash = axi_llc_pkg::Modulo,
  /// AXI4+ATOP ID field width of the slave port.
  /// The ID field width of the master port is this parameter + 1.
  parameter int unsigned AxiIdWidth      = 32'd0,
  /// AXI4+ATOP address field width of both the slave and master port.
  parameter int unsigned AxiAddrWidth    = 32'd0,
  /// AXI4+ATOP data field width of both the slave and the master port.
  parameter int unsigned AxiDataWidth    = 32'd0,
  /// AXI4+ATOP user field width of both the slave and the master port.
  /// Here, "user" data part of AXI channel is used for signaling the
  /// partition ID from which the data access is issued. AxiUserWidth 
  /// should be equal to PIDWidth, which signals the partition ID. 
  /// For current system, the upper bound of the number of partition
  /// running is 256, so AxiUserWidth should be 8.
  parameter int unsigned AxiUserWidth    = 32'd0, 
  /// Internal register width
  parameter int unsigned RegWidth        = 64,
  /// AXI4 User signal offset
  parameter int unsigned AxiUserIdMsb    = AxiUserWidth-1,
  parameter int unsigned AxiUserIdLsb    = 0,
  /// Data SRAM ECC granularity
  parameter int unsigned DataEccGranularity = 32,
  /// Tag SRAM ECC granularity
  parameter int unsigned TagEccGranularity  = 0,

  /// Register type for HW -> Register direction
  parameter type conf_regs_d_t  = logic,
  /// Register type for Register -> HW direction
  parameter type conf_regs_q_t  = logic,
  /// AXI4+ATOP request type on the slave port.
  /// Expected format can be defined using `AXI_TYPEDEF_REQ_T.
  parameter type slv_req_t      = logic,
  /// AXI4+ATOP response type on the slave port.
  /// Expected format can be defined using `AXI_TYPEDEF_RESP_T.
  parameter type slv_resp_t     = logic,
  /// AXI4+ATOP request type on the master port.
  /// Expected format can be defined using `AXI_TYPEDEF_REQ_T.
  parameter type mst_req_t      = logic,
  /// AXI4+ATOP response type on the master port.
  /// Expected format can be defined using `AXI_TYPEDEF_RESP_T.
  parameter type mst_resp_t     = logic,
  /// Full AXI4+ATOP Port address decoding rule
  parameter type rule_full_t    = axi_pkg::xbar_rule_64_t,
  /// Whether to print SRAM configs
  parameter bit  PrintSramCfg   = 0,
  /// Whether to print config of LLC
  parameter bit  PrintLlcCfg    = 0,
  /// Dependent parameter, do **not** overwrite!
  /// Address type of the AXI4+ATOP ports.
  /// The address fields of the rule type have to be the same.
  parameter type axi_addr_t     = logic[AxiAddrWidth-1:0],
  /// Dependent parameter, do **not** overwrite!
  /// Data type of set associativity wide registers
  parameter type way_ind_t      = logic[SetAssociativity-1:0],
  /// Dependent parameter, do **not** overwrite!
  /// Data type of set wide registers
  parameter type set_ind_t      = logic[NumLines-1:0]
) (
  /// Rising-edge clock of all ports.
  input logic clk_i,
  /// Asynchronous reset, active low
  input logic rst_ni,
  /// Test mode activate, active high.
  input logic test_i,
  /// AXI4+ATOP slave port request, CPU side
  input slv_req_t slv_req_i,
  /// AXI4+ATOP slave port response, CPU side
  output slv_resp_t slv_resp_o,
  /// AXI4+ATOP master port request, memory side
  output mst_req_t mst_req_o,
  /// AXI4+ATOP master port response, memory side
  input mst_resp_t mst_resp_i,
  /// Configuration registers Registers -> HW
  input  conf_regs_q_t conf_regs_i,
  /// Configuration registers HW -> Registers
  output conf_regs_d_t conf_regs_o,
  /// Start of address region mapped to cache
  input axi_addr_t cached_start_addr_i,
  /// End of address region mapped to cache
  input axi_addr_t cached_end_addr_i,
  /// SPM start address
  ///
  /// The end address is automatically calculated by the configuration of the LLC.
  /// `spm_end_addr` = `spm_start_addr_i` +
  ///     `SetAssociativity` * `NumLines` * `NumBlocks` * (`AxiCfg.DataWidthFull/8`)
  input axi_addr_t spm_start_addr_i,
  /// Events output, for tracked events see `axi_llc_pkg`.
  ///
  /// When not used, leave open.
  output axi_llc_pkg::events_t axi_llc_events_o,

  // ecc signals
  input  logic [Cfg.SetAssociativity-1:0][(Cfg.TagEccGranularity ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)+(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]  scrub_trigger_i,
  output logic [Cfg.SetAssociativity-1:0][(Cfg.TagEccGranularity ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)+(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]  scrubber_fix_o,
  output logic [Cfg.SetAssociativity-1:0][(Cfg.TagEccGranularity ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)+(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]  scrub_uncorrectable_o,
  output logic [Cfg.SetAssociativity-1:0][(Cfg.TagEccGranularity ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)+(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]  single_error_o,
  output logic [Cfg.SetAssociativity-1:0][(Cfg.TagEccGranularity ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)+(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]  multi_error_o
);
  `include "axi/typedef.svh"

  // Axi parameters are accumulated in a struct for further use.
  localparam axi_llc_pkg::llc_axi_cfg_t AxiCfg = axi_llc_pkg::llc_axi_cfg_t'{
    SlvPortIdWidth:    AxiIdWidth,
    AddrWidthFull:     AxiAddrWidth,
    DataWidthFull:     AxiDataWidth
  };

  typedef logic [AxiCfg.SlvPortIdWidth-1:0]    axi_slv_id_t;
  typedef logic [AxiCfg.SlvPortIdWidth:0]      axi_mst_id_t;
  typedef logic [AxiCfg.DataWidthFull-1:0]     axi_data_t;
  typedef logic [(AxiCfg.DataWidthFull/8)-1:0] axi_strb_t;
  typedef logic [AxiUserWidth-1:0]             axi_user_t;

  `AXI_TYPEDEF_AW_CHAN_T(slv_aw_chan_t, axi_addr_t, axi_slv_id_t, axi_user_t)
  `AXI_TYPEDEF_AW_CHAN_T(mst_aw_chan_t, axi_addr_t, axi_mst_id_t, axi_user_t)
  `AXI_TYPEDEF_W_CHAN_T(w_chan_t, axi_data_t, axi_strb_t, axi_user_t)
  `AXI_TYPEDEF_B_CHAN_T(slv_b_chan_t, axi_slv_id_t, axi_user_t)
  `AXI_TYPEDEF_B_CHAN_T(mst_b_chan_t, axi_mst_id_t, axi_user_t)
  `AXI_TYPEDEF_AR_CHAN_T(slv_ar_chan_t, axi_addr_t, axi_slv_id_t, axi_user_t)
  `AXI_TYPEDEF_AR_CHAN_T(mst_ar_chan_t, axi_addr_t, axi_mst_id_t, axi_user_t)
  `AXI_TYPEDEF_R_CHAN_T(slv_r_chan_t, axi_data_t, axi_slv_id_t, axi_user_t)
  `AXI_TYPEDEF_R_CHAN_T(mst_r_chan_t, axi_data_t, axi_mst_id_t, axi_user_t)

  // configuration struct that has all the cache parameters included for the submodules
  localparam axi_llc_pkg::llc_cfg_t Cfg = axi_llc_pkg::llc_cfg_t'{
    SetAssociativity  : SetAssociativity,
    NumLines          : NumLines,
    NumBlocks         : NumBlocks,
    BlockSize         : AxiCfg.DataWidthFull,
    TagLength         : CachePartition ? (AxiCfg.AddrWidthFull - unsigned'($clog2(NumBlocks)) - 
                                          unsigned'($clog2(AxiCfg.DataWidthFull / 32'd8))) : 
                                          AxiCfg.AddrWidthFull - unsigned'($clog2(NumLines)) - 
                                          unsigned'($clog2(NumBlocks)) - unsigned'($clog2(AxiCfg.DataWidthFull / 32'd8)),
    IndexLength       : unsigned'($clog2(NumLines)),
    BlockOffsetLength : unsigned'($clog2(NumBlocks)),
    ByteOffsetLength  : unsigned'($clog2(AxiCfg.DataWidthFull / 32'd8)),
    SPMLength         : SetAssociativity * NumLines * NumBlocks * (AxiCfg.DataWidthFull / 32'd8),
    DataEccGranularity: DataEccGranularity,
    TagEccGranularity : TagEccGranularity
  };

  typedef struct packed {
    // AXI4+ATOP specific descriptor signals
    axi_slv_id_t                     a_x_id;          // AXI ID from slave port
    axi_addr_t                       a_x_addr;        // memory address
    axi_pkg::len_t                   a_x_len;         // AXI burst length
    axi_pkg::size_t                  a_x_size;        // AXI burst size
    axi_pkg::burst_t                 a_x_burst;       // AXI burst type
    logic                            a_x_lock;        // AXI lock signal
    axi_pkg::cache_t                 a_x_cache;       // AXI cache signal
    axi_pkg::prot_t                  a_x_prot;        // AXI protection signal
    axi_pkg::resp_t                  x_resp;          // AXI response signal, for error propagation
    logic                            x_last;          // Last descriptor of a burst
    // Cache specific descriptor signals
    logic                            spm;      // this descriptor targets a SPM region in the cache
    logic                            rw;       // this descriptor is a read:0 or write:1 access
    logic [Cfg.SetAssociativity-1:0] way_ind;  // way we have to perform an operation on
    logic                            evict;    // evict what is standing in the line
    logic [Cfg.TagLength -1:0]       evict_tag;// tag for evicting a line
    logic                            refill;   // refill the cache line
    logic                            flush;    // flush this line, comes from config
    logic [AxiUserWidth-1:0]         patid;
    logic [Cfg.IndexLength+1:0]      index_partition; // remapped index for cache partitioning
    logic [Cfg.IndexLength+1:0]      pat_size;        // partition size, the width should be `Cfg.IndexLength+1`
                                                      // because in index remapping calculation, we need to shift
                                                      // this field left by 1 bit
    logic                            tcdl_overflow;   // to tell whether the mapping index is overflowing,
                                                      // only used in both-side index mapping hash function
    logic [Cfg.IndexLength-1:0]      max_tcdl_offset; // the smallest (2^n-1) number that is larger than pat_size,
                                                      // e.g. If pat_size = 85, max_tcdl_offset = 127.
  } llc_desc_t;

  // definition of the structs that are between the units and the ways
  typedef struct packed {
    axi_llc_pkg::cache_unit_e         cache_unit;   // which unit does the access
    logic [Cfg.SetAssociativity -1:0] way_ind;      // to which way the access goes
    logic [Cfg.IndexLength      -1:0] line_addr;    // cache line address
    logic [Cfg.BlockOffsetLength-1:0] blk_offset;   // block offset
    logic                             we;           // write enable
    axi_data_t                        data;         // input data
    axi_strb_t                        strb;         // write enable (equals AXI strb)
  } way_inp_t;

  typedef struct packed {
    axi_llc_pkg::cache_unit_e         cache_unit;   // which unit had the access
    axi_data_t                        data;         // read data from the way
`ifdef ENABLE_ECC
    logic                             multi_error;  // if the data has multiple errors (uncorrectable)
`endif
  } way_oup_t;

  // definitions of the miss counting struct
  typedef struct packed {
    axi_slv_id_t                      id;           // AXI id of the count operation
    logic                             rw;           // 0:read, 1:write
    logic                             valid;        // valid, equals enable
  } cnt_t;

  // definition of the lock signals
  typedef struct packed {
    logic [Cfg.IndexLength-1:0]      index;         // index of lock (cache-line)
    logic [Cfg.SetAssociativity-1:0] way_ind;       // way which is locked
  } lock_t;

  typedef struct packed {
    logic [Cfg.IndexLength:0] StartIndex; // Start index in the partition region assigned to the partition.
    logic [Cfg.IndexLength:0] NumIndex;   // Number of indice of the partition.
  } partition_table_t;

  /// Partition table which tells the range of indice assigned to each partition:
  /// The number of entry in partition_table is one more than MaxPartition because it needs to hold 
  /// the remaining part as shared region for any other partition that has not been allocated.
  /// If the entry is 0, then it means that the partition uses the shared region of cache. 
  /// When we process data access of such partition, we should look up partition_table_o[MaxPartition]
  /// for hit/miss information.
  partition_table_t [MaxPartition:0] partition_table;

  // slave requests, that go into the bypass `axi_demux` from the config module
  // `index` for the axi_mux and axi_demux: bypass: 1, llc: 0
  logic slv_aw_bypass, slv_ar_bypass;

  // bypass channels and llc connection to the axi_demux and axi_mux
  slv_req_t     to_isolate_req, to_demux_req,  bypass_req,   to_llc_req,   from_llc_req;
  slv_resp_t    to_isolate_resp, to_demux_resp, bypass_resp,  to_llc_resp,  from_llc_resp;

  // signals between channel splitters and rw_arb_tree
  llc_desc_t [2:0]      ax_desc;
  logic      [2:0]      ax_desc_valid;
  logic      [2:0]      ax_desc_ready;

  // descriptor from rw_arb_tree to spill register to cut longest path (hit miss detect)
  llc_desc_t            rw_desc;
  logic                 rw_desc_valid,     rw_desc_ready;

  // descriptor from spill register to hit miss detect
  llc_desc_t            spill_desc;
  logic                 spill_valid,       spill_ready;

  // descriptor from the hit_miss_unit
  llc_desc_t            desc;
  logic                 hit_valid,         hit_ready;
  logic                 miss_valid,        miss_ready;

  // descriptor from the evict_unit to the refill_unit
  llc_desc_t            evict_desc;
  logic                 evict_desc_valid,  evict_desc_ready;

  // descriptor from the refill_unit to the merge_unit
  llc_desc_t            refill_desc;
  logic                 refill_desc_valid, refill_desc_ready;

  // descriptor from the merge_unit to the write_unit
  llc_desc_t            write_desc;
  logic                 write_desc_valid,  write_desc_ready;

  // descriptor from the merge_unit to the read_unit
  llc_desc_t            read_desc;
  logic                 read_desc_valid,   read_desc_ready;

  // signals from the unit to the data_ways
  way_inp_t [3:0]       to_way;
  logic     [3:0]       to_way_valid;
  logic     [3:0]       to_way_ready;

  // read signals from the data SRAMs
  way_oup_t             evict_way_out,       read_way_out;
  logic                 evict_way_out_valid, read_way_out_valid;
  logic                 evict_way_out_ready, read_way_out_ready;

  // count down signal from the merge_unit to the hit miss unit
  cnt_t                 cnt_down;

  // unlock signals from the read / write unit towards the hit miss unit
  // req signal depends on gnt signal!
  lock_t                r_unlock,     w_unlock;
  logic                 r_unlock_req, w_unlock_req; // Not AXI valid / ready dependency
  logic                 r_unlock_gnt, w_unlock_gnt; // Not AXI valid / ready dependency

  // global SPM lock signal
  logic [Cfg.SetAssociativity-1:0] spm_lock;
  logic [Cfg.SetAssociativity-1:0] flushed;
  logic [Cfg.NumLines-1:0]         flushed_set;

  // BIST from tag_store
  logic [Cfg.SetAssociativity-1:0] bist_res;
  logic                            bist_valid;

  // global flush signals
  logic llc_isolate, llc_isolated, aw_unit_busy, ar_unit_busy, flush_recv;

  // ecc signals
  logic [Cfg.SetAssociativity-1:0][(Cfg.TagEccGranularity ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)-1:0]  tag_sram_scrub_trigger;
  logic [Cfg.SetAssociativity-1:0][(Cfg.TagEccGranularity ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)-1:0]  tag_sram_scrubber_fix;
  logic [Cfg.SetAssociativity-1:0][(Cfg.TagEccGranularity ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)-1:0]  tag_sram_scrub_uncorrectable;
  logic [Cfg.SetAssociativity-1:0][(Cfg.TagEccGranularity ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)-1:0]  tag_sram_single_error;
  logic [Cfg.SetAssociativity-1:0][(Cfg.TagEccGranularity ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)-1:0]  tag_sram_multi_error;

  logic [Cfg.SetAssociativity-1:0][(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]  data_sram_scrub_trigger;
  logic [Cfg.SetAssociativity-1:0][(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]  data_sram_scrubber_fix;
  logic [Cfg.SetAssociativity-1:0][(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]  data_sram_scrub_uncorrectable;
  logic [Cfg.SetAssociativity-1:0][(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]  data_sram_single_error;
  logic [Cfg.SetAssociativity-1:0][(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]  data_sram_multi_error;

`ifdef SRAM_OUTSIDE
  // generate for each Way one tag storage macro
  typedef logic [Cfg.SetAssociativity-1:0][Cfg.IndexLength + Cfg.BlockOffsetLength-1:0] data_index_t;
  typedef logic [Cfg.SetAssociativity-1:0][Cfg.IndexLength-1:0]                         tag_index_t;
  typedef logic [Cfg.TagLength-1:0] tag_t;
  typedef struct packed {
    logic val; /// The tag stored is valid.
    logic dit; /// The tag stored is dirty.
    tag_t tag; /// The stored tag itself.
  } tag_entry_t;

  localparam int unsigned SRAMDataWidth = 1'b1 << ($clog2($bits(tag_entry_t)));

  typedef logic [Cfg.BlockSize-1:0]                           data_entry_t;
  typedef logic [Cfg.SetAssociativity-1:0][SRAMDataWidth-1:0] tag_payload_t;
  typedef data_entry_t [Cfg.SetAssociativity-1:0]             data_payload_t;
  
  typedef logic [Cfg.SetAssociativity-1:0][(Cfg.BlockSize + 8 - 32'd1) / 8-1:0] data_be_t;

  // Macro signals
  way_ind_t     tag_ram_req, tag_ram_scrub_req; // Request for the macros
  way_ind_t     tag_ram_we, tag_ram_scrub_we; // Write enable for the macros, active high. (Also functions as byte enable as there is one byte).
  way_ind_t     tag_ram_be, tag_ram_scrub_be; // Write byte enable
  tag_index_t   tag_ram_index, tag_ram_scrub_index; // Index is the address.
  tag_payload_t tag_ram_wdata, tag_ram_scrub_wdata; // Write data for the macros.
  way_ind_t     tag_ram_gnt, tag_ram_scrub_gnt; // Ready from the macros
  tag_payload_t tag_ram_rdata, tag_ram_scrub_rdata; // Read data from the macros.
  way_ind_t     tag_ram_rdata_multi_err; // The data read from tag sram has multi errors.
  
  way_ind_t     data_ram_req, data_ram_scrub_req; // Request for the macros
  way_ind_t     data_ram_we, data_ram_scrub_we; // Write enable for the macros, active high. (Also functions as byte enable as there is one byte).
  data_be_t     data_ram_be, data_ram_scrub_be; // Write byte enable
  data_index_t  data_ram_index, data_ram_scrub_index; // Index is the address.
  data_payload_t  data_ram_wdata, data_ram_scrub_wdata;
  way_ind_t       data_ram_gnt, data_ram_scrub_gnt; // Ready from the macros
  data_payload_t  data_ram_rdata, data_ram_scrub_rdata; // Read data from the macros.
  way_ind_t       data_ram_rdata_multi_err; // The data read from data sram has multi errors.

  // typedef struct packed {
  //   logic [(Cfg.TagEccGranularity  ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)-1:0]  tag_sram_single_error;
  //   logic [(Cfg.TagEccGranularity  ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1)-1:0]  tag_sram_multi_error;
  //   logic [(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]                             data_sram_single_error;
  //   logic [(Cfg.DataEccGranularity ? Cfg.BlockSize/Cfg.DataEccGranularity : 1)-1:0]                             data_sram_multi_error;
  // } error_info_per_way_t;
  typedef struct packed {
    logic tag_sram_single_error;
    logic tag_sram_multi_error;
    logic data_sram_single_error;
    logic data_sram_multi_error;
  } error_info_per_way_t;
  error_info_per_way_t [Cfg.SetAssociativity-1:0] error_info;
`endif


  for (genvar i = 0; unsigned'(i) < Cfg.SetAssociativity; i++) begin : gen_ecc_signals
    // assign {data_sram_scrub_trigger[i], tag_sram_scrub_trigger[i]} = scrub_trigger_i[i];
    assign {data_sram_scrub_trigger[i], tag_sram_scrub_trigger[i]} = '0;
    assign scrubber_fix_o[i]         = {data_sram_scrubber_fix[i],        tag_sram_scrubber_fix[i]};
    assign scrub_uncorrectable_o[i]  = {data_sram_scrub_uncorrectable[i], tag_sram_scrub_uncorrectable[i]};
    assign single_error_o[i]         = {data_sram_single_error[i],        tag_sram_single_error[i]};
    assign multi_error_o[i]          = {data_sram_multi_error[i],    tag_sram_multi_error[i]};
  end

  // define address rules from the address ports, propagate it throughout the design
  rule_full_t cached_addr_rule;
  rule_full_t spm_addr_rule;
  always_comb begin
    cached_addr_rule            = '0;
    cached_addr_rule.start_addr = cached_start_addr_i;
    cached_addr_rule.end_addr   = cached_end_addr_i;
    spm_addr_rule               = '0;
    spm_addr_rule.start_addr    = spm_start_addr_i;
    spm_addr_rule.end_addr      = spm_start_addr_i + axi_addr_t'(Cfg.SPMLength);
  end

  always_comb begin
    to_isolate_req = slv_req_i;
    slv_resp_o = to_isolate_resp;

    to_isolate_req.aw.user = '0;
    to_isolate_req.aw.user[AxiUserIdMsb-AxiUserIdLsb:0] = slv_req_i.aw.user[AxiUserIdMsb:AxiUserIdLsb];
    to_isolate_req.ar.user = '0;
    to_isolate_req.ar.user[AxiUserIdMsb-AxiUserIdLsb:0] = slv_req_i.ar.user[AxiUserIdMsb:AxiUserIdLsb];
  end

generate
  if (CachePartition) begin
    // configuration for LLC partitioning enabled, also has control over bypass logic and flush
    axi_llc_config_pat #(
      .Cfg               ( Cfg               ),
      .AxiCfg            ( AxiCfg            ),
      .RegWidth          ( RegWidth          ),
      .MaxPartition      ( MaxPartition      ),
      .conf_regs_d_t     ( conf_regs_d_t     ),
      .conf_regs_q_t     ( conf_regs_q_t     ),
      .desc_t            ( llc_desc_t        ),
      .rule_full_t       ( rule_full_t       ),
      .set_asso_t        ( way_ind_t         ),
      .set_t             ( set_ind_t         ),
      .addr_full_t       ( axi_addr_t        ),
      .partition_id_t    ( axi_user_t        ),
      .partition_table_t ( partition_table_t ),
      .PrintLlcCfg       ( PrintLlcCfg       )
    ) i_llc_config_pat (
      .clk_i             ( clk_i                                  ),
      .rst_ni            ( rst_ni                                 ),
      // Configuration registers
      .conf_regs_i,
      .conf_regs_o,
      .spm_lock_o        ( spm_lock                               ),
      .flushed_o         ( flushed                                ),
      .flushed_set_o     ( flushed_set                            ),
      .desc_o            ( ax_desc[axi_llc_pkg::ConfigUnit]       ),
      .desc_valid_o      ( ax_desc_valid[axi_llc_pkg::ConfigUnit] ),
      .desc_ready_i      ( ax_desc_ready[axi_llc_pkg::ConfigUnit] ),
      // AXI address input from slave port for controlling bypass
      .slv_aw_addr_i     ( to_isolate_req.aw.addr                 ),
      .slv_aw_partition_id_i ( to_isolate_req.aw.user             ),
      .slv_ar_addr_i     ( to_isolate_req.ar.addr                 ),
      .slv_ar_partition_id_i ( to_isolate_req.ar.user             ),
      .mst_aw_bypass_o   ( slv_aw_bypass                          ),
      .mst_ar_bypass_o   ( slv_ar_bypass                          ),
      // flush control signals to prevent new data in ax_cutter loading
      .llc_isolate_o     ( llc_isolate                            ),
      .llc_isolated_i    ( llc_isolated                           ),
      .aw_unit_busy_i    ( aw_unit_busy                           ),
      .ar_unit_busy_i    ( ar_unit_busy                           ),
      .flush_desc_recv_i ( flush_recv                             ),
      // BIST input
      .bist_res_i        ( bist_res                               ),
      .bist_valid_i      ( bist_valid                             ),
      // address rules for bypass selection
      .axi_cached_rule_i ( cached_addr_rule                       ),
      .axi_spm_rule_i    ( spm_addr_rule                          ),
      // partition table
      .partition_table_o ( partition_table                        )
    );
  end else begin
    // configuration for LLC partitioning disabled, also has control over bypass logic and flush
    axi_llc_config_no_pat #(
      .Cfg            ( Cfg           ),
      .AxiCfg         ( AxiCfg        ),
      .RegWidth       ( RegWidth      ),
      .conf_regs_d_t  ( conf_regs_d_t ),
      .conf_regs_q_t  ( conf_regs_q_t ),
      .desc_t         ( llc_desc_t    ),
      .rule_full_t    ( rule_full_t   ),
      .set_asso_t     ( way_ind_t     ),
      .addr_full_t    ( axi_addr_t    ),
      .PrintLlcCfg    ( PrintLlcCfg   )
    ) i_llc_config_no_pat (
      .clk_i             ( clk_i                                  ),
      .rst_ni            ( rst_ni                                 ),
      // Configuration registers
      .conf_regs_i,
      .conf_regs_o,
      .spm_lock_o        ( spm_lock                               ),
      .flushed_o         ( flushed                                ),
      .desc_o            ( ax_desc[axi_llc_pkg::ConfigUnit]       ),
      .desc_valid_o      ( ax_desc_valid[axi_llc_pkg::ConfigUnit] ),
      .desc_ready_i      ( ax_desc_ready[axi_llc_pkg::ConfigUnit] ),
      // AXI address input from slave port for controlling bypass
      .slv_aw_addr_i     ( slv_req_i.aw.addr                      ),
      .slv_ar_addr_i     ( slv_req_i.ar.addr                      ),
      .mst_aw_bypass_o   ( slv_aw_bypass                          ),
      .mst_ar_bypass_o   ( slv_ar_bypass                          ),
      // flush control signals to prevent new data in ax_cutter loading
      .llc_isolate_o     ( llc_isolate                            ),
      .llc_isolated_i    ( llc_isolated                           ),
      .aw_unit_busy_i    ( aw_unit_busy                           ),
      .ar_unit_busy_i    ( ar_unit_busy                           ),
      .flush_desc_recv_i ( flush_recv                             ),
      // BIST input
      .bist_res_i        ( bist_res                               ),
      .bist_valid_i      ( bist_valid                             ),
      // address rules for bypass selection
      .axi_cached_rule_i ( cached_addr_rule                       ),
      .axi_spm_rule_i    ( spm_addr_rule                          )
    );
  end
endgenerate
  

  // Isolation module before demux to easy flushing,
  // AXI requests get stalled while flush is active
  axi_isolate #(
    .NumPending     ( axi_llc_pkg::MaxTrans ),
    .AxiAddrWidth   ( AxiAddrWidth          ),
    .AxiDataWidth   ( AxiDataWidth          ),
    .AxiIdWidth     ( AxiIdWidth            ),
    .AxiUserWidth   ( AxiUserWidth          ),
    .axi_req_t      ( slv_req_t             ),
    .axi_resp_t     ( slv_resp_t            )
  ) i_axi_isolate_flush (
    .clk_i,
    .rst_ni,
    .slv_req_i  ( to_isolate_req  ),  // Slave port request
    .slv_resp_o ( to_isolate_resp ), // Slave port response
    .mst_req_o  ( to_demux_req  ),
    .mst_resp_i ( to_demux_resp ),
    .isolate_i  ( llc_isolate   ),
    .isolated_o ( llc_isolated  )
  );

  axi_demux #(
    .AxiIdWidth     ( AxiCfg.SlvPortIdWidth  ),
    .aw_chan_t      ( slv_aw_chan_t          ),
    .w_chan_t       ( w_chan_t               ),
    .b_chan_t       ( slv_b_chan_t           ),
    .ar_chan_t      ( slv_ar_chan_t          ),
    .r_chan_t       ( slv_r_chan_t           ),
    .axi_req_t      ( slv_req_t              ),
    .axi_resp_t     ( slv_resp_t             ),
    .NoMstPorts     ( 32'd2                  ),
    .MaxTrans       ( axi_llc_pkg::MaxTrans  ),
    .AxiLookBits    ( axi_llc_pkg::UseIdBits ),
    .SpillAw        ( 1'b0                   ),
    .SpillW         ( 1'b0                   ),
    .SpillB         ( 1'b0                   ),
    .SpillAr        ( 1'b0                   ),
    .SpillR         ( 1'b0                   )
  ) i_axi_bypass_demux (
    .clk_i           ( clk_i                    ),
    .rst_ni          ( rst_ni                   ),
    .test_i          ( test_i                   ),
    .slv_req_i       ( to_demux_req             ),
    .slv_aw_select_i ( slv_aw_bypass            ),
    .slv_ar_select_i ( slv_ar_bypass            ),
    .slv_resp_o      ( to_demux_resp            ),
    .mst_reqs_o      ({bypass_req,  to_llc_req }),
    .mst_resps_i     ({bypass_resp, to_llc_resp})
  );

  // AW channel burst splitter
  axi_llc_chan_splitter #(
    .Cfg    ( Cfg           ),
    .AxiCfg ( AxiCfg        ),
    .CachePartition ( CachePartition      ),
    .MaxPartition   ( MaxPartition        ),
    .RemapHash      ( RemapHash           ),
    .chan_t ( slv_aw_chan_t ),
    .Write  ( 1'b1          ),
    .desc_t ( llc_desc_t    ),
    .rule_t ( rule_full_t   ),
    .partition_table_t (partition_table_t)
  ) i_aw_splitter    (
    .clk_i           ( clk_i                                  ),
    .rst_ni          ( rst_ni                                 ),
    .ax_chan_slv_i   ( to_llc_req.aw                          ),
    .ax_chan_valid_i ( to_llc_req.aw_valid                    ),
    .ax_chan_ready_o ( to_llc_resp.aw_ready                   ),
    .desc_o          ( ax_desc[axi_llc_pkg::AwChanUnit]       ),
    .desc_valid_o    ( ax_desc_valid[axi_llc_pkg::AwChanUnit] ),
    .desc_ready_i    ( ax_desc_ready[axi_llc_pkg::AwChanUnit] ),
    .unit_busy_o     ( aw_unit_busy                           ),
    .cached_rule_i   ( cached_addr_rule                       ),
    .spm_rule_i      ( spm_addr_rule                          ),
    .partition_table_i ( partition_table                      )
  );


  // RW channel burst splitter
  axi_llc_chan_splitter #(
    .Cfg               ( Cfg               ),
    .AxiCfg            ( AxiCfg            ),
    .CachePartition    ( CachePartition    ),
    .MaxPartition      ( MaxPartition      ),
    .RemapHash         ( RemapHash         ),
    .chan_t            ( slv_ar_chan_t     ),
    .Write             ( 1'b0              ),
    .desc_t            ( llc_desc_t        ),
    .rule_t            ( rule_full_t       ),
    .partition_table_t ( partition_table_t )
  ) i_ar_splitter    (
    .clk_i           ( clk_i                                  ),
    .rst_ni          ( rst_ni                                 ),
    .ax_chan_slv_i   ( to_llc_req.ar                          ),
    .ax_chan_valid_i ( to_llc_req.ar_valid                    ),
    .ax_chan_ready_o ( to_llc_resp.ar_ready                   ),
    .desc_o          ( ax_desc[axi_llc_pkg::ArChanUnit]       ),
    .desc_valid_o    ( ax_desc_valid[axi_llc_pkg::ArChanUnit] ),
    .desc_ready_i    ( ax_desc_ready[axi_llc_pkg::ArChanUnit] ),
    .unit_busy_o     ( ar_unit_busy                           ),
    .cached_rule_i   ( cached_addr_rule                       ),
    .spm_rule_i      ( spm_addr_rule                          ),
    .partition_table_i ( partition_table                      )
  );

  // arbitration tree which funnels the flush, read and write descriptors together
  rr_arb_tree #(
    .NumIn    ( 32'd3      ),
    .DataType ( llc_desc_t ),
    .AxiVldRdy( 1'b1       ),
    .LockIn   ( 1'b1       )
  ) i_rw_arb_tree (
    .clk_i  ( clk_i         ),
    .rst_ni ( rst_ni        ),
    .flush_i( '0            ),
    .rr_i   ( '0            ),
    .req_i  ( ax_desc_valid ),
    .gnt_o  ( ax_desc_ready ),
    .data_i ( ax_desc       ),
    .gnt_i  ( rw_desc_ready ),
    .req_o  ( rw_desc_valid ),
    .data_o ( rw_desc       ),
    .idx_o  ()
  );

  spill_register #(
    .T       ( llc_desc_t )
  ) i_rw_spill (
    .clk_i   ( clk_i         ),
    .rst_ni  ( rst_ni        ),
    .valid_i ( rw_desc_valid ),
    .ready_o ( rw_desc_ready ),
    .data_i  ( rw_desc       ),
    .valid_o ( spill_valid   ),
    .ready_i ( spill_ready   ),
    .data_o  ( spill_desc    )
  );

  axi_llc_hit_miss #(
    .Cfg               ( Cfg               ),
    .AxiCfg            ( AxiCfg            ),
    .EnableEcc         ( EnableEcc         ),
    .CachePartition    ( CachePartition    ),
    .RemapHash         ( RemapHash         ),
    .desc_t            ( llc_desc_t        ),
    .lock_t            ( lock_t            ),
    .cnt_t             ( cnt_t             ),
    .way_ind_t         ( way_ind_t         ),
    .set_ind_t         ( set_ind_t         ),
    .partition_table_t ( partition_table_t ),
    .PrintSramCfg      ( PrintSramCfg      )
  ) i_hit_miss_unit (
    .clk_i,
    .rst_ni,
    .test_i,
    .desc_i         ( spill_desc   ),
    .valid_i        ( spill_valid  ),
    .ready_o        ( spill_ready  ),
    .desc_o         ( desc         ),
    .miss_valid_o   ( miss_valid   ),
    .miss_ready_i   ( miss_ready   ),
    .hit_valid_o    ( hit_valid    ),
    .hit_ready_i    ( hit_ready    ),
    .spm_lock_i     ( spm_lock     ),
    .flushed_i      ( flushed      ),
    .flushed_set_i  ( flushed_set  ),
    .w_unlock_i     ( w_unlock     ),
    .w_unlock_req_i ( w_unlock_req ),
    .w_unlock_gnt_o ( w_unlock_gnt ),
    .r_unlock_i     ( r_unlock     ),
    .r_unlock_req_i ( r_unlock_req ),
    .r_unlock_gnt_o ( r_unlock_gnt ),
    .cnt_down_i     ( cnt_down     ),
    .bist_res_o     ( bist_res     ),
    .bist_valid_o   ( bist_valid   ),

  // if the sram are put outside
  `ifdef SRAM_OUTSIDE
    .ram_req_o      ( tag_ram_req  ),
    .ram_we_o       ( tag_ram_we   ),
    .ram_addr_o     ( tag_ram_index),
    .ram_wdata_o    ( tag_ram_wdata),
    .ram_be_o       ( tag_ram_be   ),
    .ram_gnt_i      ( tag_ram_gnt  ),
    .ram_data_i     ( tag_ram_rdata),
    .ram_data_multi_err_i ( tag_ram_rdata_multi_err ),
  `endif

    // ecc signals
    .scrub_trigger_i        ( '0 ), // use external scrubber
    .scrubber_fix_o         ( /*tag_sram_scrubber_fix       */ ),
    .scrub_uncorrectable_o  ( /*tag_sram_scrub_uncorrectable*/ ),
    .single_error_o         ( /*tag_sram_single_error       */ ),
    .multi_error_o          ( /*tag_sram_multi_error        */ )
  );

  axi_llc_evict_unit #(
    .Cfg            ( Cfg            ),
    .AxiCfg         ( AxiCfg         ),
    .CachePartition ( CachePartition ),
    .desc_t         ( llc_desc_t     ),
    .way_inp_t      ( way_inp_t      ),
    .way_oup_t      ( way_oup_t      ),
    .aw_chan_t      ( slv_aw_chan_t  ),
    .w_chan_t       ( w_chan_t       ),
    .b_chan_t       ( slv_b_chan_t   )
  ) i_evict_unit (
    .clk_i             ( clk_i                                ),
    .rst_ni            ( rst_ni                               ),
    .test_i            ( test_i                               ),
    .desc_i            ( desc                                 ),
    .desc_valid_i      ( miss_valid                           ),
    .desc_ready_o      ( miss_ready                           ),
    .desc_o            ( evict_desc                           ),
    .desc_valid_o      ( evict_desc_valid                     ),
    .desc_ready_i      ( evict_desc_ready                     ),
    .way_inp_o         ( to_way[axi_llc_pkg::EvictUnit]       ),
    .way_inp_valid_o   ( to_way_valid[axi_llc_pkg::EvictUnit] ),
    .way_inp_ready_i   ( to_way_ready[axi_llc_pkg::EvictUnit] ),
    .way_out_i         ( evict_way_out                        ),
    .way_out_valid_i   ( evict_way_out_valid                  ),
    .way_out_ready_o   ( evict_way_out_ready                  ),
    .aw_chan_mst_o     ( from_llc_req.aw                      ),
    .aw_chan_valid_o   ( from_llc_req.aw_valid                ),
    .aw_chan_ready_i   ( from_llc_resp.aw_ready               ),
    .w_chan_mst_o      ( from_llc_req.w                       ),
    .w_chan_valid_o    ( from_llc_req.w_valid                 ),
    .w_chan_ready_i    ( from_llc_resp.w_ready                ),
    .b_chan_mst_i      ( from_llc_resp.b                      ),
    .b_chan_valid_i    ( from_llc_resp.b_valid                ),
    .b_chan_ready_o    ( from_llc_req.b_ready                 ),
    .flush_desc_recv_o ( flush_recv                           )
  );

  // plug in refill unit for test
  axi_llc_refill_unit #(
    .Cfg            ( Cfg            ),
    .AxiCfg         ( AxiCfg         ),
    .CachePartition ( CachePartition ),
    .desc_t         ( llc_desc_t     ),
    .way_inp_t      ( way_inp_t      ),
    .ar_chan_t      ( slv_ar_chan_t  ),
    .r_chan_t       ( slv_r_chan_t   )
  ) i_refill_unit (
    .clk_i           ( clk_i                                ),
    .rst_ni          ( rst_ni                               ),
    .test_i          ( test_i                               ),
    .desc_i          ( evict_desc                           ),
    .desc_valid_i    ( evict_desc_valid                     ),
    .desc_ready_o    ( evict_desc_ready                     ),
    .desc_o          ( refill_desc                          ),
    .desc_valid_o    ( refill_desc_valid                    ),
    .desc_ready_i    ( refill_desc_ready                    ),
    .way_inp_o       ( to_way[axi_llc_pkg::RefilUnit]       ),
    .way_inp_valid_o ( to_way_valid[axi_llc_pkg::RefilUnit] ),
    .way_inp_ready_i ( to_way_ready[axi_llc_pkg::RefilUnit] ),
    .ar_chan_mst_o   ( from_llc_req.ar                      ),
    .ar_chan_valid_o ( from_llc_req.ar_valid                ),
    .ar_chan_ready_i ( from_llc_resp.ar_ready               ),
    .r_chan_mst_i    ( from_llc_resp.r                      ),
    .r_chan_valid_i  ( from_llc_resp.r_valid                ),
    .r_chan_ready_o  ( from_llc_req.r_ready                 )
  );

  // merge unit
  axi_llc_merge_unit #(
    .Cfg    ( Cfg        ),
    .desc_t ( llc_desc_t ),
    .cnt_t  ( cnt_t      )
  ) i_merge_unit (
    .clk_i,
    .rst_ni,
    .bypass_desc_i ( desc              ),
    .bypass_valid_i( hit_valid         ),
    .bypass_ready_o( hit_ready         ),
    .refill_desc_i ( refill_desc       ),
    .refill_valid_i( refill_desc_valid ),
    .refill_ready_o( refill_desc_ready ),
    .read_desc_o   ( read_desc         ),
    .read_valid_o  ( read_desc_valid   ),
    .read_ready_i  ( read_desc_ready   ),
    .write_desc_o  ( write_desc        ),
    .write_valid_o ( write_desc_valid  ),
    .write_ready_i ( write_desc_ready  ),
    .cnt_down_o    ( cnt_down          )
  );

  // write unit
  axi_llc_write_unit #(
    .Cfg            ( Cfg            ),
    .AxiCfg         ( AxiCfg         ),
    .CachePartition ( CachePartition ),
    .desc_t         ( llc_desc_t     ),
    .way_inp_t      ( way_inp_t      ),
    .lock_t         ( lock_t         ),
    .w_chan_t       ( w_chan_t       ),
    .b_chan_t       ( slv_b_chan_t   )
  ) i_write_unit  (
    .clk_i           ( clk_i                                ),
    .rst_ni          ( rst_ni                               ),
    .test_i          ( test_i                               ),
    .desc_i          ( write_desc                           ),
    .desc_valid_i    ( write_desc_valid                     ),
    .desc_ready_o    ( write_desc_ready                     ),
    .w_chan_slv_i    ( to_llc_req.w                         ),
    .w_chan_valid_i  ( to_llc_req.w_valid                   ),
    .w_chan_ready_o  ( to_llc_resp.w_ready                  ),
    .b_chan_slv_o    ( to_llc_resp.b                        ),
    .b_chan_valid_o  ( to_llc_resp.b_valid                  ),
    .b_chan_ready_i  ( to_llc_req.b_ready                   ),
    .way_inp_o       ( to_way[axi_llc_pkg::WChanUnit]       ),
    .way_inp_valid_o ( to_way_valid[axi_llc_pkg::WChanUnit] ),
    .way_inp_ready_i ( to_way_ready[axi_llc_pkg::WChanUnit] ),
`ifdef ENABLE_ECC
  /// Data way write last cycle has multiple error
    .way_out_multi_err_i  (data_ram_rdata_multi_err         ),
`endif
    .w_unlock_o      ( w_unlock                             ),
    .w_unlock_req_o  ( w_unlock_req                         ),
    .w_unlock_gnt_i  ( w_unlock_gnt                         )
  );

  // read unit
  axi_llc_read_unit #(
    .Cfg            ( Cfg            ),
    .AxiCfg         ( AxiCfg         ),
    .CachePartition ( CachePartition ),
    .desc_t         ( llc_desc_t     ),
    .way_inp_t      ( way_inp_t      ),
    .way_oup_t      ( way_oup_t      ),
    .lock_t         ( lock_t         ),
    .r_chan_t       ( slv_r_chan_t   )
  ) i_read_unit (
    .clk_i           ( clk_i                                ),
    .rst_ni          ( rst_ni                               ),
    .test_i          ( test_i                               ),
    .desc_i          ( read_desc                            ),
    .desc_valid_i    ( read_desc_valid                      ),
    .desc_ready_o    ( read_desc_ready                      ),
    .r_chan_slv_o    ( to_llc_resp.r                        ),
    .r_chan_valid_o  ( to_llc_resp.r_valid                  ),
    .r_chan_ready_i  ( to_llc_req.r_ready                   ),
    .way_inp_o       ( to_way[axi_llc_pkg::RChanUnit]       ),
    .way_inp_valid_o ( to_way_valid[axi_llc_pkg::RChanUnit] ),
    .way_inp_ready_i ( to_way_ready[axi_llc_pkg::RChanUnit] ),
    .way_out_i       ( read_way_out                         ),
    .way_out_valid_i ( read_way_out_valid                   ),
    .way_out_ready_o ( read_way_out_ready                   ),
    .r_unlock_o      ( r_unlock                             ),
    .r_unlock_req_o  ( r_unlock_req                         ),
    .r_unlock_gnt_i  ( r_unlock_gnt                         )
  );

  // data storage
  axi_llc_ways #(
    .Cfg          ( Cfg          ),
    .EnableEcc    ( EnableEcc    ),
    .way_inp_t    ( way_inp_t    ),
    .way_oup_t    ( way_oup_t    ),
    .PrintSramCfg ( PrintSramCfg )
  ) i_llc_ways (
    .clk_i                ( clk_i               ),
    .rst_ni               ( rst_ni              ),
    .test_i               ( test_i              ),
    .way_inp_i            ( to_way              ),
    .way_inp_valid_i      ( to_way_valid        ),
    .way_inp_ready_o      ( to_way_ready        ),
    .evict_way_out_o      ( evict_way_out       ),
    .evict_way_out_valid_o( evict_way_out_valid ),
    .evict_way_out_ready_i( evict_way_out_ready ),
    .read_way_out_o       ( read_way_out        ),
    .read_way_out_valid_o ( read_way_out_valid  ),
    .read_way_out_ready_i ( read_way_out_ready  ),

    `ifdef SRAM_OUTSIDE
    .ram_req_o            ( data_ram_req    ),
    .ram_we_o             ( data_ram_we     ),
    .ram_addr_o           ( data_ram_index  ),
    .ram_wdata_o          ( data_ram_wdata  ),
    .ram_be_o             ( data_ram_be     ),
    .ram_gnt_i            ( data_ram_gnt    ),
    .ram_data_i           ( data_ram_rdata  ),
    .ram_data_multi_err_i ( data_ram_rdata_multi_err ),
    `endif

    // ecc signals
    .scrub_trigger_i        ( '0 ), // use external scrubber
    .scrubber_fix_o         ( /*data_sram_scrubber_fix       */),
    .scrub_uncorrectable_o  ( /*data_sram_scrub_uncorrectable*/),
    .single_error_o         ( /*data_sram_single_error       */),
    .multi_error_o          ( /*data_sram_multi_error        */)
  );


`ifdef SRAM_OUTSIDE
  
  for (genvar i = 0; unsigned'(i) < Cfg.SetAssociativity; i++) begin : gen_scrubbers
    ecc_scrubber_out #(
      .Cfg          ( Cfg          ),
      .TagWidth       ( SRAMDataWidth ),
      .DataWidth      ( Cfg.BlockSize ),
      .TagDepth       ( Cfg.NumLines  ),
      .DataDepth      ( Cfg.NumLines * Cfg.NumBlocks ),
      .error_info_per_way_t (error_info_per_way_t)
    ) i_scrubber (
      .clk_i,
      .rst_ni,

      // .scrub_trigger_i ( |scrub_trigger_i  ),
      .scrub_trigger_i ( '1  ),
      .bit_corrected_o ( /*scrubber_fix_o       */ ),
      .uncorrectable_o ( /*scrub_uncorrectable_o*/ ),

      .tag_intc_req_i       ( tag_ram_req        [i]  ),
      .tag_intc_gnt_o       ( tag_ram_gnt        [i]  ),
      .tag_intc_we_i        ( tag_ram_we         [i]  ),
      .tag_intc_be_i        ( tag_ram_be         [i]  ),
      .tag_intc_add_i       ( tag_ram_index      [i]  ),
      .tag_intc_wdata_i     ( tag_ram_wdata      [i]  ),
      .tag_intc_rdata_o     ( tag_ram_rdata      [i]  ),
      .tag_intc_multi_err_o ( tag_ram_rdata_multi_err [i]),

      .data_intc_req_i      ( data_ram_req       [i]  ),
      .data_intc_gnt_o      ( data_ram_gnt       [i]  ),
      .data_intc_we_i       ( data_ram_we        [i]  ),
      .data_intc_be_i       ( data_ram_be        [i]  ),
      .data_intc_add_i      ( data_ram_index     [i]  ),
      .data_intc_wdata_i    ( data_ram_wdata     [i]  ),
      .data_intc_rdata_o    ( data_ram_rdata     [i]  ),
      .data_intc_multi_err_o( data_ram_rdata_multi_err [i]),

      .tag_bank_req_o       ( tag_ram_scrub_req  [i]  ),
      .tag_bank_gnt_i       ( tag_ram_scrub_gnt  [i]  ),
      .tag_bank_we_o        ( tag_ram_scrub_we   [i]  ),
      .tag_bank_be_o        ( tag_ram_scrub_be   [i]  ),
      .tag_bank_add_o       ( tag_ram_scrub_index[i]  ),
      .tag_bank_wdata_o     ( tag_ram_scrub_wdata[i]  ),
      .tag_bank_rdata_i     ( tag_ram_scrub_rdata[i] ),

      .data_bank_req_o      ( data_ram_scrub_req  [i] ),
      .data_bank_gnt_i      ( data_ram_scrub_gnt  [i] ),
      .data_bank_we_o       ( data_ram_scrub_we   [i] ),
      .data_bank_be_o       ( data_ram_scrub_be   [i] ),
      .data_bank_add_o      ( data_ram_scrub_index[i] ),
      .data_bank_wdata_o    ( data_ram_scrub_wdata[i] ),
      .data_bank_rdata_i    ( data_ram_scrub_rdata[i] ),

      .ecc_err_i            ( error_info          [i] )
    );
  end
  
  for (genvar i = 0; unsigned'(i) < Cfg.SetAssociativity; i++) begin : gen_sram_macros
    axi_llc_sram #(
      .NumWords    ( Cfg.NumLines                 ),
      .DataWidth   ( SRAMDataWidth                ),
      .ByteWidth   ( SRAMDataWidth                ),
      .Latency     ( axi_llc_pkg::TagMacroLatency ),
      .EnableEcc   ( EnableEcc                    ),
      .ECC_GRANULARITY ( Cfg.TagEccGranularity    ),
      .SimInit     ( "none"                       ),
      .PrintSimCfg ( PrintSramCfg                 )
    ) i_tag_sram (
      .clk_i,
      .rst_ni,
      .req_i   ( tag_ram_scrub_req[i]   ),
      .we_i    ( tag_ram_scrub_we[i]    ),
      .addr_i  ( tag_ram_scrub_index[i] ),
      .wdata_i ( tag_ram_scrub_wdata[i] ),
      .be_i    ( tag_ram_scrub_be[i]    ),
      .gnt_o   ( tag_ram_scrub_gnt[i]   ),
      .rdata_o ( tag_ram_scrub_rdata[i] ),

      // ecc signals
      .scrub_trigger_i        ( '0 ), // use external scrubber
      .scrubber_fix_o         ( tag_sram_scrubber_fix       [i] ),
      .scrub_uncorrectable_o  ( tag_sram_scrub_uncorrectable[i] ),
      .single_error_o         ( tag_sram_single_error       [i] ),
      .multi_error_o          ( tag_sram_multi_error        [i] )
    );

    axi_llc_sram #(
      .NumWords   ( Cfg.NumLines * Cfg.NumBlocks ),
      .DataWidth  ( Cfg.BlockSize                ),
      .ByteWidth  ( 32'd8                        ),
      .Latency    ( 32'd1                        ),
      .EnableEcc  ( EnableEcc                    ),
      .ECC_GRANULARITY ( Cfg.DataEccGranularity  ),
      .SimInit    ( "zeros"                      ),
      .PrintSimCfg( PrintSramCfg                 )
    ) i_data_sram (
      .clk_i,
      .rst_ni,
      .req_i   ( data_ram_scrub_req[i]   ),
      .we_i    ( data_ram_scrub_we[i]    ),
      .addr_i  ( data_ram_scrub_index[i] ),
      .wdata_i ( data_ram_scrub_wdata[i] ),
      .be_i    ( data_ram_scrub_be[i]    ),
      .gnt_o   ( data_ram_scrub_gnt[i]   ),
      .rdata_o ( data_ram_scrub_rdata[i] ),

      // ecc signals
      .scrub_trigger_i        ( '0 ), // use external scrubber
      .scrubber_fix_o         ( data_sram_scrubber_fix        [i]),
      .scrub_uncorrectable_o  ( data_sram_scrub_uncorrectable [i]),
      .single_error_o         ( data_sram_single_error        [i]),
      .multi_error_o          ( data_sram_multi_error         [i])
    );

    assign error_info[i].tag_sram_single_error   = |tag_sram_single_error  [i];
    assign error_info[i].tag_sram_multi_error    = |tag_sram_multi_error   [i];
    assign error_info[i].data_sram_single_error  = |data_sram_single_error [i];
    assign error_info[i].data_sram_multi_error   = |data_sram_multi_error  [i];
  end
`endif



  // this unit widens the AXI ID by one!
  axi_mux #(
    .SlvAxiIDWidth ( AxiCfg.SlvPortIdWidth     ),
    .slv_aw_chan_t ( slv_aw_chan_t             ),
    .mst_aw_chan_t ( mst_aw_chan_t             ),
    .w_chan_t      ( w_chan_t                  ),
    .slv_b_chan_t  ( slv_b_chan_t              ),
    .mst_b_chan_t  ( mst_b_chan_t              ),
    .slv_ar_chan_t ( slv_ar_chan_t             ),
    .mst_ar_chan_t ( mst_ar_chan_t             ),
    .slv_r_chan_t  ( slv_r_chan_t              ),
    .mst_r_chan_t  ( mst_r_chan_t              ),
    .slv_req_t     ( slv_req_t                 ),
    .slv_resp_t    ( slv_resp_t                ),
    .mst_req_t     ( mst_req_t                 ),
    .mst_resp_t    ( mst_resp_t                ),
    .NoSlvPorts    ( 32'd2                     ),
    .MaxWTrans     ( axi_llc_pkg::MaxTrans     ),
    .FallThrough   ( 1'b0                      ), // No registers
    .SpillAw       ( 1'b0                      ), // No registers
    .SpillW        ( 1'b0                      ), // No registers
    .SpillB        ( 1'b0                      ), // No registers
    .SpillAr       ( 1'b0                      ), // No registers
    .SpillR        ( 1'b0                      )  // No registers
  ) i_axi_bypass_mux (
    .clk_i       ( clk_i                      ),
    .rst_ni      ( rst_ni                     ),
    .test_i      ( test_i                     ),
    .slv_reqs_i  ({bypass_req,  from_llc_req }),
    .slv_resps_o ({bypass_resp, from_llc_resp}),
    .mst_req_o   ( mst_req_o                  ),
    .mst_resp_i  ( mst_resp_i                 )
  );

  // Events output track successfull handshakes at different `axi_llc` units.
  // Function definition see `axi_llc_pkg`.
  assign axi_llc_events_o = axi_llc_pkg::events_t'{
    aw_slv_transfer:    axi_llc_pkg::event_num_bytes(
        to_llc_req.aw.len,
        to_llc_req.aw.size,
        to_llc_req.aw_valid,
        to_llc_resp.aw_ready),
    ar_slv_transfer:    axi_llc_pkg::event_num_bytes(
        to_llc_req.ar.len,
        to_llc_req.ar.size,
        to_llc_req.ar_valid,
        to_llc_resp.ar_ready),
    aw_bypass_transfer: axi_llc_pkg::event_num_bytes(
        bypass_req.aw.len,
        bypass_req.aw.size,
        bypass_req.aw_valid,
        bypass_resp.aw_ready),
    ar_bypass_transfer: axi_llc_pkg::event_num_bytes(
        bypass_req.ar.len,
        bypass_req.ar.size,
        bypass_req.ar_valid,
        bypass_resp.ar_ready),
    aw_mst_transfer:    axi_llc_pkg::event_num_bytes(
        from_llc_req.aw.len,
        from_llc_req.aw.size,
        from_llc_req.aw_valid,
        from_llc_resp.aw_ready),
    ar_mst_transfer:    axi_llc_pkg::event_num_bytes(
        from_llc_req.ar.len,
        from_llc_req.ar.size,
        from_llc_req.ar_valid,
        from_llc_resp.ar_ready),
    aw_desc_spm:        axi_llc_pkg::event_num_bytes(
        ax_desc[axi_llc_pkg::AwChanUnit].a_x_len,
        ax_desc[axi_llc_pkg::AwChanUnit].a_x_size,
        ax_desc_valid[axi_llc_pkg::AwChanUnit] & ax_desc[axi_llc_pkg::AwChanUnit].spm,
        ax_desc_ready[axi_llc_pkg::AwChanUnit]),
    ar_desc_spm:        axi_llc_pkg::event_num_bytes(
        ax_desc[axi_llc_pkg::ArChanUnit].a_x_len,
        ax_desc[axi_llc_pkg::ArChanUnit].a_x_size,
        ax_desc_valid[axi_llc_pkg::ArChanUnit] & ax_desc[axi_llc_pkg::ArChanUnit].spm,
        ax_desc_ready[axi_llc_pkg::ArChanUnit]),
    aw_desc_cache:      axi_llc_pkg::event_num_bytes(
        ax_desc[axi_llc_pkg::AwChanUnit].a_x_len,
        ax_desc[axi_llc_pkg::AwChanUnit].a_x_size,
        ax_desc_valid[axi_llc_pkg::AwChanUnit] & ~ax_desc[axi_llc_pkg::AwChanUnit].spm,
        ax_desc_ready[axi_llc_pkg::AwChanUnit]),
    ar_desc_cache:      axi_llc_pkg::event_num_bytes(
        ax_desc[axi_llc_pkg::ArChanUnit].a_x_len,
        ax_desc[axi_llc_pkg::ArChanUnit].a_x_size,
        ax_desc_valid[axi_llc_pkg::ArChanUnit] & ~ax_desc[axi_llc_pkg::ArChanUnit].spm,
        ax_desc_ready[axi_llc_pkg::ArChanUnit]),
    config_desc:        axi_llc_pkg::event_num_bytes(
        ax_desc[axi_llc_pkg::ConfigUnit].a_x_len,
        ax_desc[axi_llc_pkg::ConfigUnit].a_x_size,
        ax_desc_valid[axi_llc_pkg::ConfigUnit],
        ax_desc_ready[axi_llc_pkg::ConfigUnit]),
    hit_write_spm:      axi_llc_pkg::event_num_bytes(
        desc.a_x_len,
        desc.a_x_size,
        hit_valid & desc.rw & desc.spm & ~desc.flush,
        hit_ready),
    hit_read_spm:       axi_llc_pkg::event_num_bytes(
        desc.a_x_len,
        desc.a_x_size,
        hit_valid & ~desc.rw & desc.spm & ~desc.flush,
        hit_ready),
    miss_write_spm:     axi_llc_pkg::event_num_bytes(
        desc.a_x_len,
        desc.a_x_size,
        miss_valid & desc.rw & desc.spm & ~desc.flush,
        miss_ready),
    miss_read_spm:      axi_llc_pkg::event_num_bytes(
        desc.a_x_len,
        desc.a_x_size,
        miss_valid & ~desc.rw & desc.spm & ~desc.flush,
        miss_ready),
    hit_write_cache:    axi_llc_pkg::event_num_bytes(
        desc.a_x_len,
        desc.a_x_size,
        hit_valid & desc.rw & ~desc.spm & ~desc.flush,
        hit_ready),
    hit_read_cache:     axi_llc_pkg::event_num_bytes(
        desc.a_x_len,
        desc.a_x_size,
        hit_valid & ~desc.rw & ~desc.spm & ~desc.flush,
        hit_ready),
    miss_write_cache:   axi_llc_pkg::event_num_bytes(
        desc.a_x_len,
        desc.a_x_size,
        miss_valid & desc.rw & ~desc.spm & ~desc.flush,
        miss_ready),
    miss_read_cache:    axi_llc_pkg::event_num_bytes(
        desc.a_x_len,
        desc.a_x_size,
        miss_valid & ~desc.rw & ~desc.spm & ~desc.flush,
        miss_ready),
    refill_write:       axi_llc_pkg::event_num_bytes(
        evict_desc.a_x_len,
        evict_desc.a_x_size,
        evict_desc_valid & evict_desc.rw & ~evict_desc.spm & ~evict_desc.flush & evict_desc.refill,
        evict_desc_ready),
    refill_read:        axi_llc_pkg::event_num_bytes(
        evict_desc.a_x_len,
        evict_desc.a_x_size,
        evict_desc_valid & ~evict_desc.rw & ~evict_desc.spm & ~evict_desc.flush & evict_desc.refill,
        evict_desc_ready),
    evict_write:        axi_llc_pkg::event_num_bytes(
        desc.a_x_len,
        desc.a_x_size,
        miss_valid & desc.rw & ~desc.spm & ~desc.flush & desc.evict,
        miss_ready),
    evict_read:         axi_llc_pkg::event_num_bytes(
        desc.a_x_len,
        desc.a_x_size,
        miss_valid & ~desc.rw & ~desc.spm & ~desc.flush & desc.evict,
        miss_ready),
    evict_flush:        axi_llc_pkg::event_num_bytes(
        desc.a_x_len,
        desc.a_x_size,
        miss_valid & ~desc.spm & desc.flush & desc.evict,
        miss_ready),
    evict_unit_req:     to_way_valid[axi_llc_pkg::EvictUnit] & to_way_ready[axi_llc_pkg::EvictUnit],
    refill_unit_req:    to_way_valid[axi_llc_pkg::RefilUnit] & to_way_ready[axi_llc_pkg::RefilUnit],
    w_chan_unit_req:    to_way_valid[axi_llc_pkg::WChanUnit] & to_way_ready[axi_llc_pkg::WChanUnit],
    r_chan_unit_req:    to_way_valid[axi_llc_pkg::RChanUnit] & to_way_ready[axi_llc_pkg::RChanUnit],
    default: '0
  };

  logic slv_req_i_addr_debug_aw;
  logic slv_req_i_addr_debug_ar;
  logic mst_req_o_addr_debug_aw;
  logic [31:0] slv_req_i_aw_addr_end;
  logic [31:0] slv_req_i_ar_addr_end;
  logic [31:0] mst_req_o_aw_addr_end;
  logic [31:0] target_addr_lb, target_addr_ub;
  assign target_addr_lb = 32'h80007080;
  assign target_addr_ub = 32'h80007090;
  assign slv_req_i_aw_addr_end = slv_req_i.aw.addr + (slv_req_i.aw.len+1) * slv_req_i.aw.size;
  assign slv_req_i_ar_addr_end = slv_req_i.ar.addr + (slv_req_i.ar.len+1) * slv_req_i.ar.size;
  assign mst_req_o_aw_addr_end = mst_req_o.aw.addr + (mst_req_o.aw.len+1) * mst_req_o.aw.size;
  assign slv_req_i_addr_debug_aw = slv_req_i.aw_valid && (slv_req_i.aw.addr < target_addr_ub) && (slv_req_i_aw_addr_end >= target_addr_lb);
  assign slv_req_i_addr_debug_ar = slv_req_i.ar_valid && (slv_req_i.ar.addr < target_addr_ub) && (slv_req_i_ar_addr_end >= target_addr_lb);
  assign mst_req_o_addr_debug_aw = mst_req_o.aw_valid && (mst_req_o.aw.addr < target_addr_ub) && (mst_req_o_aw_addr_end >= target_addr_lb);
  
// pragma translate_off
`ifndef VERILATOR
  initial begin : proc_assert_axi_params
    axi_addr_width : assert(AxiAddrWidth > 32'd0) else
      $fatal(1, "Parameter `AxiAddrWidth` has to be > 0!");
    axi_id_width   : assert(AxiIdWidth > 32'd0) else
      $fatal(1, "Parameter `AxiIdWidth` has to be > 0!");
    axi_data_width : assert(AxiDataWidth inside {32'd8, 32'd16, 32'd32, 32'd64,
                                                 32'd128, 32'd256, 32'd512, 32'd1028}) else
      $fatal(1, "Parameter `AxiDataWidth` has to be inside the AXI4+ATOP specification!");
    axi_user_width : assert(AxiUserWidth > 32'd0) else
      $fatal(1, "Parameter `AxiUserWidth` has to be > 0!");

    // check the address rule fields for the right size
    axi_start_addr : assert($bits(cached_addr_rule.start_addr) == AxiAddrWidth) else
      $fatal(1, "rule_t.start_addr field does not match AxiAddrWidth!");
    axi_end_addr   : assert($bits(cached_addr_rule.end_addr) == AxiAddrWidth) else
      $fatal(1, "rule_t.start_addr field does not match AxiAddrWidth!");

    // check the structs against the Cfg
    slv_aw_id    : assert ($bits(slv_req_i.aw.id) == AxiCfg.SlvPortIdWidth) else
      $fatal(1, $sformatf("llc> AXI Slave port, AW ID width not equal to AxiCfg"));
    slv_aw_addr  : assert ($bits(slv_req_i.aw.addr) == AxiCfg.AddrWidthFull) else
      $fatal(1, $sformatf("llc> AXI Slave port, AW ADDR width not equal to AxiCfg"));
    slv_ar_id    : assert ($bits(slv_req_i.ar.id) == AxiCfg.SlvPortIdWidth) else
      $fatal(1, $sformatf("llc> AXI Slave port, AW ID width not equal to AxiCfg"));
    slv_ar_addr  : assert ($bits(slv_req_i.ar.addr) == AxiCfg.AddrWidthFull) else
      $fatal(1, $sformatf("llc> AXI Slave port, AW ADDR width not equal to AxiCfg"));
    slv_w_data   : assert ($bits(slv_req_i.w.data) == AxiCfg.DataWidthFull) else
      $fatal(1, $sformatf("llc> AXI Slave port, W DATA width not equal to AxiCfg"));
    slv_r_data   : assert ($bits(slv_resp_o.r.data) == AxiCfg.DataWidthFull) else
      $fatal(1, $sformatf("llc> AXI Slave port, R DATA width not equal to AxiCfg"));
    // compare the types against the structs
    slv_req_aw   : assert ($bits(slv_aw_chan_t) == $bits(slv_req_i.aw)) else
      $fatal(1, $sformatf("llc> AXI Slave port, slv_aw_chan_t and slv_req_i.aw not equal"));
    slv_req_w    : assert ($bits(w_chan_t) == $bits(slv_req_i.w)) else
      $fatal(1, $sformatf("llc> AXI Slave port, w_chan_t and slv_req_i.w not equal"));
    slv_req_b    : assert ($bits(slv_b_chan_t) == $bits(slv_resp_o.b)) else
      $fatal(1, $sformatf("llc> AXI Slave port, slv_b_chan_t and slv_resp_o.b not equal"));
    slv_req_ar   : assert ($bits(slv_ar_chan_t) == $bits(slv_req_i.ar)) else
      $fatal(1, $sformatf("llc> AXI Slave port, slv_ar_chan_t and slv_req_i.ar not equal"));
    slv_req_r    : assert ($bits(slv_r_chan_t) == $bits(slv_resp_o.r)) else
      $fatal(1, $sformatf("llc> AXI Slave port, slv_r_chan_t and slv_resp_o.r not equal"));
    // check the structs against the Cfg
    mst_aw_id    : assert ($bits(mst_req_o.aw.id) == AxiCfg.SlvPortIdWidth + 1) else
      $fatal(1, $sformatf("llc> AXI Master port, AW ID not equal to AxiCfg.SlvPortIdWidth + 1"));
    mst_aw_addr  : assert ($bits(mst_req_o.aw.addr) == AxiCfg.AddrWidthFull) else
      $fatal(1, $sformatf("llc> AXI Master port, AW ADDR width not equal to AxiCfg"));
    mst_ar_id    : assert ($bits(mst_req_o.ar.id) == AxiCfg.SlvPortIdWidth + 1) else
      $fatal(1, $sformatf("llc> AXI Master port, AW ID not equal to AxiCfg.SlvPortIdWidth + 1"));
    mst_ar_addr  : assert ($bits(mst_req_o.ar.addr) == AxiCfg.AddrWidthFull) else
      $fatal(1, $sformatf("llc> AXI Master port, AW ADDR width not equal to AxiCfg"));
    mst_w_data   : assert ($bits(mst_req_o.w.data) == AxiCfg.DataWidthFull) else
      $fatal(1, $sformatf("llc> AXI Master port, W DATA width not equal to AxiCfg"));
    mst_r_data   : assert ($bits(mst_resp_i.r.data) == AxiCfg.DataWidthFull) else
      $fatal(1, $sformatf("llc> AXI Master port, R DATA width not equal to AxiCfg"));
    // compare the types against the structs
    mst_req_aw   : assert ($bits(mst_aw_chan_t) == $bits(mst_req_o.aw)) else
      $fatal(1, $sformatf("llc> AXI Master port, mst_aw_chan_t and mst_req_o.aw not equal"));
    mst_req_w    : assert ($bits(w_chan_t) == $bits(mst_req_o.w)) else
      $fatal(1, $sformatf("llc> AXI Master port, w_chan_t and mst_req_o.w not equal"));
    mst_req_b    : assert ($bits(mst_b_chan_t) == $bits(mst_resp_i.b)) else
      $fatal(1, $sformatf("llc> AXI Master port, mst_b_chan_t and mst_resp_i.b not equal"));
    mst_req_ar   : assert ($bits(mst_ar_chan_t) == $bits(mst_req_o.ar)) else
      $fatal(1, $sformatf("llc> AXI Master port, mst_ar_chan_t and mst_req_i.ar not equal"));
    mst_req_r    : assert ($bits(mst_r_chan_t) == $bits(mst_resp_i.r)) else
      $fatal(1, $sformatf("llc> AXI Slave port, slv_r_chan_t and mst_resp_i.r not equal"));

    cfg_num_lines : assert(Cfg.NumLines > 0 && $onehot(Cfg.NumLines)) else
      $fatal(1, "Parameter 'Cfg.NumLines' must be the integer power of 2 to ensure correct function for set based partition!");
    max_partition : assert((MaxPartition != 1) && (MaxPartition <= Cfg.NumLines)) else
      $fatal(1, "Parameter 'MaxPartition' must not be 1 or larger than number of cache lines to ensure correct function for set based partition!");

  end
`endif
// pragma translate_on

endmodule
