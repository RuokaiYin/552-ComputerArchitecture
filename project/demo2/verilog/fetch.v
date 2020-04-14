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
	err
	); 

   // TODO: Your code here
   input clk, rst, Halt, STALL, Branch_stall; 
   input [15:0] PC_Back;

   output [15:0] PC_Next, No_Branch, instr; 
   output halt_back, err; 

   // use a 16-bit register to store the PC value
   wire [15:0] PC_curr, PC_wb;
   wire err_reg;
    // a mux to choose from normal pc+2 or pc_back
   assign PC_wb = Branch_stall ? PC_Back : PC_Next;
   reg_16 pc_reg (.readData(PC_curr), .err(err_reg), .clk(clk), .rst(rst), .writeData(PC_wb), .writeEn(~STALL));
   
  
   // add current PC value by 2 
   wire [15:0]two;
   wire C_out;

   assign two = 16'b0000_0000_0000_0010;
   cla_16b add_2 (.A(PC_curr), .B(two), .C_in(1'b0), .S(PC_Next), .C_out(C_out));

   // use a dff to store HALT signal
   wire halt_q;
   dff dff_halt (.q(halt_q), .d(Halt), .clk(clk), .rst(rst));

   assign No_Branch = halt_q ? PC_curr : PC_Next;

   // instruction memory
   memory2c_align instr_mem(.data_out(instr), .data_in(16'b0), .addr(PC_curr), .enable(~halt_q), .wr(1'b0), .createdump(halt_q), .clk(clk), .rst(rst), .err(err));
   assign halt_back = halt_q;
    
   // wire err_sig;
   // assign err_sig = ^{PC_Back, Halt};
   // assign err = (err_sig === 1'bx) | err_reg;
   
endmodule
