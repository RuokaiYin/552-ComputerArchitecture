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
   wire err_mem_fetch, Stall_imem, Stall_dmem, branch_with_stall;


   // test wires
   wire[15:0] instr_test_ex, instr_test_mem;


   // Fetch Stage
   wire  Halt, halt_back;
   wire STALL, Branch_stall; 
   wire [15:0] PC_Back,PC_Next, No_Branch, instr; 
	fetch fet(
        // system inputs
	.clk(clk), .rst(rst), .Stall_dmem(Stall_dmem),
	// inputs from Decode
	.PC_Back(PC_Back), .Halt(Halt), .STALL(STALL), .Branch_stall(Branch_stall),
	// Outputs to Decode
	.No_Branch(No_Branch), .instr(instr), .halt_back(halt_back),
        // Output to WB
        .PC_Next(PC_Next), // .PC_curr(PC_curr)
	.err(err_mem_fetch), .Stall_imem(Stall_imem), .branch_with_stall(branch_with_stall));

   
   wire [15:0] instr_withNOP;
   // add a mux to choose from normal instr or NOP on stall of Branch
   assign instr_withNOP = (Branch_stall|Stall_imem|branch_with_stall) ? 16'b00001_xxxxxxxxxxx : instr;


   // IF/ID Pip Reg
   wire IFD_en,IFD_err;
   assign IFD_en = (~STALL) & (~Stall_dmem);

   wire halt_back_reg, err_mem_fetch_reg_IF;
   wire [15:0] pc_next_reg_IF, no_branch_reg, instr_reg;
   reg_16 IFD_reg_PCNEXTIF(.readData(pc_next_reg_IF), .err(IFD_err), .clk(clk), .rst(rst), .writeData(PC_Next), .writeEn(IFD_en));
   reg_16 IFD_reg_NOBRANCH(.readData(no_branch_reg), .err(IFD_err), .clk(clk), .rst(rst), .writeData(No_Branch), .writeEn(IFD_en));
   reg_16 IFD_reg_INSTR(.readData(instr_reg), .err(IFD_err), .clk(clk), .rst(rst), .writeData(instr_withNOP), .writeEn(IFD_en));
   reg_16 #(.SIZE(1)) IFD_reg_HALTBACK(.readData(halt_back_reg), .err(IFD_err), .clk(clk), .rst(rst), .writeData(halt_back), .writeEn(IFD_en));
   reg_16 #(.SIZE(1)) IFD_reg_ERRMEM(.readData(err_mem_fetch_reg_IF), .err(IFD_err), .clk(clk), .rst(rst), .writeData(err_mem_fetch), .writeEn(IFD_en));


   wire [15:0] instr_withNOP_stall;
   // add a mux to choose from normal instr or NOP on stall of other cases, after IF/ID pip reg.
   assign instr_withNOP_stall = (STALL | rst) ? 16'b00001_xxxxxxxxxxx : instr_reg;
   
   wire [4:0] Alu_op_reg;

   // forwarding and stall
   wire[2:0] target_reg_ID, target_reg_EX;
   wire Rs_exe, Rs_mem, Rt_exe, Rt_mem, Rs_exe_q, Rs_mem_q, Rt_exe_q, Rt_mem_q, err_forwarding, Mem_read_reg_ID, Reg_wrt_reg_ID, Reg_wrt_reg_EX, Mem_read_reg_EX;
   // stall detector
   stall_detector stalldetec(.instr_reg(instr_reg), .Reg_wrt_reg_ID(Reg_wrt_reg_ID), .target_reg_ID(target_reg_ID), .Reg_wrt_reg_EX(Reg_wrt_reg_EX), 
   .target_reg_EX(target_reg_EX), .Mem_read_ID(Mem_read_reg_ID), .Mem_read_EX(Mem_read_reg_EX), .STALL(STALL));

   forwarding_detector forwardingdetec(.instr_reg(instr_reg), .Reg_wrt_reg_ID(Reg_wrt_reg_ID), .target_reg_ID(target_reg_ID), .Reg_wrt_reg_EX(Reg_wrt_reg_EX), 
   .target_reg_EX(target_reg_EX), .Mem_read_ID(Mem_read_reg_ID), .Rs_exe(Rs_exe), .Rs_mem(Rs_mem), .Rt_exe(Rt_exe), .Rt_mem(Rt_mem));
   reg_16 #(.SIZE(1)) Rs_exe_reg(.readData(Rs_exe_q), .err(err_forwarding), .clk(clk), .rst(rst), .writeData(Rs_exe), .writeEn(1'b1));
   reg_16 #(.SIZE(1)) Rs_mem_reg(.readData(Rs_mem_q), .err(err_forwarding), .clk(clk), .rst(rst), .writeData(Rs_mem), .writeEn(1'b1));
   reg_16 #(.SIZE(1)) Rt_exe_reg(.readData(Rt_exe_q), .err(err_forwarding), .clk(clk), .rst(rst), .writeData(Rt_exe), .writeEn(1'b1));
   reg_16 #(.SIZE(1)) Rt_mem_reg(.readData(Rt_mem_q), .err(err_forwarding), .clk(clk), .rst(rst), .writeData(Rt_mem), .writeEn(1'b1));

   wire[15:0] data1_real, data2_real, data_exe_temp, data_mem_temp, data1_reg, data2_reg_ID, result_temp;
   wire [1:0] WB_sel_reg_EX, WB_sel_reg_MEM;
   wire [15:0] pc_next_reg_EX, extend_reg_EX, data_exe_reg, result_reg, data_mem_reg, extend_reg_MEM, pc_next_reg_MEM;
   wire [15:0] SLBI_reg, BTR_reg, Cout_reg;
   wire[15:0] data1_real_stall, data2_real_stall;
   wire [15:0] data1_real_q, data2_real_q;
   wire neg_reg, zero_reg, takeForward;
   wire fStall_dmem_q, fStall_dmem_nextcycle, fStall_dmem_prevcycle;
   wire [2:0] Alu_result_reg_EX;
   assign result_temp = Alu_result_reg_EX[2] ? 
                        (Alu_result_reg_EX[1] ? 
                        (Alu_result_reg_EX[0] ? 16'bx : SLBI_reg) : 
                        (Alu_result_reg_EX[0] ? BTR_reg : {15'b0, (zero_reg|neg_reg)})) : 
                        (Alu_result_reg_EX[1] ? (Alu_result_reg_EX[0] ? {15'b0, neg_reg} : {15'b0, zero_reg}) : 
                        (Alu_result_reg_EX[0] ? Cout_reg : result_reg));
   assign data_exe_temp = (WB_sel_reg_EX[1]) ? ((WB_sel_reg_EX[0]) ? (pc_next_reg_EX) : (extend_reg_EX)) : ((WB_sel_reg_EX[0]) ? (result_temp) : 16'b0);
   assign data_mem_temp = (WB_sel_reg_MEM[1]) ? ((WB_sel_reg_MEM[0]) ? (pc_next_reg_MEM) : (extend_reg_MEM)) : ((WB_sel_reg_MEM[0]) ? (data_exe_reg) : (data_mem_reg));
   assign data1_real = Rs_exe_q ? (data_exe_temp) : (Rs_mem_q ? data_mem_temp : data1_reg);
   assign data2_real = Rt_exe_q ? (data_exe_temp) : (Rt_mem_q ? data_mem_temp : data2_reg_ID);

   // deal with dmem stall 
   reg_16 #(.SIZE(16)) data1_real_reg(.readData(data1_real_q), .err(err_forwarding), .clk(clk), .rst(rst), .writeData(data1_real), .writeEn(fStall_dmem_prevcycle));
   reg_16 #(.SIZE(16)) data2_real_reg(.readData(data2_real_q), .err(err_forwarding), .clk(clk), .rst(rst), .writeData(data2_real), .writeEn(fStall_dmem_prevcycle));
   
   assign data1_real_stall = fStall_dmem_nextcycle ? data1_real_q : data1_real;
   assign data2_real_stall = fStall_dmem_nextcycle ? data2_real_q : data2_real;
   reg_16 #(.SIZE(1)) fstall_dmem_reg(.readData(fStall_dmem_q), .err(err_forwarding), .clk(clk), .rst(rst), .writeData(Stall_dmem), .writeEn(1'b1));
   assign fStall_dmem_nextcycle = fStall_dmem_q & ~Stall_dmem;
   assign fStall_dmem_prevcycle = ~fStall_dmem_q & Stall_dmem; 

   // For branch and jumpR
   assign takeForward = Rs_mem & (~Mem_read_reg_EX);




   // Decode stage
   wire Mem_read, Mem_wrt, Reg_wrt, Reg_wrt_reg_MEM, err_mem_fetch_reg_ID;
   wire [15:0] WB;
   wire [1:0] Op_ext, WB_sel,Alu_src, Alu_src_reg;
   wire [2:0] Alu_result, target_reg, target_reg_MEM;
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
        .clk(clk), .rst(rst), .Stall_dmem(Stall_dmem), .takeForward(takeForward), .data1_exe(data_exe_temp),
	// Out Control Logic
	.Halt(Halt),.WB_sel(WB_sel),.Alu_src(Alu_src),.Alu_result(Alu_result),.Alu_op(Alu_op),.Mem_read(Mem_read),.Mem_wrt(Mem_wrt), .target_reg(target_reg), .Reg_wrt(Reg_wrt),
        // Out to Exec
	.data1(data1),.data2(data2),.extend(extend), .Op_ext(Op_ext),
        // Out to Fetch
        .PC_back(PC_Back), .Branch_stall(Branch_stall),
        // Global out
        .err(err_1));

    // ID/EX pip reg
   wire IDEX_en,IDEX_err;
   wire Mem_wrt_reg_ID, Halt_reg_ID;
   wire [1:0] Op_ext_reg, WB_sel_reg_ID;
   wire [2:0] Alu_result_reg_ID;
   wire [15:0] extend_reg_ID, pc_next_reg_ID;
   assign IDEX_en = ~Stall_dmem;
   reg_16 test_instr_EX(.readData(instr_test_ex), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(instr_withNOP_stall), .writeEn(IDEX_en));
   reg_16 #(.SIZE(1)) IDEX_reg_ERRMEM(.readData(err_mem_fetch_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(err_mem_fetch_reg_IF), .writeEn(IDEX_en));
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
//    reg_16 #(.SIZE(16)) IDEX_reg_PCBACK(.readData(PC_Back_reg), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(PC_Back), .writeEn(IDEX_en));
   reg_16 #(.SIZE(16)) IDEX_reg_PCNEXTID(.readData(pc_next_reg_ID), .err(IDEX_err), .clk(clk), .rst(rst), .writeData(pc_next_reg_IF), .writeEn(IDEX_en));
   
    
    // Execute stage
   wire neg, zero;
   wire [15:0] Cout, SLBI, BTR, result;
	
        execute exe(
	// Inputs from Decode
	.data1(data1_real_stall), .data2(data2_real_stall), .extend(extend_reg_ID), .Alu_Src(Alu_src_reg), .Alu_op(Alu_op_reg), .Op_ext(Op_ext_reg), 
	// Outputs to Decode/Memory
	.result(result), .zero(zero), .neg(neg), .Cout(Cout), .SLBI(SLBI), .BTR(BTR), .err(err_2)
	);


    // EX/MEM pip reg
   wire EXMEM_en, EXMEM_err;
   wire Mem_read_real, Mem_wrt_real, Reg_wrt_real; // Mem_read_copy, Mem_wrt_copy;
   wire Halt_reg_EX, Mem_wrt_reg_EX, err_mem_fetch_reg_EX;
   wire [15:0] data2_reg_EX; 
   assign EXMEM_en = ~Stall_dmem;
   reg_16 test_instr_MEM(.readData(instr_test_mem), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(instr_test_ex), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(1)) EXMEM_reg_ERRMEM(.readData(err_mem_fetch_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(err_mem_fetch_reg_ID), .writeEn(EXMEM_en)); 
   reg_16 #(.SIZE(1)) EXMEM_reg_NEG(.readData(neg_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(neg), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(1)) EXMEM_reg_ZERO(.readData(zero_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(zero), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(1)) EXMEM_reg_HALTEX(.readData(Halt_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Halt_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(1)) EXMEM_reg_MEMREADEX(.readData(Mem_read_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Mem_read_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(1)) EXMEM_reg_MEMWRTEX(.readData(Mem_wrt_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Mem_wrt_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(1)) EXMEM_reg_REGWRTEX(.readData(Reg_wrt_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Reg_wrt_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(2)) EXMEM_reg_WBSELEX(.readData(WB_sel_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(WB_sel_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(3)) EXMEM_reg_TARGETREGEX(.readData(target_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(target_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(3)) EXMEM_reg_ALURESULTEX(.readData(Alu_result_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Alu_result_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_DATA2EX(.readData(data2_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(data2_real_stall), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_EXTENDEX(.readData(extend_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(extend_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_PCNEXTEX(.readData(pc_next_reg_EX), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(pc_next_reg_ID), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_RESULT(.readData(result_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(result), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_COUT(.readData(Cout_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(Cout), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_SLBI(.readData(SLBI_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(SLBI), .writeEn(EXMEM_en));
   reg_16 #(.SIZE(16)) EXMEM_reg_BTR(.readData(BTR_reg), .err(EXMEM_err), .clk(clk), .rst(rst), .writeData(BTR), .writeEn(EXMEM_en));

   // reg_16 #(.SIZE(1)) EXMEM_reg_MEMREADEX(.readData(Mem_read_), .err(EXMEM_err), .clk(clk), .rst(rst|Done), .writeDataMem_read_reg_EX .writeEn(EXMEM_en));
   // reg_16 #(.SIZE(1)) EXMEM_reg_MEMWRTEX(.readData(Mem_wrt_real), .err(EXMEM_err), .clk(clk), .rst(rst|Done), .writeData(Mem_wrt_reg_ID), .writeEn(1'b1));
   assign Mem_read_real = Mem_read_reg_EX & (~Stall_dmem); 
   assign Mem_wrt_real = Mem_wrt_reg_EX & (~Stall_dmem);
   assign Reg_wrt_real = (Reg_wrt_reg_MEM & fStall_dmem_prevcycle) | (Reg_wrt_reg_MEM & (~fStall_dmem_nextcycle & ~Stall_dmem));


    // MEM Stage
   wire [15:0] data_mem, data_exe;
   wire err_mem_mem;
	
        memory mem(
	// system inputs
	.clk(clk), .rst(rst),
	// input from Decode
        .data2(data2_reg_EX), .Mem_read(Mem_read_reg_EX), .Mem_wrt(Mem_wrt_reg_EX), .Halt(Halt_reg_EX), .Alu_result(Alu_result_reg_EX),
	// inputs from Execute
	.result(result_reg), .zero(zero_reg), .neg(neg_reg), .BTR(BTR_reg), .SLBI(SLBI_reg), .Cout(Cout_reg),  
	// outputs to WB
	.data_mem(data_mem), .data_exe(data_exe), .err(err_mem_mem),
        // global output
        .Stall_dmem(Stall_dmem)
	);


    // MEM/WB pip reg
   wire MEMWB_en, MEMWB_err, err_mem_fetch_reg_MEM, Halt_reg_MEM;//, err_mem_mem_reg;
   // wire[15:0] data_mem_reg, extend_reg_MEM, pc_next_reg_MEM;
   assign MEMWB_en = ~Stall_dmem;
//    reg_16 #(.SIZE(1)) MEMWB_reg_ERRMEMMEM(.readData(err_mem_mem_reg), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(err_mem_mem), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(1)) MEMWB_reg_ERRMEM(.readData(err_mem_fetch_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(err_mem_fetch_reg_EX), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(1)) MEMWB_reg_REGWRTMEM(.readData(Reg_wrt_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(Reg_wrt_reg_EX), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(2)) MEMWB_reg_WBSELMEM(.readData(WB_sel_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(WB_sel_reg_EX), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(3)) MEMWB_reg_TARGETREGMEM(.readData(target_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(target_reg_EX), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(16)) MEMWB_reg_DATAMEM(.readData(data_mem_reg), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(data_mem), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(16)) MEMWB_reg_DATAEXE(.readData(data_exe_reg), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(data_exe), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(16)) MEMWB_reg_EXTENDMEM(.readData(extend_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(extend_reg_EX), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(16)) MEMWB_reg_PCNEXTMEM(.readData(pc_next_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(pc_next_reg_EX), .writeEn(MEMWB_en));
   reg_16 #(.SIZE(1)) MEMWB_reg_HALTMEM(.readData(Halt_reg_MEM), .err(MEMWB_err), .clk(clk), .rst(rst), .writeData(Halt_reg_EX), .writeEn(MEMWB_en));

    // WB Stage
	wb wrib(
        // IN from Fetch
        .PC_Next(pc_next_reg_MEM),
        // IN from Decode
        .extend(extend_reg_MEM), .WB_sel(WB_sel_reg_MEM),
        // IN from Mem
        .data_mem(data_mem_reg), .data_exe(data_exe_reg),
        // Out to Decode
        .WB(WB));
   	
	assign err = err_mem_fetch_reg_MEM | err_mem_mem;
		
endmodule 

