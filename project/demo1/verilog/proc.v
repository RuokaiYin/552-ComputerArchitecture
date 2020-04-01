/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   wire err_1, err_2;
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
   wire  Halt, halt_back; 
   wire [15:0] PC_Back,PC_Next, No_Branch, instr; 
	fetch fet(
        // system inputs
	.clk(clk), .rst(rst), 
	// inputs from Decode
	.PC_Back(PC_Back), .Halt(Halt),  
	// Outputs to Decode
	.No_Branch(No_Branch), .instr(instr), .halt_back(halt_back),
        // Output to WB
        .PC_Next(PC_Next) // .PC_curr(PC_curr)
	);

   wire neg, zero,Mem_read,Mem_wrt;
   wire [15:0] WB, result;

   wire [1:0] Op_ext, WB_sel,Alu_src;
   wire [2:0] Alu_result;
   wire [4:0] Alu_op;
   wire [15:0] data1,data2,extend;
	decode dec(
        // IN from Fetch
	.instr(instr), .No_Branch(No_Branch), .halt_back(halt_back),
        // IN from Exec
        .result(result), .neg(neg), .zero(zero),
        // IN from WB
        .WB(WB),
        // Global In
        .clk(clk), .rst(rst),
	// Out Control Logic
	.Halt(Halt),.WB_sel(WB_sel),.Alu_src(Alu_src),.Alu_result(Alu_result),.Alu_op(Alu_op),.Mem_read(Mem_read),.Mem_wrt(Mem_wrt),
        // Out to Exec
	.data1(data1),.data2(data2),.extend(extend), .Op_ext(Op_ext),
        // Out to Fetch
        .PC_back(PC_Back),
        // Global out
        .err(err_1));
    wire [15:0] Cout, SLBI, BTR;
	execute exe(
	// Inputs from Decode
	.data1(data1), .data2(data2), .extend(extend), .Alu_Src(Alu_src), .Alu_op(Alu_op), .Op_ext(Op_ext), 
	// Outputs to Decode/Memory
	.result(result), .zero(zero), .neg(neg), .Cout(Cout), .SLBI(SLBI), .BTR(BTR), .err(err_2)
	);
   wire [15:0] data_mem, data_exe;
	memory mem(
	// system inputs
	.clk(clk), .rst(rst),
	// input from Decode
        .data2(data2), .Mem_read(Mem_read), .Mem_wrt(Mem_wrt), .Halt(Halt), .Alu_result(Alu_result),
	// inputs from Execute
	.result(result), .zero(zero), .neg(neg), .BTR(BTR), .SLBI(SLBI), .Cout(Cout),  
	// outputs to WB
	.data_mem(data_mem), .data_exe(data_exe)
	);

	wb wrib(
        // IN from Fetch
        .PC_Next(PC_Next),
        // IN from Decode
        .extend(extend), .WB_sel(WB_sel),
        // IN from Mem
        .data_mem(data_mem), .data_exe(data_exe),
        // Out to Decode
        .WB(WB));
   	
	assign err = 1'b0;
		
endmodule 

