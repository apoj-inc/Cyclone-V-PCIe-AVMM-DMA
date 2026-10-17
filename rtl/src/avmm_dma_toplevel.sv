module avmm_dma_toplevel #(
    parameter     DMA_CHANNEL_COUNT                     = 8         ,

    parameter     DMA_BYTES_WIDTH                       = 22        ,
    parameter     DMA_OFFFSET_WIDTH                     = 22        ,

    parameter int DMA_WORD_BYTES    [DMA_CHANNEL_COUNT] = '{8 {16 }},
    parameter int DMA_WQ_DEPTH      [DMA_CHANNEL_COUNT] = '{8 {64 }},
    parameter int DMA_RQ_DEPTH      [DMA_CHANNEL_COUNT] = '{8 {64 }},
    parameter     DMA_TQ_DEPTH                          = 8         ,

    parameter     MAX_WQ_DEPTH                          = 64        ,
    parameter     MAX_RQ_DEPTH                          = 64        ,

    parameter     BAR_DATA_WIDTH                        = 128       ,
    parameter     BAR_ADDR_WIDTH                        = 12        ,

    parameter     TX_DATA_WIDTH                         = 128       ,
    parameter     TX_ADDR_WIDTH                         = 64        ,
    parameter     TX_BURST_WIDTH                        = 6         ,

    parameter BAR_DATA_BYTES    = BAR_DATA_WIDTH / 8  ,
    parameter TX_DATA_BYTES     = TX_DATA_WIDTH / 8   ,
    parameter DMA_WQ_ADDR_WIDTH = $clog2(MAX_WQ_DEPTH),
    parameter DMA_RQ_ADDR_WIDTH = $clog2(MAX_RQ_DEPTH)
) (

    output logic                         FAN_CTRL                                ,

    input  logic                         PCIE_PERST_n                            ,
    input  logic                         PCIE_REFCLK_p                           ,
    input  logic [3:0]                   PCIE_RX_p                               ,
    output logic [3:0]                   PCIE_TX_p                               ,

    input  logic                         dma_wrdata_valid_i   [DMA_CHANNEL_COUNT],
    output logic                         dma_wrdata_ready_o   [DMA_CHANNEL_COUNT],
    input  logic [DMA_WQ_ADDR_WIDTH:0]   dma_wrdata_count_i   [DMA_CHANNEL_COUNT],
    input  logic [TX_DATA_WIDTH-1:0]     dma_wrdata_data_i    [DMA_CHANNEL_COUNT],

    output logic                         dma_rddata_valid_o   [DMA_CHANNEL_COUNT],
    input  logic                         dma_rddata_ready_i   [DMA_CHANNEL_COUNT],
    input  logic [DMA_RQ_ADDR_WIDTH:0]   dma_rddata_free_i    [DMA_CHANNEL_COUNT],
    output logic [TX_DATA_WIDTH-1:0]     dma_rddata_data_o    [DMA_CHANNEL_COUNT],

    
    output logic                         env_csr_m_chipselect                    ,
    output logic [BAR_DATA_BYTES-1:0]    env_csr_m_byteenable                    ,
    input  logic [BAR_DATA_WIDTH-1:0]    env_csr_m_readdata                      ,
    output logic [BAR_DATA_WIDTH-1:0]    env_csr_m_writedata                     ,
    output logic                         env_csr_m_read                          ,
    output logic                         env_csr_m_write                         ,
    input  logic                         env_csr_m_readdatavalid                 ,
    input  logic                         env_csr_m_waitrequest                   ,
    output logic [BAR_ADDR_WIDTH:0]      env_csr_m_address                       ,

    input  logic [DMA_CHANNEL_COUNT-1:0] user_irq_i                              ,

    output logic                         dma_clk_o                               ,
    output logic                         dma_resetn_o                            ,
    output logic                         pcie_resetn_o                           ,

    output logic                         pll_50mhz_clk_o                         

);

assign FAN_CTRL = 1;

logic           pll_50mhz_clk                   ;

logic         core_clk_clk                 ;
logic         core_reset_reset_n           ;

logic         csr_avmm_m_chipselect             ;
logic [15:0]  csr_avmm_m_byteenable             ;
logic [127:0] csr_avmm_m_readdata               ;
logic [127:0] csr_avmm_m_writedata              ;
logic         csr_avmm_m_read                   ;
logic         csr_avmm_m_write                  ;
logic         csr_avmm_m_readdatavalid          ;
logic         csr_avmm_m_waitrequest            ;
logic [11:0]  csr_avmm_m_address                ;
logic [5:0]   csr_avmm_m_burstcount             ;

