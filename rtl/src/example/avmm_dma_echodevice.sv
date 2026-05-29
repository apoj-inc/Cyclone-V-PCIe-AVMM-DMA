module avmm_dma_echodevice #(
    parameter     DMA_CHANNEL_COUNT                     = 16         ,

    parameter     DMA_BYTES_WIDTH                       = 22         ,
    parameter     DMA_OFFFSET_WIDTH                     = 22         ,

    parameter int DMA_WORD_BYTES    [DMA_CHANNEL_COUNT] = '{16{16  }},
    parameter int DMA_WQ_DEPTH      [DMA_CHANNEL_COUNT] = '{16{1024}},
    parameter int DMA_RQ_DEPTH      [DMA_CHANNEL_COUNT] = '{16{1024}},
    parameter int DMA_TQ_DEPTH                          = 16         ,

    parameter int MAX_WQ_DEPTH                          = 1024       ,
    parameter int MAX_RQ_DEPTH                          = 1024       ,
    
    parameter     BAR_DATA_WIDTH                        = 128        ,
    parameter     BAR_ADDR_WIDTH                        = 12         ,

    parameter     TX_DATA_WIDTH                         = 128        ,
    parameter     TX_ADDR_WIDTH                         = 12         ,
    parameter     TX_BURST_WIDTH                        = 6          ,
    
    parameter BAR_DATA_BYTES    = BAR_DATA_WIDTH / 8  ,
    parameter TX_DATA_BYTES     = TX_DATA_WIDTH / 8   ,
    parameter DMA_WQ_ADDR_WIDTH = $clog2(MAX_WQ_DEPTH),
    parameter DMA_RQ_ADDR_WIDTH = $clog2(MAX_RQ_DEPTH)
) (
    input  logic                       clk                                           ,
    input  logic                       rst_n                                         ,

    // DMA CSR AVMM slave bus
    input  logic                       csr_s_chipselect                              ,
    input  logic [BAR_DATA_BYTES-1:0]  csr_s_byteenable                              ,
    output logic [BAR_DATA_WIDTH-1:0]  csr_s_readdata                                ,
    input  logic [BAR_DATA_WIDTH-1:0]  csr_s_writedata                               ,
    input  logic                       csr_s_read                                    ,
    input  logic                       csr_s_write                                   ,
    output logic                       csr_s_readdatavalid                           ,
    output logic                       csr_s_waitrequest                             ,
    input  logic [BAR_ADDR_WIDTH-1:0]  csr_s_address                                 ,

    // MSI-X AVMM slave bus
    input  logic                       msix_s_chipselect                             ,
    input  logic [BAR_DATA_BYTES-1:0]  msix_s_byteenable                             ,
    output logic [BAR_DATA_WIDTH-1:0]  msix_s_readdata                               ,
    input  logic [BAR_DATA_WIDTH-1:0]  msix_s_writedata                              ,
    input  logic                       msix_s_read                                   ,
    input  logic                       msix_s_write                                  ,
    output logic                       msix_s_readdatavalid                          ,
    output logic                       msix_s_waitrequest                            ,
    input  logic [BAR_ADDR_WIDTH-1:0]  msix_s_address                                ,

    // Decoder AVMM slave bus
    input  logic                       dec_s_chipselect                              ,
    input  logic [BAR_DATA_BYTES-1:0]  dec_s_byteenable                              ,
    output logic [BAR_DATA_WIDTH-1:0]  dec_s_readdata                                ,
    input  logic [BAR_DATA_WIDTH-1:0]  dec_s_writedata                               ,
    input  logic                       dec_s_read                                    ,
    input  logic                       dec_s_write                                   ,
    output logic                       dec_s_readdatavalid                           ,
    output logic                       dec_s_waitrequest                             ,
    input  logic [BAR_ADDR_WIDTH-1:0]  dec_s_address                                 ,

    // User CSR AVMM slave bus
    input  logic                       user_csr_s_chipselect                         ,
    input  logic [BAR_DATA_BYTES-1:0]  user_csr_s_byteenable                         ,
    output logic [BAR_DATA_WIDTH-1:0]  user_csr_s_readdata                           ,
    input  logic [BAR_DATA_WIDTH-1:0]  user_csr_s_writedata                          ,
    input  logic                       user_csr_s_read                               ,
    input  logic                       user_csr_s_write                              ,
    output logic                       user_csr_s_readdatavalid                      ,
    output logic                       user_csr_s_waitrequest                        ,
    input  logic [BAR_ADDR_WIDTH-1:0]  user_csr_s_address                            ,

    // User MSIX AVMM master bus
    output logic                       user_msix_m_chipselect                        ,
    output logic [TX_DATA_BYTES-1:0]   user_msix_m_byteenable                        ,
    input  logic [TX_DATA_WIDTH-1:0]   user_msix_m_readdata                          ,
    output logic [TX_DATA_WIDTH-1:0]   user_msix_m_writedata                         ,
    output logic                       user_msix_m_read                              ,
    output logic                       user_msix_m_write                             ,
    output logic [TX_BURST_WIDTH-1:0]  user_msix_m_burstcount                        ,
    input  logic                       user_msix_m_readdatavalid                     ,
    input  logic                       user_msix_m_waitrequest                       ,
    output logic [TX_ADDR_WIDTH-1:0]   user_msix_m_address                           ,

    // TX AVMM master bus
    output logic                       tx_chipselect              [DMA_CHANNEL_COUNT],
    output logic [TX_DATA_BYTES-1:0]   tx_byteenable              [DMA_CHANNEL_COUNT],
    input  logic [TX_DATA_WIDTH-1:0]   tx_readdata                [DMA_CHANNEL_COUNT],
    output logic [TX_DATA_WIDTH-1:0]   tx_writedata               [DMA_CHANNEL_COUNT],
    output logic                       tx_read                    [DMA_CHANNEL_COUNT],
    output logic                       tx_write                   [DMA_CHANNEL_COUNT],
    output logic [TX_BURST_WIDTH-1:0]  tx_burstcount              [DMA_CHANNEL_COUNT],
    input  logic                       tx_readdatavalid           [DMA_CHANNEL_COUNT],
    input  logic                       tx_waitrequest             [DMA_CHANNEL_COUNT],
    output logic [TX_ADDR_WIDTH-1:0]   tx_address                 [DMA_CHANNEL_COUNT]
);

    logic                       dma_wrdata_valid [DMA_CHANNEL_COUNT];
    logic                       dma_wrdata_ready [DMA_CHANNEL_COUNT];
    logic [DMA_WQ_ADDR_WIDTH:0] dma_wrdata_count [DMA_CHANNEL_COUNT];
    logic [TX_DATA_WIDTH-1:0]   dma_wrdata_data  [DMA_CHANNEL_COUNT];

    logic                       dma_rddata_valid [DMA_CHANNEL_COUNT];
    logic                       dma_rddata_ready [DMA_CHANNEL_COUNT];
    logic [DMA_RQ_ADDR_WIDTH:0] dma_rddata_free  [DMA_CHANNEL_COUNT];
    logic [TX_DATA_WIDTH-1:0]   dma_rddata_data  [DMA_CHANNEL_COUNT];

    logic [DMA_CHANNEL_COUNT-1:0] user_irq;

    logic dma_resetn;

    generate
        genvar i;

        for (i = 0; i < DMA_CHANNEL_COUNT; i++) begin : echo_fifos

            logic [TX_DATA_WIDTH-1:0] file_wr_data ;
            logic                     file_wr_valid;
            logic                     file_wr_ready;

            logic [TX_DATA_WIDTH-1:0] file_rd_data ;
            logic                     file_rd_valid;
            logic                     file_rd_ready;

            stream_fifo #(
                .DATA_WIDTH (TX_DATA_WIDTH  ),
                .FIFO_DEPTH (DMA_RQ_DEPTH[i])
            ) fifo_rd (
                .ACLK    (clk  ),
                .ARESETn (dma_resetn),

                .data_i  (dma_rddata_data [i]),
                .valid_i (dma_rddata_valid[i]),
                .ready_o (dma_rddata_ready[i]),
                .free_o  (dma_rddata_free [i]),

                .data_o  (file_wr_data ),
                .valid_o (file_wr_valid),
                .ready_i (file_wr_ready),
                .count_o ()
            );
            
            stream_fifo #(
                .DATA_WIDTH (TX_DATA_WIDTH  ),
                .FIFO_DEPTH (1024)
            ) file (
                .ACLK    (clk  ),
                .ARESETn (dma_resetn),

                .data_i  (file_wr_data ),
                .valid_i (file_wr_valid),
                .ready_o (file_wr_ready),
                .free_o  (),

                .data_o  (file_rd_data ),
                .valid_o (file_rd_valid),
                .ready_i (file_rd_ready),
                .count_o ()
            );

            stream_fifo #(
                .DATA_WIDTH (TX_DATA_WIDTH  ),
                .FIFO_DEPTH (DMA_WQ_DEPTH[i])
            ) fifo_wr (
                .ACLK    (clk  ),
                .ARESETn (dma_resetn),

                .data_i  (file_rd_data ),
                .valid_i (file_rd_valid),
                .ready_o (file_rd_ready),
                .free_o  (),

                .data_o  (dma_wrdata_data [i]),
                .valid_o (dma_wrdata_valid[i]),
                .ready_i (dma_wrdata_ready[i]),
                .count_o (dma_wrdata_count[i])
            );
        end
    endgenerate

    external_csr #(
        .DMA_CHANNEL_COUNT (DMA_CHANNEL_COUNT),

        .BAR_DATA_WIDTH    (BAR_DATA_WIDTH   ),
        .BAR_ADDR_WIDTH    (BAR_ADDR_WIDTH   )
    ) example_csr (
        .clk                  (clk  ),
        .rst_n                (rst_n),

        .avmm_s_chipselect    (user_csr_s_chipselect   ),
        .avmm_s_byteenable    (user_csr_s_byteenable   ),
        .avmm_s_readdata      (user_csr_s_readdata     ),
        .avmm_s_writedata     (user_csr_s_writedata    ),
        .avmm_s_read          (user_csr_s_read         ),
        .avmm_s_write         (user_csr_s_write        ),
        .avmm_s_readdatavalid (user_csr_s_readdatavalid),
        .avmm_s_waitrequest   (user_csr_s_waitrequest  ),
        .avmm_s_address       (user_csr_s_address      ),

        .user_irq_o           (user_irq)
    );

    avmm_dma_top #(
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
    ) u_avmm_dma_top (
        .clk                       (clk                      ),
        .rst_n                     (rst_n                    ),

        .csr_s_chipselect          (csr_s_chipselect         ),
        .csr_s_byteenable          (csr_s_byteenable         ),
        .csr_s_readdata            (csr_s_readdata           ),
        .csr_s_writedata           (csr_s_writedata          ),
        .csr_s_read                (csr_s_read               ),
        .csr_s_write               (csr_s_write              ),
        .csr_s_readdatavalid       (csr_s_readdatavalid      ),
        .csr_s_waitrequest         (csr_s_waitrequest        ),
        .csr_s_address             (csr_s_address            ),

        .msix_s_chipselect         (msix_s_chipselect        ),
        .msix_s_byteenable         (msix_s_byteenable        ),
        .msix_s_readdata           (msix_s_readdata          ),
        .msix_s_writedata          (msix_s_writedata         ),
        .msix_s_read               (msix_s_read              ),
        .msix_s_write              (msix_s_write             ),
        .msix_s_readdatavalid      (msix_s_readdatavalid     ),
        .msix_s_waitrequest        (msix_s_waitrequest       ),
        .msix_s_address            (msix_s_address           ),

        .dec_s_chipselect          (dec_s_chipselect         ),
        .dec_s_byteenable          (dec_s_byteenable         ),
        .dec_s_readdata            (dec_s_readdata           ),
        .dec_s_writedata           (dec_s_writedata          ),
        .dec_s_read                (dec_s_read               ),
        .dec_s_write               (dec_s_write              ),
        .dec_s_readdatavalid       (dec_s_readdatavalid      ),
        .dec_s_waitrequest         (dec_s_waitrequest        ),
        .dec_s_address             (dec_s_address            ),

        .user_irq_i                (user_irq                 ),

        .user_msix_m_chipselect    (user_msix_m_chipselect   ),
        .user_msix_m_byteenable    (user_msix_m_byteenable   ),
        .user_msix_m_readdata      (user_msix_m_readdata     ),
        .user_msix_m_writedata     (user_msix_m_writedata    ),
        .user_msix_m_read          (user_msix_m_read         ),
        .user_msix_m_write         (user_msix_m_write        ),
        .user_msix_m_burstcount    (user_msix_m_burstcount   ),
        .user_msix_m_readdatavalid (user_msix_m_readdatavalid),
        .user_msix_m_waitrequest   (user_msix_m_waitrequest  ),
        .user_msix_m_address       (user_msix_m_address      ),

        .tx_chipselect             (tx_chipselect            ),
        .tx_byteenable             (tx_byteenable            ),
        .tx_readdata               (tx_readdata              ),
        .tx_writedata              (tx_writedata             ),
        .tx_read                   (tx_read                  ),
        .tx_write                  (tx_write                 ),
        .tx_burstcount             (tx_burstcount            ),
        .tx_readdatavalid          (tx_readdatavalid         ),
        .tx_waitrequest            (tx_waitrequest           ),
        .tx_address                (tx_address               ),

        .dma_wrdata_valid_i        (dma_wrdata_valid         ),
        .dma_wrdata_ready_o        (dma_wrdata_ready         ),
        .dma_wrdata_count_i        (dma_wrdata_count         ),
        .dma_wrdata_data_i         (dma_wrdata_data          ),

        .dma_rddata_valid_o        (dma_rddata_valid         ),
        .dma_rddata_ready_i        (dma_rddata_ready         ),
        .dma_rddata_free_i         (dma_rddata_free          ),
        .dma_rddata_data_o         (dma_rddata_data          ),

        .dma_resetn_o              (dma_resetn               )
    );
    
endmodule