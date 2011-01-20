`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    16:24:35 09/15/2010 
// Module Name:    L_add 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function to add two numbers and  check for overflow.
// 					It is modeled after the L_add function in the C code
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module L_add(a,b,overflow,sum);

input [31:0] a,b;
output overflow;
output [31:0] sum;

wire signed [31:0] a,b;
reg overflow;
reg signed [31:0] sum;
reg signed [31:0] temp;

parameter MIN_32 = 32'h8000_0000;
parameter MAX_32 = 32'h7fff_ffff;

always @(*) begin

	overflow = 0;	
	temp = a+b;
	
    if ((temp[31] ==0) && (a[31] == 1) && (b[31] == 1)) // neg+neg=pos NOT ALLOWED
	 begin
      temp = 32'h8000_0000;
		overflow = 1;
	 end
    else if ((temp[31] == 1) && (a[31] == 0) && (b[31] == 0)) // pos+pos=neg NOT ALLOWED
	 begin
      temp = 32'h7fff_ffff;
		overflow = 1;
	 end
    
	 
	if((temp[31] == 0) && (temp > MAX_32))
	begin
		temp = MAX_32;
		overflow = 1;
	end

	else if((temp[31] == 1) && (temp < MIN_32))
	begin
		temp = MIN_32;
		overflow = 1;
	end

	sum = temp;
end //end always



endmodule
