// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Wolfgang Roenninger <wroennin@iis.ee.ethz.ch>
// Date:   06.06.2019

/// This is the Tag storage for the LLC
/// There are four types of requests which can be made onto this unit.
/// `axi_llc_pkg::Bist`:
///   The pattern gets written or read to all macros, BIST resulte gets activated
/// `axi_llc_pkg::Flush`:
///   Perform a way trageted eviction, the tag is written in with all zero.
/// `axi_llc_pkg::Lookup`:
///   Perform a tag lookup in all non SPM ways, hit/eviction gets set if needed.
///   Writes the tag into the macro if needed.
`include "common_cells/registers.svh"
module axi_llc_tag_store #(
  /// Static LLC configuration struct
  parameter axi_llc_pkg::llc_cfg_t Cfg = axi_llc_pkg::llc_cfg_t'{default: '0},
  /// Tag & data sram ECC enabling parameter, bool type
  parameter bit  EnableEcc = 0,
  /// The number of SRAM banks per way
  parameter int SramBankNumPerWay = (Cfg.TagEccGranularity != 0) ? (1'b1 << ($clog2(Cfg.TagLength + 32'd2)))/Cfg.TagEccGranularity : 1,
  /// Way indicator type
  /// EG: typedef logic [Cfg.SetAssociativity-1:0] way_ind_t;
  parameter type way_ind_t = logic,
  // parameter type set_ind_t = logic,
  /// Type of the request payload made to the tag storage
  parameter type store_req_t = logic,
  /// Type of the response payload expected from the tag storage
  parameter type store_res_t = logic,
  /// Whether to print SRAM configs
  parameter bit  PrintSramCfg = 0,
  
  // typedef to have consistent tag data (that what gets written into the sram)
  parameter int unsigned TagDataLen = Cfg.TagLength + 32'd2,
  // Binary indicator of the output way selected.
  parameter int unsigned SRAMDataWidth = 1'b1 << ($clog2(TagDataLen))
) (
  /// Clock, positive edge triggered
  input  logic       clk_i,
  /// Asynchronous reset, active low
  input  logic       rst_ni,
  /// Testmode enable
  input  logic       test_i,
  /// SPM lock signal input.
  ///
  /// For each way there is one signal. When high the way is configured as SPM. They are disabled
  /// for store requests.
  input  way_ind_t   spm_lock_i,
  /// Flushed indicator from `axi_llc_config`.
  ///
  /// This indicates that a way is flushed. No LOOKUP operations are performed on flushed ways.
  input  way_ind_t   flushed_i,
  // input  set_ind_t   flushed_set_i,
  /// Tag storage request payload.
  input  store_req_t req_i,
  /// Request to the tag storage is valid.
  input  logic       valid_i,
  /// Tag storage is ready for an request.
  output logic       ready_o,
  /// Tag storage response payload
  output store_res_t res_o,
  /// Tag stoarage response is valid.
  output logic       valid_o,
  /// Hit miss unit is ready to accept response.
  input  logic       ready_i,
  /// BIST result output. If one of these bits is high, when `bist_valid_o` is `1`. The
  /// corresponding tag storage SRAM macro failed the test.
  output way_ind_t   bist_res_o,
  /// BIST output is valid.
  output logic       bist_valid_o,

  // if the sram are put outside
  output logic [Cfg.SetAssociativity-1:0]                        ram_req_o,
  output way_ind_t                                               ram_we_o,
  output logic [Cfg.SetAssociativity-1:0][Cfg.IndexLength-1:0]   ram_addr_o,
  output logic [Cfg.SetAssociativity-1:0][SRAMDataWidth-1:0]     ram_wdata_o,
  output way_ind_t                                               ram_be_o,
  input  logic [Cfg.SetAssociativity-1:0]                        ram_gnt_i,
  input  logic [Cfg.SetAssociativity-1:0][SRAMDataWidth-1:0]     ram_data_i,
  input  logic [Cfg.SetAssociativity-1:0]                        ram_data_multi_err_i,

  // ecc signals
  input  logic [Cfg.SetAssociativity-1:0][SramBankNumPerWay-1:0] scrub_trigger_i,
  output logic [Cfg.SetAssociativity-1:0][SramBankNumPerWay-1:0] scrubber_fix_o,
  output logic [Cfg.SetAssociativity-1:0][SramBankNumPerWay-1:0] scrub_uncorrectable_o,
  output logic [Cfg.SetAssociativity-1:0][SramBankNumPerWay-1:0] single_error_o,
  output logic [Cfg.SetAssociativity-1:0][SramBankNumPerWay-1:0] multi_error_o
);

  // typedef, because we use in this module many signals with the width of SetAssiciativity
  typedef logic [Cfg.IndexLength-1:0] index_t; // index type (equals the address for sram)
  typedef logic [Cfg.TagLength-1:0]   tag_t;


  /// Packed struct for the data stored in the memory macros.
  typedef struct packed {
    /// The tag stored is valid.
    logic val;
    /// The tag stored is dirty.
    logic dit;
    /// The stored tag itself.
    tag_t tag;
  } tag_data_t;

  // Binary indicator of the output way selected.
  localparam int unsigned BinIndicatorWidth = cf_math_pkg::idx_width(Cfg.SetAssociativity);
  localparam int unsigned SRAMExtendedWidth = SRAMDataWidth - TagDataLen;
  
  typedef logic [BinIndicatorWidth-1:0] bin_ind_t;

  // The module can be busy or not.
  logic       busy_q,      busy_d,       switch_busy;

  // Save the request in state
  store_req_t req_q;
  logic       load_req;
  logic       shift_req;
  logic       req_q_valid;
  logic       req_q_waiting_valid;

  // Save the last req_q state, and the victim way
  // For two continuous access to the same tag index, 
  // if the previous one update the tag ram, we can forward the new tag to the following one
  typedef struct packed {
    store_req_t req_q;
    logic       evict_valid;
    bin_ind_t   evict_way;
  } store_req_q_t;
  store_req_q_t req_q_q, req_q_d;

  // Macro signals
  // Request for the macros
  way_ind_t   ram_req;
  // Ready from the macros
  way_ind_t   ram_gnt;
  // Handshake between macro and state machine
  logic       ram_hsk;
  // Write enable for the macros, active high. (Also functions as byte enable as there is one byte).
  way_ind_t   ram_we;
  // Index is the address.
  index_t     ram_index;
  // Read data from the macros
  logic [Cfg.SetAssociativity-1:0][SRAMDataWidth-1:0] sram_rdata;
  tag_data_t [Cfg.SetAssociativity-1:0]               ram_rdata;
  tag_data_t [Cfg.SetAssociativity-1:0]               ram_rdata_q; // need to buffer the tag data, as the evict box has multiple-cycle latency, and the second tag ram read req refreshed the tag sram output
  logic      [Cfg.SetAssociativity-1:0]               ram_rdata_en;
  logic      [Cfg.SetAssociativity-1:0]               ram_rdata_q_valid, ram_rdata_q_valid_nxt;
  logic      [Cfg.SetAssociativity-1:0]               ram_rdata_q_valid_en;
  logic      [Cfg.SetAssociativity-1:0]               ram_rdata_q_valid_set, ram_rdata_q_valid_clr;
  tag_data_t [Cfg.SetAssociativity-1:0]               ram_rdata_sel;
  // Write data for the macros.
  tag_data_t  ram_wdata;
  // Read data is valid
  way_ind_t   ram_rvalid; // ram_rvalid_q;
  logic ram_rvalid_q;
  logic [$clog2(axi_llc_pkg::TagMacroLatency):0] ram_rvalid_cnt;
  logic       ram_rvalid_cnt_overflow;
  logic       ram_rvalid_cnt_en, ram_rvalid_cnt_down;
  // logic       lock_rvalid;
  // Hit indication signals
  way_ind_t   hit, tag_val, tag_dit,     tag_equ;
  tag_data_t  [Cfg.SetAssociativity-1:0] stored_tag;
  // Binary representation of the selected output indicator
  bin_ind_t   bin_ind;
  // The pattern generation unit signals
  logic       gen_valid,   gen_ready;
  index_t     gen_index;
  tag_data_t  gen_pattern, bist_pattern;
  logic       gen_req,     gen_we;
  way_ind_t   bist_res;
  logic       bist_valid,  gen_eoc;
  // Evict box signals
  logic       evict_req,   evict_valid;
  // Response output into the spill register
  store_res_t res;
  store_res_t res_q;
  logic       res_valid,   res_ready;
  logic       res_sram_wr_delay_d;
  logic       res_sram_wr_delay_q;

  assign res_sram_wr_delay_d = (((res_valid && res_ready) && |(ram_req & ram_we)) || res_sram_wr_delay_q) && !ram_hsk; // there is a unfinished resp tag update
  `FFLARN(res_q, res, res_sram_wr_delay_d & ~res_sram_wr_delay_q, store_res_t'{default: '0}, clk_i, rst_ni)
  `FFARN(res_sram_wr_delay_q, res_sram_wr_delay_d, '0, clk_i, rst_ni)


  // macro control
  always_comb begin : proc_macro_ctrl
    // default assignments
    // FFs
    switch_busy  = 1'b0;
    ready_o      = 1'b0;
    load_req     = 1'b0;
    shift_req    = 1'b0;
    res_valid    = 1'b0;
    ram_req      = way_ind_t'(0);
    ram_we       = way_ind_t'(0);
    ram_index    = way_ind_t'(0);
    ram_wdata    = tag_data_t'{default: '0};
    // Evict box
    evict_req    = 1'b0;
    // generation request
    gen_valid    = 1'b0;
    bist_valid   = 1'b0;

    if (busy_q) begin
      if(req_q_valid) begin
        // We are busy so there are active operations going on, we are not ready.
        unique case (req_q.mode)
            axi_llc_pkg::Bist: begin
              // During BIST connect the request to the tag pattern generator.
              ram_req    = {Cfg.SetAssociativity{gen_req}};
              ram_we     = {Cfg.SetAssociativity{gen_we}};
              ram_index  = gen_index;
              ram_wdata  = gen_pattern;
              bist_valid = |ram_rvalid;
              // If BIST finished, go to idle.
              if (gen_eoc) begin
                switch_busy = 1'b1;
                // Shift the req_q register
                shift_req   = 1'b1;
              end
            end
            axi_llc_pkg::Lookup: begin
              // Wait for valid macro output
              if ((|ram_rvalid) | (ram_rvalid_q)) begin
                // We are valid on hit.
                if (|hit) begin
                  res_valid = 1'b1;
                end else begin
                  evict_req = 1'b1;
                  res_valid = evict_valid;
                end
              end

              // Do we have to write back something?
              if ((res_valid && res_ready) || res_sram_wr_delay_q) begin
                if (res.hit || res_sram_wr_delay_q && res_q.hit) begin
                  // This is a hit
                  if (req_q.dirty && !tag_dit[bin_ind] || res_sram_wr_delay_q) begin
                    // Do we have to store a dirty as the hit was not dirty until now?
                    // add a 1 bit state reg
                    ram_req   = res_sram_wr_delay_q ? res_q.indicator : res.indicator;  // ff
                    ram_we    = res_sram_wr_delay_q ? res_q.indicator : res.indicator;
                    ram_index = req_q.index;
                    ram_wdata = tag_data_t'{
                                  val: 1'b1,
                                  dit: 1'b1,
                                  tag: req_q.tag
                                };
                    // Stop it switch to idle if the write not hsk or there is another req waiting
                    switch_busy = ram_hsk & ~req_q_waiting_valid; 
                    // Shift the req_q register
                    shift_req   = ram_hsk;
                  end else begin
                    // Shift the req_q register
                    shift_req   = 1'b1;
                    // Noting to write back, do we have a new LOOKUP request?
                    if (valid_i && (req_i.mode == axi_llc_pkg::Lookup)) begin
                      ready_o = 1'b1;
                      // Do the lookup on the requested macros
                      ram_req     = req_i.indicator;
                      ram_index   = req_i.index;
                      if(ram_hsk) begin
                        load_req    = 1'b1;
                        switch_busy = 1'b0;                      
                      end else begin
                        ready_o = 1'b0;
                        // Go back to IDLE if the tag sram is busy
                        switch_busy = ~req_q_waiting_valid;                      
                      end
                    end else begin
                      // Go back to IDLE if no Lookup
                      switch_busy = ~req_q_waiting_valid; 
                    end
                  end
                end else begin
                  // This is a miss!
                  // Write back the new tag, it was a miss.
                  ram_req   = res_sram_wr_delay_q ? res_q.indicator : res.indicator;
                  ram_we    = res_sram_wr_delay_q ? res_q.indicator : res.indicator;
                  ram_index = req_q.index;
                  ram_wdata = tag_data_t'{
                                val: 1'b1,
                                dit: req_q.dirty,
                                tag: req_q.tag
                              };
                  // Go back to idle.
                  // Stop it switch to idle if the write not hsk or there is another req waiting
                  switch_busy = ram_hsk & ~req_q_waiting_valid;
                  // Shift the req_q register if there is at least one waiting
                  shift_req   = ram_hsk;
                end
              end
            end
            axi_llc_pkg::Flush: begin
              if ((|ram_rvalid) | (ram_rvalid_q)) begin
                // We are valid when the read output of the macros is valid!
                res_valid = 1'b1;
              end

              // Write back all zeros to the storage if the output is acknowledged.
              if ((res_valid && res_ready) || res_sram_wr_delay_q) begin
                ram_req     = req_q.indicator;
                ram_we      = req_q.indicator;
                ram_index   = req_q.index;
                ram_wdata   = tag_data_t'{default: '0};
                // Stop it switch to idle if the write not hsk or there is another req waiting
                switch_busy = ram_hsk & ~req_q_waiting_valid;
                // Shift the req_q register if there is at least one waiting
                shift_req   = ram_hsk;
              end
            end
          default : /* default */;
        endcase
      end else begin
        // Noting to do, do we have a new LOOKUP request?
        if (valid_i && (req_i.mode == axi_llc_pkg::Lookup)) begin
          ready_o = 1'b1;
          // Do the lookup on the requested macros
          ram_req     = req_i.indicator;
          ram_index   = req_i.index;
          if(ram_hsk) begin
            load_req    = 1'b1;
            switch_busy = 1'b0;                      
          end else begin
            ready_o = 1'b0;
            // Go back to IDLE if the tag sram is busy
            switch_busy = ~req_q_waiting_valid;
            // Still shift the req_q register if there is at least one waiting
            shift_req   = req_q_waiting_valid;
          end
        end else begin
          // Go back to IDLE if no Lookup
          switch_busy = ~req_q_waiting_valid;
          // Still shift the req_q register if there is at least one waiting
          shift_req   = req_q_waiting_valid;
        end
      end
    end else begin
      // we are not busy, so we are ready to get a new request.
      ready_o = 1'b1;

      if (valid_i) begin
        // There is a request to the tag store.
        switch_busy = 1'b1;
        load_req    = 1'b1;

        // Make the requests to the tag macros.
        unique case (req_i.mode)
          axi_llc_pkg::Bist: begin
            gen_valid   = 1'b1;
            ready_o     = gen_ready;
            // Only switch the state, if the request is valid
            switch_busy = gen_ready;
          end
          axi_llc_pkg::Lookup, axi_llc_pkg::Flush: begin
            // Do the lookup on the requested macros
            ram_req     = req_i.indicator;
            ram_index   = req_i.index;
            if(ram_hsk) begin
              load_req    = 1'b1;
              ready_o     = 1'b1;
              switch_busy = 1'b1;
            end else begin
              load_req    = 1'b0;
              ready_o     = 1'b0;
              switch_busy = 1'b0;
            end
          end
          default : /* do nothing */;
        endcase
      end
    end
  end

  // make sure all the ways of sram we are accessing are ready
  assign ram_hsk     = ~(|((ram_req & ram_gnt) ^ ram_req)); 

  // `FFLARN(req_q, req_i, load_req, store_req_t'{default: '0}, clk_i, rst_ni)
  assign req_q_d = store_req_q_t'{
    req_q       : req_q,
    evict_valid : evict_req & evict_valid,
    evict_way   : bin_ind
  };
  `FFLARN(req_q_q, req_q_d, req_q_valid & (load_req | shift_req), store_req_q_t'{default: '0}, clk_i, rst_ni)
  `FFLARN(busy_q, busy_d, switch_busy, 1'b0, clk_i, rst_ni)
  assign busy_d = ~busy_q;
  // `FFLARN(ram_rvalid_q, ram_rvalid_d, lock_rvalid, way_ind_t'(0), clk_i, rst_ni)
  // assign ram_rvalid_d = (res_valid & res_ready) ? way_ind_t'(0) : ram_rvalid;
  // assign ram_rvalid_d = (res_valid & res_ready) ? ((req_q_q.req_q.mode == axi_llc_pkg::Bist) ? '0 : ram_rvalid_q & ram_rvalid) 
  //                                               : ram_rvalid;
  // assign lock_rvalid  = (res_valid & res_ready) | (|ram_rvalid);

  logic [SRAMDataWidth-1:0] sram_wdata;
  assign sram_wdata = {{SRAMExtendedWidth{1'b0}}, ram_wdata};

  logic debug_use_forward_tag;
  logic [Cfg.SetAssociativity-1:0] debug_use_forward_tag_tmp;

  assign debug_use_forward_tag = |debug_use_forward_tag_tmp;

  // generate for each Way one tag storage macro
  for (genvar i = 0; unsigned'(i) < Cfg.SetAssociativity; i++) begin : gen_tag_macros
    tag_data_t ram_compared; // comparison result of tags

    // For functional test
    assign ram_req_o  [i] = ram_req[i];
    assign ram_we_o   [i] = ram_we [i];
    assign ram_addr_o [i] = ram_index;
    assign ram_wdata_o[i] = sram_wdata;
    assign ram_be_o   [i] = ram_we[i];
    assign ram_gnt    [i] = ram_gnt_i[i];
    assign sram_rdata [i] = ram_data_i[i];

    // // For synthesis
    // axi_llc_sram_tag_fpga #(
    //   .NumWords    ( Cfg.NumLines                 ),
    //   .DataWidth   ( SRAMDataWidth                ),
    //   .ByteWidth   ( SRAMDataWidth                ),
    //   .NumPorts    ( 32'd1                        ),
    //   .Latency     ( axi_llc_pkg::TagMacroLatency ),
    //   .SimInit     ( "none"                       ),
    //   .PrintSimCfg ( 1'b1                         ),
    //   .NumLines    ( Cfg.NumLines                 ),
    //   .PrintSimCfg ( PrintSramCfg                 )
    // ) i_tag_store (
    //   .clk_i,
    //   .rst_ni,
    //   .req_i   ( ram_req[i] ),
    //   .we_i    ( ram_we[i]  ),
    //   .addr_i  ( ram_index  ),
    //   .wdata_i ( sram_wdata  ),
    //   .be_i    ( ram_we[i]  ),
    //   .rdata_o ( sram_rdata  )
    // );

    assign ram_rdata [i] = sram_rdata[i][TagDataLen-1:0];

    assign ram_rdata_en         [i] = ram_rdata_q_valid_set[i] & ~ram_rdata_q_valid_clr[i] & ~ram_rdata_q_valid[i];
    assign ram_rdata_q_valid_en [i] = ram_rdata_q_valid_set[i] | ram_rdata_q_valid_clr [i];
    assign ram_rdata_q_valid_set[i] = ~ram_rdata_q_valid[i] & ((|ram_rvalid) | (ram_rvalid_q));
    assign ram_rdata_q_valid_clr[i] = (res_valid && res_ready);
    assign ram_rdata_q_valid_nxt[i] = ram_rdata_q_valid_set[i] & ~ram_rdata_q_valid_clr[i];

    `FFLARN(ram_rdata_q[i], ram_rdata[i], ram_rdata_en[i], '0, clk_i, rst_ni)
    `FFLARN(ram_rdata_q_valid[i], ram_rdata_q_valid_nxt[i], ram_rdata_q_valid_en[i], '0, clk_i, rst_ni)

    // shift register for a validtoken for read data, this pulses once for each read request
    shift_reg #(
      .dtype ( logic                        ),
      .Depth ( axi_llc_pkg::TagMacroLatency )
    ) i_shift_reg_rvalid (
      .clk_i,
      .rst_ni,
      .d_i    ( ram_req[i] & ram_hsk & ~ram_we[i] ),
      .d_o    ( ram_rvalid[i]           )
    );

    // the tag used to compare
    always_comb begin
      ram_rdata_sel[i] = ram_rdata_q_valid ? ram_rdata_q[i] : ram_rdata[i];
      debug_use_forward_tag_tmp[i] = 1'b0;
      if(req_q_q.req_q.index == req_q.index) begin
        if(req_q_q.evict_valid) begin
          debug_use_forward_tag_tmp[i] = 1'b1;
          if(req_q_q.evict_way == i[$bits(bin_ind_t)-1:0]) begin
            ram_rdata_sel[i] = tag_data_t'{
              val: 1'b1,
              dit: req_q_q.req_q.dirty,
              tag: req_q_q.req_q.tag
            };
          end
        end
      end
    end

    // comparator (XNOR)
    assign ram_compared = tag_data_t'{
          val: bist_pattern.val,
          dit: bist_pattern.dit,
          tag: (req_q.mode == axi_llc_pkg::Bist) ? bist_pattern.tag : req_q.tag
        } ~^ ram_rdata_sel[i];
    assign tag_equ[i] = &ram_compared.tag; // valid if the stored tag equals the one looked up
    assign tag_val[i] = ram_rdata_sel[i].val;     // indicates where valid values are in the line
    assign tag_dit[i] = ram_rdata_sel[i].dit;     // indicates which tags are dirty

    // hit detection
    assign hit[i]        = req_q_valid & req_q.indicator[i] & tag_val[i] & tag_equ[i];
    // BIST also add the two bits of valid and dirty
    assign bist_res[i]   = ram_compared.val & ram_compared.dit & tag_equ[i];
    // assignment to wide output signal that goes to the tag output mux
    assign stored_tag[i] = ram_rdata_sel[i];
  end

  axi_llc_tag_pattern_gen #(
    .Cfg       ( Cfg        ),
    .pattern_t ( tag_data_t ),
    .way_ind_t ( way_ind_t  ),
    .index_t   ( index_t    )
  ) i_tag_pattern_gen (
    .clk_i,
    .rst_ni,
    .valid_i          ( gen_valid   ),
    .ready_o          ( gen_ready   ),
    .index_o          ( gen_index   ),
    .pattern_o        ( gen_pattern ),
    .req_o            ( gen_req     ),
    .we_o             ( gen_we      ),
    .sram_ready_i     ( ram_hsk     ),
    .bist_res_i       ( bist_res    ),
    .bist_res_valid_i ( bist_valid  ),
    .bist_res_o       ( bist_res_o  ),
    .eoc_o            ( gen_eoc     )
  );
  assign bist_valid_o = gen_eoc;

  // This shift register holds the pattern for comparison of the bist.
  shift_reg #(
    .dtype ( tag_data_t                   ),
    .Depth ( axi_llc_pkg::TagMacroLatency )
  ) i_shift_reg_bist (
    .clk_i,
    .rst_ni,
    .d_i    ( gen_pattern  ),
    .d_o    ( bist_pattern )
  );

  way_ind_t evict_way_ind;
  logic     evict_flag;

  axi_llc_evict_box #(
    .Cfg       ( Cfg       ),
    .way_ind_t ( way_ind_t )
  ) i_evict_box (
    .clk_i,
    .rst_ni,
    .req_i       ( evict_req     ),
    .tag_valid_i ( tag_val       ),
    .tag_dirty_i ( tag_dit       ),
    .spm_lock_i  ( spm_lock_i    ),
    .way_ind_o   ( evict_way_ind ),
    .evict_o     ( evict_flag    ),
    .valid_o     ( evict_valid   )
  );

  onehot_to_bin #(
    .ONEHOT_WIDTH ( Cfg.SetAssociativity )
  ) i_onehot_to_bin (
    .onehot ( res.indicator ),
    .bin    ( bin_ind       )
  );

  // Silence output when not in a mode where it is required.
  always_comb begin
    // Default assignment
    res = store_res_t'{default: '0};
    if (busy_q & req_q_valid) begin
      unique case (req_q.mode)
        axi_llc_pkg::Lookup: begin
          res = store_res_t'{
            indicator: (|hit) ? hit       : evict_way_ind,
            hit:       (|hit) ? 1'b1      : 1'b0,
            evict:     (|hit) ? 1'b0      : evict_flag,
            evict_tag: (|hit) ? tag_t'(0) : stored_tag[bin_ind].tag,
            hit_line_dirty: (|hit) ? stored_tag[bin_ind].dit : '0,
            default:   '0
          };
        end
        axi_llc_pkg::Flush: begin
          res = store_res_t'{
            indicator: req_q.indicator,
            hit:       1'b0,
            evict:     stored_tag[bin_ind].val & stored_tag[bin_ind].dit,
            evict_tag: stored_tag[bin_ind].tag,
            default:   '0
          };
        end
        default : /* not used */;
      endcase
    end
  end

  // Output spill register for breaking timing path
  spill_register #(
    .T       ( store_res_t                 ),
    .Bypass  ( !axi_llc_pkg::SpillTagStore )
  ) i_spill_register (
    .clk_i,
    .rst_ni,
    .valid_i ( res_valid ),
    .ready_o ( res_ready ),
    .data_i  ( res       ),
    .valid_o ( valid_o   ),
    .ready_i ( ready_i   ),
    .data_o  ( res_o     )
  );

  shift_reg_gated_with_enable #(
      .dtype ( store_req_t                  ),
      .Depth ( axi_llc_pkg::TagMacroLatency )
  ) i_shift_reg_gated_with_enable_req_q (
    .clk_i,
    .rst_ni,

    .valid_i    (load_req),
    .data_i     (req_i),
    .shift_en_i (load_req | shift_req),
    .valid_o    (req_q_valid),
    .data_o     (req_q),
    .waiting_valid_o (req_q_waiting_valid)
  );


  logic  ram_rvalid_fifo_push, ram_rvalid_fifo_pop;
  assign ram_rvalid_cnt_en    = (req_q.mode != axi_llc_pkg::Bist) &
                                ~(ram_rvalid_fifo_push & ram_rvalid_fifo_pop) &
                                (ram_rvalid_fifo_push | ram_rvalid_fifo_pop);
  assign ram_rvalid_cnt_down  = ram_rvalid_fifo_pop;
  assign ram_rvalid_fifo_push = |ram_rvalid;
  assign ram_rvalid_fifo_pop  = res_valid & res_ready;
  assign ram_rvalid_q         = |ram_rvalid_cnt;

  counter #(
    .WIDTH      ( $clog2(axi_llc_pkg::TagMacroLatency)+1 )
  ) i_ram_rvalid_cnt (
    .clk_i      ( clk_i     ),
    .rst_ni     ( rst_ni    ),
    .clear_i    ( '0        ),
    .en_i       ( ram_rvalid_cnt_en ),
    .load_i     ( '0        ),
    .down_i     ( ram_rvalid_cnt_down ),
    .d_i        ( '0        ),
    .q_o        ( ram_rvalid_cnt ),
    .overflow_o ( ram_rvalid_cnt_overflow )
  );


  // Assertions
  // pragma translate_off
  `ifndef VERILATOR
  // onehot_hit:  assert property ( @(posedge clk_i) disable iff (!rst_ni)
  //     (req_q.mode inside {axi_llc_pkg::Lookup, axi_llc_pkg::Flush}) |-> $onehot0(hit)) else
  //     $fatal(1, "[hit_ind] More than two bit set in the one-hot signal, multiple hits!");
  onehot_ind:  assert property ( @(posedge clk_i) disable iff (!rst_ni)
      (req_q.mode inside {axi_llc_pkg::Lookup, axi_llc_pkg::Flush}) |-> $onehot0(res.indicator)) else
      $fatal(1, "[way_ind_o] More than two bit set in the one-hot signal, multiple hits!");
  // trigger warning if output valid gets deasserted without ready
  check_valid: assert property ( @(posedge clk_i) disable iff (!rst_ni)
      (res_valid && !res_ready) |=> res_valid) else
      $warning("Valid was deasserted, even when no ready was set.");
  check_all_spm: assert property ( @(posedge clk_i) disable iff (~rst_ni)
      ((flushed_i == {Cfg.SetAssociativity{1'b1}}) |-> (evict_req == 1'b0))) else
      $fatal(1, "Should not have a request for the evict box, if all ways are flushed!");
  check_ram_rvalid: assert property ( @(posedge clk_i) disable iff (~rst_ni)
      ((ram_rvalid_cnt_en) |-> ((ram_rvalid_cnt <= axi_llc_pkg::TagMacroLatency)))) else
      $fatal(1, "Try to push a add ram_rvalid into a full ram_rvalid_cnt!");
  `endif
  // pragma translate_on
endmodule
