module avmm_dma_task_transport #(
    parameter DMA_CHANNEL_COUNT = 16,
    
    parameter DMA_BYTES_WIDTH   = 22,
    parameter DMA_OFFFSET_WIDTH = 22,

    parameter DMA_TQ_DEPTH      = 16,

    parameter DMA_TQ_ADDR_WIDTH       = $clog2(DMA_TQ_DEPTH)                                  ,
    parameter DMA_BURST_WIDTH         = DMA_BYTES_WIDTH - 4                                   ,
    parameter DMA_CHANNEL_COUNT_WIDTH = DMA_CHANNEL_COUNT == 1 ? 1 : $clog2(DMA_CHANNEL_COUNT)
) (
    input  logic                               clk                                   ,
    input  logic                               rst_n                                 ,

    input  logic                               dma_task_valid_i                      ,
    output logic                               dma_task_ready_o                      ,
    input  logic [DMA_CHANNEL_COUNT_WIDTH-1:0] dma_task_channel_i                    ,
    input  logic [DMA_BURST_WIDTH-1:0]         dma_task_burst_i                      ,
    input  logic [DMA_OFFFSET_WIDTH-1:0]       dma_task_offset_i                     ,
    input  logic                               dma_task_write_i                      ,

    output logic [DMA_TQ_ADDR_WIDTH:0]         dmawr_task_free_o                     ,
    output logic [DMA_TQ_ADDR_WIDTH:0]         dmard_task_free_o                     ,

    output logic [DMA_CHANNEL_COUNT-1:0]       dma_task_valid_o                      ,
    input  logic [DMA_CHANNEL_COUNT-1:0]       dma_task_ready_i                      ,
    output logic [DMA_BURST_WIDTH-1:0]         dma_task_burst_o   [DMA_CHANNEL_COUNT],
    output logic [DMA_OFFFSET_WIDTH-1:0]       dma_task_offset_o  [DMA_CHANNEL_COUNT],
    output logic [DMA_CHANNEL_COUNT-1:0]       dma_task_write_o                      
);

    logic dmawr_task_ready, dmard_task_ready;

    logic                               dmawr_task_valid_rd  , dmard_task_valid_rd  ;
    logic                               dmawr_task_ready_rd  , dmard_task_ready_rd  ;
    logic [DMA_CHANNEL_COUNT_WIDTH-1:0] dmawr_task_channel_rd, dmard_task_channel_rd;
    logic [DMA_BURST_WIDTH-1:0]         dmawr_task_burst_rd  , dmard_task_burst_rd  ;
    logic [DMA_OFFFSET_WIDTH-1:0]       dmawr_task_offset_rd , dmard_task_offset_rd ;
    logic                               dmawr_task_write_rd  , dmard_task_write_rd  ;

    logic [DMA_CHANNEL_COUNT-1:0] dmawr_task_valid_demuxed                     ;
    logic [DMA_CHANNEL_COUNT-1:0] dmawr_task_ready_demuxed                     ;
    logic [DMA_BURST_WIDTH-1:0]   dmawr_task_burst_demuxed  [DMA_CHANNEL_COUNT];
    logic [DMA_OFFFSET_WIDTH-1:0] dmawr_task_offset_demuxed [DMA_CHANNEL_COUNT];
    logic [DMA_CHANNEL_COUNT-1:0] dmawr_task_write_demuxed                     ;
    
    logic [DMA_CHANNEL_COUNT-1:0] dmard_task_valid_demuxed                     ;
    logic [DMA_CHANNEL_COUNT-1:0] dmard_task_ready_demuxed                     ;
    logic [DMA_BURST_WIDTH-1:0]   dmard_task_burst_demuxed  [DMA_CHANNEL_COUNT];
    logic [DMA_OFFFSET_WIDTH-1:0] dmard_task_offset_demuxed [DMA_CHANNEL_COUNT];
    logic [DMA_CHANNEL_COUNT-1:0] dmard_task_write_demuxed                     ;

    assign dma_task_ready_o = dma_task_write_i ? dmawr_task_ready : dmard_task_ready;

    // DMAWR
    stream_fifo #(
        .DATA_WIDTH (1 + DMA_CHANNEL_COUNT_WIDTH + DMA_BURST_WIDTH + DMA_OFFFSET_WIDTH),
        .FIFO_DEPTH (DMA_TQ_DEPTH)
    ) u_stream_fifo_dmawr_tasks (
        .ACLK    (clk                                                                                    ),
        .ARESETn (rst_n                                                                                  ),

        .data_i  ({dma_task_write_i, dma_task_channel_i, dma_task_burst_i, dma_task_offset_i}            ),
        .valid_i (dma_task_valid_i & dma_task_write_i                                                    ),
        .ready_o (dmawr_task_ready                                                                       ),
        .free_o  (dmawr_task_free_o                                                                      ),

        .data_o  ({dmawr_task_write_rd, dmawr_task_channel_rd, dmawr_task_burst_rd, dmawr_task_offset_rd}),
        .valid_o (dmawr_task_valid_rd                                                                    ),
        .ready_i (dmawr_task_ready_rd                                                                    ),
        .count_o (                                                                                       ) // NC
    );

    avmm_dma_task_demux #(
       .DMA_CHANNEL_COUNT (DMA_CHANNEL_COUNT),
       .DMA_OFFFSET_WIDTH (DMA_OFFFSET_WIDTH),
       .DMA_BYTES_WIDTH   (DMA_BYTES_WIDTH  )
    ) u_avmm_dmawr_task_demux (
        .clk                   (clk                       ),
        .rst_n                 (rst_n                     ),

        .in_dma_task_valid_i   (dmawr_task_valid_rd       ),
        .in_dma_task_ready_o   (dmawr_task_ready_rd       ),
        .in_dma_task_channel_i (dmawr_task_channel_rd     ),
        .in_dma_task_burst_i   (dmawr_task_burst_rd       ),
        .in_dma_task_offset_i  (dmawr_task_offset_rd      ),
        .in_dma_task_write_i   (dmawr_task_write_rd       ),

        .out_dma_task_valid_o  (dmawr_task_valid_demuxed  ),
        .out_dma_task_ready_i  (dmawr_task_ready_demuxed  ),
        .out_dma_task_burst_o  (dmawr_task_burst_demuxed  ),
        .out_dma_task_offset_o (dmawr_task_offset_demuxed ),
        .out_dma_task_write_o  (dmawr_task_write_demuxed  )
    );
    
    // DMARD
    stream_fifo #(
        .DATA_WIDTH (1 + DMA_CHANNEL_COUNT_WIDTH + DMA_BURST_WIDTH + DMA_OFFFSET_WIDTH),
        .FIFO_DEPTH (DMA_TQ_DEPTH)
    ) u_stream_fifo_dmard_tasks (
        .ACLK    (clk                                                                                    ),
        .ARESETn (rst_n                                                                                  ),

        .data_i  ({dma_task_write_i, dma_task_channel_i, dma_task_burst_i, dma_task_offset_i}            ),
        .valid_i (dma_task_valid_i & ~dma_task_write_i                                                   ),
        .ready_o (dmard_task_ready                                                                       ),
        .free_o  (dmard_task_free_o                                                                      ),

        .data_o  ({dmard_task_write_rd, dmard_task_channel_rd, dmard_task_burst_rd, dmard_task_offset_rd}),
        .valid_o (dmard_task_valid_rd                                                                    ),
        .ready_i (dmard_task_ready_rd                                                                    ),
        .count_o (                                                                                       ) // NC
    );

    avmm_dma_task_demux #(
       .DMA_CHANNEL_COUNT (DMA_CHANNEL_COUNT),
       .DMA_OFFFSET_WIDTH (DMA_OFFFSET_WIDTH),
       .DMA_BYTES_WIDTH   (DMA_BYTES_WIDTH  )
    ) u_avmm_dmard_task_demux (
        .clk                   (clk                       ),
        .rst_n                 (rst_n                     ),

        .in_dma_task_valid_i   (dmard_task_valid_rd       ),
        .in_dma_task_ready_o   (dmard_task_ready_rd       ),
        .in_dma_task_channel_i (dmard_task_channel_rd     ),
        .in_dma_task_burst_i   (dmard_task_burst_rd       ),
        .in_dma_task_offset_i  (dmard_task_offset_rd      ),
        .in_dma_task_write_i   (dmard_task_write_rd       ),

        .out_dma_task_valid_o  (dmard_task_valid_demuxed  ),
        .out_dma_task_ready_i  (dmard_task_ready_demuxed  ),
        .out_dma_task_burst_o  (dmard_task_burst_demuxed  ),
        .out_dma_task_offset_o (dmard_task_offset_demuxed ),
        .out_dma_task_write_o  (dmard_task_write_demuxed  )
    );

    generate
        genvar i;

        for (i = 0; i < DMA_CHANNEL_COUNT; i++) begin : task_funnel_arb
            logic [DMA_BURST_WIDTH + DMA_OFFFSET_WIDTH + 1 - 1:0] data_wr [2];
            logic [1:0] valid_wr, ready_wr;

            logic [DMA_BURST_WIDTH + DMA_OFFFSET_WIDTH + 1 - 1:0] data_rd;
            logic valid_rd, ready_rd;
            
            assign data_wr [0] = {dmawr_task_burst_demuxed[i], dmawr_task_offset_demuxed[i], dmawr_task_write_demuxed[i]};
            assign valid_wr[0] = dmawr_task_valid_demuxed[i];
            assign dmawr_task_ready_demuxed[i] = ready_wr[0];

            assign data_wr [1] = {dmard_task_burst_demuxed[i], dmard_task_offset_demuxed[i], dmard_task_write_demuxed[i]};
            assign valid_wr[1] = dmard_task_valid_demuxed[i];
            assign dmard_task_ready_demuxed[i] = ready_wr[1];

            assign {dma_task_burst_o[i], dma_task_offset_o[i], dma_task_write_o[i]} = data_rd ;
            assign dma_task_valid_o[i] = valid_rd;
            assign ready_rd = dma_task_ready_i[i];
            
            stream_arbiter #(
                .DATA_WIDTH (DMA_BURST_WIDTH + DMA_OFFFSET_WIDTH + 1),
                .INPUT_NUM  (2 ),
                .AWAIT_HS   (0 )
            ) u_stream_arbiter (
                .ACLK    (clk     ),
                .ARESETn (rst_n   ),

                .data_i  (data_wr ),
                .valid_i (valid_wr),
                .ready_o (ready_wr),

                .data_o  (data_rd ),
                .valid_o (valid_rd),
                .ready_i (ready_rd),
                .sel_o   (        ) // NC
            );
        end
    endgenerate
    
endmodule