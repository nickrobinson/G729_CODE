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

module TL_Math2 (clock,reset,start,addIn,subIn,L_subIn,T_op,PIT_MIN,PIT_MAX,
				 addOutA,addOutB,subOutA,subOutB,L_subOutA,L_subOutB,T0_min,T0_max,done);

	`include "paramList.v"
	
	//inputs
	input clock;
	input reset;
	input start;
	input [15:0] addIn;
	input [15:0] subIn;
	input [31:0] L_subIn;
	input [15:0] T_op;
	input [15:0] PIT_MIN;
	input [15:0] PIT_MAX;
	
	//outputs
	output reg [15:0] addOutA;
	output reg [15:0] addOutB;
	output reg [15:0] subOutA;
	output reg [15:0] subOutB;
	output reg [31:0] L_subOutA;
	output reg [31:0] L_subOutB;
	output [15:0] T0_min;
	output [15:0] T0_max;
	output reg done;
	
	//wires/regs
	reg [1:0] currentstate, nextstate;
	reg [15:0] nextT0_min, nextT0_max;
	reg [15:0] T0_min, T0_max;
	reg LDT0_min, LDT0_max;
	reg resetT0_min, resetT0_max;
	
	//parameters
	parameter INIT = 3'd0;
	parameter S1 = 3'd1;
	parameter S2 = 3'd2;
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
			T0_min <= 0;
		else if (resetT0_min)
			T0_min <= 0;
		else if (LDT0_min)
			T0_min <= nextT0_min;
	end
	
	always @ (posedge clock)
	begin
		if (reset)
			T0_max <= 0;
		else if (resetT0_max)
			T0_max <= 0;
		else if (LDT0_max)
			T0_max <= nextT0_max;
	end
	
	always@(*) begin
	   addOutA = 0;
		addOutB = 0;
		subOutA = 0;
		subOutB = 0;
		L_subOutA = 0;
		L_subOutB = 0;
		done = 0;
		
		nextstate = currentstate;
		nextT0_min = T0_min;
		nextT0_max = T0_max;
		LDT0_min = 0;
		LDT0_max = 0;
		resetT0_min = 0;
		resetT0_max = 0;
		case(currentstate)

			INIT: 
			begin
				resetT0_min = 1;
				resetT0_max = 1;
				if(start == 1)
					nextstate = S1;
				else
					nextstate = INIT;
			end
			
			//T0_min = sub(T_op, 3);
			// if (sub(T0_min,PIT_MIN)<0) {
			  // T0_min = PIT_MIN;
			// }
			S1: 
			begin
				subOutA = T_op;
				subOutB = 16'd3;
				if (subIn[15] == 1)
					L_subOutA = {16'hffff, subIn};
				else
					L_subOutA = {16'h0000, subIn};
				L_subOutB = PIT_MIN;
				if (L_subIn[31] == 1)
					nextT0_min = PIT_MIN;
				else
					nextT0_min = subIn;
				LDT0_min = 1;
				nextstate = S2;
			end

			// T0_max = add(T0_min, 6);
			// if (sub(T0_max ,PIT_MAX)>0)
			// {
			 // T0_max = PIT_MAX;
			 // T0_min = sub(T0_max, 6);
			// }
			S2: 
			begin
				addOutA = T0_min;
				addOutB = 16'd6;
				if (addIn[15] == 1)
					L_subOutA = {16'hffff, addIn};
				else
					L_subOutA = {16'h0000, addIn};
				L_subOutB = PIT_MAX;
				if ((L_subIn[31] == 0) && (L_subIn != 0))
				begin
					nextT0_max = PIT_MAX;
					subOutA = PIT_MAX;
					subOutB = 16'd6;
					nextT0_min = subIn;
					LDT0_min = 1;
				end
				else
					nextT0_max = addIn;
				LDT0_max = 1;
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
