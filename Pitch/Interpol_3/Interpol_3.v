`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:22:43 03/17/2011 
// Design Name: 
// Module Name:    Interpol_3 
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
module Interpol_3(
	input clk,
	input reset,
	input start,
	input [11:0] x,
	input [15:0] frac,
	input [11:0] inter_3,
	input [15:0] addIn,
	input [15:0] subIn,
	input [31:0] L_addIn,
	input [31:0] L_macIn,
	input [31:0] FSMdataInScratch,
	input [31:0] FSMdataInConstant,	
	
	output reg [15:0] addOutA,
	output reg [15:0] addOutB,
	output reg [15:0] subOutA,
	output reg [15:0] subOutB,
	output reg [31:0] L_addOutA,
	output reg [31:0] L_addOutB,
	output reg [15:0] L_macOutA,
	output reg [15:0] L_macOutB,
	output reg [31:0] L_macOutC,
	output reg [11:0] FSMreadAddrScratch,
	output reg [11:0] FSMreadAddrConstant,
	output reg [15:0] returnS,
	output reg done
   );

	parameter S0_INIT = 'd0;
	parameter S1_IF = 'd1;
	parameter S2_X = 'd2;
	parameter S3_C1 = 'd3;
	parameter S4_C2 = 'd4;
	parameter S5_FOR = 'd5;
	parameter S6_LMAC1_A = 'd6;
	parameter S7_LMAC1_B = 'd7;
	parameter S8_LMAC2_A = 'd8;
	parameter S9_LMAC2_B = 'd9;
	parameter S10_INC = 'd10;
	parameter S11_DONE = 'd11;
	parameter L_INTER4 = 'd4;
	parameter UP_SAMP = 'd3;
	
	reg [3:0] state, nextstate;
	reg [11:0] X, nextX;
	reg resetX, ldX;
	reg [15:0] FRAC, nextFRAC;
	reg resetFRAC, ldFRAC;
	reg [15:0] I, nextI;
	reg resetI, ldI;
	reg [15:0] K, nextK;
	reg resetK, ldK;
	reg [15:0] X1, nextX1;
	reg resetX1, ldX1;
	reg [15:0] X2, nextX2;
	reg resetX2, ldX2;
	reg [15:0] C1, nextC1;
	reg resetC1, ldC1;
	reg [15:0] C2, nextC2;
	reg resetC2, ldC2;
	reg [31:0] S, nextS;
	reg resetS, ldS;
	reg [15:0] nextreturnS;
	reg resetreturnS, ldreturnS;
	reg [31:0] TEMP, nextTEMP;
	reg resetTEMP, ldTEMP;

	//Flops
	always @ (posedge clk)
	begin
		if (reset)
			state <= 0;
		else
			state <= nextstate;
	end
	
	always @ (posedge clk)
	begin
		if (reset)
			X <= 0;
		else if (resetX)
			X <= 0;
		else if (ldX)
			X <= nextX;
	end
	
	always @ (posedge clk)
	begin
		if (reset)
			FRAC <= 0;
		else if (resetFRAC)
			FRAC <= 0;
		else if (ldFRAC)
			FRAC <= nextFRAC;
	end

	always @ (posedge clk)
	begin
		if (reset)
			I <= 0;
		else if (resetI)
			I <= 0;
		else if (ldI)
			I <= nextI;
	end
	
	always @ (posedge clk)
	begin
		if (reset)
			K <= 0;
		else if (resetK)
			K <= 0;
		else if (ldK)
			K <= nextK;
	end
	
	always @ (posedge clk)
	begin
		if (reset)
			X1 <= 0;
		else if (resetX1)
			X1 <= 0;
		else if (ldX1)
			X1 <= nextX1;
	end
	
	always @ (posedge clk)
	begin
		if (reset)
			X2 <= 0;
		else if (resetX2)
			X2 <= 0;
		else if (ldX2)
			X2 <= nextX2;
	end
	
	always @ (posedge clk)
	begin
		if (reset)
			C1 <= 0;
		else if (resetC1)
			C1 <= 0;
		else if (ldC1)
			C1 <= nextC1;
	end
	
	always @ (posedge clk)
	begin
		if (reset)
			C2 <= 0;
		else if (resetC2)
			C2 <= 0;
		else if (ldC2)
			C2 <= nextC2;
	end
	
	always @ (posedge clk)
	begin
		if (reset)
			S <= 0;
		else if (resetS)
			S <= 0;
		else if (ldS)
			S <= nextS;
	end
	
	always @ (posedge clk)
	begin
		if (reset)
			returnS <= 0;
		else if (resetreturnS)
			returnS <= 0;
		else if (ldreturnS)
			returnS <= nextreturnS;
	end
	
	always @ (posedge clk)
	begin
		if (reset)
			TEMP <= 0;
		else if (resetTEMP)
			TEMP <= 0;
		else if (ldTEMP)
			TEMP <= nextTEMP;
	end
	
	always @ (*)
	begin
		//set outputs to default
		nextstate = state;
		nextX = X;
		nextFRAC = FRAC;
		nextI = I;
		nextK = K;
		nextX1 = X1;
		nextX2 = X2;
		nextC1 = C1;
		nextC2 = C2;
		nextS = S;
		nextreturnS = returnS;
		nextTEMP = TEMP;
		resetX = 0;
		resetFRAC = 0;
		resetI = 0;
		resetK = 0;
		resetX1 = 0;
		resetX2 = 0;
		resetC1 = 0;
		resetC2 = 0;
		resetS = 0;
		resetreturnS = 0;
		resetTEMP = 0;
		ldX = 0;
		ldFRAC = 0;
		ldI = 0;
		ldK = 0;
		ldX1 = 0;
		ldX2 = 0;
		ldC1 = 0;
		ldC2 = 0;
		ldS = 0;
		ldreturnS = 0;
		ldTEMP = 0;
		addOutA = 0;
		addOutB = 0;
		subOutA = 0;
		subOutB = 0;
		L_addOutA = 0;
		L_addOutB = 0;
		L_macOutA = 0;
		L_macOutB = 0;
		L_macOutC = 0;
		FSMreadAddrScratch = 12'b0;
		FSMreadAddrConstant = 0;
		done = 0;
		case (state)
			S0_INIT:
			begin
				//reset flops
				resetX = 1;
				resetFRAC = 1;
				resetI = 1;
				resetK = 1;
				resetX1 = 1;
				resetX2 = 1;
				resetC1 = 1;
				resetC2 = 1;
				resetS = 1;
				resetreturnS = 1;
				resetTEMP = 1;
				if (start)
				begin
					nextstate = S1_IF;
				end
				else
					nextstate = S0_INIT;
			end
			S1_IF:
			begin
				if (frac[15] == 1)
				begin
					addOutA = frac;
					addOutB = UP_SAMP;
					nextFRAC = addIn;
					ldFRAC = 1;
					subOutA = x;
					subOutB = 'd1;
					nextX = subIn;
					ldX = 1;
				end
				else
				begin
					nextFRAC = frac;
					ldFRAC = 1;
					nextX = x;
					ldX = 1;
				end
				nextstate = S2_X;
			end
			S2_X:
			begin
				nextX1 = X;
				ldX1 = 1;
				addOutA = X;
				addOutB = 1;
				nextX2 = addIn;
				ldX2 = 1;
				nextstate = S3_C1;				
			end
			S3_C1:
			begin
				addOutA = inter_3;
				addOutB = FRAC;
				nextC1 = addIn;
				ldC1 = 1;
				nextstate = S4_C2;				
			end
			S4_C2:
			begin
				subOutA = UP_SAMP;
				subOutB = FRAC;
				addOutA = inter_3;
				addOutB = subIn;
				nextC2 = addIn;
				ldC2 = 1;
				nextstate = S5_FOR;				
			end
			S5_FOR:
			begin
				if (I < L_INTER4)
				begin
					subOutA = X1;
					subOutB = I;
					FSMreadAddrScratch = subIn;
					nextstate = S6_LMAC1_A;
				end
				else
				begin
					L_addOutA = S;
					L_addOutB = 'h00008000;
					nextreturnS = L_addIn[31:16];
					ldreturnS = 1;
					nextstate = S11_DONE;
				end
			end
			S6_LMAC1_A:
			begin
				addOutA = C1;
				addOutB = K;
				FSMreadAddrConstant = addIn;
				nextTEMP = FSMdataInScratch;
				ldTEMP = 1;
				nextstate = S7_LMAC1_B;
			end
			S7_LMAC1_B:
			begin
				addOutA = X2;
				addOutB = I;
				FSMreadAddrScratch = addIn;
				L_macOutA = TEMP;
				L_macOutB = FSMdataInConstant;
				L_macOutC = S;
				nextS = L_macIn;
				ldS = 1;
				nextstate = S8_LMAC2_A;
			end
			S8_LMAC2_A:
			begin
				addOutA = C2;
				addOutB = K;
				FSMreadAddrConstant = addIn;
				nextTEMP = FSMdataInScratch;
				ldTEMP = 1;
				nextstate = S9_LMAC2_B;
			end
			S9_LMAC2_B:
			begin
				L_macOutA = TEMP;
				L_macOutB = FSMdataInConstant;
				L_macOutC = S;
				nextS = L_macIn;
				ldS = 1;
				addOutA = I;
				addOutB = 'd1;
				nextI = addIn;
				ldI = 1;
				nextstate = S10_INC;
			end
			S10_INC:
			begin
				addOutA = K;
				addOutB = UP_SAMP;
				nextK = addIn;
				ldK = 1;
				nextstate = S5_FOR;
			end			
			S11_DONE:
			begin
				nextstate = S0_INIT;
				done = 1;
			end
			default:
				nextstate = S0_INIT;
		endcase
	end
endmodule
