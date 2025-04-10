// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Hong Pang <hongpang@ethz.ch>
// - Diyou Shen <dishen@ethz.ch>
// Date:   30.03.2023

module axi_llc_sram_tag #(
  parameter int unsigned NumWords     = 32'd1024, // Number of Words in data array
  parameter int unsigned DataWidth    = 32'd128,  // Data signal width
  parameter int unsigned ByteWidth    = 32'd8,    // Width of a data byte
  parameter int unsigned NumPorts     = 32'd2,    // Number of read and write ports
  parameter int unsigned Latency      = 32'd1,    // Latency when the read data is available
  parameter              SimInit      = "none",   // Simulation initialization
  parameter bit          PrintSimCfg  = 1'b0,     // Print configuration
  // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
  parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
  parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth, // ceil_div
  parameter type         addr_t    = logic [AddrWidth-1:0],
  parameter type         data_t    = logic [DataWidth-1:0],
  parameter type         be_t      = logic [BeWidth-1:0],
  parameter type         impl_in_t = logic
) (
  input  logic                 clk_i,      // Clock
  input  logic                 rst_ni,     // Asynchronous reset active low
  input  impl_in_t             impl_i,
  // input ports
  input  logic  [NumPorts-1:0] req_i,      // request
  input  logic  [NumPorts-1:0] we_i,       // write enable
  input  addr_t [NumPorts-1:0] addr_i,     // request address
  input  data_t [NumPorts-1:0] wdata_i,    // write data
  input  be_t   [NumPorts-1:0] be_i,       // write byte enable
  // output ports
  output data_t [NumPorts-1:0] rdata_o     // read data
);
  
  logic [DataWidth-1:0] wen;
  assign wen = (we_i) ? '0 : '1;

  tc_sram_impl #(
      .NumWords   ( NumWords    ),
      .DataWidth  ( DataWidth   ),
      .ByteWidth  ( ByteWidth   ),
      .NumPorts   ( NumPorts    ),
      .Latency    ( Latency     ),
      .SimInit    ( SimInit     ),
      .PrintSimCfg( PrintSimCfg ),
      .impl_in_t  ( impl_in_t   )
    ) i_tag_sram (
      .clk_i   ( clk_i   ),
      .rst_ni  ( rst_ni  ),
      .impl_i  ( impl_i  ),
      .impl_o  (         ), // unconnected
      .req_i   ( req_i   ),
      .we_i    ( we_i    ),
      .addr_i  ( addr_i  ),
      .wdata_i ( wdata_i ),
      .be_i    ( be_i    ),
      .rdata_o ( rdata_o )
    );

endmodule
