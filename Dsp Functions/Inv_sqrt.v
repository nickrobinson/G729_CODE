`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:15:12 03/01/2011 
// Module Name:    Inv_sqrt.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an module to implement the "Inv_sqrt" function
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Inv_sqrt(clk,start,reset,L_xAddr,L_yAddr,norm_lIn,norm_lDone,L_shlIn,L_shlDone,subIn,L_shrIn,shrIn,
					 addIn,L_msuIn,memIn,constantMemIn,norm_lVar1Out,norm_lReady,L_shlVar1Out,L_shlNumShiftOut,
					 L_shlReady,subOutA,subOutB,L_shrVar1Out,L_shrNumShiftOut,shrVar1Out,shrVar2Out,addOutA,
					 addOutB,L_msuOutA,L_msuOutB,L_msuOutC,memWriteEn,memReadAddr,memWriteAddr,memOut,
					 constantMemAddr,done);
					 
`include "constants_param_list.v"

//Inputs	 
input clk,start,reset;
input [10:0] L_xAddr;
input [10:0] L_yAddr;
input [15:0] norm_lIn;
input norm_lDone;
input [31:0] L_shlIn;
input L_shlDone;
input [15:0] subIn;
input [31:0] L_shrIn;
input [15:0] shrIn;
input [15:0] addIn;
input [31:0] L_msuIn;
input [31:0] memIn;
input [31:0] constantMemIn;

//Outputs
output reg [31:0] norm_lVar1Out;
output reg norm_lReady;
output reg [31:0] L_shlVar1Out; 
output reg [15:0] L_shlNumShiftOut;
output reg L_shlReady;
output reg [15:0] subOutA,subOutB;
output reg [31:0] L_shrVar1Out;
output reg [15:0] L_shrNumShiftOut;
output reg [15:0] shrVar1Out,shrVar2Out;
output reg [15:0] addOutA,addOutB;
output reg [15:0] L_msuOutA,L_msuOutB;
output reg [31:0] L_msuOutC;
output reg memWriteEn;
output reg [10:0] memReadAddr,memWriteAddr;
output reg [31:0] memOut;
output reg [11:0] constantMemAddr;
output reg done;

//internal regs
reg [3:0] state,nextstate;
reg [15:0] exp,nextexp;
reg expLD,expReset;
reg [15:0] i,nexti;
reg iLD,iReset;
reg [15:0] temp,nexttemp;
reg tempLD,tempReset;
reg [15:0] a,nexta;
reg aLD,aReset;
reg [31:0] L_y,nextL_y;
reg L_yLD, L_yReset;
reg [31:0] L_x,nextL_x;
reg L_xLD, L_xReset;

//state parameters
parameter INIT = 4'd0;
parameter S1 = 4'd1;
parameter S2 = 4'd2;
parameter S3 = 4'd3;
parameter S4 = 4'd4;
parameter S5 = 4'd5;
parameter S6 = 4'd6;
parameter S7 = 4'd7;
parameter S8 = 4'd8;
parameter S9 = 4'd9;

//Flip flops
//state FF

always @(posedge clk)
begin
 if(reset)
	state <= INIT;
 else
	state <= nextstate;
end

//exp FF
always @(posedge clk)
begin
	if(reset)
		exp <= 0;
	else if(expReset)
		exp <= 0;
	else if(expLD)
		exp <= nextexp;
end

//i counter FF
always @(posedge clk)
begin
	if(reset)
		i <= 0;
	else if(iReset)
		i <= 0;
	else if(iLD)
		i <= nexti;
end

//"a" FF
always @(posedge clk)
begin
	if(reset)
		a <= 0;
	else if(aReset)
		a <= 0;
	else if(aLD)
		a <= nexta;
end

//temp FF
always @(posedge clk)
begin
	if(reset)
		temp <= 0;
	else if(tempReset)
		temp <= 0;
	else if(tempLD)
		temp <= nexttemp;
end

//L_y FF
always @(posedge clk)
begin
	if(reset)
		L_y <= 0;
	else if(L_yReset)
		L_y <= 0;
	else if(L_yLD)
		L_y <= nextL_y;
end

//L_x FF
always @(posedge clk)
begin
	if(reset)
		L_x <= 0;
	else if(L_xReset)
		L_x <= 0;
	else if(L_xLD)
		L_x <= nextL_x;
end

