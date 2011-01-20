`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:46:29 10/28/2010 
// Module Name:    add 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function to add two 16bit numbers and check for overflow.
// 					It is modeled after the add function in the C code
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module add(a,b,overflow,sum);

//Inputs
input [15:0] a,b;

//Outputs 
output reg [15:0] sum;
output reg overflow;

//wires
wire signed [15:0] a,b;
wire signed [31:0] temp;

assign temp = a + b; 
always @(*)
begin
	if((temp [31] == 0) && (temp > 32'h00007fff))
	begin
		overflow = 1;
		sum = 16'h7fff;
	end
	
	else if((temp[31] == 1)&&(temp < 32'hffff8000))
	begin
		overflow = 1;
		sum = 16'h8000;
	end
	
	else
	begin
		overflow = 0;
		sum = temp[15:0];
	end
end//always block
endmodule
