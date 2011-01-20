`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:     17:31:28 11/11/2010 
// Module Name:    Scratch_Memory_Controller 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is a wrapper file to instantiate the scratch memory. 
// 
// Dependencies: 	 scratch_memory_V1.xco
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Scratch_Memory_Controller(addra,dina,wea,clk,addrb,doutb);

input [10:0] addra;
input [31:0] dina;
input wea;
input clk;
input [10:0] addrb;
output [31:0] doutb;

scratch_memory_V1 Az_scratch_mem(
						.clka(clk),
						.dina(dina),
						.addra(addra),
						.wea(wea),
						.clkb(clk),
						.addrb(addrb),
						.doutb(doutb)
						);

endmodule
