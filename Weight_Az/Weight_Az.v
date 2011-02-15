`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:59:08 01/23/2011 
// Design Name: 
// Module Name:    Weight_Az 
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
module Weight_Az(start, clk, done, reset, A, AP, gammaAddr, readAddr, readIn, writeAddr, writeOut, writeEn, 
						L_mult_in, L_add_in, add_in, L_mult_a, L_mult_b, add_a, add_b, L_add_a, L_add_b);
   input start;
   input clk;
   input reset;
	input [31:0] readIn;
	input [10:0] A, AP;
	input [10:0] gammaAddr;
	output reg done;
	output reg [10:0] writeAddr;
	output reg [31:0] writeOut;
	output reg writeEn;
	output reg [10:0] readAddr;
	
	input [31:0] L_mult_in, L_add_in;
	input [15:0] add_in;
	output reg [15:0] L_mult_a, L_mult_b, add_a, add_b;
	output reg [31:0] L_add_a, L_add_b;
	
	
	parameter INIT = 0;
	parameter S1 = 1;
	parameter S2 = 2;
	parameter S3 = 3;
	parameter S4 = 4;
	parameter S5 = 5;
	parameter S6 = 6;
	
	parameter m = 10;
	wire [31:0] readIn;
	wire [10:0] A, AP;
	wire [10:0] gammaAddr;
	reg [3:0] state, nextstate;
	reg [15:0] fac, nextfac, iter, nextiter;
	reg [15:0] gamma, nextgamma;
	
	always @(posedge clk)
		begin
			if(reset)
				fac <= 0;
			else
				fac <= nextfac;
		end
	
	
	always @(posedge clk)
		begin
			if(reset)
				gamma <= 0;
			else
				gamma <= nextgamma;
		end
		
		
	always @(posedge clk)
		begin
			if(reset)
				iter <= 1;
			else
				iter <= nextiter;
		end
	
	
	always @(posedge clk)
		begin
			if (reset)
				 state <= INIT;
			else
				 state <= nextstate;
		 end
	
	always@(*)
		begin
		nextstate = state;
		nextgamma = gamma;
		nextfac = fac;
		nextiter = iter;
		add_a = 0;
		add_b = 0;
		L_add_a = 0;
		L_add_b = 0;
		L_mult_a = 0;
		L_mult_b = 0;
		writeAddr = 0;
		writeOut = 0;
		writeEn = 0;
		readAddr = 0;
		done = 0;
		
			case(state)
				INIT:	//read in a[0]
					begin
						readAddr = {A[10:4], 4'd0};
						if(start)
							begin
								nextstate = S1;
							end
						else
							nextstate = INIT;
					end
		
				S1: //ap[0] = ap[0];  //read in gamma
					begin
						writeAddr = {AP[10:4], 4'd0};
						writeOut = readIn;
						writeEn = 1;
						readAddr = gammaAddr;
						nextstate = S2;
					end
					
				S2: //fac = gamma
					begin
						nextfac = readIn;
						nextgamma = readIn;
						nextstate = S3;
					end
					
				S3: //begin loop
					begin
						if(iter == m)
							begin
								nextiter = 1;
								readAddr = {A[10:4], 4'd10};
								nextstate = S6;
							end
						
						else
							begin
								readAddr = {A[10:4], iter[3:0]};
								nextstate = S4;
							end
					end
					
				S4:
					begin
						L_mult_a = readIn;
						L_mult_b = fac;
						L_add_a = L_mult_in;
						L_add_b = 32'h00008000;
						writeAddr = {AP[10:4], iter[3:0]};
						writeOut = L_add_in[31:16];
						writeEn = 1;
						nextstate = S5;
					end
					
				S5:
					begin
						L_mult_a = fac;
						L_mult_b = gamma;
						L_add_a = L_mult_in;
						L_add_b = 32'h00008000;
						nextfac = L_add_in[31:16];
						add_a = iter;
						add_b = 1'd1;
						nextiter = add_in;
						nextstate = S3;
					end
				
				S6:
					begin
						L_mult_a = readIn;
						L_mult_b = fac;
						L_add_a = L_mult_in;
						L_add_b = 32'h00008000;
						writeAddr = {AP[10:4], 4'd10};
						writeOut = L_add_in[31:16];
						writeEn = 1;
						done = 1;
						nextstate = INIT;
					end
				
			endcase
		end

endmodule
