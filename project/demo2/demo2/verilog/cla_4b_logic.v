/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 4-bit CLA logic module
*/
module cla_4b_logic(P, G, C_in, PG, GG, C1, C2, C3, C_out);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    input [N-1: 0] P, G;
    input          C_in;
    output         GG, PG, C_out, C1, C2, C3;

    // many temp buses to use in the negation of nor and nand gate
    wire [N-1:0] nand_3_temp;
    wire [N-1:0] nand_3_temp_n;
    wire [1:0] nand_2_temp;
    wire [1:0] nand_2_temp_n;
    wire nor_3_temp;
    wire [1:0] nor_3_temp_n;

    // For simplicity, directly use nand and not gates for C1~C3
    // C1~C3 use total 4 nand2, 5nand3 and 3not. To compensate, C_out is implemented by detail.

    wire [2:0] not_1;
    not1 not_C1_C3_buses[2:0](.in1(G[2:0]), .out(not_1)); // 3not gates to negate G0~G2

    wire [2:0] nand_2; // one output is C1
    wire [1:0] nand_3; // two outputs are C2, C3

    // 4 nand2 gates
    nand2 nand2_C_0(.in1(C_in), .in2(P[0]), .out(nand_2[0]));
    nand2 nand2_C_1(.in1(not_1[0]), .in2(nand_2[0]), .out(C1)); // the one to ouput C1
    nand2 nand2_C_2(.in1(G[0]), .in2(P[1]), .out(nand_2[1]));
    nand2 nand2_C_3(.in1(G[1]), .in2(P[2]), .out(nand_2[2]));

    // 3 nand3 gates
    nand3 nand3_C_0(.in1(C_in), .in2(P[0]), .in3(P[1]), .out(nand_3[0]));
    nand3 nand3_C_1(.in1(nand_3[0]), .in2(nand_2[1]), .in3(not_1[1]), .out(C2)); // the one to ouput C2
    nand3 nand3_C_2(.in1(G[0]), .in2(P[1]), .in3(P[2]), .out(nand_3[1]));

    // 2 nand4 gates, assemble by one nand3 and one nand2

    // nand4 1
    wire nand4_temp_n, nand4_temp, nand4;
    nand3 nand4_C_00(.in1(C_in), .in2(P[0]), .in3(P[1]), .out(nand4_temp_n));
    not1 not_C_00(.in1(nand4_temp_n), .out(nand4_temp));
    nand2 nand4_C_01(.in1(P[2]), .in2(nand4_temp), .out(nand4));

    // nand4 2
    wire nand41_temp_n, nand41_temp;
    nand3 nand4_C_10(.in1(nand4), .in2(nand_3[1]), .in3(nand_2[2]), .out(nand41_temp_n));
    not1 not_C_10(.in1(nand41_temp_n), .out(nand41_temp));
    nand2 nand4_C_11(.in1(not_1[2]), .in2(nand41_temp), .out(C3));

    // C_out
    not1 not_nand3[N-1:0](.in1(nand_3_temp_n), .out(nand_3_temp)); // four not gate to negate nand3
    not1 not_nand2[1:0](.in1(nand_2_temp_n), .out(nand_2_temp)); // two not gate to negate nand2
    not1 not_nor3[1:0](.in1(nor_3_temp_n), .out({C_out, nor_3_temp})); // two not gate to negate nor3

    nand3 nand_3_0(.in1(C_in), .in2(P[0]), .in3(P[1]), .out(nand_3_temp_n[0]));
    nand3 nand_3_1(.in1(P[3]), .in2(P[2]), .in3(nand_3_temp[0]), .out(nand_3_temp_n[1])); // nand_3_temp[1] is temp0

    nand3 nand_3_2(.in1(G[0]), .in2(P[1]),.in3(P[2]), .out(nand_3_temp_n[2]));
    nand2 nand_2_0(.in1(P[3]), .in2(nand_3_temp[2]), .out(nand_2_temp_n[0])); // then nand_2_temp[0] is temp1, also for GG

    nand3 nand_3_3(.in1(G[1]), .in2(P[2]),.in3(P[3]), .out(nand_3_temp_n[3])); // nand_3_temp[3] is temp2

    nand2 nand_2_1(.in1(P[3]), .in2(G[2]), .out(nand_2_temp_n[1])); // then nand_2_temp[1] is temp3

    nor3 nor_3_0(.in1(G[3]), .in2(nand_2_temp[1]),.in3(nand_3_temp[3]), .out(nor_3_temp_n[0])); // nor_3_temp[0] can also use by GG
    nor3 nor_3_1(.in1(nor_3_temp), .in2(nand_2_temp[0]),.in3(nand_3_temp[1]), .out(nor_3_temp_n[1])); 

    // GG, can directly use elements from CLA logic
    wire GG_temp;
    nor2 nor_2_GG(.in1(nor_3_temp), .in2(nand_2_temp[0]), .out(GG_temp));
    not1 not_GG(.in1(GG_temp), .out(GG));

    // PG, p0p1p2p3
    wire PG_temp0, PG_temp1_n, PG_temp0_n;

    // one 3and and one 2and to form 5and
    nand3 nand_PG0(.in1(P[0]), .in2(P[1]), .in3(P[2]), .out(PG_temp0_n));
    not1 not_PG0(.in1(PG_temp0_n), .out(PG_temp0));
    nand2 nand_PG1(.in1(P[3]), .in2(PG_temp0), .out(PG_temp1_n));
    not1 not_PG1(.in1(PG_temp1_n), .out(PG));

endmodule 