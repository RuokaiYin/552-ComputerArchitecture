module stall_detector (instr_reg, Reg_wrt_reg_ID, target_reg_ID, Reg_wrt_reg_EX, target_reg_EX, STALL);
input [15:0] instr_reg;
input Reg_wrt_reg_ID, Reg_wrt_reg_EX;
// input [1:0] Alu_src_reg;
input [2:0] target_reg_ID, target_reg_EX; 
// input [4:0] Alu_op_reg; 
output STALL;

wire alu_src;
assign alu_src = (instr_reg[15:14] == 2'b11) & (instr_reg[15:11] != 5'b11001);

wire IDEX_wrt;
wire IDEX_Rs;
wire IDEX_Rt;
wire IDEX_stall;
assign IDEX_wrt = (Reg_wrt_reg_ID == 1'b1) & (instr_reg[15:11] != 5'b11000); 
assign IDEX_Rs = (instr_reg[10:8] == target_reg_ID);
assign IDEX_Rt = (instr_reg[7:5] == target_reg_ID) & (alu_src);
assign IDEX_stall = IDEX_wrt & (IDEX_Rs | IDEX_Rt);

wire EXM_wrt;
wire EXM_Rs;
wire EXM_Rt;
wire EXM_stall;
assign EXM_wrt = (Reg_wrt_reg_EX == 1'b1) & (instr_reg[15:11] != 5'b11000);
assign EXM_Rs = (instr_reg[10:8] == target_reg_EX);
assign EXM_Rt = (instr_reg[7:5] == target_reg_EX) & (alu_src);
assign EXM_stall = EXM_wrt & (EXM_Rs | EXM_Rt);

assign STALL = IDEX_stall | EXM_stall; 



endmodule