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

module TL_Math3 (clock,reset,start,i_gamma_in,Ap1,ai_zero,M,addIn,memIn,addOutA,addOutB,memWriteAddr,memOut,memWriteEn,memReadAddr,i_gamma_out,done);

	`include "paramList.v"
	
	//inputs
	input clock;
	input reset;
	input start;
	input [15:0] i_gamma_in;
	input [11:0] Ap1;
	input [11:0] ai_zero;
	input [15:0] M;
	
	input [15:0] addIn;
	input [31:0] memIn;
	
	//outputs
	output [15:0] i_gamma_out;
	output reg done;

	output reg [15:0] addOutA;
	output reg [15:0] addOutB;
	output reg [11:0] memWriteAddr; 
	output reg [31:0] memOut; 
	output reg memWriteEn; 
	output reg [11:0] memReadAddr; 
	
	//wires/regs
	reg [2:0] currentstate, nextstate;
	reg [15:0] nexti, nexti_gamma_out;
	reg [15:0] i, i_gamma_out;
	reg LDi, LDi_gamma_out;
	reg reseti, reseti_gamma_out;
	
	//parameters
	parameter INIT = 3'd0;
	parameter S1 = 3'd1;
	parameter S2 = 3'd2;
	parameter S3 = 3'd3;
	parameter S4 = 3'd4;
	parameter DONE = 3'd5;
	
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
		else if (reseti)
			i <= 0;
		else if (LDi)
			i <= nexti;
	end

	always @ (posedge clock)
	begin
		if (reset)
			i_gamma_out <= 0;
		else if (reseti_gamma_out)
			i_gamma_out <= 0;
		else if (LDi_gamma_out)
			i_gamma_out <= nexti_gamma_out;
	end
	
	always@(*) begin
	   addOutA = 0;
		addOutB = 0;
		done = 0;
		memWriteAddr = 0; 
	   memOut = 0; 
		memWriteEn = 0; 
		memReadAddr = 0; 

		nextstate = currentstate;
		nexti = i;
		nexti_gamma_out = i_gamma_out;
		LDi = 0;
		LDi_gamma_out = 0;
		reseti = 0;
		reseti_gamma_out = 0;
		case(currentstate)

			INIT: 
			begin
				reseti_gamma_out = 1;
				reseti = 1;
				if(start == 1)
					nextstate = S1;
				else
					nextstate = INIT;
			end
			
			//i_gamma = add(i_gamma,1);
			S1: 
			begin
				addOutA = i_gamma_in;
				addOutB = 16'd1;
				nexti_gamma_out = addIn;
				LDi_gamma_out = 1;
				nextstate = S2;
			end

			// for (i = 0; i <= M; i++) {
				// ai_zero[i] = Ap1[i];
			// }
			S2: 
			begin
				if (i <= M)
				begin
					addOutA = Ap1;
					addOutB = i;
					memReadAddr = addIn;
					nextstate = S3;
				end
				else
					nextstate = DONE;
			end
			
			S3: 
			begin
				addOutA = ai_zero;
				addOutB = i;
				memWriteAddr = addIn;
				memOut = memIn;
				memWriteEn = 1;
				nextstate = S4;
			end
		
			S4: 
			begin
				addOutA = i;
				addOutB = 16'd1;
				nexti = addIn;
				LDi = 1;
				nextstate = S2;
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
