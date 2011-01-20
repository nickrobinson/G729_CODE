`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    17:47:24 08/25/2010 
// Module Name:    fiveway_Q31mux.
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This module implements a multiplexor with five Q31 inputs 

// Dependencies: 	 N/A

//
//////////////////////////////////////////////////////////////////////////////////
module fiveway_Q31mux(in0,in1,in2,in3,in4,sel,out);

input [2:0] sel;
input [31:0] in0,in1,in2,in3,in4;
output [31:0] out;
reg [31:0] out;

always @(*)
case	(sel)
	'd0 :	out = in0;
	'd1 :	out = in1;
	'd2 :	out = in2;
	'd3 :	out = in3;
	default	out = in4;
endcase

endmodule
