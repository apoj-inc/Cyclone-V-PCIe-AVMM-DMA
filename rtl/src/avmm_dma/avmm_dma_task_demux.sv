module avmm_dma_task_demux #(
    parameter     DMA_CHANNEL_COUNT                     = 16         ,
    parameter     DMA_OFFFSET_WIDTH                     = 22         ,
    parameter     DMA_BYTES_WIDTH                       = 22         ,

    parameter int DMA_WQ_DEPTH      [DMA_CHANNEL_COUNT] = '{16{1024}},
    parameter int DMA_RQ_DEPTH      [DMA_CHANNEL_COUNT] = '{16{1024}},

    parameter     TX_BURST_WIDTH                        = 6          ,

    parameter DMA_BURST_WIDTH         = DMA_BYTES_WIDTH - 4                                   ,
    parameter DMA_CHANNEL_COUNT_WIDTH = DMA_CHANNEL_COUNT == 1 ? 1 : $clog2(DMA_CHANNEL_COUNT)
) (
    input  logic                               clk                                      ,
    input  logic                               rst_n                                    ,

    input  logic                               in_dma_task_valid_i                      ,
    output logic                               in_dma_task_ready_o                      ,
    input  logic [DMA_CHANNEL_COUNT_WIDTH-1:0] in_dma_task_channel_i                    ,
    input  logic [DMA_BURST_WIDTH-1:0]         in_dma_task_burst_i                      ,
    input  logic [DMA_OFFFSET_WIDTH-1:0]       in_dma_task_offset_i                     ,
    input  logic                               in_dma_task_write_i                      ,
    
    output logic [DMA_CHANNEL_COUNT-1:0]       out_dma_task_valid_o                     ,
    input  logic [DMA_CHANNEL_COUNT-1:0]       out_dma_task_ready_i                     ,
    output logic [DMA_BURST_WIDTH-1:0]         out_dma_task_burst_o  [DMA_CHANNEL_COUNT],
    output logic [DMA_OFFFSET_WIDTH-1:0]       out_dma_task_offset_o [DMA_CHANNEL_COUNT],
    output logic [DMA_CHANNEL_COUNT-1:0]       out_dma_task_write_o                     ,
    output logic [TX_BURST_WIDTH-1:0]          out_dma_task_init_o   [DMA_CHANNEL_COUNT]
);

    logic in_dma_task_ready_next;

    logic [DMA_CHANNEL_COUNT-1:0] out_dma_task_valid_next                     ;
    logic [DMA_BURST_WIDTH-1:0]   out_dma_task_burst_next  [DMA_CHANNEL_COUNT];
    logic [DMA_OFFFSET_WIDTH-1:0] out_dma_task_offset_next [DMA_CHANNEL_COUNT];
    logic [DMA_CHANNEL_COUNT-1:0] out_dma_task_write_next                     ;
    logic [TX_BURST_WIDTH-1:0]    out_dma_task_init_next   [DMA_CHANNEL_COUNT];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_dma_task_ready_o <= '1;

            out_dma_task_valid_o  <= '0            ;
            out_dma_task_burst_o  <= '{default: '0};
            out_dma_task_offset_o <= '{default: '0};
            out_dma_task_write_o  <= '0            ;
            out_dma_task_init_o   <= '{default: '0};
        end
        else begin
            in_dma_task_ready_o <= in_dma_task_ready_next;

            out_dma_task_valid_o  <= out_dma_task_valid_next ;
            out_dma_task_burst_o  <= out_dma_task_burst_next ;
            out_dma_task_offset_o <= out_dma_task_offset_next;
            out_dma_task_write_o  <= out_dma_task_write_next ;
            out_dma_task_init_o   <= out_dma_task_init_next  ;
        end
    end
    
    always_comb begin
        
        if (!in_dma_task_ready_o && in_dma_task_valid_i && (out_dma_task_valid_o[in_dma_task_channel_i] != 1)) begin
            in_dma_task_ready_next = '1;
        end
        else begin
            in_dma_task_ready_next = '0;
        end
    end
    
    always_comb begin
        out_dma_task_valid_next  = out_dma_task_valid_o ;
        out_dma_task_burst_next  = out_dma_task_burst_o ;
        out_dma_task_offset_next = out_dma_task_offset_o;
        out_dma_task_write_next  = out_dma_task_write_o ;
        out_dma_task_init_next   = out_dma_task_init_o  ;
        
        for (int i = 0; i < DMA_CHANNEL_COUNT; i++) begin
            logic [TX_BURST_WIDTH-1:0] W_BURST_COMPARATOR;
            logic [TX_BURST_WIDTH-1:0] R_BURST_COMPARATOR;
            W_BURST_COMPARATOR = (DMA_WQ_DEPTH[i] < {TX_BURST_WIDTH{1'b1}}) ? DMA_WQ_DEPTH[i] : {TX_BURST_WIDTH{1'b1}};
            R_BURST_COMPARATOR = (DMA_RQ_DEPTH[i] < {TX_BURST_WIDTH{1'b1}}) ? DMA_RQ_DEPTH[i] : {TX_BURST_WIDTH{1'b1}};

            if (in_dma_task_valid_i && in_dma_task_ready_o && (in_dma_task_channel_i == i) && (out_dma_task_valid_o[i] != '1)) begin
                out_dma_task_valid_next [i] = '1                  ;
                out_dma_task_burst_next [i] = in_dma_task_burst_i ;
                out_dma_task_offset_next[i] = in_dma_task_offset_i;
                out_dma_task_write_next [i] = in_dma_task_write_i ;
                out_dma_task_init_next  [i] = in_dma_task_write_i ? ((in_dma_task_burst_i > W_BURST_COMPARATOR) ? W_BURST_COMPARATOR : in_dma_task_burst_i) :
                                                                    ((in_dma_task_burst_i > R_BURST_COMPARATOR) ? R_BURST_COMPARATOR : in_dma_task_burst_i);
            end

            if (out_dma_task_valid_o[i] && out_dma_task_ready_i[i]) begin
                out_dma_task_valid_next [i] = '0;
            end
        end
    end
    
endmodule