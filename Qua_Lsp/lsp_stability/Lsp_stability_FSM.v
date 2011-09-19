`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    10:46:39 02/11/2011  
// Module Name:    Lsp_stability_FSM  .v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "Lsp_stability".
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lsp_stability_FSM(clk,reset,start,bufAddr,addIn,subIn,L_addIn,L_subIn,memIn,
								 addOutA,addOutB,subOutA,subOutB,L_addOutA,L_addOutB,L_subOutA,L_subOutB,
								 memReadAddr,memWriteAddr,memOut,memWriteEn,done);

//Inputs
input clk,reset,start;
input [11:0] bufAddr;
input [15:0] addIn;
input [15:0] subIn;
input [31:0] L_addIn;
input [31:0] L_subIn;
input [31:0] memIn;

//Outputs
output reg [15:0] addOutA,addOutB;
output reg [15:0] subOutA,subOutB;
output reg [31:0] L_addOutA,L_addOutB;
output reg [31:0] L_subOutA,L_subOutB;
output reg [11:0] memReadAddr;
output reg [11:0] memWriteAddr;
output reg [31:0] memOut;
output reg memWriteEn;
output reg done;

//temp regs
reg [3:0] state, nextstate;
reg [3:0] j,nextj;
reg jLD,jReset;
reg [15:0] temp, nexttemp;
reg tempLD,tempReset;
reg [31:0] L_diff,nextL_diff;
reg L_diffLD,L_diffReset;
reg [31:0] L_acc,nextL_acc;
reg L_accLD,L_accReset;
reg [31:0] L_accB,nextL_accB;
reg L_accBLD,L_accBReset;

//state parameters
parameter INIT = 4'd0;
parameter FOR_LOOP1 = 4'd1;
parameter FOR_LOOP1_BODY1 = 4'd2;
parameter FOR_LOOP1_BODY2 = 4'd3;
parameter FOR_LOOP1_BODY3 = 4'd4;
parameter FOR_LOOP1_BODY4 = 4'd5;
parameter FOR_LOOP1_BODY5 = 4'd6;
parameter FOR_LOOP1_BODY6 = 4'd7;
parameter STABILITY_LOW = 4'd8;
parameter FOR_LOOP2 = 4'd9;
parameter FOR_LOOP2_BODY1 = 4'd10;
parameter FOR_LOOP2_BODY2 = 4'd11;
parameter FOR_LOOP2_BODY3 = 4'd12;
parameter FOR_LOOP2_BODY4 = 4'd13;
parameter FOR_LOOP2_BODY5 = 4'd14;
parameter STABILITY_HIGH = 4'd15;

//Flip flops
//state flip flop
always @(posedge clk)
begin
	if(reset)
		state <= INIT;
	else
		state <= nextstate;
end

//j flip flop
always @(posedge clk)
begin
	if(reset)
		j <= 0;
	else if(jReset)
		j <= 0;
	else if(jLD)
		j <= nextj;	
end

//temp flip flop
always @(posedge clk)
begin
	if(reset)
		temp <= 0;
	else if(tempReset)
		temp <= 0;
	else if(tempLD)
		temp <= nexttemp;	
end

//L_diff flip flop
always @(posedge clk)
begin
	if(reset)
		L_diff <= 0;
	else if(L_diffReset)
		L_diff <= 0;
	else if(L_diffLD)
		L_diff <= nextL_diff;	
end

//L_acc flip flop
always @(posedge clk)
begin
	if(reset)
		L_acc <= 0;
	else if(L_accReset)
		L_acc <= 0;
	else if(L_accLD)
		L_acc <= nextL_acc;	
end

//L_accB flip flop
always @(posedge clk)
begin
	if(reset)
		L_accB <= 0;
	else if(L_accBReset)
		L_accB <= 0;
	else if(L_accBLD)
		L_accB <= nextL_accB;	
end

always @(*)
begin
	nextstate = state;
	nextj = j;
	nexttemp = temp;
	nextL_diff = L_diff;
	nextL_acc = L_acc;
	nextL_accB = L_accB;
	jLD = 0;
	tempLD = 0;
	L_diffLD = 0;
	L_accLD = 0;
	L_accBLD = 0;
	jReset = 0;
	tempReset = 0;
	L_diffReset = 0;
	L_accReset = 0;
	L_accBReset = 0;
	addOutA = 0;
	addOutB = 0;
	subOutA = 0;
	subOutB = 0;
	L_addOutA = 0;
	L_addOutB = 0;
	L_subOutA = 0;
	L_subOutB = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
	memOut = 0;
	memWriteEn = 0;
	done = 0;
	
	case(state)
		INIT:		//state 0
		begin
			jReset = 1;
			tempReset = 1;
			L_diffReset = 1;
			L_accReset = 1;
			L_accBReset = 1;
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
				nextstate = FOR_LOOP1;
		end//INIT
		
		// for(j=0; j<M-1; j++) {
		FOR_LOOP1:	//state 1
		begin
			if(j>=9)
			begin
				nextstate = STABILITY_LOW;
				memReadAddr = {bufAddr[11:4],4'd0};
			end
			else if(j<9)
			begin
				addOutA = {12'd0,j[3:0]};
				addOutB = 16'd1;
				memReadAddr = {bufAddr[11:4],addIn[3:0]};
				nextstate = FOR_LOOP1_BODY1;
			end
		end//FOR_LOOP1
		
		//L_acc = L_deposit_l( buf[j+1] );
		FOR_LOOP1_BODY1:	//state 2
		begin
			if(memIn[15] == 1)
				nextL_acc = {16'hffff,memIn[15:0]};
			else if(memIn[15] == 0)
				nextL_acc = {16'd0,memIn[15:0]};
			L_accLD = 1;
			memReadAddr = {bufAddr[11:4],j[3:0]};
			nextstate = FOR_LOOP1_BODY2;
		end//FOR_LOOP1_BODY1
		
		/*L_accb = L_deposit_l( buf[j] );
		  L_diff = L_sub( L_acc, L_accb );
        if( L_diff < 0L ) {
		*/
		FOR_LOOP1_BODY2:		//state 3
		begin
			if(memIn[15] == 1)
				nextL_accB = {16'hffff,memIn[15:0]};
			else if(memIn[15] == 0)
				nextL_accB = {16'd0,memIn[15:0]};
			L_accBLD = 1;
			L_subOutA = L_acc;
			L_subOutB = nextL_accB;
			nextL_diff = L_subIn;
			L_diffLD = 1;
			if(nextL_diff[31] == 1)
				nextstate = FOR_LOOP1_BODY3;
			else
			begin
				addOutA = {12'd0,j[3:0]};
				addOutB = 16'd1;
				nextj = addIn[3:0];
				jLD = 1;
				nextstate = FOR_LOOP1;
			end
		end//FOR_LOOP1_BODY2
		
		//next two states perform  
		//tmp = buf[j+1];
		FOR_LOOP1_BODY3:		//state 4
		begin
			addOutA = {12'd0,j[3:0]};
			addOutB = 16'd1;
			memReadAddr = {bufAddr[11:4],addIn[3:0]};
			nextstate = FOR_LOOP1_BODY4;
		end//FOR_LOOP1_BODY3
		
		FOR_LOOP1_BODY4:		//state 5
		begin
			nexttemp = memIn;
			tempLD = 1;
			memReadAddr = {bufAddr[11:4],j[3:0]};
			nextstate = FOR_LOOP1_BODY5;
		end//FOR_LOOP1_BODY4
		
		//buf[j+1] = buf[j];
		FOR_LOOP1_BODY5:		//state 6
		begin
			addOutA = {12'd0,j[3:0]};
			addOutB = 16'd1;
			memWriteAddr = {bufAddr[11:4],addIn[3:0]};
			memOut = memIn;
			memWriteEn = 1;
			nextstate = FOR_LOOP1_BODY6;
		end//FOR_LOOP1_BODY5
		
		//buf[j] = tmp;
		FOR_LOOP1_BODY6:		//state 7
		begin
			memWriteAddr = {bufAddr[11:4],j[3:0]};
			memOut = temp;
			memWriteEn = 1;
			addOutA = {12'd0,j[3:0]};
			addOutB = 16'd1;
			nextj = addIn[3:0];
			jLD = 1;
			nextstate = FOR_LOOP1;
		end//FOR_LOOP1_BODY6
		
		/*if( sub(buf[0], L_LIMIT) <0 ) {
		  buf[0] = L_LIMIT;*/
		STABILITY_LOW:		//state 8
		begin
			subOutA = memIn[15:0];
			subOutB = 16'd40;
			if(subIn[15] == 1)
			begin
				memWriteAddr = {bufAddr[11:4],4'd0};
				memOut = 31'd40;
				memWriteEn = 1;
			end
			jReset = 1;
			nextstate = FOR_LOOP2;
		end//STABILITY_LOW
		
		// for(j=0; j<M-1; j++) {
		FOR_LOOP2:	//state 9
		begin
			if(j>=9)
			begin
				nextstate = STABILITY_HIGH;
				memReadAddr = {bufAddr[11:4],4'd9};
			end
			else if(j<9)
			begin
				addOutA = {12'd0,j[3:0]};
				addOutB = 16'd1;
				memReadAddr = {bufAddr[11:4],addIn[3:0]};
				nextstate = FOR_LOOP2_BODY1;
			end
		end//FOR_LOOP2
		
		//L_acc = L_deposit_l( buf[j+1] );
		FOR_LOOP2_BODY1:	//state 10
		begin
			if(memIn[15] == 1)
				nextL_acc = {16'd1,memIn[15:0]};
			else if(memIn[15] == 0)
				nextL_acc = {16'd0,memIn[15:0]};
			L_accLD = 1;
			memReadAddr = {bufAddr[11:4],j[3:0]};
			nextstate = FOR_LOOP2_BODY2;
		end//FOR_LOOP2_BODY1
		
		/*L_accb = L_deposit_l( buf[j] );
		  L_diff = L_sub( L_acc, L_accb );
        if( L_sub(L_diff, GAP3)<0L ) {
		*/
		FOR_LOOP2_BODY2:		//state 11
		begin
			if(memIn[15] == 1)
				nextL_accB = {16'd1,memIn[15:0]};
			else if(memIn[15] == 0)
				nextL_accB = {16'd0,memIn[15:0]};
			L_accBLD = 1;
			L_subOutA = L_acc;
			L_subOutB = nextL_accB;
			nextL_diff = L_subIn;
			L_diffLD = 1;			
			nextstate = FOR_LOOP2_BODY3;
		end//FOR_LOOP2_BODY2
		
		//if( L_sub(L_diff, GAP3)<0L )
		FOR_LOOP2_BODY3:		//state 12
		begin
			L_subOutA = L_diff;
			L_subOutB = 32'd321;
			if(L_subIn[31] == 1)
			begin
				memReadAddr = {bufAddr[11:4],j[3:0]};
				nextstate = FOR_LOOP2_BODY4;
			end
			else
			begin
			addOutA = {12'd0,j[3:0]};
			addOutB = 16'd1;
			nextj = addIn[3:0];
			jLD = 1;
			nextstate = FOR_LOOP2;
			end
		end//FOR_LOOP2_BODY3:
		
		//buf[j+1] = add( buf[j], GAP3 );
		FOR_LOOP2_BODY4:		//state 13
		begin
			addOutA = memIn[15:0];
			addOutB = 16'd321;
			memOut = {16'd0,addIn[15:0]};
			L_addOutA = {27'd0,j[3:0]};
			L_addOutB = 32'd1;
			memWriteAddr = {bufAddr[11:4],L_addIn[3:0]};
			memWriteEn = 1;
			nextstate  = FOR_LOOP2_BODY5;
		end//FOR_LOOP2_BODY4
		
		//j++
		FOR_LOOP2_BODY5:		//state 14
		begin
			addOutA = {12'd0,j[3:0]};
			addOutB = 16'd1;
			nextj = addIn[3:0];
			jLD = 1;
			nextstate = FOR_LOOP2;
		end//FOR_LOOP2_BODY5
		
		/*if( sub(buf[M-1],M_LIMIT)>0 ) {
       buf[M-1] = M_LIMIT;*/
		STABILITY_HIGH:		//state 15
		begin
			subOutA = memIn[15:0];
			subOutB = 16'd25681;
			if(subIn[15] == 0)
			begin
				memWriteAddr = {bufAddr[11:4],4'd9};
				memOut = 32'd25681;
				memWriteEn = 1;
			end
			done = 1;
			nextstate = INIT;
		end//STABILITY_HIGH
	endcase
end//always

endmodule
