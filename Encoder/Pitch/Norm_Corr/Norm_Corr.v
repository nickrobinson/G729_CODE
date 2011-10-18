`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    11:14:08 04/12/2011
// Module Name:    Norm_Corr.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "Norm_Corr".
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Norm_Corr(clk,start,reset,excAddr,t_min,t_max,addIn,L_addIn,L_macIn,L_msuIn,L_multIn,
					  L_negateIn,L_shlIn,L_shlDone,L_shrIn,L_subIn,multIn,norm_lIn,norm_lDone,shrIn,
					  subIn,constantMemIn,memIn,addOutA,addOutB,L_addOutA,L_addOutB,L_negateOut,
					  L_macOutA,L_macOutB,L_macOutC,L_msuOutA,L_msuOutB,L_msuOutC,L_multOutA,L_multOutB,
					  L_shlVar1Out,L_shlNumShiftOut,L_shlReady,L_shrVar1Out,L_shrNumShiftOut,
					  L_subOutA,L_subOutB,multOutA,multOutB,norm_lVar1Out,norm_lReady,shrVar1Out,
					  shrVar2Out, subOutA,subOutB,constantMemAddr,memWriteEn,memReadAddr,memWriteAddr,
					  memOut,done);
`include "paramList.v"
//Inputs
input clk,start,reset;
input [11:0] excAddr;
input [15:0] t_min;
input [15:0] t_max;
input [15:0] addIn;
input [31:0] L_addIn;
input [31:0] L_macIn;
input [31:0] L_msuIn;
input [31:0] L_multIn;
input [31:0] L_negateIn;
input [31:0] L_shlIn;
input L_shlDone;
input [31:0] L_shrIn;
input [31:0] L_subIn;
input [15:0] multIn;
input [15:0] norm_lIn;
input norm_lDone;
input [15:0] shrIn;
input [15:0] subIn;
input [31:0] constantMemIn;
input [31:0] memIn;

//Outputs
output reg [15:0] addOutA,addOutB;
output reg [31:0] L_addOutA,L_addOutB;
output reg [31:0] L_negateOut;
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;
output reg [15:0] L_msuOutA,L_msuOutB;
output reg [31:0] L_msuOutC;
output reg [15:0] L_multOutA,L_multOutB;
output reg [31:0] L_shlVar1Out; 
output reg [15:0] L_shlNumShiftOut;
output reg L_shlReady;
output reg [31:0] L_shrVar1Out;
output reg [15:0] L_shrNumShiftOut;
output reg [31:0] L_subOutA,L_subOutB;
output reg [15:0] multOutA,multOutB;
output reg [31:0] norm_lVar1Out;
output reg norm_lReady;
output reg [15:0] shrVar1Out,shrVar2Out;
output reg [15:0] subOutA,subOutB;
output reg [11:0] constantMemAddr;
output reg memWriteEn;
output reg [11:0] memReadAddr,memWriteAddr;
output reg [31:0] memOut;
output reg done;

//Inv_sqrt wires
reg Inv_sqrtStart;
reg [31:0] Inv_sqrt_in;
wire [31:0] Inv_sqrt_norm_lVar1Out;
wire Inv_sqrt_norm_lReady;
wire [31:0] Inv_sqrt_L_shlVar1Out; 
wire [15:0] Inv_sqrt_L_shlNumShiftOut;
wire Inv_sqrt_L_shlReady;
wire [15:0] Inv_sqrt_subOutA,Inv_sqrt_subOutB;
wire [31:0] Inv_sqrt_L_shrVar1Out;
wire [15:0] Inv_sqrt_L_shrNumShiftOut;
wire [15:0] Inv_sqrt_shrVar1Out,Inv_sqrt_shrVar2Out;
wire [15:0] Inv_sqrt_addOutA,Inv_sqrt_addOutB;
wire [15:0] Inv_sqrt_L_msuOutA,Inv_sqrt_L_msuOutB;
wire [31:0] Inv_sqrt_L_msuOutC;
wire [11:0] Inv_sqrt_constantMemAddr;
wire Inv_sqrt_done;
wire [31:0] Inv_sqrt_out;

