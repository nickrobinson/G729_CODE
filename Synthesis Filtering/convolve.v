`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Nick Robinson
// 
// Create Date:    13:08:31 10/12/2010 
// Module Name:    convolve
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 12.3
// Description: 	Perform the convolution between two vectors x[] and h[] and  
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module convolve(clk, reset, start, memIn, memWriteEn, memWriteAddr, memOut, done,
					    L_macIn, L_macOutA, L_macOutB, L_macOutC);

`include "paramList.v"

//inputs
input clk, reset, start;
input [31:0] memIn;
input [31:0] L_macIn;

//outputs
output reg memWriteEn;
output reg [10:0]  memWriteAddr;
output reg [31:0] memOut;
output reg done;
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;

reg count1Ld,count1Reset;
reg count2Ld,count2Reset;
reg [5:0] count1,nextcount1;
reg [5:0] count2,nextcount2;
reg [2:0] state,nextstate;
reg [31:0] temp,nexttemp;
reg tempLd,tempReset;

//state parameters
parameter STATE_INIT = 3'd0;
parameter STATE_COUNT_LOOP1 = 3'd1;
parameter STATE_COUNT_LOOP2 = 3'd2;
parameter STATE_L_MAC1 = 3'd3;
parameter L = 40;		// vector size

//state, count, and product flops
always @(posedge clk)
begin
	if(reset)
		state <= 0;
	else
		state <= nextstate;	
end	

always @(posedge clk)
begin
	if(reset)
		count1 <= 0;
	else if(count1Reset)
		count1 <= 0;
	else if(count1Ld)
		count1 <= nextcount1;
end

always @(posedge clk)
begin
	if(reset)
		count2 <= 0;
	else if(count2Reset)
		count2 <= 0;
	else if(count2Ld)
		count2 <= nextcount2;
end

// Adding temp flip flop to store s value in inner loop
always @(posedge clk)
begin
	if(reset)
		temp <= 0;
	else if(tempReset)
		temp <= 0;
	else if(tempLd)
		temp <= nexttemp;
end

always @(*)
begin
	nextstate = state;
	nextcount1 = count1;
	nextcount2 = count2;
	done = 0;
	memWriteAddr = 0;
	memWriteEn = 0;
	count1Reset = 0;
	count1Ld = 0;
	count2Reset = 0;
	count2Ld = 0;
	L_macOutA = 0;
	L_macOutB = 0;
	L_macOutC = 0;
	
	case(state)
		
		STATE_INIT:
		begin
			count1Reset = 1;
			count2Reset = 1;
			if(start == 0)
				nextstate = STATE_INIT;
			else 
			begin
				nextstate = STATE_COUNT_LOOP1;
				//rPrimeRequested = {AUTOCORR_R[10:4],4'd0};
			end
		end
		
		STATE_COUNT_LOOP1:
		begin
			if(count1 > L)
			begin
				nextstate = STATE_INIT;
			end
			else if(count1 <= L)
			begin
				//rPrimeRequested = {AUTOCORR_R[10:4],count};
				nextstate = STATE_COUNT_LOOP2;
				nexttemp = 0;    //This temp variable will represent s from the C code
				tempLd = 1;
			end		
		end
		
		STATE_COUNT_LOOP2:
		begin
			if(count2 > count1)
			begin
				nextcount1 = count1 + 1;
				count1Ld = 1;
				count2Reset = 1;
				nextstate = STATE_COUNT_LOOP1;
			end
			else if(count2 <= count1)
			begin
				//rPrimeRequested = {AUTOCORR_R[10:4],count};
				nextcount2 = count2 + 1;
		      count2Ld = 1;
				memWriteAddr = {AUTOCORR_R[10:6], count2};
			end	
		end
		
		STATE_L_MAC1:
		begin
			nextstate = STATE_COUNT_LOOP2;
		end
		
		default:
		begin
			$display("Default State Reached");
			nextstate = STATE_INIT;
		end
		
	endcase
end


endmodule
