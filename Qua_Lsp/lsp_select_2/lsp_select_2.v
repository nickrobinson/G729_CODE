`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Nick Robinson
// 
// Create Date:    13:08:31 2/8/2011 
// Module Name:    LSP Select 2
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
module lsp_select_2(clk, reset, start, memIn, memWriteEn, memWriteAddr, memOut, done, 
						   L_subOutA, L_subOutB, L_subIn, L_addOutA, L_addOutB, L_addIn, subOutA,
							subOutB, subIn, multOutA, multOutB, multIn, L_macOutA, L_macOutB, L_macOutC, L_macIn,
							constMemIn, constMemAddr, lspcb1Addr);

`include "paramList.v"
`include "constants_param_list.v"

//inputs
input clk, reset, start;
input [31:0] memIn;
input [31:0] constMemIn;
input [31:0] L_subIn;
input [31:0] L_addIn;
input [15:0] subIn;
input [15:0] multIn;
input [31:0] L_macIn;
input [11:0] lspcb1Addr;

//outputs
output reg memWriteEn;
output reg [11:0] memWriteAddr;
output reg [11:0] constMemAddr;
output reg [31:0] memOut;
output reg done;
output reg [31:0] L_subOutA, L_subOutB;
output reg [31:0] L_addOutA, L_addOutB;
output reg [15:0] subOutA, subOutB;
output reg [15:0] multOutA, multOutB;
output reg [15:0] L_macOutA, L_macOutB;
output reg [31:0] L_macOutC;

reg count1Ld,count1Reset;
reg count2Ld,count2Reset;
reg [5:0] count1,nextcount1;
reg [5:0] count2,nextcount2;
reg [4:0] state,nextstate;
reg [15:0] tempR,nexttempR;
reg tempRLd,tempRReset;
reg [31:0] tempB,nexttempB;
reg tempBLd,tempBReset;
reg [31:0] tempMin,nexttempMin;
reg tempMinLd,tempMinReset;
reg [31:0] tempDist,nexttempDist;
reg tempDistLd,tempDistReset;
reg [15:0] temp1,nexttemp1;
reg temp1Ld,temp1Reset;
reg [15:0] temp2,nexttemp2;
reg temp2Ld,temp2Reset;
reg [31:0] tempL,nexttempL;
reg tempLLd,tempLReset;

wire [11:0] lspcb1Addr;

//state parameters
parameter STATE_INIT = 5'd0;
parameter STATE_LOOP_1_1 = 5'd1;
parameter STATE_LOOP_1_2 = 5'd2;
parameter STATE_LOOP_1_3 = 5'd3;
parameter STATE_PRE_LOOP_2_1 = 5'd4;
parameter STATE_LOOP_OUTER_1 = 5'd5;
parameter STATE_LOOP_INNER_1 = 5'd6;
parameter STATE_LOOP_INNER_2 = 5'd7;
parameter STATE_LOOP_INNER_3 = 5'd8;
parameter STATE_LOOP_INNER_4 = 5'd9;
parameter STATE_LOOP_INNER_5 = 5'd10;
parameter STATE_LOOP_OUTER_2 = 5'd11;
parameter STATE_LOOP_OUTER_3 = 5'd12;
parameter NC = 5;		// vector size
parameter NC1 = 32;
parameter M = 10;
parameter MAX_32 = 32'h7fffffff;

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
		tempR <= 0;
	else if(tempRReset)
		tempR <= 0;
	else if(tempRLd)
		tempR <= nexttempR;
end

// Adding temp flip flop to store s value in inner loop
always @(posedge clk)
begin
	if(reset)
		tempB <= 0;
	else if(tempBReset)
		tempB <= 0;
	else if(tempBLd)
		tempB <= nexttempB;
end

always @(posedge clk)
begin
	if(reset)
		tempMin <= 0;
	else if(tempMinReset)
		tempMin <= 0;
	else if(tempMinLd)
		tempMin <= nexttempMin;
end

always @(posedge clk)
begin
	if(reset)
		tempDist <= 0;
	else if(tempDistReset)
		tempDist <= 0;
	else if(tempDistLd)
		tempDist <= nexttempDist;
end

always @(posedge clk)
begin
	if(reset)
		temp1 <= 0;
	else if(temp1Reset)
		temp1 <= 0;
	else if(temp1Ld)
		temp1 <= nexttemp1;
end

always @(posedge clk)
begin
	if(reset)
		temp2 <= 0;
	else if(temp2Reset)
		temp2 <= 0;
	else if(temp2Ld)
		temp2 <= nexttemp2;
end

always @(posedge clk)
begin
	if(reset)
		tempL <= 0;
	else if(tempLReset)
		tempL <= 0;
	else if(tempLLd)
		tempL <= nexttempL;
end

always @(*)
begin
	nextstate = state;
	nextcount1 = count1;
	nextcount2 = count2;
	nexttempR = tempR;
	nexttempB = tempB;
	nexttempMin = tempMin;
	nexttempDist = tempDist;
	nexttemp1 = temp1;
	nexttemp2 = temp2;
	nexttempL = tempL;
	done = 0;
	memWriteAddr = 0;
	memWriteEn = 0;
	memOut = 0;
	constMemAddr = 0;
	count1Reset = 0;
	count1Ld = 0;
	count2Reset = 0;
	count2Ld = 0;
	tempRLd = 0;
	tempRReset = 0;
	tempBLd = 0;
	tempBReset = 0;
	tempMinLd = 0;
	tempMinReset = 0;
	tempDistReset = 0;
	temp1Reset = 0;
	temp2Reset = 0;
	tempLReset = 0;
	L_addOutA = 0;
	L_addOutB = 0;
	L_subOutA = 0; 
	L_subOutB = 0;
	subOutA = 0; 
	subOutB = 0;
	multOutA = 0; 
	multOutB = 0;
	L_macOutA = 0; 
	L_macOutB = 0;
	L_macOutC = 0;
	
	case(state)
		
		STATE_INIT:	//state 0
		begin
			count1Reset = 1;
			tempRReset = 1;
			tempBReset = 1;
			tempMinReset = 1;
			if(start == 0)
				nextstate = STATE_INIT;
			else 
			begin
				nextstate = STATE_LOOP_1_1;
				nextcount1 = NC;
				count1Ld = 1;
			end
		end
		
		STATE_LOOP_1_1:
		begin
			if(count1 >= M)
			begin
				count1Reset = 1;
				nextstate = STATE_PRE_LOOP_2_1;
			end
			else if(count1 < M)
			begin
				memWriteAddr = {LSP_SELECT_1_RBUF[10:3], count1[2:0]};
				nextstate = STATE_LOOP_1_2;
			end	
		end
		
		STATE_LOOP_1_2:
		begin
			nexttempR = memIn[15:0]; 
			tempRLd = 1;
			constMemAddr = {lspcb1Addr[11:3], count1[2:0]};	//Modify this to follow the new 12 bit addressing
			nextstate = STATE_LOOP_1_3;
		end
		
		STATE_LOOP_1_3:
		begin
			subOutA = tempR;
			subOutB = constMemIn[15:0];
			memOut[15:0] = subIn;
			memWriteAddr = {LSP_SELECT_1_BUF[10:3], count1[2:0]};
			memWriteEn = 1;
			L_addOutA = count1;
			L_addOutB = 1;
			nextcount1 = L_addIn;
			count1Ld = 1;
			nextstate = STATE_LOOP_1_1;
		end
		
		STATE_PRE_LOOP_2_1:	//State 4
		begin
			memWriteAddr = LSP_SELECT_1_INDEX[10:0];
			memOut = 0;
			memWriteEn = 1;
			nexttempMin = MAX_32;
			tempMinLd = 1;
			nextstate = STATE_LOOP_OUTER_1;
		end
		
		STATE_LOOP_OUTER_1:
		begin
			if(count1 >= NC1)
			begin
				count1Reset = 1;
				nextstate = STATE_INIT;
				done = 1;
				$display("SUCCESS");
			end
			else if(count1 < NC1)
			begin
				nexttempDist = 0;
				tempDistLd = 1;
				nextstate = STATE_LOOP_INNER_1;
				nextcount2 = NC;
				count2Ld = 1;
			end	
		end
		
		STATE_LOOP_INNER_1:
		begin
			if(count2 >= M)
			begin
				count2Reset = 1;
				nextstate = STATE_LOOP_OUTER_2;
			end
			else if(count2 < M)
			begin
				memWriteAddr = {LSP_SELECT_1_BUF[10:3], count2[2:0]};
				nextstate = STATE_LOOP_INNER_2;
			end	
		end
		
		STATE_LOOP_INNER_2:	//State 7
		begin
			nexttempB = memIn[15:0];
			tempBLd = 1;
			constMemAddr = {LSPCB2[11:10], count1[5:0], count2[3:0]};
			nextstate = STATE_LOOP_INNER_3;
		end
		
		STATE_LOOP_INNER_3:
		begin
			subOutA = tempB[15:0];
			subOutB = constMemIn[15:0];
			nexttemp1 = subIn;
			temp1Ld = 1;
			memWriteAddr = {LSP_SELECT_1_WEGT[10:3], count2[2:0]};
			nextstate = STATE_LOOP_INNER_4;
		end
		
		STATE_LOOP_INNER_4:
		begin
			multOutA = memIn[15:0];
			multOutB = temp1;
			nexttemp2 = multIn[15:0];
			temp2Ld = 1;
			nextstate = STATE_LOOP_INNER_5;
		end
		
		STATE_LOOP_INNER_5:
		begin
			L_macOutA = temp2[15:0];
			L_macOutB = temp1[15:0];
			L_macOutC = tempDist[31:0];
			nexttempDist = L_macIn;
			tempDistLd = 1;
			L_addOutA = count2;
			L_addOutB = 1;
			nextcount2 = L_addIn;
			count2Ld = 1;
			nextstate = STATE_LOOP_INNER_1;
		end
		
		STATE_LOOP_OUTER_2:
		begin
			L_subOutA = tempDist;
			L_subOutB = tempMin;
			nexttempL = L_subIn;
			tempLLd = 1;
			nextstate = STATE_LOOP_OUTER_3;
		end
		
		STATE_LOOP_OUTER_3:	//State 12
		begin
			if(tempL[31] == 1)
			begin
				nexttempMin = tempDist;
				tempMinLd = 1;
				memWriteAddr = LSP_SELECT_1_INDEX[10:0];
				memOut = {5'd0, count1[5:0]};
				memWriteEn = 1;
			end
			L_addOutA = count1;
			L_addOutB = 1;
			nextcount1 = L_addIn;
			count1Ld = 1;
			nextstate = STATE_LOOP_OUTER_1;
		end
		
		default:
		begin
			done = 1;
			nextstate = STATE_INIT;
		end
		
	endcase
end


endmodule
