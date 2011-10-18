`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design 
// Engineer: Sean Owens
// 
// Create Date:    16:21:23 09/20/2010 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Vertex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Controller for the memory interface inside the Auto-Correlation
//						 block.  This controller is used to create a buffer between the hamming
//						 multiplication and the normalization computations.
//
// Dependencies: 	 auto_corr_mem_2
//
// Revision: 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LPC_Mem_Ctrl_2(clock, reset, In_Write, In_Count, In_Sample, Out_Count, Out_Sample);

input clock;
input reset;
input In_Write;
input [7:0] In_Count;
input [15:0] In_Sample;
input [7:0] Out_Count;
output [15:0] Out_Sample;

wire [15:0] douta;


AutoCorr_mem_2 i_AutoCorr_mem_2(.addra(In_Count),.dina(In_Sample),.wea(In_Write),.clka(clock),
		.douta(douta), .addrb(Out_Count), .dinb(16'd0), .web(1'd0), .clkb(clock), .doutb(Out_Sample));
	

endmodule
