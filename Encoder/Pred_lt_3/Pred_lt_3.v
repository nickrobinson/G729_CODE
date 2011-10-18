`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:18:28 04/12/2011 
// Design Name: 
// Module Name:    Pred_lt_3 
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
module Pred_lt_3(clk, start, reset, done, exc, t0, frac, L_subfr, writeAddr, writeOut, writeEn, readAddr, readIn, 
						add_a, add_b, add_in, L_mac_a, L_mac_b, L_mac_c, L_mac_in, L_add_a, L_add_b, L_add_in, 
						L_negate_out, L_negate_in, sub_a, sub_b, sub_in, constantMemIn, constantMemAddr);

`include "paramList.v"
`include "constants_param_list.v"

	input clk, start, reset;
	input [15:0] t0, frac, L_subfr;
	input [11:0] exc;
	input [31:0] readIn;
	input [31:0] constantMemIn;
	
	output reg done;
	output reg [11:0] writeAddr;
	output reg [31:0] writeOut;
	output reg writeEn;
	output reg [11:0] readAddr;
	output reg [11:0] constantMemAddr;
	
	input [15:0] add_in, sub_in;
	input [31:0] L_mac_in, L_add_in;
	input [31:0] L_negate_in;
	output reg [15:0] add_a, add_b;
	output reg [15:0] sub_a, sub_b;
	output reg [15:0] L_mac_a, L_mac_b;
	output reg [31:0] L_mac_c;
	output reg [31:0] L_add_a, L_add_b;
	output reg [31:0] L_negate_out;
	
	parameter INIT = 0;
	parameter S1 = 1;
	parameter S2 = 2;
	parameter S3 = 3;
	parameter S4 = 4;
	parameter S5 = 5;
	parameter S6 = 6;
	parameter S7 = 7;
	parameter S8 = 8;
	parameter S9 = 9;
	parameter S10 = 10;
	parameter S11 = 11;
	
	
	reg [15:0] state, nextstate;
	reg [15:0] i, nexti;
	reg [15:0] j, nextj;
	reg [15:0] k, nextk;
	reg [15:0] x0, next_x0;
	reg [15:0] x1, next_x1;
	reg [15:0] x2, next_x2;
	reg [15:0] temp_x2, next_temp_x2;
	reg [15:0] c1, next_c1;
	reg [15:0] c2, next_c2;
	reg [31:0] s, next_s;
	reg [15:0] frac1, next_frac1;
	
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
				i <= 0;
			else
				i <= nexti;
		end

	always @(posedge clk)
		begin
			if(reset)
				j <= 0;
			else
				j <= nextj;
		end

	always @(posedge clk)
		begin
			if (reset)
				 k <= 0;
			else
				 k <= nextk;
		 end
		 
	always @(posedge clk)
		begin
			if (reset)
				 x0 <= 0;
			else
				 x0 <= next_x0;
		 end

	always @(posedge clk)
		begin
			if (reset)
				 x1 <= 0;
			else
				 x1 <= next_x1;
		 end
	
	always @(posedge clk)
		begin
			if (reset)
				 x2 <= 0;
			else
				 x2 <= next_x2;
		 end
		 
	always @(posedge clk)
		begin
			if (reset)
				 c1 <= 0;
			else
				 c1 <= next_c1;
		 end

	always @(posedge clk)
		begin
			if (reset)
				 c2 <= 0;
			else
				 c2 <= next_c2;
		 end
		 
	always @(posedge clk)
		begin
			if (reset)
				 s <= 0;
			else
				 s <= next_s;
		 end
		 
	always @(posedge clk)
		begin
			if (reset)
				 frac1 <= 0;
			else
				 frac1 <= next_frac1;
		 end
		 
	always @(posedge clk)
		begin
			if (reset)
				 temp_x2 <= 0;
			else
				 temp_x2 <= next_temp_x2;
		 end
		 
	always@(*)
		begin
			done = 0;
			nextstate = state;
			nexti = i;
			nextj = j;
			nextk = k;
			next_x0 = x0;
			next_x1 = x1;
			next_x2 = x2;
			next_c1 = c1;
			next_c2 = c2;
			next_s = s;
			next_frac1 = frac1;
			next_temp_x2 = temp_x2;
			add_a = 0;
			add_b = 0;
			sub_a = 0;
			sub_b = 0;
			L_mac_a = 0;
			L_mac_b = 0;
			L_mac_c = 0;
			L_add_a = 0;
			L_add_b = 0;
			L_negate_out = 0;
			writeEn = 0;
			writeAddr = 0;
			readAddr = 0;
			constantMemAddr = 0;
		
			case(state)
				INIT:
					begin
						if(start)
							begin
								nextstate = S1;
							end
					end
				
				S1:
					begin
						sub_a = exc;
						sub_b = t0;
						next_x0 = sub_in;												//x0 = &exc[-t0];
						L_negate_out = {'d0, frac}; 
						next_frac1 = L_negate_in;									//frac = negate(frac);
						nextstate = S2;
					end
					
				S2:
					begin
						if(frac1[15] == 1)												//if(frac < 0)
							begin
								add_a = frac1;
								add_b = 'd3;
								next_frac1 = add_in;									//frac = add(frac, 3);
								sub_a = x0;
								sub_b = 'd1;
								next_x0 = sub_in;										//x0--
								nextstate = S3;
								
							end
						else
							nextstate = S3;
					end
					
				S3:		//start of j loop
					begin
						if(j < L_subfr)											//for(j=0; j<L_subfr; j++)
							begin
								add_a = x0;
								add_b = 'd1;
								next_x1 = x0;										//x1 = x0++;
								next_x2 = add_in;										//x2 = x0;
								next_x0 = add_in;
								nextstate = S4;
							end
						else
							begin
								nextj = 0;
								done = 1;
								nextstate = INIT; //out of j loop
							end
					end
					
				S4:
					begin
						next_c1 = {INTER_3L[11:5], frac1[4:0]};				//c1 = &inter_3l[frac];
						nextstate = S5;
					end
				
				S5:
					begin											
						sub_a = 'd3;	
						sub_b = frac1;					
						next_c2 = {INTER_3L[11:5], sub_in[4:0]};
						next_s = 0;														//s = 0;
						nextstate = S6;
					end
				
				S6:		//start of i loop
					begin
						if(i < 'd10)												//for(i=0, k=0; i<10; i++, k+=3)
							begin
								sub_a = x1;
								sub_b = i;
								readAddr = sub_in[11:0];
								add_a = c1;
								add_b = k;
								constantMemAddr = add_in[11:0];								
								nextstate = S7;
							end
						else
							begin
								nexti = 0;
								nextk = 0;
								L_add_a = s;
								L_add_b = 32'h0000_8000;
								add_a = exc;
								add_b = j;
								writeAddr = add_in[11:0];
								writeOut = L_add_in[31:16];						//exc[j] = round(s);
								writeEn = 1;
								nextstate = S9;
							end
					end
					
				S7:
					begin
						L_mac_a = readIn;
						L_mac_b = constantMemIn;
						L_mac_c = s;
						next_s = L_mac_in;											//s = L_mac(s, x1[-i], c1[k]);
						add_a = x2;
						add_b = i;
						readAddr = add_in[11:0];
						L_add_a = c2;
						L_add_b = k;
						constantMemAddr = L_add_in[11:0];
						nextstate = S8;
					end
			
				S8:
					begin
						L_mac_a = readIn;
						L_mac_b = constantMemIn;
						L_mac_c = s;
						next_s = L_mac_in;											//s = L_mac(s, x2[i], c2[k]);
						add_a = i;
						add_b = 'd1;
						nexti = add_in;												//i++
						L_add_a = k;
						L_add_b = 'd3;
						nextk = L_add_in;												//k+=3
						nextstate = S6;
					end
			
				S9:
					begin
						add_a = j;
						add_b = 'd1;
						nextj = add_in;												//j++
						nextstate = S3;
					end
			
			endcase		
		end
endmodule
