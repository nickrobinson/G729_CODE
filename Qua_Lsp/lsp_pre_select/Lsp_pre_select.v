`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:58:02 02/17/2011 
// Design Name: 
// Module Name:    Lsp_pre_select 
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
module Lsp_pre_select(clk, start, reset, done, rbuf, sub_a, sub_b, sub_in, L_mac_a, L_mac_b, L_mac_c,
								L_mac_in, add_a, add_b, add_in, L_sub_a, L_sub_b, L_sub_in, readIn, const_in, writeAddr, 
								writeOut, writeEn, readAddr, const_addr, cand);
`include "constants_param_list.v"
`include "paramList.v"

	input clk, start, reset;
	input [11:0] rbuf;
	input [31:0] readIn, const_in;


	output reg done;
	output reg [11:0] writeAddr;
	output reg [31:0] writeOut;
	output reg writeEn;
	output reg [11:0] readAddr;
	output reg [11:0] const_addr;
	output reg [6:0] cand;
	
	input [31:0] L_mac_in, L_sub_in;
	input [15:0] add_in, sub_in;
	output reg [15:0] L_mac_a, L_mac_b, add_a, add_b, sub_a, sub_b;
	output reg [31:0] L_mac_c, L_sub_a, L_sub_b;

	parameter INIT = 0;
	parameter S1 = 1;
	parameter S2 = 2;
	parameter S3 = 3;
	
	wire [11:0] rbuf;
	reg [3:0] state, nextstate;
	reg [15:0] i, nexti, j, nextj;
	reg [15:0] tmp, next_tmp;
	reg [31:0] L_dmin, next_L_dmin;
	reg [31:0] L_tmp, next_L_tmp;
	reg [31:0] L_temp, next_L_temp;

		always @(posedge clk)
		begin
			if(reset)
				j <= 0;
			else
				j <= nextj;
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
			if (reset)
				 state <= INIT;
			else
				 state <= nextstate;
		 end

	always @(posedge clk)
		begin
			if (reset)
				 L_temp <= 0;
			else
				 L_temp <= next_L_temp;
		 end
		 
	always @(posedge clk)
		begin
			if (reset)
				 tmp <= 0;
			else
				 tmp <= next_tmp;
		 end

	always @(posedge clk)
		begin
			if (reset)
				 L_tmp <= 0;
			else
				 L_tmp <= next_L_tmp;
		 end
		 
	always @(posedge clk)
		begin
			if (reset)
				 L_dmin <= 0;
			else
				 L_dmin <= next_L_dmin;
		 end

	always@(*)
		begin
			done = 0;
			writeAddr = 0;
			writeOut = 0;
			writeEn = 0;
			readAddr = 0;
			const_addr = 0;
			nextstate = state;
			nextj = j;
			nexti = i;
			next_L_temp = L_temp;
			next_tmp = tmp;
			next_L_tmp = L_tmp;
			next_L_dmin = L_dmin;
			L_mac_a = 0;
			L_mac_b = 0;
			L_mac_c = 0;
			sub_a = 0;
			sub_b = 0;
			L_sub_a = 0;
			L_sub_b = 0;
			add_a = 0;
			add_b = 0;
			
			case(state)
				INIT:
					begin	
						if(start)
						begin
							next_L_dmin = 'h7fffffff;								//L_dmin = MAX_32;
							cand = 0;
							nextstate = S1;
						end
					end
				
				S1:   //start of i loop
					begin
						if(i == 128)
							begin
								nexti = 0;
								done = 1'd1;
								nextstate = INIT;
							end
						
						else
							begin
								L_tmp = 0;											//L_tmp = 0;
								nextstate = S2;
							end
					end
			
				S2:   //start of j loop
					begin
						if(j == 10)
							begin
								nextj = 0;
								L_sub_a = L_tmp;
								L_sub_b = L_dmin;
								next_L_temp = L_sub_in;							//L_temp = L_sub(L_tmp, L_dmin);
								
								if(L_sub_in[31] == 1)								//if(L_temp < 0)
									begin
										next_L_dmin = L_tmp;						//L_dmin = L_tmp;
										cand = {i[6:0]};
									end
									
								add_a = i;
								add_b = 'd1;
								nexti = add_in; 									//i++
								nextstate = S1;
							end
							
						else
							begin
								readAddr = {rbuf[11:4], j[3:0]};
								const_addr = {i[7:0], j[3:0]};
								nextstate = S3;
							end
					end
			
				S3:
					begin
						sub_a = readIn;
						sub_b = const_in;
						next_tmp = sub_in;										//tmp = sub(rbuf[j], lspcb1[i][j]);
						L_mac_a = sub_in;
						L_mac_b = sub_in;
						L_mac_c = L_tmp;
						next_L_tmp = L_mac_in;									//L_tmp = L_mac(L_tmp, tmp, tmp);
						add_a = j;
						add_b = 'd1;
						nextj = add_in;											//j++
						nextstate = S2;
					end
			
			
			endcase
			 
			
			
		end

endmodule
