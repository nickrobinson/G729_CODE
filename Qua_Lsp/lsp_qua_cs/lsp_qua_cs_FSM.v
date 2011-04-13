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
module lsp_qua_cs_FSM(clk, reset, start, L_addIn, L_subIn, L_multIn, L_macIn, addIn, subIn,  
							shrIn, memIn, constantMemIn, L_addOutA, L_addOutB, L_subOutA, L_subOutB, 
							L_multOutA, L_multOutB, L_macOutA, L_macOutB, L_macOutC, addOutA, addOutB, subOutA, 
							subOutB, shrVar1Out, shrVar2Out, L_msuOutA, L_msuOutB, L_msuOutC, L_msuIn, L_shlIn, 
							L_shlOutVar1, L_shlReady, L_shlDone, L_shlNumShiftOut, multOutA, multOutB, memOut, 
							multIn, memReadAddr, memWriteAddr, memWriteEn, constantMemAddr, done, flspAddr,
							lspqAddr, shlOutVar1, shlOutVar2, shlIn, norm_sIn, norm_sDone,
							norm_sOut, norm_sReady, wegtAddr, freq_prevAddr, code_anaAddr
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
	input L_shlDone;
	input [31:0] memIn;
	input [31:0] constantMemIn;
	input [11:0] flspAddr;
	input [11:0] lspqAddr;
	input [11:0] wegtAddr;
	input [11:0] freq_prevAddr;
	input [11:0] code_anaAddr;
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
	parameter STATE_GET_WEGT = 5'd1;
	parameter STATE_RELSPWED = 5'd2;
	
	//Internal wires and regs
	reg [4:0] state, nextstate;
	
	//Relspwed wires and regs
	reg Relspwed_Start;
	wire Relspwed_Done;
	wire [31:0] Relspwed_L_addOutA, Relspwed_L_addOutB;
	wire [31:0] Relspwed_L_subOutA, Relspwed_L_subOutB;
	wire [15:0] Relspwed_L_msuOutA, Relspwed_L_msuOutB;
	wire [31:0] Relspwed_L_msuOutC;
	wire [15:0] Relspwed_L_multOutA, Relspwed_L_multOutB;
	wire [15:0] Relspwed_L_macOutA, Relspwed_L_macOutB;
	wire [31:0] Relspwed_L_macOutC;
	wire [15:0] Relspwed_multOutA, Relspwed_multOutB;
	wire [15:0] Relspwed_AddOutA, Relspwed_AddOutB;
	wire [15:0] Relspwed_subOutA, Relspwed_subOutB;
	wire [15:0] Relspwed_ShrVar1Out, Relspwed_ShrVar2Out;
	wire [31:0] Relspwed_L_shlOutVar1;
	wire [15:0] Relspwed_L_shlNumShiftOut;
	wire Relspwed_L_shlReady;
	wire [15:0] Relspwed_shlOutVar1, Relspwed_shlOutVar2;
	wire [31:0] Relspwed_MemOut;
	wire [11:0] Relspwed_MemReadAddr,  Relspwed_MemWriteAddr;
	wire [11:0] Relspwed_ConstantMemAddr;
	wire Relspwed_MemWriteEn;
	
	//Get_wegt wires and regs
	reg Get_wegt_Start;
	wire Get_wegt_Done;
	wire [31:0] Get_wegt_L_addOutA, Get_wegt_L_addOutB;
	wire [31:0] Get_wegt_L_subOutA, Get_wegt_L_subOutB;
	wire [15:0] Get_wegt_L_multOutA, Get_wegt_L_multOutB;
	wire [15:0] Get_wegt_addOutA, Get_wegt_addOutB;
	wire [15:0] Get_wegt_subOutA, Get_wegt_subOutB;
	wire [31:0] Get_wegt_L_shlOutVar1;
	wire [15:0] Get_wegt_L_shlNumShiftOut;
	wire Get_wegt_L_shlReady;
	wire [15:0] Get_wegt_norm_sOut;
	wire Get_wegt_norm_sReady;
	wire [31:0] Get_wegt_MemOut;
	wire [11:0] Get_wegt_MemReadAddr,  Get_wegt_MemWriteAddr;
	wire Get_wegt_MemWriteEn;
	
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
	Relspwed_FSM relspwed_fsm(
						.clk(clk), 
						.reset(reset), 
						.start(Relspwed_Start), 
						.L_addIn(L_addIn), 
						.L_subIn(L_subIn), 
						.L_multIn(L_multIn), 
						.L_macIn(L_macIn), 
						.addIn(addIn), 
						.subIn(subIn),  
						.shrIn(shrIn), 
						.memIn(memIn), 
						.constantMemIn(constantMemIn), 
						.L_addOutA(Relspwed_L_addOutA), 
						.L_addOutB(Relspwed_L_addOutB), 
						.L_subOutA(Relspwed_L_subOutA), 
						.L_subOutB(Relspwed_L_subOutB), 
						.L_multOutA(Relspwed_L_multOutA), 
						.L_multOutB(Relspwed_L_multOutB), 
						.L_macOutA(Relspwed_L_macOutA), 
						.L_macOutB(Relspwed_L_macOutB), 
						.L_macOutC(Relspwed_L_macOutC), 
						.addOutA(Relspwed_AddOutA), 
						.addOutB(Relspwed_AddOutB), 
						.subOutA(Relspwed_subOutA), 
						.subOutB(Relspwed_subOutB), 
						.shrVar1Out(Relspwed_ShrVar1Out), 
						.shrVar2Out(Relspwed_ShrVar2Out), 
						.L_msuOutA(Relspwed_L_msuOutA), 
						.L_msuOutB(Relspwed_L_msuOutB), 
						.L_msuOutC(Relspwed_L_msuOutC), 
						.L_msuIn(L_msuIn), 
						.L_shlIn(L_shlIn), 
						.L_shlOutVar1(Relspwed_L_shlOutVar1), 
						.L_shlReady(Relspwed_L_shlReady), 
						.L_shlDone(L_shlDone), 
						.L_shlNumShiftOut(Relspwed_L_shlNumShiftOut), 
						.multOutA(Relspwed_multOutA), 
						.multOutB(Relspwed_multOutB), 
						.memOut(Relspwed_MemOut), 
						.multIn(multIn), 
						.memReadAddr(Relspwed_MemReadAddr), 
						.memWriteAddr(Relspwed_MemWriteAddr), 
						.memWriteEn(Relspwed_MemWriteEn), 
						.constantMemAddr(Relspwed_ConstantMemAddr), 
						.done(Relspwed_Done), 
						.freq_prevAddr(freq_prevAddr), 
						.lspqAddr(lspqAddr), 
						.wegtAddr(wegtAddr), 
						.lspAddr(flspAddr), 
						.code_anaAddr(code_anaAddr), 
						.shlOutVar1(Relspwed_shlOutVar1), 
						.shlOutVar2(Relspwed_shlOutVar2), 
						.shlIn(shlIn)
    );
	 
	 Get_wegt get_wegt_fsm(
					.clk(clk),				
					.reset(reset), 
					.start(Get_wegt_Start), 
					.memIn(memIn), 
					.memWriteEn(Get_wegt_MemWriteEn), 
					.memWriteAddr(Get_wegt_MemWriteAddr), 
					.memReadAddr(Get_wegt_MemReadAddr),
					.memOut(Get_wegt_MemOut), 
					.done(Get_wegt_Done), 
					.subIn(subIn), 
					.addIn(addIn), 
					.subOutA(Get_wegt_subOutA), 
					.subOutB(Get_wegt_subOutB), 
					.addOutA(Get_wegt_addOutA), 
					.addOutB(Get_wegt_addOutB),
					.L_subOutA(Get_wegt_L_subOutA), 
					.L_subOutB(Get_wegt_L_subOutB), 
					.L_subIn(L_subIn), 
					.wegtAddr(wegtAddr), 
					.flspAddr(flspAddr), 
					.L_multOutA(Get_wegt_L_multOutA),
					.L_multOutB(Get_wegt_L_multOutB), 
					.L_multIn(L_multIn), 
					.L_shlIn(L_shlIn), 
					.L_shlDone(L_shlDone), 
					.L_shlOutVar1(Get_wegt_L_shlOutVar1), 
					.L_shlNumShiftOut(Get_wegt_L_shlNumShiftOut),
					.L_shlReady(Get_wegt_L_shlReady), 
					.L_addIn(L_addIn), 
					.L_addOutA(Get_wegt_L_addOutA), 
					.L_addOutB(Get_wegt_L_addOutB), 
					.norm_sIn(norm_sIn), 
					.norm_sDone(norm_sDone),
					.norm_sOut(Get_wegt_norm_sOut), 
					.norm_sReady(Get_wegt_norm_sReady)
					);
					
	always @(*)
   begin
		memOut = 0;
		memWriteEn = 0;
		memWriteAddr = 0;
		memReadAddr = 0;
		constantMemAddr = 0;	
		done = 0;
		Get_wegt_Start = 0;
		Relspwed_Start = 0;
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
				else 
				begin
					nextstate = STATE_GET_WEGT;
				end
			end
			
			STATE_GET_WEGT:
			begin
			
				Get_wegt_Start = 1;
				L_addOutA = Get_wegt_L_addOutA;
				L_addOutB = Get_wegt_L_addOutB;
				L_subOutA = Get_wegt_L_subOutA; 
				L_subOutB = Get_wegt_L_subOutB;
				L_multOutA = Get_wegt_L_multOutA;
				L_multOutB = Get_wegt_L_multOutB;
				addOutA = Get_wegt_addOutA;
				addOutB = Get_wegt_addOutB;
				subOutA = Get_wegt_subOutA; 
				subOutB = Get_wegt_subOutB;
				L_shlOutVar1 = Get_wegt_L_shlOutVar1;
				L_shlNumShiftOut = Get_wegt_L_shlNumShiftOut;
				L_shlReady = Get_wegt_L_shlReady;
				norm_sOut = Get_wegt_norm_sOut;
				norm_sReady = Get_wegt_norm_sReady;
				memOut = Get_wegt_MemOut;
				memReadAddr = Get_wegt_MemReadAddr;  
				memWriteAddr = Get_wegt_MemWriteAddr;
				memWriteEn = Get_wegt_MemWriteEn;
			
			
				if(Get_wegt_Done == 0)
					nextstate = STATE_GET_WEGT;
				else if(Get_wegt_Done == 1)
				begin
					nextstate = STATE_RELSPWED;
					Get_wegt_Start = 0;
				end
			end
			
			STATE_RELSPWED:
			begin
				Relspwed_Start = 1;
				L_addOutA = Relspwed_L_addOutA;
				L_addOutB = Relspwed_L_addOutB;
				L_subOutA = Relspwed_L_subOutA; 
				L_subOutB = Relspwed_L_subOutB;
				L_msuOutA = Relspwed_L_msuOutA; 
				L_msuOutB = Relspwed_L_msuOutB;
				L_msuOutC = Relspwed_L_msuOutC;
				L_multOutA = Relspwed_L_multOutA; 
				L_multOutB = Relspwed_L_multOutB;
				L_macOutA = Relspwed_L_macOutA; 
				L_macOutB = Relspwed_L_macOutB;
				L_macOutC = Relspwed_L_macOutC;
				multOutA = Relspwed_multOutA; 
				multOutB = Relspwed_multOutB;
				addOutA = Relspwed_AddOutA; 
				addOutB = Relspwed_AddOutB;
				subOutA = Relspwed_subOutA; 
				subOutB = Relspwed_subOutB;
				shrVar1Out = Relspwed_ShrVar1Out;
				shrVar2Out = Relspwed_ShrVar2Out;
				L_shlOutVar1 = Relspwed_L_shlOutVar1;
				L_shlNumShiftOut = Relspwed_L_shlNumShiftOut;
				L_shlReady = Relspwed_L_shlReady;
				shlOutVar1 = Relspwed_shlOutVar1;
				shlOutVar2 = Relspwed_shlOutVar2;
				memOut = Relspwed_MemOut;
				memReadAddr = Relspwed_MemReadAddr;
				memWriteAddr = Relspwed_MemWriteAddr;
				constantMemAddr = Relspwed_ConstantMemAddr;
				memWriteEn = Relspwed_MemWriteEn;
	
				if(Relspwed_Done == 0)
					nextstate = STATE_RELSPWED;
				else if(Relspwed_Done == 1)
				begin
					done = 1;
					nextstate = STATE_INIT;
					Relspwed_Start = 0;
				end
				
			end
			
		endcase
	
	end

endmodule
