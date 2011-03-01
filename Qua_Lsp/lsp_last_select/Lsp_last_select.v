`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:03:29 02/19/2011 
// Design Name: 
// Module Name:    Lsp_last_select 
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
module Lsp_last_select(clk, start, reset, done, L_tdist, readIn, writeAddr, writeOut, writeEn, readAddr,
								L_sub_in, L_sub_a, L_sub_b);
	`include "paramList.v"
	input clk;
	input start;
	input reset;
	input [10:0] L_tdist;
	input [31:0] readIn;
	
	
	output reg done;
	output reg [10:0] writeAddr;
	output reg [31:0] writeOut;
	output reg writeEn;
	output reg [10:0] readAddr;
	
	input [31:0] L_sub_in;
	output reg [31:0] L_sub_a, L_sub_b;
	
	parameter INIT = 0;
	parameter S1 = 1;
	parameter S2 = 2;
	parameter S3 = 3;
	
	
	wire [10:0] L_tdist;
	reg [31:0] temp_L_tdist, next_temp_L_tdist;
	reg [31:0] L_temp, next_L_temp;
	reg [1:0] state, nextstate;

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
				 temp_L_tdist <= 0;
			else
				 temp_L_tdist <= next_temp_L_tdist;
		 end
		 
	always @(*)
		begin
			nextstate = state;
			next_L_temp = L_temp;
			next_temp_L_tdist = temp_L_tdist;
			writeAddr = 0;
			writeOut = 0;
			writeEn = 0;
			readAddr = 0;
			done = 0;
			L_sub_a = 0;
			L_sub_b = 0;
		
			case(state)
				INIT:
					begin
					
						if(start)
							nextstate = S1;
					end
				
				S1:
					begin
						writeAddr = QUA_LSP_MODE_INDEX;
						writeOut = 0;
						writeEn = 1;															//*mode_index = 0;
						readAddr = {L_tdist[10:1], 1'd0};
						nextstate = S2;
					end
					
				S2:
					begin
						next_temp_L_tdist = readIn;
						readAddr = {L_tdist[10:1], 1'd1};
						nextstate = S3;
					end
					
				S3:
					begin
						L_sub_a = readIn;
						L_sub_b = temp_L_tdist;
						next_L_temp = L_sub_in;												//L_temp = L_sub(L_tdist[1], L_tdist[0]);
						
						if(L_sub_in[31] == 'b1)
							begin
								writeAddr = QUA_LSP_MODE_INDEX;
								writeOut = 1;
								writeEn = 1;													//*mode_index = 1;
							end
						done = 1;
						nextstate = INIT;
					end
				endcase
		end


endmodule
