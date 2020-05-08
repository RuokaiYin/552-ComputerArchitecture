/*
   CS/ECE 552, Spring '20
   Homework #3, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module regFile_bypass (
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
   wire[15:0] regi1_temp, regi2_temp;
   regFile #(.N(N))regi(.read1Data(regi1_temp),.read2Data(regi2_temp),.err(err),.clk(clk),.rst(rst),.read1RegSel(read1RegSel),.read2RegSel(read2RegSel),.writeRegSel(writeRegSel),.writeData(writeData),.writeEn(writeEn));
  
   // signal to check whether a bypass should happen
   wire reg1_byp, reg2_byp;
   assign reg1_byp = ~(|(read1RegSel ^ writeRegSel));
   assign reg2_byp = ~(|(read2RegSel ^ writeRegSel));
   
   // add two 4to1 mux to enable function of bypassing   
   assign read1Data = (writeEn & reg1_byp) ? (writeData) : (regi1_temp);
   assign read2Data = (writeEn & reg2_byp) ? (writeData) : (regi2_temp);
endmodule

