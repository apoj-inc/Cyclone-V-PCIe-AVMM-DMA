module tb_dma;


parameter     DMA_CHANNEL_COUNT                     = 16         ;

parameter     DMA_BYTES_WIDTH                       = 22         ;
parameter     DMA_OFFFSET_WIDTH                     = 22         ;

parameter int DMA_WORD_BYTES    [DMA_CHANNEL_COUNT] = '{16{16  }};
parameter int DMA_WQ_DEPTH      [DMA_CHANNEL_COUNT] = '{16{16  }};
parameter int DMA_RQ_DEPTH      [DMA_CHANNEL_COUNT] = '{16{16  }};
parameter     DMA_TQ_DEPTH                          = 16         ;

parameter int MAX_WQ_DEPTH                          = 16         ;
parameter int MAX_RQ_DEPTH                          = 16         ;

parameter     BAR_DATA_WIDTH                        = 128        ;
parameter     BAR_ADDR_WIDTH                        = 12         ;

parameter     TX_DATA_WIDTH                         = 128        ;
parameter     TX_ADDR_WIDTH                         = 64         ;
parameter     TX_BURST_WIDTH                        = 6          ;

parameter MSIX_COUNT              = DMA_CHANNEL_COUNT                       ;
parameter BAR_DATA_BYTES          = BAR_DATA_WIDTH / 8                      ;
parameter TX_DATA_BYTES           = TX_DATA_WIDTH / 8                       ;
parameter DMA_WQ_ADDR_WIDTH       = $clog2(MAX_WQ_DEPTH)                    ;
parameter DMA_RQ_ADDR_WIDTH       = $clog2(MAX_RQ_DEPTH)                    ;
parameter DMA_TQ_ADDR_WIDTH       = $clog2(DMA_TQ_DEPTH)                    ;
parameter PBA_COUNT               = MSIX_COUNT / 64 + (MSIX_COUNT % 64 != 0);
parameter DMA_BURST_WIDTH         = DMA_BYTES_WIDTH - 4                     ;
parameter DMA_CHANNEL_COUNT_WIDTH = $clog2(DMA_CHANNEL_COUNT)               ;


logic                           test_done           ;
logic                           start_validation    ;
logic [DMA_CHANNEL_COUNT-1:0]   finished_validation ;
logic [TX_DATA_WIDTH-1:0]       fifo_data           ;
logic [TX_DATA_WIDTH-1:0]       tx_data             ;
logic [15:0]                    current_struct      ;
logic [DMA_CHANNEL_COUNT][31:0] msi_assertion_count ;

logic                       clk                                     ;
logic                       rst_n                                   ;

logic                       csr_s_chipselect                        ;
logic [BAR_DATA_BYTES-1:0]  csr_s_byteenable                        ;
logic [BAR_DATA_WIDTH-1:0]  csr_s_readdata                          ;
logic [BAR_DATA_WIDTH-1:0]  csr_s_writedata                         ;
logic                       csr_s_read                              ;
logic                       csr_s_write                             ;
logic                       csr_s_readdatavalid                     ;
logic                       csr_s_waitrequest                       ;
logic [BAR_ADDR_WIDTH-1:0]  csr_s_address                           ;

logic                       msix_s_chipselect                       ;
logic [BAR_DATA_BYTES-1:0]  msix_s_byteenable                       ;
logic [BAR_DATA_WIDTH-1:0]  msix_s_readdata                         ;
logic [BAR_DATA_WIDTH-1:0]  msix_s_writedata                        ;
logic                       msix_s_read                             ;
logic                       msix_s_write                            ;
logic                       msix_s_readdatavalid                    ;
logic                       msix_s_waitrequest                      ;
logic [BAR_ADDR_WIDTH-1:0]  msix_s_address                          ;

logic                       dec_s_chipselect                        ;
logic [BAR_DATA_BYTES-1:0]  dec_s_byteenable                        ;
logic [BAR_DATA_WIDTH-1:0]  dec_s_readdata                          ;
logic [BAR_DATA_WIDTH-1:0]  dec_s_writedata                         ;
logic                       dec_s_read                              ;
logic                       dec_s_write                             ;
logic                       dec_s_readdatavalid                     ;
logic                       dec_s_waitrequest                       ;
logic [BAR_ADDR_WIDTH-1:0]  dec_s_address                           ;

