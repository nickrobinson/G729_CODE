`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    20:39:16 03/30/2011 
// Module Name:    Cor_h_X.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "Cor_h_X".
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Cor_h_X(clk,reset,start,L_macIn,L_absIn,L_subIn,addIn,norm_lIn,norm_lDone,subIn,L_shrIn,
					memIn,L_macOutA,L_macOutB,L_macOutC,L_absOut,L_subOutA,L_subOutB,addOutA,addOutB,
					norm_lVar1Out,norm_lReady,subOutA,subOutB,L_shrVar1Out,L_shrNumShiftOut,memReadAddr,
					memWriteAddr,memOut,memWriteEn,done);
`include "paramList.v"						

//Inputs
input clk,reset,start;
input [31:0] L_macIn;
input [31:0] L_absIn;
input [31:0] L_subIn;
input [15:0] addIn;
input [15:0] norm_lIn;
input norm_lDone;
input [15:0] subIn;
input [31:0] L_shrIn;
input [31:0] memIn;

//Outputs
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;
output reg [31:0] L_absOut;
output reg [31:0] L_subOutA,L_subOutB;
output reg [15:0] addOutA,addOutB;
output reg [31:0] norm_lVar1Out;
output reg norm_lReady;
output reg [15:0] subOutA,subOutB;
output reg [31:0] L_shrVar1Out;
output reg [15:0] L_shrNumShiftOut;
output reg [11:0] memReadAddr,memWriteAddr;
output reg [31:0] memOut;
output reg memWriteEn;
output reg done;

//Internal regs
reg [3:0] state,nextstate;
reg [15:0] i,nexti;
reg iLD,iReset;
reg [15:0] j,nextj;
reg jLD,jReset;
reg [31:0] s,nexts;
reg sLD,sReset;
reg [31:0] max,nextmax;
reg maxLD,maxReset;
reg [31:0] L_temp,nextL_temp;
reg L_tempLD,L_tempReset;

//State parameters
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
parameter S10 = 4'd10;
parameter S11 = 4'd11;
parameter S12 = 4'd12;
parameter S13 = 4'd13;
parameter S14 = 4'd14;
parameter S15 = 4'd15;

//Flip Flops

//State FF
always @(posedge clk)
begin
	if(reset)
		state <= 0;
	else
		state <=nextstate;
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
		j <= 0;
	else if(jReset)
		j <= 0;
	else if(jLD)
		j <= nextj;
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

always @(posedge clk)
begin
	if(reset)
		max <= 0;
	else if(maxReset)
		max <= 0;
	else if(maxLD)
		max <= nextmax;
end

always @(posedge clk)
begin
	if(reset)
		L_temp <= 0;
	else if(L_tempReset)
		L_temp <= 0;
	else if(L_tempLD)
		L_temp <= nextL_temp;
end

always @(*)
begin
	nextstate = state;
	nexti = i;
	nextj = j;	
	nexts = s;
	nextmax = max;
	nextL_temp = L_temp;
	iReset = 0;
	jReset = 0;
	sReset = 0;
	maxReset = 0;
	L_tempReset = 0;
	iLD = 0;
	jLD = 0;
	sLD = 0;
	maxLD = 0;
	L_tempLD = 0;
	L_macOutA = 0;
	L_macOutB = 0;
	L_macOutC = 0;
	L_absOut = 0;
	L_subOutA = 0;
	L_subOutB = 0;;
	addOutA = 0;
	addOutB = 0;
	norm_lVar1Out = 0;
	norm_lReady = 0;
	subOutA = 0;
	subOutB = 0;
	L_shrVar1Out = 0;
	L_shrNumShiftOut = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
	memOut = 0;
	memWriteEn = 0;
	done = 0;
	
	case(state)
		INIT:
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin
				iReset = 1;
				jReset = 1;
				sReset = 1;
				maxReset = 1;
				L_tempReset = 1;
				nextstate = S1;
			end
		end//INIT
		/* for (i = 0; i < L_SUBFR; i++){
		   s = 0; */
		S1:
		begin
			if(i>=40)
				nextstate = S7;
			else if(i<40)
			begin
				nextj = i;
				jLD = 1;
				sReset = 1;
				nextstate = S2;
			end
		end//S1
		
		//for (j = i; j <  L_SUBFR; j++)
		S2:
		begin
			if(j>=40)
				nextstate = S5;
			else if(j<40)
			begin				
				subOutA = j;
				subOutB = i;
				memReadAddr = {H1[11:6],subIn[5:0]};
				nextstate = S3;
			end
		end//S2
		
		S3:
		begin
			nextL_temp = memIn[15:0];
			L_tempLD = 1;
			memReadAddr = {XN2[11:6],j[5:0]};
			nextstate = S4;
		end//S3
		
		//s = L_mac(s, X[j], h[j-i]);
		S4:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = L_temp[15:0];
			L_macOutC = s;
			nexts = L_macIn;
			sLD = 1;
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S2;
		end//S4
		
		/* y32[i] = s;
         s = L_abs(s); */
		S5:
		begin
			memOut = s;
			memWriteAddr = {COR_H_X_Y32[11:6],i[5:0]};
			memWriteEn = 1;
			L_absOut = s;
			nexts = L_absIn;
			sLD = 1;
			nextstate = S6;
		end//S5
		
		/*  L_temp =L_sub(s,max);
			 if(L_temp>0L) {
          max = s;} */
		S6:
		begin
			L_subOutA = s;
			L_subOutB = max;
			nextL_temp = L_subIn;
			L_tempLD = 1;
			if((L_subIn[31] == 0) && (L_subIn != 0))
			begin
				nextmax = s;
				maxLD = 1;
			end
			addOutA = i;
			addOutB = 16'd1;
			nexti = addIn;
			iLD = 1;
			nextstate = S1;
		end//S6		
		
		S7:
		begin
			norm_lVar1Out = max;
			norm_lReady = 1;
			if(norm_lDone == 1)
				nextstate = S9;
			else
				nextstate = S8;
			
		end//S7
		
		/* j = norm_l(max); */
		S8:
		begin
			norm_lVar1Out = max;
			if(norm_lDone == 1)
			begin				
				nextj = norm_lIn;
				jLD = 1;
				nextstate = S9;
			end
			else if(norm_lDone == 0)
				nextstate = S8;
		end//S8
		
		/* if( sub(j,16) > 0) {
				j = 16;} */
		S9:
		begin
			subOutA = j;
			subOutB = 16'd16;
			if((subIn[15] == 0) && (subIn != 0))
			begin
				nextj = 16;
				jLD = 1;
			end
			nextstate = S10;
		end//S9
		
		//j = sub(18, j);
		S10:
		begin
			subOutA = 18;
			subOutB = j;
			nextj = subIn;
			jLD = 1;
			iReset = 1;
			nextstate = S11;
		end//S10
		
		//for(i=0; i<L_SUBFR; i++) 
		S11:
		begin
			if(i>=40)
			begin
				nextstate = INIT;
				done = 1;
			end
			else if(i<40)
			begin
				memReadAddr = {COR_H_X_Y32[11:6],i[5:0]};
				nextstate = S12;
			end
		end//S11
		
		// D[i] = extract_l( L_shr(y32[i], j) );
		S12:
		begin
			L_shrVar1Out = memIn;
			L_shrNumShiftOut = j;
			memOut = L_shrIn[15:0];
			memWriteAddr = {ACELP_DN[11:6],i[5:0]};
			memWriteEn = 1;
			addOutA = i;
			addOutB = 16'd1;
			nexti = addIn;
			iLD = 1;
			nextstate = S11;
		end//S12
	endcase
end//always

endmodule
