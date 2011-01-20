//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    04:22:50 09/15/2010
// Module Name:    L_mult.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function to multiply two numbers, check for overflow, and shift them to the left.
// 					It is modeled after the L_mult function in the C code
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module L_mult(a,b,overflow,product);

input [15:0] a,b;
output reg overflow;
output [31:0] product;

reg signed [31:0] product;
wire signed [15:0] a,b;
wire signed[31:0] temp1,temp2;

parameter MIN_32 = 32'h8000_0000;
parameter MAX_32 = 32'h7fff_ffff;

assign temp1 = a*b;
assign temp2 = temp1*2;

always @(*)
begin
	overflow = 0;
	
	if((a == 0) || (b == 0))
		product = temp2;
	
	else if((a[15] == 0) && (b[15] == 0) && (temp2[31] == 1))
	begin
		product = 32'h7fff_ffff; //overflow pos*pos=neg NOT ALLOWED
		overflow = 1;
	end
	
	else if((a[15] == 1)  && (b[15] == 1) && (temp2[31] == 1))
	begin
		product = 32'h7fff_ffff; //overflow neg*neg=neg NOT ALLOWED
		overflow = 1;
	end
	
	else if((a[15] == 1) && (b[15] == 0) && (temp2[31] == 0))
   begin
		product = 32'h8000_0000; //overflow neg*pos=pos NOT ALLOWED
      overflow = 1;
	end
	
	else if((a[15] == 0) && (b[15] == 1) && (temp2[31] == 0)) 
	begin
		product = 32'h8000_0000; //overflow pos*neg=pos NOT ALLOWED
		overflow = 1;
	end
       
	else
		product = temp2;

	
	if((temp2[31] == 0) && (temp2 > MAX_32))
	begin
		product = MAX_32;
		overflow = 1;
	end

	else if((temp2[31] == 1) && (temp2<MIN_32))
	begin
		product = MIN_32;
		overflow = 1;
	end
		
end


endmodule
