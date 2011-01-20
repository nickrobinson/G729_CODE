//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    04:01:50 09/15/2010
// Module Name:    twoway_16bit_mux.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This function is a mux with two 16 bit inputs and 1 16bit output
//
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module twoway_16bit_mux(in0,in1,sel,out);

input sel;
input [15:0] in0,in1;
output reg [15:0] out;

always @(*)
case	(sel)
	'd0 :	out = in0;
	default	out = in1;
endcase


endmodule


