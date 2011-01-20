`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    20:32:10 08/25/2010  
// Module Name:    twoway_Q31mux 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This module implements a multiplexor with two Q31 inputs

// Dependencies: 	 N/A

//
//////////////////////////////////////////////////////////////////////////////////
module twoway_Q31mux(in0,in1,sel,out);

input sel;
input [31:0] in0,in1;
output [31:0] out;
reg [31:0] out;

	always @(*)
	case(sel)
	'd0 :	out = in0;
	default :	out = in1;
	
	endcase	
	
endmodule
