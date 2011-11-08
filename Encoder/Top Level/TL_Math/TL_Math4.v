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

module TL_Math4 (clock,reset,start,y1,xn,xn2,temp,gain_pit_in,GPCLIP,L_SUBFR,addIn,subIn,L_multIn,memIn,L_shlIn,L_shlDone,addOutA,addOutB,subOutA,subOutB,L_multOutA,L_multOutB,L_shlReady,L_shlOutA,L_shlOutB,memWriteAddr,memOut,memWriteEn,memReadAddr,L_temp,gain_pit_out,done);

	`include "paramList.v"
	
	//inputs
	input clock;
	input reset;
	input start;
	input [11:0] y1, xn, xn2;
	input [15:0] gain_pit_in;
	input [15:0] temp;
	input [15:0] GPCLIP;
	input [15:0] L_SUBFR;

	input [15:0] addIn;
	input [15:0] subIn;
	input [31:0] L_multIn;
	input [31:0] memIn;
	input [31:0] L_shlIn;
	input L_shlDone;
	
	//outputs
	output reg [15:0] gain_pit_out;
	output reg [31:0] L_temp;
	output reg done;

	output reg [15:0] addOutA;
	output reg [15:0] addOutB;
	output reg [15:0] subOutA;
	output reg [15:0] subOutB;
	output reg [15:0] L_multOutA;
	output reg [15:0] L_multOutB;
	output reg L_shlReady;
	output reg [31:0] L_shlOutA;
	output reg [15:0] L_shlOutB;
	output reg [11:0] memWriteAddr; 
	output reg [31:0] memOut; 
	output reg memWriteEn; 
	output reg [11:0] memReadAddr; 
	
	//wires/regs
	reg [3:0] currentstate, nextstate;
	reg [15:0] next_gain_pit_out,next_i;
	reg [31:0] next_L_temp;
	reg [15:0] i;
	reg LD_gain_pit_out,LD_i,LD_L_temp;
	reg reset_gain_pit_out,reset_i,reset_L_temp;
	
	//parameters
	parameter INIT = 4'd0;
	parameter IF_1 = 4'd1;
	parameter IF_2 = 4'd2;
	parameter FOR_CHECK = 4'd3;
	parameter L_MULT = 4'd4;
	parameter L_SHL = 4'd5;
	parameter SUB = 4'd6;
	parameter INC = 4'd7;
	parameter DONE = 4'd8;
	
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
		else if (reset_i)
			i <= 0;
		else if (LD_i)
			i <= next_i;
	end

	always @ (posedge clock)
	begin
		if (reset)
			gain_pit_out <= 0;
		else if (reset_gain_pit_out)
			gain_pit_out <= 0;
		else if (LD_gain_pit_out)
			gain_pit_out <= next_gain_pit_out;
	end

	always @ (posedge clock)
	begin
		if (reset)
			L_temp <= 0;
		else if (reset_L_temp)
			L_temp <= 0;
		else if (LD_L_temp)
			L_temp <= next_L_temp;
	end
	
	always@(*) begin
		addOutA = 0;
		addOutB = 0;
	   subOutA = 0;
		subOutB = 0;
		L_multOutA = 0;
		L_multOutB = 0;
		L_shlReady = 0;
		L_shlOutA = 0;
		L_shlOutB = 0;
		done = 0;
		memWriteAddr = 0; 
	   memOut = 0; 
		memWriteEn = 0; 
		memReadAddr = 0; 

		nextstate = currentstate;
		next_gain_pit_out = gain_pit_out;
		next_i = i;
		next_L_temp = L_temp;
		LD_gain_pit_out = 0;
		LD_i = 0;
		LD_L_temp = 0;
		reset_gain_pit_out = 0;
		reset_i = 0;
		reset_L_temp = 0;
		case(currentstate)

			INIT: 
			begin
				reset_i = 1;
				reset_gain_pit_out = 1;
				if(start == 1)
					nextstate = IF_1;
				else
					nextstate = INIT;
			end
			
			//if(temp == 1)			
			IF_1: 
			begin
				if(temp[15:0] == 16'h0001)
					nextstate = IF_2;
				else
				begin
					next_gain_pit_out = gain_pit_in;
					LD_gain_pit_out = 1;
					nextstate = FOR_CHECK;
				end
			end
			
		    //if (sub(gain_pit, GPCLIP) > 0) {
              //gain_pit = GPCLIP;
            //}
			IF_2: 
			begin
				subOutA = gain_pit_in;
				subOutB = GPCLIP;
				if(subIn[15:0] != 16'h0000 && subIn[15] != 1'd1)
				begin
					next_gain_pit_out = GPCLIP;
					LD_gain_pit_out = 1;
				end
				else
				begin
					next_gain_pit_out = gain_pit_in;
					LD_gain_pit_out = 1;
				end
				nextstate = FOR_CHECK;
			end

			//for (i = 0; i < L_SUBFR; i++)
			//y1[i]
			FOR_CHECK: 
			begin
				if(i < L_SUBFR)
				begin
					addOutA = y1;
					addOutB = i;
					memReadAddr = addIn;
					nextstate = L_MULT;
				end
				else
					nextstate = DONE;
			end

			//L_temp = L_mult(y1[i], gain_pit);
			L_MULT: 
			begin
				L_multOutA = memIn;
				L_multOutB = gain_pit_out;
				next_L_temp = L_multIn;
				LD_L_temp = 1;
				nextstate = L_SHL;
			end

			//L_temp = L_shl(L_temp, 1);
			L_SHL: 
			begin
				L_shlReady = 1;
				L_shlOutA = L_temp;
				L_shlOutB = 16'd1;
				if (L_shlDone)
				begin
					next_L_temp = L_shlIn;
					LD_L_temp = 1;
					addOutA = xn;
					addOutB = i;
					memReadAddr = addIn;
					nextstate = SUB;
				end
				else
					nextstate = L_SHL;
			end

			//xn2[i] = sub(xn[i], extract_h(L_temp));
			SUB: 
			begin
				subOutA = memIn;
				subOutB = L_temp[31:16];
				addOutA = xn2;
				addOutB = i;
				memWriteAddr = addIn;
				if (subIn[15] == 1)
					memOut = {16'hffff,subIn};
				else
					memOut = {16'h0000,subIn};
				memWriteEn = 1;
				nextstate = INC;
			end

			INC: 
			begin
				addOutA = i;
				addOutB = 16'd1;
				next_i = addIn;
				LD_i = 1;
				nextstate = FOR_CHECK;
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
