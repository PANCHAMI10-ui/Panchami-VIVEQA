module shift_register_leds (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       BTN_LEFT,   // SS1
    input  wire       BTN_RIGHT,  // SS2
    output reg [7:0]  LED
);
    reg btn_l_d, btn_r_d;
    wire btn_l_edge = BTN_LEFT  & ~btn_l_d;
    wire btn_r_edge = BTN_RIGHT & ~btn_r_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin btn_l_d <= 0; btn_r_d <= 0; end
        else begin btn_l_d <= BTN_LEFT; btn_r_d <= BTN_RIGHT; end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            LED <= 8'b0000_0001;
        else if (btn_l_edge)
            LED <= {LED[6:0], LED[7]};   // shift left, wrap
        else if (btn_r_edge)
            LED <= {LED[0], LED[7:1]};   // shift right, wrap
    end
endmodule