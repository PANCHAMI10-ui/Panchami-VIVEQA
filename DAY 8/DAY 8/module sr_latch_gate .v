module sr_latch_gate (
    input  s, r,
    output q, qbar
);
    nor g1 (q, r, qbar);
    nor g2 (qbar, s, q);
endmodule
 