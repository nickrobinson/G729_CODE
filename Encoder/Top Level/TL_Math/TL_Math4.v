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

module TL_Math4 (clock,reset,start,tempIn,gain_pit_in,GPCLIP,subIn,memIn,subOutA,subOutB,memWriteAddr,memOut,memWriteEn,memReadAddr,gain_pit_out,done);

	`include "paramList.v"
	
	//inputs
	input clock;
	input reset;
	input start;
	input [15:0] gain_pit_in;
	input [15:0] tempIn;
	input [15:0] GPCLIP;
	
	input [15:0] subIn;
	input [31:0] memIn;
	
	//outputs
	output [15:0] gain_pit_out;
	output reg done;

	output reg [15:0] subOutA;
	output reg [15:0] subOutB;
	output reg [11:0] memWriteAddr; 
	output reg [31:0] memOut; 
	output reg memWriteEn; 
	output reg [11:0] memReadAddr; 
	
	//wires/regs
	reg [2:0] currentstate, nextstate;
	reg [15:0] next_gp_in, next_gp_out;
	reg [15:0] gp_in, gp_out;
	reg LD_gp_in, LD_gp_out;
	reg reset_gp_in, reset_gp_out;
	
	//parameters
	parameter INIT = 3'd0;
	parameter SUBTRACT_1 = 3'd1;
	parameter SUBTRACT_2 = 3'd2;
	parameter DONE = 3'd3;
	
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
		else if (reset_gp_in)
			i <= 0;
		else if (LD_gp_in)
			i <= next_gp_in;
	end

	always @ (posedge clock)
	begin
		if (reset)
			gp_out <= 0;
		else if (reset_gp_out)
			gp_out <= 0;
		else if (LD_gp_out)
			gp_out <= next_gp_out;
	end
	
	always@(*) begin
	   subOutA = 0;
		subOutB = 0;
		done = 0;
		memWriteAddr = 0; 
	   memOut = 0; 
		memWriteEn = 0; 
		memReadAddr = 0; 

		nextstate = currentstate;
		next_gp_in = gp_in;
		next_gp_out = gp_out;
		LD_gp_in = 0;
		LD_gp_out = 0;
		reset_gp_in = 0;
		reset_gp_out = 0;
		case(currentstate)

			INIT: 
			begin
				reset_gp_out = 1;
				reset_gp_in = 1;
				if(start == 1)
					nextstate = S1;
				else
					nextstate = INIT;
			end
			
			//if( temp == 1)			
			S1: 
			begin
				if(tempIn[15:0] == 16'h0001)
					nextstate = SUBTRACT_1;
				else
					nextstate = DONE;
			end

			// sub(gain_pit, GPCLIP)
			SUBTRACT_1: 
			begin
					subOutA = gain_pit_in[15:0];
					subOutB = GPCLIP;
					nextstate = SUBTRACT_2;
			end
			
		   //if (sub(gain_pit, GPCLIP) > 0) {
         //gain_pit = GPCLIP;
         // }
			SUBTRACT_2: 
			begin
				if(subIn[15:0] > 16'h0000)
				begin
					next_gp_out = GPCLIP;
					LD_gp_out = 1;
					nextstate = DONE;
				end
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
