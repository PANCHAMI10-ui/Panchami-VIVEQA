module counter_4bit_updown (
    input  clk, rst,
    input  load,
    input  en,
    input  up_down,
    input  [3:0] d,
    output reg [3:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 4'b0000;
        else if (load)
            q <= d;
        else if (en) begin
            if (up_down)
                q <= q + 1'b1;   // count up
            else
                q <= q - 1'b1;   // count down
        end
        else
            q <= q;
    end
endmodule