module external_csr #(
    parameter DMA_CHANNEL_COUNT = 16 ,

    parameter BAR_DATA_WIDTH    = 128,
    parameter BAR_ADDR_WIDTH    = 12 ,

    parameter BAR_DATA_BYTES = BAR_DATA_WIDTH / 8
) (
    input  logic                           clk                                     ,
    input  logic                           rst_n                                   ,

    input  logic                           avmm_s_chipselect                       ,
    input  logic [BAR_DATA_BYTES-1:0]      avmm_s_byteenable                       ,
    output logic [BAR_DATA_WIDTH-1:0]      avmm_s_readdata                         ,
    input  logic [BAR_DATA_WIDTH-1:0]      avmm_s_writedata                        ,
    input  logic                           avmm_s_read                             ,
    input  logic                           avmm_s_write                            ,
    output logic                           avmm_s_readdatavalid                    ,
    output logic                           avmm_s_waitrequest                      ,
    input  logic [BAR_ADDR_WIDTH-1:0]      avmm_s_address                          ,

    output logic [DMA_CHANNEL_COUNT-1:0]   user_irq_o                              
);

    typedef struct packed {
        logic [31:0] generate_external_irq;
    } example_struct_t;

    localparam EXAMPLE_STRUCT_BITS       = $bits(example_struct_t)                                   ;
    localparam EXAMPLE_STRUCT_BYTES      = EXAMPLE_STRUCT_BITS / 8 + ((EXAMPLE_STRUCT_BITS % 8) != 0);
    localparam EXAMPLE_STRUCT_ADDR_WIDTH = $clog2(EXAMPLE_STRUCT_BYTES)                              ;
    localparam EXAMPLE_STRUCT_SEL_WIDTH  = BAR_ADDR_WIDTH - EXAMPLE_STRUCT_ADDR_WIDTH                ;

    // AVMM translation and control
    logic [BAR_DATA_BYTES/4-1:0] word_enable;
    logic [BAR_ADDR_WIDTH-1:0]   translated_addr;
    logic [31:0]                 translated_wdata;
    logic [31:0]                 translated_rdata;

    // Read collector
    logic [31:0] csr_rdata_struct [DMA_CHANNEL_COUNT];
    
    always_comb begin
        translated_rdata = '0;
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
        end
        else begin
            avmm_s_waitrequest   <= '0;
            avmm_s_readdatavalid <= '0;
            
            if (avmm_s_chipselect && avmm_s_read && !avmm_s_waitrequest) begin
                avmm_s_waitrequest   <= '1;
                avmm_s_readdatavalid <= '1;
            end
            
        end
    end


    // Structure logic
    generate
        genvar i;

        for (i = 0; i < DMA_CHANNEL_COUNT; i++) begin : gen_structures
            example_struct_t example_struct;
            logic struct_addr_enable;

            assign struct_addr_enable = ((translated_addr >> EXAMPLE_STRUCT_ADDR_WIDTH) == i);
            assign user_irq_o[i] = example_struct.generate_external_irq[0];

            // Read data logic
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    csr_rdata_struct[i] <= '0;
                end
                else begin
                    if (struct_addr_enable) begin
                        csr_rdata_struct[i] <= example_struct[32'(translated_addr[EXAMPLE_STRUCT_ADDR_WIDTH-1:0])<<3 +: 32];
                    end
                    else begin
                        csr_rdata_struct[i] <= '0;
                    end
                end
            end

            // Write data and register reset value logic            
            
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    example_struct.generate_external_irq  <= '0;
                end
                else begin
                    // Write singlepulse registers from hardware
                    example_struct.generate_external_irq <= '0;

                    // Write registers from interface
                    if (struct_addr_enable && avmm_s_write) begin
                        example_struct[32'(translated_addr[EXAMPLE_STRUCT_ADDR_WIDTH-1:0])<<3 +: 32] <= translated_wdata;
                    end
                end
            end
        end
    endgenerate
    
endmodule