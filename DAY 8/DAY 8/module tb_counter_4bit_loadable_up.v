module tb_counter_4bit_loadable_up;
    reg clk, rst, load, en;
    reg [3:0] d;
    wire [3:0] q;
 
    counter_4bit_loadable_up DUT (
        .clk(clk), .rst(rst), .load(load), .en(en), .d(d), .q(q)
    );
 
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $display(" time | rst load en  d   | q");
        $monitor(" %0t  |  %b   %b   %b  %b | %b", $time, rst, load, en, d, q);
 
        rst = 1; load = 0; en = 0; d = 4'b0000; #10;
        rst = 0;
 
        en = 1; #50;            // count up freely
 
        load = 1; d = 4'b1010; #10;   // load value 10
        load = 0;
 
        en = 1; #40;             // continue counting from loaded value
 
        en = 0; #20;             // hold
 
        $finish;
    end
endmodule