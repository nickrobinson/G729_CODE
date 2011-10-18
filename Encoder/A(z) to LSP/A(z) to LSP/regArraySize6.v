`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    11:46:19 10/23/2010 
// Module Name:    regArraySize6 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function to instantiate 6 16bit registers. The output will be the value
//						in the register specified by the select line.
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module regArraySize6(clk,reset,q,d1,d2,d3,d4,d5,d6,ld,sel);

//Inputs
input clk,reset,ld;
input [3:0] sel;
input [15:0] q;

//Output
output reg [15:0] d1,d2,d3,d4,d5,d6;

always @(posedge clk)
begin
	if(reset)
		d1 <= 0;
	else if(ld && (sel == 0))
		d1 <=q;
end

always @(posedge clk)
begin
	if(reset)
		d2 <= 0;
	else if(ld && (sel == 1))
		d2 <=q;
end

always @(posedge clk)
begin
	if(reset)
		d3 <= 0;
	else if(ld && (sel == 2))
		d3 <=q;
end

always @(posedge clk)
begin
	if(reset)
		d4 <= 0;
	else if(ld && (sel == 3))
		d4 <=q;
end

always @(posedge clk)
begin
	if(reset)
		d5 <= 0;
	else if(ld && (sel == 4))
		d5 <=q;
end

always @(posedge clk)
begin
	if(reset)
		d6 <= 0;
	else if(ld && (sel == 5))
		d6 <=q;
end

endmodule
