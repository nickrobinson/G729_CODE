`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:10:31 04/12/2011 
// Design Name: 
// Module Name:    Parity_pitch 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Parity_pitch(clk, start, reset, done, pitch_index, sum, add_a, add_b, add_in, shr_a, shr_b, shr_in);

	input clk, start, reset;
	input [15:0] pitch_index;

	output reg done;
	output reg [15:0] sum;

	input [15:0] add_in;
	input [15:0] shr_in;
	output reg [15:0] add_a, add_b;
	output reg [15:0] shr_a, shr_b;
	
	parameter INIT = 0;
	parameter S1 = 1;
	parameter S2 = 2;
	parameter S3 = 3;
	parameter S4 = 4;
	parameter S5 = 5;
	
	reg [3:0] state, nextstate;
	reg [15:0] i, nexti;
	reg [15:0] temp, next_temp;
	reg [15:0] bit1, next_bit1;
	reg [15:0] next_sum;
	reg next_done;

	always @(posedge clk)
		begin
			if(reset)
				i <= 0;
			else
				i <= nexti;
		end

	always @(posedge clk)
		begin
			if (reset)
				 state <= INIT;
			else
				 state <= nextstate;
		 end
		 
	always @(posedge clk)
		begin
			if(reset)
				temp <= 0;
			else
				temp <= next_temp;
		end

	always @(posedge clk)
		begin
			if(reset)
				bit1 <= 0;
			else
				bit1 <= next_bit1;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				sum <= 0;
			else
				sum <= next_sum;
		end
					
	always @(posedge clk)
		begin
			if(reset)
				done <= 0;
			else
				done <= next_done;
		end
		
	always@(*)
		begin
			nextstate = state;
			nexti = i;
			next_temp = temp;
			next_bit1 = bit1;
			next_done = done;
			next_sum = sum;
			add_a = 0;
			add_b = 0;
			shr_a = 0;
			shr_b = 0;
			
			case(state)
				INIT:
					begin
						if(start)
							nextstate = S1;
					end
					
				S1:
					begin
						shr_a = pitch_index;
						shr_b = 'd1;
						next_temp = shr_in;							//temp = shr(pitch_index, 1);
						next_sum = 'd1;								//sum = 1;
						nexti = 'd0;
						nextstate = S2;
					end
					
				S2:	//start of i loop
					begin
						if(i == 6)
							begin
								nexti = 'd0;
								nextstate = S4;
							end
						else
							begin
								shr_a = temp;
								shr_b = 'd1;
								next_temp = shr_in;							//temp = shr(temp, 1);
								next_bit1 = (shr_in & 16'd1);				//bit = temp & 1;
								add_a = sum;
								add_b = (shr_in & 16'd1);					
								next_sum = add_in;							//sum = add(sum, bit);
								nextstate = S3;
							end
					end
				
				S3:
					begin
						add_a = i;
						add_b = 'd1;
						nexti = add_in;
						nextstate = S2;
					end
				
				S4:
					begin
						next_sum = sum & 16'd1;
						next_done = 1;
						nextstate = S5;
					end
					
				S5:
					begin
						next_done = 0;
						nextstate = INIT;
					end	
				endcase
				
			
			
		end
endmodule
