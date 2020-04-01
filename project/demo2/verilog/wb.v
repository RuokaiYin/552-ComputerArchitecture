/*
   CS/ECE 552 Spring '20
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb (
           // IN from Fetch
           PC_Next,
           // IN from Decode
           extend, WB_sel,
           // IN from Mem
           data_mem, data_exe,
           // Out to Decode
           WB);

   input [1:0] WB_sel;
   input [15:0] PC_Next, extend, data_mem, data_exe;
   
   output [15:0] WB;
   
   assign WB = (WB_sel[1]) ? ((WB_sel[0]) ? (PC_Next) : (extend)) : ((WB_sel[0]) ? (data_exe) : (data_mem));

   
endmodule