logic         msix_avmm_m_chipselect            ;
logic [15:0]  msix_avmm_m_byteenable            ;
logic [127:0] msix_avmm_m_readdata              ;
logic [127:0] msix_avmm_m_writedata             ;
logic         msix_avmm_m_read                  ;
logic         msix_avmm_m_write                 ;
logic         msix_avmm_m_readdatavalid         ;
logic         msix_avmm_m_waitrequest           ;
logic [11:0]  msix_avmm_m_address               ;
logic [5:0]   msix_avmm_m_burstcount            ;

logic [11:0]  decoder_avmm_m_address            ;
logic [5:0]   decoder_avmm_m_burstcount         ;
logic         decoder_avmm_m_chipselect         ;
logic [15:0]  decoder_avmm_m_byteenable         ;
logic         decoder_avmm_m_read               ;
logic [127:0] decoder_avmm_m_readdata           ;
logic         decoder_avmm_m_readdatavalid      ;
logic         decoder_avmm_m_waitrequest        ;
logic         decoder_avmm_m_write              ;
logic [127:0] decoder_avmm_m_writedata          ;

logic         msix_avmm_s_chipselect            ;
logic [15:0]  msix_avmm_s_byteenable            ;
logic [127:0] msix_avmm_s_readdata              ;
logic [127:0] msix_avmm_s_writedata             ;
logic         msix_avmm_s_read                  ;
logic         msix_avmm_s_write                 ;
logic [5:0]   msix_avmm_s_burstcount            ;
logic         msix_avmm_s_readdatavalid         ;
logic         msix_avmm_s_waitrequest           ;
logic [63:0]  msix_avmm_s_address               ;

logic         dma_avmm_s_chipselect        [16] ;
logic [15:0]  dma_avmm_s_byteenable        [16] ;
logic [127:0] dma_avmm_s_readdata          [16] ;
logic [127:0] dma_avmm_s_writedata         [16] ;
logic         dma_avmm_s_read              [16] ;
logic         dma_avmm_s_write             [16] ;
logic [5:0]   dma_avmm_s_burstcount        [16] ;
logic         dma_avmm_s_readdatavalid     [16] ;
logic         dma_avmm_s_waitrequest       [16] ;
logic [63:0]  dma_avmm_s_address           [16] ;

assign dma_clk_o     = core_clk_clk      ;
assign pcie_resetn_o = core_reset_reset_n;


logic clock_50_rstn_r  /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;
logic clock_50_rstn_rr /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;

//reset Synchronizer
always @(posedge pll_50mhz_clk or negedge PCIE_PERST_n) begin
    if (!PCIE_PERST_n) begin
        clock_50_rstn_r  <= 0;
        clock_50_rstn_rr <= 0;
    end
    else begin
        clock_50_rstn_r  <= 1;
        clock_50_rstn_rr <= clock_50_rstn_r;
    end
end


logic clock_125_rstn_r  /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;
logic clock_125_rstn_rr /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;

//reset Synchronizer
always @(posedge core_clk_clk or negedge PCIE_PERST_n) begin
    if (!PCIE_PERST_n) begin
        clock_125_rstn_r  <= 0;
        clock_125_rstn_rr <= 0;
    end
    else begin
        clock_125_rstn_r  <= 1;
        clock_125_rstn_rr <= clock_125_rstn_r;
    end
end

