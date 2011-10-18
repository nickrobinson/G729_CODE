`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    18:07:47 10/07/2010  
// Module Name:    L_abs  
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function to return the absolute value of var_in
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module L_abs(var_in, var_out);
    input signed [31:0] var_in;
    output reg signed [31:0] var_out;

	parameter [31:0] MAX_32 = 32'h7fff_ffff;
	parameter [31:0] MIN_32 = 32'h8000_0000;
	
	always@(*) begin
		if(var_in == MIN_32) begin
			var_out = MAX_32;
		end
		else begin
			if(var_in[31] == 1) begin
				var_out = ~var_in + 1;
			end
			else begin
				var_out = var_in;
			end
		end
	end
endmodule
