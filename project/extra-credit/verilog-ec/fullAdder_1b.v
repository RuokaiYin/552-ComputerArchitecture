/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 1-bit full adder
*/
module fullAdder_1b(A, B, C_in, S, C_out);
    input  A, B;
    input  C_in;
    output S;
    output C_out;

    // YOUR CODE HERE
    
    wire x1,and1,and_n1,and2,and_n2,or1;

    // use nand + not and nor + not to function as normal and and or gate
    xor2 xor_0(.in1(A),.in2(B),.out(x1));
    xor2 xor_1(.in1(C_in),.in2(x1),.out(S));
    nand2 nand_0(.in1(x1),.in2(C_in),.out(and1));
    nand2 nand_1(.in1(A),.in2(B),.out(and2));
    nor2 nor_0(.in1(and_n1),.in2(and_n2),.out(or1));
    not1 not_nand_0(.in1(and1),.out(and_n1));
    not1 not_nand_1(.in1(and2),.out(and_n2));
    not1 not_nor_0(.in1(or1),.out(C_out));
    

endmodule
