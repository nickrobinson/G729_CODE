`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    17:07:48 02/28/2011 
// Module Name:    lsp_lsf2FSM.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "lsp_lsf2"
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lsp_lsf2FSM(start,clk,reset,subIn,L_subIn,L_multIn,addIn,shlIn,L_shrIn,multIn,memIn,
						 constantMemIn,lspAddr,lsfAddr,subOutA,subOutB,L_subOutA,L_subOutB,L_multOutA,L_multOutB,
						 addOutA,addOutB,shlOutA,shlOutB,L_shrVar1Out,L_shrNumShiftOut,multOutA,multOutB,
						 shlVar1Out,shlVar2Out,memReadAddr,memWriteAddr,memOut,memWriteEn,constantMemAddr,done);
`include "constants_param_list.v"
//Inputs
input start,clk,reset;
input [15:0] subIn;
input [31:0] L_subIn;
input [31:0] L_multIn;
input [15:0] addIn;
input [15:0] shlIn;
input [31:0] L_shrIn;
input [15:0] multIn;
input [31:0] memIn;
input [31:0] constantMemIn;
input [11:0] lspAddr;
input [11:0] lsfAddr;

//Outputs
output reg [15:0] subOutA,subOutB;
output reg [31:0] L_subOutA,L_subOutB;
output reg [15:0] L_multOutA,L_multOutB;
output reg [15:0] addOutA,addOutB;
output reg [15:0] shlOutA,shlOutB;
output reg [31:0] L_shrVar1Out;
output reg [15:0] L_shrNumShiftOut;
output reg [15:0] multOutA,multOutB;
output reg [15:0] shlVar1Out,shlVar2Out;
output reg [11:0] memReadAddr;
output reg [11:0] memWriteAddr;
output reg [31:0] memOut;
output reg memWriteEn;
output reg [11:0] constantMemAddr;
output reg done;

//Temp regs
reg [2:0] state,nextstate;
reg [31:0] L_temp,nextL_temp;
reg L_tempLD,L_tempReset;
reg [15:0] temp,nexttemp;
reg tempLD,tempReset;
reg [15:0] offset,nextoffset;
reg offsetLD,offsetReset;
reg [5:0] ind,nextind;
reg indLD,indReset;
reg [3:0] i,nexti;
reg iLD,iReset;

//State parameters

parameter INIT = 3'd0;
parameter S1 = 3'd1;
parameter S2 = 3'd2;
parameter S3 = 3'd3;
parameter S4 = 3'd4;
parameter S5 = 3'd5;
parameter S6 = 3'd6;

//Flip flops
//state flip flop
always @(posedge clk)
begin
	if(reset)
		state <= 0;
	else
		state <= nextstate;
end

//L_temp flip flop
always @(posedge clk)
begin
	if(reset)
		L_temp <= 0;
	else if(L_tempReset)
		L_temp <= 0;
	else if(L_tempLD)
		L_temp <=nextL_temp;
end

//temp flip flop
always @(posedge clk)
begin
	if(reset)
		temp <= 0;
	else if(tempReset)
		temp <= 0;
	else if(tempLD)
		temp <=nexttemp;
end

//temp flip flop
always @(posedge clk)
begin
	if(reset)
		offset <= 0;
	else if(offsetReset)
		offset <= 0;
	else if(offsetLD)
		offset <=nextoffset;
end

//ind flip flop
always @(posedge clk)
begin
	if(reset)
		ind <= 6'd63;
	else if(indReset)
		ind <= 6'd63;
	else if(indLD)
		ind <= nextind;
end

//i flip flop
always @(posedge clk)
begin
	if(reset)
		i <= 4'd9;
	else if(iReset)
		i <= 4'd9;
	else if(iLD)
		i <= nexti;
end

