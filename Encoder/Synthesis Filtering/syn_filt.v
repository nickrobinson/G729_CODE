`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Nick Robinson
// 
// Create Date:    13:08:31 2/8/2011 
// Module Name:    Synthesis Filtering
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 12.3
// Description: 	 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module syn_filt(clk, reset, start, memIn, memWriteEn, memWriteAddr, memReadAddr, memOut, done,
					  xAddr, aAddr, yAddr, fMemAddr, update, addOutA, addOutB, addIn, subOutA, subOutB, subIn, L_addOutA, L_addOutB, L_addIn, L_multOutA,
					  L_multOutB, L_multIn, L_msuOutA, L_msuOutB, L_msuOutC, L_msuIn,  L_shlIn, L_shlOutVar1,
					  L_shlReady, L_shlDone, L_shlNumShiftOut);

`include "paramList.v"

//inputs
input clk, reset, start;
input [31:0] memIn;
input [11:0] xAddr;
input [11:0] aAddr;
input [11:0] yAddr;
input [11:0] fMemAddr;
input [31:0] update;
input [15:0] addIn;
input [15:0] subIn;
input [31:0] L_addIn;
input [31:0] L_multIn;
input [31:0] L_msuIn;
input [31:0] L_shlIn;
input L_shlDone;

//outputs
output reg memWriteEn;
output reg [11:0]  memWriteAddr;
output reg [11:0]  memReadAddr;
output reg [31:0] memOut;
output reg [15:0] addOutA, addOutB;
output reg [15:0] subOutA, subOutB;
output reg [31:0] L_addOutA, L_addOutB;
output reg [15:0] L_multOutA, L_multOutB;
output reg [15:0] L_msuOutA, L_msuOutB;
output reg [31:0] L_msuOutC;
output reg done;
output reg [31:0] L_shlOutVar1;
output reg [15:0] L_shlNumShiftOut;
output reg L_shlReady;

reg count1Ld,count1Reset;
reg count2Ld,count2Reset;
reg clearcountLd,clearcountReset;
reg [5:0] count1,nextcount1;
reg [5:0] count2,nextcount2;
reg [6:0] clearcount,nextclearcount;
reg [4:0] state,nextstate;
reg [31:0] tempS,nexttempS;
reg tempSLd,tempSReset;
reg [15:0] tempY,nexttempY;
reg tempYLd,tempYReset;
reg [15:0] tempX,nexttempX;
reg tempXLd,tempXReset;
reg [15:0] tempA,nexttempA;
reg tempALd,tempAReset;
reg [15:0] tempAddr,nexttempAddr;
reg tempAddrLd,tempAddrReset;
reg L_shlDoneReg;
reg L_shlDoneReset;

//state parameters
parameter STATE_INIT = 5'd0;
parameter STATE_COUNT_LOOP1_1 = 5'd1;
parameter STATE_COUNT_LOOP1_2 = 5'd2;
parameter STATE_COUNT_LOOP2_1 = 5'd3;
parameter STATE_COUNT_LOOP2_2 = 5'd4;
parameter STATE_COUNT_LOOP2_3 = 5'd5;
parameter STATE_COUNT_INNER_LOOP1_1 = 5'd6;
parameter STATE_COUNT_INNER_LOOP1_2 = 5'd7;
parameter STATE_COUNT_INNER_LOOP1_3 = 5'd8;
parameter STATE_L_SHL1 = 5'd9;
parameter STATE_L_SHL2 = 5'd10;
parameter STATE_ROUND_1 = 5'd11;
parameter STATE_ROUND_1to2 = 5'd12;
parameter STATE_ROUND_2 = 5'd13;
parameter STATE_COUNT_LOOP3_1 = 5'd14;
parameter STATE_COUNT_LOOP3_2 = 5'd15;
parameter STATE_UPDATE_1 = 5'd16;
parameter STATE_UPDATE_2 = 5'd17;
parameter STATE_UPDATE_3 = 5'd18;
parameter L = 40;		// vector size
parameter M = 10;

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

always @(posedge clk)
begin
	if(reset)
		clearcount <= 0;
	else if(clearcountReset)
		clearcount <= 0;
	else if(clearcountLd)
		clearcount <= nextclearcount;
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

// Adding temp flip flop to store Y value in inner loop
always @(posedge clk)
begin
	if(reset)
		tempY <= 0;
	else if(tempYReset)
		tempY <= 0;
	else if(tempYLd)
		tempY <= nexttempY;
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

always @(posedge clk)
begin
	if(reset)
		tempA <= 0;
	else if(tempAReset)
		tempA <= 0;
	else if(tempALd)
		tempA <= nexttempA;
end

