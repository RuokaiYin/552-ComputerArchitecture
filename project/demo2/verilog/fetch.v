/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (
	// system inputs
	clk, rst, 
	// inputs from Decode
	PC_Back, Halt, STALL, Branch_stall,
	// Outputs to Decode
	PC_Next, No_Branch, instr, halt_back, // PC_curr
	//system output
	err,Stall_imem
	); 

   // TODO: Your code here
   input clk, rst, Halt, STALL, Branch_stall; 
   input [15:0] PC_Back;

   output [15:0] PC_Next, No_Branch, instr; 
   output halt_back, err, Stall_imem;

   wire Stall_imem_nextcycle, Branch_stall_q, Stall_imem_q; 
   // use a 16-bit register to store the PC value
   wire [15:0] PC_curr, PC_wb, PC_wb_plus_stall, PC_Back_q, PC_Back_with_stall;
   wire err_reg, err_reg_dummy1,err_reg_dummy2,err_reg_dummy3;
   wire Done, CacheHit;
   wire branch_with_stall;

   reg_16 #(.SIZE(1)) stall_imem_reg(.readData(Stall_imem_q), .err(err_reg_dummy1), .clk(clk), .rst(rst), .writeData(Stall_imem), .writeEn(1'b1));
   assign Stall_imem_nextcycle = Stall_imem_q & ~Stall_imem; 

   reg_16 #(.SIZE(1)) branch_stall_reg(.readData(Branch_stall_q), .err(err_reg_dummy2), .clk(clk), .rst(rst), .writeData(Branch_stall), .writeEn(Branch_stall));
   reg_16 #(.SIZE(16)) pc_back_reg(.readData(PC_Back_q), .err(err_reg_dummy3), .clk(clk), .rst(rst), .writeData(PC_Back), .writeEn(Branch_stall));

   assign PC_Back_with_stall = Stall_imem_nextcycle ? PC_Back_q : PC_Back;
   assign branch_with_stall = Stall_imem_nextcycle ? Branch_stall_q : Branch_stall;

    // a mux to choose from normal pc+2 or pc_back
   assign PC_wb = (branch_with_stall) ? PC_Back_with_stall : PC_Next;
   assign PC_wb_plus_stall = Stall_imem ? PC_curr: PC_wb;
   reg_16 pc_reg (.readData(PC_curr), .err(err_reg), .clk(clk), .rst(rst), .writeData(PC_wb_plus_stall), .writeEn(~STALL));
   
  
   // add current PC value by 2 
   wire [15:0]two;
   wire C_out;

   assign two = 16'b0000_0000_0000_0010;
   cla_16b add_2 (.A(PC_curr), .B(two), .C_in(1'b0), .S(PC_Next), .C_out(C_out));

   // use a dff to store HALT signal
   wire halt_q;
   dff dff_halt (.q(halt_q), .d(Halt), .clk(clk), .rst(rst));

   assign No_Branch = halt_q ? PC_curr : PC_Next;
   wire stall_temp;
   // instruction memory
   //memory2c_align instr_mem(.data_out(instr), .data_in(16'b0), .addr(PC_curr), .enable(~halt_q), .wr(1'b0), .createdump(halt_q), .clk(clk), .rst(rst), .err(err));
   stallmem instr_mem(.DataOut(instr), .Done(Done), .Stall(stall_temp), .CacheHit(CacheHit), .err(err), .Addr(PC_curr), .DataIn(16'bx), .Rd(~halt_q), .Wr(1'b0), .createdump(halt_q), .clk(clk), .rst(rst));
   assign halt_back = halt_q;
   assign Stall_imem = stall_temp & ~Done;
   // wire err_sig;
   // assign err_sig = ^{PC_Back, Halt};
   // assign err = (err_sig === 1'bx) | err_reg;
   
endmodule
