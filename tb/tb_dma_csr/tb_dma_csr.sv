`timescale 1ns/1ps

module tb_dma_csr;

parameter     DMA_CHANNEL_COUNT                     = 16         ;

parameter     BAR_DATA_WIDTH                        = 128        ;
parameter     BAR_ADDR_WIDTH                        = 12         ;

parameter int DMA_WORD_BYTES    [DMA_CHANNEL_COUNT] = '{16{16  }};
parameter int DMA_WQ_DEPTH      [DMA_CHANNEL_COUNT] = '{16{1024}};
parameter int DMA_RQ_DEPTH      [DMA_CHANNEL_COUNT] = '{16{1024}};
parameter int DMA_TQ_DEPTH                          = 16         ;

parameter int MAX_WQ_DEPTH                          = 1024       ;
parameter int MAX_RQ_DEPTH                          = 1024       ;

parameter     BAR_DATA_BYTES                        = BAR_DATA_WIDTH / 8  ;
parameter     DMA_WQ_ADDR_WIDTH                     = $clog2(MAX_WQ_DEPTH);
parameter     DMA_RQ_ADDR_WIDTH                     = $clog2(MAX_RQ_DEPTH);
parameter     DMA_TQ_ADDR_WIDTH                     = $clog2(DMA_TQ_DEPTH);


parameter int BYTEENABLES[16] = '{
    'h0000, 'h000F, 'h00F0, 'h00FF,
    'h0F00, 'h0F0F, 'h0FF0, 'h0FFF,
    'hF000, 'hF00F, 'hF0F0, 'hF0FF,
    'hFF00, 'hFF0F, 'hFFF0, 'hFFFF
};

typedef struct packed {
        logic [15:0]                cap_next_ptr    ;

        logic [63:0]                dma_addr        ;
        logic [31:0]                dma_word_bytes  ;
        
        logic [31:0]                max_wr_len      ;
        logic [31:0]                max_rd_len      ;
        logic [31:0]                tq_depth        ;

        logic [31:0]                wdata_fifo_count;
        logic [31:0]                rdata_fifo_free ;
    } dma_csr_struct_t;

    localparam DMA_STRUCT_BITS       = $bits(dma_csr_struct_t)                           ;
    localparam DMA_STRUCT_BYTES      = DMA_STRUCT_BITS / 8 + ((DMA_STRUCT_BITS % 8) != 0);
    localparam DMA_STRUCT_ADDR_WIDTH = $clog2(DMA_STRUCT_BYTES)                          ;
    localparam DMA_STRUCT_SEL_WIDTH  = 16 - DMA_STRUCT_ADDR_WIDTH                        ;


logic test_done;
logic error;
logic [31:0] random_seed;
logic [31:0] expected;
logic [31:0] write_value;
logic [63:0] expected_dma_addr;

logic                       clk                                     ;
logic                       rst_n                                   ;
logic                       avmm_s_chipselect                       ;
logic [BAR_DATA_BYTES-1:0]  avmm_s_byteenable                       ;
logic [BAR_DATA_WIDTH-1:0]  avmm_s_readdata                         ;
logic [BAR_DATA_WIDTH-1:0]  avmm_s_writedata                        ;
logic                       avmm_s_read                             ;
logic                       avmm_s_write                            ;
logic                       avmm_s_readdatavalid                    ;
logic                       avmm_s_waitrequest                      ;
logic [BAR_ADDR_WIDTH-1:0]  avmm_s_address                          ;
logic [63:0]                dma_addr_o           [DMA_CHANNEL_COUNT];
logic [DMA_WQ_ADDR_WIDTH:0] wdata_fifo_count_i   [DMA_CHANNEL_COUNT];
logic [DMA_RQ_ADDR_WIDTH:0] rdata_fifo_free_i    [DMA_CHANNEL_COUNT];
logic [DMA_TQ_ADDR_WIDTH:0] dmawr_task_free_i                       ;
logic [DMA_TQ_ADDR_WIDTH:0] dmard_task_free_i                       ;

logic [15:0] next_struct;
logic [15:0] curr_struct;

avmm_dma_csr #(
    .DMA_CHANNEL_COUNT (DMA_CHANNEL_COUNT),

    .BAR_DATA_WIDTH    (BAR_DATA_WIDTH   ),
    .BAR_ADDR_WIDTH    (BAR_ADDR_WIDTH   ),

    .DMA_WORD_BYTES    (DMA_WORD_BYTES   ),
    .DMA_WQ_DEPTH      (DMA_WQ_DEPTH     ),
    .DMA_RQ_DEPTH      (DMA_RQ_DEPTH     ),
    .DMA_TQ_DEPTH      (DMA_TQ_DEPTH     ),

    .MAX_WQ_DEPTH      (MAX_WQ_DEPTH     ),
    .MAX_RQ_DEPTH      (MAX_RQ_DEPTH     )
) u_avmm_dma_csr (
    .clk                  (clk                 ),
    .rst_n                (rst_n               ),

    .avmm_s_chipselect    (avmm_s_chipselect   ),
    .avmm_s_byteenable    (avmm_s_byteenable   ),
    .avmm_s_readdata      (avmm_s_readdata     ),
    .avmm_s_writedata     (avmm_s_writedata    ),
    .avmm_s_read          (avmm_s_read         ),
    .avmm_s_write         (avmm_s_write        ),
    .avmm_s_readdatavalid (avmm_s_readdatavalid),
    .avmm_s_waitrequest   (avmm_s_waitrequest  ),
    .avmm_s_address       (avmm_s_address      ),

    .dma_addr_o           (dma_addr_o          ),

    .wdata_fifo_count_i   (wdata_fifo_count_i  ),
    .rdata_fifo_free_i    (rdata_fifo_free_i   ),
    .dmawr_task_free_i    (dmawr_task_free_i   ),
    .dmard_task_free_i    (dmard_task_free_i   )
);


always #10 clk = ~clk;

task automatic avmm_read(
    input logic [BAR_DATA_BYTES-1:0]  byteenable,
    input logic [BAR_ADDR_WIDTH-1:0]  address   
);
    @(posedge clk);
    avmm_s_chipselect    = '1;
    avmm_s_byteenable    = byteenable;
    avmm_s_read          = '1;
    avmm_s_write         = '0;
    avmm_s_writedata     = '0;
    avmm_s_address       = address;
    @(posedge clk);
    while (avmm_s_waitrequest) begin
        @(posedge clk);
    end
    avmm_s_read          = '0;
    while (!avmm_s_readdatavalid) begin
        @(posedge clk);
    end
endtask

task automatic avmm_write(
    input logic [BAR_DATA_BYTES-1:0]  byteenable,
    input logic [BAR_DATA_WIDTH-1:0]  writedata ,
    input logic [BAR_ADDR_WIDTH-1:0]  address   
);
    @(posedge clk);
    avmm_s_chipselect    = '1;
    avmm_s_byteenable    = byteenable;
    avmm_s_read          = '0;
    avmm_s_write         = '1;
    avmm_s_writedata     = writedata;
    avmm_s_address       = address;
    @(posedge clk);
    while (avmm_s_waitrequest) begin
        @(posedge clk);
    end
    avmm_s_write = '0;
endtask

task automatic test_register32(
    input logic [BAR_DATA_BYTES-1:0]  byteenable,
    input logic [BAR_ADDR_WIDTH-1:0]  address   ,
    input logic [31:0]                reset_val ,
    input logic                       rdonly
);
    logic [1:0] word_select;
    logic [31:0] expected;

    case (byteenable)
        'h000F: word_select = 0;
        'h00F0: word_select = 1;
        'h0F00: word_select = 2;
        'hF000: word_select = 3;
    endcase
    avmm_read(
        .byteenable (byteenable),
        .address    (address)
    );
    expected = reset_val;
    assert (avmm_s_readdata[32*word_select +: 32] == expected) 
    else   begin
        error = 1;
        $error("Reset addr %h byen %h expected %h, got %h", address, byteenable, expected, avmm_s_readdata[32*word_select +: 32]);
        $finish();
    end
    write_value = $urandom();
    avmm_write(
        .byteenable (byteenable),
        .writedata  (write_value<<(32*word_select)),
        .address    (address)
    );
    avmm_read(
        .byteenable (byteenable),
        .address    (address)
    );
    expected = rdonly ? reset_val : write_value;
    assert (avmm_s_readdata[32*word_select +: 32] == expected) 
    else   begin
        error = 1;
        $error("Written addr %h byen %h expected %h, got %h", address, byteenable, expected, avmm_s_readdata[32*word_select +: 32]);
        $finish();
    end
endtask

initial begin
    test_done = '0;
    error = '0;

    clk = '1;
    rst_n = '0;

    avmm_s_chipselect    = '0;
    avmm_s_byteenable    = '0;
    avmm_s_writedata     = '0;
    avmm_s_read          = '0;
    avmm_s_write         = '0;
    avmm_s_address       = '0;

    #15;
    rst_n = '1;

    @(posedge clk);
    dmawr_task_free_i = $urandom();
    dmard_task_free_i = $urandom();

    // Check TASK FIFO reg (rdonly)
    test_register32(
        .byteenable ('h00F0),
        .address    ('0),
        .reset_val  (dmawr_task_free_i),
        .rdonly     ('1)
    );
    test_register32(
        .byteenable ('h0F00),
        .address    ('0),
        .reset_val  (dmard_task_free_i),
        .rdonly     ('1)
    );

    // Read first pointer (rdonly)
    // Dummy write
    test_register32(
        .byteenable ('h000F),
        .address    ('0),
        .reset_val  ({16'(1 << DMA_STRUCT_ADDR_WIDTH), 16'(DMA_CHANNEL_COUNT)}),
        .rdonly     ('1)
    );
    avmm_read(
        .byteenable ('h000F),
        .address    ('0)
    );
    curr_struct = avmm_s_readdata[31:16];

    // Testing registers
    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) begin
        test_register32(
            .byteenable ('h000F),
            .address    (curr_struct),
            .reset_val  (i == DMA_CHANNEL_COUNT-1 ? '0 : (i+2)<<DMA_STRUCT_ADDR_WIDTH),
            .rdonly     ('1)
        );
        test_register32(
            .byteenable ('h00F0),
            .address    (curr_struct),
            .reset_val  ('0),
            .rdonly     ('0)
        );
        test_register32(
            .byteenable ('h0F00),
            .address    (curr_struct),
            .reset_val  ('0),
            .rdonly     ('0)
        );
        test_register32(
            .byteenable ('hF000),
            .address    (curr_struct),
            .reset_val  (DMA_WORD_BYTES[i]),
            .rdonly     ('1)
        );
        test_register32(
            .byteenable ('h000F),
            .address    (curr_struct+'h10),
            .reset_val  (DMA_WQ_DEPTH[i]*DMA_WORD_BYTES[i]),
            .rdonly     ('1)
        );
        test_register32(
            .byteenable ('h00F0),
            .address    (curr_struct+'h10),
            .reset_val  (DMA_RQ_DEPTH[i]*DMA_WORD_BYTES[i]),
            .rdonly     ('1)
        );
        wdata_fifo_count_i[i] = $urandom();
        rdata_fifo_free_i [i] = $urandom();
        test_register32(
            .byteenable ('h0F00),
            .address    (curr_struct+'h10),
            .reset_val  (wdata_fifo_count_i[i]),
            .rdonly     ('1)
        );
        test_register32(
            .byteenable ('hF000),
            .address    (curr_struct+'h10),
            .reset_val  (rdata_fifo_free_i[i]),
            .rdonly     ('1)
        );

        avmm_read(
            .byteenable ('h000F),
            .address    (curr_struct)
        );
        curr_struct = avmm_s_readdata[31:0];
    end

    // Test dma addr outputs
    avmm_read(
        .byteenable ('h000F),
        .address    ('0)
    );
    curr_struct = avmm_s_readdata[31:16];
    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) begin
        expected_dma_addr[31:0] = $urandom();
        expected_dma_addr[63:32] = $urandom();
        avmm_write(
            .byteenable ('h00F0),
            .writedata  (expected_dma_addr[31:0]<<32),
            .address    (curr_struct)
        );
        avmm_write(
            .byteenable ('h0F00),
            .writedata  (expected_dma_addr[63:32]<<64),
            .address    (curr_struct)
        );
        @(posedge clk);
        assert (dma_addr_o[i] == expected_dma_addr) 
        else   begin
            $error("Wrong dma_address %d, expected %h, got %h", i, expected_dma_addr, dma_addr_o[i]);
            $finish();
        end

        avmm_read(
            .byteenable ('h000F),
            .address    (curr_struct)
        );
        curr_struct = avmm_s_readdata[31:0];
    end
    
    test_done = '1;
    
    `ifdef QUESTA
        $finish();
    `endif

end

endmodule