always @(*)
begin

	nextstate = state;
	nextexp = exp;
	nexti = i;
	nexttemp = temp;
	nexta = a;
	nextL_y = L_y;
	nextL_x = L_x;
	expLD = 0;
	iLD = 0;
	tempLD = 0;
	aLD = 0;
	L_yLD = 0;
	L_xLD = 0;
	expReset = 0;
	iReset = 0;
	tempReset = 0;
	aReset = 0;
	L_yReset = 0;
	L_xReset = 0;
	norm_lVar1Out = 0;
	norm_lReady = 0;
	L_shlVar1Out = 0; 
	L_shlNumShiftOut = 0;
	L_shlReady = 0;
	subOutA = 0;
	subOutB = 0;
	L_shrVar1Out = 0;
	L_shrNumShiftOut = 0;
	shrVar1Out = 0;
	shrVar2Out = 0;
	addOutA = 0;
	addOutB = 0;
	L_msuOutA = 0;
	L_msuOutB = 0;
	L_msuOutC = 0;
	constantMemAddr = 0;
	memWriteEn = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
	memOut = 0;
	done = 0;
	
	case(state)
	
		INIT:
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin				
				expReset = 1;
				iReset = 1;
				tempReset = 1;
				aReset = 1;
				L_yReset = 1;
				L_xReset = 1;
				memReadAddr = L_xAddr;
				nextstate = S1;
			end
		end//INIT
		
		/*if( L_x <= (Word32)0)	
			return ( (Word32)0x3fffffffL);*/
		S1:
		begin
			nextL_x = memIn;
			L_xLD = 1;
			if(memIn[31] == 1 || memIn == 32'd0)
			begin				
				memOut = 32'h3fff_ffff;
				memWriteEn = 1;
				memWriteAddr = L_yAddr;
				done = 1;
				nextstate = INIT;
			end
			
			else if(memIn[31] == 0 && memIn != 32'd0)
			begin
				norm_lVar1Out = memIn;
				norm_lReady = 1;
				nextstate = S2;
			end
		end//S1
		
		//exp = norm_l(L_x);
		S2:
		begin
			norm_lReady = 1;
			norm_lVar1Out = L_x;
			if(norm_lDone == 0)
				nextstate = S2;
			else if(norm_lDone == 1)
			begin
				norm_lReady = 0;
				nextexp = norm_lIn;
				expLD = 1;
				L_shlVar1Out = L_x;
				L_shlNumShiftOut = norm_lIn;
				L_shlReady = 1;
				nextstate = S3;
			end
		end//S2
		
		/*L_x = L_shl(L_x, exp );
		  exp = sub(30, exp);*/
		S3:
		begin
			L_shlVar1Out = L_x;
			L_shlNumShiftOut = exp;
			L_shlReady = 1;
			if(L_shlDone == 0)
				nextstate = S3;
			else if(L_shlDone == 1)
			begin
				L_shlReady = 0;
				nextL_x = L_shlIn;
				L_xLD = 1;
				subOutA = 16'd30;
				subOutB = exp;
				nextexp = subIn;
				expLD = 1;
				nextstate = S4;
			end
		end//S3
		
		/*if( (exp & 1) == 0 )
			 L_x = L_shr(L_x, 1);
		 exp = shr(exp, 1);
		 exp = add(exp, 1);*/
		S4:
		begin
			if((exp & 1) == 16'd0)
			begin
				L_shrVar1Out = L_x;
				L_shrNumShiftOut = 16'd1;
				nextL_x = L_shrIn;
				L_xLD = 1;
			end
			shrVar1Out = exp;
			shrVar2Out = 16'd1;
			addOutA = shrIn;
			addOutB = 16'd1;
			nextexp = addIn;
			expLD = 1;
			nextstate = S5;
		end//S4
		
		 /*L_x = L_shr(L_x, 9);
			i   = extract_h(L_x);*/                 
		S5: 
		begin
			L_shrVar1Out = L_x;
			L_shrNumShiftOut = 32'd9;
			nextL_x = L_shrIn;
			L_xLD = 1;
			nexti = L_shrIn[31:16];
			iLD = 1;
			nextstate = S6;
		end//S5
		
		/*L_x = L_shr(L_x, 1);
		  a   = extract_l(L_x);                
		  a   = a & (Word16)0x7fff;
        i   = sub(i, 16);*/
		S6:
		begin
			L_shrVar1Out = L_x;
			L_shrNumShiftOut = 32'd1;
			nextL_x = L_shrIn;
			L_xLD = 1;
			nexta = L_shrIn[15:0] & 16'h7fff;
			aLD = 1;
			subOutA = i;
			subOutB = 16'd16;
			nexti = subIn;
			iLD = 1;
			constantMemAddr = {TABSQR[11:6],nexti[5:0]};
			nextstate = S7;		
		end//S6
		
		//L_y = L_deposit_h(tabsqr[i]); 
		S7:
		begin
			nexttemp = constantMemIn[15:0];
			tempLD = 1;
			nextL_y = {constantMemIn[15:0],16'd0};
			L_yLD = 1;
			addOutA = i;
			addOutB = 16'd1;
			constantMemAddr = {TABSQR[11:6],addIn[5:0]};
			nextstate = S8;
		end//S7
		
		/*tmp = sub(tabsqr[i], tabsqr[i+1]); 
		  L_y = L_msu(L_y, tmp, a); 
		  L_y = L_shr(L_y, exp); */
		S8:
		begin
			subOutA = temp;
			subOutB = constantMemIn;
			L_msuOutA = subIn;
			L_msuOutB = a;
			L_msuOutC = L_y;
			L_shrVar1Out = L_msuIn;
			L_shrNumShiftOut = exp;
			memWriteAddr = L_yAddr;
			memOut = L_shrIn;
			memWriteEn = 1;
			nextstate = S9;
		end//S8
		
		S9:
		begin
			memWriteAddr = L_xAddr;
			memOut = L_x;
			memWriteEn = 1;
			done = 1;
			nextstate = INIT;
		end//S9
	endcase
end//always

endmodule
