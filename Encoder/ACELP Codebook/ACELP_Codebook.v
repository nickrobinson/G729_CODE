`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:05:22 03/31/2011
// Module Name:    ACELP_Codebook.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "ACELP_Codebook".
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ACELP_Codebook(clk,reset,start,T0,pitch_sharp,i_subfr,shlIn,subIn,addIn,multIn,L_macIn,
							 L_absIn,L_subIn,norm_lIn,norm_lDone,L_shrIn,L_negateIn,L_multIn,L_msuIn,shrIn,
							 L_addIn,L_add2In,L_add3In,L_add4In,memIn,shlVar1Out,shlVar2Out,subOutA,
							 subOutB,addOutA,addOutB,multOutA,multOutB,L_macOutA,L_macOutB,L_macOutC,
							 L_absOut,L_subOutA,L_subOutB,norm_lVar1Out,norm_lReady,L_shrVar1Out,
							 L_shrNumShiftOut,L_negateOut,L_multOutA,L_multOutB,L_msuOutA,L_msuOutB,
							 L_msuOutC,shrVar1Out,shrVar2Out,L_addOutA,L_addOutB,L_add2OutA,L_add2OutB,
							 L_add3OutA,L_add3OutB,L_add4OutA,L_add4OutB,memReadAddr,memWriteAddr,memOut,
							 memWriteEn,index,i_out,done);

`include "paramList.v"

//Inputs
input clk,reset,start;
input [15:0] T0;
input [15:0] pitch_sharp;
input [15:0] i_subfr;
input [15:0] shlIn;
input [15:0] subIn;
input [15:0] addIn;
input [15:0] multIn;
input [31:0] L_macIn;
input [31:0] L_absIn;
input [31:0] L_subIn;
input [15:0] norm_lIn;
input norm_lDone;
input [31:0] L_shrIn;
input [31:0] L_negateIn;
input [31:0] L_multIn;
input [31:0] L_msuIn;
input [15:0] shrIn;
input [31:0] L_addIn;
input [31:0] L_add2In;
input [31:0] L_add3In;
input [31:0] L_add4In;
input [31:0] memIn;

//Outputs
output reg [15:0] shlVar1Out,shlVar2Out;
output reg [15:0] subOutA,subOutB;
output reg [15:0] addOutA,addOutB;
output reg [15:0] multOutA,multOutB;
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;
output reg [31:0] L_absOut;
output reg [31:0] L_subOutA,L_subOutB;
output reg [31:0] norm_lVar1Out;
output reg norm_lReady;
output reg [31:0] L_shrVar1Out;
output reg [15:0] L_shrNumShiftOut;
output reg [31:0] L_negateOut;
output reg [15:0] L_multOutA,L_multOutB;
output reg [15:0] L_msuOutA,L_msuOutB;
output reg [31:0] L_msuOutC;
output reg [15:0] shrVar1Out,shrVar2Out;
output reg [31:0] L_addOutA,L_addOutB;
output reg [31:0] L_add2OutA,L_add2OutB;
output reg [31:0] L_add3OutA,L_add3OutB;
output reg [31:0] L_add4OutA,L_add4OutB;
output reg [11:0] memReadAddr,memWriteAddr;
output reg [31:0] memOut;
output reg memWriteEn;
output [15:0] index;
output reg [15:0] i_out;
output reg done;

//Internal regs
reg [3:0] state,nextstate;
reg [15:0] i,nexti;
reg iLD,iReset;
reg [15:0] index,nextindex;
reg indexLD,indexReset;
reg [15:0] sharp,nextsharp;
reg sharpLD,sharpReset;
reg [31:0] temp,nexttemp;
reg tempLD,tempReset;
reg [15:0] T0Reg,nextT0Reg;
reg T0LD,T0Reset;
reg [15:0] pitch_sharpReg,nextpitch_sharpReg;
reg pitch_sharpLD,pitch_sharpReset;
reg [15:0] i_subfrReg,nexti_subfrReg;
reg i_subfrLD,i_subfrReset;

