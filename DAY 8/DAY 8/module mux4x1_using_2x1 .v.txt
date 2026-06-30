module mux4x1_using_2x1 (
    input  i0, i1, i2, i3,
    input  [1:0] sel,
    output y
);
    wire m0, m1;
 
    mux2x1 M0 (.i0(i0), .i1(i1), .sel(sel[0]), .y(m0)); // chooses between i0,i1
    mux2x1 M1 (.i0(i2), .i1(i3), .sel(sel[0]), .y(m1)); // chooses between i2,i3
    mux2x1 M2 (.i0(m0), .i1(m1), .sel(sel[1]), .y(y));  // final select
endmodule
 