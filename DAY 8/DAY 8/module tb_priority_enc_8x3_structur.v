module tb_priority_enc_8x3_structural;
    reg [7:0] in;
    wire y2, y1, y0, valid;
 
    priority_enc_8x3_structural DUT (
        .in(in), .y2(y2), .y1(y1), .y0(y0), .valid(valid)
    );
 
    initial begin
        $display("   in     | y2 y1 y0 valid");
        $monitor("%b | %b  %b  %b   %b", in, y2, y1, y0, valid);
 
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