//CorH wires;
reg corH_start;
wire [15:0] corH_L_macOutA,corH_L_macOutB;
wire [31:0] corH_L_macOutC;
wire [31:0] corH_L_subOutA,corH_L_subOutB;
wire [15:0] corH_subOutA,corH_subOutB;
wire [15:0] corH_shrVar1Out,corH_shrVar2Out;
wire [31:0] corH_norm_lVar1Out;
wire corH_norm_lReady;
wire [15:0] corH_shlVar1Out,corH_shlVar2Out;
wire [15:0] corH_addOutA,corH_addOutB;
wire [31:0] corH_L_addOutA,corH_L_addOutB,corH_L_add2OutA,corH_L_add2OutB;
wire [31:0] corH_L_add3OutA,corH_L_add3OutB;
wire [31:0] corH_L_add4OutA,corH_L_add4OutB;
wire [11:0] corH_memReadAddr,corH_memWriteAddr;
wire [31:0] corH_memOut;
wire corH_memWriteEn;
wire corH_done;

//D4i40_17 wires
reg D4i40_17_start;
wire [15:0] D4i40_17_addOutA,D4i40_17_addOutB;
wire [31:0] D4i40_17_L_addOutA,D4i40_17_L_addOutB;
wire [31:0] D4i40_17_L_negateOut;
wire [15:0] D4i40_17_subOutA,D4i40_17_subOutB;
wire [15:0] D4i40_17_L_macOutA,D4i40_17_L_macOutB;
wire [31:0] D4i40_17_L_macOutC;
wire [31:0] D4i40_17_L_shrVar1Out;
wire [15:0] D4i40_17_L_shrNumShiftOut;
wire [15:0] D4i40_17_multOutA,D4i40_17_multOutB;
wire [15:0]	D4i40_17_L_multOutA,D4i40_17_L_multOutB;
wire [15:0] D4i40_17_L_msuOutA,D4i40_17_L_msuOutB;
wire [31:0] D4i40_17_L_msuOutC;
wire [31:0] D4i40_17_L_subOutA,D4i40_17_L_subOutB;
wire [15:0] D4i40_17_shrVar1Out,D4i40_17_shrVar2Out;
wire [15:0] D4i40_17_shlVar1Out,D4i40_17_shlVar2Out;
wire [11:0] D4i40_17_memReadAddr,D4i40_17_memWriteAddr;
wire D4i40_17_memWriteEn;
wire [31:0] D4i40_17_memOut;
wire [15:0] D4i40_17_i;
wire D4i40_17_done;

//Cor_h_X wires
reg Cor_h_X_start;
wire [31:0] Cor_h_X_L_absOut;
wire [15:0] Cor_h_X_L_macOutA,Cor_h_X_L_macOutB;
wire [31:0] Cor_h_X_L_macOutC;
wire [31:0] Cor_h_X_L_subOutA,Cor_h_X_L_subOutB;
wire [15:0] Cor_h_X_addOutA,Cor_h_X_addOutB;
wire [31:0] Cor_h_X_norm_lVar1Out;
wire Cor_h_X_norm_lReady;
wire [15:0] Cor_h_X_subOutA,Cor_h_X_subOutB;
wire [31:0] Cor_h_X_L_shrVar1Out;
wire [15:0] Cor_h_X_L_shrNumShiftOut;
wire [11:0] Cor_h_X_memReadAddr,Cor_h_X_memWriteAddr;
wire [31:0] Cor_h_X_memOut;
wire Cor_h_X_memWriteEn;
wire Cor_h_X_done;

//State parameters
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
parameter S10 = 4'd10;
parameter S11 = 4'd11;
parameter S12 = 4'd12;
parameter S13 = 4'd13;
parameter S14 = 4'd14;
parameter S15 = 4'd15;

//Flip flops
always @(posedge clk)
begin
	if(reset)
		state <= 0;
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
		index <= 0;
	else if(indexReset)
		index <= 0;
	else if(indexLD)
		index <= nextindex;
end

always @(posedge clk)
begin
	if(reset)
		sharp <= 0;
	else if(sharpReset)
		sharp <= 0;
	else if(sharpLD)
		sharp <= nextsharp;
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

always @(posedge clk)
begin
	if(reset)
		T0Reg <= 0;
	else if(T0Reset)
		T0Reg <= 0;
	else if(T0LD)
		T0Reg <= nextT0Reg;
end

always @(posedge clk)
begin
	if(reset)
		pitch_sharpReg <= 0;
	else if(pitch_sharpReset)
		pitch_sharpReg <= 0;
	else if(pitch_sharpLD)
		pitch_sharpReg <= nextpitch_sharpReg;