//Convolve wires
reg Convolve_start;
reg [11:0] Convolve_xAddr; 
reg [11:0] Convolve_hAddr;
reg [11:0] Convolve_yAddr;
wire Convolve_memWriteEn;
wire [11:0]  Convolve_memWriteAddr;
wire [31:0] Convolve_memOut;
wire Convolve_L_shlReady;
wire Convolve_done;
wire [15:0] Convolve_L_macOutA,Convolve_L_macOutB;
wire [31:0] Convolve_L_addOutA,Convolve_L_addOutB;
wire [15:0] Convolve_addOutA,Convolve_addOutB;
wire [31:0] Convolve_L_subOutA,Convolve_L_subOutB;
wire [31:0] Convolve_L_macOutC;
wire [31:0] Convolve_L_shlVar1Out;
wire [15:0] Convolve_L_shlNumShiftOut;

//Mpy_32 wires
reg Mpy_32Start;
reg [31:0] Mpy_32_var1,Mpy_32_var2;
wire [15:0] Mpy_32_L_multOutA, Mpy_32_L_multOutB;
wire [15:0] Mpy_32_L_macOutA, Mpy_32_L_macOutB;
wire [15:0] Mpy_32_multOutA, Mpy_32_multOutB;
wire [31:0] Mpy_32_L_macOutC, Mpy_32_Out;
wire Mpy_32_done;

//internal regs
reg [5:0] state,nextstate;
reg [15:0] i,nexti;
reg iLD,iReset;
reg [15:0] j,nextj;
reg jLD,jReset;
reg [15:0] k,nextk;
reg kLD,kReset;
reg [15:0] corr_h,nextcorr_h;
reg corr_hLD,corr_hReset;
reg [15:0] corr_l,nextcorr_l;
reg corr_lLD,corr_lReset;
reg [15:0] norm_h,nextnorm_h;
reg norm_hLD,norm_hReset;
reg [15:0] norm_l,nextnorm_l;
reg norm_lLD,norm_lReset;
reg [15:0] scaling,nextscaling;
reg scalingLD,scalingReset;
reg [15:0] h_fac,nexth_fac;
reg h_facLD,h_facReset;
reg [11:0] s_excf,nexts_excf;
reg s_excfLD,s_excfReset;
reg [31:0] s,nexts;
reg sLD,sReset;
reg [31:0] L_temp,nextL_temp;
reg L_tempLD,L_tempReset;
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
parameter S33 = 6'd33;
parameter S34 = 6'd34;
parameter S35 = 6'd35;
parameter S36 = 6'd36;
parameter S37 = 6'd37;
parameter S38 = 6'd38;
parameter S39 = 6'd39;

//Flip flops
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
		j <= 0;
	else if(jReset)
		j <= 0;
	else if(jLD)
		j <= nextj;
end

always @(posedge clk)
begin
	if(reset)
		k <= 0;
	else if(kReset)
		k <= 0;
	else if(kLD)
		k <= nextk;
end

always @(posedge clk)
begin
	if(reset)
		corr_h <= 0;
	else if(corr_hReset)
		corr_h <= 0;
	else if(corr_hLD)
		corr_h <= nextcorr_h;
end

always @(posedge clk)
begin
	if(reset)
		corr_l <= 0;
	else if(corr_lReset)
		corr_l <= 0;
	else if(corr_lLD)
		corr_l <= nextcorr_l;
end

always @(posedge clk)
begin
	if(reset)
		norm_h <= 0;
	else if(norm_hReset)
		norm_h <= 0;
	else if(norm_hLD)
		norm_h <= nextnorm_h;
end


always @(posedge clk)
begin
	if(reset)
		norm_l <= 0;
	else if(norm_lReset)
		norm_l <= 0;
	else if(norm_lLD)
		norm_l <= nextnorm_l;
end

always @(posedge clk)
begin
	if(reset)
		scaling <= 0;
	else if(scalingReset)
		scaling <= 0;
	else if(scalingLD)
		scaling <= nextscaling;
end

always @(posedge clk)
begin
	if(reset)
		h_fac <= 0;
	else if(h_facReset)
		h_fac <= 0;
	else if(h_facLD)
		h_fac <= nexth_fac;
