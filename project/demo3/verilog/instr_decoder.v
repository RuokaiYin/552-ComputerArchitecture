module instr_decoder(
// Input
instr, halt_back,
//Output
Halt,WB_sel,Branch_sel,Alu_src,Alu_result,Alu_op,Mem_read,Mem_wrt,I_sel,J_sel,
Sign_sel,WB_tar,Reg_wrt, Branch, Jmp_sel, Jmp, err, fwd, siic, rti);

input halt_back;
input [4:0] instr;

output Halt,Mem_read,Mem_wrt,I_sel,J_sel,
       Sign_sel,Reg_wrt, Branch, Jmp_sel, Jmp, err, fwd, siic, rti;

output [1:0] WB_tar, Branch_sel, WB_sel, Alu_src;
output [2:0] Alu_result;
output [4:0] Alu_op;

// termination
`define HALT 5'b00000
`define NOP 5'b00001

//I type
`define ADDI 5'b01000
`define SUBI 5'b01001
`define XORI 5'b01010
`define ANDNI 5'b01011
`define ROLI 5'b10100
`define SLLI 5'b10101
`define RORI 5'b10110
`define SRLI 5'b10111

//Mem
`define ST 5'b10000
`define LD 5'b10001
`define STU 5'b10011

//Strange one
`define BTR 5'b11001

//R type
`define ADD 5'b11011
`define SUB 5'b11011
`define XOR 5'b11011
`define ANDN 5'b11011
`define ROL 5'b11010
`define SLL 5'b11010
`define ROR 5'b11010
`define SRL 5'b11010
`define SEQ 5'b11100
`define SLT 5'b11101
`define SLE 5'b11110
`define SCO 5'b11111

//Branch
`define BEQZ 5'b01100
`define BNEZ 5'b01101
`define BLTZ 5'b01110
`define BGEZ 5'b01111

//Strange ones
`define LBI 5'b11000
`define SLBI 5'b10010

//J type
`define J 5'b00100
`define JR 5'b00101
`define JAL 5'b00110
`define JALR 5'b00111

//For geniuses
`define SIIC 5'b00010
`define RTI 5'b00011

reg[26:0] op_temp;
reg err_temp;
always @*
  begin
    siic = 1'b0;
    rti = 1'b0;
    case(instr)
        default: err_temp = 1;
        `HALT: op_temp = 27'b00_x_x_x_xx_xx_0_0_xx_0_0_xx_xxx_00000_1_0; 
        `NOP: op_temp = 27'b00_x_x_x_xx_xx_0_0_xx_0_0_xx_xxx_00001_0_0;
        // I-1 type
        `ADDI: op_temp = 27'b10_0_0_1_01_01_0_0_xx_0_1_01_000_01000_0_0;
        `SUBI: op_temp = 27'b10_0_0_1_01_01_0_0_xx_0_1_01_000_01001_0_0;
        `XORI: op_temp = 27'b10_0_x_0_01_01_0_0_xx_0_1_01_000_01010_0_0;
        `ANDNI: op_temp = 27'b10_0_x_0_01_01_0_0_xx_0_1_01_000_01011_0_0;
        `ROLI: op_temp = 27'b10_0_x_0_01_01_0_0_xx_0_1_01_000_10100_0_0;
        `SLLI: op_temp = 27'b10_0_x_0_01_01_0_0_xx_0_1_01_000_10101_0_0;
        `RORI: op_temp = 27'b10_0_x_0_01_01_0_0_xx_0_1_01_000_10110_0_0;
        `SRLI: op_temp = 27'b10_0_x_0_01_01_0_0_xx_0_1_01_000_10111_0_0;
        // MEM
        `ST: op_temp = 27'b00_0_0_1_xx_xx_0_0_xx_1_0_01_000_10000_0_0;
        `LD: op_temp = 27'b11_0_0_1_01_00_0_0_xx_0_1_01_000_10001_0_0;
        `STU: op_temp = 27'b10_0_0_1_00_01_0_0_xx_1_1_01_000_10011_0_0;
        // R type
        `BTR: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_xx_101_11001_0_0;
        `ADD: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_000_11011_0_0;
        `SUB: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_000_11011_0_0;
        `XOR: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_000_11011_0_0;
        `ANDN: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_000_11011_0_0;
        `ROL: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_000_11010_0_0;
        `SLL: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_000_11010_0_0;
        `ROR: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_000_11010_0_0;
        `SRL: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_000_11010_0_0;
        `SEQ: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_010_11100_0_0;
        `SLT: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_011_11101_0_0;
        `SLE: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_100_11110_0_0;
        `SCO: op_temp = 27'b10_x_x_x_10_01_0_0_xx_0_1_00_001_11111_0_0;
        // I-2 type
        `BEQZ: op_temp = 27'b00_1_0_1_xx_xx_1_0_00_0_0_10_xxx_01100_0_0;
        `BNEZ: op_temp = 27'b00_1_0_1_xx_xx_1_0_01_0_0_10_xxx_01101_0_0;
        `BLTZ: op_temp = 27'b00_1_0_1_xx_xx_1_0_10_0_0_10_xxx_01110_0_0;
        `BGEZ: op_temp = 27'b00_1_0_1_xx_xx_1_0_11_0_0_10_xxx_01111_0_0;
        `LBI: op_temp = 27'b10_1_0_1_00_10_0_0_xx_0_1_xx_xxx_11000_0_0;
        `SLBI: op_temp = 27'b10_1_x_0_00_01_0_0_xx_0_1_11_110_10010_0_0;
        // J type
        `J: op_temp = 27'b00_x_1_1_xx_xx_0_0_xx_0_0_xx_xxx_00100_0_1;
        `JR: op_temp = 27'b00_1_0_1_xx_xx_0_1_xx_0_0_01_xxx_00101_0_0;
        `JAL: op_temp = 27'b10_x_1_1_11_11_0_0_xx_0_1_xx_xxx_00110_0_1;
        `JALR: op_temp = 27'b10_1_0_1_11_11_0_1_xx_0_1_01_xxx_00111_0_0;
        `SIIC: 
        begin 
        op_temp = 27'b00_x_x_x_xx_xx_0_0_xx_0_0_xx_xxx_00010_0_0;
        siic = 1'b1;
        end
        `RTI:
        begin 
        op_temp = 27'b00_x_x_x_xx_xx_0_0_xx_0_0_xx_xxx_00011_0_0;
        rti = 1'b1;
        end
      end
    endcase

assign Mem_read = op_temp[25];
assign I_sel = op_temp[24];
assign J_sel = op_temp[23];
assign Sign_sel = op_temp[22];
assign WB_tar = op_temp[21:20];
assign WB_sel = op_temp[19:18];
assign Branch = op_temp[17];
assign Jmp_sel = op_temp[16];
assign Branch_sel = op_temp[15:14];
assign Mem_wrt = op_temp[13];
assign Reg_wrt = op_temp[12];
assign Alu_src = op_temp[11:10];
assign Alu_result = op_temp[9:7];
assign Alu_op = op_temp[6:2];
assign Halt = halt_back ? 1'b1 : op_temp[1];
assign Jmp = op_temp[0];
assign fwd = op_temp[26]; // if it is possible to forward to later instruction

assign err = (err_temp == 1);

endmodule
