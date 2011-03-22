`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:52:39 03/03/2011 
// Module Name:    lsf_lsp2FSM.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "lsf_lsp2"
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lsf_lsp2FSM(start,clk,reset,lsfAddr,lspAddr,multIn,shrIn,subIn,L_multIn,addIn,L_shrIn,constantMemIn,memIn,
						 multOutA,multOutB,shrVar1Out,shrVar2Out,subOutA,subOutB,L_multOutA,L_multOutB,
						 addOutA,addOutB,L_shrVar1Out,L_shrNumShiftOut,constantMemAddr,memReadAddr,memWriteAddr,
						 memOut,memWriteEn,done);
`include "constants_param_list.v"

//Inputs
input start,clk,reset;
input [11:0] lsfAddr,lspAddr;
input [15:0] multIn;
input [15:0] shrIn;
input [15:0] subIn;
input [31:0] L_multIn;
input [15:0] addIn;
input [31:0] L_shrIn;
input [31:0] constantMemIn;
input [31:0] memIn;

//Outputs
output reg [15:0] multOutA,multOutB;
output reg [15:0] shrVar1Out,shrVar2Out;
output reg [15:0] subOutA,subOutB;
output reg [15:0] L_multOutA,L_multOutB;
output reg [15:0] addOutA,addOutB;
output reg [31:0] L_shrVar1Out;
output reg [15:0] L_shrNumShiftOut;
output reg [11:0] constantMemAddr;
output reg [11:0] memReadAddr,memWriteAddr;
output reg [31:0] memOut;
output reg memWriteEn;
output reg done;

//internal regs
reg [2:0] state,nextstate;
reg [3:0] i,nexti;
reg iLD,iReset;
reg [15:0] ind,nextind;
reg indLD,indReset;
reg [15:0] offset,nextoffset;
reg offsetLD,offsetReset;
reg [31:0] L_temp,nextL_temp;
reg L_tempLD,L_tempReset;

//State parameters
parameter INIT = 3'd0;
parameter S1 = 3'd1;
parameter S2 = 3'd2;
parameter S3 = 3'd3;
parameter S4 = 3'd4;
parameter S5 = 3'd5;

//Flip Flops

//State FF
always @(posedge clk)
begin
	if(reset)
		state <= 0;
	else
		state <= nextstate;
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

//ind FF
always @(posedge clk)
begin
	if(reset)
		ind <= 0;
	else if(indReset)
		ind <= 0;
	else if(indLD)
		ind <= nextind;
end

//offset FF
always @(posedge clk)
begin
	if(reset)
		offset <= 0;
	else if(offsetReset)
		offset <= 0;
	else if(offsetLD)
		offset <= nextoffset;
end

//L_temp FF
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
	nextind = ind;
	nextoffset = offset;
	nextL_temp = L_temp;
	iLD = 0;
	indLD = 0;
	offsetLD = 0;
	L_tempLD = 0;
	iReset = 0;
	indReset = 0;
	offsetReset = 0;
	L_tempReset = 0;	
	multOutA = 0;
	multOutB = 0;
	shrVar1Out = 0;
	shrVar2Out = 0;
	subOutA = 0;
	subOutB = 0;
	L_multOutA = 0;
	L_multOutB = 0;
	addOutA = 0;
	addOutB = 0;
	L_shrVar1Out = 0;
	L_shrNumShiftOut = 0;
	constantMemAddr = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
	memOut = 0;
	memWriteEn = 0;
	done = 0;
	
	case(state)
		INIT:
		begin
			if(start == 0)
			begin
				nextstate = INIT;
				iReset = 1;
				indReset = 1;
				offsetReset = 1;
				L_tempReset = 1;
			end
			else if(start == 1)
			begin				
				memReadAddr = {lsfAddr[10:4],i[3:0]};
				nextstate = S1;
			end
		end	//INIT
		
		/* for(i=0; i<m; i++)
				freq = mult(lsf[i], 20861);          
				ind    = shr(freq, 8);               
				offset = freq & (Word16)0x00ff;*/
		S1:
		begin
			if(i>=10)
			begin
				nextstate = INIT;
				done = 1;
			end
			else if(i<10)
			begin
				multOutA = memIn[15:0];
				multOutB = 16'd20861;
				shrVar1Out = multIn;
				shrVar2Out = 16'd8;
				nextind = shrIn;
				indLD = 1;
				nextoffset = multIn & 16'h00ff;
				offsetLD = 1;
				nextstate = S2;
			end
		end //S1
		
		/*if ( sub(ind, 63)>0 ){
      ind = 63;}*/
		S2:
		begin
			subOutA = ind;
			subOutB = 16'd63;
			if(subIn[15] == 0)
			begin
				nextind = 16'd63;
				indLD = 1;
			end
			constantMemAddr = {SLOPE_COS[11:6],nextind[5:0]};
			nextstate = S3;
		end//S2
		
		//L_tmp   = L_mult(slope_cos[ind], offset);
		S3:
		begin
			L_multOutA = constantMemIn[15:0];
			L_multOutB = offset;
			nextL_temp = L_multIn;
			L_tempLD = 1;
			constantMemAddr = {TABLE2[11:6],ind[5:0]};
			nextstate = S4;
		end//S3
		
		//lsp[i] = add(table2[ind], extract_l(L_shr(L_tmp, 13)));}
		S4:
		begin
			L_shrVar1Out = L_temp;
			L_shrNumShiftOut = 32'd13;
			addOutA = constantMemIn[15:0];
			addOutB = L_shrIn[15:0];
			if(addIn[15] == 0)
				memOut = addIn;
			else if(addIn[15] == 1)
				memOut = {16'hffff,addIn[15:0]};
			memWriteAddr = {lspAddr[10:4],i[3:0]};
			memWriteEn = 1;
			nextstate = S5;
		end//S4
		
		S5:
		begin
			addOutA = {12'd0,i[3:0]};
			addOutB = 16'd1;
			nexti = addIn;
			iLD = 1;
			nextstate = S1;
			memReadAddr = {lsfAddr[10:4],nexti[3:0]};
		end//S5
	endcase


end//always

endmodule
