/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (
	// Inputs from Decode
	data1, data2, extend, Alu_Src, Alu_op, Op_ext,
   // Input from EX/MEM fowarding
   EX_MEM_fowarding_data, EX_MEM_fwd,
   // Input from MEM/WB fowarding
   MEM_WB_fowarding_data, MEM_WB_fwd,
	// Outputs to Decode/Memory
	result, zero, neg, Cout, SLBI, BTR, err
	);

   // TODO: Your code here
   input [15:0] data1, data2, extend, EX_MEM_fowarding_data, MEM_WB_fowarding_data;
   input [4:0] Alu_op; 
   input [1:0] Alu_Src, Op_ext;
   input EX_MEM_fwd, MEM_WB_fwd;

   output [15:0] result, SLBI, Cout, BTR;
   output zero, neg, err; 

   wire [15:0] data1_fowarding, data2_fowarding;


// TODO instantiate the alu_control module   
   wire sign;
   wire err_alu;
   wire invA, invB;
   wire [2:0] op;  
   alu_control alu_deco(
	.Alu_op(Alu_op), .Op_ext(Op_ext), 
	.InvA(invA), .InvB(invB), .Cin(Cin), .sign(sign), .op(op), .err(err_alu)
	);

   wire fwd;
   assign fwd = EX_MEM_fwd | MEM_WB_fwd;
   // two 3-1 muxes for fowarding.
   assign data1_fowarding = (fwd) ? (EX_MEM_fwd ? EX_MEM_fowarding_data : MEM_WB_fowarding_data) : data1;
   assign data2_fowarding = (fwd) ? (EX_MEM_fwd ? EX_MEM_fowarding_data : MEM_WB_fowarding_data) : data2;


   // use a 4-1 mux to choose the second operand
   wire [15:0] operand2;
   assign operand2 = Alu_Src[1] ? (Alu_Src[0] ? 16'b0000_0000_0000_1000 : 16'b0) : (Alu_Src[0] ? extend : data2_fowarding); 

   // initialize an ALU
   wire of, cout_1, neg_temp;
   alu alu_exe(.InA(data1_fowarding), .InB(operand2), .Cin(Cin), .Op(op), .invA(invA), .invB(invB), .sign(sign), .Out(result), .Ofl(of), .Zero(zero), .neg(neg_temp), .Cout(cout_1)); 
   
   assign Cout = {15'b000_0000_0000_0000, cout_1}; 
   assign BTR = {data1[0], data1[1], data1[2], data1[3], data1[4], data1[5], data1[6], data1[7], data1[8], data1[9], data1[10], data1[11], data1[12], data1[13], data1[14], data1[15]};
   assign SLBI = {result[15:8], extend[7:0]};
   assign neg = of ? ~neg_temp : neg_temp; 

   // wire err_sig;
   // assign err_sig = ^{data1, data2, extend, Alu_Src, Alu_op, Op_ext};
   assign err = err_alu;
   
endmodule