end

always @(posedge clk)
begin
	if(reset)
		i_subfrReg <= 0;
	else if(i_subfrReset)
		i_subfrReg <= 0;
	else if(i_subfrLD)
		i_subfrReg <= nexti_subfrReg;
end

//instantiated modules
Cor_h CorH_fsm(
			 .clk(clk),
			 .reset(reset),
			 .start(corH_start),			 
			 .L_macIn(L_macIn),
			 .L_subIn(L_subIn),
			 .subIn(subIn),
			 .shrIn(shrIn),
			 .norm_lIn(norm_lIn),
			 .norm_lDone(norm_lDone),
			 .shlIn(shlIn),
			 .addIn(addIn),
			 .L_addIn(L_addIn),
			 .L_add2In(L_add2In),
			 .L_add3In(L_add3In),
			 .L_add4In(L_add4In),
			 .memIn(memIn),
			 .L_macOutA(corH_L_macOutA),
			 .L_macOutB(corH_L_macOutB),
			 .L_macOutC(corH_L_macOutC),
			 .L_subOutA(corH_L_subOutA),
			 .L_subOutB(corH_L_subOutB),
			 .subOutA(corH_subOutA),
			 .subOutB(corH_subOutB),
			 .shrVar1Out(corH_shrVar1Out),
			 .shrVar2Out(corH_shrVar2Out),
			 .norm_lVar1Out(corH_norm_lVar1Out),
			 .norm_lReady(corH_norm_lReady),
			 .shlVar1Out(corH_shlVar1Out),
			 .shlVar2Out(corH_shlVar2Out),
			 .addOutA(corH_addOutA),
			 .addOutB(corH_addOutB),
			 .L_addOutA(corH_L_addOutA),
			 .L_addOutB(corH_L_addOutB),
			 .L_add2OutA(corH_L_add2OutA),
			 .L_add2OutB(corH_L_add2OutB),
			 .L_add3OutA(corH_L_add3OutA),
			 .L_add3OutB(corH_L_add3OutB),
			 .L_add4OutA(corH_L_add4OutA),
			 .L_add4OutB(corH_L_add4OutB),
			 .memReadAddr(corH_memReadAddr),
			 .memWriteAddr(corH_memWriteAddr),
			 .memOut(corH_memOut),
			 .memWriteEn(corH_memWriteEn),
			 .done(corH_done)
			 );
			 

D4i40_17 D4i40_17_fsm(
							 .clk(clk),
							 .reset(reset),
							 .start(D4i40_17_start),
							 .addIn(addIn),
							 .L_addIn(L_addIn),
							 .L_negateIn(L_negateIn),
							 .subIn(subIn),
							 .L_macIn(L_macIn),
							 .L_shrIn(L_shrIn),
							 .multIn(multIn),
							 .L_multIn(L_multIn),
							 .L_msuIn(L_msuIn),
							 .L_subIn(L_subIn),
							 .shrIn(shrIn),
							 .shlIn(shlIn),
							 .memIn(memIn),
							 .i_subfr(i_subfrReg),
							 .addOutA(D4i40_17_addOutA),
							 .addOutB(D4i40_17_addOutB),
							 .L_addOutA(D4i40_17_L_addOutA),
							 .L_addOutB(D4i40_17_L_addOutB),
							 .L_negateOut(D4i40_17_L_negateOut),
							 .subOutA(D4i40_17_subOutA),
							 .subOutB(D4i40_17_subOutB),
							 .L_macOutA(D4i40_17_L_macOutA),
							 .L_macOutB(D4i40_17_L_macOutB),
							 .L_macOutC(D4i40_17_L_macOutC),
							 .L_shrVar1Out(D4i40_17_L_shrVar1Out),
							 .L_shrNumShiftOut(D4i40_17_L_shrNumShiftOut),
							 .multOutA(D4i40_17_multOutA),
							 .multOutB(D4i40_17_multOutB),
							 .L_multOutA(D4i40_17_L_multOutA),
							 .L_multOutB(D4i40_17_L_multOutB),
							 .L_msuOutA(D4i40_17_L_msuOutA),
							 .L_msuOutB(D4i40_17_L_msuOutB),
							 .L_msuOutC(D4i40_17_L_msuOutC),
							 .L_subOutA(D4i40_17_L_subOutA),
							 .L_subOutB(D4i40_17_L_subOutB),
							 .shrVar1Out(D4i40_17_shrVar1Out),
							 .shrVar2Out(D4i40_17_shrVar2Out),
							 .shlVar1Out(D4i40_17_shlVar1Out),
							 .shlVar2Out(D4i40_17_shlVar2Out),
							 .memReadAddr(D4i40_17_memReadAddr),
							 .memWriteAddr(D4i40_17_memWriteAddr),
							 .memWriteEn(D4i40_17_memWriteEn),
							 .memOut(D4i40_17_memOut),
							 .i(D4i40_17_i),
							 .done(D4i40_17_done)
							 );