end

always @(posedge clk)
begin
	if(reset)
		s_excf <= 0;
	else if(s_excfReset)
		s_excf <= 0;
	else if(s_excfLD)
		s_excf <= nexts_excf;
end

always @(posedge clk)
begin
	if(reset)
		s <= 0;
	else if(sReset)
		s <= 0;
	else if(sLD)
		s <= nexts;
end

always @(posedge clk)
begin
	if(reset)
		L_temp <= 0;
	else if(L_tempReset)
		L_temp <= 0;
	else if(L_tempLD)
		L_temp <= nextL_temp;
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
//Instantiated modules
Inv_sqrt sqareroot(
						 .clk(clk),
						 .start(Inv_sqrtStart),
						 .reset(reset),
						 .in(Inv_sqrt_in),
						 .norm_lIn(norm_lIn),
						 .norm_lDone(norm_lDone),
						 .L_shlIn(L_shlIn),
						 .L_shlDone(L_shlDone),
						 .subIn(subIn),
						 .L_shrIn(L_shrIn),
						 .shrIn(shrIn),
						 .addIn(addIn),
						 .L_msuIn(L_msuIn),
						 .constantMemIn(constantMemIn),
						 .norm_lVar1Out(Inv_sqrt_norm_lVar1Out),
						 .norm_lReady(Inv_sqrt_norm_lReady),
						 .L_shlVar1Out(Inv_sqrt_L_shlVar1Out),
						 .L_shlNumShiftOut(Inv_sqrt_L_shlNumShiftOut),
					    .L_shlReady(Inv_sqrt_L_shlReady),
						 .subOutA(Inv_sqrt_subOutA),
						 .subOutB(Inv_sqrt_subOutB),
						 .L_shrVar1Out(Inv_sqrt_L_shrVar1Out),
						 .L_shrNumShiftOut(Inv_sqrt_L_shrNumShiftOut),
						 .shrVar1Out(Inv_sqrt_shrVar1Out),
						 .shrVar2Out(Inv_sqrt_shrVar2Out),
						 .addOutA(Inv_sqrt_addOutA),
					    .addOutB(Inv_sqrt_addOutB),
						 .L_msuOutA(Inv_sqrt_L_msuOutA),
						 .L_msuOutB(Inv_sqrt_L_msuOutB),
						 .L_msuOutC(Inv_sqrt_L_msuOutC),
						 .constantMemAddr(Inv_sqrt_constantMemAddr),
						 .done(Inv_sqrt_done),
						 .out(Inv_sqrt_out)
						 );
						 
convolve theConvolver(
							  .clk(clk),
							  .reset(reset), 
							  .start(Convolve_start),
							  .memIn(memIn),
							  .memWriteEn(Convolve_memWriteEn),
							  .memWriteAddr(Convolve_memWriteAddr),
							  .memOut(Convolve_memOut),
							  .done(Convolve_done),
							  .L_macIn(L_macIn),
							  .L_macOutA(Convolve_L_macOutA),
							  .L_macOutB(Convolve_L_macOutB),
							  .L_macOutC(Convolve_L_macOutC),
							  .L_shlIn(L_shlIn),
							  .L_shlOutVar1(Convolve_L_shlVar1Out),
						     .L_shlReady(Convolve_L_shlReady),
							  .L_shlDone(L_shlDone),
							  .L_shlNumShiftOut(Convolve_L_shlNumShiftOut),
							  .xAddr(Convolve_xAddr), 
							  .hAddr(Convolve_hAddr), 
							  .yAddr(Convolve_yAddr), 
							  .L_subOutA(Convolve_L_subOutA),
						     .L_subOutB(Convolve_L_subOutB),
							  .L_subIn(L_subIn),
							  .L_addOutA(Convolve_L_addOutA), 
							  .L_addOutB(Convolve_L_addOutB),
							  .L_addIn(L_addIn),
							  .addOutA(Convolve_addOutA),
							  .addOutB(Convolve_addOutB),
							  .addIn(addIn)
							  );
							  
