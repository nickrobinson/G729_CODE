`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:35:35 10/18/2010 
// Module Name:    sixway_16bitmux 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This module implements a multiplexor with six 16bit inputs.
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module sixway_16bitmux(in0,in1,in2,in3,in4,in5,sel,out);

input [2:0]  sel;
input [15:0] in0,in1,in2,in3,in4,in5;
output[15:0] out;
reg [15:0] out;

always @(*)
case	(sel)
	'd0 :	out = in0;
	'd1 :	out = in1;
	'd2 :	out = in2;
	'd3 :	out = in3;
	'd4 : 	out = in4;
	default	out = in5;
endcase


endmodule