Cor_h_X Cor_h_X_fsm(
							.clk(clk),
							.reset(reset),
							.start(Cor_h_X_start),
							.L_macIn(L_macIn),
							.L_absIn(L_absIn),
							.L_subIn(L_subIn),
							.addIn(addIn),
							.norm_lIn(norm_lIn),
							.norm_lDone(norm_lDone),
							.subIn(subIn),
							.L_shrIn(L_shrIn),
							.memIn(memIn),
							.L_macOutA(Cor_h_X_L_macOutA),
							.L_macOutB(Cor_h_X_L_macOutB),
							.L_macOutC(Cor_h_X_L_macOutC),
							.L_absOut(Cor_h_X_L_absOut),
							.L_subOutA(Cor_h_X_L_subOutA),
							.L_subOutB(Cor_h_X_L_subOutB),
							.addOutA(Cor_h_X_addOutA),
							.addOutB(Cor_h_X_addOutB),
							.norm_lVar1Out(Cor_h_X_norm_lVar1Out),
							.norm_lReady(Cor_h_X_norm_lReady),
							.subOutA(Cor_h_X_subOutA),
							.subOutB(Cor_h_X_subOutB),
							.L_shrVar1Out(Cor_h_X_L_shrVar1Out),
							.L_shrNumShiftOut(Cor_h_X_L_shrNumShiftOut),
							.memReadAddr(Cor_h_X_memReadAddr),
							.memWriteAddr(Cor_h_X_memWriteAddr),
							.memOut(Cor_h_X_memOut),
							.memWriteEn(Cor_h_X_memWriteEn),
							.done(Cor_h_X_done)
							);
							
