module tb_mux4x1_using_2x1;
    reg i0, i1, i2, i3;
    reg [1:0] sel;
    wire y;
 
    mux4x1_using_2x1 DUT (
        .i0(i0), .i1(i1), .i2(i2), .i3(i3), .sel(sel), .y(y)
    );
 
    initial begin
        i0 = 0; i1 = 1; i2 = 0; i3 = 1;
        $display("sel | i0 i1 i2 i3 | y");
        $monitor(" %b  | %b  %b  %b  %b | %b", sel, i0, i1, i2, i3, y);
 
        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;
 
        i0 = 1; i1 = 0; i2 = 1; i3 = 0;
        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;
        $finish;
    end
endmodule