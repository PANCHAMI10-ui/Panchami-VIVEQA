module tb_jk_ff;
    reg clk, rst, j, k;
    wire q;
 
    jk_ff DUT (.clk(clk), .rst(rst), .j(j), .k(k), .q(q));
 
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $display(" time | rst j k | q");
        $monitor(" %0t  |  %b  %b %b | %b", $time, rst, j, k, q);
 
        rst = 1; j = 0; k = 0; #10;
        rst = 0;
 
        j = 0; k = 0; #10;  // HOLD
        j = 0; k = 1; #10;  // RESET
        j = 1; k = 0; #10;  // SET
        j = 1; k = 1; #10;  // TOGGLE
        j = 1; k = 1; #10;  // TOGGLE again
        j = 0; k = 0; #10;  // HOLD
 
        $finish;
    end
endmodule