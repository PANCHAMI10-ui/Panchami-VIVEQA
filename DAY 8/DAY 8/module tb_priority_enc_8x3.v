module tb_priority_enc_8x3;
    reg  [7:0] in;
    wire [2:0] y;
    wire valid;
 
    priority_enc_8x3 DUT (.in(in), .y(y), .valid(valid));
 
    initial begin
        $display("   in     | y  valid");
        $monitor("%b | %b   %b", in, y, valid);
 
        in = 8'b00000000; #10;
        in = 8'b00000001; #10;
        in = 8'b00000010; #10;
        in = 8'b00000101; #10;
        in = 8'b00011000; #10;
        in = 8'b00100100; #10;
        in = 8'b01000000; #10;
        in = 8'b10000000; #10;
        in = 8'b11111111; #10;
        $finish;
    end
endmodule