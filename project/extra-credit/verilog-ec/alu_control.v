module alu_control (
	// Inputs from Decode
	Alu_op, Op_ext, 
	// Outputs to Execute
	InvA, InvB, Cin, sign, op, err
	);
input [4:0] Alu_op; 
input [1:0] Op_ext; 
output InvA, InvB, Cin, sign, err;
output [2:0] op; 

// termination
`define HALTA 7'b00000xx
`define NOPA 7'b00001xx

//I type
`define ADDIA 7'b01000xx
`define SUBIA 7'b01001xx
`define XORIA 7'b01010xx
`define ANDNIA 7'b01011xx
`define ROLIA 7'b10100xx
`define SLLIA 7'b10101xx
`define RORIA 7'b10110xx
`define SRLIA 7'b10111xx

//Mem
`define STA 7'b10000xx
`define LDA 7'b10001xx
`define STUA 7'b10011xx

//Strange one
`define BTRA 7'b11001xx

//R type
`define ADDA 7'b1101100
`define SUBA 7'b1101101
`define XORA 7'b1101110
`define ANDNA 7'b1101111
`define ROLA 7'b1101000
`define SLLA 7'b1101001
`define RORA 7'b1101010
`define SRLA 7'b1101011
`define SEQA 7'b11100xx
`define SLTA 7'b11101xx
`define SLEA 7'b11110xx
`define SCOA 7'b11111xx

//Branch
`define BEQZA 7'b01100xx
`define BNEZA 7'b01101xx
`define BLTZA 7'b01110xx
`define BGEZA 7'b01111xx

//Strange ones
`define LBIA 7'b11000xx
`define SLBIA 7'b10010xx

//J type
`define JA 7'b00100xx
`define JRA 7'b00101xx
`define JALA 7'b00110xx
`define JALRA 7'b00111xx

//For geniuses
`define SIICA 7'b00010xx
`define RTIA 7'b00011xx

reg [6:0] temp_op;
reg err_temp; 
always @*
casex ({Alu_op, Op_ext})
    default: err_temp = 1;
	`ADDIA: temp_op = 7'b0001100;
	`SUBIA: temp_op = 7'b1011100;
	`XORIA: temp_op = 7'b0000111; 
	`ANDNIA: temp_op = 7'b0100101;
	`ROLIA: temp_op = 7'b0000000;
	`SLLIA: temp_op = 7'b0000001;
	`RORIA: temp_op = 7'b0000010;
	`SRLIA: temp_op = 7'b0000011; 
	`STA: temp_op = 7'b0001100; 
	`LDA: temp_op = 7'b0001100; 
	`STUA: temp_op = 7'b0001100;
	`BTRA: temp_op = 7'b0000xxx;
	`ADDA: temp_op = 7'b0001100;
	`SUBA: temp_op = 7'b1011100;
	`XORA: temp_op = 7'b0000111;
	`ANDNA: temp_op = 7'b0100101; 
	`ROLA: temp_op = 7'b0000000;
	`SLLA: temp_op = 7'b0000001;
	`RORA: temp_op = 7'b0000010;
	`SRLA: temp_op = 7'b0000011;
	`SEQA: temp_op = 7'b0111100; 
	`SLTA: temp_op = 7'b0111100;
	`SLEA: temp_op = 7'b0111100;
	`SCOA: temp_op = 7'b0001100;
	`BEQZA: temp_op = 7'b0001100;
	`BNEZA: temp_op = 7'b0001100;
	`BLTZA: temp_op = 7'b0001100;
	`BGEZA: temp_op = 7'b0001100;
	`LBIA: temp_op = 7'bxxxxxxx; 
	`SLBIA: temp_op = 7'b0000001; 
	`JA: temp_op = 7'bxxxxxxx;
	`JRA: temp_op = 7'b0001100;
	`JALA: temp_op = 7'bxxxxxxx; 
	`JALRA: temp_op = 7'b0001100;
	`NOPA: temp_op = 7'bxxxxxxx;
	`HALTA: temp_op = 7'bxxxxxxx;
endcase

   assign InvA = temp_op[6];
   assign InvB = temp_op[5];
   assign Cin = temp_op[4];
   assign sign = temp_op[3];
   assign op = temp_op[2:0];

  assign err = (err_temp == 1);

endmodule

 
