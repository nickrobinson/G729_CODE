`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    13:25:06 11/07/2010  
// Module Name:    mpy_32_mux 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is a 32bit, 10 to 1 multiplexor.
//						 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mpy_32_mux(in1, in2, in3, in4, in5, in6, in7, in8, in9,in10, sel, out);
    input [31:0] in1;
    input [31:0] in2;
    input [31:0] in3;
    input [31:0] in4;
    input [31:0] in5;
    input [31:0] in6;
    input [31:0] in7;
    input [31:0] in8;
    input [31:0] in9;
	 input [31:0] in10;
    input [3:0] sel;
    output reg [31:0] out;

	always@(*) begin
	
		case(sel)
			4'd1: out = in1;
			4'd2: out = in2;
			4'd3: out = in3;
			4'd4: out = in4;
			4'd5: out = in5;
			4'd6: out = in6;
			4'd7: out = in7;
			4'd8: out = in8;
			4'd9: out = in9;
			4'd10: out = in10;
			default: out = 32'd0;
		endcase
	end

endmodule
