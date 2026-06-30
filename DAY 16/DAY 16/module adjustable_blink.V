module adjustable_blink(
    input clk, 
    input btn1, 
    input btn2,
    output reg [7:0] led = 8'd0 
);

    reg btn1_prev, btn2_prev;
    reg [2:0] speed = 3'd2; 
    reg [24:0] counter = 25'd0;

    always @(posedge clk) begin

        btn1_prev <= btn1;
        btn2_prev <= btn2;

        if (btn1 && !btn1_prev && speed < 3'd4) 
            speed <= speed + 1; 
        else if (btn2 && !btn2_prev && speed > 3'd0) 
            speed <= speed - 1; 

        if (counter >= (25'd1_499_999 << (4 - speed))) begin
            counter <= 25'd0;
            led[0] <= ~led[0]; 
        end else begin
            counter <= counter + 1;
        end

        led[7:1] <= 7'd0; 
    end

endmodule