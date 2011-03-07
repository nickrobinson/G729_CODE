`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:49:36 02/19/2011 
// Design Name: 
// Module Name:    Lsp_get_tdist 
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
module Lsp_get_tdist(
	input clk,
	input reset,
	input start,
	input [10:0] wegt,
	input [10:0] buff,
	input [10:0] L_tdist,
	input [10:0] rbuf,
	input [12:0] fg_sum,
	input [15:0] subIn,
	input [15:0] multIn,
	input [31:0] L_multIn,
	input [31:0] L_shlIn,
	input L_shlDone,
	input [31:0] L_macIn,
	input [15:0] addIn,
	input [31:0] dataInScratch,
	input [31:0] dataInConstant,
	
	output reg [15:0] subOutA,
	output reg [15:0] subOutB,
	output reg [15:0] multOutA,
	output reg [15:0] multOutB,
	output reg [15:0] L_multOutA,
	output reg [15:0] L_multOutB,
	output reg [31:0] L_shlOutA,
	output reg [15:0] L_shlOutB,
	output reg L_shlReady,
	output reg [15:0] L_macOutA,
	output reg [15:0] L_macOutB,
	output reg [31:0] L_macOutC,
	output reg [15:0] addOutA,
	output reg [15:0] addOutB,
	output reg [10:0] FSMwriteAddrScratch,
	output reg [31:0] FSMwriteDataScratch,
	output reg FSMwriteEnScratch,
	output reg [10:0] FSMreadAddrScratch,
	output reg [12:0] readAddrConstant,
	output reg done	
   );
	 
	parameter S0_INIT = 4'd0;
	parameter S1_FOR = 4'd1;
	parameter S2_SUB1 = 4'd2;
	parameter S3_SUB2 = 4'd3;
	parameter S4_MULT = 4'd4;
	parameter S5_LMULT_LSHL = 4'd5;
	parameter S6_LTDIST = 4'd6;
	parameter S7_DONE = 4'd7;
	parameter M = 4'd10;

	//regs
	reg [2:0] state, nextstate;
	reg [3:0] J, nextJ;
	reg resetJ, ldJ;
	reg [15:0] tmp, nexttmp;
	reg resettmp, ldtmp;
	reg [31:0] L_tdist_flop, nextL_tdist_flop;
	reg resetL_tdist_flop, ldL_tdist_flop;
	
	
	//Flops
	//state
	always @ (posedge clk)
	begin
		if (reset)
			state <= 0;
		else
			state <= nextstate;
	end

	//J
	always @ (posedge clk)
	begin
		if (reset)
			J <= 0;
		else if (resetJ)
			J <= 0;
		else if (ldJ)
			J <= nextJ;
	end
	
	//tmp
	always @ (posedge clk)
	begin
		if (reset)
			tmp <= 0;
		else if (resettmp)
			tmp <= 0;
		else if (ldtmp)
			tmp <= nexttmp;
	end
	
	//L_tdist_flop
	always @ (posedge clk)
	begin
		if (reset)
			L_tdist_flop <= 0;
		else if (resetL_tdist_flop)
			L_tdist_flop <= 0;
		else if (ldL_tdist_flop)
			L_tdist_flop <= nextL_tdist_flop;
	end

	always @ (*)
	begin
		//set outputs to default
		nextstate = state;
		nextJ = J;
		resetJ = 0;
		ldJ = 0;
		nexttmp = tmp;
		resettmp = 0;
		ldtmp = 0;
		nextL_tdist_flop = L_tdist_flop;
		resetL_tdist_flop = 0;
		ldL_tdist_flop = 0;
		subOutA = 0;
		subOutB = 0;
		multOutA = 0;
		multOutB = 0;
		L_multOutA = 0;
		L_multOutB = 0;
		L_shlOutA = 0;
		L_shlOutB = 0;
		L_shlReady = 0;
		L_macOutA = 0;
		L_macOutB = 0;
		L_macOutC = 0;
		addOutA = 0;
		addOutB = 0;
		FSMwriteAddrScratch = 0;
		FSMwriteDataScratch = 0;
		FSMwriteEnScratch = 0;
		FSMreadAddrScratch = 0;
		readAddrConstant = 0;
		done = 0;
		case (state)
			S0_INIT:
			begin
				//reset flops L_tdist, J, L_acc
				resetJ = 1;
				resettmp = 1;
				resetL_tdist_flop = 1;
				if(start)
					nextstate = S1_FOR;
				else
					nextstate = S0_INIT;
			end
			S1_FOR:
			begin
				if(J < M)
				begin
					FSMreadAddrScratch = {buff[10:4], J[3:0]};
					nextstate = S2_SUB1;
				end
				else
					nextstate = S6_LTDIST;
			end
			S2_SUB1:
			begin
				FSMreadAddrScratch = {rbuf[10:4], J[3:0]};
				nexttmp = dataInScratch;
				ldtmp = 1;
				nextstate = S3_SUB2;
			end
			S3_SUB2:
			begin
				readAddrConstant = {fg_sum[12:4], J[3:0]};
				subOutA = tmp;
				subOutB = dataInScratch;
				nexttmp = subIn;
				ldtmp = 1;
				nextstate = S4_MULT;
			end
			S4_MULT:
			begin
				FSMreadAddrScratch = {wegt[10:4], J[3:0]};
				multOutA = tmp;
				multOutB = dataInConstant;
				nexttmp = multIn;
				ldtmp = 1;
				addOutA = {12'd0, J[3:0]};
				addOutB = 16'd1;
				nextJ = addIn;
				ldJ = 1;
				nextstate = S5_LMULT_LSHL;
			end
			S5_LMULT_LSHL:
			begin
				L_multOutA = dataInScratch;
				L_multOutB = tmp;
				L_shlOutA = L_multIn;
				L_shlOutB = 16'd4;
				L_shlReady = 1;
				if(L_shlDone)
				begin
					L_macOutA = tmp;
					L_macOutB = L_shlIn[31:16];
					L_macOutC = L_tdist_flop;
					nextL_tdist_flop = L_macIn;
					ldL_tdist_flop = 1;
					nextstate = S1_FOR;
				end
				else
					nextstate = S5_LMULT_LSHL;
			end
			S6_LTDIST:
			begin
				FSMwriteAddrScratch = L_tdist;
				FSMwriteDataScratch = L_tdist_flop;
				FSMwriteEnScratch = 1;
				nextstate = S7_DONE;
			end
			S7_DONE:
			begin
				done = 1;
				nextstate = S0_INIT;
			end
			default:
				nextstate = S0_INIT;
		endcase
	end


endmodule
