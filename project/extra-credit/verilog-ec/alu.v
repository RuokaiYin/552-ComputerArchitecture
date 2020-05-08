/*
    CS/ECE 552 Spring '20
    Homework #2, Problem 2
    A 16-bit ALU module.  It is designed to choose
    the correct operation to perform on 2 16-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the 16-bit result
    of the operation, as well as output a Zero bit and an Overflow
    (OFL) bit.
*/
module alu (InA, InB, Cin, Op, invA, invB, sign, Out, Zero, Ofl, neg, Cout);

   // declare constant for size of inputs, outputs (N),
   // and operations (O)
   parameter    N = 16;
   parameter    O = 3;
   
   input [N-1:0] InA;
   input [N-1:0] InB;
   input         Cin;
   input [O-1:0] Op;
   input         invA;
   input         invB;
   input         sign;
   output [N-1:0] Out;
   output         Ofl;
   output         Zero;
   output  	  neg; 
   output 	  Cout; 

   /* YOUR CODE HERE */

   // check inversion first
   wire[N-1:0] A_inv, B_inv;
   assign A_inv = invA ? ~InA : InA;
   assign B_inv = invB ? ~InB : InB;
   
   wire [N-1:0] A_sft;
   shifter sft(.In(A_inv), .Cnt(B_inv[3:0]), .Op(Op[1:0]), .Out(A_sft));


   // check for operation code
   wire[N-1:0] adder_out;
   wire adder_cout;
   cla_16b adder(.A(A_inv), .B(B_inv), .C_in(Cin), .S(adder_out), .C_out(adder_cout));

   // deal with overflow
   wire A_sign, B_sign,of_p, Ofl_sign,ofl_sign_hap;
   assign A_sign = A_inv[15];
   assign B_sign = B_inv[15];
   assign of_p = A_sign ~^ B_sign;
   assign ofl_sign_hap = ~((&({A_sign,B_sign,adder_out[N-1]})) | ~(|({A_sign,B_sign,adder_out[N-1]})));
   assign Ofl_sign = sign ? (of_p & (ofl_sign_hap)) : (1'b0);        
   assign Ofl = (adder_cout & ~sign) | Ofl_sign;   

   assign Zero = ~(|adder_out);

   wire[N-1:0] logic_out_and, logic_out_or, logic_out_xor;
   assign logic_out_and = A_inv & B_inv;
   assign logic_out_or = A_inv | B_inv;
   assign logic_out_xor = A_inv ^ B_inv;


   assign Out = Op[O-1] ? (Op[O-2] ? (Op[O-3] ? (logic_out_xor) : (logic_out_or)) : (Op[O-3] ? (logic_out_and) : (adder_out))) : (A_sft) ; 

   assign neg = Out[N-1]; 
   assign Cout = adder_cout; 
   
endmodule
