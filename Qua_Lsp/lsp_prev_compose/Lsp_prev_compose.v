`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:43:24 02/03/2011 
// Design Name: 
// Module Name:    Lsp_prev 
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
module Lsp_prev_compose(start, clk, done, reset, lspele, fg, fg_sum, freq_prev, lsp, readAddr, readIn, writeAddr, writeOut, writeEn,
						L_mult_in, add_in, L_mult_a, L_mult_b, add_a, add_b, L_mac_a, L_mac_b, L_mac_c, L_mac_in,
						constantMemIn,constantMemAddr);

	input start;
   input clk;
   input reset;
	input [10:0] lspele;
	input [11:0] fg;
	input [11:0] fg_sum;
	input [10:0] freq_prev;
	input [10:0] lsp;
	input [31:0] readIn;
	input [31:0] constantMemIn;
	
	output reg done;
	output reg [10:0] writeAddr;
	output reg [31:0] writeOut;
	output reg writeEn;
	output reg [10:0] readAddr;
	output reg [11:0] constantMemAddr;
	
	input [31:0] L_mult_in, L_mac_in;
	input [15:0] add_in;
	output reg [15:0] L_mult_a, L_mult_b, add_a, add_b, L_mac_a, L_mac_b;
	output reg [31:0] L_mac_c;
	
	
	parameter INIT = 0;
	parameter S1 = 1;
	parameter S2 = 2;
	parameter S3 = 3;
	parameter S4 = 4;
	parameter S5 = 5;
	parameter S6 = 6;
	
	wire [10:0] lspele;
	wire [11:0] fg;
	wire [11:0] fg_sum;
	wire [10:0] freq_prev;
	wire [10:0] lsp;
	reg [15:0] temp_lspele, temp_freq_prev, next_temp_lspele, next_temp_freq_prev;
	reg [31:0] L_acc, next_L_acc;
	reg [3:0] state, nextstate;
	reg [15:0] j, nextj, k, nextk;
	
	
	
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
				k <= 0;
			else
				k <= nextk;
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
				 L_acc <= 0;
			else
				 L_acc <= next_L_acc;
		 end


	always @(posedge clk)
		begin
			if (reset)
				 temp_lspele <= 0;
			else
				 temp_lspele <= next_temp_lspele;
		 end
		 
		 
	always @(posedge clk)
		begin
			if (reset)
				 temp_freq_prev <= 0;
			else
				 temp_freq_prev <= next_temp_freq_prev;
		 end


	always @(*)
		begin
			nextstate = state;
			nextj = j;
			nextk = k;
			next_L_acc = L_acc;
			next_temp_lspele = temp_lspele;
			next_temp_freq_prev = temp_freq_prev;
			writeAddr = 0;
			writeOut = 0;
			writeEn = 0;
			readAddr = 0;
			done = 0;
			L_mult_a = 0;
			L_mult_b = 0;
			add_a = 0;
			add_b = 0;
			L_mac_a = 0;
			L_mac_b = 0;
			L_mac_c = 0;
			constantMemAddr = 0;
	
			case(state)
				INIT:
					begin
						readAddr = {lspele[10:4], j[3:0]};
						
						if(start)
							nextstate = S1;
					end
			
				S1:	//start of j loop
					begin
						if(j == 10)
							begin
								nextj = 0;
								done = 1;
								nextstate = INIT;
							end
							
						else
							begin
								next_temp_lspele = readIn[15:0];
								constantMemAddr = {fg_sum[11:4], j[3:0]};
								nextstate = S2;
							end
					end
			
				S2:   //L_acc = lsp_ele[j] * fg_sum[j]
					begin
						L_mult_a = temp_lspele;
						L_mult_b = constantMemIn;
						next_L_acc = L_mult_in;
						nextstate = S3;
					end
			
				S3:   //start of k loop
					begin
						if(k == 4)
						begin
							readAddr = {lspele[10:4], add_in[3:0]};
							writeAddr = {lsp[10:4], j[3:0]};
							writeOut  = L_acc[31:16];
							writeEn = 1;
							add_a = j;
							add_b = 1'd1;
							nextj = add_in;
							nextk = 0;
							nextstate = S1;
						end
						
						else
							begin
								readAddr = {freq_prev[10:6],j[3:0],k[1:0]};
								nextstate = S4;					
							end
					end
				
				S4:
					begin
						next_temp_freq_prev = readIn[15:0];
						constantMemAddr = {fg[11:6],k[1:0],j[3:0]};
						nextstate = S5;
					end
				
				S5:   //L_acc = L_acc * freq_prev + fg;
					begin
						L_mac_c = L_acc;
						L_mac_a = temp_freq_prev;
						L_mac_b = constantMemIn[15:0];
						next_L_acc = L_mac_in;
						add_a = k;
						add_b = 1'd1;
						nextk = add_in;
						nextstate = S3;
					end
					
				endcase

		end

endmodule
