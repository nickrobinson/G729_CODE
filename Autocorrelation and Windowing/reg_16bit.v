`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:41:09 09/15/2010 
// Design Name: 
// Module Name:    reg_16bit 
// Project Name: 
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
module reg_16bit(mclk,reset,ld,d,q);
input mclk,reset,ld;
input [15:0] d;
output [15:0] q;
reg [15:0] q;

always @(posedge mclk or posedge reset)
	begin
	if(reset)
		q <= 0;
	else if (ld)
		q <= d;
	end
endmodule
