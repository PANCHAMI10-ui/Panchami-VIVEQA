module priority_enc_8x3_structural (
    input  [7:0] in,
    output y2, y1, y0,
    output valid
);
    // Intermediate wires
    wire n7, n6, n5, n4, n3, n2, n1;
 
    // y2 = 1 if in[7]..in[4] -> any of those active
    or  g1 (y2, in[7], in[6], in[5], in[4]);
 
    // y1 = 1 if (in7 OR in6) OR (NOT(in7,in6,in5,in4) AND (in3 OR in2))
    not g2 (n7, in[7]);
    not g3 (n6, in[6]);
    not g4 (n5, in[5]);
    not g5 (n4, in[4]);
 
    wire none_7654;
    and g6 (none_7654, n7, n6, n5, n4);
 
    wire or_76, or_32;
    or  g7 (or_76, in[7], in[6]);
    or  g8 (or_32, in[3], in[2]);
 
    wire term2;
    and g9 (term2, none_7654, or_32);
    or  g10 (y1, or_76, term2);
 
    // y0 = 1 if in7 OR (NOT in6 AND in5) OR (NOT(in7..in4) AND (in3 OR (NOT in2 AND in1)))
    not g11 (n3, in[3]);
    not g12 (n2, in[2]);
    not g13 (n1, in[1]);
 
    wire term_a, term_b, term_c, term_d;
    and g14 (term_a, n6, in[5]);                  // in6'=0,in5=1
    and g15 (term_b, none_7654, in[3]);
    and g16 (term_c, n2, in[1]);
    and g17 (term_d, none_7654, n3, term_c);
 
    or  g18 (y0, in[7], term_a, term_b, term_d);
 
    // valid = OR of all inputs
    or  g19 (valid, in[7], in[6], in[5], in[4], in[3], in[2], in[1], in[0]);
 
endmodule