module synth_axi_llc import axi_pkg::*; #(
  /// Set Associativity of the LLC
  parameter int unsigned SetAssociativity = 32'd8,
  /// Number of cache lines of the LLC
  parameter int unsigned NumLines         = 32'd256, // must be 256 currently
  /// Number of Blocks per cache line
  parameter int unsigned NumBlocks        = 32'd8,
  /// Max. number of threads supported for partitioning
  parameter int unsigned MaxPartition        = 32'd256,
  /// ID width of the Full AXI slave port, master port has ID `AxiIdWidthFull + 32'd1`
  parameter int unsigned AxiIdWidth       = 32'd6,
  /// Address width of the full AXI bus
  parameter int unsigned AxiAddrWidth     = 32'd48,
  /// Data width of the full AXI bus
  parameter int unsigned AxiDataWidth     = 32'd64,
  /// User width of the full AXI bus
  parameter int unsigned AxiUserWidth     = 32'd8,
  /// Axi types
  parameter type axi_slv_id_t             = logic [AxiIdWidth-1:0],
  parameter type axi_mst_id_t             = logic [AxiIdWidth:0],
  parameter type axi_addr_t               = logic [AxiAddrWidth-1:0],
  parameter type axi_data_t               = logic [AxiDataWidth-1:0],
  parameter type axi_strb_t               = logic [AxiDataWidth/32'd8-1:0],
  parameter type axi_user_t               = logic [AxiUserWidth-1:0]
) (
  /// Rising-edge clock of all ports.
  input logic clk_i,
  /// Asynchronous reset, active low
  input logic rst_ni,
  /// Test mode activate, active high.
  input logic test_i,

  /***********************************
  /* Slave ports request inputs
  ***********************************/
  // AW
  input axi_slv_id_t      slv_aw_id,
  input axi_addr_t        slv_aw_addr,
  input axi_pkg::len_t    slv_aw_len,
  input axi_pkg::size_t   slv_aw_size,
  input axi_pkg::burst_t  slv_aw_burst,
  input logic             slv_aw_lock,
  input axi_pkg::cache_t  slv_aw_cache,
  input axi_pkg::prot_t   slv_aw_prot,
  input axi_pkg::qos_t    slv_aw_qos,
  input axi_pkg::region_t slv_aw_region,
  input axi_pkg::atop_t   slv_aw_atop,
  input axi_user_t        slv_aw_user,
  input logic             slv_aw_valid,
  // W
  input axi_data_t        slv_w_data,
  input axi_strb_t        slv_w_strb,
  input logic             slv_w_last,
  input axi_user_t        slv_w_user,
  input logic             slv_w_valid,
  // B
  input logic             slv_b_ready,
  // AR
  input axi_slv_id_t      slv_ar_id,
  input axi_addr_t        slv_ar_addr,
  input axi_pkg::len_t    slv_ar_len,
  input axi_pkg::size_t   slv_ar_size,
  input axi_pkg::burst_t  slv_ar_burst,
  input logic             slv_ar_lock,
  input axi_pkg::cache_t  slv_ar_cache,
  input axi_pkg::prot_t   slv_ar_prot,
  input axi_pkg::qos_t    slv_ar_qos,
  input axi_pkg::region_t slv_ar_region,
  input axi_user_t        slv_ar_user,
  input logic             slv_ar_valid,
  // R
  input logic             slv_r_ready,

  /***********************************
  /* Slave ports response outputs
  ***********************************/
  // AW
  output logic           slv_aw_ready,
  // AR
  output logic           slv_ar_ready,
  // W
  output logic           slv_w_ready,
  // B
  output logic           slv_b_valid,
  output axi_slv_id_t    slv_b_id,
  output axi_pkg::resp_t slv_b_resp,
  output axi_user_t      slv_b_user,
  // R
  output logic           slv_r_valid,
  output axi_slv_id_t    slv_r_id,
  output axi_data_t      slv_r_data,
  output axi_pkg::resp_t slv_r_resp,
  output logic           slv_r_last,
  output axi_user_t      slv_r_user,

  /***********************************
  /* Master ports request outputs
  ***********************************/
  // AW
  output axi_mst_id_t       mst_aw_id,
  output axi_addr_t         mst_aw_addr,
  output axi_pkg::len_t     mst_aw_len,
  output axi_pkg::size_t    mst_aw_size,
  output axi_pkg::burst_t   mst_aw_burst,
  output logic              mst_aw_lock,
  output axi_pkg::cache_t   mst_aw_cache,
  output axi_pkg::prot_t    mst_aw_prot,
  output axi_pkg::qos_t     mst_aw_qos,
  output axi_pkg::region_t  mst_aw_region,
  output axi_pkg::atop_t    mst_aw_atop,
  output axi_user_t         mst_aw_user,
  output logic              mst_aw_valid,
  // W
  output axi_data_t         mst_w_data,
  output axi_strb_t         mst_w_strb,
  output logic              mst_w_last,
  output axi_user_t         mst_w_user,
  output logic              mst_w_valid,
  // B
  output logic              mst_b_ready,
  // AR
  output axi_mst_id_t       mst_ar_id,
  output axi_addr_t         mst_ar_addr,
  output axi_pkg::len_t     mst_ar_len,
  output axi_pkg::size_t    mst_ar_size,
  output axi_pkg::burst_t   mst_ar_burst,
  output logic              mst_ar_lock,
  output axi_pkg::cache_t   mst_ar_cache,
  output axi_pkg::prot_t    mst_ar_prot,
  output axi_pkg::qos_t     mst_ar_qos,
  output axi_pkg::region_t  mst_ar_region,
  output axi_user_t         mst_ar_user,
  output logic              mst_ar_valid,
  // R
  output logic              mst_r_ready,

  /***********************************
  /* Master ports response inputs
  ***********************************/
  // AW
  input logic            mst_aw_ready,
  // AR
  input logic            mst_ar_ready,
  // W
  input logic            mst_w_ready,
  // B
  input logic            mst_b_valid,
  input axi_mst_id_t     mst_b_id,
  input axi_pkg::resp_t  mst_b_resp,
  input axi_user_t       mst_b_user,
  // R
  input logic            mst_r_valid,
  input axi_mst_id_t     mst_r_id,
  input axi_data_t       mst_r_data,
  input axi_pkg::resp_t  mst_r_resp,
  input logic            mst_r_last,
  input axi_user_t       mst_r_user,

  /*******************************************
  /* Configuration RegBus interface - request
  *******************************************/
  input logic [31:0]     conf_req_addr,
  input logic            conf_req_w,
  input logic [31:0]     conf_req_wdata,
  input logic [3:0]      conf_req_wstrb,
  input logic            conf_req_valid,

  /*******************************************
  /* Configuration RegBus interface - response
  *******************************************/
  output logic [31:0]    conf_resp_rdata,
  output logic           conf_resp_error,
  output logic           conf_resp_ready,

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
  output axi_llc_pkg::events_t axi_llc_events_o
);

  /////////////////////////////
  // Axi channel definitions //
  /////////////////////////////
  `include "axi/typedef.svh"
  `include "axi/assign.svh"
  `include "register_interface/typedef.svh"
  `include "register_interface/assign.svh"

  `AXI_TYPEDEF_AW_CHAN_T(axi_slv_aw_t, axi_addr_t, axi_slv_id_t, axi_user_t)
  `AXI_TYPEDEF_AW_CHAN_T(axi_mst_aw_t, axi_addr_t, axi_mst_id_t, axi_user_t)
  `AXI_TYPEDEF_W_CHAN_T(axi_w_t, axi_data_t, axi_strb_t, axi_user_t)
  `AXI_TYPEDEF_B_CHAN_T(axi_slv_b_t, axi_slv_id_t, axi_user_t)
  `AXI_TYPEDEF_B_CHAN_T(axi_mst_b_t, axi_mst_id_t, axi_user_t)
  `AXI_TYPEDEF_AR_CHAN_T(axi_slv_ar_t, axi_addr_t, axi_slv_id_t, axi_user_t)
  `AXI_TYPEDEF_AR_CHAN_T(axi_mst_ar_t, axi_addr_t, axi_mst_id_t, axi_user_t)
  `AXI_TYPEDEF_R_CHAN_T(axi_slv_r_t, axi_data_t, axi_slv_id_t, axi_user_t)
  `AXI_TYPEDEF_R_CHAN_T(axi_mst_r_t, axi_data_t, axi_mst_id_t, axi_user_t)

  `AXI_TYPEDEF_REQ_T(axi_slv_req_t, axi_slv_aw_t, axi_w_t, axi_slv_ar_t)
  `AXI_TYPEDEF_RESP_T(axi_slv_resp_t, axi_slv_b_t, axi_slv_r_t)
  `AXI_TYPEDEF_REQ_T(axi_mst_req_t, axi_mst_aw_t, axi_w_t, axi_mst_ar_t)
  `AXI_TYPEDEF_RESP_T(axi_mst_resp_t, axi_mst_b_t, axi_mst_r_t)

  `REG_BUS_TYPEDEF_ALL(conf, logic [31:0], logic [31:0], logic [3:0])

   // rule definitions
  typedef struct packed {
    int unsigned idx;
    axi_addr_t   start_addr;
    axi_addr_t   end_addr;
  } rule_full_t;

  ////////////////////
  // Address Ranges //
  ////////////////////
  localparam axi_addr_t SpmRegionLength    =
      axi_addr_t'(SetAssociativity * NumLines * NumBlocks * AxiDataWidth / 32'd8);
  localparam axi_addr_t CachedRegionLength = axi_addr_t'(2*SpmRegionLength);

  /////////////////
  // Dut signals //
  /////////////////
  // axi_llc_pkg::events_t llc_events;
  // AXI channels
  axi_slv_req_t  slv_req;
  axi_slv_resp_t slv_resp;
  axi_mst_req_t  mst_req;
  axi_mst_resp_t mst_resp;
  conf_req_t     reg_cfg_req;
  conf_rsp_t     reg_cfg_rsp;

  // Connect XBAR interfaces
  // SLV Request
  assign slv_req.aw.id     = slv_aw_id;
  assign slv_req.aw.addr   = slv_aw_addr;
  assign slv_req.aw.len    = slv_aw_len;
  assign slv_req.aw.size   = slv_aw_size;
  assign slv_req.aw.burst  = slv_aw_burst;
  assign slv_req.aw.lock   = slv_aw_lock;
  assign slv_req.aw.cache  = slv_aw_cache;
  assign slv_req.aw.prot   = slv_aw_prot;
  assign slv_req.aw.qos    = slv_aw_qos;
  assign slv_req.aw.region = slv_aw_region;
  assign slv_req.aw.atop   = slv_aw_atop;
  assign slv_req.aw.user   = slv_aw_user;
  assign slv_req.aw_valid  = slv_aw_valid;
  assign slv_req.w.data    = slv_w_data;
  assign slv_req.w.strb    = slv_w_strb;
  assign slv_req.w.last    = slv_w_last;
  assign slv_req.w.user    = slv_w_user;
  assign slv_req.w_valid   = slv_w_valid;
  assign slv_req.b_ready   = slv_b_ready;
  assign slv_req.ar.id     = slv_ar_id;
  assign slv_req.ar.addr   = slv_ar_addr;
  assign slv_req.ar.len    = slv_ar_len;
  assign slv_req.ar.size   = slv_ar_size;
  assign slv_req.ar.burst  = slv_ar_burst;
  assign slv_req.ar.lock   = slv_ar_lock;
  assign slv_req.ar.cache  = slv_ar_cache;
  assign slv_req.ar.prot   = slv_ar_prot;
  assign slv_req.ar.qos    = slv_ar_qos;
  assign slv_req.ar.region = slv_ar_region;
  assign slv_req.ar.user   = slv_ar_user;
  assign slv_req.ar_valid  = slv_ar_valid;
  assign slv_req.r_ready   = slv_r_ready;
  // SLV Response
  assign slv_aw_ready = slv_resp.aw_ready;
  assign slv_ar_ready = slv_resp.ar_ready;
  assign slv_w_ready  = slv_resp.w_ready;
  assign slv_b_valid  = slv_resp.b_valid;
  assign slv_b_id     = slv_resp.b.id;
  assign slv_b_resp   = slv_resp.b.resp;
  assign slv_b_user   = slv_resp.b.user;
  assign slv_r_valid  = slv_resp.r_valid;
  assign slv_r_id     = slv_resp.r.id;
  assign slv_r_data   = slv_resp.r.data;
  assign slv_r_resp   = slv_resp.r.resp;
  assign slv_r_last   = slv_resp.r.last;
  assign slv_r_user   = slv_resp.r.user;
  // MST Request
  assign mst_aw_id     = mst_req.aw.id;
  assign mst_aw_addr   = mst_req.aw.addr;
  assign mst_aw_len    = mst_req.aw.len;
  assign mst_aw_size   = mst_req.aw.size;
  assign mst_aw_burst  = mst_req.aw.burst;
  assign mst_aw_lock   = mst_req.aw.lock;
  assign mst_aw_cache  = mst_req.aw.cache;
  assign mst_aw_prot   = mst_req.aw.prot;
  assign mst_aw_qos    = mst_req.aw.qos;
  assign mst_aw_region = mst_req.aw.region;
  assign mst_aw_atop   = mst_req.aw.atop;
  assign mst_aw_user   = mst_req.aw.user;
  assign mst_aw_valid  = mst_req.aw_valid;
  assign mst_w_data    = mst_req.w.data;
  assign mst_w_strb    = mst_req.w.strb;
  assign mst_w_last    = mst_req.w.last;
  assign mst_w_user    = mst_req.w.user;
  assign mst_w_valid   = mst_req.w_valid;
  assign mst_b_ready   = mst_req.b_ready;
  assign mst_ar_id     = mst_req.ar.id;
  assign mst_ar_addr   = mst_req.ar.addr;
  assign mst_ar_len    = mst_req.ar.len;
  assign mst_ar_size   = mst_req.ar.size;
  assign mst_ar_burst  = mst_req.ar.burst;
  assign mst_ar_lock   = mst_req.ar.lock;
  assign mst_ar_cache  = mst_req.ar.cache;
  assign mst_ar_prot   = mst_req.ar.prot;
  assign mst_ar_qos    = mst_req.ar.qos;
  assign mst_ar_region = mst_req.ar.region;
  assign mst_ar_user   = mst_req.ar.user;
  assign mst_ar_valid  = mst_req.ar_valid;
  assign mst_r_ready   = mst_req.r_ready;
  // MST Response
  assign mst_resp.aw_ready = mst_aw_ready;
  assign mst_resp.ar_ready = mst_ar_ready;
  assign mst_resp.w_ready  = mst_w_ready;
  assign mst_resp.b_valid  = mst_b_valid;
  assign mst_resp.b.id     = mst_b_id;
  assign mst_resp.b.resp   = mst_b_resp;
  assign mst_resp.b.user   = mst_b_user;
  assign mst_resp.r_valid  = mst_r_valid;
  assign mst_resp.r.id     = mst_r_id;
  assign mst_resp.r.data   = mst_r_data;
  assign mst_resp.r.resp   = mst_r_resp;
  assign mst_resp.r.last   = mst_r_last;
  assign mst_resp.r.user   = mst_r_user;
  // Configuration Register Request
  assign reg_cfg_req.addr   = conf_req_addr;
  assign reg_cfg_req.write  = conf_req_w;
  assign reg_cfg_req.wdata  = conf_req_wdata;
  assign reg_cfg_req.wstrb  = conf_req_wstrb;
  assign reg_cfg_req.valid  = conf_req_valid;
  // Configuration Reegister Response
  assign conf_resp_rdata   = reg_cfg_rsp.rdata;
  assign conf_resp_error   = reg_cfg_rsp.error;
  assign conf_resp_ready   = reg_cfg_rsp.ready;


  ///////////////////////
  // Design under test //
  ///////////////////////
  axi_llc_reg_wrap #(
    .SetAssociativity ( SetAssociativity ),
    .NumLines         ( NumLines         ),
    .NumBlocks        ( NumBlocks        ),
    .MaxPartition        ( MaxPartition        ),
    .AxiIdWidth       ( AxiIdWidth         ),
    .AxiAddrWidth     ( AxiAddrWidth       ),
    .AxiDataWidth     ( AxiDataWidth       ),
    .AxiUserWidth     ( AxiUserWidth       ),
    .slv_req_t        ( axi_slv_req_t      ),
    .slv_resp_t       ( axi_slv_resp_t     ),
    .mst_req_t        ( axi_mst_req_t      ),
    .mst_resp_t       ( axi_mst_resp_t     ),
    .reg_req_t        ( conf_req_t         ),
    .reg_resp_t       ( conf_rsp_t         ),
    .rule_full_t      ( rule_full_t        )
  ) i_axi_llc_dut (
    .clk_i               ( clk_i                                  ),
    .rst_ni              ( rst_ni                                 ),
    .test_i              ( test_i                                 ),
    .slv_req_i           ( slv_req                                ),
    .slv_resp_o          ( slv_resp                               ),
    .mst_req_o           ( mst_req                                ),
    .mst_resp_i          ( mst_resp                               ),
    .conf_req_i          ( reg_cfg_req                            ),
    .conf_resp_o         ( reg_cfg_rsp                            ),
    .cached_start_addr_i ( cached_start_addr_i                    ),
    .cached_end_addr_i   ( cached_start_addr_i+CachedRegionLength ),
    .spm_start_addr_i    ( spm_start_addr_i                       ),
    .axi_llc_events_o    ( axi_llc_events_o                       )
  );
endmodule