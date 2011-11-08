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

module TL_Math5 (clock,reset,start,g_coeff,g_coeff_cs,exp_g_coeff_cs,addIn,negateIn,memIn,addOutA,addOutB,negateOut,memWriteAddr,memOut,memWriteEn,memReadAddr,done);

	`include "paramList.v"
	
	//inputs
	input clock,reset,start;
	input [11:0] g_coeff, g_coeff_cs, exp_g_coeff_cs;

	input [15:0] addIn;
	input [31:0] negateIn;
	input [31:0] memIn;
	
	//outputs
	output reg done;

	output reg [15:0] addOutA;
	output reg [15:0] addOutB;
	output reg [31:0] negateOut;
	output reg [11:0] memWriteAddr; 
	output reg [31:0] memOut; 
	output reg memWriteEn; 
	output reg [11:0] memReadAddr; 
	
	//wires/regs
	reg [3:0] currentstate, nextstate;
	reg [15:0] nexttemp, temp;
	reg LDtemp, resettemp;
	
	//parameters
	parameter INIT = 3'd0;
	parameter WRITE = 3'd1;
	parameter NEGATE1 = 3'd2;
	parameter NEGATE2 = 3'd3;
	parameter GET_ADDR = 3'd4;
	parameter GET_VALUE = 3'd5;
	parameter NEGATE_ADD = 3'd6;
	parameter DONE = 3'd7;

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
			temp <= 0;
		else if (resettemp)
			temp <= 0;
		else if (LDtemp)
			temp <= nexttemp;
	end

	always@(*) begin
		addOutA = 0;
		addOutB = 0;
		negateOut = 0;
		memWriteAddr = 0; 
	    memOut = 0; 
		memWriteEn = 0; 
		memReadAddr = 0; 
		done = 0;

		nextstate = currentstate;
		nexttemp = temp;
		LDtemp = 0;
		resettemp = 0;
		case(currentstate)

			INIT: 
			begin
				if(start == 1)
				begin
					memReadAddr = g_coeff;
					nextstate = WRITE;
				end
				else
				begin
					resettemp = 1;
					nextstate = INIT;
				end
			end
			
			// g_coeff_cs[0]     = g_coeff[0];                   /* <y1,y1> */
			WRITE: 
			begin
				memWriteAddr = g_coeff_cs;
				memOut = memIn;
				memWriteEn = 1;
				addOutA = g_coeff;
				addOutB = 16'd1;
				memReadAddr = addIn;
				nextstate = NEGATE1;
			end
			
			// exp_g_coeff_cs[0] = negate(g_coeff[1]);           /* Q-Format:XXX -> JPN  */			
			NEGATE1: 
			begin
				negateOut = memIn;
				memWriteAddr = exp_g_coeff_cs;
				memOut = negateIn;
				memWriteEn = 1;
				addOutA = g_coeff;
				addOutB = 16'd2;
				memReadAddr = addIn;
				nextstate = NEGATE2;
			end

			// g_coeff_cs[1]     = negate(g_coeff[2]);           /* (xn,y1) -> -2<xn,y1> */
			NEGATE2: 
			begin
				negateOut = memIn;
				addOutA = g_coeff_cs;
				addOutB = 16'd1;
				memWriteAddr = addIn;
				memOut = negateIn;
				memWriteEn = 1;
				nextstate = GET_ADDR;
			end

			// exp_g_coeff_cs[1]
			GET_ADDR: 
			begin
				addOutA = exp_g_coeff_cs;
				addOutB = 16'd1;
				nexttemp = addIn;
				LDtemp = 1;
				nextstate = GET_VALUE;
			end

			// g_coeff[3]
			GET_VALUE: 
			begin
				addOutA = g_coeff;
				addOutB = 16'd3;
				memReadAddr = addIn;
				nextstate = NEGATE_ADD;
			end

			// exp_g_coeff_cs[1] = negate(add(g_coeff[3], 1));   /* Q-Format:XXX -> JPN  */
			NEGATE_ADD: 
			begin
				addOutA = memIn;
				addOutB = 16'd1;
				if (addIn[15] == 1)
					negateOut = {16'hffff,addIn};
				else
					negateOut = {16'h0000,addIn};
				memWriteAddr = temp;
				memOut = negateIn;
				memWriteEn = 1;
				nextstate = DONE;
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
