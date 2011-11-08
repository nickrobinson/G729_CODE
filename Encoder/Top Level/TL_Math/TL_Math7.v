`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Cooper McClain
// 
// Create Date:    9:56:50 8/27/2011 
// Module Name:    TLMath1 
// Project Name: 	 ITU G.729 Hardware Implementation
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 12.4
// Description: 	 Fourth section of math inside the the top level function.  Help encapsulate simple math functionality and keeps
//					    the Top Level FSM modular.
//
// Dependencies: 	 L_mult.v, mux128_16.v, mult.v, L_mac.v, mux128_32.v, L_msu.v, L_add.v, L_sub.v, norm_l.v, mux128_1.v
//						 norm_s.v, L_shl.v, L_shr.v, L_abs.v, L_negate.v, add.v, sub.v, shr.v, shl.v, Scratch_Memory_Controller.v,
//						 mux128_11.v, g729_hpfilter.v, LPC_Mem_Ctrl.v, autocorrFSM.v, lag_window.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module TL_Math7 (clock,reset,start,gain_pit,gain_code,M,i_subfr,L_SUBFR,speech,mem_err,mem_w0,synth,y1,y2,xn,
				 L_multIn,L_shlIn,L_shlDone,addIn,subIn,memIn,temp,k,L_multOutA,L_multOutB,
				 L_shlReady,L_shlOutA,L_shlOutB,addOutA,addOutB,subOutA,subOutB,memWriteAddr,memOut,
				 memWriteEn,memReadAddr,speechAddr,speechIn,done);

	`include "paramList.v"
	
	//inputs
	input clock,reset,start;
	input [15:0] gain_pit,gain_code,M,i_subfr,L_SUBFR;
	input [11:0] speech,mem_err,mem_w0,synth,y1,y2,xn;
	
	input [31:0] L_multIn;
	input [31:0] L_shlIn;
	input L_shlDone;
	input [15:0] addIn;
	input [15:0] subIn;
	input [31:0] memIn,speechIn;

	//outputs
	output reg done;
	output reg [15:0] temp, k;
	
	output reg [15:0] L_multOutA;
	output reg [15:0] L_multOutB;
	output reg L_shlReady;
	output reg [31:0] L_shlOutA;
	output reg [15:0] L_shlOutB;
	output reg [15:0] addOutA;
	output reg [15:0] addOutB;
	output reg [15:0] subOutA;
	output reg [15:0] subOutB;
	output reg [11:0] memWriteAddr;
	output reg [31:0] memOut;
	output reg memWriteEn;
	output reg [11:0] memReadAddr,speechAddr;
	
	
	//wires/regs
	reg [3:0] currentstate, nextstate;
	reg [15:0] nexti, i, nextj, j, nextk, nexttemp, nextytmp, ytmp, nextaddtmp, addtmp, nextaddtmp2, addtmp2;
	
	//parameters
	parameter INIT = 4'd0;
	parameter S0 = 4'd14;
	parameter S0_5 = 4'd15;
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
	parameter DONE = 4'd13;

	//flip flops
	always @ (posedge clock)
	begin
		if (reset)
			currentstate <= INIT;
		else
			currentstate <= nextstate;
	end

	always @ (posedge clock)
	begin
		if (reset)
			i <= 0;
		else
			i <= nexti;
	end

	always @ (posedge clock)
	begin
		if (reset)
			j <= 0;
		else
			j <= nextj;
	end

	always @ (posedge clock)
	begin
		if (reset)
			k <= 0;
		else
			k <= nextk;
	end

	always @ (posedge clock)
	begin
		if (reset)
			temp <= 0;
		else
			temp <= nexttemp;
	end
	
	always @ (posedge clock)
	begin
		if (reset)
			ytmp <= 0;
		else
			ytmp <= nextytmp;
	end

	always @ (posedge clock)
	begin
		if (reset)
			addtmp <= 0;
		else
			addtmp <= nextaddtmp;
	end

	always @ (posedge clock)
	begin
		if (reset)
			addtmp2 <= 0;
		else
			addtmp2 <= nextaddtmp2;
	end

	always@(*) begin
		addOutA = 0;
		addOutB = 0;
		L_multOutA = 0;
		L_multOutB = 0;
		L_shlReady = 0;
		L_shlOutA = 0;
		L_shlOutB = 0;
		subOutA = 0;
		subOutB = 0;
		memWriteAddr = 0; 
	    memOut = 0; 
		memWriteEn = 0; 
		memReadAddr = 0; 
		speechAddr = 0;
		done = 0;

		nextstate = currentstate;
		nexti = i;
		nextj = j;
		nextk = k;
		nexttemp = temp;
		nextytmp = ytmp;
		nextaddtmp = addtmp;
		nextaddtmp2 = addtmp2;
		case(currentstate)

			INIT: 
			begin
				if(start == 1)
					nextstate = S0;
				else
				begin
					subOutA = L_SUBFR;
					subOutB = M;
					nexti = subIn;
					nextj = 0;
					nextk = 0;
					nexttemp = 0;
					nextstate = INIT;
				end
			end
			
			S0: 
			begin
				addOutA = i_subfr;
				addOutB = i;
				nextaddtmp = addIn;
				nextstate = S0_5;
			end
			
			S0_5: 
			begin
				addOutA = speech;
				addOutB = addtmp;
				nextaddtmp2 = addIn;
				nextstate = S1;
			end
			
			// for (i = L_SUBFR-M, j = 0; i < L_SUBFR; i++, j++)
			// speech[i_subfr+i]
			S1: 
			begin
				if (i < L_SUBFR)
				begin
					addOutA = synth;
					addOutB = addtmp;
					memReadAddr = addIn;
					speechAddr = addtmp2;
					nextstate = S2;
				end
				else
					nextstate = DONE;
			end
			
			// mem_err[j] = sub(speech[i_subfr+i], synth[i_subfr+i]);
			S2: 
			begin
				subOutA = speechIn;
				subOutB = memIn;
				addOutA = mem_err;
				addOutB = j;
				memWriteAddr = addIn;
				if (subIn[15] == 1)
					memOut = {16'hffff, subIn};
				else
					memOut = {16'h0000, subIn};
				memWriteEn = 1;
				nextstate = S3;
			end

			// y1[i]
			S3: 
			begin
				addOutA = y1;
				addOutB = i;
				memReadAddr = addIn;
				nextstate = S4;
			end

			// y1[i]
			S4: 
			begin
				nextytmp = memIn;
				nextstate = S5;
			end
			
			// temp = extract_h(L_shl( L_mult(y1[i], gain_pit),  1) );
			// y2[i]
			S5: 
			begin
				L_multOutA = ytmp;
				L_multOutB = gain_pit;
				L_shlReady = 1;
				L_shlOutA = L_multIn;
				L_shlOutB = 16'd1;
				if (L_shlDone)
				begin
					addOutA = y2;
					addOutB = i;
					memReadAddr = addIn;
					nextaddtmp = addIn;
					nexttemp = L_shlIn[31:16];
					nextstate = S6;
				end
				else
					nextstate = S5;
			end
			
			// y2[i]
			S6: 
			begin
				addOutA = y2;
				addOutB = i;
				memReadAddr = addIn;
				nextstate = S7;
			end

			// y2[i]
			S7: 
			begin
				nextytmp = memIn;
				nextstate = S8;
			end
			
			// k          = extract_h(L_shl( L_mult(y2[i], gain_code), 2) );
			S8: 
			begin
				L_multOutA = ytmp;
				L_multOutB = gain_code;
				L_shlReady = 1;
				L_shlOutA = L_multIn;
				L_shlOutB = 16'd2;
				if (L_shlDone)
				begin
					addOutA = mem_w0;
					addOutB = j;
					nextaddtmp = addIn;
					nextk = L_shlIn[31:16];
					nextstate = S9;
				end
				else
					nextstate = S8;
			end
			
			// xn[i]
			S9: 
			begin
				addOutA = xn;
				addOutB = i;
				memReadAddr = addIn;
				nextstate = S10;
			end

			// mem_w0[j]  = sub(xn[i], add(temp, k));
			S10: 
			begin
				addOutA = temp;
				addOutB = k;
				subOutA = memIn;
				subOutB = addIn;
				memWriteAddr = addtmp;
				if (subIn[15] == 1)
					memOut = {16'hffff, subIn};
				else
					memOut = {16'h0000, subIn};
				memWriteEn = 1;
				nextstate = S11;
			end

			// i++
			S11: 
			begin
				addOutA = i;
				addOutB = 16'd1;
				nexti = addIn;
				nextstate = S12;
			end

			// j++
			S12: 
			begin
				addOutA = j;
				addOutB = 16'd1;
				nextj = addIn;
				nextstate = S0;
			end

			DONE: 
			begin
				done = 1;
				nextstate = INIT;
			end
			
			default:
				nextstate = INIT;
		endcase
	end

	
endmodule
