	`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:59:22 04/07/2011 
// Design Name: 
// Module Name:    lsp_qua_cs_FSM 
// Project Name: 
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
module Qua_lsp_FSM(clk, reset, start, L_addIn, L_subIn, L_multIn, L_macIn, addIn, subIn,  
							shrIn, memIn, constantMemIn, L_addOutA, L_addOutB, L_subOutA, L_subOutB, 
							L_multOutA, L_multOutB, L_macOutA, L_macOutB, L_macOutC, addOutA, addOutB, subOutA, 
							subOutB, shrVar1Out, shrVar2Out, L_msuOutA, L_msuOutB, L_msuOutC, L_msuIn, L_shlIn, 
							L_shlOutVar1, L_shlReady, L_shlDone, L_shlNumShiftOut, multOutA, multOutB, memOut, 
							multIn, memReadAddr, memWriteAddr, memWriteEn, constantMemAddr, done,
							lsp_qAddr, shlOutVar1, shlOutVar2, shlIn, norm_sIn, norm_sDone, L_shrIn,
							norm_sOut, norm_sReady, lspAddr, anaAddr, L_shrVar1Out, L_shrNumShiftOut, 
							freq_prevAddr
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
	input [15:0] norm_sIn;
	input [15:0] multIn;
	input [31:0] L_shlIn;
	input [31:0] L_shrIn;
	input L_shlDone;
	input [31:0] memIn;
	input [31:0] constantMemIn;
	input [11:0] anaAddr;
	input [11:0] lsp_qAddr;
	input [11:0] lspAddr;
	input [11:0] freq_prevAddr;
	input norm_sDone;
	
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
	output reg [31:0] L_shrVar1Out;
	output reg [15:0] L_shrNumShiftOut;
	output reg [15:0] norm_sOut;
	output reg norm_sReady;
	output reg [31:0] memOut;
	output reg [11:0] memReadAddr;
	output reg [11:0] memWriteAddr;
	output reg memWriteEn;
	output reg [11:0] constantMemAddr;
	output reg done;
	output reg L_shlReady;
	
	//state parameters
	parameter STATE_INIT = 5'd0;
	parameter STATE_LSP_LSF2 = 5'd1;
	parameter STATE_LSP_QUA_CS= 5'd2;
	parameter STATE_LSF_LSP2= 5'd3;
	
	//Internal wires and regs
	reg [4:0] state, nextstate;
	
	//lsf_lsp2 wires and regs
	reg lsf_lsp2_Start;
	wire lsf_lsp2_Done;
	wire [15:0] lsf_lsp2_L_multOutA, lsf_lsp2_L_multOutB;
	wire [15:0] lsf_lsp2_multOutA, lsf_lsp2_multOutB;
	wire [15:0] lsf_lsp2_AddOutA, lsf_lsp2_AddOutB;
	wire [15:0] lsf_lsp2_subOutA, lsf_lsp2_subOutB;
	wire [15:0] lsf_lsp2_ShrVar1Out, lsf_lsp2_ShrVar2Out;
	wire [31:0] lsf_lsp2_L_shrVar1Out;
	wire [15:0] lsf_lsp2_L_shrNumShiftOut;
	wire [31:0] lsf_lsp2_MemOut;
	wire [11:0] lsf_lsp2_MemReadAddr,  lsf_lsp2_MemWriteAddr;
	wire [11:0] lsf_lsp2_ConstantMemAddr;
	wire lsf_lsp2_MemWriteEn;
	
	//lsp_qua_cs wires and regs
	reg lsp_qua_cs_Start;
	wire lsp_qua_cs_Done;
	wire [31:0] lsp_qua_cs_L_addOutA, lsp_qua_cs_L_addOutB;
	wire [31:0] lsp_qua_cs_L_subOutA, lsp_qua_cs_L_subOutB;
	wire [15:0] lsp_qua_cs_L_msuOutA, lsp_qua_cs_L_msuOutB;
	wire [31:0] lsp_qua_cs_L_msuOutC;
	wire [15:0] lsp_qua_cs_L_multOutA, lsp_qua_cs_L_multOutB;
	wire [15:0] lsp_qua_cs_L_macOutA, lsp_qua_cs_L_macOutB;
	wire [31:0] lsp_qua_cs_L_macOutC;
	wire [15:0] lsp_qua_cs_multOutA, lsp_qua_cs_multOutB;
	wire [15:0] lsp_qua_cs_AddOutA, lsp_qua_cs_AddOutB;
	wire [15:0] lsp_qua_cs_subOutA, lsp_qua_cs_subOutB;
	wire [15:0] lsp_qua_cs_ShrVar1Out, lsp_qua_cs_ShrVar2Out;
	wire [31:0] lsp_qua_cs_L_shlOutVar1;
	wire [15:0] lsp_qua_cs_L_shlNumShiftOut;
	wire lsp_qua_cs_L_shlReady;
	wire [15:0] lsp_qua_cs_shlOutVar1, lsp_qua_cs_shlOutVar2;
	wire [15:0] lsp_qua_cs_norm_sOut;
	wire lsp_qua_cs_norm_sReady;
	wire [31:0] lsp_qua_cs_MemOut;
	wire [11:0] lsp_qua_cs_MemReadAddr,  lsp_qua_cs_MemWriteAddr;
	wire [11:0] lsp_qua_cs_ConstantMemAddr;
	wire lsp_qua_cs_MemWriteEn;
	
	//lsp_lsf2 wires and regs
	reg lsp_lsf2_Start;
	wire lsp_lsf2_Done;
	wire [31:0] lsp_lsf2_L_subOutA, lsp_lsf2_L_subOutB;
	wire [15:0] lsp_lsf2_L_multOutA, lsp_lsf2_L_multOutB;
	wire [15:0] lsp_lsf2_addOutA, lsp_lsf2_addOutB;
	wire [15:0] lsp_lsf2_subOutA, lsp_lsf2_subOutB;
	wire [15:0] lsp_lsf2_multOutA, lsp_lsf2_multOutB;
	wire [15:0] lsp_lsf2_shlOutVar1, lsp_lsf2_shlOutVar2;
	wire [31:0] lsp_lsf2_L_shrVar1Out;
	wire [15:0] lsp_lsf2_L_shrNumShiftOut;
	wire [31:0] lsp_lsf2_MemOut;
	wire [11:0] lsp_lsf2_MemReadAddr,  lsp_lsf2_MemWriteAddr;
	wire [11:0] lsp_lsf2_ConstantMemAddr;
	wire lsp_lsf2_MemWriteEn;
	
	//flip flops
	//state flip flop
	always@(posedge clk)
	begin
		if(reset)
			state <= STATE_INIT;
		else
			state <= nextstate;
	end
	
	
	//Instantiated Modules
	lsp_lsf2FSM lsf2FSM(
						.start(lsp_lsf2_Start),
						.clk(clk),
						.reset(reset),
						.subIn(subIn),
						.L_subIn(L_subIn),
						.L_multIn(L_multIn),
						.addIn(addIn),
						.shlIn(shlIn),
						.L_shrIn(L_shrIn),
						.multIn(multIn),
						.memIn(memIn),
						.constantMemIn(constantMemIn),
						.lspAddr(lspAddr),
						.lsfAddr(QUA_LSP_LSF),
						.subOutA(lsp_lsf2_subOutA),
						.subOutB(lsp_lsf2_subOutB),
						.L_subOutA(lsp_lsf2_L_subOutA),
						.L_subOutB(lsp_lsf2_L_subOutB),
						.L_multOutA(lsp_lsf2_L_multOutA),
						.L_multOutB(lsp_lsf2_L_multOutB),
						.addOutA(lsp_lsf2_addOutA),
						.addOutB(lsp_lsf2_addOutB),
						.L_shrVar1Out(lsp_lsf2_L_shrVar1Out),
						.L_shrNumShiftOut(lsp_lsf2_L_shrNumShiftOut),
						.multOutA(lsp_lsf2_multOutA),
						.multOutB(lsp_lsf2_multOutB),
						.shlVar1Out(lsp_lsf2_shlOutVar1),
						.shlVar2Out(lsp_lsf2_shlOutVar2),
						.memReadAddr(lsp_lsf2_MemReadAddr),
						.memWriteAddr(lsp_lsf2_MemWriteAddr),
						.memOut(lsp_lsf2_MemOut),
						.memWriteEn(lsp_lsf2_MemWriteEn),
						.constantMemAddr(lsp_lsf2_ConstantMemAddr),
						.done(lsp_lsf2_Done)
					);
					
	lsp_qua_cs_FSM qua_cs_FSM(
							.clk(clk), 
							.reset(reset), 
							.start(lsp_qua_cs_Start), 
							.L_addIn(L_addIn), 
							.L_subIn(L_subIn), 
							.L_multIn(L_multIn), 
							.L_macIn(L_macIn), 
							.addIn(addIn), 
							.subIn(subIn),  
							.shrIn(shrIn), 
							.memIn(memIn), 
							.constantMemIn(constantMemIn), 
							.L_addOutA(lsp_qua_cs_L_addOutA), 
							.L_addOutB(lsp_qua_cs_L_addOutB), 
							.L_subOutA(lsp_qua_cs_L_subOutA), 
							.L_subOutB(lsp_qua_cs_L_subOutB), 
							.L_multOutA(lsp_qua_cs_L_multOutA), 
							.L_multOutB(lsp_qua_cs_L_multOutB), 
							.L_macOutA(lsp_qua_cs_L_macOutA), 
							.L_macOutB(lsp_qua_cs_L_macOutB), 
							.L_macOutC(lsp_qua_cs_L_macOutC), 
							.addOutA(lsp_qua_cs_AddOutA), 
							.addOutB(lsp_qua_cs_AddOutB), 
							.subOutA(lsp_qua_cs_subOutA), 
							.subOutB(lsp_qua_cs_subOutB), 
							.shrVar1Out(lsp_qua_cs_ShrVar1Out), 
							.shrVar2Out(lsp_qua_cs_ShrVar2Out), 
							.L_msuOutA(lsp_qua_cs_L_msuOutA), 
							.L_msuOutB(lsp_qua_cs_L_msuOutB), 
							.L_msuOutC(lsp_qua_cs_L_msuOutC), 
							.L_msuIn(L_msuIn), 
							.L_shlIn(L_shlIn), 
							.L_shlOutVar1(lsp_qua_cs_L_shlOutVar1), 
							.L_shlReady(lsp_qua_cs_L_shlReady), 
							.L_shlDone(L_shlDone), 
							.L_shlNumShiftOut(lsp_qua_cs_L_shlNumShiftOut), 
							.multOutA(lsp_qua_cs_multOutA), 
							.multOutB(lsp_qua_cs_multOutB), 
							.memOut(lsp_qua_cs_MemOut), 
							.multIn(multIn), 
							.memReadAddr(lsp_qua_cs_MemReadAddr), 
							.memWriteAddr(lsp_qua_cs_MemWriteAddr), 
							.memWriteEn(lsp_qua_cs_MemWriteEn), 
							.constantMemAddr(lsp_qua_cs_ConstantMemAddr), 
							.done(lsp_qua_cs_Done), 
							.flspAddr(QUA_LSP_LSF),
							.lspqAddr(QUA_LSP_LSF_Q),
							.freq_prevAddr(freq_prevAddr),
							.shlOutVar1(lsp_qua_cs_shlOutVar1), 
							.shlOutVar2(lsp_qua_cs_shlOutVar2), 
							.shlIn(shlIn), 
							.norm_sIn(norm_sIn), 
							.norm_sDone(norm_sDone),
							.norm_sOut(lsp_qua_cs_norm_sOut), 
							.norm_sReady(lsp_qua_cs_norm_sReady), 
							.code_anaAddr(anaAddr)
					);
					
	lsf_lsp2FSM lsp2FSM(
						.start(lsf_lsp2_Start),
						.clk(clk),
						.reset(reset),
						.lsfAddr(QUA_LSP_LSF_Q),
						.lspAddr(lsp_qAddr),
						.multIn(multIn),
						.shrIn(shrIn),
						.subIn(subIn),
						.L_multIn(L_multIn),
						.addIn(addIn),
						.L_shrIn(L_shrIn),
						.constantMemIn(constantMemIn),
						.memIn(memIn),
						.multOutA(lsf_lsp2_multOutA),
						.multOutB(lsf_lsp2_multOutB),
						.shrVar1Out(lsf_lsp2_ShrVar1Out),
						.shrVar2Out(lsf_lsp2_ShrVar2Out),
						.subOutA(lsf_lsp2_subOutA),
						.subOutB(lsf_lsp2_subOutB),
						.L_multOutA(lsf_lsp2_L_multOutA),
						.L_multOutB(lsf_lsp2_L_multOutB),
						.addOutA(lsf_lsp2_AddOutA),
						.addOutB(lsf_lsp2_AddOutB),
						.L_shrVar1Out(lsf_lsp2_L_shrVar1Out),
						.L_shrNumShiftOut(lsf_lsp2_L_shrNumShiftOut),
						.constantMemAddr(lsf_lsp2_ConstantMemAddr),
						.memReadAddr(lsf_lsp2_MemReadAddr),
						.memWriteAddr(lsf_lsp2_MemWriteAddr),
						.memOut(lsf_lsp2_MemOut),
						.memWriteEn(lsf_lsp2_MemWriteEn),
						.done(lsf_lsp2_Done)
					);
	
				
	always @(*)
   begin
		memOut = 0;
		memWriteEn = 0;
		memWriteAddr = 0;
		memReadAddr = 0;
		constantMemAddr = 0;	
		done = 0;
		lsf_lsp2_Start = 0;
		lsp_qua_cs_Start = 0;
		lsp_lsf2_Start = 0;
		nextstate = state;
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
		L_shrVar1Out = 0;
		L_shrNumShiftOut = 0;
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
		norm_sReady = 0;
		norm_sOut = 0;	
		
		case(state)
		
			STATE_INIT:		//state 0
			begin
				if(start == 0)
					nextstate = STATE_INIT;
				else if(start == 1)
				begin
					nextstate = STATE_LSP_LSF2;
				end
			end
			
			STATE_LSP_LSF2:
			begin
			
				lsp_lsf2_Start = 1;
				L_subOutA = lsp_lsf2_L_subOutA;
				L_subOutB = lsp_lsf2_L_subOutB;
				L_multOutA = lsp_lsf2_L_multOutA;
				L_multOutB = lsp_lsf2_L_multOutB;
				addOutA = lsp_lsf2_addOutA;
				addOutB = lsp_lsf2_addOutB;
				subOutA = lsp_lsf2_subOutA; 
				subOutB = lsp_lsf2_subOutB;
				multOutA = lsp_lsf2_multOutA; 
				multOutB = lsp_lsf2_multOutB;
				shlOutVar1 = lsp_lsf2_shlOutVar1; 
				shlOutVar2 = lsp_lsf2_shlOutVar2;
				L_shrVar1Out = lsp_lsf2_L_shrVar1Out;
				L_shrNumShiftOut = lsp_lsf2_L_shrNumShiftOut;
				memOut = lsp_lsf2_MemOut;
				memReadAddr = lsp_lsf2_MemReadAddr;
				memWriteAddr = lsp_lsf2_MemWriteAddr;
				constantMemAddr = lsp_lsf2_ConstantMemAddr;
				memWriteEn = lsp_lsf2_MemWriteEn;
	
				if(lsp_lsf2_Done == 0)
					nextstate = STATE_LSP_LSF2;
				else if(lsp_lsf2_Done == 1)
				begin
					nextstate = STATE_LSP_QUA_CS;
					lsp_lsf2_Start = 0;
				end
			end
			
			STATE_LSP_QUA_CS:
			begin
				lsp_qua_cs_Start = 1;
				L_addOutA = lsp_qua_cs_L_addOutA;
				L_addOutB = lsp_qua_cs_L_addOutB;
				L_subOutA = lsp_qua_cs_L_subOutA;
				L_subOutB = lsp_qua_cs_L_subOutB;
				L_msuOutA = lsp_qua_cs_L_msuOutA;
				L_msuOutB = lsp_qua_cs_L_msuOutB;
				L_msuOutC = lsp_qua_cs_L_msuOutC;
				L_multOutA = lsp_qua_cs_L_multOutA;
				L_multOutB = lsp_qua_cs_L_multOutB;
				L_macOutA = lsp_qua_cs_L_macOutA;
				L_macOutB = lsp_qua_cs_L_macOutB;
				L_macOutC = lsp_qua_cs_L_macOutC;
				multOutA = lsp_qua_cs_multOutA; 
				multOutB = lsp_qua_cs_multOutB;
				addOutA = lsp_qua_cs_AddOutA;
				addOutB = lsp_qua_cs_AddOutB;
				subOutA = lsp_qua_cs_subOutA; 
				subOutB = lsp_qua_cs_subOutB;
				shrVar1Out = lsp_qua_cs_ShrVar1Out;
				shrVar2Out = lsp_qua_cs_ShrVar2Out;
				L_shlOutVar1 = lsp_qua_cs_L_shlOutVar1;
				L_shlNumShiftOut = lsp_qua_cs_L_shlNumShiftOut;
				L_shlReady = lsp_qua_cs_L_shlReady;
				shlOutVar1 = lsp_qua_cs_shlOutVar1;
				shlOutVar2 = lsp_qua_cs_shlOutVar2;
				norm_sOut = lsp_qua_cs_norm_sOut;
				norm_sReady = lsp_qua_cs_norm_sReady;
				memOut = lsp_qua_cs_MemOut;
				memReadAddr = lsp_qua_cs_MemReadAddr;
				memWriteAddr = lsp_qua_cs_MemWriteAddr;
				constantMemAddr = lsp_qua_cs_ConstantMemAddr;
				memWriteEn = lsp_qua_cs_MemWriteEn;
	
				if(lsp_qua_cs_Done == 0)
					nextstate = STATE_LSP_QUA_CS;
				else if(lsp_qua_cs_Done == 1)
				begin
					nextstate = STATE_LSF_LSP2;
					lsp_qua_cs_Start = 0;
				end
				
			end
			
			STATE_LSF_LSP2:
			begin
				
				lsf_lsp2_Start = 1;
				L_multOutA = lsf_lsp2_L_multOutA;
				L_multOutB = lsf_lsp2_L_multOutB;
				multOutA = lsf_lsp2_multOutA;
				multOutB = lsf_lsp2_multOutB;
				addOutA = lsf_lsp2_AddOutA;
				addOutB = lsf_lsp2_AddOutB;
				subOutA = lsf_lsp2_subOutA; 
				subOutB = lsf_lsp2_subOutB;
				shrVar1Out = lsf_lsp2_ShrVar1Out;
				shrVar2Out = lsf_lsp2_ShrVar2Out;
				L_shrVar1Out = lsf_lsp2_L_shrVar1Out;
				L_shrNumShiftOut = lsf_lsp2_L_shrNumShiftOut;
				memOut = lsf_lsp2_MemOut;
				memReadAddr = lsf_lsp2_MemReadAddr;
				memWriteAddr = lsf_lsp2_MemWriteAddr;
				constantMemAddr = lsf_lsp2_ConstantMemAddr;
				memWriteEn = lsf_lsp2_MemWriteEn;
			
				if(lsf_lsp2_Done == 0)
					nextstate = STATE_LSF_LSP2;
				else if(lsf_lsp2_Done == 1)
				begin
					nextstate = STATE_INIT;
					done = 1;
					lsf_lsp2_Start = 0;
				end
			end
			
		endcase
	
	end

endmodule
