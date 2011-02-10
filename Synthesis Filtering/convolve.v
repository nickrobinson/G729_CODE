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
					    L_macIn, L_macOutA, L_macOutB, L_macOutC, L_shlIn, L_shlOutVar1,
						 L_shlReady, L_shlDone, L_shlNumShiftOut, xAddr, hAddr, yAddr);

`include "paramList.v"

//inputs
input clk, reset, start;
input [31:0] memIn;
input [31:0] L_macIn;
input [31:0] L_shlIn;
input L_shlDone;
input [10:0] xAddr;
input [10:0] yAddr;
input [10:0] hAddr;

//outputs
output reg memWriteEn;
output reg [10:0]  memWriteAddr;
output reg [31:0] memOut;
output reg L_shlReady, done;
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;
output reg [31:0] L_shlOutVar1;
output reg [15:0] L_shlNumShiftOut;

reg count1Ld,count1Reset;
reg count2Ld,count2Reset;
reg [5:0] count1,nextcount1;
reg [5:0] count2,nextcount2;
reg [2:0] state,nextstate;
reg [31:0] tempS,nexttempS;
reg tempSLd,tempSReset;
reg [15:0] tempX,nexttempX;
reg tempXLd,tempXReset;
reg L_shlDoneReg;
reg L_shlDoneReset;

wire [10:0] xAddr;
wire [10:0] yAddr;
wire [10:0] hAddr;

//state parameters
parameter STATE_INIT = 3'd0;
parameter STATE_COUNT_LOOP1 = 3'd1;
parameter STATE_COUNT_LOOP2 = 3'd2;
parameter STATE_L_MAC1 = 3'd3;
parameter STATE_L_MAC2 = 3'd4;
parameter STATE_L_SHL1 = 3'd5;
parameter STATE_L_SHL2 = 3'd6;
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
		tempS <= 0;
	else if(tempSReset)
		tempS <= 0;
	else if(tempSLd)
		tempS <= nexttempS;
end

// Adding temp flip flop to store X value in inner loop
always @(posedge clk)
begin
	if(reset)
		tempX <= 0;
	else if(tempXReset)
		tempX <= 0;
	else if(tempXLd)
		tempX <= nexttempX;
end

//left shifter done flop
always@(posedge clk) begin
	if(reset)	 
		 L_shlDoneReg <= 0;
	else if (L_shlDoneReset)
		L_shlDoneReg <= 0;
	else if (L_shlReady)
	    L_shlDoneReg <= L_shlDone;
end

always @(*)
begin
	nextstate = state;
	nextcount1 = count1;
	nextcount2 = count2;
	nexttempS = tempS;
	nexttempX = tempX;
	done = 0;
	memWriteAddr = 0;
	memWriteEn = 0;
	memOut = 0;
	count1Reset = 0;
	count1Ld = 0;
	count2Reset = 0;
	count2Ld = 0;
	L_macOutA = 0;
	L_macOutB = 0;
	L_macOutC = 0;
	tempSLd = 0;
	tempSReset = 0;
	tempXLd = 0;
	tempXReset = 0;
	L_shlOutVar1 = 0;
	L_shlNumShiftOut = 0;
	L_shlReady = 0;
	L_shlDoneReset = 0;
	
	case(state)
		
		STATE_INIT:
		begin
			count1Reset = 1;
			count2Reset = 1;
			L_shlDoneReset = 1;
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
			if(count1 >= L)
			begin
				nextstate = STATE_INIT;
				done = 1;
			end
			else if(count1 < L)
			begin
				nextstate = STATE_COUNT_LOOP2;
				nexttempS = 0;    //This temp variable will represent s from the C code
				tempSLd = 1;
			end		
		end
		
		STATE_COUNT_LOOP2:
		begin
			if(count2 > count1)
			begin
				count2Reset = 1;
				nextstate = STATE_L_SHL1;
			end
			else if(count2 <= count1)
			begin
				memWriteAddr = {xAddr[10:6], count2[5:0]};
				nextstate = STATE_L_MAC1;
			end	
		end
		
		STATE_L_MAC1:
		begin
			nexttempX = memIn[15:0];
			tempXLd = 1;
			memWriteAddr = {hAddr[10:6], count1[5:0]-count2[5:0]};
			nextstate = STATE_L_MAC2;
		end
		
		STATE_L_MAC2:
		begin
			L_macOutC = tempS;
			L_macOutB = tempX;
			L_macOutA = memIn[15:0];
			nexttempS = L_macIn;
			tempSLd = 1;
			nextcount2 = count2 + 1;
			count2Ld = 1;
			nextstate = STATE_COUNT_LOOP2;
		end
		
		STATE_L_SHL1:
		begin 
			L_shlOutVar1 = tempS;
			L_shlNumShiftOut = 16'd3;
			L_shlReady = 1;
			nextstate = STATE_L_SHL2;
		end
		
		STATE_L_SHL2:
		begin
			if(L_shlDone == 1'b0)
				begin
					nextstate = STATE_L_SHL2;
				end
			else
				begin
					nexttempS = L_shlIn;
					tempSLd = 1;
					memWriteAddr = {yAddr[10:6], count1[5:0]};
					memOut = {16'd0, L_shlIn[31:16]};
					memWriteEn = 1;
					//Increment count 1 since we are done with the outside loop
					nextcount1 = count1 + 1;
					count1Ld = 1;
					nextstate = STATE_COUNT_LOOP1;
				end
		end
		
		default:
		begin
			nextstate = STATE_INIT;
		end
		
	endcase
end


endmodule
