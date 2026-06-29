`timescale 1ns / 1ps

module tb_seq_detect_110_lsb;

    reg clk;
    reg reset;
    reg in_bit;
    wire out_toggle;

    // Instantiate the DUT (Device Under Test)
    seq_detect_110_lsb uut (
        .clk(clk),
        .reset(reset),
        .in_bit(in_bit),
        .out_toggle(out_toggle)
    );

    // Clock Generation (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to send one bit
    task send_bit;
        input bit_value;
        begin
            in_bit = bit_value;
            #10;
        end
    endtask

    // Test Sequence
    initial begin
        // Initialize
        reset = 1;
        in_bit = 0;

        #20;
        reset = 0;

        // Apply input sequence
        // Sequence: 0 1 1 0 1 1 0 0 1 1
        // "011" (LSB-first for 110) appears three times
        send_bit(0);
        send_bit(1);
        send_bit(1); // Detect -> Toggle

        send_bit(0);
        send_bit(1);
        send_bit(1); // Detect -> Toggle

        send_bit(0);
        send_bit(0);
        send_bit(1);
        send_bit(1); // Detect -> Toggle

        #20;
        $finish;
    end

    // Monitor signals
    initial begin
        $display("Time\tReset\tInput\tState Output");
        $monitor("%0t\t%b\t%b\t%b",
                  $time, reset, in_bit, out_toggle);
    end

endmodule