`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:26:05 04/11/2011
// Module Name:    Corr_xy2.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "Corr_xy2".
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Corr_xy2(clk,reset,start,shrIn,L_macIn,addIn,norm_lIn,norm_lDone,L_shlIn,L_shlDone,
					 L_addIn,subIn,L_negateIn,memIn,shrVar1Out,shrVar2Out,L_macOutA,L_macOutB,
					 L_macOutC,addOutA,addOutB,norm_lVar1Out,norm_lReady,L_shlVar1Out,L_shlNumShiftOut,
					 L_shlReady,L_addOutA,L_addOutB,subOutA,subOutB,L_negateOut,memReadAddr,memWriteAddr,
				    memOut,memWriteEn,done);
					 
`include "paramList.v"

//Inputs
input clk,reset,start;
input [15:0] shrIn;
input [31:0] L_macIn;
input [15:0] addIn;
input [15:0] norm_lIn;
input norm_lDone;
input [31:0] L_shlIn;
input L_shlDone;
input [31:0] L_addIn;
input [15:0] subIn;
input [31:0] L_negateIn;
input [31:0] memIn;

//Outputs
output reg [15:0] shrVar1Out,shrVar2Out;
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;
output reg [15:0] addOutA,addOutB;
output reg [31:0] norm_lVar1Out;
output reg norm_lReady;
output reg [31:0] L_shlVar1Out;
output reg [15:0] L_shlNumShiftOut;
output reg L_shlReady;
output reg [31:0] L_addOutA,L_addOutB;
output reg [15:0] subOutA,subOutB;
output reg [31:0] L_negateOut;
output reg  [11:0] memReadAddr,memWriteAddr;
output reg [31:0] memOut;
output reg memWriteEn;
output reg done;

//Internal Regs
reg [5:0] state,nextstate;
reg [15:0] i,nexti;
reg iLD,iReset;
reg [15:0] exp,nextexp;
reg expLD,expReset;
reg [15:0] exp_y2y2,nextexp_y2y2;
reg exp_y2y2LD,exp_y2y2Reset;
reg [15:0] exp_xny2,nextexp_xny2;
reg exp_xny2LD,exp_xny2Reset;
reg [15:0] exp_y1y2,nextexp_y1y2;
reg exp_y1y2LD, exp_y1y2Reset;
reg [15:0] y2y2,nexty2y2;
reg y2y2LD,y2y2Reset;
reg [15:0] xny2,nextxny2;
reg xny2LD,xny2Reset;
reg [15:0] y1y2,nexty1y2;
reg y1y2LD,y1y2Reset;
reg [31:0] L_acc,nextL_acc;
reg L_accLD,L_accReset;
reg [31:0] temp,nexttemp;
reg tempLD,tempReset;

//State parameters
parameter INIT = 6'd0;
parameter S1 = 6'd1;
parameter S2 = 6'd2;
parameter S3 = 6'd3;
parameter S4 = 6'd4;
parameter S5 = 6'd5;
parameter S6 = 6'd6;
parameter S7 = 6'd7;
parameter S8 = 6'd8;
parameter S9 = 6'd9;
parameter S10 = 6'd10;
parameter S11 = 6'd11;
parameter S12 = 6'd12;
parameter S13 = 6'd13;
parameter S14 = 6'd14;
parameter S15 = 6'd15;
parameter S16 = 6'd16;
parameter S17 = 6'd17;
parameter S18 = 6'd18;
parameter S19 = 6'd19;
parameter S20 = 6'd20;
parameter S21 = 6'd21;
parameter S22 = 6'd22;
parameter S23 = 6'd23;
parameter S24 = 6'd24;
parameter S25 = 6'd25;
parameter S26 = 6'd26;
parameter S27 = 6'd27;
parameter S28 = 6'd28;
parameter S29 = 6'd29;
parameter S30 = 6'd30;
parameter S31 = 6'd31;
parameter S32 = 6'd32;