logic [MSIX_COUNT-1:0]      user_irq_i                              ;

logic                       user_msix_m_chipselect                  ;
logic [TX_DATA_BYTES-1:0]   user_msix_m_byteenable                  ;
logic [TX_DATA_WIDTH-1:0]   user_msix_m_readdata                    ;
logic [TX_DATA_WIDTH-1:0]   user_msix_m_writedata                   ;
logic                       user_msix_m_read                        ;
logic                       user_msix_m_write                       ;
logic [TX_BURST_WIDTH-1:0]  user_msix_m_burstcount                  ;
logic                       user_msix_m_readdatavalid               ;
logic                       user_msix_m_waitrequest                 ;
logic [TX_ADDR_WIDTH-1:0]   user_msix_m_address                     ;

logic                       tx_chipselect        [DMA_CHANNEL_COUNT];
logic [TX_DATA_BYTES-1:0]   tx_byteenable        [DMA_CHANNEL_COUNT];
logic [TX_DATA_WIDTH-1:0]   tx_readdata          [DMA_CHANNEL_COUNT];
logic [TX_DATA_WIDTH-1:0]   tx_writedata         [DMA_CHANNEL_COUNT];
logic                       tx_read              [DMA_CHANNEL_COUNT];
logic                       tx_write             [DMA_CHANNEL_COUNT];
logic [TX_BURST_WIDTH-1:0]  tx_burstcount        [DMA_CHANNEL_COUNT];
logic                       tx_readdatavalid     [DMA_CHANNEL_COUNT];
logic                       tx_waitrequest       [DMA_CHANNEL_COUNT];
logic [TX_ADDR_WIDTH-1:0]   tx_address           [DMA_CHANNEL_COUNT];

logic                       dma_wrdata_valid_i   [DMA_CHANNEL_COUNT];
logic                       dma_wrdata_ready_o   [DMA_CHANNEL_COUNT];
logic [DMA_WQ_ADDR_WIDTH:0] dma_wrdata_count_i   [DMA_CHANNEL_COUNT];
logic [TX_DATA_WIDTH-1:0]   dma_wrdata_data_i    [DMA_CHANNEL_COUNT];

logic                       dma_rddata_valid_o   [DMA_CHANNEL_COUNT];
logic                       dma_rddata_ready_i   [DMA_CHANNEL_COUNT];
logic [DMA_RQ_ADDR_WIDTH:0] dma_rddata_free_i    [DMA_CHANNEL_COUNT];
logic [TX_DATA_WIDTH-1:0]   dma_rddata_data_o    [DMA_CHANNEL_COUNT];


logic [TX_DATA_WIDTH+TX_ADDR_WIDTH+TX_DATA_WIDTH/8-1:0] user_msix_log [$];

always_ff @(posedge clk) begin
    if (user_msix_m_chipselect && user_msix_m_write && !user_msix_m_waitrequest) begin
        user_msix_log.push_back({user_msix_m_writedata, user_msix_m_address, user_msix_m_byteenable});
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        user_msix_m_waitrequest <= '1;
    end
    else begin
        user_msix_m_waitrequest <= $urandom();
    end
end

