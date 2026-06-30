module counter_4bit_mod12_up (
    input  clk, rst,
    input  load,
    input  en,
    input  [3:0] d,
    output reg [3:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 4'b0000;
        else if (load)
            q <= d;
        else if (en) begin
            if (q == 4'd11)
                q <= 4'd0;
            else
                q <= q + 1'b1;
        end
        else
            q <= q;
    end
endmodule