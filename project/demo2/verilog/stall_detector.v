module stall_detector (instr_reg, Reg_wrt_reg_ID, target_reg_ID, Reg_wrt_reg_EX, target_reg_EX, Alu_src_reg, STALL);
input [15:0] instr_reg;
input Reg_wrt_reg_ID, Reg_wrt_reg_EX;
input [2:0] target_reg_ID, target_reg_EX; 
output STALL;

wire IDEX_wrt;
wire IDEX_Rs;
wire IDEX_Rt;
wire IDEX_stall;
assign IDEX_wrt = (target_reg_ID != 3'b000) & (Reg_wrt_reg_ID == 1'b1); 
assign IDEX_Rs = (instr_reg[10:8] == target_reg_ID);
assign IDEX_Rt = (instr_reg[7:5] == target_reg_ID) & (Alu_src_reg == 2'b00);
assign IDEX_stall = IDEX_wrt & (IDEX_Rs | IDEX_Rt);

wire EXM_wrt;
wire EXM_Rs;
wire EXM_Rt;
wire EXM_stall;
assign EXM_wrt = (target_reg_EX != 3'b000) & (Reg_wrt_reg_EX == 1'b1);
assign EXM_Rs = (instr_reg[10:8] == target_reg_EX);
assign EXM_Rt = (instr_reg[7:5] == target_reg_EX) & (Alu_src_reg == 2'b00);
assign EXM_stall = EXM_wrt & (EXM_Rs | EXM_Rt);

assign STALL = IDEX_stall | EXM_stall; 



endmodule