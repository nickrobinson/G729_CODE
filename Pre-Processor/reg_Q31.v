`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    17:39:30 08/25/2010  
// Module Name:    reg_Q31
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This module implements a hardware register for storing Q31 numbers.

// Dependencies: 	 N/A

//
//////////////////////////////////////////////////////////////////////////////////
module reg_Q31(mclk,reset,ld,d,q);
input mclk,reset,ld;
input [31:0] d;
output [31:0] q;
reg [31:0] q;

always @(posedge mclk or posedge reset)
	begin
	if(reset)
		q <= 0;
	else if (ld)
		q <= d;
	end



endmodule
