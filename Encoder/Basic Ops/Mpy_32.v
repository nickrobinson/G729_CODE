`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    18:20:14 10/18/2010  
// Module Name:    Mpy_32 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is the mpy32 function replication the C-model function "mpy32". 
//						 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Mpy_32(clock, reset, start, done, var1, var2, out, L_mult_outa, L_mult_outb,
					L_mult_overflow, L_mult_in, L_mac_outa, L_mac_outb, L_mac_outc, 
					L_mac_overflow, L_mac_in, mult_outa, mult_outb, mult_in, mult_overflow);
					
   input clock, reset, start;
	input L_mult_overflow, L_mac_overflow, mult_overflow;
	input [15:0] mult_in;
	input [31:0] var1, var2, L_mult_in, L_mac_in;	
   output reg [15:0] L_mult_outa, L_mult_outb, L_mac_outa, L_mac_outb, mult_outa, mult_outb;
   output reg [31:0] L_mac_outc, out;
	output reg done;
	
	wire [15:0] high1, high2, low1,low2;
	
	assign high1 = var1[31:16];
	assign high2 = var2[31:16];
	assign low1 = var1[15:0];
	assign low2 = var2[15:0];
	
	parameter init = 4'd0;
	parameter state1 = 4'd1;
	parameter state2 = 4'd2;
	parameter state3 = 4'd3;
	parameter state4 = 4'd4;
	
	reg [3:0] currentstate, nextstate;
	reg [31:0] product,nextproduct;	
	always@(posedge clock) begin
		if(reset)
			currentstate <= init;
		else
			currentstate <= nextstate;
	end
	
	always@(posedge clock) begin
		if(reset)
			product <= 0;
		else
			product <= nextproduct;
	end
	
	always@(*) begin
		done = 0;
		nextstate = currentstate;
		nextproduct = product;
		
		L_mult_outa = 0;
		L_mult_outb = 0;
		
		mult_outa = 0;
		mult_outb = 0;
		
		L_mac_outa = 0;
		L_mac_outb = 0;
		L_mac_outc = 0;
		
		out = 0;
		
		case(currentstate)
		
			init: begin
				if(start==1)
					nextstate = state1;
				else begin
					nextstate = init;
				end
			end
			
			state1: begin
				L_mult_outa = high1;
				L_mult_outb = high2;
				nextproduct = L_mult_in;
				nextstate = state2;
			end
			
			state2: begin
				mult_outa = high1;
				mult_outb = low2;
				L_mac_outa = mult_in;
				L_mac_outb = 16'd1;
				L_mac_outc = product;				
				nextproduct = L_mac_in;
				nextstate = state3;
			end
			
			state3: begin
				mult_outa = low1;
				mult_outb = high2;
				L_mac_outa = mult_in;
				L_mac_outb = 16'd1;
				L_mac_outc = product;
				nextproduct = L_mac_in;
				nextstate = state4;
			end
			
			state4: begin
				out = product;
				done = 1;
				nextstate = init;
			end
		endcase
	end
endmodule
