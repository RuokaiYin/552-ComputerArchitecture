/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 4-bit CLA module
*/
module cla_4b(A, B, C_in, S, C_out, PG, GG);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    input [N-1: 0] A, B;
    input          C_in;
    output [N-1:0] S;
    output         C_out, PG, GG;

    // YOUR CODE HERE

    // P and G to feed in CLA logic

    // Comment: This can be done by add more outputs form full adder, but since 
    // the specification does not say we can modify the output of full adder, 
    // I choose to add some more logic here. This is actually waste of area.

    wire [N-1:0] p;
    wire [N-1:0] g_n;
    wire [N-1:0] g;
    xor2 p_xor[N-1:0](.in1(A), .in2(B), .out(p)); // generate pi
    
    nand2 g_n_nand[N-1:0](.in1(A), .in2(B), .out(g_n)); // generate gi
    not1 g_not[N-1:0](.in1(g_n), .out(g));
 
    wire [2:0] C1_3;
    cla_4b_logic cla(.P(p), .G(g), .C_in(C_in), .PG(PG), .GG(GG), .C1(C1_3[0]), .C2(C1_3[1]), .C3(C1_3[2]), .C_out(C_out));
    
    wire [3:0] garbage_Cout;
    // four full adders
    fullAdder_1b fA[N-1:0](.A(A),.B(B), .C_in({C1_3,C_in}), .S(S), .C_out(garbage_Cout));

endmodule
