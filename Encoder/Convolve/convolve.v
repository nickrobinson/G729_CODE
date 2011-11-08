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
						 L_shlReady, L_shlDone, L_shlNumShiftOut, xAddr, hAddr, yAddr, L_subOutA,
						 L_subOutB, L_subIn, L_addOutA, L_addOutB, L_addIn,addOutA,addOutB,addIn);

`include "paramList.v"

//inputs
input clk, reset, start;
input [31:0] memIn;
input [31:0] L_macIn;
input [31:0] L_addIn;
input [31:0] L_subIn;
input [31:0] L_shlIn;
input L_shlDone;
input [11:0] xAddr;
input [11:0] hAddr;
input [11:0] yAddr;
input [15:0] addIn;

//outputs
output reg memWriteEn;
output reg [11:0]  memWriteAddr;
output reg [31:0] memOut;
output reg L_shlReady, done;
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_addOutA,L_addOutB;
output reg [31:0] L_subOutA,L_subOutB;
output reg [31:0] L_macOutC;
output reg [31:0] L_shlOutVar1;
output reg [15:0] L_shlNumShiftOut;
output reg [15:0] addOutA,addOutB;

//state parameters
parameter INIT = 3'd0;
parameter S1 = 3'd1;
parameter S2 = 3'd2;
parameter S3 = 3'd3;
parameter S4 = 3'd4;
parameter S5 = 3'd5;
parameter S6 = 3'd6;
parameter S7 = 3'd7;

//Internal regs
reg [2:0] state,nextstate;
reg [15:0] i,nexti;
reg iLD,iReset;
reg [15:0] n,nextn;
reg nLD,nReset;
reg [31:0] s,nexts;
reg sLD,sReset;
reg [31:0] temp,nexttemp;
reg tempLD,tempReset;

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
		temp <= 0;
	else if(tempReset)
		temp <= 0;
	else if(tempLD)
		temp <= nexttemp;
end

always @(posedge clk)
begin
	if(reset)
		i <= 0;
	else if(iReset)
		i <= 0;
	else if(iLD)
		i <= nexti;
end

always @(posedge clk)
begin
	if(reset)
		n <= 0;
	else if(nReset)
		n <= 0;
	else if(nLD)
		n <= nextn;
end

always @(posedge clk)
begin
	if(reset)
		s <= 0;
	else if(sReset)
		s <= 0;
	else if(sLD)
		s <= nexts;
end
always @(*)
begin
	nextstate = state;
	nexti = i;
	nextn = n;
	nexts = s;
	nexttemp = temp;
	done = 0;
	memWriteAddr = 0;
	memWriteEn = 0;
	memOut = 0;	
	L_macOutA = 0;
	L_macOutB = 0;
	L_macOutC = 0;
	L_subOutA = 0;
	L_subOutB = 0;
	L_addOutA = 0;
	L_addOutB = 0;	
	addOutA = 0;
	addOutB = 0;
	iLD = 0;
	nLD = 0;
	sLD = 0;
	tempLD = 0;
	iReset = 0;
	nReset = 0;
	sReset = 0;
	tempReset = 0;
	L_shlOutVar1 = 0;
	L_shlNumShiftOut = 0;
	L_shlReady = 0;
	
	case(state)
		
		INIT:
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin
				iReset = 1;
				nReset = 1;
				sReset = 1;
				tempReset = 1;
				nextstate = S1;
			end
		end//INIT
		
		//for (n = 0; n < L; n++)
		S1:
		begin
			if(n>=40)
			begin
				nextstate = INIT;
				done = 1;
			end			
			else if(n<40)
			begin
				sReset = 1;
				iReset = 1;
				nextstate = S2;
			end			
		end//S1
		
		//for (i = 0; i <= n; i++)
		S2:
		begin
			if(i>n)			
				nextstate = S5;
			else if(i<=n)
			begin
				addOutA = xAddr;
				addOutB = i;
				memWriteAddr = addIn;
				nextstate = S3;
			end
		end//S2
		
		S3:
		begin
			nexttemp = memIn;
			tempLD = 1;
			L_subOutA = n;
			L_subOutB = i;
			addOutA = L_subIn;
			addOutB = hAddr;
			memWriteAddr = addIn;
			nextstate = S4;
		end//S3
		
		//s = L_mac(s, x[i], h[n-i]);
		S4:
		begin
			L_macOutA = temp[15:0];
			L_macOutB = memIn[15:0];
			L_macOutC = s;
			nexts = L_macIn;
			sLD = 1;
			L_addOutA = i;
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			nextstate = S2;
		end//S4
		
		//s = L_shl(s, 3); 
		S5:
		begin
			L_shlOutVar1 = s;
			L_shlNumShiftOut = 16'd3;
			L_shlReady = 1;
			if(L_shlDone == 1)
			begin
				nexts = L_shlIn;
				sLD = 1;
				nextstate = S7;
			end
			else
				nextstate = S6;
		end//S5
		
		//s = L_shl(s, 3); 
		S6:
		begin
			L_shlOutVar1 = s;
			L_shlNumShiftOut = 16'd3;
			if(L_shlDone == 0)
				nextstate = S6;
			else if(L_shlDone == 1)
			begin
				nexts = L_shlIn;
				sLD = 1;
				nextstate = S7;
			end
		end//S6
		
		//y[n] = extract_h(s);
		S7:
		begin
			if (s[31] == 1)
				memOut = {16'hffff,s[31:16]};
			else	
				memOut = {16'h0000,s[31:16]};
			memWriteEn = 1;
			addOutA = yAddr;
			addOutB = n;
			memWriteAddr = addIn;
			L_addOutA = n;
			L_addOutB = 32'd1;
			nextn = L_addIn;
			nLD = 1;
			nextstate = S1;
		end//S7
	endcase
end


endmodule