Mpy_32 theMpy_32(
					 .clock(clk),
					 .reset(reset),
					 .start(Mpy_32Start),
					 .done(Mpy_32_done),
					 .var1(Mpy_32_var1), 
					 .var2(Mpy_32_var2), 
					 .out(Mpy_32_Out),
					 .L_mult_outa(Mpy_32_L_multOutA),
					 .L_mult_outb(Mpy_32_L_multOutB),
					 .L_mult_overflow(1'd0),
					 .L_mult_in(L_multIn),
					 .L_mac_outa(Mpy_32_L_macOutA),
					 .L_mac_outb(Mpy_32_L_macOutB),
					 .L_mac_outc(Mpy_32_L_macOutC), 
					 .L_mac_overflow(1'd0),
					 .L_mac_in(L_macIn),
					 .mult_outa(Mpy_32_multOutA),
					 .mult_outb(Mpy_32_multOutB),
					 .mult_in(multIn), 
					 .mult_overflow(1'd0)
					 );
//State machine always block
always @(*)
begin
	addOutA = 0;
	addOutB = 0;
   L_addOutA = 0;
	L_addOutB = 0;
	L_negateOut = 0;
   L_macOutA = 0;
	L_macOutB = 0;
   L_macOutC = 0;
   L_msuOutA = 0;
	L_msuOutB = 0;
   L_msuOutC = 0;
   L_shlVar1Out = 0; 
   L_shlNumShiftOut = 0;
	L_shlReady = 0;
   L_shrVar1Out = 0;
   L_shrNumShiftOut = 0;
	L_shlReady = 0;
   L_subOutA = 0;
	L_subOutB = 0;
	L_multOutA = 0;
	L_multOutB = 0;
   multOutA = 0;
	multOutB = 0;
   norm_lVar1Out = 0;
	norm_lReady = 0;
   shrVar1Out = 0;
	shrVar2Out = 0;
   subOutA = 0;
	subOutB = 0;
   constantMemAddr = 0;
	memWriteEn = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
   memOut = 0;
	done = 0;
	nextstate = state;
	nexti = i;
	nextj = j;
	nextk = k;
	nextcorr_h = corr_h;
	nextcorr_l = corr_l;
	nextnorm_h = norm_h;
	nextnorm_l = norm_l;
	nextscaling = scaling;
	nexth_fac = h_fac;
	nexts_excf = s_excf;
	nexts = s;
	nextL_temp = L_temp;
	nexttemp = temp;
	iReset = 0;
	jReset = 0;
	kReset = 0;
	corr_hReset = 0;
	corr_hReset = 0;
	corr_lReset = 0;
	norm_hReset = 0;
	norm_lReset = 0;
	scalingReset = 0;
	h_facReset = 0;
	s_excfReset = 0;
	sReset = 0;
	L_tempReset = 0;
	tempReset = 0;
	iLD = 0;
	jLD = 0;
	kLD = 0;
	corr_hLD = 0;
	corr_lLD = 0;
	norm_hLD = 0;
	norm_lLD = 0;
	scalingLD = 0;
	h_facLD = 0;
	s_excfLD = 0;
	sLD = 0;
	L_tempLD = 0;
	tempLD = 0;
	Inv_sqrtStart = 0;
	Inv_sqrt_in = 0;
	Convolve_start = 0;
	Convolve_xAddr = 0; 
	Convolve_hAddr = 0;
   Convolve_yAddr = 0;
	Mpy_32Start = 0;
	Mpy_32_var1 = 0;
	Mpy_32_var2 = 0;
	
	case(state)
	
		INIT:
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin
					iReset = 1;
					jReset = 1;
					kReset = 1;
					corr_hReset = 1;
					corr_hReset = 1;
					corr_lReset = 1;
					norm_hReset = 1;
					norm_lReset = 1;
					scalingReset = 1;
					h_facReset = 1;
					s_excfReset = 1;
					sReset = 1;
					L_tempReset = 1;
					tempReset = 1;
					nextstate = S1;
			end
		end//INIT
		
		//k =  negate(t_min);
		S1:
		begin
			L_negateOut = t_min;
			nextk = L_negateIn;
			kLD = 1;
			addOutA = L_negateIn;
			addOutB = excAddr;
			nextL_temp = addIn[15:0];
			L_tempLD = 1;
			nextstate = S2;
		end//S1
		
		//Convolve(&exc[k], h, excf, l_subfr);
		S2:
		begin			
			Convolve_xAddr = L_temp[11:0]; 
			Convolve_hAddr = H1;
			Convolve_yAddr = NORM_CORR_EXCF;
			memWriteEn = Convolve_memWriteEn;
			memReadAddr = Convolve_memWriteAddr;
			memWriteAddr = Convolve_memWriteAddr;
			memOut = Convolve_memOut;
			L_shlReady = Convolve_L_shlReady;
			L_macOutA = Convolve_L_macOutA;
			L_macOutB = Convolve_L_macOutB;
			L_addOutA = Convolve_L_addOutA;
			L_addOutB = Convolve_L_addOutB;
			L_subOutA = Convolve_L_subOutA;
			L_subOutB = Convolve_L_subOutB;
			L_macOutC = Convolve_L_macOutC;
			L_shlVar1Out = Convolve_L_shlVar1Out;
			L_shlNumShiftOut = Convolve_L_shlNumShiftOut;
			addOutA = Convolve_addOutA;
			addOutB = Convolve_addOutB;
			Convolve_start = 1;
			nextstate = S3;
		end//S2
		
		//Convolve(&exc[k], h, excf, l_subfr);
		S3:
		begin
			Convolve_xAddr = L_temp[11:0]; 
			Convolve_hAddr = H1;
			Convolve_yAddr = NORM_CORR_EXCF;
			memWriteEn = Convolve_memWriteEn;
			memReadAddr = Convolve_memWriteAddr;
			memWriteAddr = Convolve_memWriteAddr;
			memOut = Convolve_memOut;
			L_shlReady = Convolve_L_shlReady;
			L_macOutA = Convolve_L_macOutA;
			L_macOutB = Convolve_L_macOutB;
			L_addOutA = Convolve_L_addOutA;
			L_addOutB = Convolve_L_addOutB;
			L_subOutA = Convolve_L_subOutA;
			L_subOutB = Convolve_L_subOutB;
			L_macOutC = Convolve_L_macOutC;
			L_shlVar1Out = Convolve_L_shlVar1Out;
			L_shlNumShiftOut = Convolve_L_shlNumShiftOut;
			addOutA = Convolve_addOutA;
			addOutB = Convolve_addOutB;
			if(Convolve_done == 0)
				nextstate = S3;
			else if(Convolve_done == 1)
			begin
				jReset = 1;
				nextstate = S4;
			end
		end//S3
		
		/* for(j=0; j<l_subfr; j++)
			 */
		S4:
		begin
			if(j>=40)
			begin
				jReset = 1;
				nexts = 0;
				sLD = 1;
				nextstate = S6;
			end
			
			else if(j<40)
			begin
				memReadAddr = {NORM_CORR_EXCF[11:6],j[5:0]};
				nextstate = S5;
			end			
		end//S4
		
		//scaled_excf[j] = shr(excf[j], 2); 
		S5:
		begin
			shrVar1Out = memIn[15:0];
			shrVar2Out = 16'd2;
			memOut = shrIn[15:0];
			memWriteEn = 1;
			memWriteAddr = {NORM_CORR_SCALED_EXCF[11:6],j[5:0]};
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S4;
		end//S5
		
		//for (j = 0; j < l_subfr; j++)
		S6:
		begin
			if(j>=40)
			begin
				jReset = 1;				
				nextstate = S8;
			end
			
			else if(j<40)
			begin
				memReadAddr = {NORM_CORR_EXCF[11:6],j[5:0]};
				nextstate = S7;
			end
		end//S6
		
		//s = L_mac(s, excf[j], excf[j])
		S7:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = memIn[15:0];
			L_macOutC = s;
			nexts = L_macIn;
			sLD = 1;
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S6;
		end//S7
		
		/* L_temp = L_sub(s, 67108864L);
			if (L_temp <= 0L)  {
				s_excf = excf;
				h_fac = 15-12;            
				scaling = 0; } 
				else {
				  s_excf = scaled_excf;        
			     h_fac = 15-12-2;             
				  scaling = 2; }*/
		S8:
		begin
			L_subOutA = s;
			L_subOutB = 32'd67108864;
			nextL_temp = L_subIn;
			L_tempLD = 1;
			if(L_subIn[31] == 1 || L_subIn == 0)
			begin
				nexts_excf = NORM_CORR_EXCF;
				s_excfLD = 1;
				nexth_fac = 16'd3;
				h_facLD = 1;
				scalingReset = 1;
			end
			else
			begin
				nexts_excf = NORM_CORR_SCALED_EXCF;
				s_excfLD = 1;
				nexth_fac = 16'd1;
				h_facLD = 1;
				nextscaling = 2;
				scalingLD = 1;
			end
			nexti = t_min;
			iLD = 1;
			nextstate = S9;
		end//S8
		
		//for (i = t_min; i <= t_max; i++)
		S9:
		begin
			if(i>t_max)
			begin
				nextstate = INIT;
				done = 1;
			end
			else if(i<=t_max)
			begin
				subOutA = i;
				subOutB = t_min;
				nexttemp = subIn;
				tempLD = 1;
				sReset = 1;
				jReset = 1;
				nextstate = S10;
			end
		end//S9
		
		//for (j = 0; j < l_subfr; j++)
		S10:
		begin
			if(j>=40)
				nextstate = S12;
			else if(j<40)
			begin
				memReadAddr = {s_excf[11:6],j[5:0]};
				nextstate = S11;
			end
		end//S10
		
		//s = L_mac(s, s_excf[j], s_excf[j]);
		S11:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = memIn[15:0];
			L_macOutC = s;
			nexts = L_macIn;
			sLD = 1;
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S10;
		end//S11
		
		//s = Inv_sqrt(s);
		S12:
		begin
			Inv_sqrt_in = s;
			norm_lVar1Out = Inv_sqrt_norm_lVar1Out;
			norm_lReady = Inv_sqrt_norm_lReady;
			L_shlVar1Out = Inv_sqrt_L_shlVar1Out; 
			L_shlNumShiftOut = Inv_sqrt_L_shlNumShiftOut;
			L_shlReady = Inv_sqrt_L_shlReady;
			subOutA = Inv_sqrt_subOutA;
			subOutB = Inv_sqrt_subOutB;
			L_shrVar1Out = Inv_sqrt_L_shrVar1Out;
			L_shrNumShiftOut = Inv_sqrt_L_shrNumShiftOut;
			shrVar1Out = Inv_sqrt_shrVar1Out;
			shrVar2Out = Inv_sqrt_shrVar2Out;
			addOutA = Inv_sqrt_addOutA;
			addOutB = Inv_sqrt_addOutB;
			L_msuOutA = Inv_sqrt_L_msuOutA;
			L_msuOutB = Inv_sqrt_L_msuOutB;
			L_msuOutC = Inv_sqrt_L_msuOutC;
			constantMemAddr = Inv_sqrt_constantMemAddr;
			Inv_sqrtStart = 1;
			nextstate = S13;
		end//S12
		
		//s = Inv_sqrt(s);
		S13:
		begin
			Inv_sqrt_in = s;
			norm_lVar1Out = Inv_sqrt_norm_lVar1Out;
			norm_lReady = Inv_sqrt_norm_lReady;
			L_shlVar1Out = Inv_sqrt_L_shlVar1Out; 
			L_shlNumShiftOut = Inv_sqrt_L_shlNumShiftOut;
			L_shlReady = Inv_sqrt_L_shlReady;
			subOutA = Inv_sqrt_subOutA;
			subOutB = Inv_sqrt_subOutB;
			L_shrVar1Out = Inv_sqrt_L_shrVar1Out;
			L_shrNumShiftOut = Inv_sqrt_L_shrNumShiftOut;
			shrVar1Out = Inv_sqrt_shrVar1Out;
			shrVar2Out = Inv_sqrt_shrVar2Out;
			addOutA = Inv_sqrt_addOutA;
			addOutB = Inv_sqrt_addOutB;
			L_msuOutA = Inv_sqrt_L_msuOutA;
			L_msuOutB = Inv_sqrt_L_msuOutB;
			L_msuOutC = Inv_sqrt_L_msuOutC;
			constantMemAddr = Inv_sqrt_constantMemAddr;
			if(Inv_sqrt_done == 0)
				nextstate = S13;
			else if(Inv_sqrt_done == 1)
			begin
				nexts = Inv_sqrt_out;
				sLD = 1;
				nextstate = S14;
			end
		end//S13
		
		// L_Extract(s, &norm_h, &norm_l);
		S14:
		begin
			L_shrVar1Out = s;
			L_shrNumShiftOut = 32'd1;
			nextL_temp = L_shrIn;
			L_tempLD = 1;
			nextstate = S15;
		end//S14
		
		// L_Extract(s, &norm_h, &norm_l);
		S15:
		begin
			L_msuOutA = s[31:16];
			L_msuOutB = 16'd16384;
			L_msuOutC = L_temp;
			nextnorm_h = s[31:16];
			norm_hLD = 1;
			nextnorm_l = L_msuIn[15:0];
			norm_lLD = 1;
			nexts = 0;
			sLD = 1;
			jReset = 1;
			nextstate = S16;
		end//S15
		
		//for (j = 0; j < l_subfr; j++)
		S16:
		begin
			if(j>=40)
				nextstate = S19;
			else if(j<40)
			begin
				memReadAddr = {s_excf[11:6],j[5:0]};
				nextstate = S17;
			end
		end//S16
		
		S17:
		begin
			nextL_temp = memIn[15:0];
			L_tempLD = 1;
			memReadAddr = {XN[11:6],j[5:0]};
			nextstate = S18;
		end//S17
		
		//s = L_mac(s, xn[j], s_excf[j]);
		S18:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = L_temp[15:0];
			L_macOutC = s;
			nexts = L_macIn;
			sLD = 1;
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S16;
		end//S18
		
		//L_Extract(s, &corr_h, &corr_l);
		S19:
		begin
			L_shrVar1Out = s;
			L_shrNumShiftOut = 32'd1;
			nextL_temp = L_shrIn;
			L_tempLD = 1;
			nextstate = S20;
		end//S19
		
		//L_Extract(s, &corr_h, &corr_l);
		S20:
		begin
			L_msuOutA = s[31:16];
			L_msuOutB = 16'd16384;
			L_msuOutC = L_temp;
			nextcorr_h = s[31:16];
			corr_hLD = 1;
			nextcorr_l = L_msuIn[15:0];
			corr_lLD = 1;			
			nextstate = S21;
		end//S20
		
		//s = Mpy_32(corr_h, corr_l, norm_h, norm_l);
		S21:
		begin
			Mpy_32_var1 = {corr_h[15:0],corr_l[15:0]};
			Mpy_32_var2 = {norm_h[15:0],norm_l};
			L_multOutA = Mpy_32_L_multOutA;
			L_multOutB = Mpy_32_L_multOutB;
			L_macOutA = Mpy_32_L_macOutA;
			L_macOutB = Mpy_32_L_macOutB;
			multOutA = Mpy_32_multOutA;
			multOutB = Mpy_32_multOutB;
			L_macOutC = Mpy_32_L_macOutC;
			Mpy_32Start = 1;
			nextstate = S22;
		end//S21
		
		//s = Mpy_32(corr_h, corr_l, norm_h, norm_l);
		S22:
		begin
			Mpy_32_var1 = {corr_h[15:0],corr_l[15:0]};
			Mpy_32_var2 = {norm_h[15:0],norm_l};
			L_multOutA = Mpy_32_L_multOutA;
			L_multOutB = Mpy_32_L_multOutB;
			L_macOutA = Mpy_32_L_macOutA;
			L_macOutB = Mpy_32_L_macOutB;
			multOutA = Mpy_32_multOutA;
			multOutB = Mpy_32_multOutB;
			L_macOutC = Mpy_32_L_macOutC;
			if(Mpy_32_done == 0)
				nextstate = S22;
			else if(Mpy_32_done == 1)
			begin
				nexts = Mpy_32_Out;
				sLD = 1;
				nextstate = S23;
			end
		end//S22
		
		//L_shl(s, 16)
		S23:
		begin
			L_shlVar1Out = s;
			L_shlNumShiftOut = 16'd16;
			L_shlReady = 1;
			nextstate = S24;
		end//S23
		
		// corr_norm[i] = extract_h(L_shl(s, 16));
		S24:
		begin
			L_shlVar1Out = s;
			L_shlNumShiftOut = 16'd16;
			if(L_shlDone == 0)
				nextstate =S24;
			else if(L_shlDone == 1)
			begin
				if(L_shlIn[31] == 1)
					memOut = {16'hFFFF,L_shlIn[31:16]};
				if(L_shlIn[31] == 0)
					memOut = {16'h0,L_shlIn[31:16]};
				memWriteEn = 1;
				addOutA = PITCH_FR3_CORR_V;
				addOutB = temp;
				memWriteAddr =	addIn;
				nextstate = S25;
			end
		end//S24
		
		/* if( sub(i, t_max) != 0)
			  k=sub(k,1); */
		S25:
		begin
			subOutA = i;
			subOutB = t_max;
			if(subIn != 0)
			begin
				L_subOutA = {16'd0,k[15:0]};
				L_subOutB = 32'd1;
				nextk = L_subIn[15:0];
				kLD = 1;
				jReset = 1;
				nextstate = S26;
			end
			else
			begin
				addOutA = i;
				addOutB = 16'd1;
				nexti = addIn;
				iLD = 1;
				nextstate = S9;
			end
		end//S25
		
		S26:
		begin			
			nextj = 16'd39;
			jLD = 1;
			nextstate = S27;
		end//S26
		
		// for (j = l_subfr-(Word16)1; j > 0; j--)
		S27:
		begin
			if(j[15] == 1 || j == 0)	
			begin
				addOutA = excAddr;
				addOutB = k;
				memReadAddr = addIn;
				nextstate = S33;
			end
			else if(j[15] == 0 && j != 0)
			begin
				addOutA = H1;
				addOutB = j;
				memReadAddr = addIn[11:0];
				nextstate = S28;
			end
		end//S27
		
		S28:
		begin
			nextL_temp = memIn[15:0];
			L_tempLD = 1;
			addOutA = excAddr;
			addOutB = k;
			memReadAddr = addIn[11:0];
			nextstate = S29;
		end//S28
		
		//s = L_mult(exc[k], h[j]);
		S29:
		begin
			L_multOutA = memIn[15:0];
			L_multOutB = L_temp;
			nexts = L_multIn;
			sLD = 1;
			nextstate = S30;
		end//S29
		
		//s = L_shl(s, h_fac);   
		S30:
		begin
			L_shlVar1Out = s;
			L_shlNumShiftOut = h_fac;
			L_shlReady = 1;
			nextstate = S31;
		end//S30
		
		//s = L_shl(s, h_fac); 
		S31:
		begin
			L_shlVar1Out = s;
			L_shlNumShiftOut = h_fac;
			if(L_shlDone == 0)
				nextstate = S31;
			else if(L_shlDone == 1)
			begin
				nexts = L_shlIn;
				sLD = 1;
				subOutA = j;
				subOutB = 16'd1;
				addOutA = s_excf;
				addOutB = subIn;
				memReadAddr = addIn;
				nextstate = S32;
			end
		end//S31
		
		// s_excf[j] = add(extract_h(s), s_excf[j-1]);
		S32:
		begin
			addOutA = s[31:16];
			addOutB = memIn[15:0];
			memOut = addIn;
			memWriteEn = 1;
			L_addOutA = s_excf;
			L_addOutB = j;
			memWriteAddr = L_addIn;
			subOutA = j;
			subOutB = 16'd1;
			nextj = subIn;
			jLD = 1;
			nextstate = S27;
		end//S32
		
		//s_excf[0] = shr(exc[k], scaling);
		S33:
		begin
			shrVar1Out = memIn[15:0];
			shrVar2Out = scaling;
			memOut = shrIn;
			memWriteEn = 1;
			memWriteAddr = s_excf;
			addOutA = i;
			addOutB = 16'd1;
			nexti = addIn;
			iLD = 1;
			nextstate = S9;
		end//S33
	endcase
	
end//always


endmodule
