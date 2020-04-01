/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 16-bit CLA module
*/
module cla_16b(A, B, C_in, S, C_out);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    input [N-1: 0] A, B;
    input          C_in;
    output [N-1:0] S;
    output         C_out;

    // YOUR CODE HERE
    wire C1,C2,C3;
    wire [3:0] garbage_out;
    wire [3:0] pg, gg;

    cla_4b cla_4b[3:0](.A({A[N-1:12],A[11:8],A[7:4],A[3:0]}), .B({B[N-1:12],B[11:8],B[7:4],B[3:0]}), .C_in({C3,C2,C1,C_in}), .S({S[N-1:12],S[11:8],S[7:4],S[3:0]}), .C_out(garbage_out), .PG(pg), .GG(gg));
   
    wire garbage_g[1:0];
    cla_4b_logic cla_16b_logic(.P(pg), .G(gg), .C_in(C_in), .PG(garbage_g[0]), .GG(garbage_g[1]), .C1(C1), .C2(C2), .C3(C3), .C_out(C_out));

endmodule