generate
    for (genvar i = 0; i < DMA_CHANNEL_COUNT; i++) begin : dma_data_fifos

        logic [TX_DATA_WIDTH-1:0] dma_fifo_write [$];
        logic [TX_DATA_WIDTH-1:0] dma_fifo_read  [$];

        logic [TX_DATA_WIDTH-1:0] dma_tx_write   [$];
        logic [TX_DATA_WIDTH-1:0] dma_tx_read    [$];

        logic                       dma_wrdata_valid_wr;
        logic                       dma_wrdata_ready_wr;
        logic [TX_DATA_WIDTH-1:0]   dma_wrdata_data_wr ;

        logic                       dma_rddata_valid_rd;
        logic                       dma_rddata_ready_rd;
        logic [TX_DATA_WIDTH-1:0]   dma_rddata_data_rd ;

        // MSI logging
        always_ff @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                msi_assertion_count[i] <= '0;
            end
            else begin
                if (tx_chipselect[i] && tx_write[i] && !tx_waitrequest[i] && (tx_address[i] == {32'('hFEE00000), 32'((i/4)*16)}) && (tx_byteenable[i] == ('h000F << ((i%4)*4))) && (tx_writedata[i] == (32'('hDEADBEE0 + i) << ((i%4)*32)))) begin
                    msi_assertion_count[i] <= msi_assertion_count[i] + 1;
                end
            end
        end

        // FIFO logging
        always_ff @(posedge clk) begin
            if (dma_wrdata_valid_wr && dma_wrdata_ready_wr) begin
                dma_fifo_write.push_back(dma_wrdata_data_wr);
            end
            if (dma_rddata_valid_rd && dma_rddata_ready_rd) begin
                dma_fifo_read.push_back(dma_rddata_data_rd);
            end

            
            if (tx_write[i] && !tx_waitrequest[i]) begin
                if (!((tx_address[i] == {32'('hFEE00000), 32'((i/4)*16)}) && (tx_byteenable[i] == ('h000F << ((i%4)*4))) && (tx_writedata[i] == (32'('hDEADBEE0 + i) << ((i%4)*32))))) begin
                    dma_tx_write.push_back(tx_writedata[i]);
                end
            end
            if (tx_readdatavalid[i]) begin
                dma_tx_read.push_back(tx_readdata[i]);
            end
        end

        always_ff @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                dma_wrdata_valid_wr <= '0;
                for (int i = 0; i < 4; i++) begin
                    dma_wrdata_data_wr[i*32 +: 32] <= $urandom();
                end

                dma_rddata_ready_rd <= '0;
            end
            else begin
                if (!dma_wrdata_valid_wr || (dma_wrdata_valid_wr && dma_wrdata_ready_wr)) begin
                    dma_wrdata_valid_wr <= $urandom();
                end
                if (dma_wrdata_valid_wr && dma_wrdata_ready_wr) begin
                    for (int i = 0; i < 4; i++) begin
                        dma_wrdata_data_wr[i*32 +: 32] <= $urandom();
                    end
                end

                dma_rddata_ready_rd <= $urandom();
            end
        end

        stream_fifo #(
            .DATA_WIDTH (TX_DATA_WIDTH  ),
            .FIFO_DEPTH (DMA_WQ_DEPTH[i])
        ) u_stream_fifo_dmawr (
            .ACLK    (clk                   ),
            .ARESETn (rst_n                 ),

            .data_i  (dma_wrdata_data_wr    ),
            .valid_i (dma_wrdata_valid_wr   ),
            .ready_o (dma_wrdata_ready_wr   ),
            .free_o  (                      ), // NC

            .data_o  (dma_wrdata_data_i [i] ),
            .valid_o (dma_wrdata_valid_i[i] ),
            .ready_i (dma_wrdata_ready_o[i] ),
            .count_o (dma_wrdata_count_i[i] )
        );

        stream_fifo #(
            .DATA_WIDTH (TX_DATA_WIDTH  ),
            .FIFO_DEPTH (DMA_WQ_DEPTH[i])
        ) u_stream_fifo_dmard (
            .ACLK    (clk                   ),
            .ARESETn (rst_n                 ),

            .data_i  (dma_rddata_data_o [i] ),
            .valid_i (dma_rddata_valid_o[i] ),
            .ready_o (dma_rddata_ready_i[i] ),
            .free_o  (dma_rddata_free_i [i] ), // NC

            .data_o  (dma_rddata_data_rd    ),
            .valid_o (dma_rddata_valid_rd   ),
            .ready_i (dma_rddata_ready_rd   ),
            .count_o (                      )  // NC
        );
    end

    for (genvar i = 0; i < DMA_CHANNEL_COUNT; i++) begin : tx_read_logic
        logic rdvalid_gate;
        logic [31:0] reads_pipelined;

        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                tx_waitrequest[i] <= '1;
                for (int j = 0; j < 4; j++) begin
                    tx_readdata[i][j*32 +: 32] <= $urandom();
                end
            end
            else begin
                tx_waitrequest[i] <= $urandom();
                if (tx_readdatavalid[i]) begin
                    for (int j = 0; j < 4; j++) begin
                        tx_readdata[i][j*32 +: 32] <= $urandom();
                    end
                end
            end
        end

        always_ff @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                reads_pipelined <= '0;
            end
            else begin
                if (tx_chipselect[i] && tx_read[i] && !tx_waitrequest[i]) begin
                    reads_pipelined <= reads_pipelined + tx_burstcount[i] - tx_readdatavalid[i];
                end
                else if (tx_readdatavalid[i]) begin
                    reads_pipelined <= reads_pipelined - 1;
                end
            end
        end

        always_ff @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                rdvalid_gate <= '0;
            end
            else begin
                rdvalid_gate <= $urandom();
            end
        end

        assign tx_readdatavalid[i] = (reads_pipelined != 0) & rdvalid_gate;
    end

    for (genvar i = 0; i < DMA_CHANNEL_COUNT; i++) begin : convenience
        logic                       loc_tx_chipselect   ;
        logic [TX_DATA_BYTES-1:0]   loc_tx_byteenable   ;
        logic [TX_DATA_WIDTH-1:0]   loc_tx_readdata     ;
        logic [TX_DATA_WIDTH-1:0]   loc_tx_writedata    ;
        logic                       loc_tx_read         ;
        logic                       loc_tx_write        ;
        logic [TX_BURST_WIDTH-1:0]  loc_tx_burstcount   ;
        logic                       loc_tx_readdatavalid;
        logic                       loc_tx_waitrequest  ;
        logic [TX_ADDR_WIDTH-1:0]   loc_tx_address      ;

        assign loc_tx_chipselect    = tx_chipselect   [i];
        assign loc_tx_byteenable    = tx_byteenable   [i];
        assign loc_tx_readdata      = tx_readdata     [i];
        assign loc_tx_writedata     = tx_writedata    [i];
        assign loc_tx_read          = tx_read         [i];
        assign loc_tx_write         = tx_write        [i];
        assign loc_tx_burstcount    = tx_burstcount   [i];
        assign loc_tx_readdatavalid = tx_readdatavalid[i];
        assign loc_tx_waitrequest   = tx_waitrequest  [i];
        assign loc_tx_address       = tx_address      [i];
    end
