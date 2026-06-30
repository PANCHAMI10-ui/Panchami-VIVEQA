module parking_top(
    input  wire clk,
    input  wire rx,
    output wire tx,
    output wire [7:0] led,
    output wire servo_pwm,
    output wire buzzer
);

wire [7:0] rx_data;
wire       rx_done;
wire       tx_busy;

reg [7:0]  slot_reg   = 8'b00000000;
reg [7:0]  tx_data    = 8'b00000000;
reg        tx_start   = 1'b0;
reg        servo_trig = 1'b0;

// Buzzer
reg [23:0] buzz_count  = 0;
reg        buzz_active = 1'b0;
reg [11:0] pwm_count   = 0;
reg        buzzer_pwm  = 1'b0;

// All slots full beep = 1 second
// Single slot beep    = 100ms
localparam BEEP_SHORT = 24'd2400000;   // 100ms
localparam BEEP_LONG  = 24'd48000000;  // 2 seconds at 24MHz
localparam PWM_HALF   = 12'd1250;      // 1kHz tone at 24MHz

assign led    = slot_reg;
assign buzzer = buzzer_pwm;

uart_rx #(.CLK_FREQ(24000000),.BAUD_RATE(9600)) UART_RX (
    .clk(clk),.rx(rx),.rx_data(rx_data),.rx_done(rx_done)
);
uart_tx #(.CLK_FREQ(24000000),.BAUD_RATE(9600)) UART_TX (
    .clk(clk),.tx_data(tx_data),.tx_start(tx_start),.tx(tx),.tx_busy(tx_busy)
);
servo_ctrl #(.CLK_FREQ(24000000)) SERVO (
    .clk(clk),.trigger(servo_trig),.servo_pwm(servo_pwm)
);

// PWM tone generator for buzzer
always @(posedge clk) begin
    if(buzz_active) begin
        if(pwm_count >= PWM_HALF - 1) begin
            pwm_count  <= 0;
            buzzer_pwm <= ~buzzer_pwm;
        end else
            pwm_count <= pwm_count + 1;
    end else begin
        buzzer_pwm <= 1'b0;
        pwm_count  <= 0;
    end
end

// Main logic
always @(posedge clk) begin
    tx_start   <= 1'b0;
    servo_trig <= 1'b0;

    // Buzzer countdown
    if(buzz_active) begin
        if(buzz_count == 0)
            buzz_active <= 1'b0;
        else
            buzz_count <= buzz_count - 1;
    end

    if(rx_done) begin
        case(rx_data)
            8'h31: begin
                slot_reg[0] <= ~slot_reg[0];
                tx_data     <= {slot_reg[7:1], ~slot_reg[0]};
                servo_trig  <= 1'b1;
                if(!slot_reg[0]) begin buzz_active<=1'b1; buzz_count<=BEEP_SHORT; end
            end
            8'h32: begin
                slot_reg[1] <= ~slot_reg[1];
                tx_data     <= {slot_reg[7:2], ~slot_reg[1], slot_reg[0]};
                if(!slot_reg[1]) begin buzz_active<=1'b1; buzz_count<=BEEP_SHORT; end
            end
            8'h33: begin
                slot_reg[2] <= ~slot_reg[2];
                tx_data     <= {slot_reg[7:3], ~slot_reg[2], slot_reg[1:0]};
                if(!slot_reg[2]) begin buzz_active<=1'b1; buzz_count<=BEEP_SHORT; end
            end
            8'h34: begin
                slot_reg[3] <= ~slot_reg[3];
                tx_data     <= {slot_reg[7:4], ~slot_reg[3], slot_reg[2:0]};
                if(!slot_reg[3]) begin buzz_active<=1'b1; buzz_count<=BEEP_SHORT; end
            end
            8'h35: begin
                slot_reg[4] <= ~slot_reg[4];
                tx_data     <= {slot_reg[7:5], ~slot_reg[4], slot_reg[3:0]};
                if(!slot_reg[4]) begin buzz_active<=1'b1; buzz_count<=BEEP_SHORT; end
            end
            8'h36: begin
                slot_reg[5] <= ~slot_reg[5];
                tx_data     <= {slot_reg[7:6], ~slot_reg[5], slot_reg[4:0]};
                if(!slot_reg[5]) begin buzz_active<=1'b1; buzz_count<=BEEP_SHORT; end
            end
            8'h37: begin
                slot_reg[6] <= ~slot_reg[6];
                tx_data     <= {slot_reg[7], ~slot_reg[6], slot_reg[5:0]};
                if(!slot_reg[6]) begin buzz_active<=1'b1; buzz_count<=BEEP_SHORT; end
            end
            8'h38: begin
                slot_reg[7] <= ~slot_reg[7];
                tx_data     <= {~slot_reg[7], slot_reg[6:0]};
                if(!slot_reg[7]) begin buzz_active<=1'b1; buzz_count<=BEEP_SHORT; end
            end
            default: tx_data <= slot_reg;
        endcase

        // Check if ALL slots will be occupied after this toggle
        // If new slot_reg == 8'hFF -> long beep 1 second
        if(({slot_reg[7:1], ~slot_reg[0]} == 8'hFF) ||
           ({slot_reg[7:2], ~slot_reg[1], slot_reg[0]} == 8'hFF) ||
           ({slot_reg[7:3], ~slot_reg[2], slot_reg[1:0]} == 8'hFF) ||
           ({slot_reg[7:4], ~slot_reg[3], slot_reg[2:0]} == 8'hFF) ||
           ({slot_reg[7:5], ~slot_reg[4], slot_reg[3:0]} == 8'hFF) ||
           ({slot_reg[7:6], ~slot_reg[5], slot_reg[4:0]} == 8'hFF) ||
           ({slot_reg[7], ~slot_reg[6], slot_reg[5:0]} == 8'hFF) ||
           ({~slot_reg[7], slot_reg[6:0]} == 8'hFF)) begin
            buzz_active <= 1'b1;
            buzz_count  <= BEEP_LONG;
        end

        if(!tx_busy) tx_start <= 1'b1;
    end
end

endmodule