avmm_dma_assembly #(
    .DMA_CHANNEL_COUNT (DMA_CHANNEL_COUNT),

    .DMA_BYTES_WIDTH   (DMA_BYTES_WIDTH  ),
    .DMA_OFFFSET_WIDTH (DMA_OFFFSET_WIDTH),

    .DMA_WORD_BYTES    (DMA_WORD_BYTES   ),
    .DMA_WQ_DEPTH      (DMA_WQ_DEPTH     ),
    .DMA_RQ_DEPTH      (DMA_RQ_DEPTH     ),
    .DMA_TQ_DEPTH      (DMA_TQ_DEPTH     ),

    .MAX_WQ_DEPTH      (MAX_WQ_DEPTH     ),
    .MAX_RQ_DEPTH      (MAX_RQ_DEPTH     ),

    .BAR_DATA_WIDTH    (BAR_DATA_WIDTH   ),
    .BAR_ADDR_WIDTH    (BAR_ADDR_WIDTH   ),

    .TX_DATA_WIDTH     (TX_DATA_WIDTH    ),
    .TX_ADDR_WIDTH     (TX_ADDR_WIDTH    ),
    .TX_BURST_WIDTH    (TX_BURST_WIDTH   )
) (
    .clk                       (core_clk_clk                                        ),
    .rst_n                     (core_reset_reset_n                                  ),

    .csr_s_chipselect          (csr_avmm_m_chipselect                               ),
    .csr_s_byteenable          (csr_avmm_m_byteenable                               ),
    .csr_s_readdata            (csr_avmm_m_readdata                                 ),
    .csr_s_writedata           (csr_avmm_m_writedata                                ),
    .csr_s_read                (csr_avmm_m_read                                     ),
    .csr_s_write               (csr_avmm_m_write                                    ),
    .csr_s_readdatavalid       (csr_avmm_m_readdatavalid                            ),
    .csr_s_waitrequest         (csr_avmm_m_waitrequest                              ),
    .csr_s_address             (csr_avmm_m_address                                  ),

    .msix_s_chipselect         (msix_avmm_m_chipselect                              ),
    .msix_s_byteenable         (msix_avmm_m_byteenable                              ),
    .msix_s_readdata           (msix_avmm_m_readdata                                ),
    .msix_s_writedata          (msix_avmm_m_writedata                               ),
    .msix_s_read               (msix_avmm_m_read                                    ),
    .msix_s_write              (msix_avmm_m_write                                   ),
    .msix_s_readdatavalid      (msix_avmm_m_readdatavalid                           ),
    .msix_s_waitrequest        (msix_avmm_m_waitrequest                             ),
    .msix_s_address            (msix_avmm_m_address                                 ),

    .dec_s_chipselect          (decoder_avmm_m_chipselect                           ),
    .dec_s_byteenable          (decoder_avmm_m_byteenable                           ),
    .dec_s_readdata            (decoder_avmm_m_readdata                             ),
    .dec_s_writedata           (decoder_avmm_m_writedata                            ),
    .dec_s_read                (decoder_avmm_m_read                                 ),
    .dec_s_write               (decoder_avmm_m_write                                ),
    .dec_s_readdatavalid       (decoder_avmm_m_readdatavalid                        ),
    .dec_s_waitrequest         (decoder_avmm_m_waitrequest                          ),
    .dec_s_address             (decoder_avmm_m_address                              ),

    .user_irq_i                (user_irq_i                                          ),

    .tx_chipselect             (dma_avmm_s_chipselect        [0:DMA_CHANNEL_COUNT-1]),
    .tx_byteenable             (dma_avmm_s_byteenable        [0:DMA_CHANNEL_COUNT-1]),
    .tx_readdata               (dma_avmm_s_readdata          [0:DMA_CHANNEL_COUNT-1]),
    .tx_writedata              (dma_avmm_s_writedata         [0:DMA_CHANNEL_COUNT-1]),
    .tx_read                   (dma_avmm_s_read              [0:DMA_CHANNEL_COUNT-1]),
    .tx_write                  (dma_avmm_s_write             [0:DMA_CHANNEL_COUNT-1]),
    .tx_burstcount             (dma_avmm_s_burstcount        [0:DMA_CHANNEL_COUNT-1]),
    .tx_readdatavalid          (dma_avmm_s_readdatavalid     [0:DMA_CHANNEL_COUNT-1]),
    .tx_waitrequest            (dma_avmm_s_waitrequest       [0:DMA_CHANNEL_COUNT-1]),
    .tx_address                (dma_avmm_s_address           [0:DMA_CHANNEL_COUNT-1]),

    .msix_m_chipselect         (msix_avmm_s_chipselect                              ),
    .msix_m_byteenable         (msix_avmm_s_byteenable                              ),
    .msix_m_readdata           (msix_avmm_s_readdata                                ),
    .msix_m_writedata          (msix_avmm_s_writedata                               ),
    .msix_m_read               (msix_avmm_s_read                                    ),
    .msix_m_write              (msix_avmm_s_write                                   ),
    .msix_m_burstcount         (msix_avmm_s_burstcount                              ),
    .msix_m_readdatavalid      (msix_avmm_s_readdatavalid                           ),
    .msix_m_waitrequest        (msix_avmm_s_waitrequest                             ),
    .msix_m_address            (msix_avmm_s_address                                 ),

    .dma_wrdata_valid_i        (dma_wrdata_valid_i                                  ),
    .dma_wrdata_ready_o        (dma_wrdata_ready_o                                  ),
    .dma_wrdata_count_i        (dma_wrdata_count_i                                  ),
    .dma_wrdata_data_i         (dma_wrdata_data_i                                   ),

    .dma_rddata_valid_o        (dma_rddata_valid_o                                  ),
    .dma_rddata_ready_i        (dma_rddata_ready_i                                  ),
    .dma_rddata_free_i         (dma_rddata_free_i                                   ),
    .dma_rddata_data_o         (dma_rddata_data_o                                   ),

    .dma_resetn_o              (dma_resetn_o                                        )
);