always @(posedge clk)
begin
	if(reset)
		tempAddr <= 0;
	else if(tempAddrReset)
		tempAddr <= 0;
	else if(tempAddrLd)
		tempAddr <= nexttempAddr;
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
	nextclearcount = clearcount;
	nexttempS = tempS;
	nexttempY = tempY;
	nexttempA = tempA;
	nexttempAddr = tempAddr;
	nexttempX = tempX;
	done = 0;
	memWriteAddr = 0;
	memReadAddr = 0;
	memWriteEn = 0;
	memOut = 0;
	count1Reset = 0;
	count1Ld = 0;
	count2Reset = 0;
	count2Ld = 0;
	clearcountReset = 0;
	clearcountLd = 0;
	tempSLd = 0;
	tempSReset = 0;
	tempYLd = 0;
	tempYReset = 0;
	tempALd = 0;
	tempAReset = 0;
	tempAddrLd = 0;
	tempAddrReset = 0;
	tempXLd = 0;
	tempXReset = 0;
	L_msuOutA = 0;
	L_msuOutB = 0;
   L_msuOutC = 0;
	addOutA = 0;
	addOutB = 0;
	subOutA = 0;
	subOutB = 0;
	L_addOutA = 0;
	L_addOutB = 0;
	L_multOutA = 0;
	L_multOutB = 0;
	L_shlOutVar1 = 0;
	L_shlNumShiftOut = 0;
	L_shlReady = 0;
	L_shlDoneReset = 0;
	
	case(state)
		
		STATE_INIT:	//state 0
		begin
			count1Reset = 1;
			count2Reset = 1;
			clearcountReset = 1;
			L_shlDoneReset = 1;
			if(start == 0)
				nextstate = STATE_INIT;
			else 
			begin
				nextstate = STATE_COUNT_LOOP1_1;
			end
		end
		
		STATE_COUNT_LOOP1_1:	//state 1
		begin
			if(count1 >= M)
			begin
				nextstate = STATE_COUNT_LOOP2_1;
				count1Reset = 1;
			end
			else if(count1 < M)
			begin
