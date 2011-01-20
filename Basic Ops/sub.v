`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:     17:41:20 11/08/2010 
// Module Name:    sub
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function to subtract 16bit a from b and check for overflow.
// 					It is modeled after the add function in the C code
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module sub(a,b,overflow,diff);

//Inputs
input [15:0] a,b;

//Outputs 
output reg [15:0] diff;
output reg overflow;

//wires
wire signed [15:0] a,b,bneg;
wire signed [31:0] temp;

assign bneg = ~b + 1;
assign temp = a + bneg; 
always @(*)
begin
	if((temp [31] == 0) && (temp > 32'h00007fff))
	begin
		overflow = 1;
		diff = 16'h7fff;
	end
	
	else if((temp[31] == 1)&&(temp < 32'hffff8000))
	begin
		overflow = 1;
		diff = 16'h8000;
	end
	
	else
	begin
		overflow = 0;
		diff = temp[15:0];
	end
end//always block
endmodule