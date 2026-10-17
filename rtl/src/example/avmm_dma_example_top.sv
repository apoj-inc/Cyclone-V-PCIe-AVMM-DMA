module avmm_dma_example_top(

    output                          FAN_CTRL,
    
    inout                           PCIE_PERST_n,
    input                           PCIE_REFCLK_p,
    input              [3:0]        PCIE_RX_p,
    output             [3:0]        PCIE_TX_p
);

    parameter     DMA_ECHODEVICE                        = 0         ;
    parameter     DMA_CHANNEL_COUNT                     = 8         ;

    parameter     DMA_BYTES_WIDTH                       = 22        ;
    parameter     DMA_OFFFSET_WIDTH                     = 22        ;

    parameter int DMA_WORD_BYTES    [DMA_CHANNEL_COUNT] = '{8 {16 }};
    parameter int DMA_WQ_DEPTH      [DMA_CHANNEL_COUNT] = '{8 {64 }};
    parameter int DMA_RQ_DEPTH      [DMA_CHANNEL_COUNT] = '{8 {64 }};
    parameter int DMA_TQ_DEPTH                          = 8         ;

    parameter int MAX_WQ_DEPTH                          = 64        ;
    parameter int MAX_RQ_DEPTH                          = 64        ;

    parameter     BAR_DATA_WIDTH                        = 128       ;
    parameter     BAR_ADDR_WIDTH                        = 12        ;

    parameter     TX_DATA_WIDTH                         = 128       ;
    parameter     TX_ADDR_WIDTH                         = 64        ;
    parameter     TX_BURST_WIDTH                        = 6         ;
    
    parameter BAR_DATA_BYTES    = BAR_DATA_WIDTH / 8  ;
    parameter TX_DATA_BYTES     = TX_DATA_WIDTH / 8   ;
    parameter DMA_WQ_ADDR_WIDTH = $clog2(MAX_WQ_DEPTH);
    parameter DMA_RQ_ADDR_WIDTH = $clog2(MAX_RQ_DEPTH);

    logic                       dma_wrdata_valid [DMA_CHANNEL_COUNT];
    logic                       dma_wrdata_ready [DMA_CHANNEL_COUNT];
    logic [DMA_WQ_ADDR_WIDTH:0] dma_wrdata_count [DMA_CHANNEL_COUNT];
    logic [TX_DATA_WIDTH-1:0]   dma_wrdata_data  [DMA_CHANNEL_COUNT];

    logic                       dma_rddata_valid [DMA_CHANNEL_COUNT];
    logic                       dma_rddata_ready [DMA_CHANNEL_COUNT];
    logic [DMA_RQ_ADDR_WIDTH:0] dma_rddata_free  [DMA_CHANNEL_COUNT];
    logic [TX_DATA_WIDTH-1:0]   dma_rddata_data  [DMA_CHANNEL_COUNT];

    logic                       user_csr_s_chipselect   ;
    logic [BAR_DATA_BYTES-1:0]  user_csr_s_byteenable   ;
    logic [BAR_DATA_WIDTH-1:0]  user_csr_s_readdata     ;
    logic [BAR_DATA_WIDTH-1:0]  user_csr_s_writedata    ;
    logic                       user_csr_s_read         ;
    logic                       user_csr_s_write        ;
    logic                       user_csr_s_readdatavalid;
    logic                       user_csr_s_waitrequest  ;
    logic [BAR_ADDR_WIDTH:0]    user_csr_s_address      ;

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
        .BAR_ADDR_WIDTH    (BAR_ADDR_WIDTH+1 )
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

    avmm_dma_toplevel #(
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
    ) u_avmm_dma_toplevel (

        .FAN_CTRL                (FAN_CTRL                ),

        .PCIE_PERST_n            (PCIE_PERST_n            ),
        .PCIE_REFCLK_p           (PCIE_REFCLK_p           ),
        .PCIE_RX_p               (PCIE_RX_p               ),
        .PCIE_TX_p               (PCIE_TX_p               ),

        .dma_wrdata_valid_i      (dma_wrdata_valid        ),
        .dma_wrdata_ready_o      (dma_wrdata_ready        ),
        .dma_wrdata_count_i      (dma_wrdata_count        ),
        .dma_wrdata_data_i       (dma_wrdata_data         ),

        .dma_rddata_valid_o      (dma_rddata_valid        ),
        .dma_rddata_ready_i      (dma_rddata_ready        ),
        .dma_rddata_free_i       (dma_rddata_free         ),
        .dma_rddata_data_o       (dma_rddata_data         ),

        
        .env_csr_m_chipselect    (user_csr_s_chipselect   ),
        .env_csr_m_byteenable    (user_csr_s_byteenable   ),
        .env_csr_m_readdata      (user_csr_s_readdata     ),
        .env_csr_m_writedata     (user_csr_s_writedata    ),
        .env_csr_m_read          (user_csr_s_read         ),
        .env_csr_m_write         (user_csr_s_write        ),
        .env_csr_m_readdatavalid (user_csr_s_readdatavalid),
        .env_csr_m_waitrequest   (user_csr_s_waitrequest  ),
        .env_csr_m_address       (user_csr_s_address      ),

        .user_irq_i              (user_irq                ),

        .dma_resetn_o            (dma_resetn              )
    );

endmodule