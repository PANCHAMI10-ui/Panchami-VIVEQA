module seq_detect_110_lsb(
    input wire clk,
    input wire reset,
    input wire in_bit,
    output reg out_toggle
);
    // State Encoding
    parameter [1:0] A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;
    reg [1:0] current_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= A;
            out_toggle <= 1'b0;
        end else begin
            current_state <= next_state;
            if (next_state == D) begin
                out_toggle <= ~out_toggle; // Toggle output when entering state D
            end
        end
    end

    always @(*) begin
        case (current_state)
            A: next_state = in_bit ? B : A;
            B: next_state = in_bit ? B : C;
            C: next_state = in_bit ? D : A;
            D: next_state = in_bit ? B : A; 
            default: next_state = A;
        endcase
    end
endmodule  