`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    23:26:34 10/18/2010  
// Module Name:    mpy_32_16 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is the mpy_32_16 function replication the C-model function "mpy32_16".
//						 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mpy_32_16(var1, var2, out, L_mult_outa, L_mult_outb,
					L_mult_overflow, L_mult_in, L_mac_outa, L_mac_outb, L_mac_outc, 
					L_mac_overflow, L_mac_in, mult_outa, mult_outb, mult_in, mult_overflow);
					
	 input L_mult_overflow, L_mac_overflow, mult_overflow;
	 input [31:0] var1, L_mult_in, L_mac_in;
	 input [15:0] mult_in;
	 input [15:0] var2;
	 output reg [15:0] L_mult_outa, L_mult_outb, L_mac_outa, L_mac_outb, mult_outa, mult_outb;
	 output reg [31:0] L_mac_outc, out;
	 
	 always@(*) begin
		L_mult_outa = var1[31:16];
		L_mult_outb = var2;
		mult_outa = var1[15:0];
		mult_outb = var2;
		L_mac_outa = mult_in;
		L_mac_outb = 16'd1;
		L_mac_outc = L_mult_in;
		out = L_mac_in;
	end

endmodule
