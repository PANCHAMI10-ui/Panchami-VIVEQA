module uart_rx
#(
    parameter CLK_FREQ  = 24000000,
    parameter BAUD_RATE = 9600
)
(
    input  clk,
    input  rx,
    output reg [7:0] rx_data,
    output reg       rx_done
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

reg [15:0] clk_count;
reg [2:0]  bit_index;
reg [7:0]  rx_shift;
reg [1:0]  state;

reg rx_sync1, rx_sync2;
always @(posedge clk) begin
    rx_sync1 <= rx;
    rx_sync2 <= rx_sync1;
end

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

always @(posedge clk)
begin
    rx_done <= 0;
    case(state)
    IDLE:
    begin
        if(rx_sync2 == 0)
        begin
            clk_count <= CLKS_PER_BIT/2 - 1;
            state     <= START;
        end
    end
    START:
    begin
        if(clk_count == 0)
        begin
            if(rx_sync2 == 0)
            begin
                clk_count <= CLKS_PER_BIT - 1;
                bit_index <= 0;
                state     <= DATA;
            end
            else
                state <= IDLE;
        end
        else
            clk_count <= clk_count - 1;
    end
    DATA:
    begin
        if(clk_count == 0)
        begin
            rx_shift[bit_index] <= rx_sync2;
            if(bit_index == 7)
            begin
                clk_count <= CLKS_PER_BIT - 1;
                state     <= STOP;
            end
            else
            begin
                clk_count <= CLKS_PER_BIT - 1;
                bit_index <= bit_index + 1;
            end
        end
        else
            clk_count <= clk_count - 1;
    end
    STOP:
    begin
        if(clk_count == 0)
        begin
            if(rx_sync2 == 1)
            begin
                rx_data <= rx_shift;
                rx_done <= 1;
            end
            state <= IDLE;
        end
        else
            clk_count <= clk_count - 1;
    end
    default: state <= IDLE;
    endcase
end
endmodule