//Flip Flops
always @(posedge clk)
begin
	if(reset)
		state <= INIT;
	else
		state <= nextstate;
end

always @(posedge clk)
begin
	if(reset)
		i <= 0;
	else if(iReset)
		i <= 0;
	else if(iLD)
		i <= nexti;
end

always @(posedge clk)
begin
	if(reset)
		exp <= 0;
	else if(expReset)
		exp <= 0;
	else if(expLD)
		exp <= nextexp;
end

always @(posedge clk)
begin
	if(reset)
		exp_y2y2 <= 0;
	else if(exp_y2y2Reset)
		exp_y2y2 <= 0;
	else if(exp_y2y2LD)
		exp_y2y2 <= nextexp_y2y2;
end

always @(posedge clk)
begin
	if(reset)
		exp_xny2 <= 0;
	else if(exp_xny2Reset)
		exp_xny2 <= 0;
	else if(exp_xny2LD)
		exp_xny2 <= nextexp_xny2;
end

always @(posedge clk)
begin
	if(reset)
		exp_y1y2 <= 0;
	else if(exp_y1y2Reset)
		exp_y1y2 <= 0;
	else if(exp_y1y2LD)
		exp_y1y2 <= nextexp_y1y2;
end

always @(posedge clk)
begin
	if(reset)
		y2y2 <= 0;
	else if(y2y2Reset)
		y2y2 <= 0;
	else if(y2y2LD)
		y2y2 <= nexty2y2;
end

always @(posedge clk)
begin
	if(reset)
		xny2 <= 0;
	else if(xny2Reset)
		xny2 <= 0;
	else if(xny2LD)
		xny2 <= nextxny2;
end

always @(posedge clk)
begin
	if(reset)
		y1y2 <= 0;
	else if(y1y2Reset)
		y1y2 <= 0;
	else if(y1y2LD)
		y1y2 <= nexty1y2;
end

always @(posedge clk)
begin
	if(reset)
		L_acc <= 0;
	else if(L_accReset)
		L_acc <= 0;
	else if(L_accLD)
		L_acc <= nextL_acc;
end

always @(posedge clk)
begin
	if(reset)
		temp <= 0;
	else if(tempReset)
		temp <= 0;
	else if(tempLD)
		temp <= nexttemp;
