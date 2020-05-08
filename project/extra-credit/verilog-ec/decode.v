/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (
        // IN from Fetch
	instr, No_Branch, halt_back,
        // IN from Exec //TODO：make branch inside
        // result,neg,zero,
        // IN from WB
        WB, target_reg_WB, Reg_wrt_WB,
        // Global In
        clk, rst, Stall_dmem, takeForward, data1_exe, 
	// Out Control Logic
	Halt,WB_sel,Alu_src,Alu_result,Alu_op,Mem_read,Mem_wrt,target_reg,Reg_wrt,
        // Out to Exec
	data1,data2,extend,Op_ext,
        // Out to Fetch
        PC_back, Branch_stall,
        // Global out
        err, fwd, siic, rti);
	

   // TODO: Your code here
   input clk, rst, halt_back, Reg_wrt_WB, Stall_dmem, takeForward;
   input [2:0] target_reg_WB;
   input [15:0] instr, WB, No_Branch, data1_exe;

   output Halt,Mem_read,Mem_wrt,err,Branch_stall, Reg_wrt, fwd, siic, rti;
   output [1:0] Op_ext, WB_sel,Alu_src;
   output [2:0] Alu_result, target_reg;
   output [4:0] Alu_op;
   output [15:0] data1,data2,extend, PC_back;

   // local control unit
   wire[15:0] result_jmp;
   wire[1:0] WB_tar, Branch_sel;
   wire I_sel, J_sel, Sign_sel, Jmp, Jmp_sel, neg, zero, Branch;

   wire valid,err_valid_temp, Stall_dmem_q;
   wire [15:0] previous_instr;
   reg_16 valid_reg(.readData(previous_instr), .err(err_valid_temp), .clk(clk), .rst(rst), .writeData(instr), .writeEn(1'b1));
   reg_16 #(.SIZE(1))previous_stall_dmem(.readData(Stall_dmem_q), .err(err_valid_temp), .clk(clk), .rst(rst), .writeData(Stall_dmem), .writeEn(1'b1));
   assign valid = (|(previous_instr[15:11] | (instr[15:11]))) | Stall_dmem_q;
   

   wire [4:0] instr_valid;
   assign instr_valid = valid ? instr[15:11] : 5'b00001; 

   // control unit
   wire err_control;
   instr_decoder ins_dec(instr_valid,halt_back,Halt,WB_sel,Branch_sel,Alu_src,Alu_result,Alu_op,Mem_read,Mem_wrt,I_sel,J_sel
	,Sign_sel,WB_tar,Reg_wrt, Branch, Jmp_sel, Jmp, err_control, fwd, siic, rti);
   
   // signal to choose which reg to write
   assign target_reg = (WB_tar[1]) ? ((WB_tar[0]) ? (3'b111) : (instr[4:2])) : ((WB_tar[0]) ? (instr[7:5]) : (instr[10:8]));

   // register file
   wire err_reg;
   regFile_bypass regi_file(.read1Data(data1), .read2Data(data2), .err(err_reg), .clk(clk), .rst(rst), .read1RegSel(instr[10:8]), 
   	.read2RegSel(instr[7:5]), .writeRegSel(target_reg_WB), .writeData(WB), .writeEn(Reg_wrt_WB & (~Stall_dmem)));  

   // Logic for extension
   wire [15:0] zero_extend, sign_extend;
   
   assign zero_extend = I_sel ? {{8{1'b0}},instr[7:0]} : {{11{1'b0}},instr[4:0]};
   assign sign_extend = J_sel ? ({{5{instr[10]}},instr[10:0]}) : (I_sel ? ({{8{instr[7]}},instr[7:0]}) : ({{11{instr[4]}},instr[4:0]}));
   assign extend = Sign_sel ? (sign_extend) : (zero_extend);

   // Logic for branch
   wire [15:0] branch_mux_1;
   wire branch_sel_mux;  
   wire pc_back_sel; // sel sig to sel PC_back
   wire [15:0] Bran; // addr of branch
   wire idle_cout_bran, idle_cout_jmp; // no-use wire for C_out
   
   // logic zero and neg
   wire [15:0] data1_jump; 
   assign zero = takeForward ? ~(|data1_exe) : ~(|data1);
   assign neg = takeForward ? data1_exe[15] : data1[15];
   assign data1_jump = takeForward ? data1_exe : data1; 


   // adders
   cla_16b bran_adder(.A(extend), .B(No_Branch), .C_in(1'b0), .S(Bran), .C_out(idle_cout_bran)); // adder to add branch result
   cla_16b jmp_adder(.A(extend), .B(data1_jump), .C_in(1'b0), .S(result_jmp), .C_out(idle_cout_jmp)); // adder to add jmp result
   
   assign branch_mux_1 = Jmp_sel ? result_jmp : No_Branch;
   assign branch_sel_mux = (Branch_sel[1]) ? ((Branch_sel[0]) ? (~neg) : (neg)) : ((Branch_sel[0]) ? (~zero) : (zero));
   assign pc_back_sel = (Branch & branch_sel_mux) | Jmp;
   assign PC_back = pc_back_sel ? Bran : branch_mux_1;
   assign Op_ext = instr[1:0];

   // signal to detect Branch stall
   assign Branch_stall = (Jmp_sel | pc_back_sel) | (siic | rti);

   // wire err_sig;
   // assign err_sig = ^{instr, No_Branch, halt_back,result,neg,zero,WB};
   assign err = err_control;


endmodule