module tb_full_adder_df;
    reg a, b, cin;
    wire sum, cout;
 
    full_adder_df DUT (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));
 
    initial begin
        $display(" a  b  cin | sum cout");
        $monitor(" %b  %b   %b  |  %b   %b", a, b, cin, sum, cout);
        a = 0; b = 0; cin = 0;
        #10 a = 0; b = 0; cin = 1;
        #10 a = 0; b = 1; cin = 0;
        #10 a = 0; b = 1; cin = 1;
        #10 a = 1; b = 0; cin = 0;
        #10 a = 1; b = 0; cin = 1;
        #10 a = 1; b = 1; cin = 0;
        #10 a = 1; b = 1; cin = 1;
        #10 $finish;
    end
endmodule