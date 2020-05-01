module stall_detector (instr_reg, Reg_wrt_reg_ID, Mem_read_ID, target_reg_ID, Reg_wrt_reg_EX, target_reg_EX, STALL);
input [15:0] instr_reg;
input Reg_wrt_reg_ID, Reg_wrt_reg_EX, Mem_read_ID;
// input [1:0] Alu_src_reg;
input [2:0] target_reg_ID, target_reg_EX; 
// input [4:0] Alu_op_reg; 
output STALL;

wire Rt_valid; // Rt is used
assign Rt_valid = ((instr_reg[15:14] === 2'b11) & (instr_reg[15:11] !== 5'b11001) & (instr_reg[15:11] !== 5'b11000)) | ((instr_reg[15:11] === 5'b10000) | (instr_reg[15:11] == 5'b10011));

wire IDEX_wrt;
wire IDEX_Rs;
wire IDEX_Rt;
wire IDEX_stall;
assign IDEX_wrt = (Reg_wrt_reg_ID === 1'b1) & (instr_reg[15:11] !== 5'b11000); // last instruction will write to register
assign IDEX_Rs = (instr_reg[10:8] === target_reg_ID); // Rs RAW
assign IDEX_Rt = (instr_reg[7:5] === target_reg_ID) & (Rt_valid); // Rt RAW
assign IDEX_stall = IDEX_wrt & (IDEX_Rs | IDEX_Rt);

// wire EXM_wrt;
// wire EXM_Rs;
// wire EXM_Rt;
// wire EXM_stall;
// assign EXM_wrt = (Reg_wrt_reg_EX === 1'b1) & (instr_reg[15:11] !== 5'b11000);
// assign EXM_Rs = (instr_reg[10:8] === target_reg_EX);
// assign EXM_Rt = (instr_reg[7:5] === target_reg_EX) & (Rt_valid);
// assign EXM_stall = EXM_wrt & (EXM_Rs | EXM_Rt);

// assign STALL = 1'b0; // IDEX_stall | EXM_stall; 


// Two situations that a STALL cannot be avoided
// a stall is needed when it is dependent on previous load
// a stall is needed when a branch/jumpR is dependent on its previous instruction
wire isBranch, isJumpR; 
assign isBranch = (instr_reg[15:11] === 5'b01100) | (instr_reg[15:11] === 5'b01101) | (instr_reg[15:11] === 5'b01110) | (instr_reg[15:11] === 5'b01111);
assign isJumpR = (instr_reg[15:11] === 5'b00101) | (instr_reg[15:11] === 5'b00111);
assign STALL = (IDEX_stall & Mem_read_ID) | (IDEX_stall & isBranch) | (IDEX_stall & isJumpR);


endmodule