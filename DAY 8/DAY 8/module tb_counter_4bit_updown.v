module tb_counter_4bit_updown;
    reg clk, rst, load, en, up_down;
    reg [3:0] d;
    wire [3:0] q;
 
    counter_4bit_updown DUT (
        .clk(clk), .rst(rst), .load(load), .en(en),
        .up_down(up_down), .d(d), .q(q)
    );
 
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $display(" time | rst load en up/dn  d   | q");
        $monitor(" %0t  |  %b   %b   %b   %b   %b | %d", $time, rst, load, en, up_down, d, q);
 
        rst = 1; load = 0; en = 0; up_down = 1; d = 4'b0000; #10;
        rst = 0;
 
        load = 1; d = 4'd5; #10;  // load value 5
        load = 0;
 
        en = 1; up_down = 1; #50; // count up from 5
 
        up_down = 0; #50;         // count down
 
        en = 0; #20;              // hold
 
        $finish;
    end
endmodule