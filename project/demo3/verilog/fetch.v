/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (
	// system inputs
	clk, rst, Stall_dmem,
	// inputs from Decode
	PC_Back, Halt, STALL, Branch_stall,
	// Outputs to Decode
	PC_Next, No_Branch, instr, halt_back, // PC_curr
	//system output
	err, Stall_imem, branch_with_stall
	); 

   // TODO: Your code here
   input clk, rst, Halt, STALL, Branch_stall, Stall_dmem; 
   input [15:0] PC_Back;

   output [15:0] PC_Next, No_Branch, instr; 
   output halt_back, err, Stall_imem, branch_with_stall;

   wire Stall_imem_nextcycle,Stall_dmem_nextcycle, Branch_stall_q, Stall_imem_q, Stall_dmem_q, dBranch_stall_q, dStall_imem_q; 
   // use a 16-bit register to store the PC value
   wire [15:0] PC_curr, PC_wb, PC_wb_plus_stall, PC_Back_q, PC_Back_with_stall, PC_branch_opt;
   wire err_reg, err_reg_dummy1,err_reg_dummy2,err_reg_dummy3;
   wire Done, CacheHit;
   wire branch_stall_reg_clr, branch_stall_reg_en;
   // wire branch_with_stall;

   assign branch_stall_reg_clr = (Stall_imem_nextcycle & ~Stall_dmem) | Stall_dmem_nextcycle;
   assign branch_stall_reg_en = (Branch_stall&Stall_imem) | (Branch_stall&Stall_dmem);

   reg_16 #(.SIZE(1)) stall_imem_reg(.readData(Stall_imem_q), .err(err_reg_dummy1), .clk(clk), .rst(rst), .writeData(Stall_imem), .writeEn(1'b1));
   assign Stall_imem_nextcycle = Stall_imem_q & ~Stall_imem; 

   reg_16 #(.SIZE(1)) stall_dmem_reg(.readData(Stall_dmem_q), .err(err_reg_dummy1), .clk(clk), .rst(rst), .writeData(Stall_dmem), .writeEn(1'b1));
   assign Stall_dmem_nextcycle = Stall_dmem_q & ~Stall_dmem;

   reg_16 #(.SIZE(1)) branch_stall_reg(.readData(Branch_stall_q), .err(err_reg_dummy2), .clk(clk), .rst(rst|branch_stall_reg_clr), .writeData(Branch_stall), .writeEn(branch_stall_reg_en));
   reg_16 #(.SIZE(16)) pc_back_reg(.readData(PC_Back_q), .err(err_reg_dummy3), .clk(clk), .rst(rst), .writeData(PC_Back), .writeEn(Branch_stall));

   // reg_16 #(.SIZE(1)) branch_stall_reg_d(.readData(dBranch_stall_q), .err(err_reg_dummy2), .clk(clk), .rst(rst|Stall_dmem_nextcycle), .writeData(Branch_stall), .writeEn(Branch_stall&Stall_imem));
   // reg_16 #(.SIZE(16)) pc_back_reg_d(.readData(dPC_Back_q), .err(err_reg_dummy3), .clk(clk), .rst(rst), .writeData(PC_Back), .writeEn(Branch_stall));

   assign PC_Back_with_stall = (Stall_imem_nextcycle|Stall_dmem_nextcycle) ? PC_Back_q : PC_Back;
   //assign branch_with_stall = (Stall_imem_nextcycle|Stall_dmem_nextcycle) ? Branch_stall_q : Branch_stall;
   assign branch_with_stall = (Stall_imem_nextcycle) ? Branch_stall_q : Branch_stall;

    // a mux to choose from normal pc+2 or pc_back
   assign PC_wb = (branch_with_stall) ? PC_Back_with_stall : PC_Next;
   assign PC_wb_plus_stall = Stall_imem|Stall_dmem ? PC_curr: PC_wb;
   reg_16 pc_reg (.readData(PC_curr), .err(err_reg), .clk(clk), .rst(rst), .writeData(PC_wb_plus_stall), .writeEn(~STALL));
   assign PC_branch_opt = (Stall_dmem_nextcycle & Branch_stall_q) ? PC_Back_q : PC_curr;
  
   // add current PC value by 2 
   wire C_out;
   cla_16b add_2 (.A(PC_branch_opt), .B(16'b0000_0000_0000_0010), .C_in(1'b0), .S(PC_Next), .C_out(C_out));

   // use a dff to store HALT signal
   wire halt_q;
   dff dff_halt (.q(halt_q), .d(Halt), .clk(clk), .rst(rst));

   assign No_Branch = halt_q ? PC_curr : PC_Next;
   wire stall_temp;
   // instruction memory
   // memory2c_align instr_mem(.data_out(instr), .data_in(16'b0), .addr(PC_curr), .enable(~halt_q), .wr(1'b0), .createdump(halt_q), .clk(clk), .rst(rst), .err(err));
   // stallmem instr_mem(.DataOut(instr), .Done(Done), .Stall(stall_temp), .CacheHit(CacheHit), .err(err), .Addr(PC_curr), .DataIn(16'bx), .Rd(~halt_q), .Wr(1'b0), .createdump(halt_q), .clk(clk), .rst(rst));
   mem_system #(.memtype(0))mem_instr(.DataOut(instr), .Done(Done), .Stall(stall_temp), .CacheHit(CacheHit), .err(err), .Addr(PC_branch_opt), .DataIn(16'bx), .Rd(~halt_q&~Branch_stall), .Wr(1'b0), .createdump(halt_q), .clk(clk), .rst(rst));
   
   assign halt_back = halt_q;
   assign Stall_imem = stall_temp & ~Done;

endmodule