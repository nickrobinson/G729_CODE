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

module TL_Math6 (clock,reset,start,gain_pit,gain_code,SHARPMIN,SHARPMAX,exc,i_subfr,code,L_SUBFR,L_multIn,
				 L_macIn,L_shlIn,L_shlDone,addIn,subIn,memIn,L_addIn,
				 sharp,L_temp,L_multOutA,L_multOutB,L_macOutA,L_macOutB,L_macOutC,L_shlReady,L_shlOutA,
				 L_shlOutB,addOutA,addOutB,subOutA,subOutB,memWriteAddr,memOut,memWriteEn,memReadAddr,
				 L_addOutA,L_addOutB,done);

	`include "paramList.v"
	
	//inputs
	input clock,reset,start;
	input [15:0] gain_pit,gain_code,SHARPMIN,SHARPMAX,i_subfr,L_SUBFR;
	input [11:0] exc,code;
	input [31:0] L_multIn;
	input [31:0] L_macIn;
	input [31:0] L_shlIn;
	input L_shlDone;
	input [15:0] addIn;
	input [15:0] subIn;
	input [31:0] memIn;
	input [31:0] L_addIn;

	//outputs
	output reg done;
	output reg [15:0] sharp;
	output reg [31:0] L_temp;
	
	output reg [15:0] L_multOutA;
	output reg [15:0] L_multOutB;
	output reg [15:0] L_macOutA, L_macOutB;
	output reg [31:0] L_macOutC;
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
	output reg [11:0] memReadAddr;
	output reg [31:0] L_addOutA, L_addOutB;
	
	//wires/regs
	reg [3:0] currentstate, nextstate;
	reg [15:0] nexti, i, nextsharp, nextroundtmp, roundtmp;
	reg [31:0] nextL_temp;
	
	//parameters
	parameter INIT = 4'd0;
	parameter S1 = 4'd1;
	parameter S2 = 4'd2;
	parameter S3 = 4'd3;
	parameter S4 = 4'd4;
	parameter S5 = 4'd5;
	parameter S6 = 4'd6;
	parameter S7 = 4'd7;
	parameter S8 = 4'd8;
	parameter S9 = 4'd9;
	parameter DONE = 4'd10;

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
			sharp <= 0;
		else
			sharp <= nextsharp;
	end

	always @ (posedge clock)
	begin
		if (reset)
			L_temp <= 0;
		else
			L_temp <= nextL_temp;
	end

	always @ (posedge clock)
	begin
		if (reset)
			roundtmp <= 0;
		else
			roundtmp <= nextroundtmp;
	end
	
	always@(*) begin
		addOutA = 0;
		addOutB = 0;
		L_multOutA = 0;
		L_multOutB = 0;
		L_macOutA = 0;
		L_macOutB = 0;
		L_macOutC = 0;
		L_shlReady = 0;
		L_shlOutA = 0;
		L_shlOutB = 0;
		subOutA = 0;
		subOutB = 0;
		memWriteAddr = 0; 
	    memOut = 0; 
		memWriteEn = 0; 
		memReadAddr = 0; 
		L_addOutA = 0;
		L_addOutB = 0;
		done = 0;

		nextstate = currentstate;
		nexti = i;
		nextsharp = sharp;
		nextL_temp = L_temp;
		nextroundtmp = roundtmp;
		case(currentstate)

			INIT: 
			begin
				if(start == 1)
					nextstate = S1;
				else
				begin
					nexti = 0;
					nextsharp = 0;
					nextL_temp = 0;
					nextroundtmp = 0;
					nextstate = INIT;
				end
			end
			
			//sharp = gain_pit;
			// if (sub(sharp, SHARPMAX) > 0) { sharp = SHARPMAX;         }
			S1: 
			begin
				nextsharp = gain_pit;
				subOutA = gain_pit;
				subOutB = SHARPMAX;
				if (subIn[15] == 0 && subIn != 16'd0)
				begin
					nextsharp = SHARPMAX;
					nextstate = S3;
				end
				else
					nextstate = S2;
			end
			
			// if (sub(sharp, SHARPMIN) < 0) { sharp = SHARPMIN;         }
			S2: 
			begin
				subOutA = sharp;
				subOutB = SHARPMIN;
				if (subIn[15] == 1)
					nextsharp = SHARPMIN;
				nextstate = S3;
			end

			// for (i = 0; i < L_SUBFR;  i++)
			// exc[i+i_subfr]
			S3: 
			begin
				if (i < L_SUBFR)
				begin
					L_addOutA = i;
					L_addOutB = i_subfr;
					addOutA = exc;
					addOutB = L_addIn;
					memReadAddr = addIn;
					nextstate = S4;
				end
				else
					nextstate = DONE;
			end

			// L_temp = L_mult(exc[i+i_subfr], gain_pit);
			// code[i]
			S4: 
			begin
				L_multOutA = memIn;
				L_multOutB = gain_pit;
				nextL_temp = L_multIn;
				addOutA = code;
				addOutB = i;
				memReadAddr = addIn;
				nextstate = S5;
			end

			// L_temp = L_mac(L_temp, code[i], gain_code);
			S5: 
			begin
				L_macOutA = memIn;
				L_macOutB = gain_code;
				L_macOutC = L_temp;
				nextL_temp = L_macIn;
				nextstate = S6;
			end

			// L_temp = L_shl(L_temp, 1);
			S6: 
			begin
				L_shlReady = 1;
				L_shlOutA = L_temp;
				L_shlOutB = 1;
				if (L_shlDone)
				begin
					nextstate = S7;
					nextL_temp = L_shlIn;
				end
				else
					nextstate = S6;
			end

			//round(L_temp);
			S7: 
			begin
				L_addOutA = L_temp;
				L_addOutB = 32'h00008000;
				nextroundtmp = L_addIn[31:16];
				nextstate = S8;
			end

			// exc[i+i_subfr] = round(L_temp);
			S8: 
			begin
				L_addOutA = i;
				L_addOutB = i_subfr;
				addOutA = exc;
				addOutB = L_addIn;
				memWriteAddr = addIn;
				if (roundtmp[15] == 1)
					memOut = {16'hffff,roundtmp};
				else
					memOut = {16'h0000,roundtmp};
				memWriteEn = 1;
				nextstate = S9;
			end

			// i++
			S9: 
			begin
				addOutA = i;
				addOutB = 16'd1;
				nexti = addIn;
				nextstate = S3;
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
