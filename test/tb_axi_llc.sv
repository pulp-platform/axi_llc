// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Wolfgang Roenninger <wroennin@iis.ee.ethz.ch>
// - Nicole Narr <narrn@ethz.ch>
// - Christopher Reinwardt <creinwar@ethz.ch>

/// Testbench for the module `axi_llc_top`.
module tb_axi_llc #(
  /// Set Associativity of the LLC
  parameter int unsigned TbSetAssociativity = 32'd8,
  /// Number of cache lines of the LLC
  parameter int unsigned TbNumLines         = 32'd256, // must be 256 currently
  /// Number of Blocks per cache line
  parameter int unsigned TbNumBlocks        = 32'd8,
  /// Max. number of threads supported for partitioning
  parameter int unsigned TbMaxThread        = 32'd256,
  /// ID width of the Full AXI slave port, master port has ID `AxiIdWidthFull + 32'd1`
  parameter int unsigned TbAxiIdWidthFull   = 32'd6,
  /// Address width of the full AXI bus
  parameter int unsigned TbAxiAddrWidthFull = 32'd48,
  /// Data width of the full AXI bus
  parameter int unsigned TbAxiDataWidthFull = 32'd64,
  /// Width of the Registers
  parameter int unsigned TbRegWidth         = 32'd64,
  /// Number of random write transactions in a testblock.
  parameter int unsigned TbNumWrites        = 32'd1100,
  /// Number of random read transactions in a testblock.
  parameter int unsigned TbNumReads         = 32'd1500,
  /// Cycle time for the TB clock generator
  parameter time         TbCyclTime         = 10ns,
  /// Application time to the DUT
  parameter time         TbApplTime         = 2ns,
  /// Test time of the DUT
  parameter time         TbTestTime         = 8ns
);
  /////////////////////////////
  // Axi channel definitions //
  /////////////////////////////
  `include "axi/typedef.svh"
  `include "axi/assign.svh"
  `include "register_interface/typedef.svh"
  `include "register_interface/assign.svh"

  localparam int unsigned TbAxiStrbWidthFull = TbAxiDataWidthFull / 32'd8;
  // localparam int unsigned TbAxiUserWidthFull = 32'd8;
  localparam int unsigned TbAxiUserWidthFull = $clog2(TbMaxThread);



  typedef logic [TbAxiIdWidthFull-1:0]     axi_slv_id_t;
  typedef logic [TbAxiIdWidthFull:0]       axi_mst_id_t;
  typedef logic [TbAxiAddrWidthFull-1:0]   axi_addr_t;
  typedef logic [TbAxiDataWidthFull-1:0]   axi_data_t;
  typedef logic [TbAxiStrbWidthFull-1:0]   axi_strb_t;
  typedef logic [TbAxiUserWidthFull-1:0]   axi_user_t;

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

  typedef logic [7:0] byte_t;

  // rule definitions
  typedef struct packed {
    int unsigned idx;
    axi_addr_t   start_addr;
    axi_addr_t   end_addr;
  } rule_full_t;

  // Config register addresses
  // typedef enum logic [31:0] {
  //   CfgSpmLow     = 32'h00,
  //   CfgSpmHigh    = 32'h04,
  //   CfgFlushLow   = 32'h08,
  //   CfgFlushHigh  = 32'h0C,
  //   CfgFlushSet0Low  = 32'h10,
  //   CfgFlushSet0High = 32'h14,
  //   CfgFlushSet1Low  = 32'h18,
  //   CfgFlushSet1High = 32'h1c,
  //   CfgFlushSet2Low  = 32'h20,
  //   CfgFlushSet2High = 32'h24,
  //   CfgFlushSet3Low  = 32'h28,
  //   CfgFlushSet3High = 32'h2c,
  //   CfgSetPartition0Low = 32'h30,
  //   CfgSetPartition0High = 32'h34,
  //   CfgSetPartition1Low = 32'h38,
  //   CfgSetPartition1High = 32'h3c,
  //   CfgSetPartition2Low = 32'h40,
  //   CfgSetPartition2High = 32'h44,
  //   CfgSetPartition3Low = 32'h48,
  //   CfgSetPartition3High = 32'h4c,
  //   CommitCfg     = 32'h50,
  //   CommitPadding = 32'h54,
  //   CommitPartitionCfg     = 32'h58,
  //   CommitPartitionPadding = 32'h5c,
  //   FlushedLow    = 32'h60,
  //   FlushedHigh   = 32'h64,
  //   BistOutLow    = 32'h68,
  //   BistOutHigh   = 32'h6c,
  //   SetAssoLow    = 32'h70,
  //   SetAssoHigh   = 32'h74,
  //   NumLinesLow   = 32'h78,
  //   NumLinesHigh  = 32'h7c,
  //   NumBlocksLow  = 32'h80,
  //   NumBlocksHigh = 32'h84,
  //   VersionLow    = 32'h88,
  //   VersionHigh   = 32'h8c,
  //   FlushedSet0Low  = 32'h90,
  //   FlushedSet0High  = 32'h94,
  //   FlushedSet1Low  = 32'h98,
  //   FlushedSet1High  = 32'h9c,
  //   FlushedSet2Low  = 32'ha0,
  //   FlushedSet2High  = 32'ha4,
  //   FlushedSet3Low  = 32'ha8,
  //   FlushedSet3High  = 32'hac
  // } llc_cfg_addr_e;
  // Config register addresses

  // Config register addresses
  typedef enum logic [31:0] {
    CfgSpmLow     = 32'h00,
    CfgSpmHigh    = 32'h04,
    CfgFlushLow   = 32'h08,
    CfgFlushHigh  = 32'h0C,
    CfgFlushThreadLow  = 32'h10,
    CfgFlushThreadHigh = 32'h14,
    CfgSetPartition0Low = 32'h18,
    CfgSetPartition0High = 32'h1c,
    CfgSetPartition1Low = 32'h20,
    CfgSetPartition1High = 32'h24,
    CfgSetPartition2Low = 32'h28,
    CfgSetPartition2High = 32'h2c,
    CfgSetPartition3Low = 32'h30,
    CfgSetPartition3High = 32'h34,
    CfgSetPartition4Low = 32'h38,
    CfgSetPartition4High = 32'h3c,
    CfgSetPartition5Low = 32'h40,
    CfgSetPartition5High = 32'h44,
    CfgSetPartition6Low = 32'h48,
    CfgSetPartition6High = 32'h4c,
    CfgSetPartition7Low = 32'h50,
    CfgSetPartition7High = 32'h54,
    CfgSetPartition8Low = 32'h58,
    CfgSetPartition8High = 32'h5c,
    CfgSetPartition9Low = 32'h60,
    CfgSetPartition9High = 32'h64,
    CfgSetPartition10Low = 32'h68,
    CfgSetPartition10High = 32'h6c,
    CfgSetPartition11Low = 32'h70,
    CfgSetPartition11High = 32'h74,
    CfgSetPartition12Low = 32'h78,
    CfgSetPartition12High = 32'h7c,
    CfgSetPartition13Low = 32'h80,
    CfgSetPartition13High = 32'h84,
    CfgSetPartition14Low = 32'h88,
    CfgSetPartition14High = 32'h8c,
    CfgSetPartition15Low = 32'h90,
    CfgSetPartition15High = 32'h94,
    CfgSetPartition16Low = 32'h98,
    CfgSetPartition16High = 32'h9c,
    CfgSetPartition17Low = 32'ha0,
    CfgSetPartition17High = 32'ha4,
    CfgSetPartition18Low = 32'ha8,
    CfgSetPartition18High = 32'hac,
    CfgSetPartition19Low = 32'hb0,
    CfgSetPartition19High = 32'hb4,
    CfgSetPartition20Low = 32'hb8,
    CfgSetPartition20High = 32'hbc,
    CfgSetPartition21Low = 32'hc0,
    CfgSetPartition21High = 32'hc4,
    CfgSetPartition22Low = 32'hc8,
    CfgSetPartition22High = 32'hcc,
    CfgSetPartition23Low = 32'hd0,
    CfgSetPartition23High = 32'hd4,
    CfgSetPartition24Low = 32'hd8,
    CfgSetPartition24High = 32'hdc,
    CfgSetPartition25Low = 32'he0,
    CfgSetPartition25High = 32'he4,
    CfgSetPartition26Low = 32'he8,
    CfgSetPartition26High = 32'hec,
    CfgSetPartition27Low = 32'hf0,
    CfgSetPartition27High = 32'hf4,
    CfgSetPartition28Low = 32'hf8,
    CfgSetPartition28High = 32'hfc,
    CfgSetPartition29Low = 32'h100,
    CfgSetPartition29High = 32'h104,
    CfgSetPartition30Low = 32'h108,
    CfgSetPartition30High = 32'h10c,
    CfgSetPartition31Low = 32'h110,
    CfgSetPartition31High = 32'h114,
    CommitCfg     = 32'h118,
    CommitPadding = 32'h11c,
    CommitPartitionCfg     = 32'h138,
    CommitPartitionPadding = 32'h13c,
    FlushedLow    = 32'h140,
    FlushedHigh   = 32'h144,
    BistOutLow    = 32'h148,
    BistOutHigh   = 32'h14c,
    SetAssoLow    = 32'h150,
    SetAssoHigh   = 32'h154,
    NumLinesLow   = 32'h158,
    NumLinesHigh  = 32'h15c,
    NumBlocksLow  = 32'h160,
    NumBlocksHigh = 32'h164,
    VersionLow    = 32'h168,
    VersionHigh   = 32'h16c,
    BistStatus    = 32'h170,
    FlushedSet0Low  = 32'h174,
    FlushedSet0High  = 32'h178,
    FlushedSet1Low  = 32'h17c,
    FlushedSet1High  = 32'h180,
    FlushedSet2Low  = 32'h184,
    FlushedSet2High  = 32'h188,
    FlushedSet3Low  = 32'h18c,
    FlushedSet3High  = 32'h190
  } llc_cfg_addr_e;

  ////////////////////////////////
  // Stimuli generator typedefs //
  ////////////////////////////////
  typedef axi_test::axi_rand_master #(
    .AW                   ( TbAxiAddrWidthFull ),
    .DW                   ( TbAxiDataWidthFull ),
    .IW                   ( TbAxiIdWidthFull   ),
    .UW                   ( TbAxiUserWidthFull ),
    .TA                   ( TbApplTime         ),
    .TT                   ( TbTestTime         ),
    .MAX_READ_TXNS        ( 5                  ),
    .MAX_WRITE_TXNS       ( 5                  ),
    .AX_MIN_WAIT_CYCLES   ( 0                  ),
    .AX_MAX_WAIT_CYCLES   ( 50                 ),
    .W_MIN_WAIT_CYCLES    ( 0                  ),
    .W_MAX_WAIT_CYCLES    ( 0                  ),
    .RESP_MIN_WAIT_CYCLES ( 0                  ),
    .RESP_MAX_WAIT_CYCLES ( 0                  ),
    .AXI_BURST_FIXED      ( 1'b0               ),
    .AXI_BURST_INCR       ( 1'b1               ),
    .AXI_BURST_WRAP       ( 1'b0               ),
    .MAXTHREAD            ( TbMaxThread        )
  ) axi_rand_master_t;

  typedef axi_test::axi_rand_slave #(
    .AW                   ( TbAxiAddrWidthFull        ),
    .DW                   ( TbAxiDataWidthFull        ),
    .IW                   ( TbAxiIdWidthFull + 32'd1  ),
    .UW                   ( TbAxiUserWidthFull        ),
    .TA                   ( TbApplTime                ),
    .TT                   ( TbTestTime                ),
    .AX_MIN_WAIT_CYCLES   ( 0                         ),
    .AX_MAX_WAIT_CYCLES   ( 50                        ),
    .R_MIN_WAIT_CYCLES    ( 10                        ),
    .R_MAX_WAIT_CYCLES    ( 20                        ),
    .RESP_MIN_WAIT_CYCLES ( 10                        ),
    .RESP_MAX_WAIT_CYCLES ( 20                        ),
    .MAPPED               ( 1'b1                      )
  ) axi_rand_slave_t;

  // Standard 32-bit RegBus
  typedef reg_test::reg_driver #(
    .AW ( 32'd32      ),
    .DW ( 32'd32      ),
    .TA ( TbApplTime  ),
    .TT ( TbTestTime  )
  ) regbus_conf_driver_t;

  typedef axi_test::axi_scoreboard #(
    .IW( TbAxiIdWidthFull   ),
    .AW( TbAxiAddrWidthFull ),
    .DW( TbAxiDataWidthFull ),
    .UW( TbAxiUserWidthFull ),
    .TT( TbTestTime         )
  ) axi_scoreboard_cpu_t;

  typedef axi_test::axi_scoreboard #(
    .IW( TbAxiIdWidthFull + 32'd1  ),
    .AW( TbAxiAddrWidthFull        ),
    .DW( TbAxiDataWidthFull        ),
    .UW( TbAxiUserWidthFull        ),
    .TT( TbTestTime                )
  ) axi_scoreboard_mem_t;

  ////////////////////
  // Address Ranges //
  ////////////////////
  localparam axi_addr_t SpmRegionStart     = axi_addr_t'(0);
  localparam axi_addr_t SpmRegionLength    =
      axi_addr_t'(TbSetAssociativity * TbNumLines * TbNumBlocks * TbAxiDataWidthFull / 32'd8);
  localparam axi_addr_t CachedRegionStart  = axi_addr_t'(32'h8000_0000);
  localparam axi_addr_t CachedRegionLength = axi_addr_t'(2*SpmRegionLength);

  /////////////////
  // Dut signals //
  /////////////////
  logic clk, rst_n, test;
  axi_llc_pkg::events_t llc_events;
  // AXI channels
  axi_slv_req_t  axi_cpu_req;
  axi_slv_resp_t axi_cpu_res;
  axi_mst_req_t  axi_mem_req;
  axi_mst_resp_t axi_mem_res;
  conf_req_t     reg_cfg_req;
  conf_rsp_t     reg_cfg_rsp;
  // Tb signals
  logic enable_counters, print_counters, enable_progress;

  ///////////////////////
  // AXI DV interfaces //
  ///////////////////////
  AXI_BUS_DV #(
    .AXI_ADDR_WIDTH ( TbAxiAddrWidthFull ),
    .AXI_DATA_WIDTH ( TbAxiDataWidthFull ),
    .AXI_ID_WIDTH   ( TbAxiIdWidthFull   ),
    .AXI_USER_WIDTH ( TbAxiUserWidthFull )
  ) axi_cpu_intf_dv (
    .clk_i ( clk )
  );

  AXI_BUS_DV #(
    .AXI_ADDR_WIDTH ( TbAxiAddrWidthFull ),
    .AXI_DATA_WIDTH ( TbAxiDataWidthFull ),
    .AXI_ID_WIDTH   ( TbAxiIdWidthFull   ),
    .AXI_USER_WIDTH ( TbAxiUserWidthFull )
  ) score_cpu_intf_dv (
    .clk_i ( clk )
  );

  AXI_BUS_DV #(
    .AXI_ADDR_WIDTH ( TbAxiAddrWidthFull       ),
    .AXI_DATA_WIDTH ( TbAxiDataWidthFull       ),
    .AXI_ID_WIDTH   ( TbAxiIdWidthFull + 32'd1 ),
    .AXI_USER_WIDTH ( TbAxiUserWidthFull       )
  ) axi_mem_intf_dv (
    .clk_i ( clk )
  );

  AXI_BUS_DV #(
    .AXI_ADDR_WIDTH ( TbAxiAddrWidthFull       ),
    .AXI_DATA_WIDTH ( TbAxiDataWidthFull       ),
    .AXI_ID_WIDTH   ( TbAxiIdWidthFull + 32'd1 ),
    .AXI_USER_WIDTH ( TbAxiUserWidthFull       )
  ) score_mem_intf_dv (
    .clk_i ( clk )
  );

  REG_BUS #(
    .ADDR_WIDTH ( 32'd32 ),
    .DATA_WIDTH ( 32'd32 )
  ) reg_cfg_intf (
    .clk_i ( clk )
  );

  `AXI_ASSIGN_TO_REQ(axi_cpu_req, axi_cpu_intf_dv)
  `AXI_ASSIGN_FROM_RESP(axi_cpu_intf_dv, axi_cpu_res)

  `AXI_ASSIGN_FROM_REQ(axi_mem_intf_dv, axi_mem_req)
  `AXI_ASSIGN_TO_RESP(axi_mem_res, axi_mem_intf_dv)

  `AXI_ASSIGN_MONITOR(score_cpu_intf_dv, axi_cpu_intf_dv)
  `AXI_ASSIGN_MONITOR(score_mem_intf_dv, axi_mem_intf_dv)

  `REG_BUS_ASSIGN_TO_REQ(reg_cfg_req, reg_cfg_intf)
  `REG_BUS_ASSIGN_FROM_RSP(reg_cfg_intf, reg_cfg_rsp)

  /////////////////////////
  // Clock and Reset gen //
  /////////////////////////
  clk_rst_gen #(
    .ClkPeriod     ( TbCyclTime ),
    .RstClkCycles  ( 32'd5    )
  ) i_clk_rst_gen (
    .clk_o  ( clk   ),
    .rst_no ( rst_n )
  );
  assign test = 1'b0;

  ////////////////////////////////////////
  // Scoreboards and simulation control //
  ////////////////////////////////////////
  //axi_rand_master_t axi_master;
  //axi_rand_slave_t  axi_slave;


  initial begin : proc_sim_crtl
    automatic axi_scoreboard_cpu_t   cpu_scoreboard  = new( score_cpu_intf_dv );
    automatic axi_scoreboard_mem_t   mem_scoreboard  = new( score_mem_intf_dv );
    automatic axi_rand_master_t      axi_master      = new( axi_cpu_intf_dv   );
    automatic regbus_conf_driver_t   reg_conf_driver = new( reg_cfg_intf      );
    // Variables for the RegBus configuration transactions.
    automatic logic[31:0]     cfg_addr    = 32'd0;
    automatic logic[31:0]     cfg_data    = 32'd0;
    automatic logic[ 3:0]     cfg_wstrb   =  4'd0;
    automatic logic           cfg_error   =  1'b0;

    // Reset the AXI drivers and scoreboards
    cpu_scoreboard.reset();
    mem_scoreboard.reset();
    axi_master.reset();
    reg_conf_driver.reset_master();
    enable_counters = 1'b0;
    print_counters  = 1'b0;
    enable_progress = 1'b0;

    // Set some mem regions for rand axi master
    axi_master.add_memory_region(CachedRegionStart, CachedRegionStart + 2*CachedRegionLength,
                                 axi_pkg::WBACK_RWALLOCATE);
    axi_master.add_memory_region(SpmRegionStart, SpmRegionStart + SpmRegionLength,
                                 axi_pkg::NORMAL_NONCACHEABLE_BUFFERABLE);

    cpu_scoreboard.enable_all_checks();
    mem_scoreboard.enable_all_checks();

    @(posedge rst_n);
    cpu_scoreboard.monitor();
    mem_scoreboard.monitor();
    enable_counters = 1'b1;
    enable_progress = 1'b1;

    $info("Wait for BIST to complete.");
    do begin
      reg_conf_driver.send_read(BistStatus, cfg_data, cfg_error);
      // $display("%x", cfg_data);
    end while (cfg_data[0] === 1'b0);
    $info("BIST completed.");

    $info("Read all Cfg registers.");
    reg_conf_driver.send_read(CfgSpmLow,      cfg_data, cfg_error);
    reg_conf_driver.send_read(CfgSpmHigh,     cfg_data, cfg_error);
    reg_conf_driver.send_read(CfgFlushLow,    cfg_data, cfg_error);
    reg_conf_driver.send_read(CfgFlushHigh,   cfg_data, cfg_error);
    // reg_conf_driver.send_read(CfgFlushSet0Low,    cfg_data, cfg_error);
    // reg_conf_driver.send_read(CfgFlushSet0High,   cfg_data, cfg_error);
    // reg_conf_driver.send_read(CfgFlushSet1Low,    cfg_data, cfg_error);
    // reg_conf_driver.send_read(CfgFlushSet1High,   cfg_data, cfg_error);
    // reg_conf_driver.send_read(CfgFlushSet2Low,    cfg_data, cfg_error);
    // reg_conf_driver.send_read(CfgFlushSet2High,   cfg_data, cfg_error);
    // reg_conf_driver.send_read(CfgFlushSet3Low,    cfg_data, cfg_error);
    // reg_conf_driver.send_read(CfgFlushSet3High,   cfg_data, cfg_error);
    reg_conf_driver.send_read(CommitCfg,      cfg_data, cfg_error);
    reg_conf_driver.send_read(FlushedLow,     cfg_data, cfg_error);
    reg_conf_driver.send_read(FlushedHigh,    cfg_data, cfg_error);
    reg_conf_driver.send_read(BistOutLow,     cfg_data, cfg_error);
    reg_conf_driver.send_read(BistOutHigh,    cfg_data, cfg_error);
    reg_conf_driver.send_read(BistStatus,     cfg_data, cfg_error);
    reg_conf_driver.send_read(SetAssoLow,     cfg_data, cfg_error);
    reg_conf_driver.send_read(SetAssoHigh,    cfg_data, cfg_error);
    reg_conf_driver.send_read(NumLinesLow,    cfg_data, cfg_error);
    reg_conf_driver.send_read(NumLinesHigh,   cfg_data, cfg_error);
    reg_conf_driver.send_read(NumBlocksLow,   cfg_data, cfg_error);
    reg_conf_driver.send_read(NumBlocksHigh,  cfg_data, cfg_error);
    reg_conf_driver.send_read(VersionLow,     cfg_data, cfg_error);
    reg_conf_driver.send_read(VersionHigh,    cfg_data, cfg_error);
    reg_conf_driver.send_read(FlushedSet0Low,     cfg_data, cfg_error);
    reg_conf_driver.send_read(FlushedSet0High,    cfg_data, cfg_error);
    reg_conf_driver.send_read(FlushedSet1Low,     cfg_data, cfg_error);
    reg_conf_driver.send_read(FlushedSet1High,    cfg_data, cfg_error);
    reg_conf_driver.send_read(FlushedSet2Low,     cfg_data, cfg_error);
    reg_conf_driver.send_read(FlushedSet2High,    cfg_data, cfg_error);
    reg_conf_driver.send_read(FlushedSet3Low,     cfg_data, cfg_error);
    reg_conf_driver.send_read(FlushedSet3High,    cfg_data, cfg_error);

    $info("Configure set-based cache partitioning");
    cache_partition(reg_conf_driver);

    // $info("Random read and write");
    // axi_master.run(TbNumReads, TbNumWrites);
    // flush_all(reg_conf_driver);
    // // flush_all_set(reg_conf_driver);
    // compare_mems(cpu_scoreboard, mem_scoreboard);
    // clear_spm_cpu(cpu_scoreboard);

    // Randomize patid and test 0

    $info("Run 10 random RW tests for random PatIDs");
    $info("Random read and write 0");
    axi_master.run(TbNumReads/10, TbNumWrites/10);
    flush_all_set(reg_conf_driver);
    // flush_all_set(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);

    // Randomize patid and test 1
    $info("Random read and write 1");
    axi_master.run(TbNumReads/10, TbNumWrites/10);
    // flush_all(reg_conf_driver);
    flush_all_set_2(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);

    // Randomize patid and test 2
    $info("Random read and write 2");
    axi_master.run(TbNumReads/10, TbNumWrites/10);
    flush_all(reg_conf_driver);
    // flush_all_set(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);

    // Randomize patid and test 3
    $info("Random read and write 3");
    axi_master.run(TbNumReads/10, TbNumWrites/10);
    flush_all(reg_conf_driver);
    // flush_all_set(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);

    // Randomize patid and test 4
    $info("Random read and write 4");
    axi_master.run(TbNumReads/10, TbNumWrites/10);
    //flush_all(reg_conf_driver);
    flush_all_set_2(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);

    // Randomize patid and test 5
    $info("Random read and write 5");
    axi_master.run(TbNumReads/10, TbNumWrites/10);
    // flush_all(reg_conf_driver);
    flush_all_set_2(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);

    // Randomize patid and test 6
    $info("Random read and write 6");
    axi_master.run(TbNumReads/10, TbNumWrites/10);
    // flush_all(reg_conf_driver);
    flush_all_set_2(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);

    // Randomize patid and test 7
    $info("Random read and write 7");
    axi_master.run(TbNumReads/10, TbNumWrites/10);
    // flush_all(reg_conf_driver);
    flush_all_set_2(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);

    // Randomize patid and test 8
    $info("Random read and write 8");
    axi_master.run(TbNumReads/10, TbNumWrites/10);
    // flush_all(reg_conf_driver);
    flush_all_set_2(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);

    // Randomize patid and test 9
    $info("Random read and write 9");
    axi_master.run(TbNumReads/10, TbNumWrites/10);
    // flush_all(reg_conf_driver);
    flush_all_set_2(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);


    $info("Enable lower half SPM");
    cfg_addr  = CfgSpmLow;
    cfg_data  = {((TbSetAssociativity == 32'd1) ? 32'd1 : (TbSetAssociativity/2)){1'b1}};
    cfg_wstrb = 4'hF;
    reg_conf_driver.send_write(cfg_addr, cfg_data, cfg_wstrb, cfg_error);
    cfg_addr  = CommitCfg;
    cfg_data  = 32'd1;
    cfg_wstrb = 4'hF;
    reg_conf_driver.send_write(cfg_addr, cfg_data, cfg_wstrb, cfg_error);
    axi_master.run(TbNumReads, TbNumWrites);
    // flush_all(reg_conf_driver);
    flush_all_set_2(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);

    $info("All SPM");
    cfg_addr  = CfgSpmLow;
    cfg_data  = {32{1'b1}};
    cfg_wstrb = 4'hF;
    reg_conf_driver.send_write(cfg_addr, cfg_data, cfg_wstrb, cfg_error);
    cfg_addr  = CfgSpmHigh;
    cfg_data  = {32{1'b1}};
    cfg_wstrb = 4'hF;
    reg_conf_driver.send_write(cfg_addr, cfg_data, cfg_wstrb, cfg_error);
    cfg_addr  = CommitCfg;
    cfg_data  = 32'd1;
    cfg_wstrb = 4'hF;
    reg_conf_driver.send_write(cfg_addr, cfg_data, cfg_wstrb, cfg_error);
    axi_master.run(TbNumReads, TbNumWrites);
    // flush_all(reg_conf_driver);
    flush_all_set_2(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);

    $info("Random read and write");
    cfg_addr  = CfgSpmLow;
    cfg_data  = 32'b0;
    cfg_wstrb = 4'hF;
    reg_conf_driver.send_write(cfg_addr, cfg_data, cfg_wstrb, cfg_error);
    cfg_addr  = CfgSpmHigh;
    cfg_data  = 32'b0;
    cfg_wstrb = 4'hF;
    reg_conf_driver.send_write(cfg_addr, cfg_data, cfg_wstrb, cfg_error);
    cfg_addr  = CommitCfg;
    cfg_data  = 32'd1;
    cfg_wstrb = 4'hF;
    reg_conf_driver.send_write(cfg_addr, cfg_data, cfg_wstrb, cfg_error);
    axi_master.run(TbNumReads, TbNumWrites);

    print_perf_couters();

    flush_all(reg_conf_driver);
    // flush_all_set(reg_conf_driver);
    compare_mems(cpu_scoreboard, mem_scoreboard);
    clear_spm_cpu(cpu_scoreboard);


    $display("Tests ended!");
    $finish();
  end

  initial begin : proc_sim_mem
    automatic axi_rand_slave_t axi_slave = new( axi_mem_intf_dv );
    axi_slave.reset();
    @(posedge rst_n);
    axi_slave.run();
  end

  task compare_mems(axi_scoreboard_cpu_t cpu_scoreboard, axi_scoreboard_mem_t mem_scoreboard);
    automatic byte_t     cpu_byte, mem_byte;
    automatic axi_addr_t compare_addr = CachedRegionStart;
    automatic longint unsigned correct_num = 0;
    automatic longint unsigned uncorrect_num = 0;
    while (compare_addr < (CachedRegionStart + 2*CachedRegionLength)) begin
      cpu_scoreboard.get_byte(compare_addr, cpu_byte);
      mem_scoreboard.get_byte(compare_addr, mem_byte);
      // As the whole cache line is written back there are some bytes which are only present
      // in the scoreboard of the memory and X in the CPU memory.
      if (cpu_byte !== 8'hxx) begin
        assert (cpu_byte === mem_byte) begin 
          correct_num++;
          // $display("Pass addr: %h \n Correct_count: %d, Wrong_count: %d", compare_addr, correct_num, uncorrect_num);
        end else begin
          uncorrect_num++;
          $error("At addr: %h differeing memory values are encoutered! \n CPU: %h \n MEM: %h \n Correct_count: %d, Wrong_count: %d",
              compare_addr, cpu_byte, mem_byte, correct_num, uncorrect_num);
        end
      end
      compare_addr++;
    end
    $display("Correct_count: %d, Wrong_count: %d", correct_num, uncorrect_num);
  endtask : compare_mems

  task clear_spm_cpu(axi_scoreboard_cpu_t cpu_scoreboard);
    cpu_scoreboard.clear_range(SpmRegionStart, SpmRegionStart + SpmRegionLength);
  endtask : clear_spm_cpu

  task flush_all(regbus_conf_driver_t reg_conf_driver);
    automatic logic       cfg_error;
    automatic logic[63:0] data = {TbSetAssociativity{1'b1}};
    automatic logic[31:0] rdata_low;
    automatic logic[31:0] rdata_high;
    $info("Flushing the cache!");
    reg_conf_driver.send_write(CfgFlushLow, data[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgFlushHigh, data[63:32], 4'hF, cfg_error);
    data  = 64'd1;
    reg_conf_driver.send_write(CommitCfg, data[31:0], 4'hF, cfg_error);

    // poll on the flush config until it is cleared
    while (|data) begin
      reg_conf_driver.send_read(CfgFlushLow, rdata_low, cfg_error);
      reg_conf_driver.send_read(CfgFlushHigh, rdata_high, cfg_error);
      data = {rdata_high, rdata_low};
      repeat (5000) @(posedge clk);
    end
    $info("Finished flushing the cache set!");
  endtask : flush_all

  task flush_all_set_2(regbus_conf_driver_t reg_conf_driver);
    automatic logic       cfg_error;
    automatic logic[63:0] data = TbMaxThread+1;
    automatic logic[31:0] rdata_low;
    automatic logic[31:0] rdata_high;
    $info("Flushing all the cache set!");
    reg_conf_driver.send_write(CfgFlushThreadLow, data[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgFlushThreadHigh, data[63:32], 4'hF, cfg_error);
    data  = 64'd1;
    reg_conf_driver.send_write(CommitCfg, data[31:0], 4'hF, cfg_error);

    data  = 64'd0;
    // poll on the flush config until it is cleared
    while (data!={64{1'b1}}) begin
      reg_conf_driver.send_read(CfgFlushThreadLow, rdata_low, cfg_error);
      reg_conf_driver.send_read(CfgFlushThreadHigh, rdata_high, cfg_error);
      data = {rdata_high, rdata_low};
      repeat (5000) @(posedge clk);
    end
    $info("Finished flushing all the cache set!");
  endtask : flush_all_set_2

  task flush_all_set(regbus_conf_driver_t reg_conf_driver);
    automatic logic       cfg_error;
    automatic logic[63:0] data = TbMaxThread;
    automatic logic[31:0] rdata_low;
    automatic logic[31:0] rdata_high;
    $info("Flushing the cache!");
    
    // flush section 0
    data = 202;
    reg_conf_driver.send_write(CfgFlushThreadLow, data[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgFlushThreadHigh, data[63:32], 4'hF, cfg_error);
    data  = 64'd1;
    reg_conf_driver.send_write(CommitCfg, data[31:0], 4'hF, cfg_error);

    data  = 64'd0;
    // poll on the flush config until it is cleared
    while (data!={64{1'b1}}) begin
      reg_conf_driver.send_read(CfgFlushThreadLow, rdata_low, cfg_error);
      reg_conf_driver.send_read(CfgFlushThreadHigh, rdata_high, cfg_error);
      data = {rdata_high, rdata_low};
      repeat (5000) @(posedge clk);
    end

    // // flush section 2
    // data = TbMaxThread;
    // reg_conf_driver.send_write(CfgFlushThreadLow, data[31:0], 4'hF, cfg_error);
    // reg_conf_driver.send_write(CfgFlushThreadHigh, data[63:32], 4'hF, cfg_error);
    // data  = 64'd1;
    // reg_conf_driver.send_write(CommitCfg, data[31:0], 4'hF, cfg_error);

    // data  = 64'd0;
    // // poll on the flush config until it is cleared
    // while (data!={64{1'b1}}) begin
    //   reg_conf_driver.send_read(CfgFlushThreadLow, rdata_low, cfg_error);
    //   reg_conf_driver.send_read(CfgFlushThreadHigh, rdata_high, cfg_error);
    //   data = {rdata_high, rdata_low};
    //   repeat (5000) @(posedge clk);
    // end

    $info("Finished flushing the cache set!");
  endtask : flush_all_set

//   task flush_all_set(regbus_conf_driver_t reg_conf_driver);
//     automatic logic       cfg_error;
//     automatic logic[63:0] data = {64{1'b1}};
// /********************************************     SET BASED CACHE PARTITIONING     ********************************************/
//     automatic logic[31:0] rdata0_low, rdata1_low, rdata2_low, rdata3_low, rdata4_low, rdata5_low, rdata6_low, rdata7_low;
//     automatic logic[31:0] rdata0_high, rdata1_high, rdata2_high, rdata3_high, rdata4_high, rdata5_high, rdata6_high, rdata7_high;
// /******************************************************************************************************************************/
//     automatic logic[TbNumLines-1:0] data_set = {TbNumLines{1'b1}};
//     $info("Flushing the cache set!");
// /********************************************     SET BASED CACHE PARTITIONING     ********************************************/
//     reg_conf_driver.send_write(CfgFlushSet0Low, data[31:0], 4'hF, cfg_error);
//     reg_conf_driver.send_write(CfgFlushSet0High, data[63:32], 4'hF, cfg_error);
//     reg_conf_driver.send_write(CfgFlushSet1Low, data[31:0], 4'hF, cfg_error);
//     reg_conf_driver.send_write(CfgFlushSet1High, data[63:32], 4'hF, cfg_error);
//     reg_conf_driver.send_write(CfgFlushSet2Low, data[31:0], 4'hF, cfg_error);
//     reg_conf_driver.send_write(CfgFlushSet2High, data[63:32], 4'hF, cfg_error);
//     reg_conf_driver.send_write(CfgFlushSet3Low, data[31:0], 4'hF, cfg_error);
//     reg_conf_driver.send_write(CfgFlushSet3High, data[63:32], 4'hF, cfg_error);
// /******************************************************************************************************************************/

//     data  = 64'd1;
//     reg_conf_driver.send_write(CommitCfg, data[31:0], 4'hF, cfg_error);

//     // poll on the flush config until it is cleared
//     while (|data_set) begin
// /********************************************     SET BASED CACHE PARTITIONING     ********************************************/
//       reg_conf_driver.send_read(CfgFlushSet0Low, rdata0_low, cfg_error);
//       reg_conf_driver.send_read(CfgFlushSet0High, rdata0_high, cfg_error);
//       reg_conf_driver.send_read(CfgFlushSet1Low, rdata1_low, cfg_error);
//       reg_conf_driver.send_read(CfgFlushSet1High, rdata1_high, cfg_error);
//       reg_conf_driver.send_read(CfgFlushSet2Low, rdata2_low, cfg_error);
//       reg_conf_driver.send_read(CfgFlushSet2High, rdata2_high, cfg_error);
//       reg_conf_driver.send_read(CfgFlushSet3Low, rdata3_low, cfg_error);
//       reg_conf_driver.send_read(CfgFlushSet3High, rdata3_high, cfg_error);
//       data_set = {rdata3_high, rdata3_low, rdata2_high, rdata2_low, rdata1_high, rdata1_low, rdata0_high, rdata0_low};
// /******************************************************************************************************************************/
//       repeat (5000) @(posedge clk);
//     end
//     $info("Finished flushing the cache set!");
//   endtask : flush_all_set

  task cache_partition(regbus_conf_driver_t reg_conf_driver);
    automatic logic       cfg_error;
    automatic logic[61:0] data0 = {62{1'b0}};
    automatic logic[1:0]  data1 = {2{1'b1}};
    automatic logic[63:0] data = {data0,data1};
    automatic logic[63:0] zeros = 64'b0;
    // automatic logic[31:0] rdata0_low, rdata1_low, rdata2_low, rdata3_low;
    // automatic logic[31:0] rdata0_high, rdata1_high, rdata2_high, rdata3_high;
    // automatic logic[255:0] data_set = {256{1'b1}};
    $info("Configuring set-based cache partitioning!");
    reg_conf_driver.send_write(CfgSetPartition0Low, data[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition0High, data[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition1Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition1High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition2Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition2High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition3Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition3High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition4Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition4High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition5Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition5High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition6Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition6High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition7Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition7High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition8Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition8High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition9Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition9High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition10Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition10High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition11Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition11High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition12Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition12High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition13Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition13High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition14Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition14High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition15Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition15High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition16Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition16High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition17Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition17High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition18Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition18High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition19Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition19High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition20Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition20High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition21Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition21High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition22Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition22High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition23Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition23High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition24Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition24High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition25Low, 32'b00000010_00001010_00000011_00000010, 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition25High, 32'b00000010_00001010_00000011_00000010, 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition26Low, 32'b00000010_00001010_00000011_00000010, 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition26High, 32'b00000010_00001010_00000011_00000010, 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition27Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition27High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition28Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition28High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition29Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition29High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition30Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition30High, zeros[63:32], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition31Low, zeros[31:0], 4'hF, cfg_error);
    reg_conf_driver.send_write(CfgSetPartition31High, zeros[63:32], 4'hF, cfg_error);
    data  = 64'd1;
    reg_conf_driver.send_write(CommitPartitionCfg, data[31:0], 4'hF, cfg_error);
    $info("Finished partition configuration!");
  endtask : cache_partition

  task print_perf_couters();
    @(negedge clk);
    print_counters = 1'b1;
    @(negedge clk);
    print_counters = 1'b0;
  endtask : print_perf_couters


  ///////////////////////
  // Design under test //
  ///////////////////////
  axi_llc_reg_wrap #(
    .SetAssociativity ( TbSetAssociativity ),
    .NumLines         ( TbNumLines         ),
    .NumBlocks        ( TbNumBlocks        ),
    .MaxThread        ( TbMaxThread        ),
    .AxiIdWidth       ( TbAxiIdWidthFull   ),
    .AxiAddrWidth     ( TbAxiAddrWidthFull ),
    .AxiDataWidth     ( TbAxiDataWidthFull ),
    .AxiUserWidth     ( TbAxiUserWidthFull ),
    .slv_req_t        ( axi_slv_req_t      ),
    .slv_resp_t       ( axi_slv_resp_t     ),
    .mst_req_t        ( axi_mst_req_t      ),
    .mst_resp_t       ( axi_mst_resp_t     ),
    .reg_req_t        ( conf_req_t         ),
    .reg_resp_t       ( conf_rsp_t         ),
    .rule_full_t      ( rule_full_t        )
  ) i_axi_llc_dut (
    .clk_i               ( clk                                    ),
    .rst_ni              ( rst_n                                  ),
    .test_i              ( test                                   ),
    .slv_req_i           ( axi_cpu_req                            ),
    .slv_resp_o          ( axi_cpu_res                            ),
    .mst_req_o           ( axi_mem_req                            ),
    .mst_resp_i          ( axi_mem_res                            ),
    .conf_req_i          ( reg_cfg_req                            ),
    .conf_resp_o         ( reg_cfg_rsp                            ),
    .cached_start_addr_i ( CachedRegionStart                      ),
    .cached_end_addr_i   ( CachedRegionStart + CachedRegionLength ),
    .spm_start_addr_i    ( SpmRegionStart                         ),
    .axi_llc_events_o    ( llc_events                             )
  );

  ////////////////////////////
  // `Perf Counter` process //
  ////////////////////////////
  localparam int unsigned NumCounters = 32'd52;
  localparam int unsigned PrintCycles = 32'd100;
  initial begin : proc_counters
    automatic longint unsigned count [0:NumCounters-1];
    automatic longint unsigned cycle_count = 0;
    for (int unsigned i = 0; i < NumCounters; i++) begin
      count[i] = 0;
    end

    @(posedge rst_n);
    forever begin
      // Wait for the test time
      @(posedge clk);
      #(TbTestTime);
      cycle_count++;

      if (enable_counters) begin
        if (llc_events.aw_slv_transfer.active) begin
          count[0] = count[0] + llc_events.aw_slv_transfer.num_bytes;
          count[1] = count[1] + 64'd1;
          if ((count[1]%PrintCycles == 0) && enable_progress) begin
            $display("%0t> AW transaction: %d", $time(), count[1]);
          end
        end
        if (llc_events.ar_slv_transfer.active) begin
          count[2] = count[2] + llc_events.ar_slv_transfer.num_bytes;
          count[3] = count[3] + 64'd1;
          if ((count[3]%PrintCycles == 0) && enable_progress) begin
            $display("%0t> AR transaction: %d", $time(), count[3]);
          end
        end
        if (llc_events.aw_bypass_transfer.active) begin
          count[4] = count[4] + llc_events.aw_bypass_transfer.num_bytes;
          count[5] = count[5] + 64'd1;
        end
        if (llc_events.ar_bypass_transfer.active) begin
          count[6] = count[6] + llc_events.ar_bypass_transfer.num_bytes;
          count[7] = count[7] + 64'd1;
        end
        if (llc_events.aw_mst_transfer.active) begin
          count[8] = count[8] + llc_events.aw_mst_transfer.num_bytes;
          count[9] = count[9] + 64'd1;
        end
        if (llc_events.ar_mst_transfer.active) begin
          count[10] = count[10] + llc_events.ar_mst_transfer.num_bytes;
          count[11] = count[11] + 64'd1;
        end
        if (llc_events.aw_desc_spm.active) begin
          count[12] = count[12] + llc_events.aw_desc_spm.num_bytes;
          count[13] = count[13] + 64'd1;
        end
        if (llc_events.ar_desc_spm.active) begin
          count[14] = count[14] + llc_events.ar_desc_spm.num_bytes;
          count[15] = count[15] + 64'd1;
        end
        if (llc_events.aw_desc_cache.active) begin
          count[16] = count[16] + llc_events.aw_desc_cache.num_bytes;
          count[17] = count[17] + 64'd1;
        end
        if (llc_events.ar_desc_cache.active) begin
          count[18] = count[18] + llc_events.ar_desc_cache.num_bytes;
          count[19] = count[19] + 64'd1;
        end
        if (llc_events.config_desc.active) begin
          count[20] = count[20] + llc_events.config_desc.num_bytes;
          count[21] = count[21] + 64'd1;
        end
        if (llc_events.hit_write_spm.active) begin
          count[22] = count[22] + llc_events.hit_write_spm.num_bytes;
          count[23] = count[23] + 64'd1;
        end
        if (llc_events.hit_read_spm.active) begin
          count[24] = count[24] + llc_events.hit_read_spm.num_bytes;
          count[25] = count[25] + 64'd1;
        end
        if (llc_events.miss_write_spm.active) begin
          count[26] = count[26] + llc_events.miss_write_spm.num_bytes;
          count[27] = count[27] + 64'd1;
        end
        if (llc_events.miss_read_spm.active) begin
          count[28] = count[28] + llc_events.miss_read_spm.num_bytes;
          count[29] = count[29] + 64'd1;
        end
        if (llc_events.hit_write_cache.active) begin
          count[30] = count[30] + llc_events.hit_write_cache.num_bytes;
          count[31] = count[31] + 64'd1;
        end
        if (llc_events.hit_read_cache.active) begin
          count[32] = count[32] + llc_events.hit_read_cache.num_bytes;
          count[33] = count[33] + 64'd1;
        end
        if (llc_events.miss_write_cache.active) begin
          count[34] = count[34] + llc_events.miss_write_cache.num_bytes;
          count[35] = count[35] + 64'd1;
        end
        if (llc_events.miss_read_cache.active) begin
          count[36] = count[36] + llc_events.miss_read_cache.num_bytes;
          count[37] = count[37] + 64'd1;
        end
        if (llc_events.refill_write.active) begin
          count[38] = count[38] + llc_events.refill_write.num_bytes;
          count[39] = count[39] + 64'd1;
        end
        if (llc_events.refill_read.active) begin
          count[40] = count[40] + llc_events.refill_read.num_bytes;
          count[41] = count[41] + 64'd1;
        end
        if (llc_events.evict_write.active) begin
          count[42] = count[42] + llc_events.evict_write.num_bytes;
          count[43] = count[43] + 64'd1;
        end
        if (llc_events.evict_read.active) begin
          count[44] = count[44] + llc_events.evict_read.num_bytes;
          count[45] = count[45] + 64'd1;
        end
        if (llc_events.evict_flush.active) begin
          count[46] = count[46] + llc_events.evict_flush.num_bytes;
          count[47] = count[47] + 64'd1;
        end
        if (llc_events.evict_unit_req) begin
          count[48] = count[48] + 64'd1;
        end
        if (llc_events.refill_unit_req) begin
          count[49] = count[49] + 64'd1;
        end
        if (llc_events.w_chan_unit_req) begin
          count[50] = count[50] + 64'd1;
        end
        if (llc_events.r_chan_unit_req) begin
          count[51] = count[51] + 64'd1;
        end
      end

      if (print_counters) begin
        $display("##################################################################");
        $display("LLC: Performance");
        $display("Max Bandwidth of one AXI channel: %f MiB/sec", (real'(TbAxiDataWidthFull)
            / real'(8)) * (real'(1000000000) /  real'(TbCyclTime)) / 1024 / 1024);
        $display("##################################################################");
        $display("Bandwidths:");
        $display("aw_slv_transfer:    %f MiB/sec", real'(count[0] ) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("ar_slv_transfer:    %f MiB/sec", real'(count[2] ) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("aw_bypass_transfer: %f MiB/sec", real'(count[4] ) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("ar_bypass_transfer: %f MiB/sec", real'(count[6] ) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("aw_mst_transfer:    %f MiB/sec", real'(count[8] ) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("ar_mst_transfer:    %f MiB/sec", real'(count[10]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("aw_desc_spm:        %f MiB/sec", real'(count[12]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("ar_desc_spm:        %f MiB/sec", real'(count[14]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("aw_desc_cache:      %f MiB/sec", real'(count[16]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("ar_desc_cache:      %f MiB/sec", real'(count[18]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("config_desc:        %f MiB/sec", real'(count[20]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("hit_write_spm:      %f MiB/sec", real'(count[22]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("hit_read_spm:       %f MiB/sec", real'(count[24]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("miss_write_spm:     %f MiB/sec", real'(count[26]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("miss_read_spm:      %f MiB/sec", real'(count[28]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("hit_write_cache:    %f MiB/sec", real'(count[30]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("hit_read_cache:     %f MiB/sec", real'(count[32]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("miss_write_cache:   %f MiB/sec", real'(count[34]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("miss_read_cache:    %f MiB/sec", real'(count[36]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("refill_write:       %f MiB/sec", real'(count[38]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("refill_read:        %f MiB/sec", real'(count[40]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("evict_write:        %f MiB/sec", real'(count[42]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("evict_read:         %f MiB/sec", real'(count[44]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("evict_flush:        %f MiB/sec", real'(count[46]) / real'(cycle_count)
            / real'(TbCyclTime) * real'(1000000000) / 1024 / 1024);
        $display("##################################################################");
        $display("Utilization:");
        $display("aw_slv_transfer:    %f", real'(count[1] ) / real'(cycle_count));
        $display("ar_slv_transfer:    %f", real'(count[3] ) / real'(cycle_count));
        $display("aw_bypass_transfer: %f", real'(count[5] ) / real'(cycle_count));
        $display("ar_bypass_transfer: %f", real'(count[7] ) / real'(cycle_count));
        $display("aw_mst_transfer:    %f", real'(count[9] ) / real'(cycle_count));
        $display("ar_mst_transfer:    %f", real'(count[11]) / real'(cycle_count));
        $display("aw_desc_spm:        %f", real'(count[13]) / real'(cycle_count));
        $display("ar_desc_spm:        %f", real'(count[15]) / real'(cycle_count));
        $display("aw_desc_cache:      %f", real'(count[17]) / real'(cycle_count));
        $display("ar_desc_cache:      %f", real'(count[19]) / real'(cycle_count));
        $display("config_desc:        %f", real'(count[21]) / real'(cycle_count));
        $display("hit_write_spm:      %f", real'(count[23]) / real'(cycle_count));
        $display("hit_read_spm:       %f", real'(count[25]) / real'(cycle_count));
        $display("miss_write_spm:     %f", real'(count[27]) / real'(cycle_count));
        $display("miss_read_spm:      %f", real'(count[29]) / real'(cycle_count));
        $display("hit_write_cache:    %f", real'(count[31]) / real'(cycle_count));
        $display("hit_read_cache:     %f", real'(count[33]) / real'(cycle_count));
        $display("miss_write_cache:   %f", real'(count[35]) / real'(cycle_count));
        $display("miss_read_cache:    %f", real'(count[37]) / real'(cycle_count));
        $display("refill_write:       %f", real'(count[39]) / real'(cycle_count));
        $display("refill_read:        %f", real'(count[41]) / real'(cycle_count));
        $display("evict_write:        %f", real'(count[43]) / real'(cycle_count));
        $display("evict_read:         %f", real'(count[45]) / real'(cycle_count));
        $display("evict_flush:        %f", real'(count[47]) / real'(cycle_count));
        $display("evict_unit_req:     %f", real'(count[48]) / real'(cycle_count));
        $display("refill_unit_req:    %f", real'(count[49]) / real'(cycle_count));
        $display("w_chan_unit_req:    %f", real'(count[50]) / real'(cycle_count));
        $display("r_chan_unit_req:    %f", real'(count[51]) / real'(cycle_count));
        $display("##################################################################");
        // After printing, reset the counters.
        cycle_count = 0;
        for (int unsigned i = 0; i < NumCounters; i++) begin
          count[i] = 0;
        end
      end // print counters
    end // forever begin
  end : proc_counters
endmodule