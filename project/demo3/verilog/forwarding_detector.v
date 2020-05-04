module forwarding_detector (instr_reg, Reg_wrt_reg_ID, target_reg_ID, Reg_wrt_reg_EX, target_reg_EX, Mem_read_ID, Rs_exe, Rs_mem, Rt_exe, Rt_mem, fwd_possible_ID, fwd_possible_EX);
input [15:0] instr_reg;
input Reg_wrt_reg_ID, Reg_wrt_reg_EX, Mem_read_ID, fwd_possible_ID, fwd_possible_EX;
// input [1:0] Alu_src_reg;
input [2:0] target_reg_ID, target_reg_EX; 
// input [4:0] Alu_op_reg; 
output Rs_exe, Rs_mem, Rt_exe, Rt_mem;

wire Rt_valid; // Rt is used
assign Rt_valid = ((instr_reg[15:14] == 2'b11) & (instr_reg[15:11] != 5'b11001) & (instr_reg[15:11] != 5'b11000)) | ((instr_reg[15:11] == 5'b10000) | (instr_reg[15:11] == 5'b10011));
wire rs_nox;
assign rs_nox = (instr_reg[15:11] != 5'b00000) & (instr_reg[15:11] != 5'b00001); // & (instr_reg[15:11] != 5'b00100) & (instr_reg[15:11] != 5'b00110)
wire rt_nox;
assign rt_nox = rs_nox & instr_reg[15:11] != 5'b11001; 

wire IDEX_wrt;
wire IDEX_Rs;
wire IDEX_Rt;
assign IDEX_wrt = (Reg_wrt_reg_ID == 1'b1) & (instr_reg[15:11] != 5'b11000); // last instruction will write to register
assign IDEX_Rs = (instr_reg[10:8] == target_reg_ID); // Rs RAW
assign IDEX_Rt = (instr_reg[7:5] == target_reg_ID) & (Rt_valid); // Rt RAW
assign Rs_exe = (rs_nox & fwd_possible_ID) ? (IDEX_wrt & IDEX_Rs & (~Mem_read_ID)) : 1'b0;
assign Rt_exe = (rt_nox & fwd_possible_ID) ? (IDEX_wrt & IDEX_Rt & (~Mem_read_ID)) : 1'b0;

wire EXM_wrt;
wire EXM_Rs;
wire EXM_Rt;
assign EXM_wrt = (Reg_wrt_reg_EX == 1'b1) & (instr_reg[15:11] != 5'b11000);
assign EXM_Rs = (instr_reg[10:8] == target_reg_EX);
assign EXM_Rt = (instr_reg[7:5] == target_reg_EX) & (Rt_valid);
assign Rs_mem = (rs_nox & fwd_possible_EX) ? (EXM_wrt & EXM_Rs) : 1'b0;
assign Rt_mem = (rt_nox & fwd_possible_EX) ? (EXM_wrt & EXM_Rt) : 1'b0;


endmodule
