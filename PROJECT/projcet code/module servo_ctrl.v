module servo_ctrl
#(
    parameter CLK_FREQ = 24000000
)
(
    input  wire clk,
    input  wire trigger,
    output reg  servo_pwm
);

// PWM: 20ms period, 0deg=1ms, 90deg=1.5ms
localparam PWM_PERIOD  = 480000;  // 20ms at 24MHz
localparam PULSE_0DEG  = 24000;   // 1.0ms = 0 degrees
localparam PULSE_90DEG = 36000;   // 1.5ms = 90 degrees
localparam HOLD_TIME   = 24000000; // 1 second at 24MHz

localparam IDLE  = 2'd0;
localparam OPEN  = 2'd1;
localparam CLOSE = 2'd2;

reg [1:0]  state       = IDLE;
reg [19:0] pwm_count   = 0;
reg [24:0] hold_count  = 0;
reg [19:0] pulse_width = PULSE_0DEG;

// PWM generation
always @(posedge clk) begin
    if(pwm_count >= PWM_PERIOD - 1)
        pwm_count <= 0;
    else
        pwm_count <= pwm_count + 1;
    servo_pwm <= (pwm_count < pulse_width) ? 1'b1 : 1'b0;
end

// State machine
always @(posedge clk) begin
    case(state)
        IDLE: begin
            pulse_width <= PULSE_0DEG;
            hold_count  <= 0;
            if(trigger)
                state <= OPEN;
        end
        OPEN: begin
            pulse_width <= PULSE_90DEG;
            hold_count  <= hold_count + 1;
            if(hold_count >= HOLD_TIME - 1) begin
                hold_count <= 0;
                state <= CLOSE;
            end
        end
        CLOSE: begin
            pulse_width <= PULSE_0DEG;
            hold_count  <= hold_count + 1;
            if(hold_count >= HOLD_TIME - 1) begin
                hold_count <= 0;
                state <= IDLE;
            end
        end
        default: state <= IDLE;
    endcase
end

endmodule