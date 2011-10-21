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
// Description: 	 First section of math inside the the top level function.  Help encapsulate simple math functionality and keeps
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

module TL_Math1 (clock,reset,start,addIn,memIn,addOutA,addOutB,memWriteAddr,memOut,memWriteEn,memReadAddr,done);

	`include "paramList.v"

	//inputs
	input clock;
	input reset;
	input start;
	input [15:0] addIn;
	input [31:0] memIn;
	
	//outputs
	output reg [15:0] addOutA;
	output reg [15:0] addOutB;
	output reg [11:0] memWriteAddr;
	output reg [31:0] memOut;
	output reg memWriteEn;
	output reg [11:0] memReadAddr;
	output reg done;
	
	//wires/regs
	reg [2:0] currentstate, nextstate;
	reg [3:0] I, nextI;
	reg ldI, resetI;
	
	//parameters
	parameter INIT = 3'd0;
	parameter S1 = 3'd1;
	parameter S2 = 3'd2;
	parameter S3 = 3'd3;
	parameter DONE = 3'd4;
	
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
			I <= 0;
		else if (resetI)
			I <= 0;
		else if (ldI)
			I <= nextI;
	end
	
	always@(*) begin
	   addOutA = 0;
		addOutB = 0;
		memWriteAddr = 0;
		memOut = 0;
		memWriteEn = 0;
		memReadAddr = 0;
		done = 0;
		
		nextstate = currentstate;
		nextI = I;
		ldI = 0;
		resetI = 0;
		case(currentstate)

			// true: start
			// false: wait
			INIT: 
			begin
				resetI = 1;
				if(start == 1)
					nextstate = S1;
				else
					nextstate = INIT;
			end
			
			// for(i=0; i<M; i++)
			// true: lsp_new[i];
			// false: done
			S1: 
			begin
				if (I < 10)
				begin
					memReadAddr = LSP_NEW + I;
					nextstate = S2;
				end
				else
					nextstate = DONE;
			end
			
		    // lsp_old[i]   = lsp_new[i];
			// lsp_new_q[i]
			S2: 
			begin
				memWriteAddr = LSP_OLD + I;
				memOut = memIn;
				memWriteEn = 1;
				memReadAddr = LSP_NEW_Q + I;
				nextstate = S3;
			end
			
			// lsp_old_q[i] = lsp_new_q[i];
			S3:
			begin
				memWriteAddr = LSP_OLD_Q + I;
				memOut = memIn;
				memWriteEn = 1;
				addOutA = I;
				addOutB = 'd1;
				nextI = addIn;
				ldI = 1;
				nextstate = S1;
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
