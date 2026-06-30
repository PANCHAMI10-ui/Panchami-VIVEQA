module multi_freq_blinker (
    input  wire clk,        // 24 MHz board oscillator
    input  wire rst_n,      // active-low reset (slide switch)
    output reg  L1, L2, L3, L4
);
    parameter CLK_FREQ = 24_000_000;

    reg [31:0] cnt1, cnt2, cnt3, cnt4;

    localparam T1 = CLK_FREQ / (2*1);  // 1 Hz
    localparam T2 = CLK_FREQ / (2*2);  // 2 Hz
    localparam T3 = CLK_FREQ / (2*4);  // 4 Hz
    localparam T4 = CLK_FREQ / (2*8);  // 8 Hz

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt1 <= 0; cnt2 <= 0; cnt3 <= 0; cnt4 <= 0;
            L1 <= 0; L2 <= 0; L3 <= 0; L4 <= 0;
        end else begin
            if (cnt1 == T1-1) begin cnt1 <= 0; L1 <= ~L1; end else cnt1 <= cnt1 + 1;
            if (cnt2 == T2-1) begin cnt2 <= 0; L2 <= ~L2; end else cnt2 <= cnt2 + 1;
            if (cnt3 == T3-1) begin cnt3 <= 0; L3 <= ~L3; end else cnt3 <= cnt3 + 1;
            if (cnt4 == T4-1) begin cnt4 <= 0; L4 <= ~L4; end else cnt4 <= cnt4 + 1;
        end
    end
endmodule