`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Nick Robinson
// 
// Create Date:    13:08:31 2/8/2011 
// Module Name:    Get_wget
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
module Get_wegt(clk, reset, start, memIn, memWriteEn, memWriteAddr, memReadAddr,
						memOut, done, subIn, addIn, subOutA, subOutB, addOutA, addOutB,
						L_subOutA, L_subOutB, L_subIn, wegtAddr, flspAddr, L_multOutA,
						L_multOutB, L_multIn, L_shlIn, L_shlDone, L_shlOutVar1, L_shlNumShiftOut,
						L_shlReady, L_addIn, L_addOutA, L_addOutB, norm_sIn, norm_sDone,
						norm_sOut, norm_sReady);

`include "paramList.v"

//inputs
input clk, reset, start;
input [31:0] memIn;
input [10:0] wegtAddr;
input [10:0] flspAddr;
input [15:0] subIn;
input [15:0] addIn;
input [31:0] L_subIn;
input [31:0] L_addIn;
input [31:0] L_multIn;
input [31:0] L_shlIn;
input L_shlDone;
input [15:0] norm_sIn;
input norm_sDone;

//outputs
output reg memWriteEn;
output reg [10:0]  memWriteAddr;
output reg [10:0]  memReadAddr;
output reg [31:0] memOut;
output reg [15:0] subOutA, subOutB;
output reg [15:0] addOutA, addOutB;
output reg [31:0] L_subOutA, L_subOutB;
output reg [31:0] L_addOutA, L_addOutB;
output reg [15:0] L_multOutA, L_multOutB;
output reg [31:0] L_shlOutVar1;
output reg [15:0] L_shlNumShiftOut;
output reg L_shlReady;
output reg [15:0] norm_sOut;
output reg norm_sReady;
output reg done;


reg count1Ld,count1Reset;
reg [5:0] count1,nextcount1;
reg [4:0] state,nextstate;
reg [15:0] tempFlsp,nexttempFlsp;
reg tempFlspLd,tempFlspReset;
reg [15:0] temp1,nexttemp1;
reg temp1Ld,temp1Reset;
reg [31:0] tempAcc,nexttempAcc;
reg tempAccLd,tempAccReset;
reg [15:0] tempSft,nexttempSft;
reg tempSftLd,tempSftReset;
reg L_shlDoneReg;
reg L_shlDoneReset;


wire [10:0] flspAddr;
wire [10:0] wegtAddr;

//state parameters
parameter STATE_INIT = 5'd0;
parameter STATE_SUB_1 = 5'd1;
parameter STATE_COUNT_LOOP1 = 5'd2;
parameter STATE_COUNT_LOOP2 = 5'd3;
parameter STATE_COUNT_LOOP3 = 5'd4;
parameter STATE_COUNT_LOOP4 = 5'd5;
parameter STATE_5 = 5'd6;
parameter STATE_COUNT2_LOOP1 = 5'd7;
parameter STATE_COUNT2_LOOP2 = 5'd8;
parameter STATE_COUNT2_LOOP3 = 5'd9;
parameter STATE_COUNT2_LOOP4 = 5'd10;
parameter STATE_COUNT2_LOOP5 = 5'd11;
parameter STATE_COUNT2_LOOP6 = 5'd12;
parameter STATE_COUNT2_LOOP7 = 5'd13;
parameter STATE_COUNT2_LOOP8 = 5'd14;
parameter STATE_COUNT2_LOOP9 = 5'd15;
parameter STATE_12 = 5'd16;
parameter STATE_SHL1_1 = 5'd17;
parameter STATE_SHL1_2 = 5'd18;
parameter STATE_15 = 5'd19;
parameter STATE_16 = 5'd20;
parameter STATE_SHL2_1 = 5'd21;
parameter STATE_SHL2_2 = 5'd22;
parameter STATE_COUNT3_LOOP1 = 5'd23;
parameter STATE_COUNT3_LOOP2 = 5'd24;
parameter STATE_SFT_1 = 5'd25;
parameter STATE_SFT_2 = 5'd26;
parameter STATE_COUNT4_LOOP1 = 5'd27;
parameter STATE_COUNT4_LOOP2 = 5'd28;
parameter STATE_COUNT4_LOOP3 = 5'd29;