//				memReadAddr = {fMemAddr[11:6], count1[5:0]};
				addOutA = fMemAddr;
				addOutB = count1;
				memReadAddr = addIn;
				nextstate = STATE_COUNT_LOOP1_2;
			end	
		end
		
		STATE_COUNT_LOOP1_2: //state 2
		begin
			if (memIn[15] == 1)
				memOut = {16'hffff, memIn};
			else
				memOut = {16'd0, memIn};
//			memOut = memIn[15:0];
//			memWriteAddr = {SYN_FILT_TEMP[11:8], 2'd0, count1[5:0]};
			addOutA = SYN_FILT_TEMP;
			addOutB = count1;
			memWriteAddr = addIn;
			memWriteEn = 1;
			L_addOutA = count1;
			L_addOutB = 1;
			nextcount1 = L_addIn;
			count1Ld = 1;
			nextstate = STATE_COUNT_LOOP1_1;
		end
		
		
		STATE_COUNT_LOOP2_1:	//state 3
		begin
			if(count1 >= L)
			begin
				count1Reset = 1;
				nextstate = STATE_COUNT_LOOP3_1;
			end
			else if(count1 < L)
			begin
//				memReadAddr = {xAddr[11:6], count1[5:0]};
				addOutA = xAddr;
				addOutB = count1;
				memReadAddr = addIn;
				nextstate = STATE_COUNT_LOOP2_2;
			end	
		end
		
		STATE_COUNT_LOOP2_2:	//state 4
		begin
			nexttempX = memIn[15:0];
			tempXLd = 1;
			memReadAddr = aAddr[11:0];
			nextstate = STATE_COUNT_LOOP2_3;
		end
		
		STATE_COUNT_LOOP2_3:	//state 5
		begin
			L_multOutA = tempX;
			L_multOutB = memIn[15:0];
			nexttempS = L_multIn;
			tempSLd = 1;
			nextcount2 = 1;
			count2Ld = 1;
			nextstate = STATE_COUNT_INNER_LOOP1_1;
		end
		
		STATE_COUNT_INNER_LOOP1_1:	//state 6
		begin
			if(count2 > M)
			begin
				count2Reset = 1;
				nextstate = STATE_L_SHL1;
			end
			else if(count2 <= M)
			begin
//				memReadAddr = {aAddr[11:6], count2[5:0]};
				addOutA = aAddr;
				addOutB = count2;
				memReadAddr = addIn;
				nextstate = STATE_COUNT_INNER_LOOP1_2;
			end
		end
		
		STATE_COUNT_INNER_LOOP1_2:	//state 7
		begin
			nexttempA = memIn[15:0];
			tempALd = 1;
//			memReadAddr = {SYN_FILT_TEMP[11:8], 2'd0, (M-count2[5:0]) + count1[5:0]};
			addOutA = SYN_FILT_TEMP;
			addOutB = M;
			L_addOutA = addIn;
			L_addOutB = count1;
			subOutA = L_addIn;
			subOutB = count2;
			memReadAddr = subIn;
			nextstate = STATE_COUNT_INNER_LOOP1_3;
		end
		
		STATE_COUNT_INNER_LOOP1_3:	//state 8
		begin
			L_msuOutA = tempA;
			L_msuOutB = memIn[15:0];
			L_msuOutC = tempS;
			nexttempS = L_msuIn;
			tempSLd = 1;
			L_addOutA = count2;
			L_addOutB = 1;
			nextcount2 = L_addIn;
			count2Ld = 1;
			nextstate = STATE_COUNT_INNER_LOOP1_1;
		end
		
		STATE_L_SHL1:	//state 9
		begin
			L_shlOutVar1 = tempS;
			L_shlNumShiftOut = 16'd3;
			L_shlReady = 1;
			nextstate = STATE_L_SHL2;
		end
		
		STATE_L_SHL2:	//state 10
		begin
			if(L_shlDone == 1'b0)
				begin
					nextstate = STATE_L_SHL2;
				end
			else
				begin
					nexttempS = L_shlIn;
					tempSLd = 1;
					nextstate = STATE_ROUND_1;
				end
		end
		
		STATE_ROUND_1:	//state 11
		begin
//			L_addOutA = tempS;
//			L_addOutB = 32'h0008000;
//			memWriteAddr = {SYN_FILT_TEMP[11:8], 2'd0, M + count1[5:0]};
			addOutA = SYN_FILT_TEMP;
			addOutB = M;
			L_addOutA = addIn;
			L_addOutB = count1;
			nexttempAddr = L_addIn;
			tempAddrLd = 1;
//			memWriteEn = 1;
//			memOut = L_addIn[31:16];
			nextstate = STATE_ROUND_1to2;
		end

		STATE_ROUND_1to2:	//state 12
		begin
			L_addOutA = tempS;
			L_addOutB = 32'h00008000;
			memWriteAddr = tempAddr;
			memWriteEn = 1;
//			memOut = L_addIn[31:16];
			if (L_addIn[31] == 1)
				memOut = {16'hffff, L_addIn[31:16]};
			else
				memOut = {16'd0, L_addIn[31:16]};
			nextstate = STATE_ROUND_2;
		end
		
		STATE_ROUND_2:	//state 12
		begin
			L_addOutA = count1;
			L_addOutB = 1;
			nextcount1 = L_addIn;
			count1Ld = 1;
			nextstate = STATE_COUNT_LOOP2_1;
		end
		
		STATE_COUNT_LOOP3_1:
		begin
			if(count1 >= L)
			begin
				count1Reset = 1;
				nextstate = STATE_UPDATE_1;
			end
			else if(count1 < L)
			begin
				addOutA = M;
				addOutB = count1;
				L_addOutA = SYN_FILT_TEMP;
				L_addOutB = addIn;
				memReadAddr = L_addIn;
				nextstate = STATE_COUNT_LOOP3_2;
			end
		end
		
		STATE_COUNT_LOOP3_2:
		begin
			addOutA = yAddr;
			addOutB = count1;
			memWriteAddr = addIn;
//			memWriteAddr = {yAddr[11:6], count1[5:0]};
//			memOut = memIn[15:0];
			if (memIn[15] == 1)
				memOut = {16'hffff, memIn};
			else
				memOut = {16'd0, memIn};
			memWriteEn = 1;
			L_addOutA = count1;
			L_addOutB = 1;
			nextcount1 = L_addIn;
			count1Ld = 1;
			nextstate = STATE_COUNT_LOOP3_1;
		end
		
		STATE_UPDATE_1:
		begin
			if(update == 'd1)
			begin
				nextstate = STATE_UPDATE_2;
			end
			else
			begin
				done = 1;
				nextstate = STATE_INIT;
			end
		end
		
		STATE_UPDATE_2:
		begin
			if(count1 >= M)
			begin
//				done = 1;
//				count1Reset = 1;
//				nextstate = STATE_INIT;
				if(clearcount > 80)
				begin
					done = 1;
					count1Reset = 1;
					nextstate = STATE_INIT;
				end
				else
				begin
					addOutA = SYN_FILT_TEMP;
					addOutB = clearcount;
					memWriteAddr = addIn;
					memOut = 32'd0;
					memWriteEn = 1;
					L_addOutA = clearcount;
					L_addOutB = 32'd1;
					nextclearcount = L_addIn;
					clearcountLd = 1;
					nextstate = STATE_UPDATE_2;
				end
			end
			else if(count1 < M)
			begin
//				memReadAddr = {yAddr[11:6], (L-M+count1[5:0])};
				subOutA = L;
				subOutB = M;
				addOutA = subIn;
				addOutB = count1;
				L_addOutA = yAddr;
				L_addOutB = addIn;
				memReadAddr = L_addIn;
				nextstate = STATE_UPDATE_3;
			end
		end
		
		STATE_UPDATE_3:
		begin
//			memWriteAddr = {fMemAddr[11:6], count1[5:0]};
			addOutA = fMemAddr;
			addOutB = count1;
			memWriteAddr = addIn;
			memOut = memIn;
			memWriteEn = 1;
			L_addOutA = count1;
			L_addOutB = 1;
			nextcount1 = L_addIn;
			count1Ld = 1;
			nextstate = STATE_UPDATE_2;
		end
		
		default:
		begin
			done = 1;
			nextstate = STATE_INIT;
		end
		
	endcase
end


endmodule
