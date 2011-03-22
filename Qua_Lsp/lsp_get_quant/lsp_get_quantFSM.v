	`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    10:51:15 02/14/2011 
// Module Name:    lsp_get_quantFSM 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "lsp_get_quant".
// 
// Dependencies: 	 lsp_get_quant_pipe.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lsp_get_quantFSM(clk,reset,start,L_addIn,L_subIn,L_multIn,L_macIn,addIn,subIn,shrIn,memIn,code0,
								code1,code2,fgAddr,freq_prevAddr,fg_sumAddr,lspqAddr,constantMemIn,
								L_addOutA,L_addOutB,L_subOutA,L_subOutB,L_multOutA,L_multOutB,L_macOutA,L_macOutB,
								L_macOutC,addOutA,addOutB,subOutA,subOutB,shrVar1Out,shrVar2Out,memOut,
								memReadAddr,memWriteAddr,memWriteEn,constantMemAddr,done);
	`include "paramList.v"
	`include "constants_param_list.v"
	//Inputs 
	input clk,reset,start;
	input [31:0] L_addIn;
	input [31:0] L_subIn;
	input [31:0] L_multIn;
	input [31:0] L_macIn;
	input [15:0] addIn;
	input [15:0] subIn;
	input [15:0] shrIn;
	input [31:0] memIn;
	input [15:0] code0,code1,code2;
	input [11:0] fgAddr;
	input [11:0] freq_prevAddr;
	input [11:0] fg_sumAddr;
	input [11:0] lspqAddr;
	input [31:0] constantMemIn;
	
	//Outputs
	output reg [31:0] L_addOutA,L_addOutB;
	output reg [31:0] L_subOutA,L_subOutB;
	output reg [15:0] L_multOutA,L_multOutB;
	output reg [15:0] L_macOutA,L_macOutB;
	output reg [31:0] L_macOutC;
	output reg [15:0] addOutA,addOutB;
	output reg [15:0] subOutA,subOutB;
	output reg [15:0] shrVar1Out;
	output reg [15:0] shrVar2Out;		
	output reg [31:0] memOut;
	output reg [11:0] memReadAddr;
	output reg [11:0] memWriteAddr;
	output reg memWriteEn;
	output reg [11:0] constantMemAddr;
	output reg done;
	
	//state parameters
	parameter INIT = 4'd0;
	parameter FOR_LOOP1 = 4'd1;
	parameter FOR_LOOP1_BODY1 = 4'd2;
	parameter FOR_LOOP1_BODY2 = 4'd3;
	parameter FOR_LOOP2 = 4'd4;
	parameter FOR_LOOP2_BODY1 = 4'd5;
	parameter FOR_LOOP2_BODY2 = 4'd6;
	parameter EXPAND1 = 4'd7;
	parameter EXPAND2 = 4'd8;
	parameter COMPOSE = 4'd9;
	parameter UPDATE = 4'd10;
	parameter STABILITY = 4'd11;
	
	//Internal wires and regs
	reg [3:0] state,nextstate;
	reg [31:0] temp,nexttemp;
	reg tempLD,tempReset;
	reg [3:0] j,nextj;
	reg jLD,jReset;
	
	//lsp_expand_1_2 wires and regs
	reg expandStart;
	wire [15:0] expandSubOutA,expandSubOutB;
	wire [31:0] expandL_subOutA,expandL_subOutB;
	wire [15:0] expandShrVar1Out,expandShrVar2Out;
	wire [15:0] expandAddOutA,expandAddOutB;
	wire [31:0] expandL_addOutA,expandL_addOutB;
	wire [31:0] expandMemOut;
	wire [10:0] expandMemReadAddr,expandMemWriteAddr;
	wire expandMemWriteEn;
	wire expandDone;
	reg gapSel;
	reg [3:0] gapMux;
	
	//GAP selector mux
	always @(*)
	begin
		case(gapSel)
			4'd0:	gapMux = 'd10;
			4'd1:	gapMux = 'd5;
		endcase
	end
	
	//lsp_prev_compose wires and regs
	reg composeStart;
	wire [10:0] composeMemReadAddr;									 
   wire [10:0] composeMemWriteAddr;
   wire [31:0] composeMemOut;
   wire composeWriteEn;
	wire [11:0] composeConstantMemAddr;
   wire [15:0] composeL_multOutA,composeL_multOutB;
   wire [15:0] composeAddOutA,composeAddOutB;
   wire [15:0] composeL_macOutA,composeL_macOutB;
   wire [31:0] composeL_macOutC;
	wire composeDone;	
	
	//lsp_prev_update wires and regs
	reg updateStart;
	wire [15:0] updateAddOutA,updateAddOutB;
	wire [15:0] updateSubOutA,updateSubOutB;
	wire [31:0] updateL_addOutA,updateL_addOutB;
	wire [10:0] updateMemReadAddr,updateMemWriteAddr;
	wire [31:0] updateMemOut;
   wire updateMemWriteEn;
   wire updateDone;
	
	//lsp_stability wires and regs
	reg stabilityStart;
	wire [15:0] stabilityAddOutA,stabilityAddOutB;
	wire [15:0] stabilitySubOutA,stabilitySubOutB;
	wire [31:0] stabilityL_addOutA,stabilityL_addOutB;
	wire [31:0] stabilityL_subOutA,stabilityL_subOutB;
	wire [10:0] stabilityMemReadAddr,stabilityMemWriteAddr;
	wire [31:0] stabilityMemOut;
	wire stabilityMemWriteEn;
	wire stabilityDone;	
	
	//flip flops
	//state flip flop
	always@(posedge clk)
	begin
		if(reset)
			state <= INIT;
		else
			state <= nextstate;
	end
	
	//temp flip flop
	always@(posedge clk)
	begin
		if(reset)
			temp <= 0;
		if(tempReset)
			temp <= 0;
		else if(tempLD)
			temp <= nexttemp;
	end
	
	//j flip flop
	always@(posedge clk)
	begin
		if(reset)
			j <= 0;
		if(jReset)
			j <= 0;
		else if(jLD)
			j <= nextj;
	end
	
	//Instantiated modules
	Lsp_expand_1_2 expand(
								.clk(clk),						
								.reset(reset),
								.start(expandStart),
								.subIn(subIn),
								.L_subIn(L_subIn),
								.shrIn(shrIn),
								.addIn(addIn),
								.L_addIn(L_addIn),
								.memIn(memIn),
								.bufAddr(LSPGETQ_BUF),
								.gap(gapMux),
								.subOutA(expandSubOutA),
								.subOutB(expandSubOutB),
								.L_subOutA(expandL_subOutA),
								.L_subOutB(expandL_subOutB),
								.shrVar1Out(expandShrVar1Out),
								.shrVar2Out(expandShrVar2Out),
								.addOutA(expandAddOutA),
								.addOutB(expandAddOutB),
								.L_addOutA(expandL_addOutA),
								.L_addOutB(expandL_addOutB),
								.memOut(expandMemOut),
								.memReadAddr(expandMemReadAddr),
								.memWriteAddr(expandMemWriteAddr),
								.memWriteEn(expandMemWriteEn),
								.done(expandDone)
								);
	Lsp_prev_compose compose(
									 .start(composeStart),
									 .clk(clk),
									 .done(composeDone),
									 .reset(reset), 
									 .lspele(LSPGETQ_BUF),
									 .fg(fgAddr), 
									 .fg_sum(fg_sumAddr),
									 .freq_prev(freq_prevAddr),
									 .lsp(lspqAddr),
									 .readIn(memIn),
									 .constantMemAddr(composeConstantMemAddr),
									 .constantMemIn(constantMemIn),
									 .L_mult_in(L_multIn),
									 .add_in(addIn),
									 .L_mac_in(L_macIn),
									 .readAddr(composeMemReadAddr),									 
									 .writeAddr(composeMemWriteAddr),
									 .writeOut(composeMemOut),
									 .writeEn(composeWriteEn),
									 .L_mult_a(composeL_multOutA),
									 .L_mult_b(composeL_multOutB),
									 .add_a(composeAddOutA),
									 .add_b(composeAddOutB),
									 .L_mac_a(composeL_macOutA),
									 .L_mac_b(composeL_macOutB),
									 .L_mac_c(composeL_macOutC)									 
									 );	
   Lsp_prev_update update(
									.clk(clk),
									.reset(reset),
									.start(updateStart),
									.addIn(addIn),
									.subIn(subIn),
									.L_addIn(L_addIn),
									.memIn(memIn),									
									.lsp_eleAddr(LSPGETQ_BUF),
									.freq_prevAddr(freq_prevAddr),
									.addOutA(updateAddOutA),
									.addOutB(updateAddOutB),
									.subOutA(updateSubOutA),
									.subOutB(updateSubOutB),
									.L_addOutA(updateL_addOutA),
									.L_addOutB(updateL_addOutB),
									.memReadAddr(updateMemReadAddr),
									.memWriteAddr(updateMemWriteAddr),
									.memOut(updateMemOut),
									.memWriteEn(updateMemWriteEn),
									.done(updateDone)
									);		
	Lsp_stability_FSM stablility(
											.clk(clk),
											.reset(reset),
											.start(stabilityStart),
											.bufAddr(lspqAddr),
											.addIn(addIn),
											.subIn(subIn),
											.L_addIn(L_addIn),
											.L_subIn(L_subIn),
											.memIn(memIn),
											.addOutA(stabilityAddOutA),
											.addOutB(stabilityAddOutB),
											.subOutA(stabilitySubOutA),
											.subOutB(stabilitySubOutB),
											.L_addOutA(stabilityL_addOutA),
											.L_addOutB(stabilityL_addOutB),
											.L_subOutA(stabilityL_subOutA),
											.L_subOutB(stabilityL_subOutB),
											.memReadAddr(stabilityMemReadAddr),
											.memWriteAddr(stabilityMemWriteAddr),
											.memOut(stabilityMemOut),
											.memWriteEn(stabilityMemWriteEn),
											.done(stabilityDone)
										);									
	always @(*)
   begin
		
		nextstate = state;
		nexttemp = temp;
		nextj = j;
		tempLD = 0;
		jLD = 0;
		tempReset = 0;
		jReset = 0;
		L_addOutA = 0;
		L_addOutB = 0;
		L_subOutA = 0;
		L_subOutB = 0;
		L_multOutA = 0;
		L_multOutB = 0;
		L_macOutA = 0;
		L_macOutB = 0;
		L_macOutC = 0;
		addOutA = 0;
		addOutB = 0;
		subOutA = 0;
		subOutB = 0;
		shrVar1Out = 0;
		shrVar2Out = 0;		
		memOut = 0;
		memReadAddr = 0;
		memWriteAddr = 0;
		memWriteEn = 0;
		expandStart = 0;
		gapSel = 0;
		composeStart = 0;
		updateStart = 0;
		stabilityStart = 0;
		done = 0;
		constantMemAddr = 0;
		
		case(state)
		
			INIT:		//state 0
			begin
				if(start == 0)
					nextstate = INIT;
				else if(start == 1)
				begin
					tempReset = 1;
					jReset = 1;
					nextstate = FOR_LOOP1;
					
				end
			end//INIT
			
			//for ( j = 0 ; j < NC ; j++ )
			FOR_LOOP1:	//state 1
			begin
				if(j >= 5)
				begin
					nextstate = FOR_LOOP2;
					nextj = 4'd5;
					jLD = 1;
				end
				
				else if(j < 5)
				begin
					constantMemAddr = {LSPCB2[11:9],code1[4:0],j[3:0]};		//lspcb2[code1][j] 
					nextstate = FOR_LOOP1_BODY1;
				end
			end//FOR_LOOP1
			
			FOR_LOOP1_BODY1:				//state 2
			begin
				nexttemp = constantMemIn;
				tempLD = 1;
				constantMemAddr = {LSPCB1[11:10],code0[6:0],j[3:0]};			//lspcb1[code0][j] 
				nextstate = FOR_LOOP1_BODY2;
			end //FOR_LOOP1_BODY1
			
			//buf[j] = add( lspcb1[code0][j], lspcb2[code1][j] );
			FOR_LOOP1_BODY2:			//state 3	
			begin
				addOutA = constantMemIn[15:0];
				addOutB = temp[15:0];
				memOut = addIn;
				memWriteAddr = {LSPGETQ_BUF[10:4],j[3:0]};
				memWriteEn = 1;
				L_addOutA = {27'd0,j[3:0]};
				L_addOutB = 32'd1;
				nextj = L_addIn[3:0];
				jLD = 1;
				nextstate = FOR_LOOP1;
			end//FOR_LOOP1_BODY2
			
			//for ( j = NC ; j < M ; j++ )
			FOR_LOOP2:			//state 4
			begin
				if(j>=10)
					nextstate = EXPAND1;
				else if (j<10)
				begin
					constantMemAddr = {LSPCB2[11:9],code2[4:0],j[3:0]};			//lspcb2[code2][j]
					nextstate = FOR_LOOP2_BODY1;
				end
			end//FOR_LOOP2
			
			FOR_LOOP2_BODY1:			//state 5
			begin
				nexttemp = constantMemIn[15:0];
				tempLD = 1;
				constantMemAddr = {LSPCB1[11:10],code0[6:0],j[3:0]};				//lspcb1[code0][j]
				nextstate = FOR_LOOP2_BODY2;
			end//FOR_LOOP2_BODY1
			
			//buf[j] = add( lspcb1[code0][j], lspcb2[code2][j] );
			FOR_LOOP2_BODY2:		//state 6
			begin
				addOutA = constantMemIn[15:0];
				addOutB = temp[15:0];
				memOut = addIn;
				memWriteAddr = {LSPGETQ_BUF[10:4],j[3:0]};
				memWriteEn = 1;
				L_addOutA = {27'd0,j[3:0]};
				L_addOutB = 32'd1;
				nextj = L_addIn[3:0];
				jLD = 1;
				nextstate = FOR_LOOP2;
			end//FOR_LOOP2_BODY2
			
			//Lsp_expand_1_2(buf, GAP1);
			EXPAND1:				//state 7
			begin
				expandStart = 1;
				subOutA = expandSubOutA;
				subOutB = expandSubOutB;
				L_subOutA = expandL_subOutA;
				L_subOutB = expandL_subOutB;
				shrVar1Out = expandShrVar1Out;
				shrVar2Out = expandShrVar2Out;
				addOutA = expandAddOutA;
				addOutB = expandAddOutB;
				L_addOutA = expandL_addOutA;
				L_addOutB = expandL_addOutB;
				memOut = expandMemOut;
				memReadAddr = expandMemReadAddr;
				memWriteAddr = expandMemWriteAddr;
				memWriteEn = expandMemWriteEn;
				gapSel = 0;
				if(expandDone == 0)
					nextstate = EXPAND1;
				else if(expandDone == 1)
				begin
					nextstate = EXPAND2;
					expandStart = 0;
				end
			end//EXPAND1
			
			//Lsp_expand_1_2(buf, GAP2);
			EXPAND2:			////state 8
			begin
				expandStart = 1;
				subOutA = expandSubOutA;
				subOutB = expandSubOutB;
				L_subOutA = expandL_subOutA;
				L_subOutB = expandL_subOutB;
				shrVar1Out = expandShrVar1Out;
				shrVar2Out = expandShrVar2Out;
				addOutA = expandAddOutA;
				addOutB = expandAddOutB;
				L_addOutA = expandL_addOutA;
				L_addOutB = expandL_addOutB;
				memOut = expandMemOut;
				memReadAddr = expandMemReadAddr;
				memWriteAddr = expandMemWriteAddr;
				memWriteEn = expandMemWriteEn;
				gapSel = 1;
				if(expandDone == 0)
					nextstate = EXPAND2;
				else if(expandDone == 1)
				begin
					nextstate = COMPOSE;
					expandStart = 0;
				end
			end//EXPAND2
			
			//Lsp_prev_compose(buf, lspq, fg, freq_prev, fg_sum);
			COMPOSE:				//state 9
			begin
				composeStart = 1;
				memReadAddr = composeMemReadAddr;									 
				memWriteAddr = composeMemWriteAddr;
				memOut = composeMemOut;
				memWriteEn = composeWriteEn;
				constantMemAddr = composeConstantMemAddr;				
				L_multOutA = composeL_multOutA;
				L_multOutB = composeL_multOutB;
				addOutA = composeAddOutA;
				addOutB = composeAddOutB;
				L_macOutA = composeL_macOutA;
				L_macOutB = composeL_macOutB;
				L_macOutC = composeL_macOutC;
				if(composeDone == 0)
					nextstate = COMPOSE;
				else if(composeDone == 1)
				begin
					composeStart = 0;
					nextstate = UPDATE;
				end				
			end//COMPOSE
			
			//Lsp_prev_update(buf, freq_prev);
			UPDATE:			//state 10
			begin
				updateStart = 1;
				addOutA = updateAddOutA;
				addOutB = updateAddOutB;
				subOutA = updateSubOutA;
				subOutB = updateSubOutB;
				L_addOutA = updateL_addOutA;
				L_addOutB = updateL_addOutB;
				memReadAddr = updateMemReadAddr;
				memWriteAddr = updateMemWriteAddr;
				memOut = updateMemOut;
				memWriteEn = updateMemWriteEn;				
				if(updateDone == 0)
					nextstate = UPDATE;
				else if(updateDone == 1)
				begin
					updateStart = 0;
					nextstate = STABILITY;
				end
			end//UPDATE
			
			//Lsp_stability( lspq );
			STABILITY:			//state 11
			begin
				stabilityStart = 1;
				addOutA = stabilityAddOutA;
				addOutB = stabilityAddOutB;
				subOutA = stabilitySubOutA;
				subOutB = stabilitySubOutB;
				L_addOutA = stabilityL_addOutA;
				L_addOutB = stabilityL_addOutB;
				L_subOutA = stabilityL_subOutA;
				L_subOutB = stabilityL_subOutB;
				memReadAddr = stabilityMemReadAddr;
				memWriteAddr = stabilityMemWriteAddr;
				memOut = stabilityMemOut;
				memWriteEn = stabilityMemWriteEn;
				if(stabilityDone == 0)
					nextstate = STABILITY;
				else if(stabilityDone == 1)
				begin
					stabilityStart = 0;
					done = 1;
					nextstate = INIT;
				end
			end//STABILITY
	 endcase
	end//always
endmodule
