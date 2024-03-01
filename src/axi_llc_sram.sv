// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Hong Pang <hongpang@ethz.ch>
// - Diyou Shen <dishen@ethz.ch>
// Date:   30.03.2023

module axi_llc_sram #(
  parameter int unsigned NumWords     = 32'd1024, // Number of Words in data array
  parameter int unsigned DataWidth    = 32'd128,  // Data signal width
  parameter int unsigned ByteWidth    = 32'd8,    // Width of a data byte
  // parameter int unsigned NumPorts     = 32'd2,    // Number of read and write ports
  parameter int unsigned Latency      = 32'd1,    // Latency when the read data is available
  parameter bit          EnableEcc    = 0,        // Tag & data sram ECC enabling parameter, bool type
  parameter int unsigned ECC_GRANULARITY = 0,     // Per ECC unit width
  parameter              SimInit      = "none",   // Simulation initialization
  parameter bit          PrintSimCfg  = 1'b0,     // Print configuration
  // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
  parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
  parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth, // ceil_div
  parameter type         addr_t    = logic [AddrWidth-1:0],
  parameter type         data_t    = logic [DataWidth-1:0],
  parameter type         be_t      = logic [BeWidth-1:0]
) (
  input  logic                 clk_i,      // Clock
  input  logic                 rst_ni,     // Asynchronous reset active low
  // input ports
  input  logic                 req_i,      // request
  input  logic                 we_i,       // write enable
  input  addr_t                addr_i,     // request address
  input  data_t                wdata_i,    // write data
  input  be_t                  be_i,       // write byte enable
  // output ports
  output logic                 gnt_o,      // sram ready
  output data_t                rdata_o     // read data
);
  
  logic [DataWidth-1:0] wen;
  assign wen = (we_i) ? '0 : '1;
  
  data_t                rdata_cmp;

  // if (EnableEcc) begin: gen_ecc_sram

    localparam int unsigned G = (ECC_GRANULARITY == 0) ? DataWidth : ECC_GRANULARITY;
    localparam int unsigned NumBanks = DataWidth/G;
    localparam int unsigned K = $clog2(G) + 2;
    localparam int unsigned EccDataWidth = G + K;
    localparam int unsigned BeWidthPerBank = (BeWidth+NumBanks-1)/NumBanks;

    logic [NumBanks-1:0][G-1:0] wdata, rdata;
    logic [NumBanks-1:0][BeWidthPerBank-1:0] be;
    logic [NumBanks-1:0] gnt;

    logic req_q;
    logic we_q;
    data_t rdata_d, rdata_q;
    logic  rdata_en;

    // LFSR
    logic [16-1:0] rand_value;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if(~rst_ni) begin
        rand_value <= 16'b1010110011100001;
      end else begin
        rand_value <= {rand_value[13]^rand_value[15]^rand_value[12]^rand_value[10], rand_value[15:1]};
      end
    end

    assign gnt_o = &gnt;
    for (genvar i = 0; i < NumBanks; i++) begin: gen_data_split
      assign wdata[i] = wdata_i[G*i+:G];
      assign rdata_o[G*i+:G] = (req_q & ~we_q) ? rdata[i] : rdata_q[G*i+:G];
      // assign rdata_cmp[G*i+:G] = (req_q & ~we_q) ? rdata[i] : '0;
      assign be[i] = be_i[BeWidthPerBank*i+:BeWidthPerBank];

      ecc_sram_wrap #(
        .BankSize         ( NumWords       ),
        .InputECC         ( 0              ),
        .EnableTestMask   ( 0              ),
        .NumRMWCuts       ( 1              ),
        .UnprotectedWidth ( G              ),
        .ProtectedWidth   ( EccDataWidth   )
      ) i_ecc_sram (
        .clk_i,
        .rst_ni,
        .test_enable_i        ( '0  ),

        .scrub_trigger_i      ( '1  ),
        .scrubber_fix_o       (),
        .scrub_uncorrectable_o(),

        .tcdm_wdata_i ( wdata[i]),
        .tcdm_add_i   ( {{(32-AddrWidth-2){1'b0}}, addr_i, 2'b0}  ),
        .tcdm_req_i   ( req_i   ),
        .tcdm_wen_i   ( ~we_i   ),
        .tcdm_be_i    ( {(ByteWidth/8){be[i]}}   ),
        .tcdm_rdata_o ( rdata[i]),
        .tcdm_gnt_o   ( gnt[i]  ),

        .single_error_o       (),
        .multi_error_o        (),

        .test_write_mask_ni ('0)
      );
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if(~rst_ni) begin
        req_q <= 1'b0;
        we_q  <= 1'b0;
      end else begin
        req_q <= req_i;
        we_q  <= we_i;
      end
    end

    assign rdata_en = req_q & ~we_q;
    assign rdata_d  = rdata_o;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if(~rst_ni) begin
        rdata_q <= '0;
      end else if (rdata_en) begin
        rdata_q <= rdata_d;
      end
    end
  
  // end else begin: gen_standard_sram
  //   assign gnt_o = 1'b1;
    tc_sram #(
        .NumWords   ( NumWords    ),
        .DataWidth  ( DataWidth   ),
        .ByteWidth  ( ByteWidth   ),
        .NumPorts   ( 32'd1       ),
        .Latency    ( Latency     ),
        .SimInit    ( SimInit     ),
        .PrintSimCfg( PrintSimCfg )
      ) i_sram (
        .clk_i   ( clk_i   ),
        .rst_ni  ( rst_ni  ),
        .req_i   ( req_i   ),
        .we_i    ( we_i    ),
        .addr_i  ( addr_i  ),
        .wdata_i ( wdata_i ),
        .be_i    ( be_i    ),
        .rdata_o ( rdata_cmp )
      );
  // end
  
  // Assertions
  // pragma translate_off
  `ifndef VERILATOR
  data_cmp:  assert property ( @(posedge clk_i) disable iff (!rst_ni)
      (req_i & ~we_i) |=> (rdata_o == rdata_cmp)) else
      $fatal(1, "[data_cmp] data mismatch");
  `endif
  // pragma translate_on
endmodule