/*
   CS/ECE 552, Spring '20
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile (
                // Outputs
                read1Data, read2Data, err,
                // Inputs
                clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                );

   parameter N =16;

   input        clk, rst;
   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;

   output [15:0] read1Data;
   output [15:0] read2Data;
   output        err;
   
   
   /* YOUR CODE HERE */
   wire[N-1:0] read_1, read_2, read_3, read_4, read_5, read_6, read_7, read_8;
   wire[7:0] err_temp;
   wire[7:0] en_temp, en_temp_temp;
   reg_16 #(.SIZE(N)) regs[7:0](.readData({read_8,read_7,read_6,read_5,read_4,read_3,read_2,read_1}), .err(err_temp),.clk(clk), .rst(rst), .writeData(writeData), .writeEn(en_temp));

   assign read1Data = (read1RegSel[2]) ? ((read1RegSel[1]) ? ((read1RegSel[0]) ? (read_8) : (read_7)) : ((read1RegSel[0]) ? (read_6) : (read_5))) : ((read1RegSel[1]) ? ((read1RegSel[0]) ? (read_4) : (read_3)) : ((read1RegSel[0]) ? (read_2) : (read_1)));
   assign read2Data = (read2RegSel[2]) ? ((read2RegSel[1]) ? ((read2RegSel[0]) ? (read_8) : (read_7)) : ((read2RegSel[0]) ? (read_6) : (read_5))) : ((read2RegSel[1]) ? ((read2RegSel[0]) ? (read_4) : (read_3)) : ((read2RegSel[0]) ? (read_2) : (read_1)));
   
   assign en_temp_temp = (writeRegSel[2]) ? ((writeRegSel[1]) ? ((writeRegSel[0]) ? (8'b1000_0000) : (8'b0100_0000)) : ((writeRegSel[0]) ? (8'b0010_0000) : (8'b0001_0000))) : ((writeRegSel[1]) ? ((writeRegSel[0]) ? (8'b0000_1000) : (8'b0000_0100)) : ((writeRegSel[0]) ? (8'b0000_0010) : (8'b0000_0001)));
   assign en_temp = en_temp_temp & {8{writeEn}};   
   
   assign err = 1'b0;

endmodule
