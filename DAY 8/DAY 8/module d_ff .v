module t_ff_using_dff (
    input  clk, rst,
    input  t,
    output q
);
    wire d_in;
 
    assign d_in = t ^ q;
 
    d_ff DFF0 (.clk(clk), .rst(rst), .d(d_in), .q(q));
endmodule