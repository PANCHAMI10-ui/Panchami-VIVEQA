module tb_decoder_3x8;
    reg  [2:0] in;
    reg  en;
    wire [7:0] out;
 
    decoder_3x8 DUT (.in(in), .en(en), .out(out));
 
    integer i;
    initial begin
        $display(" en  in  | out");
        $monitor("  %b  %b  | %b", en, in, out);
 
        en = 0; in = 3'b000; #10;
        en = 1;
        for (i = 0; i < 8; i = i + 1) begin
            in = i;
            #10;
        end
        en = 0; #10;
        $finish;
    end
endmodule