endgenerate

avmm_dma_top #(
    .DMA_CHANNEL_COUNT (DMA_CHANNEL_COUNT ),

    .DMA_BYTES_WIDTH   (DMA_BYTES_WIDTH   ),
    .DMA_OFFFSET_WIDTH (DMA_OFFFSET_WIDTH ),

    .DMA_WORD_BYTES    (DMA_WORD_BYTES    ),
    .DMA_WQ_DEPTH      (DMA_WQ_DEPTH      ),
    .DMA_RQ_DEPTH      (DMA_RQ_DEPTH      ),
    .DMA_TQ_DEPTH      (DMA_TQ_DEPTH      ),

    .MAX_WQ_DEPTH      (MAX_WQ_DEPTH      ),
    .MAX_RQ_DEPTH      (MAX_RQ_DEPTH      ),

    .BAR_DATA_WIDTH    (BAR_DATA_WIDTH    ),
    .BAR_ADDR_WIDTH    (BAR_ADDR_WIDTH    ),

    .TX_DATA_WIDTH     (TX_DATA_WIDTH     ),
    .TX_ADDR_WIDTH     (TX_ADDR_WIDTH     ),
    .TX_BURST_WIDTH    (TX_BURST_WIDTH    )
) dut (
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

    .user_irq_i                (user_irq_i               ),

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

    .dma_wrdata_valid_i        (dma_wrdata_valid_i       ),
    .dma_wrdata_ready_o        (dma_wrdata_ready_o       ),
    .dma_wrdata_count_i        (dma_wrdata_count_i       ),
    .dma_wrdata_data_i         (dma_wrdata_data_i        ),

    .dma_rddata_valid_o        (dma_rddata_valid_o       ),
    .dma_rddata_ready_i        (dma_rddata_ready_i       ),
    .dma_rddata_free_i         (dma_rddata_free_i        ),
    .dma_rddata_data_o         (dma_rddata_data_o        )
);

