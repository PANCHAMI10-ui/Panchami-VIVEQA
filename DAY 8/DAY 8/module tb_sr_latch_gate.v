module tb_sr_latch_gate;
    reg s, r;
    wire q, qbar;
 
    sr_latch_gate DUT (.s(s), .r(r), .q(q), .qbar(qbar));
 
    initial begin
        $display(" s  r | q qbar");
        $monitor(" %b  %b |  %b   %b", s, r, q, qbar);
 
        s = 0; r = 0; #10;   // hold (initial unknown -> may settle)
        s = 1; r = 0; #10;   // set
        s = 0; r = 0; #10;   // hold (keeps set)
        s = 0; r = 1; #10;   // reset
        s = 0; r = 0; #10;   // hold (keeps reset)
        s = 1; r = 1; #10;   // invalid state
        s = 0; r = 0; #10;   // back to hold
        $finish;
    end
endmodule
 