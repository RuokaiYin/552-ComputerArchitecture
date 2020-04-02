/*
   CS/ECE 552, Spring '20
   Homework #3, Problem #1
  
   This module creates a 16-bit register
*/
module reg_16_instr (
                // Outputs
                readData, err,
                // Inputs
                clk, rst, writeData, writeEn
                );
   
   parameter SIZE = 16;
   
   input         clk, rst, writeEn;
   input[SIZE-1:0]  writeData;

   output         err;
   output [SIZE-1:0] readData;

   /* YOUR CODE HERE */
   wire[SIZE-1:0] in;
   wire [SIZE-1:0] readData_temp;
   assign in = (writeEn) ? writeData : readData;

   dff ff[SIZE-1:0](.q(readData_temp) ,.d(in), .clk(clk), .rst(rst));
   assign readData = rst ? 16'b00001_xxxxxxxxxxx : readData_temp;   
   
   // err_checker checker(.err(err),.writeData(writeData), .writeEn(writeEn));   
   wire err_temp;
   assign err_temp = ^{writeEn, writeData};
   assign err = (err_temp === 1'bx);

endmodule