always #10 clk = ~clk;

initial begin
    test_done = '0;

    clk = '1;
    rst_n = '0;

    user_irq_i = '0;

    csr_s_chipselect  = '0;
    csr_s_byteenable  = '0;
    csr_s_writedata   = '0;
    csr_s_read        = '0;
    csr_s_write       = '0;
    csr_s_address     = '0;

    msix_s_chipselect = '0;
    msix_s_byteenable = '0;
    msix_s_writedata  = '0;
    msix_s_read       = '0;
    msix_s_write      = '0;
    msix_s_address    = '0;

    dec_s_chipselect  = '0;
    dec_s_byteenable  = '0;
    dec_s_writedata   = '0;
    dec_s_read        = '0;
    dec_s_write       = '0;
    dec_s_address     = '0;

    #15;
    rst_n = '1;
    @(posedge clk);

    csr_s_chipselect = '1;
    csr_s_byteenable = 'h000F;
    csr_s_read       = '1;
    csr_s_write      = '0;
    csr_s_writedata  = '0;
    csr_s_address    = '0;
    @(posedge clk);
    csr_s_read       = '0;
    while (!csr_s_readdatavalid) begin
        @(posedge clk);
    end
    current_struct = csr_s_readdata[31:16];
    $display("DMA channels: %d;", csr_s_readdata[15:0]);
    $display("Address of struct 0: 0x%x;", csr_s_readdata[31:16]);

    // DMA configuration

    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) begin
        // Write DMA ADDR LO
        csr_s_chipselect = '1;
        csr_s_byteenable = 'h00F0;
        csr_s_read       = '0;
        csr_s_write      = '1;
        csr_s_writedata  = '0;
        csr_s_address    = current_struct;
        @(posedge clk);
        while (csr_s_waitrequest) begin
            @(posedge clk);
        end

        // Write DMA ADDR HI
        csr_s_chipselect = '1;
        csr_s_byteenable = 'h0F00;
        csr_s_read       = '0;
        csr_s_write      = '1;
        csr_s_writedata  = (i << 64) << 28;
        csr_s_address    = current_struct;
        @(posedge clk);
        while (csr_s_waitrequest) begin
            @(posedge clk);
        end

        csr_s_chipselect = '1;
        csr_s_byteenable = 'h000F;
        csr_s_read       = '1;
        csr_s_write      = '0;
        csr_s_writedata  = '0;
        csr_s_address    = current_struct;
        @(posedge clk);
        csr_s_read       = '0;
        while (!csr_s_readdatavalid) begin
            @(posedge clk);
        end
        current_struct = csr_s_readdata[31:0];
        $write("DMA address for channel %u: 0x%x; ", 4'(i), dut.dma_addr[i]);
        $display("Next address: 0x%x;", current_struct);
    end

    for (int i = 0; i < DMA_CHANNEL_COUNT; i++) begin
        // Write MSIX
        msix_s_chipselect = '1;
        msix_s_byteenable = 'hFFFF;
        msix_s_read       = '0;
        msix_s_write      = '1;
        msix_s_writedata  = {32'(i % 2), 32'('hDEADBEE0 + i), 32'('hFEE00000), 32'(i*4)}; // ctrl, data, addr_hi, addr_lo
        msix_s_address    = i * 'h10;
        @(posedge clk);
        while (csr_s_waitrequest) begin
            @(posedge clk);
        end
        @(posedge clk);
        $write("MSI-X for DMA channel %u: mask 0x%x, data 0x%x, addr 0x%x;\n", 4'(i), dut.dma_msix_mask[i][0], dut.dma_msix_data[i], dut.dma_msix_addrs[i]);
    end
    
    for (int i = DMA_CHANNEL_COUNT; i < DMA_CHANNEL_COUNT*2; i++) begin
        int index;
        index = i - DMA_CHANNEL_COUNT;
        // Write MSIX
        msix_s_chipselect = '1;
        msix_s_byteenable = 'hFFFF;
        msix_s_read       = '0;
        msix_s_write      = '1;
        msix_s_writedata  = {32'(i % 2), 32'('hDEADBEE0 + i), 32'('hFEE00000), 32'(i*4)}; // ctrl, data, addr_hi, addr_lo
        msix_s_address    = i * 'h10;
        @(posedge clk);
        while (csr_s_waitrequest) begin
            @(posedge clk);
        end
        @(posedge clk);
        $write("MSI-X for user %u: mask 0x%x, data 0x%x, addr 0x%x;\n", 4'(i), dut.user_msix_mask[index][0], dut.user_msix_data[index], dut.user_msix_addrs[index]);
    end

    
    // DMA action

    for (int i = 0; i < 2; i++) begin
        // Short operations
        for (int i = 0; i < DMA_CHANNEL_COUNT; i++) begin
            dec_s_chipselect = '1;
            dec_s_byteenable = 'hFF00;
            dec_s_read       = '0;
            dec_s_write      = '1;
            dec_s_writedata  = (((22'(16*16)) << 32) | 22'('h100)) << 64;
            dec_s_address    = i << 4;
            @(posedge clk);
            while (dec_s_waitrequest) begin
                @(posedge clk);
            end
            dec_s_chipselect = '1;
            dec_s_byteenable = 'h00FF;
            dec_s_read       = '0;
            dec_s_write      = '1;
            dec_s_writedata  = ((22'(16*16)) << 32) | 22'('h0);
            dec_s_address    = i << 4;
            @(posedge clk);
            while (dec_s_waitrequest) begin
                @(posedge clk);
            end
        end
        // Long operations
        for (int i = 0; i < DMA_CHANNEL_COUNT; i++) begin
            dec_s_chipselect = '1;
            dec_s_byteenable = 'hFF00;
            dec_s_read       = '0;
            dec_s_write      = '1;
            dec_s_writedata  = (((22'(128*16)) << 32) | 22'('h100)) << 64;
            dec_s_address    = i << 4;
            @(posedge clk);
            while (dec_s_waitrequest) begin
                @(posedge clk);
            end
            dec_s_chipselect = '1;
            dec_s_byteenable = 'h00FF;
            dec_s_read       = '0;
            dec_s_write      = '1;
            dec_s_writedata  = ((22'(128*16)) << 32) | 22'('h0);
            dec_s_address    = i << 4;
            @(posedge clk);
            while (dec_s_waitrequest) begin
                @(posedge clk);
            end
        end
        dec_s_write      = '0;

        for (int j = 0; j < DMA_CHANNEL_COUNT; j++) begin
            repeat (100) @(posedge clk);
            while (msi_assertion_count[j] != (8 - j%2*4 - (1-i)*4)) begin
                @(posedge clk);
            end
        
            // Demask masked MSIX
            msix_s_chipselect = '1;
            msix_s_byteenable = 'hFFFF;
            msix_s_read       = '0;
            msix_s_write      = '1;
            msix_s_writedata  = {32'(1'b0), 32'('hDEADBEE0 + j), 32'('hFEE00000), 32'(j*4)}; // ctrl, data, addr_hi, addr_lo
            msix_s_address    = j * 'h10;
            @(posedge clk);
            while (csr_s_waitrequest) begin
                @(posedge clk);
            end
            @(posedge clk);
            $write("MSI-X for DMA channel %u: mask 0x%x, data 0x%x, addr 0x%x;\n", 4'(j), dut.dma_msix_mask[j][0], dut.dma_msix_data[j], dut.dma_msix_addrs[j]);
        end
    end

    // Test user IRQs
    for (int i = 0; i < MSIX_COUNT; i++) begin
        user_irq_i[i] = 1;
        @(posedge clk);
        user_irq_i[i] = 0;
    end
    while (user_msix_log.size() != MSIX_COUNT/2) begin
        @(posedge clk);
    end
    for (int i = 0; i < MSIX_COUNT/2; i++) begin
        user_msix_log.pop_front();
    end
    for (int i = 6; i < MSIX_COUNT; i++) begin
        user_irq_i[i] = 1;
        @(posedge clk);
        user_irq_i[i] = 0;
    end
    while (user_msix_log.size() != (MSIX_COUNT-6)/2) begin
        @(posedge clk);
    end
    for (int i = 0; i < (MSIX_COUNT-6)/2; i++) begin
        user_msix_log.pop_front();
    end
    for (int i = DMA_CHANNEL_COUNT; i < DMA_CHANNEL_COUNT*2; i++) begin
        int index;
        index = i - DMA_CHANNEL_COUNT;
        // Write MSIX
        msix_s_chipselect = '1;
        msix_s_byteenable = 'hF000;
        msix_s_read       = '0;
        msix_s_write      = '1;
        msix_s_writedata  = {32'(0), 32'('hDEADBEE0 + i), 32'('hFEE00000), 32'(i*4)}; // ctrl, data, addr_hi, addr_lo
        msix_s_address    = i * 'h10;
        @(posedge clk);
        while (csr_s_waitrequest) begin
            @(posedge clk);
        end
        @(posedge clk);
        $write("MSI-X for user %u: mask 0x%x, data 0x%x, addr 0x%x;\n", 4'(index), dut.user_msix_mask[index][0], dut.user_msix_data[index], dut.user_msix_addrs[index]);
    end
    while (user_msix_log.size() != MSIX_COUNT/2) begin
        @(posedge clk);
    end
    for (int i = 0; i < MSIX_COUNT/2; i++) begin
        user_msix_log.pop_front();
    end

    repeat (100) @(posedge clk);
    
    assert (user_msix_log.size() == 0) 
    else   begin
        $error("Extra transactions on user MSIXs");
        $finish();
    end
    
    // Validate contents
    start_validation = 1;

    while (finished_validation != DMA_CHANNEL_COUNT'('1)) begin
        @(posedge clk);
    end
    
    test_done = '1;

    `ifdef QUESTA
        $finish();
    `endif
    
end

generate
    for (genvar i = 0; i < DMA_CHANNEL_COUNT; i++) begin : fifo_validator
        logic [31:0] iter;

        initial begin
            finished_validation[i] = 0;

            @(posedge start_validation);

            iter = 0;
            
            assert ((128 + 16)*2 == dma_data_fifos[i].dma_tx_write.size()) 
            else   begin
                $error("Mismatched write sizes channel %d: %d expected, %d got", i, (128 + 16)*2, dma_data_fifos[i].dma_tx_write.size());
                $finish();
            end
            

            while (dma_data_fifos[i].dma_tx_write.size()) begin
                fifo_data = dma_data_fifos[i].dma_fifo_write.pop_front();
                tx_data   = dma_data_fifos[i].dma_tx_write.pop_front();

                assert (fifo_data == tx_data) 
                else   begin
                    $error("Erroneous write data channel %d: iter %d, %x dma_fifo, %x dma_tx", i, iter, fifo_data, tx_data);
                    $finish();
                end
                iter = iter + 1;
            end


            iter = 0;

            assert ((128 + 16)*2 == dma_data_fifos[i].dma_tx_read.size()) 
            else   begin
                $error("Mismatched read sizes channel %d: %d expected, %d got", (128 + 16)*2, i, dma_data_fifos[i].dma_tx_read.size());
                $finish();
            end


            while (dma_data_fifos[i].dma_tx_read.size()) begin
                fifo_data = dma_data_fifos[i].dma_fifo_read.pop_front();
                tx_data   = dma_data_fifos[i].dma_tx_read.pop_front();

                assert (fifo_data == tx_data) 
                else   begin
                    $error("Erroneous read data channel %d: iter %d, %x dma_fifo, %x dma_tx", i, iter, fifo_data, tx_data);
                    $finish();
                end
                iter = iter + 1;
            end

            $display("Channel %d data checking success", i);
            finished_validation[i] = 1;
        end
    end
endgenerate

endmodule