//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    03:35:50 09/15/2010
// Module Name:    L_mac.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function to call both the L_add adder and the L_mult multiplier at once to 
// 					replicate the functionality of the L_mac function
// Dependencies: 	 L_mult.v, L_add.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module L_mac(a,b,c,overflow,out);

input [15:0] a,b;
input [31:0] c;
output [31:0] out;
output reg overflow;

wire overflow1,overflow2;
wire signed [15:0] a,b;
wire signed [31:0] c,multOut,out;

L_mult mult(.a(a), .b(b), .overflow(overflow1), .product(multOut));
L_add add(.a(c), .b(multOut),.overflow(overflow2), .sum(out));



always @(*) begin 
	overflow = 0;
	if((overflow1 == 1) || (overflow2 == 1))
		overflow = 1;
	else if ((overflow1 == 0) && (overflow2 == 0))
		overflow = 0;
end

endmodule
