module UART #(
    parameter CLK_FREQ    = 24_000_000,
    parameter BAUD_RATE   = 9600,
    parameter PARITY_EN   = 1,
    parameter PARITY_TYPE = 0
)(
    input        clk,
    input        rst,

    input        uart_rx_pin,
    output       uart_tx_pin,

    output [3:0] led,
    input  [3:0] btn
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam TWO_SEC      = CLK_FREQ * 2;
    localparam TIMER_W      = $clog2(TWO_SEC + 1);

    wire [7:0] rx_data;
    wire       rx_done;
    wire       rx_parity_err;
    wire       rx_frame_err;

    uart_rx #(
        .CLKS_PER_BIT (CLKS_PER_BIT),
        .PARITY_EN    (PARITY_EN),
        .PARITY_TYPE  (PARITY_TYPE)
    ) u_rx (
        .clk        (clk),
        .rst        (rst),
        .rx         (uart_rx_pin),
        .rx_data    (rx_data),
        .rx_done    (rx_done),
        .parity_err (rx_parity_err),
        .frame_err  (rx_frame_err)
    );

    wire       tx_busy;
    wire       tx_done;
    reg        tx_start;
    reg  [7:0] tx_byte;

    uart_tx #(
        .CLKS_PER_BIT (CLKS_PER_BIT),
        .PARITY_EN    (PARITY_EN),
        .PARITY_TYPE  (PARITY_TYPE)
    ) u_tx (
        .clk      (clk),
        .rst      (rst),
        .tx_start (tx_start),
        .tx_data  (tx_byte),
        .tx       (uart_tx_pin),
        .tx_busy  (tx_busy),
        .tx_done  (tx_done)
    );

    // ------------------------------------------------------------------
    // Physical button debounce + edge detect (btn[3:0] -> virtual idx 0-3)
    // ------------------------------------------------------------------
    localparam DEBOUNCE_MS  = 20;
    localparam DEBOUNCE_CNT = (CLK_FREQ / 1000) * DEBOUNCE_MS;
    localparam DEB_W        = $clog2(DEBOUNCE_CNT + 1);

    reg [3:0] btn_sync1, btn_sync2;
    reg [3:0] btn_stable;
    reg [3:0] btn_prev;
    reg [3:0] btn_posedge;
    reg [DEB_W-1:0] deb_cnt [0:3];

    always @(posedge clk) begin
        if (rst) begin btn_sync1 <= 4'b0; btn_sync2 <= 4'b0; end
        else     begin btn_sync1 <= btn;  btn_sync2 <= btn_sync1; end
    end

    genvar gi;
    generate
        for (gi = 0; gi < 4; gi = gi + 1) begin : g_deb
            always @(posedge clk) begin
                if (rst) begin
                    deb_cnt[gi]    <= 0;
                    btn_stable[gi] <= 1'b0;
                end else begin
                    if (btn_sync2[gi] !== btn_stable[gi]) begin
                        if (deb_cnt[gi] == DEBOUNCE_CNT - 1) begin
                            btn_stable[gi] <= btn_sync2[gi];
                            deb_cnt[gi]    <= 0;
                        end else
                            deb_cnt[gi] <= deb_cnt[gi] + 1;
                    end else
                        deb_cnt[gi] <= 0;
                end
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (rst) begin btn_prev <= 4'b0; btn_posedge <= 4'b0; end
        else begin
            btn_prev    <= btn_stable;
            btn_posedge <= btn_stable & ~btn_prev;
        end
    end

    // ------------------------------------------------------------------
    // UART RX hex-char decode -> virtual idx 0-15
    // '0'-'9' -> 0-9 , 'A'-'F' or 'a'-'f' -> 10-15
    // ------------------------------------------------------------------
    reg        hex_valid;
    reg  [3:0] hex_val;

    always @(*) begin
        hex_valid = 1'b0;
        hex_val   = 4'd0;
        if (rx_done && !rx_parity_err && !rx_frame_err) begin
            if (rx_data >= "0" && rx_data <= "9") begin
                hex_valid = 1'b1;
                hex_val   = rx_data - "0";
            end else if (rx_data >= "A" && rx_data <= "F") begin
                hex_valid = 1'b1;
                hex_val   = rx_data - "A" + 4'd10;
            end else if (rx_data >= "a" && rx_data <= "f") begin
                hex_valid = 1'b1;
                hex_val   = rx_data - "a" + 4'd10;
            end
        end
    end

    // pulse, one cycle, for newly selected virtual button index 0-15
    reg        sel_valid;
    reg [3:0]  sel_idx;

    always @(posedge clk) begin
        if (rst) begin
            sel_valid <= 1'b0;
            sel_idx   <= 4'd0;
        end else begin
            sel_valid <= 1'b0;
            sel_idx   <= 4'd0;
            if (hex_valid) begin
                // UART hex char selects any of the 16 virtual buttons
                sel_valid <= 1'b1;
                sel_idx   <= hex_val;
            end else if (|btn_posedge) begin
                // physical buttons map to virtual indices 0-3
                sel_valid <= 1'b1;
                sel_idx   <= btn_posedge[0] ? 4'd0 :
                             btn_posedge[1] ? 4'd1 :
                             btn_posedge[2] ? 4'd2 : 4'd3;
            end
        end
    end

    // ------------------------------------------------------------------
    // LED: show binary code (0-15) of the most recently pressed button,
    // auto-clear after 2 seconds (same behaviour as before, now 4-bit code
    // instead of one-hot, so all 16 states are representable on 4 LEDs)
    // ------------------------------------------------------------------
    reg [3:0]         led_reg;
    reg               timer_active;
    reg [TIMER_W-1:0] led_timer;

    always @(posedge clk) begin
        if (rst) begin
            led_reg      <= 4'b0000;
            timer_active <= 1'b0;
            led_timer    <= 0;
        end else begin
            if (sel_valid) begin
                led_reg      <= sel_idx;
                timer_active <= 1'b1;
                led_timer    <= TWO_SEC;
            end

            if (timer_active) begin
                if (led_timer == 0) begin
                    led_reg      <= 4'b0000;
                    timer_active <= 1'b0;
                end else
                    led_timer <= led_timer - 1;
            end
        end
    end

    assign led = led_reg;

    // ------------------------------------------------------------------
    // 16 name messages, one per virtual button (0-15).
    // Replace "Name01".."Name16" below with the actual names you want
    // sent out over UART. Keep each entry exactly MSG_LEN bytes long
    // (pad short names with trailing spaces) so the indexing stays simple.
    // ------------------------------------------------------------------
    localparam NUM_MSGS  = 16;
    localparam MSG_LEN   = 20;                 // fixed slot length per message
    localparam MSG_TOTAL = NUM_MSGS * MSG_LEN;

    reg [7:0] msg_rom [0:MSG_TOTAL-1];

    // helper task-like initial block: each message is MSG_LEN bytes:
    // up to 17 printable chars, then CR, LF, then a trailing space pad.
    integer i;
    initial begin
        for (i = 0; i < MSG_TOTAL; i = i + 1)
            msg_rom[i] = " ";   // default-pad everything with spaces

        // --- index 0 (0) ---
        msg_rom[0]="P"; msg_rom[1]="A"; msg_rom[2]="N"; msg_rom[3]="C"; msg_rom[4]="H"; msg_rom[5]="A"; msg_rom[6]="M"; msg_rom[7]="I"; msg_rom[8]=" "; msg_rom[9]="0"; msg_rom[10]="1"; msg_rom[16]=8'h0D; msg_rom[17]=8'h0A;

        // --- index 1 (1) ---
        msg_rom[20]="P"; msg_rom[21]="A"; msg_rom[22]="N"; msg_rom[23]="C"; msg_rom[24]="H"; msg_rom[25]="A"; msg_rom[26]="M"; msg_rom[27]="I"; msg_rom[28]=" "; msg_rom[29]="0"; msg_rom[30]="2"; msg_rom[36]=8'h0D; msg_rom[37]=8'h0A;

        // --- index 2 (2) ---
        msg_rom[40]="P"; msg_rom[41]="A"; msg_rom[42]="N"; msg_rom[43]="C"; msg_rom[44]="H"; msg_rom[45]="A"; msg_rom[46]="M"; msg_rom[47]="I"; msg_rom[48]=" "; msg_rom[49]="0"; msg_rom[50]="3"; msg_rom[56]=8'h0D; msg_rom[57]=8'h0A;

        // --- index 3 (3) ---
        msg_rom[60]="P"; msg_rom[61]="A"; msg_rom[62]="N"; msg_rom[63]="C"; msg_rom[64]="H"; msg_rom[65]="A"; msg_rom[66]="M"; msg_rom[67]="I"; msg_rom[68]=" "; msg_rom[69]="0"; msg_rom[70]="4"; msg_rom[76]=8'h0D; msg_rom[77]=8'h0A;

        // --- index 4 (4) ---
        msg_rom[80]="P"; msg_rom[81]="A"; msg_rom[82]="N"; msg_rom[83]="C"; msg_rom[84]="H"; msg_rom[85]="A"; msg_rom[86]="M"; msg_rom[87]="I"; msg_rom[88]=" "; msg_rom[89]="0"; msg_rom[90]="5"; msg_rom[96]=8'h0D; msg_rom[97]=8'h0A;

        // --- index 5 (5) ---
        msg_rom[100]="P"; msg_rom[101]="A"; msg_rom[102]="N"; msg_rom[103]="C"; msg_rom[104]="H"; msg_rom[105]="A"; msg_rom[106]="M"; msg_rom[107]="I"; msg_rom[108]=" "; msg_rom[109]="0"; msg_rom[110]="6"; msg_rom[116]=8'h0D; msg_rom[117]=8'h0A;

        // --- index 6 (6) ---
        msg_rom[120]="P"; msg_rom[121]="A"; msg_rom[122]="N"; msg_rom[123]="C"; msg_rom[124]="H"; msg_rom[125]="A"; msg_rom[126]="M"; msg_rom[127]="I"; msg_rom[128]=" "; msg_rom[129]="0"; msg_rom[130]="7"; msg_rom[136]=8'h0D; msg_rom[137]=8'h0A;

        // --- index 7 (7) ---
        msg_rom[140]="P"; msg_rom[141]="A"; msg_rom[142]="N"; msg_rom[143]="C"; msg_rom[144]="H"; msg_rom[145]="A"; msg_rom[146]="M"; msg_rom[147]="I"; msg_rom[148]=" "; msg_rom[149]="0"; msg_rom[150]="8"; msg_rom[156]=8'h0D; msg_rom[157]=8'h0A;

        // --- index 8 (8) ---
        msg_rom[160]="P"; msg_rom[161]="A"; msg_rom[162]="N"; msg_rom[163]="C"; msg_rom[164]="H"; msg_rom[165]="A"; msg_rom[166]="M"; msg_rom[167]="I"; msg_rom[168]=" "; msg_rom[169]="0"; msg_rom[170]="9"; msg_rom[176]=8'h0D; msg_rom[177]=8'h0A;

        // --- index 9 (9) ---
        msg_rom[180]="P"; msg_rom[181]="A"; msg_rom[182]="N"; msg_rom[183]="C"; msg_rom[184]="H"; msg_rom[185]="A"; msg_rom[186]="M"; msg_rom[187]="I"; msg_rom[188]=" "; msg_rom[189]="1"; msg_rom[190]="0"; msg_rom[196]=8'h0D; msg_rom[197]=8'h0A;

        // --- index 10 (A) ---
        msg_rom[200]="P"; msg_rom[201]="A"; msg_rom[202]="N"; msg_rom[203]="C"; msg_rom[204]="H"; msg_rom[205]="A"; msg_rom[206]="M"; msg_rom[207]="I"; msg_rom[208]=" "; msg_rom[209]="1"; msg_rom[210]="1"; msg_rom[216]=8'h0D; msg_rom[217]=8'h0A;

        // --- index 11 (B) ---
        msg_rom[220]="P"; msg_rom[221]="A"; msg_rom[222]="N"; msg_rom[223]="C"; msg_rom[224]="H"; msg_rom[225]="A"; msg_rom[226]="M"; msg_rom[227]="I"; msg_rom[228]=" "; msg_rom[229]="1"; msg_rom[230]="2"; msg_rom[236]=8'h0D; msg_rom[237]=8'h0A;

        // --- index 12 (C) ---
        msg_rom[240]="P"; msg_rom[241]="A"; msg_rom[242]="N"; msg_rom[243]="C"; msg_rom[244]="H"; msg_rom[245]="A"; msg_rom[246]="M"; msg_rom[247]="I"; msg_rom[248]=" "; msg_rom[249]="1"; msg_rom[250]="3"; msg_rom[256]=8'h0D; msg_rom[257]=8'h0A;

        // --- index 13 (D) ---
        msg_rom[260]="P"; msg_rom[261]="A"; msg_rom[262]="N"; msg_rom[263]="C"; msg_rom[264]="H"; msg_rom[265]="A"; msg_rom[266]="M"; msg_rom[267]="I"; msg_rom[268]=" "; msg_rom[269]="1"; msg_rom[270]="4"; msg_rom[276]=8'h0D; msg_rom[277]=8'h0A;

        // --- index 14 (E) ---
        msg_rom[280]="P"; msg_rom[281]="A"; msg_rom[282]="N"; msg_rom[283]="C"; msg_rom[284]="H"; msg_rom[285]="A"; msg_rom[286]="M"; msg_rom[287]="I"; msg_rom[288]=" "; msg_rom[289]="1"; msg_rom[290]="5"; msg_rom[296]=8'h0D; msg_rom[297]=8'h0A;

        // --- index 15 (F) ---
        msg_rom[300]="P"; msg_rom[301]="A"; msg_rom[302]="N"; msg_rom[303]="C"; msg_rom[304]="H"; msg_rom[305]="A"; msg_rom[306]="M"; msg_rom[307]="I"; msg_rom[308]=" "; msg_rom[309]="1"; msg_rom[310]="6"; msg_rom[316]=8'h0D; msg_rom[317]=8'h0A;

    end

    // ------------------------------------------------------------------
    // TX engine: queue of pending virtual-button presses (0-15),
    // serviced in priority order, each sends its MSG_LEN-byte message.
    // ------------------------------------------------------------------
    localparam TX_IDLE = 2'd0;
    localparam TX_LOAD = 2'd1;
    localparam TX_SEND = 2'd2;
    localparam TX_WAIT = 2'd3;

    reg [1:0]  tx_state;
    reg [8:0]  tx_ptr;
    reg [8:0]  tx_end;
    reg [15:0] pending;   // one bit per virtual button 0-15
    integer    idx;

    always @(posedge clk) begin
        if (rst) begin
            tx_state <= TX_IDLE;
            tx_ptr   <= 0;
            tx_end   <= 0;
            tx_start <= 0;
            tx_byte  <= 0;
            pending  <= 16'b0;
        end else begin
            tx_start <= 1'b0;

            if (sel_valid)
                pending[sel_idx] <= 1'b1;

            case (tx_state)
                TX_IDLE: begin
                    if (pending != 16'b0) begin
                        for (idx = 15; idx >= 0; idx = idx - 1)
                            if (pending[idx]) begin
                                tx_ptr        = idx * MSG_LEN;
                                tx_end        = idx * MSG_LEN + MSG_LEN - 1;
                                pending[idx]  = 1'b0;
                            end
                        tx_state <= TX_LOAD;
                    end
                end

                TX_LOAD: begin
                    tx_byte  <= msg_rom[tx_ptr];
                    tx_state <= TX_SEND;
                end

                TX_SEND: begin
                    if (!tx_busy) begin
                        tx_start <= 1'b1;
                        tx_state <= TX_WAIT;
                    end
                end

                TX_WAIT: begin
                    if (tx_done) begin
                        if (tx_ptr == tx_end)
                            tx_state <= TX_IDLE;
                        else begin
                            tx_ptr   <= tx_ptr + 1;
                            tx_state <= TX_LOAD;
                        end
                    end
                end

                default: tx_state <= TX_IDLE;
            endcase
        end
    end

endmodule