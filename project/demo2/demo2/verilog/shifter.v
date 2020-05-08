/*
    CS/ECE 552 Spring '20
    Homework #2, Problem 1
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the Op() value that is passed in (2 bit number).  It uses these
    shifts to shift the value any number of bits between 0 and 15 bits.
 */
module shifter (In, Cnt, Op, Out);

   // declare constant for size of inputs, outputs (N) and # bits to shift (C)
   parameter   N = 16;
   parameter   C = 4;
   parameter   O = 2;

   input [N-1:0]   In;
   input [C-1:0]   Cnt;
   input [O-1:0]   Op;
   output [N-1:0]  Out;

   /* YOUR CODE HERE */
   
   wire left, shift_mode;
   assign left = ~Op[1];
   assign shift_mode = Op[0];

   wire[15:0] Out_1;
   wire extra_left_1; // extra mux at left end
   assign extra_left_1 = left ? (shift_mode ? (1'bx) : (In[15])) : (shift_mode ? (1'b0) : (In[0]));
   assign Out_1 = Cnt[0] ? (left ? (shift_mode ? ({In[14:0],1'b0}) : ({In[14:0],extra_left_1}) ) : (shift_mode ? ({extra_left_1,In[15:1]}) : ({extra_left_1,In[15:1]}))) : (In);
                                                   //01: shift left  //00: rotate left                            //11: right logical     //10: right arith -> rotate right
   wire[15:0] Out_2;
   wire[1:0] extra_left_2; // extra mux at left end
   assign extra_left_2 = left ? (shift_mode ? (2'bx) : (Out_1[15:14])) : (shift_mode ? (2'b0) : (Out_1[1:0]));
   assign Out_2 = Cnt[1] ? (left ? (shift_mode ? ({Out_1[13:0],{2{1'b0}}}) : ({Out_1[13:0],extra_left_2}) ) : (shift_mode ? ({extra_left_2,Out_1[15:2]}) : ({extra_left_2,Out_1[15:2]}))) : (Out_1);

   wire[15:0] Out_4;
   wire[3:0] extra_left_4; // extra mux at left end
   assign extra_left_4 = left ? (shift_mode ? ({4{1'bx}}) : (Out_2[15:12])) : (shift_mode ? ({4{1'b0}}) : (Out_2[3:0]));
   assign Out_4 = Cnt[2] ? (left ? (shift_mode ? ({Out_2[11:0],{4{1'b0}}}) : ({Out_2[11:0],extra_left_4}) ) : (shift_mode ? ({extra_left_4,Out_2[15:4]}) : ({extra_left_4,Out_2[15:4]}))) : (Out_2);

   wire[15:0] Out_8;
   wire[7:0] extra_left_8; // extra mux at left end
   assign extra_left_8 = left ? (shift_mode ? ({8{1'bx}}) : (Out_4[15:8])) : (shift_mode ? ({8{1'b0}}) : (Out_4[7:0]));
   assign Out_8 = Cnt[3] ? (left ? (shift_mode ? ({Out_4[7:0],{8{1'b0}}}) : ({Out_4[7:0],extra_left_8}) ) : (shift_mode ? ({extra_left_8,Out_4[15:8]}) : ({extra_left_8,Out_4[15:8]}))) : (Out_4);

   assign Out = Out_8;
endmodule