end
//state machine always block
always @(*)
begin
	shrVar1Out = 0;
	shrVar2Out = 0;
	L_macOutA = 0;
	L_macOutB = 0;
	L_macOutC = 0;
	addOutA = 0;
	addOutB = 0;
	norm_lVar1Out = 0;
	norm_lReady = 0;
	L_shlVar1Out = 0;
	L_shlNumShiftOut = 0;
	L_shlReady = 0;
	L_addOutA = 0;
	L_addOutB = 0;
	subOutA = 0;
	subOutB = 0;
	L_negateOut = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
	memOut = 0;
	memWriteEn = 0;
	done = 0;
	nextstate = state;
	nexti = i;
	nextexp = exp;
	nextexp_y2y2 = exp_y2y2;
	nextexp_xny2 = exp_xny2;
	nextexp_y1y2 = exp_y1y2;
	nexty2y2 = y2y2;
	nextxny2 = xny2;
	nexty1y2 = y1y2;
	nextL_acc = L_acc;
	nexttemp = temp;
	iLD = 0;
	expLD = 0;
	exp_y2y2LD = 0;
	exp_xny2LD = 0;
	exp_y1y2LD = 0;
	y2y2LD = 0;
	xny2LD = 0;
	y1y2LD = 0;
	iReset = 0;
	L_accLD = 0;
	tempLD = 0;
	expReset = 0;
	exp_y2y2Reset = 0;
	exp_xny2Reset = 0;
	exp_y1y2Reset = 0;
	y2y2Reset = 0;
	xny2Reset = 0;
	y1y2Reset = 0;
	L_accReset = 0;
	tempReset = 0;
	iReset = 0;
	
	case(state)
		INIT:
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin
				expReset = 1;
				exp_y2y2Reset = 1;
				exp_xny2Reset = 1;
				exp_y1y2Reset = 1;
				y2y2Reset = 1;
				xny2Reset = 1;
				y1y2Reset = 1;
				iReset = 1;
				L_accReset = 1;
				tempReset = 1;
				nextstate = S1;
			end
		end//INIT
		
		//for(i=0; i<L_SUBFR; i++)
		S1:
		begin
			if(i>=40)
			begin
				nextL_acc = 32'd1;
				L_accLD = 1;
				iReset = 1;
				nextstate = S3;
			end
			else if(i<40)
			begin
				memReadAddr = {Y2[11:6],i[5:0]};
				nextstate = S2;
			end			
		end//S1
		
		//scaled_y2[i] = shr(y2[i], 3);
		S2:
		begin
			shrVar1Out = memIn[15:0];
			shrVar2Out = 16'd3;
			memOut = shrIn[15:0];
			memWriteEn = 1;
			memWriteAddr = {CORR_XY2_SCALED_Y2[11:6],i[5:0]};
			addOutA = i;
			addOutB = 16'd1;
			nexti = addIn;
			iLD = 1;
			nextstate = S1;
		end//S2
		
		/* L_acc = 1; 
         for(i=0; i<L_SUBFR; i++) */
		S3:
		begin
			if(i>=40)
				nextstate = S5;
			else if(i<40)
			begin
				memReadAddr = {CORR_XY2_SCALED_Y2[11:6],i[5:0]};
				nextstate = S4;
			end
		end//S3
		
		//L_acc = L_mac(L_acc, scaled_y2[i], scaled_y2[i]);
		S4:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = memIn[15:0];
			L_macOutC = L_acc;
			nextL_acc = L_macIn;
			L_accLD = 1;
			addOutA = i;
			addOutB = 16'd1;
			nexti = addIn;
			iLD = 1;
			nextstate = S3;
		end//S4
		
		//exp = norm_l(L_acc);
		S5:
		begin
			norm_lVar1Out = L_acc;
			norm_lReady = 1;
			if(norm_lDone == 1)
			begin
				nextexp = norm_lIn;
				expLD = 1;
				nextstate = S7;
			end
			else
				nextstate = S6;
		end//S5
		
		S6:
		begin
			norm_lVar1Out = L_acc;
			if(norm_lDone == 0)
				nextstate = S6;
			else if(norm_lDone == 1)
			begin
				nextexp = norm_lIn;
				expLD = 1;
				nextstate = S7;
			end			
		end//S6
		
		//L_shl(L_acc, exp)
		S7:
		begin
			L_shlVar1Out = L_acc;
			L_shlNumShiftOut = exp;
			L_shlReady = 1;
			if(L_shlDone == 1)
			begin
				nexttemp = L_shlIn;
				tempLD = 1;
				nextstate = S9;
			end
			else 
				nextstate = S8;			
		end//S7
		
		S8:
		begin
			L_shlVar1Out = L_acc;
			L_shlNumShiftOut = exp;	
			if(L_shlDone == 0)
				nextstate = S8;
			else if(L_shlDone == 1)
			begin
				nexttemp = L_shlIn;
				tempLD = 1;
				nextstate = S9;
			end			
		end//S8
		
		/* y2y2 = round( L_shl(L_acc, exp) );
			exp_y2y2 = add(exp, 19-16); */
		S9:
		begin
			L_addOutA = temp;
			L_addOutB = 32'h0000_8000;
			nexty2y2 = L_addIn[31:16];
			y2y2LD = 1;
			addOutA = exp;
			addOutB = 16'd3;
			nextexp_y2y2 = addIn;
			exp_y2y2LD = 1;
			nextstate = S10;			
		end//S9
		
		/* g_coeff[2] = y2y2;*/
		S10:
		begin
			memWriteAddr = {G_COEFF_CS[11:2],2'd2};
			memOut = y2y2;
			memWriteEn = 1;
			nextstate = S11;
		end//S10
		
		/* exp_g_coeff[2] = exp_y2y2; 
			L_acc = 1; */
		S11:
		begin
			memWriteAddr = {EXP_G_COEFF_CS[11:2],2'd2};
			memOut = exp_y2y2;
			memWriteEn = 1;
			nextL_acc = 16'd1;
			L_accLD = 1;
			iReset = 1;
			nextstate = S12;
		end//S11
		
		//for(i=0; i<L_SUBFR; i++)
		S12:
		begin
			if(i>= 40)
				nextstate = S15;
			else if(i<40)
			begin
				memReadAddr = {CORR_XY2_SCALED_Y2[11:6],i[5:0]};
				nextstate = S13;
			end
		end//S12
		
		S13:
		begin
			nexttemp = memIn[15:0];
			tempLD = 1;
			memReadAddr = {XN[11:6],i[5:0]};
			nextstate = S14;			
		end//S13
		
		//L_acc = L_mac(L_acc, xn[i], scaled_y2[i]);
		S14:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = temp[15:0];
			L_macOutC = L_acc;
			nextL_acc = L_macIn;
			L_accLD = 1;
			addOutA = i;
			addOutB = 16'd1;
			nexti = addIn;
			iLD = 1;
			nextstate = S12;
		end//S14
	
		// exp = norm_l(L_acc);
		S15:
		begin
			norm_lVar1Out = L_acc;
			norm_lReady = 1;
			if(norm_lDone == 1)
			begin
				nextstate = S17;
				nextexp = norm_lIn;
				expLD = 1;
			end
			else
				nextstate = S16;
		end//S15
		
		// exp = norm_l(L_acc);
		S16:
		begin
			norm_lVar1Out = L_acc;
			if(norm_lDone == 0)
				nextstate = S16;
			else if(norm_lDone == 1)
			begin
				nextstate = S17;
				nextexp = norm_lIn;
				expLD = 1;
			end
		end//S16
		
		//L_shl(L_acc, exp)
		S17:
		begin
			L_shlVar1Out = L_acc;
			L_shlNumShiftOut = exp;
			L_shlReady = 1;
			if(L_shlDone == 1)
			begin
				nexttemp = L_shlIn;
				tempLD = 1;
				nextstate = S19;
			end
			else
				nextstate = S18;
		end//S17
		
		//L_shl(L_acc, exp)
		S18:
		begin
			L_shlVar1Out = L_acc;
			L_shlNumShiftOut = exp;
			if(L_shlDone == 0)
				nextstate = S18;
			else if(L_shlDone == 1)
			begin
				nexttemp = L_shlIn;
				tempLD = 1;
				nextstate = S19;
			end			
		end//S18
		
		/* xny2     = round( L_shl(L_acc, exp) );
		   exp_xny2 = add(exp, 10-16); */
		S19:
		begin
			L_addOutA = temp;
			L_addOutB = 32'h0000_8000;
			nextxny2 = L_addIn[31:16];
			xny2LD = 1;
			addOutA = exp;
			addOutB = 16'hfffa;
			nextexp_xny2 = addIn;
			exp_xny2LD = 1;
			nextstate = S20;
		end//S19
		
		//g_coeff[3]     = negate(xny2);
		S20:
		begin
			if(xny2[15] == 1)
				L_negateOut = {16'hffff,xny2[15:0]};
			else if(xny2[15] == 0)
				L_negateOut = {16'd0,xny2[15:0]};
			memWriteEn = 1;
			memWriteAddr = {G_COEFF_CS[11:2],2'd3};
			memOut = L_negateIn[15:0];
			nextstate = S21;
		end//S20
		
		/* exp_g_coeff[3] = sub(exp_xny2,1);
		   L_acc = 1;  */
		S21:
		begin
			subOutA = exp_xny2;
			subOutB = 16'd1;
			memWriteAddr = {EXP_G_COEFF_CS[11:2],2'd3};
			memOut = subIn[15:0];
			memWriteEn = 1;
			nextL_acc = 32'd1;
			L_accLD = 1;
			iReset = 1;
			nextstate = S22;
		end//S21
		
		//for(i=0; i<L_SUBFR; i++)
		S22:
		begin
			if(i>=40)
				nextstate = S25;
			else if(i<40)
			begin
				memReadAddr = {CORR_XY2_SCALED_Y2[11:6],i[5:0]};
				nextstate = S23;
			end
		end//S22
		
		S23:
		begin
			nexttemp = memIn[15:0];
			tempLD = 1;
			memReadAddr = {Y1[11:6],i[5:0]};
			nextstate = S24;
		end//S23
		
		//L_acc = L_mac(L_acc, y1[i], scaled_y2[i]);
		S24:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = temp[15:0];
			L_macOutC = L_acc;
			nextL_acc = L_macIn;
			L_accLD = 1;
			addOutA = i;
			addOutB = 16'd1;
			nexti = addIn;
			iLD = 1;
			nextstate = S22;
		end//S24
		
		 //exp = norm_l(L_acc);
		S25:
		begin
			norm_lVar1Out = L_acc;
			norm_lReady = 1;
			if(norm_lDone == 1)
			begin
				nextexp = norm_lIn;
				expLD = 1;
				nextstate = S27;
			end
			else
				nextstate = S26;
		end//S25
		
		//exp = norm_l(L_acc);
		S26:
		begin
			norm_lVar1Out = L_acc;	
			if(norm_lDone == 0)
				nextstate = S26;
			else if(norm_lDone == 1)
			begin
				nextexp = norm_lIn;
				expLD = 1;
				nextstate = S27;
			end			
		end//S26
		
		//L_shl(L_acc, exp)
		S27:
		begin
			L_shlVar1Out = L_acc;
			L_shlNumShiftOut = exp;
			L_shlReady = 1;
			if(L_shlDone == 1)
			begin
				nexttemp = L_shlIn;
				tempLD = 1;
				nextstate = S29;
			end
			else
				nextstate = S28;
		end//S27
		
		S28:
		begin
			L_shlVar1Out = L_acc;
			L_shlNumShiftOut = exp;
			if(L_shlDone == 0)
				nextstate = S28;
			else if(L_shlDone == 1)
			begin
				nexttemp = L_shlIn;
				tempLD = 1;
				nextstate = S29;
			end			
		end//S28
		
		/*  y1y2     = round( L_shl(L_acc, exp) );
			 exp_y1y2 = add(exp, 10-16); */  
		S29:
		begin
			L_addOutA = temp;
			L_addOutB = 32'h0000_8000;
			nexty1y2 = L_addIn[31:16];
			y1y2LD = 1;
			addOutA = exp;
			addOutB = 16'hfffa;
			nextexp_y1y2 = addIn;
			exp_y1y2LD = 1;
			nextstate = S30;
		end//S29
		
		//g_coeff[4] = y1y2;
		S30:
		begin
			memOut = y1y2[15:0];
			memWriteAddr = {G_COEFF_CS[11:3],3'd4};
			memWriteEn = 1;
			nextstate = S31;
		end//S30
		
		//exp_g_coeff[4] = sub(exp_y1y2,1);
		S31:
		begin
			subOutA = exp_y1y2;
			subOutB = 16'd1;
			memOut = subIn[15:0];
			memWriteEn = 1;
			memWriteAddr = {EXP_G_COEFF_CS[11:3],3'd4};
			nextstate = S32;
		end//S31
		
		S32:
		begin
			done = 1;
			nextstate = INIT;
		end//S32
	endcase
end//always
endmodule
