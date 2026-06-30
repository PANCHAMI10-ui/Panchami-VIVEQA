module tb_counter_4bit_mod12_up;
    reg clk, rst, load, en;
    reg [3:0] d;
    wire [3:0] q;
 
    counter_4bit_mod12_up DUT (
        .clk(clk), .rst(rst), .load(load), .en(en), .d(d), .q(q)
    );
 
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $display(" time | rst load en  d   | q");
        $monitor(" %0t  |  %b   %b   %b  %b | %d", $time, rst, load, en, d, q);
 
        rst = 1; load = 0; en = 0; d = 4'b0000; #10;
        rst = 0;
 
        en = 1; #150;            // count 0..11..0..11 multiple wraps
 
        load = 1; d = 4'd9; #10; // load mid-value
        load = 0;
 
        en = 1; #60;             // count from 9, wrap at 11->0
 
        en = 0; #20;             // hold
 
        $finish;
    end
endmodule