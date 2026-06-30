module jk_ff (
    input  clk, rst,
    input  j, k,
    output reg q
);
    // Parameters describing JK operation scenarios
    parameter HOLD   = 2'b00;
    parameter RESET  = 2'b01;
    parameter SET    = 2'b10;
    parameter TOGGLE = 2'b11;
 
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 1'b0;
        else begin
            case ({j, k})
                HOLD:   q <= q;        // J=0,K=0 -> Hold
                RESET:  q <= 1'b0;     // J=0,K=1 -> Reset
                SET:    q <= 1'b1;     // J=1,K=0 -> Set
                TOGGLE: q <= ~q;       // J=1,K=1 -> Toggle
                default: q <= q;
            endcase
        end
    end
endmodule
