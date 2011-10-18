`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Mississippi State University
// Engineer: Nick Robinson
// 
// Create Date:    20:33:28 03/18/2011 
// Design Name: 
// Module Name:    Relspwed_FSM 
// Project Name: G.729 Verilog Encoder
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Relspwed_FSM(clk, reset, start, L_addIn, L_subIn, L_multIn, L_macIn, addIn, subIn,  
							shrIn, memIn, constantMemIn, L_addOutA, L_addOutB, L_subOutA, L_subOutB, 
							L_multOutA, L_multOutB, L_macOutA, L_macOutB, L_macOutC, addOutA, addOutB, subOutA, 
							subOutB, shrVar1Out, shrVar2Out, L_msuOutA, L_msuOutB, L_msuOutC, L_msuIn, L_shlIn, 
							L_shlOutVar1, L_shlReady, L_shlDone, L_shlNumShiftOut, multOutA, multOutB, memOut, 
							multIn, memReadAddr, memWriteAddr, memWriteEn, constantMemAddr, done, freq_prevAddr, 
							lspqAddr, wegtAddr, lspAddr, code_anaAddr, shlOutVar1, shlOutVar2, shlIn
    );
	 
	`include "paramList.v"
	`include "constants_param_list.v"
	
	//Inputs 
	input clk, reset, start;
	input [31:0] L_addIn;
	input [31:0] L_subIn;
	input [31:0] L_multIn;
	input [31:0] L_macIn;
	input [31:0] L_msuIn;
	input [15:0] addIn;
	input [15:0] subIn;
	input [15:0] shrIn;
	input [15:0] shlIn;
	input [15:0] multIn;
	input [31:0] L_shlIn;
	input L_shlDone;
	input [31:0] memIn;
	input [31:0] constantMemIn;
	input [11:0] freq_prevAddr;
	input [11:0] lspqAddr;
	input [11:0] lspAddr;
	input [11:0] code_anaAddr;
	input [11:0] wegtAddr;
	
	//Outputs
	output reg [31:0] L_addOutA, L_addOutB;
	output reg [31:0] L_subOutA, L_subOutB;
	output reg [15:0] L_multOutA, L_multOutB;
	output reg [15:0] L_macOutA, L_macOutB;
	output reg [31:0] L_macOutC;
	output reg [15:0] L_msuOutA, L_msuOutB;
	output reg [31:0] L_msuOutC;
	output reg [15:0] addOutA, addOutB;
	output reg [15:0] subOutA, subOutB;
	output reg [15:0] multOutA, multOutB;
	output reg [15:0] shrVar1Out;
	output reg [15:0] shrVar2Out;	
	output reg [15:0] shlOutVar1, shlOutVar2;
   output reg [31:0] L_shlOutVar1;
   output reg [15:0] L_shlNumShiftOut;
	output reg [31:0] memOut;
	output reg [11:0] memReadAddr;
	output reg [11:0] memWriteAddr;
	output reg memWriteEn;
	output reg [11:0] constantMemAddr;
	output reg done;
	output reg L_shlReady;
	
	//internal address regs
	reg [11:0] select1Lspcb1, nextselect1Lspcb1;
	reg select1Lspcb1LD,select1Lspcb1Reset;
	reg [11:0] selectFg, nextselectFg;
	reg selectFgLD,selectFgReset;
	reg [11:0] selectFgSum, nextselectFgSum;
	reg selectFgSumLD,selectFgSumReset;
	reg [11:0] selectFgSumInv, nextselectFgSumInv;
	reg selectFgSumInvLD,selectFgSumInvReset;
	reg [11:0] selectLTdist, nextselectLTdist;
	reg selectLTdistLD,selectLTdistReset;
	
	//constants
	parameter MODE = 2;
	parameter M = 10;
	parameter NC = 5;
	parameter GAP1 = 10;
	parameter MA_NP = 4;
	parameter GAP2 = 5;
	parameter NC0_B = 7;
	parameter NC1_B = 5;
	
	//state parameters
	parameter STATE_INIT = 5'd0;
	parameter STATE_COUNT_LOOP1 = 5'd1;
	parameter PREV_EXTRACT = 5'd2;
	parameter PRE_SELECT = 5'd3;
	parameter COPY_CAND = 5'd4;
	parameter COPY_CAND_1 = 5'd5;
	parameter SELECT_1 = 5'd6;
	parameter COPY_INDEX = 5'd7;
	parameter FOR_LOOP2 = 5'd8;
	parameter ADD_CB1_1 = 5'd9;
	parameter ADD_CB1_2 = 5'd10;
	parameter EXPAND_1 = 5'd11;
	parameter SELECT_2 = 5'd12;
	parameter COPY_INDEX2 = 5'd13;
	parameter FOR_LOOP3 = 5'd14;
	parameter ADD_CB2_1 = 5'd15;
	parameter ADD_CB2_2 = 5'd16;
	parameter EXPAND_2 = 5'd17;
	parameter EXPAND_1_2 = 5'd18;
	parameter GET_TDIST = 5'd19;
	parameter LAST_SELECT = 5'd20;
	parameter SHL_1 = 5'd21;
	parameter SHL_2 = 5'd22;
	parameter SHL_3 = 5'd23;
	parameter SHL_4 = 5'd24;
	parameter SHL_5 = 5'd25;
	parameter GET_QUANT_1 = 5'd26;
	parameter GET_QUANT_2 = 5'd27;
	parameter GET_QUANT_3 = 5'd28;
	parameter GET_QUANT_4 = 5'd29;
	
	//Internal wires and regs
	reg [4:0] state, nextstate;
	reg [15:0] temp, nexttemp;
	reg tempLD, tempReset;
	reg [15:0] tempCandCur, nexttempCandCur;
	reg tempCandCurLD,tempCandCurReset;
	reg count1LD,count1Reset;
	reg [15:0] tempIndex, nexttempIndex;
	reg tempIndexLD,tempIndexReset;
	reg [15:0] tempIndex1, nexttempIndex1;
	reg tempIndex1LD,tempIndex1Reset;
	reg [15:0] tempIndex2, nexttempIndex2;
	reg tempIndex2LD,tempIndex2Reset;
	reg [15:0] tempCand, nexttempCand;
	reg tempCandLD,tempCandReset;
	reg count2LD,count2Reset;
	reg [5:0] count1,nextcount1;
	reg [5:0] count2,nextcount2;
	
	//lsp_prev_extract wires and regs
	reg prev_extract_Start;
	wire prev_extract_Done;
	wire [15:0] prev_extract_L_msuOutA, prev_extract_L_msuOutB;
	wire [31:0] prev_extract_L_msuOutC;
	wire [15:0] prev_extract_L_multOutA, prev_extract_L_multOutB;
	wire [31:0] prev_extract_L_shlOutVar1;
	wire [15:0] prev_extract_L_shlNumShiftOut;
	wire prev_extract_L_shlReady;
	wire [15:0] prev_extract_AddOutA, prev_extract_AddOutB;
	wire [31:0] prev_extract_MemOut;
	wire [11:0] prev_extract_MemReadAddr,  prev_extract_MemWriteAddr;
	wire [11:0] prev_extract_ConstantMemAddr;
	wire prev_extract_MemWriteEn;
	
	//lsp_pre_select wires and regs
	reg pre_select_Start;
	wire pre_select_Done;
	wire [15:0] pre_select_subOutA, pre_select_subOutB;
	wire [15:0] pre_select_L_macOutA, pre_select_L_macOutB;
	wire [31:0] pre_select_L_macOutC;
	wire [15:0] pre_select_AddOutA, pre_select_AddOutB;
	wire [31:0] pre_select_L_subOutA, pre_select_L_subOutB;
	wire [31:0] pre_select_MemOut;
	wire [11:0] pre_select_MemReadAddr,  pre_select_MemWriteAddr;
	wire [11:0] pre_select_ConstantMemAddr;
	wire pre_select_MemWriteEn;
	
	//lsp_select_1 wires and regs
	reg select_1_Start;
	wire select_1_Done;
	wire [31:0] select_1_L_subOutA, select_1_L_subOutB;
	wire [31:0] select_1_L_addOutA, select_1_L_addOutB;
	wire [15:0] select_1_subOutA, select_1_subOutB;
	wire [15:0] select_1_multOutA, select_1_multOutB;
	wire [15:0] select_1_L_macOutA, select_1_L_macOutB;
	wire [31:0] select_1_L_macOutC;
	wire [31:0] select_1_MemOut;
	wire [11:0] select_1_MemReadAddr,  select_1_MemWriteAddr;
	wire [11:0] select_1_ConstantMemAddr;
	wire select_1_MemWriteEn;
	
	//lsp_expand_1 wires and regs
	reg expand_1_Start;
	wire expand_1_Done;
	wire [15:0] expand_1_subOutA, expand_1_subOutB;
	wire [15:0] expand_1_ShrVar1Out,expand_1_ShrVar2Out;
	wire [15:0] expand_1_addOutA, expand_1_addOutB;
	wire [31:0] expand_1_L_subOutA, expand_1_L_subOutB;
	wire [31:0] expand_1_L_addOutA, expand_1_L_addOutB;
	wire [31:0] expand_1_MemOut;
	wire [11:0] expand_1_MemReadAddr,  expand_1_MemWriteAddr;
	wire expand_1_MemWriteEn;
	
	//lsp_select_2 wires and regs
	reg select_2_Start;
	wire select_2_Done;
	wire [31	:0] select_2_L_subOutA, select_2_L_subOutB;
	wire [31:0] select_2_L_addOutA, select_2_L_addOutB;
	wire [15:0] select_2_subOutA, select_2_subOutB;
	wire [15:0] select_2_multOutA, select_2_multOutB;
	wire [15:0] select_2_L_macOutA, select_2_L_macOutB;
	wire [31:0] select_2_L_macOutC;
	wire [31:0] select_2_MemOut;
	wire [11:0] select_2_MemReadAddr,  select_2_MemWriteAddr;
	wire [11:0] select_2_ConstantMemAddr;
	wire select_2_MemWriteEn;
	
	//lsp_expand_2 wires and regs
	reg expand_2_Start;
	wire expand_2_Done;
	wire [15:0] expand_2_subOutA, expand_2_subOutB;
	wire [15:0] expand_2_ShrVar1Out,expand_2_ShrVar2Out;
	wire [15:0] expand_2_addOutA, expand_2_addOutB;
	wire [31:0] expand_2_L_subOutA, expand_2_L_subOutB;
	wire [31:0] expand_2_L_addOutA, expand_2_L_addOutB;
	wire [31:0] expand_2_MemOut;
	wire [11:0] expand_2_MemReadAddr,  expand_2_MemWriteAddr;
	wire expand_2_MemWriteEn;
	
	//lsp_expand_1_2 wires and regs
	reg expand_1_2_Start;
	wire expand_1_2_Done;
	wire [15:0] expand_1_2_subOutA, expand_1_2_subOutB;
	wire [15:0] expand_1_2_ShrVar1Out,expand_1_2_ShrVar2Out;
	wire [15:0] expand_1_2_addOutA, expand_1_2_addOutB;
	wire [31:0] expand_1_2_L_subOutA, expand_1_2_L_subOutB;
	wire [31:0] expand_1_2_L_addOutA, expand_1_2_L_addOutB;
	wire [31:0] expand_1_2_MemOut;
	wire [11:0] expand_1_2_MemReadAddr,  expand_1_2_MemWriteAddr;
	wire expand_1_2_MemWriteEn;
	
	//lsp_get_tdist wires and regs
	reg get_tdist_Start;
	wire get_tdist_Done;
	wire [15:0] get_tdist_multOutA, get_tdist_multOutB;
	wire [15:0] get_tdist_L_multOutA, get_tdist_L_multOutB;
	wire [31:0] get_tdist_L_shlOutVar1;
	wire get_tdist_L_shlReady;
	wire [15:0] get_tdist_L_shlNumShiftOut;
	wire [15:0] get_tdist_addOutA, get_tdist_addOutB;
	wire [15:0] get_tdist_subOutA, get_tdist_subOutB;
	wire [15:0] get_tdist_L_macOutA, get_tdist_L_macOutB;
	wire [31:0] get_tdist_L_macOutC;
	wire [31:0] get_tdist_MemOut;
	wire [11:0] get_tdist_MemReadAddr,  get_tdist_MemWriteAddr;
	wire [11:0] get_tdist_ConstantMemAddr;
	wire get_tdist_MemWriteEn;
	
	//lsp_last_select wires and regs
	reg last_select_Start;
	wire last_select_Done;
	wire [31:0] last_select_L_subOutA, last_select_L_subOutB;
	wire [31:0] last_select_MemOut;
	wire [11:0] last_select_MemReadAddr,  last_select_MemWriteAddr;
	wire last_select_MemWriteEn;
	
	//lsp_get_quant wires and regs
	reg get_quant_Start;
	wire get_quant_Done;
	wire [31:0] get_quant_L_subOutA, get_quant_L_subOutB;
	wire [31:0] get_quant_L_addOutA, get_quant_L_addOutB;
	wire [15:0] get_quant_L_macOutA, get_quant_L_macOutB;
	wire [31:0] get_quant_L_macOutC;
	wire [15:0] get_quant_L_msuOutA, get_quant_L_msuOutB;
	wire [31:0] get_quant_L_msuOutC;
	wire [31:0] get_quant_L_shlOutVar1;
	wire get_quant_L_shlReady;
	wire [15:0] get_quant_L_shlNumShiftOut;
	wire [15:0] get_quant_multOutA, get_quant_multOutB;
	wire [15:0] get_quant_addOutA, get_quant_addOutB;
	wire [15:0] get_quant_subOutA, get_quant_subOutB;
	wire [15:0] get_quant_ShrVar1Out, get_quant_ShrVar2Out;
	wire [31:0] get_quant_MemOut;
	wire [11:0] get_quant_MemReadAddr,  get_quant_MemWriteAddr;
	wire [11:0] get_quant_ConstantMemAddr;
	wire get_quant_MemWriteEn;
	
	//flip flops
	//state flip flop
	always@(posedge clk)
	begin
		if(reset)
			state <= STATE_INIT;
		else
			state <= nextstate;
	end
	
	//tempCandCur flip flop
	always@(posedge clk)
	begin
		if(reset)
			tempCandCur <= 0;
		if(tempCandCurReset)
			tempCandCur <= 0;
		else if(tempCandCurLD)
			tempCandCur <= nexttempCandCur;
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
	
	//temp flip flop
	always@(posedge clk)
	begin
		if(reset)
			tempIndex1 <= 0;
		if(tempIndex1Reset)
			tempIndex1 <= 0;
		else if(tempIndex1LD)
			tempIndex1 <= nexttempIndex1;
	end
	
	//temp flip flop
	always@(posedge clk)
	begin
		if(reset)
			tempIndex2 <= 0;
		if(tempIndex2Reset)
			tempIndex2 <= 0;
		else if(tempIndex2LD)
			tempIndex2 <= nexttempIndex2;
	end
	
	//temp flip flop
	always@(posedge clk)
	begin
		if(reset)
			tempCand <= 0;
		if(tempCandReset)
			tempCand <= 0;
		else if(tempCandLD)
			tempCand <= nexttempCand;
	end
	
	//temp flip flop
	always@(posedge clk)
	begin
		if(reset)
			tempIndex <= 0;
		if(tempIndexReset)
			tempIndex <= 0;
		else if(tempIndexLD)
			tempIndex <= nexttempIndex;
	end
	
	always @(posedge clk)
	begin
		if(reset)
			count1 <= 0;
		else if(count1Reset)
			count1 <= 0;
		else if(count1LD)
			count1 <= nextcount1;
	end
	
	always @(posedge clk)
	begin
		if(reset)
			count2 <= 0;
		else if(count2Reset)
			count2 <= 0;
		else if(count2LD)
			count2 <= nextcount2;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			select1Lspcb1 <= 0;
		if(select1Lspcb1Reset)
			select1Lspcb1 <= 0;
		else if(select1Lspcb1LD)
			select1Lspcb1 <= nextselect1Lspcb1;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			selectFg <= 0;
		if(selectFgReset)
			selectFg <= 0;
		else if(selectFgLD)
			selectFg <= nextselectFg;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			selectFgSum <= 0;
		if(selectFgSumReset)
			selectFgSum <= 0;
		else if(selectFgSumLD)
			selectFgSum <= nextselectFgSum;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			selectFgSumInv <= 0;
		if(selectFgSumInvReset)
			selectFgSumInv <= 0;
		else if(selectFgSumInvLD)
			selectFgSumInv <= nextselectFgSumInv;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			selectLTdist <= 0;
		if(selectLTdistReset)
			selectLTdist <= 0;
		else if(selectLTdistLD)
			selectLTdist <= nextselectLTdist;
	end
	
	//Instantiated Modules
	Lsp_prev_extract prev_extract (
						  .start(prev_extract_Start), 
						  .clk(clk), 
						  .done(prev_extract_Done), 
						  .reset(reset), 
						  .lspele(RELSPWED_RBUF), //rbuf starting addr
						  .freq_prev(freq_prevAddr), 
						  .lsp(lspAddr), 
						  .readAddr(prev_extract_MemReadAddr), 
						  .readIn(memIn),
						  .fgAddr(selectFg),
						  .fg_sum_invAddr(selectFgSumInv),
						  .constantMemIn(constantMemIn),
						  .constantMemAddr(prev_extract_ConstantMemAddr),
						  .writeAddr(prev_extract_MemWriteAddr), 
						  .writeOut(prev_extract_MemOut), 
						  .writeEn(prev_extract_MemWriteEn), 
						  .L_msu_a(prev_extract_L_msuOutA), 
						  .L_msu_b(prev_extract_L_msuOutB), 
						  .L_msu_c(prev_extract_L_msuOutC), 
						  .L_msu_in(L_msuIn), 
						  .L_mult_a(prev_extract_L_multOutA),
						  .L_mult_b(prev_extract_L_multOutB),
						  .L_mult_in(L_multIn), 
						  .L_shl_a(prev_extract_L_shlOutVar1), 
						  .L_shl_b(prev_extract_L_shlNumShiftOut), 
						  .L_shl_in(L_shlIn), 
						  .add_a(prev_extract_AddOutA),
						  .add_b(prev_extract_AddOutB),
						  .add_in(addIn), 
						  .L_shl_ready(prev_extract_L_shlReady), 
						  .L_shl_done(L_shlDone)
						  );
						  
	Lsp_pre_select pre_select (
						.clk(clk), 
						.start(pre_select_Start), 
						.reset(reset), 
						.done(pre_select_Done), 
						.rbuf(RELSPWED_RBUF), //pass address of rbuf
						.sub_a(pre_select_subOutA), 
						.sub_b(pre_select_subOutB), 
						.sub_in(subIn), 
						.L_mac_a(pre_select_L_macOutA), 
						.L_mac_b(pre_select_L_macOutB), 
						.L_mac_c(pre_select_L_macOutC),
						.L_mac_in(L_macIn), 
						.add_a(pre_select_AddOutA), 
						.add_b(pre_select_AddOutB), 
						.add_in(addIn), 
						.L_sub_a(pre_select_L_subOutA), 
						.L_sub_b(pre_select_L_subOutB), 
						.L_sub_in(L_subIn), 
						.readIn(memIn), 
						.const_in(constantMemIn), 
						.writeAddr(pre_select_MemWriteAddr), 
						.writeOut(pre_select_MemOut), 
						.writeEn(pre_select_MemWriteEn), 
						.readAddr(pre_select_MemReadAddr), 
						.const_addr(pre_select_ConstantMemAddr), 
						.cand(RELSPWED_CAND_CUR) //pass address of cand_cur
						);
						
						
	lsp_select_1 select_1 (
					 .clk(clk), 
					 .reset(reset), 
					 .start(select_1_Start), 
					 .memIn(memIn), 
					 .memWriteEn(select_1_MemWriteEn), 
					 .memWriteAddr(select_1_MemWriteAddr), 
					 .memReadAddr(select_1_MemReadAddr),
					 .memOut(select_1_MemOut), 
					 .done(select_1_Done), 
					 .L_subOutA(select_1_L_subOutA), 
					 .L_subOutB(select_1_L_subOutB), 
					 .L_subIn(L_subIn), 
					 .L_addOutA(select_1_L_addOutA), 
					 .L_addOutB(select_1_L_addOutB), 
					 .L_addIn(L_addIn), 
					 .subOutA(select_1_subOutA),
					 .subOutB(select_1_subOutB), 
					 .subIn(subIn), 
					 .multOutA(select_1_multOutA), 
					 .multOutB(select_1_multOutB), 
					 .multIn(multIn), 
					 .L_macOutA(select_1_L_macOutA), 
					 .L_macOutB(select_1_L_macOutB), 
					 .L_macOutC(select_1_L_macOutC), 
					 .L_macIn(L_macIn),
					 .constMemIn(constantMemIn), 
					 .constMemAddr(select_1_ConstantMemAddr), 
					 .lspcb1Addr(select1Lspcb1), 
					 .lspcb2Addr(LSPCB2), 
					 .rbufAddr(RELSPWED_RBUF), //rbuf addr
					 .wegtAddr(wegtAddr), 
					 .indexAddr(RELSPWED_INDEX) //local var index
					 );
					
	Lsp_expand_1 expand_1 (
					  .clk(clk),
					  .reset(reset),
					  .start(expand_1_Start),
					  .subIn(subIn),
					  .L_subIn(L_subIn),
					  .shrIn(shrIn),
					  .addIn(addIn),
					  .L_addIn(L_addIn),
					  .memIn(memIn),
					  .subOutA(expand_1_subOutA),
					  .subOutB(expand_1_subOutB),
					  .L_subOutA(expand_1_L_subOutA),
					  .L_subOutB(expand_1_L_subOutB),
					  .shrVar1Out(expand_1_ShrVar1Out),
					  .shrVar2Out(expand_1_ShrVar2Out),
					  .addOutA(expand_1_addOutA),
					  .addOutB(expand_1_addOutB),
					  .L_addOutA(expand_1_L_addOutA),
					  .L_addOutB(expand_1_L_addOutB),
					  .memOut(expand_1_MemOut),
					  .memReadAddr(expand_1_MemReadAddr),
					  .memWriteAddr(expand_1_MemWriteAddr),
					  .memWriteEn(expand_1_MemWriteEn),
					  .done(expand_1_Done)
					  );
					  
	lsp_select_2 select_2 (
					 .clk(clk), 
					 .reset(reset), 
					 .start(select_2_Start), 
					 .memIn(memIn), 
					 .memWriteEn(select_2_MemWriteEn), 
					 .memWriteAddr(select_2_MemWriteAddr), 
					 .memReadAddr(select_2_MemReadAddr),
					 .memOut(select_2_MemOut),  
					 .done(select_2_Done), 
					 .L_subOutA(select_2_L_subOutA), 
					 .L_subOutB(select_2_L_subOutB), 
					 .L_subIn(L_subIn), 
					 .L_addOutA(select_2_L_addOutA), 
					 .L_addOutB(select_2_L_addOutB), 
					 .L_addIn(L_addIn), 
					 .subOutA(select_2_subOutA),
					 .subOutB(select_2_subOutB), 
					 .subIn(subIn), 
					 .multOutA(select_2_multOutA), 
					 .multOutB(select_2_multOutB), 
					 .multIn(multIn), 
					 .L_macOutA(select_2_L_macOutA), 
					 .L_macOutB(select_2_L_macOutB), 
					 .L_macOutC(select_2_L_macOutC), 
					 .L_macIn(L_macIn),
					 .constMemIn(constantMemIn), 
					 .constMemAddr(select_2_ConstantMemAddr), 
					 .lspcb1Addr(select1Lspcb1), 
					 .lspcb2Addr(LSPCB2), 
					 .rbufAddr(RELSPWED_RBUF), //rbuf addr
					 .wegtAddr(wegtAddr), 
					 .indexAddr(RELSPWED_INDEX) //local var index
					 );
					 
	Lsp_Expand_2 expand_2 (
					  .clk(clk),
					  .reset(reset),
					  .start(expand_2_Start),
					  .subIn(subIn),
					  .L_subIn(L_subIn),
					  .shrIn(shrIn),
					  .addIn(addIn),
					  .L_addIn(L_addIn),
					  .memIn(memIn),
					  .subOutA(expand_2_subOutA),
					  .subOutB(expand_2_subOutB),
					  .L_subOutA(expand_2_L_subOutA),
					  .L_subOutB(expand_2_L_subOutB),
					  .shrVar1Out(expand_2_ShrVar1Out),
					  .shrVar2Out(expand_2_ShrVar2Out),
					  .addOutA(expand_2_addOutA),
					  .addOutB(expand_2_addOutB),
					  .L_addOutA(expand_2_L_addOutA),
					  .L_addOutB(expand_2_L_addOutB),
					  .memOut(expand_2_MemOut),
					  .memReadAddr(expand_2_MemReadAddr),
					  .memWriteAddr(expand_2_MemWriteAddr),
					  .memWriteEn(expand_2_MemWriteEn),
					  .done(expand_2_Done)
					  );
					  
	Lsp_expand_1_2 expand_1_2 (
						 .clk(clk),
						 .reset(reset),
						 .start(expand_1_2_Start),
						 .subIn(subIn),
						 .L_subIn(L_subIn),
						 .shrIn(shrIn),
						 .addIn(addIn),
						 .L_addIn(L_addIn),
						 .memIn(memIn),
						 .bufAddr(RELSPWED_BUF), //buf addr
						 .gap(GAP2),	//gap[3:0] value
						 .subOutA(expand_1_2_subOutA),
						 .subOutB(expand_1_2_subOutB),
						 .L_subOutA(expand_1_2_L_subOutA),
						 .L_subOutB(expand_1_2_L_subOutB),
						 .shrVar1Out(expand_1_2_ShrVar1Out),
						 .shrVar2Out(expand_1_2_ShrVar2Out),
						 .addOutA(expand_1_2_addOutA),
						 .addOutB(expand_1_2_addOutB),
						 .L_addOutA(expand_1_2_L_addOutA),
						 .L_addOutB(expand_1_2_L_addOutB),
						 .memOut(expand_1_2_MemOut),
						 .memReadAddr(expand_1_2_MemReadAddr),
						 .memWriteAddr(expand_1_2_MemWriteAddr),
						 .memWriteEn(expand_1_2_MemWriteEn),
						 .done(expand_1_2_Done)
						 );
						 
	Lsp_get_tdist get_tdist (
				      .clk(clk),
						.reset(reset),
						.start(get_tdist_Start),
						.wegt(wegtAddr),
						.buff(RELSPWED_BUF), //passing buffer
						.L_tdist(selectLTdist), //passing local
						.rbuf(RELSPWED_RBUF),
						.fg_sum(selectFgSum),
						.subIn(subIn),
						.multIn(multIn),
						.L_multIn(L_multIn),
						.L_shlIn(L_shlIn),
						.L_shlDone(L_shlDone),
						.L_macIn(L_macIn),
						.addIn(addIn),
						.dataInScratch(memIn),
						.dataInConstant(constantMemIn),
						.subOutA(get_tdist_subOutA),
						.subOutB(get_tdist_subOutB),
						.multOutA(get_tdist_multOutA),
						.multOutB(get_tdist_multOutB),
						.L_multOutA(get_tdist_L_multOutA),
						.L_multOutB(get_tdist_L_multOutB),
						.L_shlOutA(get_tdist_L_shlOutVar1),
						.L_shlOutB(get_tdist_L_shlNumShiftOut),
						.L_shlReady(get_tdist_L_shlReady),
						.L_macOutA(get_tdist_L_macOutA),
						.L_macOutB(get_tdist_L_macOutB),
						.L_macOutC(get_tdist_L_macOutC),
						.addOutA(get_tdist_addOutA),
						.addOutB(get_tdist_addOutB),
						.FSMwriteAddrScratch(get_tdist_MemWriteAddr),
						.FSMwriteDataScratch(get_tdist_MemOut),
						.FSMwriteEnScratch(get_tdist_MemWriteEn),
						.FSMreadAddrScratch(get_tdist_MemReadAddr),
						.readAddrConstant(get_tdist_ConstantMemAddr),
						.done(get_tdist_Done)	
						);
						 
	Lsp_last_select last_select (
	                .clk(clk), 
						 .start(last_select_Start), 
						 .reset(reset),
						 .done(last_select_Done), 
						 .L_tdist(selectLTdist), //pass local var
						 .readIn(memIn), 
						 .writeAddr(last_select_MemWriteAddr), 
						 .writeOut(last_select_MemOut), 
						 .writeEn(last_select_MemWriteEn), 
						 .readAddr(last_select_MemReadAddr),
						 .L_sub_in(L_subIn), 
						 .L_sub_a(last_select_L_subOutA), 
						 .L_sub_b(last_select_L_subOutB)
						 );
						 
	lsp_get_quantFSM get_quant (
	                 .clk(clk), 
						  .reset(reset), 
						  .start(get_quant_Start), 
						  .L_addIn(L_addIn), 
						  .L_subIn(L_subIn), 
						  .L_multIn(L_multIn), 
						  .L_macIn(L_macIn), 
						  .addIn(addIn), 
						  .subIn(subIn), 
						  .shrIn(shrIn), 
						  .memIn(memIn), 
						  .code0(tempCand), //cand
						  .code1(tempIndex1), //tindex1
						  .code2(tempIndex2), //tindex2
						  .fgAddr(selectFg), 
						  .freq_prevAddr(freq_prevAddr), 
						  .fg_sumAddr(selectFgSum), 
						  .lspqAddr(lspqAddr), 
						  .constantMemIn(constantMemIn), 
						  .L_addOutA(get_quant_L_addOutA), 
						  .L_addOutB(get_quant_L_addOutB), 
						  .L_subOutA(get_quant_L_subOutA), 
						  .L_subOutB(get_quant_L_subOutB), 
						  .L_multOutA(get_quant_multOutA), 
						  .L_multOutB(get_quant_multOutB), 
						  .L_macOutA(get_quant_L_macOutA), 
						  .L_macOutB(get_quant_L_macOutB), 
						  .L_macOutC(get_quant_L_macOutC), 
						  .addOutA(get_quant_addOutA), 
						  .addOutB(get_quant_addOutB), 
						  .subOutA(get_quant_subOutA), 
						  .subOutB(get_quant_subOutB), 
						  .shrVar1Out(get_quant_ShrVar1Out), 
						  .shrVar2Out(get_quant_ShrVar2Out), 
						  .L_msuOutA(get_quant_L_msuOutA), 
						  .L_msuOutB(get_quant_L_msuOutB), 
						  .L_msuOutC(get_quant_L_msuOutC), 
						  .L_msuIn(L_msuIn), 
						  .L_shlIn(L_shlIn), 
						  .L_shlOutVar1(get_quant_L_shlOutVar1),
						  .L_shlReady(get_quant_L_shlReady), 
						  .L_shlDone(L_shlDone), 
						  .L_shlNumShiftOut(get_quant_L_shlNumShiftOut), 
						  .memOut(get_quant_MemOut), 
						  .memReadAddr(get_quant_MemReadAddr), 
						  .memWriteAddr(get_quant_MemWriteAddr), 
						  .memWriteEn(get_quant_MemWriteEn), 
						  .constantMemAddr(get_quant_ConstantMemAddr), 
						  .done(get_quant_Done)
						  );
							  
	always @(*)
   begin
		nextstate = state;
		nexttemp = temp;
		nexttempIndex = tempIndex;
		nextcount1 = count1;
		nextcount2 = count2;
		nexttempCandCur = tempCandCur;
		nexttempCand = tempCand;
		nexttempIndex1 = tempIndex1;
		nexttempIndex2 = tempIndex2;
		nextselect1Lspcb1 = select1Lspcb1;
		nextselectFg = selectFg;
		nextselectFgSum = selectFgSum;
		nextselectFgSumInv = selectFgSumInv;
		nextselectLTdist = selectLTdist;
		memOut = 0;
		memReadAddr = 0;
		memWriteAddr = 0;
		memWriteEn = 0;
		tempCandCurLD = 0;
		tempCandCurReset = 0;
		tempIndexLD = 0;
		tempIndexReset = 0;
		tempCandLD = 0;
		tempIndex1LD = 0;
		tempIndex2LD = 0;
		tempCandReset = 0;
		tempIndex1Reset = 0;
		tempIndex2Reset = 0;
		select1Lspcb1Reset = 0;
		selectFgReset = 0;
		selectFgSumReset = 0;
		selectLTdistReset = 0;
		selectFgSumInvReset = 0;
		tempReset = 0;
		L_addOutA = 0;
		L_addOutB = 0;
		L_subOutA = 0;
		L_subOutB = 0;
		L_multOutA = 0;
		L_multOutB = 0;
		L_macOutA = 0;
		L_macOutB = 0;
		L_macOutC = 0;
		L_msuOutA = 0;
		L_msuOutB = 0;
		L_msuOutC = 0;
		L_shlOutVar1 = 0;
		L_shlReady = 0;
		L_shlNumShiftOut = 0;
		addOutA = 0;
		addOutB = 0;
		subOutA = 0;
		subOutB = 0;
		multOutA = 0;
		multOutB = 0;
		shrVar1Out = 0;
		shrVar2Out = 0;
		shlOutVar1 = 0;
		shlOutVar2 = 0;
		prev_extract_Start = 0;
		pre_select_Start = 0;
		select_1_Start = 0;
		expand_1_Start = 0;
		select_2_Start = 0;
		expand_2_Start = 0;
		expand_1_2_Start = 0;
		get_tdist_Start = 0;
		last_select_Start = 0;
		get_quant_Start = 0;
		done = 0;
		constantMemAddr = 0;	
		count1LD = 0;
		count2LD = 0;
		count1Reset = 0;
		count2Reset = 0;
		
		case(state)
		
			STATE_INIT:		//state 0
			begin
				count1Reset = 1;
				if(start == 0)
					nextstate = STATE_INIT;
				else 
				begin
					nextstate = STATE_COUNT_LOOP1;
				end
			end
			
			STATE_COUNT_LOOP1:	//state 1
			begin
				if(count1 >= MODE)
				begin
					nextstate = LAST_SELECT;
					count1Reset = 1;
				end
				else if(count1 < MODE)
				begin
					nextstate = PREV_EXTRACT;
					nextselectFg = {FG[11:7], count1[0], FG[5:0]};
					selectFgLD = 1;
					nextselectFgSumInv = {FG_SUM_INV[11:5], count1[0], FG_SUM_INV[3:0]};
					selectFgSumInvLD = 1;
				end	
			end
			
			//Lsp_prev_extract(lsp, rbuf, fg[mode], freq_prev, fg_sum_inv[mode]);
			PREV_EXTRACT:	//state 2
			begin		
				prev_extract_Start = 1;
				L_msuOutA = prev_extract_L_msuOutA;
				L_msuOutB = prev_extract_L_msuOutB;
				L_msuOutC = prev_extract_L_msuOutC;
				L_multOutA = prev_extract_L_multOutA;
				L_multOutB = prev_extract_L_multOutB;
				addOutA = prev_extract_AddOutA;
				addOutB = prev_extract_AddOutB;
				L_shlOutVar1 = prev_extract_L_shlOutVar1;
				L_shlNumShiftOut = prev_extract_L_shlNumShiftOut;
				L_shlReady = prev_extract_L_shlReady;
				memOut = prev_extract_MemOut;
				memReadAddr = prev_extract_MemReadAddr;  
				memWriteAddr = prev_extract_MemWriteAddr;
				constantMemAddr = prev_extract_ConstantMemAddr;
				memWriteEn = prev_extract_MemWriteEn;
			
				if(prev_extract_Done == 0)
					nextstate = PREV_EXTRACT;
				else if(prev_extract_Done == 1)
				begin
					nextstate = PRE_SELECT;
					prev_extract_Start = 0;
				end
			end
			
			//Lsp_pre_select(rbuf, lspcb1, &cand_cur );
			PRE_SELECT:	//state 3
			begin
				pre_select_Start = 1;
				subOutA = pre_select_subOutA; 
				subOutB = pre_select_subOutB;
				L_macOutA = pre_select_L_macOutA; 
				L_macOutB = pre_select_L_macOutB;
				L_macOutC = pre_select_L_macOutC;
				addOutA = pre_select_AddOutA; 
				addOutB = pre_select_AddOutB;
				L_subOutA = pre_select_L_subOutA; 
				L_subOutB = pre_select_L_subOutB;
				memOut = pre_select_MemOut;
				memReadAddr = pre_select_MemReadAddr;  
				memWriteAddr = pre_select_MemWriteAddr;
				constantMemAddr = pre_select_ConstantMemAddr;
				memWriteEn = pre_select_MemWriteEn;
				
				if(pre_select_Done == 0)
					nextstate = PRE_SELECT;
				else if(pre_select_Done == 1)
				begin
					memReadAddr = RELSPWED_CAND_CUR;
					nextstate = COPY_CAND;
					pre_select_Start = 0;
				end
			end
			
			//cand[mode] = cand_cur;
			COPY_CAND:	//state 4
			begin
				nexttempCandCur = memIn[15:0];
				tempCandCurLD = 1;
				memWriteAddr = {RELSPWED_CAND[11:1] , count1[0]};
				memOut = memIn[15:0];
				memWriteEn = 1;
				nextstate = COPY_CAND_1;
			end
			
			COPY_CAND_1:
			begin
				nextselect1Lspcb1 = {LSPCB1[11], tempCandCur[6:0], 4'd0};
				select1Lspcb1LD = 1;
				nextstate = SELECT_1;
			end
			
			//Lsp_select_1(rbuf, lspcb1[cand_cur], wegt, lspcb2, &index);
			SELECT_1:	//state 5
			begin
				select_1_Start = 1;
				L_subOutA = select_1_L_subOutA;
				L_subOutB = select_1_L_subOutB;
				L_addOutA = select_1_L_addOutA; 
				L_addOutB = select_1_L_addOutB;
				subOutA = select_1_subOutA; 
				subOutB = select_1_subOutB;
				multOutA = select_1_multOutA; 
				multOutB = select_1_multOutB;
				L_macOutA = select_1_L_macOutA;
				L_macOutB = select_1_L_macOutB;
				L_macOutC = select_1_L_macOutC;
				memOut = select_1_MemOut;
				memReadAddr = select_1_MemReadAddr;  
				memWriteAddr = select_1_MemWriteAddr;
				constantMemAddr = select_1_ConstantMemAddr;
				memWriteEn = select_1_MemWriteEn;
				
				if(select_1_Done == 0)
					nextstate = SELECT_1;
				else if(select_1_Done == 1)
				begin
					memReadAddr = RELSPWED_INDEX;
					nextstate = COPY_INDEX;
					select_1_Start = 0;
				end
			end
			
			//tindex1[mode] = index;
			COPY_INDEX:	//state 6
			begin
				nexttempIndex = memIn[15:0];
				tempIndexLD = 1;
				memWriteAddr = {RELSPWED_TINDEX1[11:1], count1[0]};
				memOut = memIn[15:0];
				memWriteEn = 1;
				nextstate = FOR_LOOP2;
			end
			
			//for( j = 0 ; j < NC ; j++ )
			FOR_LOOP2:	//state 7
			begin
				if(count2 >= NC)
				begin
					nextstate = EXPAND_1;
					count2Reset = 1;
				end
				else if(count2 < NC)
				begin
					constantMemAddr = {LSPCB1[11], tempCandCur[6:0], count2[3:0]};
					nextstate = ADD_CB1_1;
				end
			end
			
			//buf[j] = add( lspcb1[cand_cur][j], lspcb2[index][j] );
			ADD_CB1_1:	//state 8
			begin
				nexttemp = constantMemIn[15:0];
				tempLD = 1;
				constantMemAddr = {LSPCB2[11], tempIndex[6:0], count2[3:0]};
				nextstate = ADD_CB1_2;
			end
			
			ADD_CB1_2:	//state 9
			begin
				addOutA = temp;
				addOutB = constantMemIn[15:0];
				memWriteAddr = {RELSPWED_BUF[11:4], count2[3:0]};
				memOut = addIn[15:0];
				memWriteEn = 1;
				L_addOutA = count2;
				L_addOutB = 1;
				nextcount2 = L_addIn[5:0];
				count2LD = 1;
				nextstate = FOR_LOOP2;
			end
			
			//Lsp_expand_1(buf, GAP1);
			EXPAND_1:	//state 10
			begin
				expand_1_Start = 1;
				subOutA = expand_1_subOutA;
				subOutB = expand_1_subOutB;
				shrVar1Out = expand_1_ShrVar1Out;
				shrVar2Out = expand_1_ShrVar2Out;
				addOutA = expand_1_addOutA;
				addOutB = expand_1_addOutB;
				L_subOutA = expand_1_L_subOutA;
				L_subOutB = expand_1_L_subOutB;
				L_addOutA = expand_1_L_addOutA; 
				L_addOutB = expand_1_L_addOutB;
				memOut = expand_1_MemOut;
				memReadAddr = expand_1_MemReadAddr;
				memWriteAddr = expand_1_MemWriteAddr;
				memWriteEn = expand_1_MemWriteEn;
				
				if(expand_1_Done == 0)
					nextstate = EXPAND_1;
				else if(expand_1_Done == 1)
				begin
					nextselect1Lspcb1 = {LSPCB1[11], tempCandCur[6:0], 4'd0};
					select1Lspcb1LD = 1;
					nextstate = SELECT_2;
					expand_1_Start = 0;
				end
			end
			
			//Lsp_select_2(rbuf, lspcb1[cand_cur], wegt, lspcb2, &index);
			SELECT_2:
			begin
				select_2_Start = 1;
				L_subOutA = select_2_L_subOutA; 
				L_subOutB = select_2_L_subOutB;
				L_addOutA = select_2_L_addOutA; 
				L_addOutB = select_2_L_addOutB;
				subOutA = select_2_subOutA; 
				subOutB = select_2_subOutB;
				multOutA = select_2_multOutA;
				multOutB = select_2_multOutB;
				L_macOutA = select_2_L_macOutA; 
				L_macOutB = select_2_L_macOutB;
				L_macOutC = select_2_L_macOutC;
				memOut = select_2_MemOut;
				memReadAddr = select_2_MemReadAddr;  
				memWriteAddr = select_2_MemWriteAddr;
				constantMemAddr = select_2_ConstantMemAddr;
				memWriteEn = select_2_MemWriteEn;
				
				if(select_2_Done == 0)
					nextstate = SELECT_2;
				else if(select_2_Done == 1)
				begin
					memReadAddr = RELSPWED_INDEX;
					nextstate = COPY_INDEX2;
					select_2_Start = 0;
				end
			end
			
			//tindex2[mode] = index;
			COPY_INDEX2:
			begin
				nexttempIndex = memIn[15:0];
				tempIndexLD = 1;
				memWriteAddr = {RELSPWED_TINDEX2[11:1], count1[0]};
				memOut = memIn[15:0];
				memWriteEn = 1;
				nextcount2 = NC;
				count2LD = 1;
				nextstate = FOR_LOOP3;
			end
			
			//for( j = NC ; j < M ; j++ )
			FOR_LOOP3:	//State 13
			begin
				if(count2 >= M)
				begin
					nextstate = EXPAND_2;
					count2Reset = 1;
				end
				else if(count2 < M)
				begin
					constantMemAddr = {LSPCB1[11], tempCandCur[6:0], count2[3:0]};
					nextstate = ADD_CB2_1;
				end
			end
			
			//buf[j] = add( lspcb1[cand_cur][j], lspcb2[index][j] );
			ADD_CB2_1:	//state 14
			begin
				nexttemp = constantMemIn[15:0];
				tempLD = 1;
				constantMemAddr = {LSPCB2[11], tempIndex[6:0], count2[3:0]};
				nextstate = ADD_CB2_2;
			end
			
			ADD_CB2_2:	//state 15
			begin
				addOutA = temp;
				addOutB = constantMemIn[15:0];
				memWriteAddr = {RELSPWED_BUF[11:4], count2[3:0]};
				memOut = addIn[15:0];
				memWriteEn = 1;
				L_addOutA = count2;
				L_addOutB = 1;
				nextcount2 = L_addIn[5:0];
				count2LD = 1;
				nextstate = FOR_LOOP3;
			end
			
			//Lsp_expand_2(buf, GAP1);
			EXPAND_2:
			begin
				expand_2_Start = 1;
				subOutA = expand_2_subOutA;
				subOutB = expand_2_subOutB;
				shrVar1Out = expand_2_ShrVar1Out;
				shrVar2Out = expand_2_ShrVar2Out;
				addOutA = expand_2_addOutA;
				addOutB = expand_2_addOutB;
				L_subOutA = expand_2_L_subOutA;
				L_subOutB = expand_2_L_subOutB;
				L_addOutA = expand_2_L_addOutA;
				L_addOutB = expand_2_L_addOutB;
				memOut = expand_2_MemOut;
				memReadAddr = expand_2_MemReadAddr;  
				memWriteAddr = expand_2_MemWriteAddr;
				memWriteEn = expand_2_MemWriteEn;
				
				if(expand_2_Done == 0)
					nextstate = EXPAND_2;
				else if(expand_2_Done == 1)
				begin
					nextstate = EXPAND_1_2;
					expand_2_Start = 0;
				end
			end
			
			//Lsp_expand_1_2(buf, GAP2);
			EXPAND_1_2:
			begin
				expand_1_2_Start = 1;
				subOutA = expand_1_2_subOutA; 
				subOutB = expand_1_2_subOutB;
				shrVar1Out = expand_1_2_ShrVar1Out;
				shrVar2Out = expand_1_2_ShrVar2Out;
				addOutA = expand_1_2_addOutA; 
				addOutB = expand_1_2_addOutB;
				L_subOutA = expand_1_2_L_subOutA; 
				L_subOutB = expand_1_2_L_subOutB;
				L_addOutA = expand_1_2_L_addOutA;
				L_addOutB = expand_1_2_L_addOutB;
				memOut = expand_1_2_MemOut;
				memReadAddr = expand_1_2_MemReadAddr;
				memWriteAddr = expand_1_2_MemWriteAddr;
				memWriteEn = expand_1_2_MemWriteEn;
				
				if(expand_1_2_Done == 0)
					nextstate = EXPAND_1_2;
				else if(expand_1_2_Done == 1)
				begin
					nextselectFgSum = {FG_SUM[11:5], count1[0], FG_SUM[3:0]};
					selectFgSumLD = 1;
					nextselectLTdist = {RELSPWED_L_TDIST[11:1], count1[0]};
					selectLTdistLD = 1;
					nextstate = GET_TDIST;
					expand_1_2_Start = 0;
				end
			end
			
			GET_TDIST:
			begin
				get_tdist_Start = 1;
				multOutA = get_tdist_multOutA;
				multOutB = get_tdist_multOutB;
				L_multOutA = get_tdist_L_multOutA;
				L_multOutB = get_tdist_L_multOutB;
				L_shlOutVar1 = get_tdist_L_shlOutVar1;
				L_shlReady = get_tdist_L_shlReady;
				L_shlNumShiftOut = get_tdist_L_shlNumShiftOut;
				addOutA = get_tdist_addOutA; 
				addOutB = get_tdist_addOutB;
				subOutA = get_tdist_subOutA; 
				subOutB = get_tdist_subOutB;
				L_macOutA = get_tdist_L_macOutA;
				L_macOutB = get_tdist_L_macOutB;
				L_macOutC = get_tdist_L_macOutC;
				memOut = get_tdist_MemOut;
				memReadAddr = get_tdist_MemReadAddr;
				memWriteAddr = get_tdist_MemWriteAddr;
				constantMemAddr = get_tdist_ConstantMemAddr;
				memWriteEn = get_tdist_MemWriteEn;
				
				
				if(get_tdist_Done == 0)
					nextstate = GET_TDIST;
				else if(get_tdist_Done == 1)
				begin
					addOutA = count1;
					addOutB = 1;
					nextcount1 = addIn[5:0];
					count1LD = 1;
					nextstate = STATE_COUNT_LOOP1;
					get_tdist_Start = 0;
				end
			end
			
			LAST_SELECT:
			begin
				last_select_Start = 1;
				L_subOutA = last_select_L_subOutA;
				L_subOutB = last_select_L_subOutB;
				memOut = last_select_MemOut;
				memReadAddr = last_select_MemReadAddr;  
				memWriteAddr = last_select_MemWriteAddr;
				memWriteEn = last_select_MemWriteEn;
				
				if(last_select_Done == 0)
					nextstate = LAST_SELECT;
				else if(last_select_Done == 1)
				begin
					memReadAddr = QUA_LSP_MODE_INDEX;
					nextstate = SHL_1;
					last_select_Start = 0;
				end
			end
			
			SHL_1:	//state 20
			begin
				shlOutVar1 = memIn[15:0];
				shlOutVar2 = NC0_B;
				nexttemp = shlIn[15:0];
				tempLD = 1;
				memReadAddr = {RELSPWED_CAND[11:1], memIn[0]};
				nextstate = SHL_2;
			end
			
			SHL_2:	//state 21
			begin
				memWriteAddr = code_anaAddr[11:0];
				memOut = temp[15:0] | memIn[15:0];
				memWriteEn = 1;
				memReadAddr = QUA_LSP_MODE_INDEX;
				nextstate = SHL_3;
			end
			
			SHL_3:	//state 22
			begin
				nexttempIndex = memIn[15:0];
				tempIndexLD = 1;
				memReadAddr = {RELSPWED_TINDEX1[11:1], memIn[0]};
				nextstate = SHL_4;
			end
			
			SHL_4:	//state 23
			begin
				shlOutVar1 = memIn[15:0];
				shlOutVar2 = NC1_B;
				nexttemp = shlIn;
				tempLD = 1;
				memReadAddr = {RELSPWED_TINDEX2[11:1], tempIndex[0]};
				nextstate = SHL_5;
			end
			
			SHL_5:	//state 24
			begin
				memWriteAddr = {code_anaAddr[11:1], 1'd1};
				memReadAddr = {RELSPWED_CAND[11:1], tempIndex[0]};
				memOut = temp[15:0] | memIn[15:0];
				memWriteEn = 1;
				nextstate = GET_QUANT_1;
			end
			
			GET_QUANT_1:
			begin
				nexttempCand = memIn[15:0];
				tempCandLD = 1;
				memReadAddr = {RELSPWED_TINDEX1[11:1], tempIndex[0]};
				nextstate = GET_QUANT_2;
			end
			
			GET_QUANT_2:
			begin
				nexttempIndex1 = memIn[15:0];
				tempIndex1LD = 1;
				memReadAddr = {RELSPWED_TINDEX2[11:1], tempIndex[0]};
				nextstate = GET_QUANT_3;
			end
			
			GET_QUANT_3:
			begin
				nexttempIndex2 = memIn[15:0];
				tempIndex2LD = 1;
				nextselectFg = {FG[11:7], tempIndex[0], FG[5:0]};
				selectFgLD = 1;
				nextselectFgSum = {FG_SUM[11:5], tempIndex[0], FG_SUM[3:0]};
				selectFgSumLD = 1;
				nextstate = GET_QUANT_4;
			end
			
			GET_QUANT_4:
			begin
				get_quant_Start = 1;
				L_subOutA = get_quant_L_subOutA; 
				L_subOutB = get_quant_L_subOutB;
				L_addOutA = get_quant_L_addOutA;
				L_addOutB = get_quant_L_addOutB;
				L_multOutA = get_quant_multOutA;
				L_multOutB = get_quant_multOutB;
				L_macOutA = get_quant_L_macOutA; 
				L_macOutB = get_quant_L_macOutB;
				L_macOutC = get_quant_L_macOutC;
				L_msuOutA = get_quant_L_msuOutA;
				L_msuOutB = get_quant_L_msuOutB;
				L_msuOutC = get_quant_L_msuOutC;
				L_shlOutVar1 = get_quant_L_shlOutVar1;
				L_shlReady = get_quant_L_shlReady;
				L_shlNumShiftOut = get_quant_L_shlNumShiftOut;
				multOutA = get_quant_multOutA;
				multOutB = get_quant_multOutB;
				addOutA = get_quant_addOutA; 
				addOutB = get_quant_addOutB;
				subOutA = get_quant_subOutA;
				subOutB = get_quant_subOutB;
				shrVar1Out = get_quant_ShrVar1Out;
				shrVar2Out = get_quant_ShrVar2Out;
				memOut = get_quant_MemOut;
				memReadAddr = get_quant_MemReadAddr;
				memWriteAddr = get_quant_MemWriteAddr;
				constantMemAddr = get_quant_ConstantMemAddr;
				memWriteEn = get_quant_MemWriteEn;
				
				if(get_quant_Done == 0)
					nextstate = GET_QUANT_4;
				else if(get_quant_Done == 1)
				begin
					nextstate = STATE_INIT;
					done = 1;
					get_quant_Start = 0;
				end
			end
				
		endcase
		
	end
							  
endmodule