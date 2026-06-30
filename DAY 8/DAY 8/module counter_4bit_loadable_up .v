module counter_4bit_loadable_up (
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
        else if (en)
            q <= q + 1'b1;
        else
            q <= q;
    end
endmodule
 