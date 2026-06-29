module largest_digit_fsm (
    input wire clk,
    input wire reset,
    input wire [1:0] in_digit, // 2-bit input representing {0, 1, 2, 3}
    output reg [1:0] max_out   // 2-bit output
);
    // State Encoding
    parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;
    parameter S3 = 2'b11;

    reg [1:0] current_state, next_state;

    // State Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S0;
            max_out <= 2'b00;
        end else begin
            current_state <= next_state;
            max_out <= next_state; // Moore output is equivalent to state
        end
    end

    // Next State Combinational Logic
    always @(*) begin
        case (current_state)
            S0: begin
                case (in_digit)
                    2'b01: next_state = S1;
                    2'b10: next_state = S2;
                    2'b11: next_state = S3;
                    default: next_state = S0;
                endcase
            end
            S1: begin
                case (in_digit)
                    2'b10: next_state = S2;
                    2'b11: next_state = S3;
                    default: next_state = S1;
                endcase
            end
            S2: begin
                case (in_digit)
                    2'b11: next_state = S3;
                    default: next_state = S2;
                endcase
            end
            S3: next_state = S3; // Stays max
            default: next_state = S0;
        endcase
    end
endmodule for this also