parameter M = 10;
parameter M1 = 9; //M-1
parameter PI04 = 1029;
parameter PI92 = 23677;
parameter CONST10 = 20480;
parameter CONST12 = 19661;

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


// Adding temp flip flop to store s value in inner loop
always @(posedge clk)
begin
	if(reset)
		tempFlsp <= 0;
	else if(tempFlspReset)
		tempFlsp <= 0;
	else if(tempFlspLd)
		tempFlsp <= nexttempFlsp;
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
		tempSft <= 0;
	else if(tempSftReset)
		tempSft <= 0;
	else if(tempSftLd)
		tempSft <= nexttempSft;
end

always @(posedge clk)
begin
	if(reset)
		tempAcc <= 0;
	else if(tempAccReset)
		tempAcc <= 0;
	else if(tempAccLd)
		tempAcc <= nexttempAcc;
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
	nexttempFlsp = tempFlsp;
	nexttemp1 = temp1;
	nexttempAcc = tempAcc;
	nexttempSft = tempSft;
	done = 0;
	memWriteAddr = 0;
	memReadAddr = 0;
	memWriteEn = 0;
	memOut = 0;
	count1Reset = 0;
	count1Ld = 0;
	tempFlspLd = 0;
	tempFlspReset = 0;
	temp1Ld = 0;
	temp1Reset = 0;
	tempAccLd = 0;
	tempAccReset = 0;
	tempSftLd = 0;
	tempSftReset = 0;
	subOutA = 0;
	subOutB = 0;
	L_subOutA = 0;
	L_subOutB = 0;
	L_multOutA = 0;
	L_multOutB = 0;
	addOutA = 0;
	addOutB = 0;
	L_shlOutVar1 = 0;
	L_shlNumShiftOut = 0;
	L_shlReady = 0;
	L_shlDoneReset = 0;
	norm_sReady = 0;
	norm_sOut = 0;	
	
	case(state)
		
		STATE_INIT:	//state 0
		begin
			count1Reset = 1;
			if(start == 0)
				nextstate = STATE_INIT;
			else if(start == 1)
			begin
				//Read from FLSP[1] addr
				addOutA = flspAddr[10:0];
				addOutB = 1;
				memReadAddr = addIn[10:0];
				nextstate = STATE_SUB_1;
			end
		end	

		STATE_SUB_1:	//state 1
		begin
			addOutA = PI04;
			addOutB = 8192;
			subOutA = memIn[15:0];
			subOutB = addIn;
			memOut = subIn;
			nextcount1 = 6'd1;
			count1Ld = 1;
			memWriteAddr = GET_WEGT_BUF;
			memWriteEn = 1;
			nextstate = STATE_COUNT_LOOP1;
		end
		
		STATE_COUNT_LOOP1:	 //state 2
		begin
			if(count1 >= M1)
			begin
				count1Reset = 1;
				subOutA = M;
				subOutB = 2;
				memReadAddr = {flspAddr[10:4], subIn[3:0]};
				nextstate = STATE_5;
			end
			else if(count1 < M1)
			begin
				addOutA = count1;
				addOutB = 1;
				memReadAddr = {flspAddr[10:4], addIn[3:0]};
				nextstate = STATE_COUNT_LOOP2;
			end	
		end
		
		STATE_COUNT_LOOP2:	//state 3
		begin
			nexttempFlsp = memIn[15:0];
			tempFlspLd = 1;
			subOutA = count1;
			subOutB = 1;
			memReadAddr = {flspAddr[10:4], subIn[3:0]};
			nextstate = STATE_COUNT_LOOP3;
		end
		
		STATE_COUNT_LOOP3:	//state 4
		begin
			subOutA = tempFlsp;
			subOutB = memIn[15:0];
			nexttemp1 = subIn;
			temp1Ld = 1;
			nextstate = STATE_COUNT_LOOP4;
		end
		
		STATE_COUNT_LOOP4:	//state 5
		begin
			subOutA = temp1;
			subOutB = 16'd8192;
			memWriteAddr = {GET_WEGT_BUF[10:4], count1[3:0]};
			memOut = subIn;
			memWriteEn = 1;
			//Increment Counter
			addOutA = count1;
			addOutB = 1;
			nextcount1 = addIn;
			count1Ld = 1;
			//Transition back to loop
			nextstate = STATE_COUNT_LOOP1;
		end
		
		STATE_5:	//state 6
		begin
			L_subOutA = {16'd0, PI92};
			L_subOutB = {16'd0, 16'd8192};
			subOutA = L_subIn[15:0];
			subOutB = memIn;
			addOutA = M1;
			addOutB = 0;
			memWriteAddr = {GET_WEGT_BUF[10:4], addIn[3:0]};
			memOut = subIn;
			memWriteEn = 1;
			nextstate = STATE_COUNT2_LOOP1;
		end
		
		STATE_COUNT2_LOOP1:	//state 7
		begin
			if(count1 >= M)
			begin
				count1Reset = 1;
				memReadAddr = {wegtAddr[10:4], 4'd4};
				nextstate = STATE_12;
			end
			else if(count1 < M)
			begin
				memReadAddr = {GET_WEGT_BUF[10:4], count1[3:0]};
				nextstate = STATE_COUNT2_LOOP2;
			end
		end
		
		STATE_COUNT2_LOOP2:	//state 8
		begin
			if(memIn[15] == 0)
			begin
				memWriteAddr = {wegtAddr[10:4], count1[3:0]};
				memOut = 32'd2048;
				memWriteEn = 1;
				addOutA = count1;
				addOutB = 1;
				nextcount1 = addIn;
				count1Ld = 1;
				nextstate = STATE_COUNT2_LOOP1;
			end
			else
			begin
				memReadAddr = {GET_WEGT_BUF[10:4], count1[3:0]};
				nextstate = STATE_COUNT2_LOOP3;
				//do stuff
			end
		end
		
		STATE_COUNT2_LOOP3:	//state 9
		begin
			L_multOutA = memIn[15:0];
			L_multOutB = memIn[15:0];
			nexttempAcc = L_multIn;
			tempAccLd = 1;
			nextstate = STATE_COUNT2_LOOP4;
		end
		
		STATE_COUNT2_LOOP4:	//state 10
		begin
			L_shlOutVar1 = tempAcc;
			L_shlNumShiftOut = 16'd2;
			L_shlReady = 1;
			nextstate = STATE_COUNT2_LOOP5;
		end
		
		STATE_COUNT2_LOOP5:	//state 11
		begin
			if(L_shlDone == 1'b0)
				begin
					nextstate = STATE_COUNT2_LOOP5;
				end
			else
				begin
					nexttemp1 = L_shlIn[31:16];
					temp1Ld = 1;
					nextstate = STATE_COUNT2_LOOP6;
				end
		end
		
		STATE_COUNT2_LOOP6:	//state 12
		begin
			L_multOutA = temp1[15:0];
			L_multOutB = CONST10;
			nexttempAcc = L_multIn;
			tempAccLd = 1;
			nextstate = STATE_COUNT2_LOOP7;
		end
		
		STATE_COUNT2_LOOP7:	//state 13
		begin
			L_shlOutVar1 = tempAcc;
			L_shlNumShiftOut = 16'd2;
			L_shlReady = 1;
			nextstate = STATE_COUNT2_LOOP8;
		end
		
		STATE_COUNT2_LOOP8:	//state 14
		begin
			if(L_shlDone == 1'b0)
				begin
					nextstate = STATE_COUNT2_LOOP8;
				end
			else
				begin
					nexttemp1 = L_shlIn[31:16];
					temp1Ld = 1;
					nextstate = STATE_COUNT2_LOOP9;
				end
		end
		
		STATE_COUNT2_LOOP9: //State 15
		begin
			addOutA = temp1;
			addOutB = 16'd2048;
			memWriteAddr = {wegtAddr[10:4], count1[3:0]};
			memOut = addIn[15:0];
			memWriteEn = 1;
			L_addOutA = {28'd0, count1[3:0]};
			L_addOutB = {31'd0, 1'd1};
			nextcount1 = L_addIn[5:0];
			count1Ld = 1;
			nextstate = STATE_COUNT2_LOOP1;
		end
		
		STATE_12:
		begin
			L_multOutA = memIn[15:0];
			L_multOutB = CONST12;
			nexttempAcc = L_multIn;
			tempAccLd = 1;
			nextstate = STATE_SHL1_1;
		end
		
		STATE_SHL1_1:
		begin
			L_shlOutVar1 = tempAcc;
			L_shlNumShiftOut = 16'd1;
			L_shlReady = 1;
			nextstate = STATE_SHL1_2;
		end
		
		STATE_SHL1_2:
		begin
			if(L_shlDone == 1'b0)
				begin
					nextstate = STATE_SHL1_2;
				end
			else
				begin
					memWriteAddr = {wegtAddr[10:4], 4'd4};
					memOut = L_shlIn[31:16];
					memWriteEn = 1;
					nextstate = STATE_15;
				end
		end
		
		STATE_15:
		begin
			memReadAddr = {wegtAddr[10:4], 4'd5};
			nextstate = STATE_16;
		end
		
		STATE_16:
		begin
			L_multOutA = memIn[15:0];
			L_multOutB = CONST12;
			nexttempAcc = L_multIn;
			tempAccLd = 1;
			nextstate = STATE_SHL2_1;
		end
		
		STATE_SHL2_1:
		begin
			L_shlOutVar1 = tempAcc;
			L_shlNumShiftOut = 16'd1;
			L_shlReady = 1;
			nextstate = STATE_SHL2_2;
		end
		
		STATE_SHL2_2:
		begin
			if(L_shlDone == 1'b0)
				begin
					nextstate = STATE_SHL2_2;
				end
			else
				begin
					memWriteAddr = {wegtAddr[10:4], 4'd5};
					memOut = L_shlIn[31:16];
					memWriteEn = 1;
					nexttemp1 = 0;
					temp1Ld = 1;
					nextstate = STATE_COUNT3_LOOP1;
				end
		end
		
		STATE_COUNT3_LOOP1:
		begin
			if(count1 >= M)
			begin
				count1Reset = 1;
				nextstate = STATE_SFT_1;
			end
			else if(count1 < M)
			begin
				memReadAddr = {wegtAddr[10:4], count1[3:0]};
				nextstate = STATE_COUNT3_LOOP2;
			end
		end
		
		STATE_COUNT3_LOOP2:
		begin
			subOutA = memIn[15:0];
			subOutB = temp1[15:0];
			if(subIn[15] == 0)
			begin
				nexttemp1 = memIn[15:0];
				temp1Ld = 1;
			end
			addOutA = count1;
			addOutB = 1;
			nextcount1 = addIn[15:0];
			count1Ld = 1;
			nextstate = STATE_COUNT3_LOOP1;
		end
		
		STATE_SFT_1:
		begin
			norm_sOut = temp1;
			norm_sReady = 1;
			nextstate = STATE_SFT_2;
		end
		
		STATE_SFT_2:
		begin
			norm_sOut = temp1;
			if(norm_sDone == 0)
			begin
				nextstate = STATE_SFT_2;
				norm_sOut = temp1;
			end
			else if(norm_sDone == 1)
			begin
				nexttempSft = norm_sIn[15:0];
				tempSftLd = 1;
				nextstate = STATE_COUNT4_LOOP1;			
			end	
		end
		
		STATE_COUNT4_LOOP1:
		begin
			if(count1 >= M)
			begin
				count1Reset = 1;
				done = 1;
				nextstate = STATE_INIT;
			end
			else if(count1 < M)
			begin
				memReadAddr = {wegtAddr[10:4], count1[3:0]};
				nextstate = STATE_COUNT4_LOOP2;
			end
		end
		
		STATE_COUNT4_LOOP2:
		begin
			L_shlOutVar1 = memIn[15:0];
			L_shlNumShiftOut = tempSft[15:0];
			L_shlReady = 1;
			nextstate = STATE_COUNT4_LOOP3;
		end
		
		STATE_COUNT4_LOOP3:
		begin
			if(L_shlDone == 1'b0)
				begin
					nextstate = STATE_COUNT4_LOOP3;
				end
			else
				begin
					memWriteAddr = {wegtAddr[10:4], count1[3:0]};
					memOut = L_shlIn[15:0];
					memWriteEn = 1;
					addOutA = count1;
					addOutB = 1;
					nextcount1 = addIn;
					count1Ld = 1;
					nextstate = STATE_COUNT4_LOOP1;
				end
		end
		
		default:
		begin
			done = 1;
			nextstate = STATE_INIT;
		end
		
	endcase
end


endmodule
