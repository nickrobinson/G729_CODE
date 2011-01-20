`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:     
// Module Name:    
// Project Name: 	 g729_hpfilter
// Target Devices: 
// Tool versions: 
// Description: 	 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    17:52:14 08/25/2010 
// Module Name:    fiveway_constantmux 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This module implements a multiplexor with five 16bit inputs.
//						 In the hpfilter, these are constants. 

// Dependencies: 	 N/A

//
//////////////////////////////////////////////////////////////////////////////////
module fiveway_constantmux(in0,in1,in2,in3,in4,sel,out);

input [2:0]  sel;
input [15:0] in0,in1,in2,in3,in4;
output[15:0] out;
reg [15:0] out;

always @(*)
case	(sel)
	'd0 :	out = in0;
	'd1 :	out = in1;
	'd2 :	out = in2;
	'd3 :	out = in3;
	default	out = in4;
endcase


endmodule
