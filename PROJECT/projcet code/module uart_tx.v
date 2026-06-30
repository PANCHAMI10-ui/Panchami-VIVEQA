module uart_tx
#(
    parameter CLK_FREQ  = 24000000,
    parameter BAUD_RATE = 9600
)
(
    input  clk,
    input  [7:0] tx_data,
    input        tx_start,
    output reg   tx,
    output reg   tx_busy
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

reg [15:0] clk_count;
reg [2:0]  bit_index;
reg [7:0]  tx_shift;
reg [1:0]  state;

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

initial begin
    state     = IDLE;
    tx        = 1'b1;
    tx_busy   = 0;
    clk_count = 0;
    bit_index = 0;
end

always @(posedge clk)
begin
    case(state)
    IDLE:
    begin
        tx      <= 1'b1;
        tx_busy <= 0;
        if(tx_start)
        begin
            tx_shift <= tx_data;
            tx_busy  <= 1;
            state    <= START;
        end
    end
    START:
    begin
        tx <= 1'b0;
        if(clk_count == CLKS_PER_BIT - 1)
        begin
            clk_count <= 0;
            bit_index <= 0;
            state     <= DATA;
        end
        else
            clk_count <= clk_count + 1;
    end
    DATA:
    begin
        tx <= tx_shift[bit_index];
        if(clk_count == CLKS_PER_BIT - 1)
        begin
            clk_count <= 0;
            if(bit_index == 7)
                state <= STOP;
            else
                bit_index <= bit_index + 1;
        end
        else
            clk_count <= clk_count + 1;
    end
    STOP:
    begin
        tx <= 1'b1;
        if(clk_count == CLKS_PER_BIT - 1)
        begin
            clk_count <= 0;
            state     <= IDLE;
        end
        else
            clk_count <= clk_count + 1;
    end
    default: state <= IDLE;
    endcase
end
endmodule