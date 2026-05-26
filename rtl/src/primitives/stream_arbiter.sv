module stream_arbiter #(
    parameter DATA_WIDTH = 32,
    parameter INPUT_NUM  = 2 ,
    parameter AWAIT_HS   = 1 ,

    parameter ADDR_WIDTH = INPUT_NUM == 1 ? 1 : $clog2(INPUT_NUM)
) (
    input  logic                  ACLK               ,
    input  logic                  ARESETn            ,

    input  logic [DATA_WIDTH-1:0] data_i  [INPUT_NUM],
    input  logic [INPUT_NUM-1:0]  valid_i            ,
    output logic [INPUT_NUM-1:0]  ready_o            ,

    output logic [DATA_WIDTH-1:0] data_o             ,
    output logic                  valid_o            ,
    input  logic                  ready_i            ,
    output logic [ADDR_WIDTH-1:0] sel_o              
);

    logic [ADDR_WIDTH-1:0] current_grant;
    logic [ADDR_WIDTH-1:0] next_grant;
    logic [ADDR_WIDTH-1:0] increment;

    logic [INPUT_NUM*2 - 1:0] shifted_valid_i;

    assign sel_o = current_grant;
    assign shifted_valid_i = {valid_i, valid_i} >> current_grant;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            current_grant <= 0;
        end
        else begin
            if (AWAIT_HS) begin
                if (ready_i || !valid_i[current_grant]) begin
                    current_grant <= next_grant;
                end
            end
            else begin
                current_grant <= next_grant;
            end
        end
    end

    always_comb begin
        next_grant = current_grant;
        increment = 0;
        for (int i = INPUT_NUM-1; i > 0; i--) begin
            if (shifted_valid_i[i]) begin
                increment = i;
            end
        end

        next_grant = (next_grant + increment) >= INPUT_NUM ? (next_grant + increment - INPUT_NUM) : (next_grant + increment);
    end

    always_comb begin

        ready_o = '0;

        valid_o = valid_i[current_grant];
        data_o = data_i[current_grant];
        ready_o[current_grant] = ready_i;
    end
    
endmodule