module avmm_dma_engine #(
    parameter DMA_OFFFSET_WIDTH = 22  ,
    parameter DMA_BYTES_WIDTH   = 22  ,

    parameter DMA_WQ_DEPTH      = 1024,
    parameter DMA_RQ_DEPTH      = 1024,

    parameter TX_DATA_WIDTH     = 128 ,
    parameter TX_ADDR_WIDTH     = 64  ,
    parameter TX_BURST_WIDTH    = 6   ,

    parameter DMA_BURST_WIDTH     = DMA_BYTES_WIDTH - 4                    ,
    parameter DMA_TASK_WIDTH      = 1 + DMA_OFFFSET_WIDTH + DMA_BURST_WIDTH,

    parameter W_BURST_COMPARATOR  = DMA_WQ_DEPTH < {TX_BURST_WIDTH{1'b1}} ?
                                    DMA_WQ_DEPTH : {TX_BURST_WIDTH{1'b1}}  ,
    parameter R_BURST_COMPARATOR  = DMA_RQ_DEPTH < {TX_BURST_WIDTH{1'b1}} ?
                                    DMA_RQ_DEPTH : {TX_BURST_WIDTH{1'b1}}  ,

    parameter TX_DATA_BYTES       = TX_DATA_WIDTH / 8                      ,
    parameter TX_DATA_BYTES_WIDTH = $clog2(TX_DATA_BYTES)                  ,
    parameter DMA_WQ_ADDR_WIDTH   = $clog2(DMA_WQ_DEPTH)                   ,
    parameter DMA_RQ_ADDR_WIDTH   = $clog2(DMA_RQ_DEPTH)                   
) (
    input  logic                         clk               ,
    input  logic                         rst_n             ,

    // MSIX table
    input  logic [31:0]                  msix_mask_i       ,
    input  logic [31:0]                  msix_data_i       ,
    input  logic [63:0]                  msix_addr_i       ,

    // CSR
    input  logic [63:0]                  dma_addr_i        ,

    // DMA task channel
    input  logic                         dma_task_valid_i  ,
    output logic                         dma_task_ready_o  ,
    input  logic [DMA_BURST_WIDTH-1:0]   dma_task_burst_i  ,
    input  logic [DMA_OFFFSET_WIDTH-1:0] dma_task_offset_i ,
    input  logic                         dma_task_write_i  ,

    // DMAWR data channel
    input  logic                         dma_wrdata_valid_i,
    output logic                         dma_wrdata_ready_o,
    input  logic [DMA_WQ_ADDR_WIDTH:0]   dma_wrdata_count_i,
    input  logic [TX_DATA_WIDTH-1:0]     dma_wrdata_data_i ,

    // DMARD data channel
    output logic                         dma_rddata_valid_o,
    input  logic                         dma_rddata_ready_i,
    input  logic [DMA_RQ_ADDR_WIDTH:0]   dma_rddata_free_i ,
    output logic [TX_DATA_WIDTH-1:0]     dma_rddata_data_o ,

    // To PC data channel
    output logic                         tx_chipselect     ,
    output logic [TX_DATA_BYTES-1:0]     tx_byteenable     ,
    input  logic [TX_DATA_WIDTH-1:0]     tx_readdata       ,
    output logic [TX_DATA_WIDTH-1:0]     tx_writedata      ,
    output logic                         tx_read           ,
    output logic                         tx_write          ,
    output logic [TX_BURST_WIDTH-1:0]    tx_burstcount     ,
    input  logic                         tx_readdatavalid  ,
    input  logic                         tx_waitrequest    ,
    output logic [TX_ADDR_WIDTH-1:0]     tx_address        
);

    /* Write logic */

    typedef enum logic [2:0] {
        IDLE    ,
        READ    ,
        WRITE   ,
        GEN_MSI ,
        WAIT_MSI
    } state_t;

    typedef struct packed {
        logic [63:0]                  curr_addr  ;
        logic [5:0]                   curr_burst ;
        logic [DMA_BURST_WIDTH-1:0]   reads_left ;
        logic [DMA_BURST_WIDTH-1:0]   bursts_left;
        logic [DMA_BURST_WIDTH-1:0]   burstcount ;
        logic [DMA_OFFFSET_WIDTH-1:0] offset     ;
        logic                         write      ;
    } dma_descriptor_t;
    
    dma_descriptor_t dma_descriptor, dma_descriptor_next;
    
    state_t state, state_next;

    logic                      tx_chipselect_next;
    logic [TX_DATA_BYTES-1:0]  tx_byteenable_next;
    logic [TX_DATA_WIDTH-1:0]  tx_writedata_next ;
    logic                      tx_write_next     ;
    logic                      tx_read_next      ;
    logic [TX_BURST_WIDTH-1:0] tx_burstcount_next;
    logic [TX_ADDR_WIDTH-1:0]  tx_address_next   ;

    logic [DMA_RQ_ADDR_WIDTH:0] outstanding_reads, outstanding_reads_next;

    logic                     dma_rddata_valid, dma_rddata_valid_next;
    logic [TX_DATA_WIDTH-1:0] dma_rddata_data , dma_rddata_data_next ;

    logic [DMA_RQ_ADDR_WIDTH:0] dma_rddata_free_checker;
    logic                       wait_checker, wait_checker_next;

    assign dma_rddata_valid_o = dma_rddata_valid;
    assign dma_rddata_data_o  = dma_rddata_data ;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dma_rddata_free_checker <= '0;
        end
        else begin
            dma_rddata_free_checker <= dma_rddata_free_i - outstanding_reads;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;

            dma_descriptor <= '0;

            tx_chipselect <= '0;
            tx_byteenable <= '0;
            tx_writedata  <= '0;
            tx_write      <= '0;
            tx_read       <= '0;
            tx_burstcount <= '0;
            tx_address    <= '0;

            outstanding_reads <= '0;

            dma_rddata_valid <= '0;
            dma_rddata_data  <= '0;

            wait_checker <= '0;
        end
        else begin
            state <= state_next;

            dma_descriptor <= dma_descriptor_next;

            tx_chipselect <= tx_chipselect_next;
            tx_byteenable <= tx_byteenable_next;
            tx_writedata  <= tx_writedata_next ;
            tx_write      <= tx_write_next     ;
            tx_read       <= tx_read_next      ;
            tx_burstcount <= tx_burstcount_next;
            tx_address    <= tx_address_next   ;

            outstanding_reads <= outstanding_reads_next;

            dma_rddata_valid <= dma_rddata_valid_next;
            dma_rddata_data  <= dma_rddata_data_next ;

            wait_checker <= wait_checker_next;
        end
    end

    always_comb begin
        state_next = state;

        case (state)
            IDLE    : begin
                if (dma_task_valid_i && dma_task_ready_o) begin
                    if (dma_task_write_i && dma_wrdata_count_i >= ((dma_task_burst_i > W_BURST_COMPARATOR) ? W_BURST_COMPARATOR : dma_task_burst_i)) begin
                        state_next = WRITE;
                    end
                    else if (!dma_task_write_i && dma_rddata_free_i >= ((dma_task_burst_i > R_BURST_COMPARATOR) ? R_BURST_COMPARATOR : dma_task_burst_i)) begin
                        state_next = READ;
                    end
                    else begin
                        state_next = state;
                    end
                end
                else begin
                    state_next = state;
                end
            end
            WRITE   : begin
                if (tx_chipselect && tx_write && !tx_waitrequest && dma_descriptor.bursts_left == 1) begin
                    if (!msix_mask_i[0]) begin
                        state_next = GEN_MSI;
                    end
                    else begin
                        state_next = IDLE;
                    end
                end
                else begin
                    state_next = state;
                end
            end
            READ    : begin
                if (tx_readdatavalid && dma_descriptor.reads_left == 1) begin
                    if (!msix_mask_i[0]) begin
                        state_next = GEN_MSI;
                    end
                    else begin
                        state_next = IDLE;
                    end
                end
                else begin
                    state_next = state;
                end
            end
            GEN_MSI : begin
                if (tx_chipselect && tx_write && !tx_waitrequest) begin
                    state_next = IDLE;
                end
                else begin
                    state_next = state;
                end
            end
            default: begin
                
            end
        endcase
    end

    always_comb begin
        dma_task_ready_o = '0;
        dma_wrdata_ready_o = '0;

        dma_descriptor_next = dma_descriptor;

        tx_chipselect_next = tx_chipselect;
        tx_byteenable_next = tx_byteenable;
        tx_writedata_next  = tx_writedata ;
        tx_write_next      = tx_write     ;
        tx_read_next       = tx_read      ;
        tx_burstcount_next = tx_burstcount;
        tx_address_next    = tx_address   ;

        outstanding_reads_next = outstanding_reads;

        wait_checker_next = wait_checker;

        case (state)
            IDLE    : begin
                if (dma_task_valid_i) begin
                    if (dma_task_write_i && dma_wrdata_count_i >= ((dma_task_burst_i > W_BURST_COMPARATOR) ? W_BURST_COMPARATOR : dma_task_burst_i)) begin
                        dma_task_ready_o = '1;
                    end
                    else if (!dma_task_write_i && dma_rddata_free_i >= ((dma_task_burst_i > R_BURST_COMPARATOR) ? R_BURST_COMPARATOR : dma_task_burst_i)) begin
                        dma_task_ready_o = '1;
                    end
                    else begin
                        dma_task_ready_o = '0;
                    end
                end
                else begin
                    dma_task_ready_o = '0;
                end

                if (dma_task_valid_i && dma_task_ready_o) begin
                    dma_descriptor_next.burstcount  = dma_task_burst_i ;
                    dma_descriptor_next.offset      = dma_task_offset_i;
                    dma_descriptor_next.write       = dma_task_write_i ;

                    dma_descriptor_next.curr_addr   = dma_addr_i + dma_task_offset_i;
                    dma_descriptor_next.bursts_left = dma_task_burst_i;
                    if (!dma_task_write_i) begin
                        dma_descriptor_next.reads_left = dma_task_burst_i;
                        dma_descriptor_next.curr_burst = (dma_task_burst_i > R_BURST_COMPARATOR) ? R_BURST_COMPARATOR : dma_task_burst_i;
                    end
                    else begin
                        dma_descriptor_next.reads_left = '0;
                        dma_descriptor_next.curr_burst = (dma_task_burst_i > W_BURST_COMPARATOR) ? W_BURST_COMPARATOR : dma_task_burst_i;
                    end
                end
            end
            WRITE   : begin
                tx_read_next = '0;
                
                if (tx_chipselect && tx_write) begin
                    if (!tx_waitrequest) begin
                        dma_descriptor_next.curr_addr   = dma_descriptor.curr_addr + TX_DATA_BYTES;
                        dma_descriptor_next.bursts_left = dma_descriptor.bursts_left - 1;

                        tx_byteenable_next = '1                         ;
                        tx_burstcount_next = tx_burstcount - 1          ;
                        tx_address_next    = tx_address + TX_DATA_BYTES ;
                        tx_writedata_next  = dma_wrdata_data_i;

                        if (dma_descriptor.curr_burst == 1) begin
                            dma_descriptor_next.curr_burst = ((dma_descriptor.bursts_left - 1) > W_BURST_COMPARATOR) ?
                                                                W_BURST_COMPARATOR : dma_descriptor.bursts_left - 1;

                            tx_chipselect_next = '0;
                            tx_write_next      = '0;
                            dma_wrdata_ready_o = '0;
                        end
                        else begin
                            dma_descriptor_next.curr_burst = dma_descriptor.curr_burst - 1;

                            tx_chipselect_next = '1;
                            tx_write_next      = '1;

                            dma_wrdata_ready_o = '1;
                        end
                    end
                end
                else begin
                    if (!dma_descriptor.bursts_left == 0 && (dma_descriptor.curr_burst <= dma_wrdata_count_i)) begin
                        tx_write_next      = '1             ;
                        tx_chipselect_next = '1             ;
                        tx_writedata_next  = dma_wrdata_data_i;
                        tx_byteenable_next = '1                       ;
                        tx_burstcount_next = dma_descriptor.curr_burst;
                        tx_address_next    = dma_descriptor.curr_addr ;

                        dma_wrdata_ready_o = '1;
                    end
                end
            end
            READ    : begin
                if (tx_chipselect && tx_read) begin
                    if (!tx_waitrequest) begin
                        dma_descriptor_next.curr_addr   = dma_descriptor.curr_addr + (dma_descriptor.curr_burst << TX_DATA_BYTES_WIDTH);
                        dma_descriptor_next.bursts_left = dma_descriptor.bursts_left - dma_descriptor.curr_burst;
                        dma_descriptor_next.curr_burst  = ((dma_descriptor.bursts_left - dma_descriptor.curr_burst) > R_BURST_COMPARATOR) ?
                                                            R_BURST_COMPARATOR : dma_descriptor.bursts_left - dma_descriptor.curr_burst;

                        tx_chipselect_next = '0;
                        tx_write_next      = '0;
                        tx_read_next       = '0;
                    end
                end
                else begin
                    if (wait_checker) begin
                        if (!dma_descriptor.bursts_left == 0 && (dma_descriptor.curr_burst <= dma_rddata_free_checker)) begin
                            tx_chipselect_next = '1                       ;
                            tx_write_next      = '0                       ;
                            tx_read_next       = '1                       ;
                            tx_byteenable_next = '1                       ;
                            tx_burstcount_next = dma_descriptor.curr_burst;
                            tx_address_next    = dma_descriptor.curr_addr ;

                            outstanding_reads_next = outstanding_reads + dma_descriptor.curr_burst;
                            wait_checker_next = '0;
                        end
                    end
                    else begin
                        if (!dma_descriptor.bursts_left == 0 && (dma_descriptor.curr_burst <= dma_rddata_free_checker)) begin
                            wait_checker_next = '1;
                        end
                    end
                end

                outstanding_reads_next = outstanding_reads_next - tx_readdatavalid;
                dma_descriptor_next.reads_left = dma_descriptor.reads_left - tx_readdatavalid;
            end
            GEN_MSI : begin
                tx_chipselect_next = '1         ;
                tx_write_next      = '1         ;
                tx_read_next       = '0         ;
                tx_burstcount_next = 1          ;
                case (msix_addr_i[3:0])
                    'h0    : begin
                        tx_writedata_next  = msix_data_i << 0 ;
                        tx_byteenable_next = 16'h000F;
                    end
                    'h4    : begin
                        tx_writedata_next  = msix_data_i << 32;
                        tx_byteenable_next = 16'h00F0;
                    end
                    'h8    : begin
                        tx_writedata_next  = msix_data_i << 64;
                        tx_byteenable_next = 16'h0F00;
                    end
                    'hC    : begin
                        tx_writedata_next  = msix_data_i << 96;
                        tx_byteenable_next = 16'hF000;
                    end
                    default: begin
                        tx_writedata_next  = msix_data_i << 0 ;
                        tx_byteenable_next = 16'h000F;
                    end
                endcase
                tx_address_next    = {msix_addr_i[63:4], 4'h0};

                if (tx_chipselect && tx_write && !tx_waitrequest) begin
                    tx_chipselect_next = '0;
                    tx_write_next      = '0;
                    tx_read_next       = '0;
                end
            end
            default: begin
            end
        endcase
    end
    
    always_comb begin
        dma_rddata_valid_next = tx_readdatavalid;
        dma_rddata_data_next  = tx_readdata     ;
    end

endmodule