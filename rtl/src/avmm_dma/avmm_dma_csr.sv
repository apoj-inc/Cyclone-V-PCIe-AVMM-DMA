// s.talibov: this is a configuration regmap for the avmm_dma
/*
    High-level CSR structure

0x000  | Struct size | Struct 0 pointer | -\
0x004  | Task FIFO free spaces          |  |
                                           |
   /---------------------------------------/
   \-> | Struct 1 pointer | -\
       | Struct info 0    |  |
            ...              |
       | Struct info N    |  |
                             |
   /-------------------------/
   \-> | Struct 2 pointer |
       | Struct info 0    |
            ...            
       | Struct info N    |
            ...

    There are DMA_CHANNEL_COUNT number of structures.
    Last structure's pointer is equal to 0. That's how you
    know it's last.

    Info about DMA channel capability structure can be acquired
    from code section under "// Per structure address decoding"
    comment

*/

module avmm_dma_csr #(
    parameter     DMA_CHANNEL_COUNT                     = 16         ,

    parameter     BAR_DATA_WIDTH                        = 128        ,
    parameter     BAR_ADDR_WIDTH                        = 12         ,
    
    parameter int DMA_WORD_BYTES    [DMA_CHANNEL_COUNT] = '{16{16  }},
    parameter int DMA_WQ_DEPTH      [DMA_CHANNEL_COUNT] = '{16{1024}},
    parameter int DMA_RQ_DEPTH      [DMA_CHANNEL_COUNT] = '{16{1024}},
    parameter     DMA_TQ_DEPTH                          = 16         ,

    parameter int MAX_WQ_DEPTH                          = 1024       ,
    parameter int MAX_RQ_DEPTH                          = 1024       ,

    parameter     BAR_DATA_BYTES                        = BAR_DATA_WIDTH / 8  ,
    parameter     DMA_WQ_ADDR_WIDTH                     = $clog2(MAX_WQ_DEPTH),
    parameter     DMA_RQ_ADDR_WIDTH                     = $clog2(MAX_RQ_DEPTH),
    parameter     DMA_TQ_ADDR_WIDTH                     = $clog2(DMA_TQ_DEPTH)
) (
    input  logic                       clk                                     ,
    input  logic                       rst_n                                   ,

    input  logic                       avmm_s_chipselect                       ,
    input  logic [BAR_DATA_BYTES-1:0]  avmm_s_byteenable                       ,
    output logic [BAR_DATA_WIDTH-1:0]  avmm_s_readdata                         ,
    input  logic [BAR_DATA_WIDTH-1:0]  avmm_s_writedata                        ,
    input  logic                       avmm_s_read                             ,
    input  logic                       avmm_s_write                            ,
    output logic                       avmm_s_readdatavalid                    ,
    output logic                       avmm_s_waitrequest                      ,
    input  logic [BAR_ADDR_WIDTH-1:0]  avmm_s_address                          ,

    output logic                       dma_resetn_o                            ,

    output logic [63:0]                dma_addr_o           [DMA_CHANNEL_COUNT],

    input  logic [DMA_WQ_ADDR_WIDTH:0] wdata_fifo_count_i   [DMA_CHANNEL_COUNT],
    input  logic [DMA_RQ_ADDR_WIDTH:0] rdata_fifo_free_i    [DMA_CHANNEL_COUNT],
    input  logic [DMA_TQ_ADDR_WIDTH:0] dmawr_task_free_i                       ,
    input  logic [DMA_TQ_ADDR_WIDTH:0] dmard_task_free_i                       
);

    typedef struct packed {
        logic [15:0]                cap_next_ptr    ;

        logic [63:0]                dma_addr        ;
        logic [31:0]                dma_word_bytes  ;
        
        logic [31:0]                max_wr_len      ;
        logic [31:0]                max_rd_len      ;

        logic [31:0]                wdata_fifo_count;
        logic [31:0]                rdata_fifo_free ;
    } dma_csr_struct_t;

    localparam DMA_STRUCT_BITS       = $bits(dma_csr_struct_t)                           ;
    localparam DMA_STRUCT_BYTES      = DMA_STRUCT_BITS / 8 + ((DMA_STRUCT_BITS % 8) != 0);
    localparam DMA_STRUCT_ADDR_WIDTH = $clog2(DMA_STRUCT_BYTES)                          ;
    localparam DMA_STRUCT_SEL_WIDTH  = 16 - DMA_STRUCT_ADDR_WIDTH                        ;

    // Global registers address decoding
    localparam INFO_REG        = 16'h0000;
    localparam DMAWR_TASK_FREE = 16'h0004;
    localparam DMARD_TASK_FREE = 16'h0008;
    localparam DMA_RESET       = 16'h000C;

    // Per structure address decoding
    localparam CAP_NEXT_PTR    = 16'h0000;

    localparam DMA_ADDR_LO     = 16'h0004;
    localparam DMA_ADDR_HI     = 16'h0008;
    localparam DMA_W_BYTES_REG = 16'h000C;
    
    localparam MAX_WR_LEN      = 16'h0010;
    localparam MAX_RD_LEN      = 16'h0014;
    
    localparam WDATA_CONUT     = 16'h0018;
    localparam RDATA_FREE      = 16'h001C;


    // AVMM translation and control
    logic [BAR_DATA_BYTES/4-1:0] word_enable;
    logic [BAR_DATA_BYTES/4-1:0] word_enable_reg;
    logic [BAR_ADDR_WIDTH-1:0]   translated_addr;
    logic [31:0]                 translated_wdata;
    logic [31:0]                 translated_rdata;

    // Read collector
    logic [31:0] csr_rdata_glob;
    logic [31:0] csr_rdata_struct [DMA_CHANNEL_COUNT];
    
    always_comb begin
        translated_rdata = csr_rdata_glob;
        for (int i = 0; i < DMA_CHANNEL_COUNT; i++) begin
            translated_rdata |= csr_rdata_struct[i];
        end
    end

    assign word_enable = {avmm_s_byteenable[12], avmm_s_byteenable[8], avmm_s_byteenable[4], avmm_s_byteenable[0]};

    always_comb begin
        casez (word_enable)
            4'b???1: translated_addr = avmm_s_address;
            4'b??10: translated_addr = avmm_s_address + 4;
            4'b?100: translated_addr = avmm_s_address + 8;
            4'b1000: translated_addr = avmm_s_address + 12;
            default: translated_addr = avmm_s_address;
        endcase

        casez (word_enable)
            4'b???1: translated_wdata = avmm_s_writedata[31:0]  ;
            4'b??10: translated_wdata = avmm_s_writedata[63:32] ;
            4'b?100: translated_wdata = avmm_s_writedata[95:64] ;
            4'b1000: translated_wdata = avmm_s_writedata[127:96];
            default: translated_wdata = avmm_s_writedata[31:0]  ;
        endcase
        
        avmm_s_readdata = '0;
        casez (word_enable)
            4'b???1: avmm_s_readdata[31:0]   = translated_rdata;
            4'b??10: avmm_s_readdata[63:32]  = translated_rdata;
            4'b?100: avmm_s_readdata[95:64]  = translated_rdata;
            4'b1000: avmm_s_readdata[127:96] = translated_rdata;
            default: avmm_s_readdata[31:0]   = translated_rdata;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            avmm_s_waitrequest   <= '1;
            avmm_s_readdatavalid <= '0;
            word_enable_reg      <= '0;
        end
        else begin
            avmm_s_waitrequest   <= '0;
            avmm_s_readdatavalid <= '0;
            
            if (avmm_s_chipselect && avmm_s_read && !avmm_s_waitrequest) begin
                word_enable_reg <= word_enable;
                avmm_s_waitrequest   <= '1;
                avmm_s_readdatavalid <= '1;
            end
            
        end
    end


    // Global register logic
    logic [31:0] info_register;
    assign info_register = {16'(1 << DMA_STRUCT_ADDR_WIDTH), 16'(DMA_CHANNEL_COUNT)};

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            csr_rdata_glob <= '0;
        end
        else begin
            case (translated_addr)
                INFO_REG        : csr_rdata_glob <= info_register;
                DMAWR_TASK_FREE : csr_rdata_glob <= dmawr_task_free_i;
                DMARD_TASK_FREE : csr_rdata_glob <= dmard_task_free_i;
                DMA_RESET       : csr_rdata_glob <= dma_resetn_o;
                default         : csr_rdata_glob <= '0;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dma_resetn_o <= '0;
        end
        else begin
            // Write singlepulse registers from hardware
            dma_resetn_o <= '1;

            // Write registers from interface
            if (avmm_s_chipselect && avmm_s_write) begin
                case (translated_addr)
                    DMA_RESET: dma_resetn_o <= translated_wdata;
                    default  :                                 ;
                endcase
            end
        end
    end


    // Structure logic
    generate
        genvar i;

        for (i = 0; i < DMA_CHANNEL_COUNT; i++) begin : gen_structures
            dma_csr_struct_t dma_csr_struct;

            logic struct_addr_enable;

            assign struct_addr_enable = ((translated_addr >> DMA_STRUCT_ADDR_WIDTH) == (i+1));
            assign dma_addr_o[i] = dma_csr_struct.dma_addr;

            // Read data logic
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    csr_rdata_struct[i] <= '0;
                end
                else begin
                    if (struct_addr_enable) begin
                        case (translated_addr[DMA_STRUCT_ADDR_WIDTH-1:0])
                            CAP_NEXT_PTR    : csr_rdata_struct[i] <= dma_csr_struct.cap_next_ptr    ;
                            DMA_ADDR_LO     : csr_rdata_struct[i] <= dma_csr_struct.dma_addr[31:0]  ;
                            DMA_ADDR_HI     : csr_rdata_struct[i] <= dma_csr_struct.dma_addr[63:32] ;
                            DMA_W_BYTES_REG : csr_rdata_struct[i] <= dma_csr_struct.dma_word_bytes  ;
                            MAX_WR_LEN      : csr_rdata_struct[i] <= dma_csr_struct.max_wr_len      ;
                            MAX_RD_LEN      : csr_rdata_struct[i] <= dma_csr_struct.max_rd_len      ;
                            WDATA_CONUT     : csr_rdata_struct[i] <= dma_csr_struct.wdata_fifo_count;
                            RDATA_FREE      : csr_rdata_struct[i] <= dma_csr_struct.rdata_fifo_free ;
                            default         : csr_rdata_struct[i] <= '0                             ;
                        endcase
                    end
                    else begin
                        csr_rdata_struct[i] <= '0;
                    end
                end
            end

            // Write data and register reset value logic
            
            assign dma_csr_struct.cap_next_ptr   = (i == (DMA_CHANNEL_COUNT-1)) ? '0 : ((i+2) << DMA_STRUCT_ADDR_WIDTH);
            assign dma_csr_struct.dma_word_bytes = DMA_WORD_BYTES[i]                                                   ;
            assign dma_csr_struct.max_wr_len     = DMA_WQ_DEPTH[i] * DMA_WORD_BYTES[i]                                 ;
            assign dma_csr_struct.max_rd_len     = DMA_RQ_DEPTH[i] * DMA_WORD_BYTES[i]                                 ;

            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    dma_csr_struct.dma_addr         <= '0                              ;
                    dma_csr_struct.wdata_fifo_count <= '0                              ;
                    dma_csr_struct.rdata_fifo_free  <= '0                              ;
                end
                else begin
                    // Write registers from interface
                    if (struct_addr_enable && avmm_s_chipselect && avmm_s_write) begin
                        case (translated_addr[DMA_STRUCT_ADDR_WIDTH-1:0])
                            CAP_NEXT_PTR    : /*dma_csr_struct.cap_next_ptr     <= translated_wdata*/ ; // Read-only
                            DMA_ADDR_LO     :   dma_csr_struct.dma_addr[31:0]   <= translated_wdata   ;
                            DMA_ADDR_HI     :   dma_csr_struct.dma_addr[63:32]  <= translated_wdata   ;
                            DMA_W_BYTES_REG : /*dma_csr_struct.dma_word_bytes   <= translated_wdata*/ ; // Read-only
                            MAX_WR_LEN      : /*dma_csr_struct.max_wr_len       <= translated_wdata*/ ; // Read-only
                            MAX_RD_LEN      : /*dma_csr_struct.max_rd_len       <= translated_wdata*/ ; // Read-only
                            WDATA_CONUT     : /*dma_csr_struct.wdata_fifo_count <= translated_wdata*/ ; // Read-only
                            RDATA_FREE      : /*dma_csr_struct.rdata_fifo_free  <= translated_wdata*/ ; // Read-only
                            default         :                                                         ;
                        endcase
                    end

                    // Write registers from hardware
                    dma_csr_struct.wdata_fifo_count <= wdata_fifo_count_i[i];
                    dma_csr_struct.rdata_fifo_free  <= rdata_fifo_free_i [i];
                end
            end
        end
    endgenerate
    
endmodule