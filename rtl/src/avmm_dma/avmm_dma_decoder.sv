// DMA commands:
/*
    ioread* from any address: returns 0

    Address format:
    0xXX0 - DMA write
    0xXX8 - DMA read
    0x00X - DMA channel 0 command
    0x01X - DMA channel 1 command
    ...
    0x0FX - DMA channel 15 command

    iowrite64 to 0xXX0 (avmm_addr == 0x000, avmm_byteen == 0x00FF): DMA write to PC operation
    data:  63..54.53.............32.31..22.21.............0
          | xxxx | number of bytes | xxxx | address offset |
           
    iowrite64 to 0xXX8 (avmm_addr == 0x000, avmm_byteen == 0xFF00): DMA read from PC operation
    data:  63..54.53.............32.31..22.21.............0
          | xxxx | number of bytes | xxxx | address offset |

    iowrite64 to any inactive address: nothing happens
    
    iowrite(8, 16, 32) to 0x000-0xFFF: nothing happens
*/

module avmm_dma_decoder #(
    parameter BAR_DATA_WIDTH    = 128,
    parameter BAR_ADDR_WIDTH    = 12 ,

    parameter DMA_CHANNEL_COUNT = 16 ,
    parameter DMA_OFFFSET_WIDTH = 22 ,
    parameter DMA_BYTES_WIDTH   = 22 ,

    parameter DMA_BURST_WIDTH         = DMA_BYTES_WIDTH - 4                                   ,
    parameter DMA_CHANNEL_COUNT_WIDTH = DMA_CHANNEL_COUNT == 1 ? 1 : $clog2(DMA_CHANNEL_COUNT),
    parameter BAR_DATA_BYTES          = BAR_DATA_WIDTH / 8                                    
) (
    input  logic                               clk                 ,
    input  logic                               rst_n               ,

    input  logic                               avmm_s_chipselect   ,
    input  logic [BAR_DATA_BYTES-1:0]          avmm_s_byteenable   ,
    output logic [BAR_DATA_WIDTH-1:0]          avmm_s_readdata     ,
    input  logic [BAR_DATA_WIDTH-1:0]          avmm_s_writedata    ,
    input  logic                               avmm_s_read         ,
    input  logic                               avmm_s_write        ,
    output logic                               avmm_s_readdatavalid,
    output logic                               avmm_s_waitrequest  ,
    input  logic [BAR_ADDR_WIDTH-1:0]          avmm_s_address      ,

    output logic                               dma_task_valid_o    ,
    input  logic                               dma_task_ready_i    ,
    output logic [DMA_CHANNEL_COUNT_WIDTH-1:0] dma_task_channel_o  ,
    output logic [DMA_BURST_WIDTH-1:0]         dma_task_burst_o    ,
    output logic [DMA_OFFFSET_WIDTH-1:0]       dma_task_offset_o   ,
    output logic                               dma_task_write_o    
);

    typedef enum logic[1:0] { 
        IDLE          ,
        BAR_READ_DUMMY,
        GENERATE_DMAWR,
        GENERATE_DMARD
    } state_t;

    state_t state, state_next;
    logic [31:0] in_state_counter, in_state_counter_next;

    logic avmm_s_waitrequest_next  ;
    logic avmm_s_readdatavalid_next;

    logic                               dma_task_valid  , dma_task_valid_next  ;
    logic [DMA_CHANNEL_COUNT_WIDTH-1:0] dma_task_channel, dma_task_channel_next;
    logic [DMA_BURST_WIDTH-1:0]         dma_task_burst  , dma_task_burst_next  ;
    logic [DMA_OFFFSET_WIDTH-1:0]       dma_task_offset , dma_task_offset_next ;
    logic                               dma_task_write  , dma_task_write_next  ;

    assign avmm_s_readdata = '0;

    assign dma_task_valid_o   = dma_task_valid  ;
    assign dma_task_channel_o = dma_task_channel;
    assign dma_task_burst_o   = dma_task_burst  ;
    assign dma_task_offset_o  = dma_task_offset ;
    assign dma_task_write_o   = dma_task_write  ;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            in_state_counter <= '0;

            avmm_s_waitrequest   <= '1;
            avmm_s_readdatavalid <= '0;

            dma_task_valid   <= '0;
            dma_task_channel <= '0;
            dma_task_burst   <= '0;
            dma_task_offset  <= '0;
            dma_task_write   <= '0;
        end
        else begin
            state <= state_next;
            
            avmm_s_waitrequest   <= avmm_s_waitrequest_next  ;
            avmm_s_readdatavalid <= avmm_s_readdatavalid_next;

            dma_task_valid   <= dma_task_valid_next  ;
            dma_task_channel <= dma_task_channel_next;
            dma_task_burst   <= dma_task_burst_next  ;
            dma_task_offset  <= dma_task_offset_next ;
            dma_task_write   <= dma_task_write_next  ;
        end
    end

    always_comb begin
        state_next = state;

        case (state)
            IDLE: begin
                if (avmm_s_chipselect & !avmm_s_waitrequest) begin
                    if (avmm_s_read) begin
                        state_next = BAR_READ_DUMMY;
                    end
                    else if (avmm_s_write) begin
                        if (((avmm_s_address >> 4) < DMA_CHANNEL_COUNT) && (avmm_s_byteenable == 'h00FF)) begin
                            state_next = GENERATE_DMAWR;
                        end
                        else if (((avmm_s_address >> 4) < DMA_CHANNEL_COUNT) && (avmm_s_byteenable == 'hFF00)) begin
                            state_next = GENERATE_DMARD;
                        end
                        else begin
                            state_next = state;
                        end
                    end
                    else begin
                        state_next = state;
                    end
                end
                else begin
                    state_next = state;
                end
            end
            BAR_READ_DUMMY: begin
                state_next = IDLE;
            end
            GENERATE_DMAWR, GENERATE_DMARD: begin
                if (dma_task_valid_o && dma_task_ready_i) begin
                    state_next = IDLE;
                end
                else begin
                    state_next = state;
                end
            end
            default: begin
                state_next = IDLE;
            end
        endcase
    end

    always_comb begin
        avmm_s_waitrequest_next   = avmm_s_waitrequest  ;
        avmm_s_readdatavalid_next = avmm_s_readdatavalid;

        dma_task_valid_next   = dma_task_valid  ;
        dma_task_channel_next = dma_task_channel;
        dma_task_burst_next   = dma_task_burst  ;
        dma_task_offset_next  = dma_task_offset ;
        dma_task_write_next   = dma_task_write  ;

        case (state)
            IDLE          : begin
                avmm_s_waitrequest_next   = '0;
                avmm_s_readdatavalid_next = '0;

                if (avmm_s_chipselect & !avmm_s_waitrequest) begin
                    if (avmm_s_read) begin
                        avmm_s_waitrequest_next   = '1;
                        avmm_s_readdatavalid_next = '1;
                    end
                    else if (avmm_s_write) begin
                        if ((avmm_s_address[BAR_ADDR_WIDTH-1:4] < DMA_CHANNEL_COUNT) && (avmm_s_byteenable == 'h00FF)) begin
                            avmm_s_waitrequest_next = '1;

                            dma_task_valid_next   = '1                                ;
                            dma_task_channel_next = avmm_s_address[BAR_ADDR_WIDTH-1:4];
                            dma_task_burst_next   = avmm_s_writedata[53:36]           ;
                            dma_task_offset_next  = avmm_s_writedata[21:0]            ;
                            dma_task_write_next   = 1'b1                              ;
                        end
                        else if ((avmm_s_address[BAR_ADDR_WIDTH-1:4] < DMA_CHANNEL_COUNT) && (avmm_s_byteenable == 'hFF00)) begin
                            avmm_s_waitrequest_next = '1;

                            dma_task_valid_next   = '1                                ;
                            dma_task_channel_next = avmm_s_address[BAR_ADDR_WIDTH-1:4];
                            dma_task_burst_next   = avmm_s_writedata[117:100]         ;
                            dma_task_offset_next  = avmm_s_writedata[85:64]           ;
                            dma_task_write_next   = 1'b0                              ;
                        end
                    end
                end
            end
            BAR_READ_DUMMY: begin
                avmm_s_waitrequest_next = '0;
                avmm_s_readdatavalid_next = '0;
            end
            GENERATE_DMAWR, GENERATE_DMARD: begin
                if (dma_task_valid_o && dma_task_ready_i) begin
                    avmm_s_waitrequest_next = '0;
                    dma_task_valid_next = '0;
                end
            end
            default: begin
            end
        endcase
    end
    
endmodule