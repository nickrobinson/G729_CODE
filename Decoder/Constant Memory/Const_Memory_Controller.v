`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:     17:31:28 2/20/2011 
// Module Name:    Constant_Memory_Controller 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is a wrapper file to instantiate the scratch memory. 
// 
// Dependencies: 	 CONSTANT_MEM.xco
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Const_Memory_Controller(addra,dina,wea,clock,douta);

input [11:0] addra;
input [31:0] dina;
output [31:0] douta;
input wea;
input clock;

CONSTANT_MEMORY Constant_Mem(
	.clka(clock),
	.wea(wea),
	.addra(addra),
	.dina(dina),
	.douta(douta));

endmodule