always @(*)
begin
	nextstate = state;
	nexti = i;
	nextindex = index;
	nextsharp = sharp;
	nextT0Reg = T0Reg;
	nexttemp = temp;
	nextpitch_sharpReg = pitch_sharpReg;
	nexti_subfrReg = i_subfrReg;
	iReset = 0;
	indexReset = 0;
	sharpReset = 0;
	tempReset = 0;
	i_subfrReset = 0;
   T0Reset = 0;
	pitch_sharpReset = 0;
	iLD = 0;
	indexLD = 0;
	sharpLD = 0;
	tempLD = 0;
	T0LD = 0;
	pitch_sharpLD = 0;
	i_subfrLD = 0;
	corH_start = 0;
	D4i40_17_start = 0;
	Cor_h_X_start = 0;
   shlVar1Out = 0;
	shlVar2Out = 0;
   subOutA = 0;
	subOutB = 0;
   addOutA = 0;
	addOutB = 0;
   multOutA = 0;
	multOutB = 0;
   L_macOutA = 0;
	L_macOutB = 0;
   L_macOutC = 0;
   L_absOut = 0;
   L_subOutA = 0;
	L_subOutB = 0;
   norm_lVar1Out = 0;
   norm_lReady = 0;
   L_shrVar1Out = 0;
   L_shrNumShiftOut = 0;
   L_negateOut = 0;
   L_multOutA = 0;
	L_multOutB = 0;
   L_msuOutA = 0;
	L_msuOutB = 0;
   L_msuOutC = 0;
   shrVar1Out = 0; 
	shrVar2Out = 0;
   L_addOutA = 0;
	L_addOutB = 0;
	L_add2OutA = 0;
	L_add2OutB = 0;
	L_add3OutA = 0;
	L_add3OutB = 0;
	L_add4OutA = 0;
	L_add4OutB = 0;
   memReadAddr = 0;
	memWriteAddr = 0;
   memOut = 0;
   memWriteEn = 0;
	i_out = 0;
   done = 0;
	
	case(state)
		INIT:
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin
				iReset = 1;
				indexReset = 1;
				sharpReset = 1;
				tempReset = 1;
				nexti_subfrReg = i_subfr;
				i_subfrLD = 1;
				nextT0Reg = T0;
				T0LD = 1;
				nextpitch_sharpReg = pitch_sharp;
				pitch_sharpLD = 1;
				nextstate = S1;
			end
		end//INIT
		
		/*  sharp = shl(pitch_sharp, 1);
			 if (sub(T0, L_SUBFR)<0) */
		S1:
		begin
			shlVar1Out = pitch_sharpReg;
			shlVar2Out = 16'd1;
			nextsharp = shlIn;
			sharpLD = 1;
			subOutA = T0Reg;
			subOutB = 16'd40;
			if(subIn[15] == 1) 
			begin
				nexti = T0Reg;
				iLD = 1;
				nextstate = S2;				
			end
			else 
				nextstate = S5;
		end//S1
		
		// for (i = T0; i < L_SUBFR; i++)
		S2:
		begin
			if(i>=40)
				nextstate = S5;
			else if(i<40)
			begin
				subOutA = i;
				subOutB = T0Reg;
				memReadAddr = {H1[11:6],subIn[5:0]};
				nextstate = S3;
			end
		end//S2
		
		//mult(h[i-T0], sharp)
		S3:
		begin
			multOutA = memIn[15:0];
			multOutB = sharp;
			nexttemp = multIn;
			tempLD = 1;
			memReadAddr = {H1[11:6],i[5:0]};
			nextstate = S4;
		end//S3
		
		//h[i] = add(h[i], mult(h[i-T0], sharp));
		S4:
		begin
			addOutA = memIn[15:0];
			addOutB = temp[15:0];
			memOut = addIn[15:0];
			memWriteAddr = {H1[11:6],i[5:0]};
			memWriteEn = 1;
			L_addOutA = i;
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			nextstate = S2;
		end//S4
		
		//Cor_h(h, rr);
		S5:
		begin
			L_macOutA = corH_L_macOutA;
			L_macOutB = corH_L_macOutB;
			L_macOutC = corH_L_macOutC;
			L_subOutA = corH_L_subOutA;
			L_subOutB = corH_L_subOutB;
			subOutA = corH_subOutA;
			subOutB = corH_subOutB;
			shrVar1Out = corH_shrVar1Out;
			shrVar2Out = corH_shrVar2Out;
			norm_lVar1Out = corH_norm_lVar1Out;
			norm_lReady = corH_norm_lReady;
			shlVar1Out = corH_shlVar1Out;
			shlVar2Out = corH_shlVar2Out;
			addOutA = corH_addOutA;
			addOutB = corH_addOutB;
			L_addOutA = corH_L_addOutA;
			L_addOutB = corH_L_addOutB;
			L_add2OutA = corH_L_add2OutA;
			L_add2OutB = corH_L_add2OutB;
			L_add3OutA = corH_L_add3OutA;
			L_add3OutB = corH_L_add3OutB;
			L_add4OutA = corH_L_add4OutA;
			L_add4OutB = corH_L_add4OutB;
			memReadAddr = corH_memReadAddr;
			memWriteAddr = corH_memWriteAddr;
			memOut = corH_memOut;
			memWriteEn = corH_memWriteEn;			
			corH_start = 1;
			if(corH_done == 0)
				nextstate = S5;
			else if(corH_done == 1)
			begin
				corH_start = 0;
				nextstate = S6;
			end
		end//S5
		
		//Cor_h_X(h, x, Dn);
		S6:
		begin				
			L_absOut = Cor_h_X_L_absOut;
			L_macOutA = Cor_h_X_L_macOutA;
			L_macOutB = Cor_h_X_L_macOutB;
			L_macOutC = Cor_h_X_L_macOutC;
			L_subOutA = Cor_h_X_L_subOutA;
			L_subOutB = Cor_h_X_L_subOutB;
			addOutA = Cor_h_X_addOutA;
			addOutB = Cor_h_X_addOutB;
			norm_lVar1Out = Cor_h_X_norm_lVar1Out;
			norm_lReady = Cor_h_X_norm_lReady;
			subOutA = Cor_h_X_subOutA;
			subOutB = Cor_h_X_subOutB;
			L_shrVar1Out = Cor_h_X_L_shrVar1Out;
			L_shrNumShiftOut = Cor_h_X_L_shrNumShiftOut;
			memReadAddr = Cor_h_X_memReadAddr;
			memWriteAddr = Cor_h_X_memWriteAddr;
			memOut = Cor_h_X_memOut;
			memWriteEn = Cor_h_X_memWriteEn;
			Cor_h_X_start = 1;
			if(Cor_h_X_done == 0)
				nextstate = S6;
			else if(Cor_h_X_done == 1)
				nextstate = S7;
		end//S6
		
		//index = D4i40_17(Dn, rr, h, code, y, sign, i_subfr);
		S7:
		begin		
			addOutA = D4i40_17_addOutA;
			addOutB = D4i40_17_addOutB;
			L_addOutA = D4i40_17_L_addOutA;
			L_addOutB = D4i40_17_L_addOutB;
			L_negateOut = D4i40_17_L_negateOut;
			subOutA = D4i40_17_subOutA;
			subOutB = D4i40_17_subOutB;
			L_macOutA = D4i40_17_L_macOutA;
			L_macOutB = D4i40_17_L_macOutB;
			L_macOutC = D4i40_17_L_macOutC;
			L_shrVar1Out = D4i40_17_L_shrVar1Out;
			L_shrNumShiftOut = D4i40_17_L_shrNumShiftOut;
			multOutA = D4i40_17_multOutA;
			multOutB = D4i40_17_multOutB;
			L_multOutA = D4i40_17_L_multOutA;
			L_multOutB = D4i40_17_L_multOutB;
			L_msuOutA = D4i40_17_L_msuOutA;
			L_msuOutB = D4i40_17_L_msuOutB;
			L_msuOutC = D4i40_17_L_msuOutC;
			L_subOutA = D4i40_17_L_subOutA;
			L_subOutB = D4i40_17_L_subOutB;
			shrVar1Out = D4i40_17_shrVar1Out;
			shrVar2Out = D4i40_17_shrVar2Out;
			shlVar1Out = D4i40_17_shlVar1Out;
			shlVar2Out = D4i40_17_shlVar2Out;
			memReadAddr = D4i40_17_memReadAddr;
			memWriteAddr = D4i40_17_memWriteAddr;
			memWriteEn = D4i40_17_memWriteEn;
			memOut = D4i40_17_memOut;
			D4i40_17_start = 1;
			if(D4i40_17_done == 0)
				nextstate = S7;
			else if(D4i40_17_done == 1)
			begin				
				D4i40_17_start = 0;
				nextindex = D4i40_17_i;
				indexLD = 1;
				nextstate = S8;
			end		
		end//S7
		
		//if(sub(T0 ,L_SUBFR) <0)
		S8:
		begin
			subOutA = T0Reg;
			subOutB = 16'd40;
			if(subIn[15] == 1)
			begin
				nexti = T0Reg;
				iLD = 1;
				nextstate = S9;
			end
			else if (subIn[15] == 0)				
				nextstate = S12;
		end//S8
		
		//for (i = T0; i < L_SUBFR; i++) 
		S9:
		begin
			if(i >= 40)			
				nextstate = S12;				
			else if(i<40)
			begin
				subOutA = i;
				subOutB = T0Reg;
				memReadAddr = {CODE[11:6],subIn[5:0]};
				nextstate = S10;
			end
		end//S9
		
		//mult(code[i-T0], sharp)
		S10:
		begin
			multOutA = memIn[15:0];
			multOutB = sharp;
			nexttemp = multIn;
			tempLD = 1;
			memReadAddr = {CODE[11:6],i[5:0]};
			nextstate = S11;
		end//S10
		
		//code[i] = add(code[i], mult(code[i-T0], sharp));
		S11:
		begin
			addOutA = memIn[15:0];
			addOutB = temp[15:0];
			if (addIn[15] == 1)
				memOut = {16'hffff, addIn};
			else
				memOut = {16'h0000, addIn};
			memWriteAddr = {CODE[11:6],i[5:0]};
			memWriteEn = 1;
			L_addOutA = i;
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			nextstate = S9;
		end//S11

		S12:
		begin
			memReadAddr = TOP_LEVEL_I;
			nextstate = S13;
		end
		
		S13:
		begin
			i_out = memIn;
			done = 1;
			nextstate = INIT;
		end//S12
	endcase
end//always
endmodule
