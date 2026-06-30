module tb_decoder_2x4_df;
    reg  [1:0] in;
    reg  en;
    wire [3:0] out;
 
    decoder_2x4_df DUT (.in(in), .en(en), .out(out));
 
    initial begin
        $display(" en  in | out");
        $monitor("  %b  %b%b |  %b", en, in[1], in[0], out);
        en = 0; in = 2'b00;
        #10 en = 1; in = 2'b00;
        #10 in = 2'b01;
        #10 in = 2'b10;
        #10 in = 2'b11;
        #10 en = 0; in = 2'b10;
        #10 $finish;
    end
endmodule