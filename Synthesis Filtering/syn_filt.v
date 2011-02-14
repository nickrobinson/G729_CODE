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
module syn_filt(clk, reset, start, memIn, memWriteEn, memWriteAddr, memOut, done,
					  xAddr, aAddr, yAddr, fMemAddr, updateAddr, L_addOutA, L_addOutB, L_addIn, L_multOutA,
					  L_multOutB, L_multIn, L_msuOutA, L_msuOutB, L_msuOutC, L_msuIn,  L_shlIn, L_shlOutVar1,
					  L_shlReady, L_shlDone, L_shlNumShiftOut);

`include "paramList.v"

//inputs
input clk, reset, start;
input [31:0] memIn;
input [10:0] xAddr;
input [10:0] aAddr;
input [10:0] yAddr;
input [10:0] fMemAddr;
input [10:0] updateAddr;
input [31:0] L_addIn;
input [31:0] L_multIn;
input [31:0] L_msuIn;
input [31:0] L_shlIn;
input L_shlDone;

//outputs
output reg memWriteEn;
output reg [10:0]  memWriteAddr;
output reg [31:0] memOut;
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
reg [5:0] count1,nextcount1;
reg [5:0] count2,nextcount2;
reg [4:0] state,nextstate;
reg [31:0] tempS,nexttempS;
reg tempSLd,tempSReset;
reg [15:0] tempY,nexttempY;
reg tempYLd,tempYReset;
reg [15:0] tempX,nexttempX;
reg tempXLd,tempXReset;
reg [15:0] tempA,nexttempA;
reg tempALd,tempAReset;
reg L_shlDoneReg;
reg L_shlDoneReset;

wire [10:0] xAddr;
wire [10:0] hAddr;
wire [10:0] yAddr;
wire [10:0] fMemAddr;
wire [10:0] updateAddr;

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
parameter STATE_ROUND_2 = 5'd12;
parameter STATE_COUNT_LOOP3_1 = 5'd13;
parameter STATE_COUNT_LOOP3_2 = 5'd14;
parameter STATE_UPDATE_1 = 5'd15;
parameter STATE_UPDATE_2 = 5'd16;
parameter STATE_UPDATE_3 = 5'd17;
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
	nexttempY = tempY;
	nexttempA = tempA;
	nexttempX = tempX;
	done = 0;
	memWriteAddr = 0;
	memWriteEn = 0;
	memOut = 0;
	count1Reset = 0;
	count1Ld = 0;
	count2Reset = 0;
	count2Ld = 0;
	tempSLd = 0;
	tempSReset = 0;
	tempYLd = 0;
	tempYReset = 0;
	tempALd = 0;
	tempAReset = 0;
	L_msuOutA = 0;
	L_msuOutB = 0;
   L_msuOutC = 0;
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
				memWriteAddr = {fMemAddr[10:8], 2'd0, count1[5:0]};
				nextstate = STATE_COUNT_LOOP1_2;
			end	
		end
		
		STATE_COUNT_LOOP1_2: //state 2
		begin
			memOut = memIn[15:0];
			memWriteAddr = {SYN_FILT_TEMP[10:8], 2'd0, count1[5:0]};
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
				memWriteAddr = {xAddr[10:6], count1[5:0]};
				nextstate = STATE_COUNT_LOOP2_2;
			end	
		end
		
		STATE_COUNT_LOOP2_2:	//state 4
		begin
			nexttempX = memIn[15:0];
			tempXLd = 1;
			memWriteAddr = {aAddr[10:6], 6'd0};
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
				memWriteAddr = {aAddr[10:6], count2[5:0]};
				nextstate = STATE_COUNT_INNER_LOOP1_2;
			end
		end
		
		STATE_COUNT_INNER_LOOP1_2:	//state 7
		begin
			nexttempA = memIn[15:0];
			tempALd = 1;
			memWriteAddr = {SYN_FILT_TEMP[10:8], 2'd0, (M-count2[5:0]) + count1[5:0]};
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
			L_addOutA = tempS;
			L_addOutB = 32'h0008000;
			memWriteAddr = {SYN_FILT_TEMP[10:8], 2'd0, M + count1[5:0]};
			memWriteEn = 1;
			memOut = L_addIn[31:16];
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
				memWriteAddr = updateAddr[10:0];
				count1Reset = 1;
				nextstate = STATE_UPDATE_1;
				$display("LEAVING LAST LOOP");
			end
			else if(count1 < L)
			begin
				memWriteAddr = {SYN_FILT_TEMP[10:8], 2'd0, (M + count1[5:0])};
				nextstate = STATE_COUNT_LOOP3_2;
			end
		end
		
		STATE_COUNT_LOOP3_2:
		begin
			memWriteAddr = {yAddr[10:6], count1[5:0]};
			memOut = memIn[15:0];
			memWriteEn = 1;
			L_addOutA = count1;
			L_addOutB = 1;
			nextcount1 = L_addIn;
			count1Ld = 1;
			nextstate = STATE_COUNT_LOOP3_1;
		end
		
		STATE_UPDATE_1:
		begin
			if(memIn == 1)
			begin
				$display("UPDATING\n");
				$display("memOut: %x\n", memOut);
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
				done = 1;
				count1Reset = 1;
				nextstate = STATE_INIT;
			end
			else if(count1 < M)
			begin
				memWriteAddr = {yAddr[10:6], (L-M+count1[5:0])};
				nextstate = STATE_UPDATE_3;
			end
		end
		
		STATE_UPDATE_3:
		begin
			memWriteAddr = {fMemAddr[10:8], 2'd0, count1[5:0]};
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
