//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    09:05:50 09/10/2010
// Module Name:    mult
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is a 16 bit input, 32 bit output multiplier .
//						 If the product exceeds the limit for 32 bit numbers, overflow will go high
// 					 and the output will be set to the 32bit limit
//
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mult(a, b,multRsel,overflow, product);

input [15:0] a, b;
input multRsel;
output reg overflow;
output [15:0] product;

wire signed [15:0] a,b;
reg signed [15:0] product;

parameter MIN_32 = 32'hffff_8000;
parameter MAX_32 = 32'h0000_7fff;
parameter MIN_16 = 16'h8000;
parameter MAX_16 = 16'h7fff;

wire signed [31:0] temp1,temp2,temp3,temp4;
reg signed [31:0] temp,temp5;

always @(*) 
begin
	overflow = 0;
	temp = a*b;
	if(multRsel)
		temp = temp + 32'h0000_4000;
	//I don't know where these magic numbers came from, except from the C model.
	temp = temp & 32'hffff_8000;	
	temp = temp >>> 15;

	if((temp & 32'h0001_0000)!=0)
		temp = temp | 32'hffff_0000;
		
		//what follows replicates the saturate function	
		
	if((temp[31] == 0 )&& (temp > MAX_32)) 
	begin
		product = MAX_16;
		overflow = 1;
	end

	else if((temp[31] == 1) && (temp < MIN_32)) 
	begin
		product = MIN_16;
		overflow = 1;
	end
	
	else
	begin
		product = temp[15:0];
		overflow = 0;
	end
	
end
endmodule