always @(*)
begin
	nextstate = state;
	nexti = i;
	nextind = ind;
	nextL_temp = L_temp;
	nexttemp = temp;
	nextoffset = offset;
	offsetLD = 0;	
	L_tempLD = 0;
	tempLD = 0;
	indLD = 0;
	iLD = 0;
	L_tempReset = 0;
	tempReset = 0;		
	indReset = 0;	
	iReset = 0;
	offsetReset = 0;
	subOutA = 0;
	subOutB = 0;
	L_subOutA = 0;
	L_subOutB = 0;
	L_multOutA = 0;
	L_multOutB = 0;
	addOutA = 0;
	addOutB = 0;
	shlOutA = 0;
	shlOutB = 0;
	L_shrVar1Out = 0;
	L_shrNumShiftOut = 0;
	multOutA = 0;
	multOutB = 0;
	shlVar1Out = 0;
	shlVar2Out = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
	memOut = 0;
	memWriteEn = 0;
	constantMemAddr = 0;
	done = 0;
	
	case(state)
		INIT:
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin
				L_tempReset = 1;	
				indReset = 1;	
				tempReset = 1;
				iReset = 1;
				offsetReset = 1;
				nextstate = S1;
			end
		end	//INIT
		
		//for(i= m-(Word16)1; i >= 0; i--)
		S1:
		begin
			
			if(i >= 0 && i < 4'd10)
			begin
				constantMemAddr = {TABLE2[11:6],ind[5:0]};
				memReadAddr = {lspAddr[10:4],i[3:0]};
				nextstate = S2;
			end
			else if(i == 4'hf)
			begin
				nextstate = INIT;
				done = 1;
			end
		end//S1
		
		/* while( sub(table2[ind], lsp[i]) < 0 )
		{
      ind = sub(ind,1);
      if ( ind <= 0 )
        break;
		}
		*/
		S2:
		begin
			subOutA = constantMemIn[15:0];
			subOutB = memIn[15:0];
			if(ind == 0)
				nextstate = S3;
			else if(subIn[15] == 1)
			begin
				L_subOutA = {26'd0,ind[5:0]};
				L_subOutB = 32'd1;
				nextind = L_subIn[5:0];
				indLD = 1;
				nextstate = S2; 				
			end
			else if (subIn[15] == 0)
				nextstate = S3;
			constantMemAddr = {TABLE2[11:6],nextind[5:0]};
			memReadAddr = {lspAddr[10:4],i[3:0]};
		end//S2
		
		//offset = sub(lsp[i], table2[ind]);
		S3:
		begin
			subOutA = memIn[15:0];
			subOutB = constantMemIn[15:0];
			nextoffset = subIn[15:0];
			offsetLD = 1;
			constantMemAddr = {SLOPE_ACOS[11:6],ind[5:0]};
			nextstate = S4;
		end//S3
		
		//L_tmp  = L_mult( slope_acos[ind], offset ); 
		S4:
		begin
			L_multOutA = constantMemIn[15:0];
			L_multOutB = offset[15:0];
			L_shrVar1Out = L_multIn;
			L_shrNumShiftOut = 16'd12;
			nextL_temp = L_shrIn;
			L_tempLD = 1;
			shlVar1Out = {10'd0,ind[5:0]};
			shlVar2Out = 16'd9;
			nexttemp = shlIn;
			tempLD = 1;
			nextstate = S5;
		end//S4
		
		//freq = add(shl(ind, 9), extract_l(L_shr(L_tmp, 12)));
		//lsf[i] = mult(freq, 25736);          
		S5:
		begin
			addOutA = temp;
			addOutB = L_temp[15:0];
			multOutA = addIn;
			multOutB = 16'd25736;
			memOut = multIn;
			memWriteEn = 1;
			memWriteAddr = {lsfAddr[10:4],i[3:0]};			
			subOutA = {12'd0,i[3:0]};
			subOutB = 16'd1;
			nexti = subIn[3:0];
			iLD = 1;
			nextstate = S1;
		end//S5
		
	endcase
end//always


endmodule
