module tb_t_ff_using_dff;
    reg clk, rst, t;
    wire q;
 
    t_ff_using_dff DUT (.clk(clk), .rst(rst), .t(t), .q(q));
 
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $display(" time | rst t | q");
        $monitor(" %0t  |  %b  %b | %b", $time, rst, t, q);
 
        rst = 1; t = 0; #10;
        rst = 0;
 
        t = 0; #10;  // hold
        t = 1; #10;  // toggle
        t = 1; #10;  // toggle
        t = 0; #10;  // hold
        t = 1; #10;  // toggle
        t = 1; #10;  // toggle
 
        $finish;
    end
endmodule