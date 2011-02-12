`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    18:07:32 02/01/2011 
// Module Name:    Lsp_Expand_2.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "Lsp_Expand_2".
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lsp_Expand_2 (clk,reset,start,subIn,L_subIn,shrIn,addIn,L_addIn,memIn,
							subOutA,subOutB,L_subOutA,L_subOutB,shrVar1Out,shrVar2Out,addOutA,addOutB,L_addOutA,
							L_addOutB,memOut,memReadAddr,memWriteAddr,memWriteEn,done);
`include "paramList.v"

//Inputs
input clk,reset,start;
input [15:0] subIn;
input [31:0] L_subIn;
input [15:0] shrIn;
input [15:0] addIn;
input [31:0] L_addIn;
input [31:0] memIn;

//Outputs
output reg [31:0] memOut;
output reg [15:0] subOutA,subOutB;
output reg [31:0] L_subOutA,L_subOutB;
output reg [15:0] shrVar1Out,shrVar2Out;
output reg [15:0] addOutA,addOutB;
output reg [31:0] L_addOutA,L_addOutB;
output reg [10:0] memReadAddr;
output reg [10:0] memWriteAddr;
output reg memWriteEn;
output reg done;

//Working regs
reg [2:0] state, nextstate;
reg [3:0] j,nextj;
reg jLD,jReset;
reg [15:0] bufj_1,nextbufj_1;
reg bufj_1LD,bufj_1Reset;
reg [15:0] bufj,nextbufj;
reg bufjLD,bufjReset;
reg [15:0] temp,nexttemp;
reg tempLD,tempReset;

//state params
parameter INIT = 3'd0;
parameter FOR_LOOP = 3'd1;
parameter FOR_LOOP_BODY1 = 3'd2;
parameter FOR_LOOP_BODY2 = 3'd3;
parameter FOR_LOOP_BODY3 = 3'd4;
parameter FOR_LOOP_BODY4 = 3'd5;

//other params
// the constant GAP1 is passed into this function in the C-code by the variable "gap"

//Always blocks for working flip-flops

//state flip flop
always @(posedge clk)
begin
	if(reset)
		state <=0;
	else
		state <= nextstate;
end

//for loop count j flip flop		
always @(posedge clk)
begin
	if(reset)
		j <= 5;
	else if(jReset)
		j<=5;
	else if(jLD)
		j<= nextj;
end 		

//memory read temp flipflop		
always @(posedge clk)
begin
	if(reset)
		bufj_1 <= 0;
	else if(bufj_1Reset)
		bufj_1 <= 0;
	else if(bufj_1LD)
		bufj_1 <= nextbufj_1;
end 

always @(posedge clk)
begin
	if(reset)
		bufj <= 0;
	else if(bufjReset)
		bufj <= 0;
	else if(bufjLD)
		bufj <= nextbufj;
end 

//temporary flip flop		
always @(posedge clk)
begin
	if(reset)
		temp <= 0;
	else if(tempReset)
		temp <= 0;
	else if(tempLD)
		temp <= nexttemp;
end 

always@(*)
begin

	nextstate = state;
	nextj = j;
	nextbufj_1 = bufj_1;
	nextbufj = bufj;
	nexttemp = temp;
	jLD = 0;
	bufj_1LD = 0;
	bufjLD = 0;
	tempLD = 0;
	jReset = 0;
	bufj_1Reset = 0;
	bufjReset = 0;
	tempReset = 0;
	memOut = 0;
	subOutA = 0;
	subOutB = 0;
	shrVar1Out = 0;
	shrVar2Out = 0;
	addOutA = 0;
	addOutB = 0;
	L_addOutA = 0;
	L_addOutB = 0;
	L_subOutA = 0;
	L_subOutB = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
	memWriteEn = 0;
	done = 0;
	
	case(state)
		INIT:		//state 0
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin
				jReset = 1;
				bufj_1Reset = 1;
				bufjReset = 1;
				tempReset = 1;
				nextstate = FOR_LOOP;
			end
		end //INIT
		
		//for (j = NC;j<M;j++)
		FOR_LOOP:	//state 1
		begin
			if(j>=10)
			begin
				nextstate = INIT;
				done = 1;
			end
			else
			begin
				subOutA = j;
				subOutB = 1;
				memReadAddr = {RELSPWED_BUF[10:4],subIn[3:0]};
				nextstate = FOR_LOOP_BODY1;
			end
		end//FOR_LOOP1
		
		//gets buf[j-1] out of memory into memTemp
		FOR_LOOP_BODY1:	//state 2
		begin
			nextbufj_1 = memIn;
			bufj_1LD = 1;
			memReadAddr = {RELSPWED_BUF[10:4],j[3:0]};
			nextstate = FOR_LOOP_BODY2;
		end//FOR_LOOP1_BODY1
		
		/*diff = sub( buf[j-1], buf[j] );
		 tmp = shr( add( diff, gap), 1 );*/
		 
		FOR_LOOP_BODY2:		//state 3
		begin
			nextbufj = memIn;
			bufjLD = 1;
			subOutA = bufj_1;
			subOutB = memIn;
			addOutA = subIn;
			addOutB = {11'd0,4'd10};	//GAP = 10;
			shrVar1Out = addIn;
			shrVar2Out = 16'd1;
			nexttemp = shrIn;
			tempLD = 1;
			nextstate = FOR_LOOP_BODY3;
		end//FOR_LOOP_BODY2
		
		/*if ( tmp > 0 ) {
			buf[j-1] = sub( buf[j-1], tmp );*/
		FOR_LOOP_BODY3:		//state 4
		begin
			if(temp[15] != 1)
			begin
				subOutA = bufj_1;
				subOutB = temp;
				L_subOutA = {27'd0,j[3:0]};
				L_subOutB = {30'd0,1'd1};
				memOut = subIn;
				memWriteAddr = {RELSPWED_BUF[10:4],L_subIn[3:0]};
				memWriteEn = 1;
				nextstate = FOR_LOOP_BODY4;
			end
			else
			begin
				addOutA = {11'd0,j[3:0]};
				addOutB = 16'd1;
				nextj = addIn[3:0];
				jLD = 1;
				nextstate = FOR_LOOP;
			end
		end//FOR_LOOP_BODY3
		
		//buf[j]   = add( buf[j], tmp );
		FOR_LOOP_BODY4:		//state 5
		begin
			addOutA = bufj;
			addOutB = temp;
			memOut = addIn;
			memWriteAddr = {RELSPWED_BUF[10:4],j[3:0]};
			memWriteEn = 1;
			L_addOutA = {27'd0,j[3:0]};
			L_addOutB = 32'd1;
			nextj = L_addIn[3:0];
			jLD = 1;
			nextstate = FOR_LOOP;
		end//FOR_LOOP_BODY4
	endcase
end//always

endmodule