my_pcie u_my_pcie (
        .pll_50mhz_clk                                            (pll_50mhz_clk                      ),
        .core_clk_clk                                             (core_clk_clk                       ),
        .core_reset_reset_n                                       (core_reset_reset_n                 ),
        .csr_avmm_m_address                                       (csr_avmm_m_address                 ),
        .csr_avmm_m_burstcount                                    (csr_avmm_m_burstcount              ),
        .csr_avmm_m_chipselect                                    (csr_avmm_m_chipselect              ),
        .csr_avmm_m_byteenable                                    (csr_avmm_m_byteenable              ),
        .csr_avmm_m_read                                          (csr_avmm_m_read                    ),
        .csr_avmm_m_readdata                                      (csr_avmm_m_readdata                ),
        .csr_avmm_m_readdatavalid                                 (csr_avmm_m_readdatavalid           ),
        .csr_avmm_m_waitrequest                                   (csr_avmm_m_waitrequest             ),
        .csr_avmm_m_write                                         (csr_avmm_m_write                   ),
        .csr_avmm_m_writedata                                     (csr_avmm_m_writedata               ),
        .decoder_avmm_m_address                                   (decoder_avmm_m_address             ),
        .decoder_avmm_m_burstcount                                (decoder_avmm_m_burstcount          ),
        .decoder_avmm_m_chipselect                                (decoder_avmm_m_chipselect          ),
        .decoder_avmm_m_byteenable                                (decoder_avmm_m_byteenable          ),
        .decoder_avmm_m_read                                      (decoder_avmm_m_read                ),
        .decoder_avmm_m_readdata                                  (decoder_avmm_m_readdata            ),
        .decoder_avmm_m_readdatavalid                             (decoder_avmm_m_readdatavalid       ),
        .decoder_avmm_m_waitrequest                               (decoder_avmm_m_waitrequest         ),
        .decoder_avmm_m_write                                     (decoder_avmm_m_write               ),
        .decoder_avmm_m_writedata                                 (decoder_avmm_m_writedata           ),
        .env_csr_avmm_m_address                                   (env_csr_m_address                  ),
        .env_csr_avmm_m_burstcount                                (env_csr_m_burstcount               ),
        .env_csr_avmm_m_byteenable                                (env_csr_m_byteenable               ),
        .env_csr_avmm_m_chipselect                                (env_csr_m_chipselect               ),
        .env_csr_avmm_m_read                                      (env_csr_m_read                     ),
        .env_csr_avmm_m_readdata                                  (env_csr_m_readdata                 ),
        .env_csr_avmm_m_readdatavalid                             (env_csr_m_readdatavalid            ),
        .env_csr_avmm_m_waitrequest                               (env_csr_m_waitrequest              ),
        .env_csr_avmm_m_write                                     (env_csr_m_write                    ),
        .env_csr_avmm_m_writedata                                 (env_csr_m_writedata                ),
        .dma_0_avmm_s_chipselect                                  (dma_avmm_s_chipselect          [0] ),
        .dma_0_avmm_s_byteenable                                  (dma_avmm_s_byteenable          [0] ),
        .dma_0_avmm_s_readdata                                    (dma_avmm_s_readdata            [0] ),
        .dma_0_avmm_s_writedata                                   (dma_avmm_s_writedata           [0] ),
        .dma_0_avmm_s_read                                        (dma_avmm_s_read                [0] ),
        .dma_0_avmm_s_write                                       (dma_avmm_s_write               [0] ),
        .dma_0_avmm_s_burstcount                                  (dma_avmm_s_burstcount          [0] ),
        .dma_0_avmm_s_readdatavalid                               (dma_avmm_s_readdatavalid       [0] ),
        .dma_0_avmm_s_waitrequest                                 (dma_avmm_s_waitrequest         [0] ),
        .dma_0_avmm_s_address                                     (dma_avmm_s_address             [0] ),
        .dma_1_avmm_s_chipselect                                  (dma_avmm_s_chipselect          [1] ),
        .dma_1_avmm_s_byteenable                                  (dma_avmm_s_byteenable          [1] ),
        .dma_1_avmm_s_readdata                                    (dma_avmm_s_readdata            [1] ),
        .dma_1_avmm_s_writedata                                   (dma_avmm_s_writedata           [1] ),
        .dma_1_avmm_s_read                                        (dma_avmm_s_read                [1] ),
        .dma_1_avmm_s_write                                       (dma_avmm_s_write               [1] ),
        .dma_1_avmm_s_burstcount                                  (dma_avmm_s_burstcount          [1] ),
        .dma_1_avmm_s_readdatavalid                               (dma_avmm_s_readdatavalid       [1] ),
        .dma_1_avmm_s_waitrequest                                 (dma_avmm_s_waitrequest         [1] ),
        .dma_1_avmm_s_address                                     (dma_avmm_s_address             [1] ),
        .dma_2_avmm_s_chipselect                                  (dma_avmm_s_chipselect          [2] ),
        .dma_2_avmm_s_byteenable                                  (dma_avmm_s_byteenable          [2] ),
        .dma_2_avmm_s_readdata                                    (dma_avmm_s_readdata            [2] ),
        .dma_2_avmm_s_writedata                                   (dma_avmm_s_writedata           [2] ),
        .dma_2_avmm_s_read                                        (dma_avmm_s_read                [2] ),
        .dma_2_avmm_s_write                                       (dma_avmm_s_write               [2] ),
        .dma_2_avmm_s_burstcount                                  (dma_avmm_s_burstcount          [2] ),
        .dma_2_avmm_s_readdatavalid                               (dma_avmm_s_readdatavalid       [2] ),
        .dma_2_avmm_s_waitrequest                                 (dma_avmm_s_waitrequest         [2] ),
        .dma_2_avmm_s_address                                     (dma_avmm_s_address             [2] ),
        .dma_3_avmm_s_chipselect                                  (dma_avmm_s_chipselect          [3] ),
        .dma_3_avmm_s_byteenable                                  (dma_avmm_s_byteenable          [3] ),
        .dma_3_avmm_s_readdata                                    (dma_avmm_s_readdata            [3] ),
        .dma_3_avmm_s_writedata                                   (dma_avmm_s_writedata           [3] ),
        .dma_3_avmm_s_read                                        (dma_avmm_s_read                [3] ),
        .dma_3_avmm_s_write                                       (dma_avmm_s_write               [3] ),
        .dma_3_avmm_s_burstcount                                  (dma_avmm_s_burstcount          [3] ),
        .dma_3_avmm_s_readdatavalid                               (dma_avmm_s_readdatavalid       [3] ),
        .dma_3_avmm_s_waitrequest                                 (dma_avmm_s_waitrequest         [3] ),
        .dma_3_avmm_s_address                                     (dma_avmm_s_address             [3] ),
        .dma_4_avmm_s_chipselect                                  (dma_avmm_s_chipselect          [4] ),
        .dma_4_avmm_s_byteenable                                  (dma_avmm_s_byteenable          [4] ),
        .dma_4_avmm_s_readdata                                    (dma_avmm_s_readdata            [4] ),
        .dma_4_avmm_s_writedata                                   (dma_avmm_s_writedata           [4] ),
        .dma_4_avmm_s_read                                        (dma_avmm_s_read                [4] ),
        .dma_4_avmm_s_write                                       (dma_avmm_s_write               [4] ),
        .dma_4_avmm_s_burstcount                                  (dma_avmm_s_burstcount          [4] ),
        .dma_4_avmm_s_readdatavalid                               (dma_avmm_s_readdatavalid       [4] ),
        .dma_4_avmm_s_waitrequest                                 (dma_avmm_s_waitrequest         [4] ),
        .dma_4_avmm_s_address                                     (dma_avmm_s_address             [4] ),
        .dma_5_avmm_s_chipselect                                  (dma_avmm_s_chipselect          [5] ),
        .dma_5_avmm_s_byteenable                                  (dma_avmm_s_byteenable          [5] ),
        .dma_5_avmm_s_readdata                                    (dma_avmm_s_readdata            [5] ),
        .dma_5_avmm_s_writedata                                   (dma_avmm_s_writedata           [5] ),
        .dma_5_avmm_s_read                                        (dma_avmm_s_read                [5] ),
        .dma_5_avmm_s_write                                       (dma_avmm_s_write               [5] ),
        .dma_5_avmm_s_burstcount                                  (dma_avmm_s_burstcount          [5] ),
        .dma_5_avmm_s_readdatavalid                               (dma_avmm_s_readdatavalid       [5] ),
        .dma_5_avmm_s_waitrequest                                 (dma_avmm_s_waitrequest         [5] ),
        .dma_5_avmm_s_address                                     (dma_avmm_s_address             [5] ),
        .dma_6_avmm_s_chipselect                                  (dma_avmm_s_chipselect          [6] ),
        .dma_6_avmm_s_byteenable                                  (dma_avmm_s_byteenable          [6] ),
        .dma_6_avmm_s_readdata                                    (dma_avmm_s_readdata            [6] ),
        .dma_6_avmm_s_writedata                                   (dma_avmm_s_writedata           [6] ),
        .dma_6_avmm_s_read                                        (dma_avmm_s_read                [6] ),
        .dma_6_avmm_s_write                                       (dma_avmm_s_write               [6] ),
        .dma_6_avmm_s_burstcount                                  (dma_avmm_s_burstcount          [6] ),
        .dma_6_avmm_s_readdatavalid                               (dma_avmm_s_readdatavalid       [6] ),
        .dma_6_avmm_s_waitrequest                                 (dma_avmm_s_waitrequest         [6] ),
        .dma_6_avmm_s_address                                     (dma_avmm_s_address             [6] ),
        .dma_7_avmm_s_chipselect                                  (dma_avmm_s_chipselect          [7] ),
        .dma_7_avmm_s_byteenable                                  (dma_avmm_s_byteenable          [7] ),
        .dma_7_avmm_s_readdata                                    (dma_avmm_s_readdata            [7] ),
        .dma_7_avmm_s_writedata                                   (dma_avmm_s_writedata           [7] ),
        .dma_7_avmm_s_read                                        (dma_avmm_s_read                [7] ),
        .dma_7_avmm_s_write                                       (dma_avmm_s_write               [7] ),
        .dma_7_avmm_s_burstcount                                  (dma_avmm_s_burstcount          [7] ),
        .dma_7_avmm_s_readdatavalid                               (dma_avmm_s_readdatavalid       [7] ),
        .dma_7_avmm_s_waitrequest                                 (dma_avmm_s_waitrequest         [7] ),
        .dma_7_avmm_s_address                                     (dma_avmm_s_address             [7] ),
        .dma_8_avmm_s_chipselect                                  (dma_avmm_s_chipselect          [8] ),
        .dma_8_avmm_s_byteenable                                  (dma_avmm_s_byteenable          [8] ),
        .dma_8_avmm_s_readdata                                    (dma_avmm_s_readdata            [8] ),
        .dma_8_avmm_s_writedata                                   (dma_avmm_s_writedata           [8] ),
        .dma_8_avmm_s_read                                        (dma_avmm_s_read                [8] ),
        .dma_8_avmm_s_write                                       (dma_avmm_s_write               [8] ),
        .dma_8_avmm_s_burstcount                                  (dma_avmm_s_burstcount          [8] ),
        .dma_8_avmm_s_readdatavalid                               (dma_avmm_s_readdatavalid       [8] ),
        .dma_8_avmm_s_waitrequest                                 (dma_avmm_s_waitrequest         [8] ),
        .dma_8_avmm_s_address                                     (dma_avmm_s_address             [8] ),
        .dma_9_avmm_s_chipselect                                  (dma_avmm_s_chipselect          [9] ),
        .dma_9_avmm_s_byteenable                                  (dma_avmm_s_byteenable          [9] ),
        .dma_9_avmm_s_readdata                                    (dma_avmm_s_readdata            [9] ),
        .dma_9_avmm_s_writedata                                   (dma_avmm_s_writedata           [9] ),
        .dma_9_avmm_s_read                                        (dma_avmm_s_read                [9] ),
        .dma_9_avmm_s_write                                       (dma_avmm_s_write               [9] ),
        .dma_9_avmm_s_burstcount                                  (dma_avmm_s_burstcount          [9] ),
        .dma_9_avmm_s_readdatavalid                               (dma_avmm_s_readdatavalid       [9] ),
        .dma_9_avmm_s_waitrequest                                 (dma_avmm_s_waitrequest         [9] ),
        .dma_9_avmm_s_address                                     (dma_avmm_s_address             [9] ),
        .dma_10_avmm_s_chipselect                                 (dma_avmm_s_chipselect          [10]),
        .dma_10_avmm_s_byteenable                                 (dma_avmm_s_byteenable          [10]),
        .dma_10_avmm_s_readdata                                   (dma_avmm_s_readdata            [10]),
        .dma_10_avmm_s_writedata                                  (dma_avmm_s_writedata           [10]),
        .dma_10_avmm_s_read                                       (dma_avmm_s_read                [10]),
        .dma_10_avmm_s_write                                      (dma_avmm_s_write               [10]),
        .dma_10_avmm_s_burstcount                                 (dma_avmm_s_burstcount          [10]),
        .dma_10_avmm_s_readdatavalid                              (dma_avmm_s_readdatavalid       [10]),
        .dma_10_avmm_s_waitrequest                                (dma_avmm_s_waitrequest         [10]),
        .dma_10_avmm_s_address                                    (dma_avmm_s_address             [10]),
        .dma_11_avmm_s_chipselect                                 (dma_avmm_s_chipselect          [11]),
        .dma_11_avmm_s_byteenable                                 (dma_avmm_s_byteenable          [11]),
        .dma_11_avmm_s_readdata                                   (dma_avmm_s_readdata            [11]),
        .dma_11_avmm_s_writedata                                  (dma_avmm_s_writedata           [11]),
        .dma_11_avmm_s_read                                       (dma_avmm_s_read                [11]),
        .dma_11_avmm_s_write                                      (dma_avmm_s_write               [11]),
        .dma_11_avmm_s_burstcount                                 (dma_avmm_s_burstcount          [11]),
        .dma_11_avmm_s_readdatavalid                              (dma_avmm_s_readdatavalid       [11]),
        .dma_11_avmm_s_waitrequest                                (dma_avmm_s_waitrequest         [11]),
        .dma_11_avmm_s_address                                    (dma_avmm_s_address             [11]),
        .dma_12_avmm_s_chipselect                                 (dma_avmm_s_chipselect          [12]),
        .dma_12_avmm_s_byteenable                                 (dma_avmm_s_byteenable          [12]),
        .dma_12_avmm_s_readdata                                   (dma_avmm_s_readdata            [12]),
        .dma_12_avmm_s_writedata                                  (dma_avmm_s_writedata           [12]),
        .dma_12_avmm_s_read                                       (dma_avmm_s_read                [12]),
        .dma_12_avmm_s_write                                      (dma_avmm_s_write               [12]),
        .dma_12_avmm_s_burstcount                                 (dma_avmm_s_burstcount          [12]),
        .dma_12_avmm_s_readdatavalid                              (dma_avmm_s_readdatavalid       [12]),
        .dma_12_avmm_s_waitrequest                                (dma_avmm_s_waitrequest         [12]),
        .dma_12_avmm_s_address                                    (dma_avmm_s_address             [12]),
        .dma_13_avmm_s_chipselect                                 (dma_avmm_s_chipselect          [13]),
        .dma_13_avmm_s_byteenable                                 (dma_avmm_s_byteenable          [13]),
        .dma_13_avmm_s_readdata                                   (dma_avmm_s_readdata            [13]),
        .dma_13_avmm_s_writedata                                  (dma_avmm_s_writedata           [13]),
        .dma_13_avmm_s_read                                       (dma_avmm_s_read                [13]),
        .dma_13_avmm_s_write                                      (dma_avmm_s_write               [13]),
        .dma_13_avmm_s_burstcount                                 (dma_avmm_s_burstcount          [13]),
        .dma_13_avmm_s_readdatavalid                              (dma_avmm_s_readdatavalid       [13]),
        .dma_13_avmm_s_waitrequest                                (dma_avmm_s_waitrequest         [13]),
        .dma_13_avmm_s_address                                    (dma_avmm_s_address             [13]),
        .dma_14_avmm_s_chipselect                                 (dma_avmm_s_chipselect          [14]),
        .dma_14_avmm_s_byteenable                                 (dma_avmm_s_byteenable          [14]),
        .dma_14_avmm_s_readdata                                   (dma_avmm_s_readdata            [14]),
        .dma_14_avmm_s_writedata                                  (dma_avmm_s_writedata           [14]),
        .dma_14_avmm_s_read                                       (dma_avmm_s_read                [14]),
        .dma_14_avmm_s_write                                      (dma_avmm_s_write               [14]),
        .dma_14_avmm_s_burstcount                                 (dma_avmm_s_burstcount          [14]),
        .dma_14_avmm_s_readdatavalid                              (dma_avmm_s_readdatavalid       [14]),
        .dma_14_avmm_s_waitrequest                                (dma_avmm_s_waitrequest         [14]),
        .dma_14_avmm_s_address                                    (dma_avmm_s_address             [14]),
        .dma_15_avmm_s_chipselect                                 (dma_avmm_s_chipselect          [15]),
        .dma_15_avmm_s_byteenable                                 (dma_avmm_s_byteenable          [15]),
        .dma_15_avmm_s_readdata                                   (dma_avmm_s_readdata            [15]),
        .dma_15_avmm_s_writedata                                  (dma_avmm_s_writedata           [15]),
        .dma_15_avmm_s_read                                       (dma_avmm_s_read                [15]),
        .dma_15_avmm_s_write                                      (dma_avmm_s_write               [15]),
        .dma_15_avmm_s_burstcount                                 (dma_avmm_s_burstcount          [15]),
        .dma_15_avmm_s_readdatavalid                              (dma_avmm_s_readdatavalid       [15]),
        .dma_15_avmm_s_waitrequest                                (dma_avmm_s_waitrequest         [15]),
        .dma_15_avmm_s_address                                    (dma_avmm_s_address             [15]),
        .user_msi_avmm_s_address                                  (msix_avmm_s_address                ),
        .user_msi_avmm_s_burstcount                               (msix_avmm_s_burstcount             ),
        .user_msi_avmm_s_byteenable                               (msix_avmm_s_byteenable             ),
        .user_msi_avmm_s_chipselect                               (msix_avmm_s_chipselect             ),
        .user_msi_avmm_s_read                                     (msix_avmm_s_read                   ),
        .user_msi_avmm_s_readdata                                 (msix_avmm_s_readdata               ),
        .user_msi_avmm_s_readdatavalid                            (msix_avmm_s_readdatavalid          ),
        .user_msi_avmm_s_waitrequest                              (msix_avmm_s_waitrequest            ),
        .user_msi_avmm_s_write                                    (msix_avmm_s_write                  ),
        .user_msi_avmm_s_writedata                                (msix_avmm_s_writedata              ),
        .msix_avmm_m_address                                      (msix_avmm_m_address                ),
        .msix_avmm_m_burstcount                                   (msix_avmm_m_burstcount             ),
        .msix_avmm_m_chipselect                                   (msix_avmm_m_chipselect             ),
        .msix_avmm_m_byteenable                                   (msix_avmm_m_byteenable             ),
        .msix_avmm_m_read                                         (msix_avmm_m_read                   ),
        .msix_avmm_m_readdata                                     (msix_avmm_m_readdata               ),
        .msix_avmm_m_readdatavalid                                (msix_avmm_m_readdatavalid          ),
        .msix_avmm_m_waitrequest                                  (msix_avmm_m_waitrequest            ),
        .msix_avmm_m_write                                        (msix_avmm_m_write                  ),
        .msix_avmm_m_writedata                                    (msix_avmm_m_writedata              ),
        .pcie_cv_hip_avmm_0_hip_ctrl_test_in                      (32'b00000000000000000000000010001100),
        .pcie_cv_hip_avmm_0_hip_ctrl_simu_mode_pipe               ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_sim_pipe_pclk_in             ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_phystatus0                   ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_phystatus1                   ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_phystatus2                   ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_phystatus3                   ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxdata0                      ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxdata1                      ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxdata2                      ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxdata3                      ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxdatak0                     ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxdatak1                     ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxdatak2                     ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxdatak3                     ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxelecidle0                  ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxelecidle1                  ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxelecidle2                  ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxelecidle3                  ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxstatus0                    ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxstatus1                    ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxstatus2                    ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxstatus3                    ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxvalid0                     ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxvalid1                     ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxvalid2                     ('0),
        .pcie_cv_hip_avmm_0_hip_pipe_rxvalid3                     ('0),
        .pcie_cv_hip_avmm_0_hip_serial_rx_in0                     (PCIE_RX_p[0]),
        .pcie_cv_hip_avmm_0_hip_serial_rx_in1                     (PCIE_RX_p[1]),
        .pcie_cv_hip_avmm_0_hip_serial_rx_in2                     (PCIE_RX_p[2]),
        .pcie_cv_hip_avmm_0_hip_serial_rx_in3                     (PCIE_RX_p[3]),
        .pcie_cv_hip_avmm_0_hip_serial_tx_out0                    (PCIE_TX_p[0]),
        .pcie_cv_hip_avmm_0_hip_serial_tx_out1                    (PCIE_TX_p[1]),
        .pcie_cv_hip_avmm_0_hip_serial_tx_out2                    (PCIE_TX_p[2]),
        .pcie_cv_hip_avmm_0_hip_serial_tx_out3                    (PCIE_TX_p[3]),
        .pcie_cv_hip_avmm_0_intx_interface_intx_req               ('0),
        .pcie_cv_hip_avmm_0_npor_npor                             (clock_125_rstn_rr),
        .pcie_cv_hip_avmm_0_npor_pin_perst                        (PCIE_PERST_n),
        .pcie_cv_hip_avmm_0_reconfig_busy_reconfig_busy           ('0),
        .pcie_cv_hip_avmm_0_reconfig_to_xcvr_reconfig_to_xcvr     ('0),
        .pcie_cv_hip_avmm_0_refclk_clk                            (PCIE_REFCLK_p)
    );


endmodule