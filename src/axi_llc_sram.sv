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
  parameter int unsigned NumOutputCuts    = 32'd0, // Number of cuts in the data output path
  parameter bit          EnableEcc    = 0,        // Tag & data sram ECC enabling parameter, bool type
  parameter int unsigned ECC_GRANULARITY = 0,     // Per ECC unit width
  parameter              SimInit      = "none",   // Simulation initialization
  parameter bit          PrintSimCfg  = 1'b0,     // Print configuration
  // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
  parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
  parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth, // ceil_div
  parameter type         addr_t    = logic [AddrWidth-1:0],
  parameter type         data_t    = logic [DataWidth-1:0],
  parameter type         be_t      = logic [BeWidth-1:0],

  parameter int unsigned G = (ECC_GRANULARITY == 0) ? DataWidth : ECC_GRANULARITY,
  parameter int unsigned NumBanks = DataWidth/G,
  parameter int unsigned K = $clog2(G) + 2,
  parameter int unsigned EccDataWidth = G + K,
  parameter int unsigned BeWidthPerBank = (BeWidth+NumBanks-1)/NumBanks,
  parameter int unsigned NumBankPerInBeBit = (NumBanks/BeWidth == 0) ? 1 : NumBanks/BeWidth,
  parameter int unsigned ByteWidthPerBank  = (ByteWidth > G) ? G : ByteWidth
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
  output data_t                rdata_o,    // read data

  // ecc signals
  input  logic [NumBanks-1:0]  scrub_trigger_i,
  output logic [NumBanks-1:0]  scrubber_fix_o,
  output logic [NumBanks-1:0]  scrub_uncorrectable_o,
  output logic [NumBanks-1:0]  single_error_o,
  output logic [NumBanks-1:0]  multi_error_o
);
  

  if (EnableEcc) begin: gen_ecc_sram

    logic [NumBanks-1:0][G-1:0] wdata, rdata;
    logic [NumBanks-1:0][BeWidthPerBank-1:0] be;
    logic [NumBanks-1:0] gnt;
    logic                gnt_all;

    logic hsk_d, hsk_q;
    logic we_q;
    data_t rdata_d, rdata_q;
    logic  rdata_en;

    assign hsk_d   = req_i & gnt_all;
    assign gnt_all = &gnt;
    assign gnt_o   = gnt_all;

    shift_reg #(
      .dtype(logic),
      .Depth(NumOutputCuts+1)
    ) i_hsk_q (
      .clk_i,
      .rst_ni,
      .d_i   (hsk_d),
      .d_o   (hsk_q)
    );

    shift_reg #(
      .dtype(logic),
      .Depth(NumOutputCuts+1)
    ) i_we_q (
      .clk_i,
      .rst_ni,
      .d_i   (we_i),
      .d_o   (we_q)
    );

    shift_reg_gated #(
      .dtype(data_t),
      .Depth(NumOutputCuts+1)
    ) i_rdata_q (
      .clk_i,
      .rst_ni,
      .valid_i(rdata_en),
      .data_i (rdata_d),
      .valid_o(),
      .data_o (rdata_q)
    );



    for (genvar i = 0; i < NumBanks; i++) begin: gen_data_split
      assign wdata[i] = wdata_i[G*i+:G];
      assign rdata_o[G*i+:G] = (hsk_q & ~we_q) ? rdata[i] : rdata_q[G*i+:G];
      assign be[i] = be_i[BeWidthPerBank*(i/NumBankPerInBeBit)+:BeWidthPerBank];

      ecc_sram #(
        .NumWords         ( NumWords       ),
        .UnprotectedWidth ( G              ),
        .ProtectedWidth   ( EccDataWidth   ),
        .InputECC         ( 0              ),
        .NumRMWCuts       ( 1              ),
        .NumOutputCuts    ( NumOutputCuts  ),
        .SimInit          ( "zeros"        )
      ) i_ecc_sram (
        .clk_i,
        .rst_ni,

        .scrub_trigger_i      ( scrub_trigger_i       [i]),
        .scrubber_fix_o       ( scrubber_fix_o        [i]),
        .scrub_uncorrectable_o( scrub_uncorrectable_o [i]),

        .wdata_i              ( wdata[i]),
        .addr_i               ( addr_i  ),
        .req_i                ( req_i   ),
        .we_i                 ( we_i    ),
        .be_i                 ( {(ByteWidthPerBank/8){be[i]}}   ),
        .rdata_o              ( rdata[i]),
        .gnt_o                ( gnt[i]  ),

        .single_error_o       ( single_error_o [i] ),
        .multi_error_o        ( multi_error_o  [i] )
      );
    end

    // always_ff @(posedge clk_i or negedge rst_ni) begin
    //   if(~rst_ni) begin
    //     hsk_q <= 1'b0;
    //     we_q  <= 1'b0;
    //     rdata_q <= '0;
    //   end else begin
    //     hsk_q <= hsk_d;
    //     we_q  <= we_i;
    //     if (rdata_en) begin
    //       rdata_q <= rdata_d;
    //     end
    //   end
    // end

    assign rdata_en = hsk_q & ~we_q;
    assign rdata_d  = rdata_o;
  
  // end else begin: gen_standard_sram
  //   assign gnt_o = 1'b1;
    data_t                rdata_cmp, rdata_cmp_q;
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
        // .rdata_o ( rdata_o )
        .rdata_o ( rdata_cmp )
      );

    shift_reg #(
      .dtype(data_t),
      .Depth(NumOutputCuts)
    ) i_rdata_cmp_q (
      .clk_i,
      .rst_ni,
      .d_i   (rdata_cmp),
      .d_o   (rdata_cmp_q)
    );


  // Assertions
  // pragma translate_off
  `ifndef VERILATOR
  // data_cmp:  assert property ( @(posedge clk_i) disable iff (!rst_ni)
  //     (hsk_d & ~we_i) |=> (rdata_o == rdata_cmp_q)) else
  //     $info(1, "[data_cmp] data mismatch");
  data_cmp:  assert property ( @(posedge clk_i) disable iff (!rst_ni)
      (hsk_d & ~we_i) ##(NumOutputCuts+1) 1 |-> (rdata_o == rdata_cmp_q)) else
      $info(1, "[data_cmp] data mismatch");
  `endif
  // pragma translate_on
  end
  
endmodule