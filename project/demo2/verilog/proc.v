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

   // Fetch Stage
   wire  Halt, halt_back;
   wire STALL, Branch_stall; 
   wire [15:0] PC_Back,PC_Next, No_Branch, instr, PC_Back_reg; 
	fetch fet(
        // system inputs
	.clk(clk), .rst(rst), 
	// inputs from Decode
	.PC_Back(PC_Back_reg), .Halt(Halt), .STALL(STALL), .Branch_stall(Branch_stall),
	// Outputs to Decode
	.No_Branch(No_Branch), .instr(instr), .halt_back(halt_back),
        // Output to WB
        .PC_Next(PC_Next) // .PC_curr(PC_curr)
	);

   
   wire [15:0] instr_withNOP;
   // add a mux to choose from normal instr or NOP on stall of Branch
   assign instr_withNOP = Branch_stall ? 16'b00001_xxxxxxxxxxx : instr;


   // IF/ID Pip Reg
   wire IFD_en,IFD_err;
   assign IFD_en = ~STALL;

   wire halt_back_reg;
   wire [15:0] pc_next_reg_IF, no_branch_reg, instr_reg;
   reg_16 IFD_reg_PCNEXTIF(.readData(pc_next_reg_IF), .err(IFD_err), .clk(clk), .rst(rst), .writeData(PC_Next), .writeEn(IFD_en));
   reg_16 IFD_reg_NOBRANCH(.readData(no_branch_reg), .err(IFD_err), .clk(clk), .rst(rst), .writeData(No_Branch), .writeEn(IFD_en));
   reg_16 IFD_reg_INSTR(.readData(instr_reg), .err(IFD_err), .clk(clk), .rst(rst), .writeData(instr_withNOP), .writeEn(IFD_en));
   reg_16 #(.SIZE(1)) IFD_reg_HALTBACK(.readData(halt_back_reg), .err(IFD_err), .clk(clk), .rst(rst), .writeData(halt_back), .writeEn(IFD_en));


   wire [15:0] instr_withNOP_stall;
   // add a mux to choose from normal instr or NOP on stall of other cases, after IF/ID pip reg.
   assign instr_withNOP_stall = (STALL | rst) ? 16'b00001_xxxxxxxxxxx : instr_reg;
   
   

   // Decode stage
   wire Mem_read, Mem_wrt, Reg_wrt, Reg_wrt_reg_ID, Reg_wrt_reg_MEM, Reg_wrt_reg_EX;
   wire [15:0] WB;
   wire [1:0] Op_ext, WB_sel,Alu_src, Alu_src_reg;
   wire [2:0] Alu_result, target_reg, target_reg_ID, target_reg_MEM, target_reg_EX;
   wire [4:0] Alu_op;
   wire [15:0] data1,data2,extend;
	
        decode dec(
        // IN from Fetch
	.instr(instr_withNOP_stall), .No_Branch(no_branch_reg), .halt_back(halt_back_reg),
        // IN from Exec
        // .result(result), .neg(neg), .zero(zero),
        // IN from WB
        .WB(WB), .target_reg_WB(target_reg_MEM), .Reg_wrt_WB(Reg_wrt_reg_MEM),
        // Global In
        .clk(clk), .rst(rst),
	// Out Control Logic
	.Halt(Halt),.WB_sel(WB_sel),.Alu_src(Alu_src),.Alu_result(Alu_result),.Alu_op(Alu_op),.Mem_read(Mem_read),.Mem_wrt(Mem_wrt), .target_reg(target_reg), .Reg_wrt(Reg_wrt),
        // Out to Exec
	.data1(data1),.data2(data2),.extend(extend), .Op_ext(Op_ext),
        // Out to Fetch
        .PC_back(PC_Back), .Branch_stall(Branch_stall),
        // Global out
        .err(err_1));

   
   // stall detector
   stall_detector stalldetec(.instr_reg(instr_reg), .Reg_wrt_reg_ID(Reg_wrt_reg_ID), .target_reg_ID(target_reg_ID), .Reg_wrt_reg_EX(Reg_wrt_reg_EX), 
   .target_reg_EX(target_reg_EX), .Alu_src_reg(Alu_src_reg), .STALL(STALL));


    // ID/EX pip reg
   wire IDEX_en,IDEX_err;
   wire Mem_read_reg_ID, Mem_wrt_reg_ID, Halt_reg_ID;
   wire [1:0] Op_ext_reg, WB_sel_reg_ID;
   wire [2:0] Alu_result_reg_ID;
   wire [4:0] Alu_op_reg;
   wire [15:0] data1_reg, data2_reg_ID, extend_reg_ID, pc_next_reg_ID;
   assign IDEX_en = 1'b1;
   reg_16 #(.SIZE(1)) IDEX_reg_MEMREADID(.readData(Mem_read_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(Mem_read), .writeEn(IDEX_en));
   reg_16 #(.SIZE(1)) IDEX_reg_MEMWRTID(.readData(Mem_wrt_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(Mem_wrt), .writeEn(IDEX_en));
   reg_16 #(.SIZE(1)) IDEX_reg_HALTID(.readData(Halt_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(Halt), .writeEn(IDEX_en));
   reg_16 #(.SIZE(1)) IDEX_reg_REGWRTID(.readData(Reg_wrt_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(Reg_wrt), .writeEn(IDEX_en));
   reg_16 #(.SIZE(2)) IDEX_reg_OPEXT(.readData(Op_ext_reg), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(Op_ext), .writeEn(IDEX_en));
   reg_16 #(.SIZE(2)) IDEX_reg_WBSELID(.readData(WB_sel_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(WB_sel), .writeEn(IDEX_en));
   reg_16 #(.SIZE(3)) IDEX_reg_TARGETREGID(.readData(target_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(target_reg), .writeEn(IDEX_en));
   reg_16 #(.SIZE(2)) IDEX_reg_ALUSRC(.readData(Alu_src_reg), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(Alu_src), .writeEn(IDEX_en));
   reg_16 #(.SIZE(3)) IDEX_reg_ALURESULTID(.readData(Alu_result_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(Alu_result), .writeEn(IDEX_en));
   reg_16 #(.SIZE(5)) IDEX_reg_ALUOP(.readData(Alu_op_reg), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(Alu_op), .writeEn(IDEX_en));
   reg_16 #(.SIZE(16)) IDEX_reg_DATA1(.readData(data1_reg), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(data1), .writeEn(IDEX_en));
   reg_16 #(.SIZE(16)) IDEX_reg_DATA2ID(.readData(data2_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(data2), .writeEn(IDEX_en));
   reg_16 #(.SIZE(16)) IDEX_reg_EXTENDID(.readData(extend_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(extend), .writeEn(IDEX_en));
   reg_16 #(.SIZE(16)) IDEX_reg_PCBACK(.readData(PC_Back_reg), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(PC_Back), .writeEn(IDEX_en));
   reg_16 #(.SIZE(16)) IDEX_reg_PCNEXTID(.readData(pc_next_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(pc_next_reg_IF), .writeEn(IDEX_en));
   

    // Execute stage
   wire neg, zero;
   wire [15:0] Cout, SLBI, BTR, result;
	
        execute exe(
	// Inputs from Decode
	.data1(data1_reg), .data2(data2_reg_ID), .extend(extend_reg_ID), .Alu_Src(Alu_src_reg), .Alu_op(Alu_op_reg), .Op_ext(Op_ext_reg), 
	// Outputs to Decode/Memory
	.result(result), .zero(zero), .neg(neg), .Cout(Cout), .SLBI(SLBI), .BTR(BTR), .err(err_2)
	);


    // EX/MEM pip reg
   wire EXMEM_en, EXMEM_err;
   wire neg_reg, zero_reg, Halt_reg_EX, Mem_read_reg_EX, Mem_wrt_reg_EX;
   wire [1:0] WB_sel_reg_EX;
   wire [2:0] Alu_result_reg_EX;
   wire [15:0] data2_reg_EX, extend_reg_EX, pc_next_reg_EX, result_reg, Cout_reg, SLBI_reg, BTR_reg; 
   assign EXMEM_en = 1'b1; 
   reg_16 #(.SIZE(1)) EXMEM_reg_NEG(.readData(neg_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(neg), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(1)) EXMEM_reg_ZERO(.readData(zero_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(zero), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(1)) EXMEM_reg_HALTEX(.readData(Halt_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Halt_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(1)) EXMEM_reg_MEMREADEX(.readData(Mem_read_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Mem_read_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(1)) EXMEM_reg_MEMWRTEX(.readData(Mem_wrt_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Mem_wrt_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(1)) EXMEM_reg_REGWRTEX(.readData(Reg_wrt_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Reg_wrt_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(2)) EXMEM_reg_WBSELEX(.readData(WB_sel_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(WB_sel_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(3)) EXMEM_reg_TARGETREGEX(.readData(target_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(target_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(3)) EXMEM_reg_ALURESULTEX(.readData(Alu_result_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Alu_result_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_DATA2EX(.readData(data2_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(data2_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_EXTENDEX(.readData(extend_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(extend_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_PCNEXTEX(.readData(pc_next_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(pc_next_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_RESULT(.readData(result_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(result), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_COUT(.readData(Cout_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Cout), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_SLBI(.readData(SLBI_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(SLBI), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_BTR(.readData(BTR_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(BTR), .writeEn(EXMEM_en));





    // MEM Stage
   wire [15:0] data_mem, data_exe;
	
        memory mem(
	// system inputs
	.clk(clk), .rst(rst),
	// input from Decode
        .data2(data2_reg_EX), .Mem_read(Mem_read_reg_EX), .Mem_wrt(Mem_wrt_reg_EX), .Halt(Halt_reg_EX), .Alu_result(Alu_result_reg_EX),
	// inputs from Execute
	.result(result_reg), .zero(zero_reg), .neg(neg_reg), .BTR(BTR_reg), .SLBI(SLBI_reg), .Cout(Cout_reg),  
	// outputs to WB
	.data_mem(data_mem), .data_exe(data_exe)
	);


    // MEM/WB pip reg
   wire MEMWB_en, MEMWB_err;
   wire[1:0] WB_sel_reg_MEM;
   wire[15:0] data_mem_reg, data_exe_reg, extend_reg_MEM, pc_next_reg_MEM;
   assign MEMWB_en = 1'b1;
   reg_16 #(.SIZE(1)) MEMWB_reg_REGWRTMEM(.readData(Reg_wrt_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(Reg_wrt_reg_EX), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(2)) MEMWB_reg_WBSELMEM(.readData(WB_sel_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(WB_sel_reg_EX), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(3)) MEMWB_reg_TARGETREGMEM(.readData(target_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(target_reg_EX), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(16)) MEMWB_reg_DATAMEM(.readData(data_mem_reg), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(data_mem), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(16)) MEMWB_reg_DATAEXE(.readData(data_exe_reg), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(data_exe), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(16)) MEMWB_reg_EXTENDMEM(.readData(extend_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(extend_reg_EX), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(16)) MEMWB_reg_PCNEXTMEM(.readData(pc_next_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(pc_next_reg_EX), .writeEn(MEMWB_en));


    // WB Stage
	wb wrib(
        // IN from Fetch
        .PC_Next(pc_next_reg_MEM),
        // IN from Decode
        .extend(extend_reg_MEM), .WB_sel(WB_sel),
        // IN from Mem
        .data_mem(data_mem_reg), .data_exe(data_exe_reg),
        // Out to Decode
        .WB(WB));
   	
	assign err = 1'b0;
		
endmodule 

