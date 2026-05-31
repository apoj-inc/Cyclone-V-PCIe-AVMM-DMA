module avmm_dma_dmic #(
    parameter MSIX_COUNT     = 16  ,

    parameter TX_DATA_WIDTH  = 128 ,
    parameter TX_ADDR_WIDTH  = 64  ,
    parameter TX_BURST_WIDTH = 6   ,

    parameter ST_1_GRP_SIZE  = 4   ,

    parameter ST_1_ARB_DIV     = MSIX_COUNT / ST_1_GRP_SIZE                    ,
    parameter ST_1_ARB_REM     = MSIX_COUNT % ST_1_GRP_SIZE                    ,
    parameter ST_1_ARB_CNT     = ST_1_ARB_DIV + (ST_1_ARB_REM != 0)            ,
    parameter ST_1_GRP_SIZE_W  = ST_1_GRP_SIZE == 1 ? 1 : $clog2(ST_1_GRP_SIZE),
    parameter ST_1_ARB_REM_W   = ST_1_ARB_REM == 1 ? 1 : $clog2(ST_1_ARB_REM)  ,
    
    parameter TX_DATA_BYTES    = TX_DATA_WIDTH / 8                             ,
    parameter MSIX_COUNT_WIDTH = MSIX_COUNT == 1 ? 1 : $clog2(MSIX_COUNT)      
) (
    input  logic                      clk                          ,
    input  logic                      rst_n                        ,

    input  logic [MSIX_COUNT-1:0]     irq_i                        ,

    input  logic [31:0]               msix_mask_i      [MSIX_COUNT],
    input  logic [31:0]               msix_data_i      [MSIX_COUNT],
    input  logic [63:0]               msix_addrs_i     [MSIX_COUNT],

    output logic                      tx_chipselect                ,
    output logic [TX_DATA_BYTES-1:0]  tx_byteenable                ,
    input  logic [TX_DATA_WIDTH-1:0]  tx_readdata                  ,
    output logic [TX_DATA_WIDTH-1:0]  tx_writedata                 ,
    output logic                      tx_read                      ,
    output logic                      tx_write                     ,
    output logic [TX_BURST_WIDTH-1:0] tx_burstcount                ,
    input  logic                      tx_readdatavalid             ,
    input  logic                      tx_waitrequest               ,
    output logic [TX_ADDR_WIDTH-1:0]  tx_address                   
);

    logic [MSIX_COUNT-1:0] irq_ff, irq_pending, irq_clear, irq_pending_to_arb;

    logic [MSIX_COUNT_WIDTH-1:0] irq_index;
    logic send_irq, irq_sent;

    assign tx_read       = 0;
    assign tx_burstcount = 1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            irq_ff <= '0;
        end
        else begin
            irq_ff <= irq_i;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            irq_pending        <= '0;
            irq_pending_to_arb <= '0;
        end        
        else begin
            irq_pending <= (irq_pending | (~irq_ff & irq_i)) & ~(irq_clear & irq_pending);

            for (int i = 0; i < MSIX_COUNT; i++) begin
                irq_pending_to_arb[i] <= irq_pending[i] & ~msix_mask_i[i][0];
            end
        end
    end


    logic [ST_1_ARB_CNT-1:0]     send_irq_st_1                ;
    logic [ST_1_ARB_CNT-1:0]     irq_sent_st_1                ;
    logic [MSIX_COUNT_WIDTH-1:0] irq_index_st_1 [ST_1_ARB_CNT];
    logic [MSIX_COUNT_WIDTH-1:0] irq_index_norm [ST_1_ARB_CNT];
        
    generate
        genvar i;

        for (i = 0; i < ST_1_ARB_DIV; i++) begin : st_1_arbs
            stream_arbiter #(
                .DATA_WIDTH (1            ),
                .INPUT_NUM  (ST_1_GRP_SIZE),
                .REG_ST     (1            )
            ) u_stream_arbiter (
                .ACLK    (clk                                                   ),
                .ARESETn (rst_n                                                 ),

                .data_i  ('{ST_1_GRP_SIZE{1'b0}}                                ),
                .valid_i (irq_pending_to_arb[i * ST_1_GRP_SIZE +: ST_1_GRP_SIZE]),
                .ready_o (irq_clear         [i * ST_1_GRP_SIZE +: ST_1_GRP_SIZE]),

                .data_o  (                                                      ), // NC
                .valid_o (send_irq_st_1 [i]                                     ),
                .ready_i (irq_sent_st_1 [i]                                     ),
                .sel_o   (irq_index_st_1[i][ST_1_GRP_SIZE_W-1:0]                )
            );

            assign irq_index_st_1[i][MSIX_COUNT_WIDTH-1:ST_1_GRP_SIZE_W] = '0;
        end
        if (ST_1_ARB_REM != 0) begin : st_1_arb_rem
            stream_arbiter #(
                .DATA_WIDTH (1           ),
                .INPUT_NUM  (ST_1_ARB_REM),
                .REG_ST     (1           )
            ) u_stream_arbiter (
                .ACLK    (clk                                                             ),
                .ARESETn (rst_n                                                           ),

                .data_i  ('{ST_1_ARB_REM{1'b0}}                                           ),
                .valid_i (irq_pending_to_arb[ST_1_ARB_DIV * ST_1_GRP_SIZE +: ST_1_ARB_REM]),
                .ready_o (irq_clear         [ST_1_ARB_DIV * ST_1_GRP_SIZE +: ST_1_ARB_REM]),

                .data_o  (                                                                ), // NC
                .valid_o (send_irq_st_1 [ST_1_ARB_DIV]                                    ),
                .ready_i (irq_sent_st_1 [ST_1_ARB_DIV]                                    ),
                .sel_o   (irq_index_st_1[ST_1_ARB_DIV][ST_1_ARB_REM_W-1:0]                )
            );

            assign irq_index_st_1[ST_1_ARB_DIV][MSIX_COUNT_WIDTH-1:ST_1_ARB_REM_W] = '0;
        end

        for (i = 0; i < ST_1_ARB_CNT; i++) begin : st_1_idx_norm
            assign irq_index_norm[i] = irq_index_st_1[i] + i * ST_1_GRP_SIZE;
        end
    endgenerate
    
    stream_arbiter #(
        .DATA_WIDTH (MSIX_COUNT_WIDTH),
        .INPUT_NUM  (ST_1_ARB_CNT    ),
        .REG_ST     (1               )
    ) u_stream_arbiter (
        .ACLK    (clk           ),
        .ARESETn (rst_n         ),

        .data_i  (irq_index_norm),
        .valid_i (send_irq_st_1 ),
        .ready_o (irq_sent_st_1 ),

        .data_o  (irq_index     ),
        .valid_o (send_irq      ),
        .ready_i (irq_sent      )
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_chipselect <= '0;
            tx_byteenable <= '0;
            tx_writedata  <= '0;
            tx_write      <= '0;
            tx_address    <= '0;

            irq_sent <= '0;
        end
        else begin
            if (send_irq && !irq_sent) begin
                tx_chipselect <= '1                                      ;
                tx_write      <= '1                                      ;
                tx_address    <= (msix_addrs_i[irq_index] >> 4) << 4;
                case (msix_addrs_i[irq_index][3:0])
                    'h0    : begin
                        tx_byteenable <= 'h000F                           ;
                        tx_writedata  <= msix_data_i[irq_index] << 0 ;
                    end
                    'h4    : begin
                        tx_byteenable <= 'h00F0                           ;
                        tx_writedata  <= msix_data_i[irq_index] << 32;
                    end
                    'h8    : begin
                        tx_byteenable <= 'h0F00                           ;
                        tx_writedata  <= msix_data_i[irq_index] << 64;
                    end
                    'hC    : begin
                        tx_byteenable <= 'hF000                           ;
                        tx_writedata  <= msix_data_i[irq_index] << 96;
                    end
                    default: begin
                        tx_byteenable <= 'h000F                           ;
                        tx_writedata  <= msix_data_i[irq_index] << 0 ;
                    end
                endcase

                if (tx_chipselect && tx_write && !tx_waitrequest) begin
                    tx_chipselect <= '0;
                    tx_write      <= '0;

                    irq_sent <= '1;
                end
            end
            else if (send_irq && irq_sent) begin
                tx_chipselect <= '0;
                tx_write      <= '0;

                irq_sent <= '0;
            end
            else begin
                tx_chipselect <= '0;
                tx_write      <= '0;
            end
        end
    end
    
endmodule