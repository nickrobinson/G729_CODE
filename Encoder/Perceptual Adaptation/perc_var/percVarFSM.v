`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    13:08:31 01/11/2011 
// Module Name:    percVarFSM 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function to compute the bandwidth expansion parameters by executing 
//						the Perceptual Adaptation module of the encoder. It is modeled after the perc_var function
//						found in the pwf.c file of the C-model 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module percVarFSM(clk,reset,start,shlIn,shrIn,subIn,L_multIn,L_subIn,L_shrIn,L_addIn,addIn,multIn,memIn,
						shlVar1Out,shlVar2Out,shrVar1Out,shrVar2Out,subOutA,subOutB,L_multOutA,L_multOutB,
						L_subOutA,L_subOutB,L_shrOutVar1,L_shrOutNumShift,L_addOutA,L_addOutB,addOutA,addOutB,
						multOutA,multOutB,memReadAddr,memWriteAddr,memWrite,memOut,done);
`include "paramList.v"

//Inputs
input clk,reset,start;
input [15:0] shlIn;
input [15:0] shrIn;
input [15:0] subIn;
input [31:0] L_multIn;
input [31:0] L_subIn;
input [31:0] L_shrIn;
input [31:0] L_addIn;
input [15:0] addIn;
input [15:0] multIn;
input [31:0] memIn;

//Outputs
output reg [15:0] shlVar1Out;
output reg [15:0] shlVar2Out;
output reg [15:0] shrVar1Out;
output reg [15:0] shrVar2Out;
output reg [15:0] subOutA;
output reg [15:0] subOutB;
output reg [15:0] L_multOutA;
output reg [15:0] L_multOutB;
output reg [31:0] L_subOutA;
output reg [31:0] L_subOutB;
output reg [31:0] L_shrOutVar1;
output reg [15:0] L_shrOutNumShift;
output reg [31:0] L_addOutA;
output reg [31:0] L_addOutB;
output reg [15:0] addOutA;
output reg [15:0] addOutB;
output reg [15:0] multOutA;
output reg [15:0] multOutB;
output reg [11:0] memReadAddr;
output reg [11:0] memWriteAddr;
output reg memWrite;
output reg [31:0] memOut;
output reg done;

//regs for registers
reg [5:0] state,nextstate;
reg [11:0] Lsf,nextLsf;
reg LsfReset,LsfLD;
reg [15:0] cur_rc,nextcur_rc;
reg cur_rcReset,cur_rcLD;
reg [15:0] critLar0,nextcritLar0;
reg critLar0Reset,critLar0LD;
reg [15:0] critLar1,nextcritLar1;
reg critLar1Reset,critLar1LD;
reg [15:0] temp,nexttemp;
reg tempReset,tempLD;
reg [15:0] d_min,nextd_min;
reg d_minReset,d_minLD;
reg [4:0] i,nexti;
reg iReset,iLD;
reg [4:0] k,nextk;
reg kReset,kLD;
reg [15:0] smooth,nextsmooth;
reg smoothReset,smoothLD;
//LarNew,LSF

parameter SEG1 = 32'd1299;
parameter SEG2 = 32'd1815;
parameter SEG3 = 32'd1944;
parameter A1 = 32'd4567;
parameter A2 = 32'd11776;
parameter A3 = 32'd27443;
parameter L_B1 = 32'd3271557;
parameter L_B2 = 32'd16357786;
parameter L_B3 = 32'd46808433;
parameter THRESH_L1 = -32'd3562;
parameter THRESH_L2 = -32'd3116;
parameter THRESH_H1 = 32'd1336;
parameter THRESH_H2 = 32'd890;
parameter GAMMA1_0 = 32'd32113;
parameter GAMMA1_1 = 32'd30802;
parameter GAMMA2_0_H = 32'd22938;
parameter GAMMA2_0_L = 32'd13107;
parameter GAMMA2_1 = 32'd19661;
parameter ALPHA = 32'd19302;
parameter BETA = 32'd1024;

//STATE parameters
parameter INIT = 6'd0;
parameter FOR_LOOP1 = 6'd1;
parameter FOR_LOOP1_MEM_WAIT1 = 6'd2;
parameter FOR_LOOP1_BODY1 = 6'd3;
parameter FOR_LOOP1_MEM_WAIT2 = 6'd4;
parameter FOR_LOOP2 = 6'd5;
parameter FOR_LOOP2_MEM_WAIT1 = 56'd6;
parameter FOR_LOOP2_BODY1 = 6'd7;
parameter FOR_LOOP2_BODY2 = 6'd8;
parameter FOR_LOOP2_BODY3 = 6'd9;
parameter FOR_LOOP2_BODY4 = 6'd10;
parameter FOR_LOOP2_BODY5 = 6'd11;
parameter FOR_LOOP2_BODY5_MEM_WAIT1 = 6'd12;
parameter FOR_LOOP2_BODY5_MEM_WAIT2 = 6'd13;
parameter LAR_INTERPOL1 = 6'd14;
parameter LAR_INTERPOL1_MEM_WAIT1 = 6'd15;
parameter LAR_INTERPOL1_MEM_WAIT2 = 6'd16;
parameter LAR_INTERPOL1_MEM_WAIT3 = 6'd17;
parameter LAR_INTERPOL2 = 6'd18;
parameter LAR_INTERPOL2_MEM_WAIT1 = 6'd19;
parameter LAR_INTERPOL2_MEM_WAIT2 = 6'd20;
parameter LAR_INTERPOL2_MEM_WAIT3 = 6'd21;
parameter FOR_LOOP3 = 6'd22;
parameter FOR_LOOP3_MEM_WAIT1 = 6'd23;
parameter FOR_LOOP3_BODY1 = 6'd24;
parameter FOR_LOOP3_BODY2 = 6'd25;
parameter FOR_LOOP3_BODY3 = 6'd26;
parameter FOR_LOOP3_BODY3_MEM_WAIT1 = 6'd27;
parameter FOR_LOOP3_BODY3_MEM_WAIT1_5 = 6'd28;
parameter FOR_LOOP3_BODY3_MEM_WAIT2 = 6'd29;
parameter FOR_LOOP4 = 6'd30; 
parameter FOR_LOOP4_MEM_WAIT1 = 6'd31;
parameter FOR_LOOP4_MEM_WAIT2 = 6'd32;
parameter FOR_LOOP3_BODY4 = 6'd33;
parameter FOR_LOOP3_BODY5 = 6'd34;
parameter FOR_LOOP3_BODY6 = 6'd35;
parameter GAMMA_SET1 = 6'd36;
parameter GAMMA_SET2 = 6'd37;

//always blocks for working registers

//state register
always @(posedge clk)
begin
	if(reset)
		state <= INIT;
	else
		state <= nextstate;
end

//L_temp register
always @(posedge clk)
begin
	if(reset)
		Lsf <= 0;
	else if(LsfReset)
		Lsf <= 0;
	else if(LsfLD)
		Lsf <= nextLsf;
end

//cur_rc register
always @(posedge clk)
begin
	if(reset)
		cur_rc <= 0;
	else if(cur_rcReset)
		cur_rc <= 0;
	else if(cur_rcLD)
		cur_rc <= nextcur_rc;
end

//critLar0 register
always @(posedge clk)
begin
	if(reset)
		critLar0 <= 0;
	else if(critLar0Reset)
		critLar0 <= 0;
	else if(critLar0LD)
		critLar0 <= nextcritLar0;
end

//critLar1 register
always @(posedge clk)
begin
	if(reset)
		critLar1 <= 0;
	else if(critLar1Reset)
		critLar1 <= 0;
	else if(critLar1LD)
		critLar1 <= nextcritLar1;
end

//temp register
always @(posedge clk)
begin
	if(reset)
		temp <= 0;
	else if(tempReset)
		temp <= 0;
	else if(tempLD)
		temp <= nexttemp;
end

//d_min register
always @(posedge clk)
begin
	if(reset)
		d_min <= 0;
	else if(d_minReset)
		d_min <= 0;
	else if(d_minLD)
		d_min <= nextd_min;
end

//i register
always @(posedge clk)
begin
	if(reset)
		i <= 0;
	else if(iReset)
		i <= 0;
	else if(iLD)
		i <= nexti;
end

//k register
always @(posedge clk)
begin
	if(reset)
		k <= 0;
	else if(kReset)
		k <= 0;
	else if(kLD)
		k <= nextk;
end

//smooth register
always @(posedge clk)
begin
	if(reset)
		smooth <= 0;
	else if(smoothReset)
		smooth <= 1;
	else if(smoothLD)
		smooth <= nextsmooth;
end

//FSM always block
always @(*)
begin
	nextstate = state;
	nextLsf = Lsf;
	nextcur_rc = cur_rc;
	nextcritLar0 = critLar0;
	nextcritLar1 = critLar1;
	nexttemp = temp;
	nextd_min = d_min;
	nexti = i;
	nextk = k;
	nextsmooth = smooth;
	LsfReset = 0;
	LsfLD = 0;
	cur_rcReset = 0;
	cur_rcLD = 0;
	critLar0Reset = 0;
	critLar0LD = 0;
	critLar1Reset = 0;
	critLar1LD = 0;
	tempReset = 0;
	tempLD = 0;
	d_minReset = 0;
	d_minLD = 0;	
	iReset = 0;
	iLD = 0;
	kReset = 0;
	kLD = 0;
   smoothReset = 0;
	smoothLD = 0;
	memWrite = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
	memOut = 0;
	done = 0;
	shlVar1Out = 0;
	shlVar2Out = 0;
	addOutA = 0;
	addOutB = 0;
	subOutA = 0;
	subOutB = 0;
	shrVar1Out = 0;
	shrVar2Out = 0;
	L_multOutA = 0;
	L_multOutB = 0;
	L_subOutA = 0;
	L_subOutB = 0;
	L_shrOutVar1 = 0;
	L_shrOutNumShift = 0;
	L_addOutA = 0;
	L_addOutB = 0;
	multOutA = 0;
	multOutB = 0;
	
	case(state)
	
		INIT:			//state0
		begin
			LsfReset = 1;
			cur_rcReset = 1;			
			critLar0Reset = 1;
			critLar1Reset = 1;
			tempReset = 1;
			d_minReset = 1;
			iReset = 1;
			kReset = 1;	
			smoothReset = 1;
			if(start != 1)
				nextstate = INIT;
			else if (start == 1)				
					nextstate = FOR_LOOP1;
				
		end//INIT
		
		/*This state and the next state perfom
		"for (k=0; k<M; k++)" and
		"LsfInt[k] = shl(LsfInt[k],1)" */
		FOR_LOOP1:			//state1
		begin
			if(k>=10)
			begin
				nextstate = FOR_LOOP2;
				kReset = 1;
			end
			else if(k<10)
			begin
				memReadAddr = {INTERPOLATION_LSF_INT[11:4],k[3:0]};
				nextstate = FOR_LOOP1_MEM_WAIT1;
			end
		end//FOR_LOOP1
		
		FOR_LOOP1_MEM_WAIT1:			//state2
		begin
			memReadAddr = {INTERPOLATION_LSF_INT[11:4],k[3:0]};
			shlVar1Out = memIn[15:0];
			shlVar2Out = 16'd1;
			memWriteAddr = {INTERPOLATION_LSF_INT[11:4],k[3:0]};
			memOut = {16'd0,shlIn[15:0]};
			memWrite = 1;
			nextstate = FOR_LOOP1_BODY1;
		end	//FOR_LOOP1_MEM_WAIT1
		
		/*This state and the next state perfom		
		"LsfNew[k] = shl(LsfNew[k],1)" */
		FOR_LOOP1_BODY1:			//state3
		begin
			memReadAddr = {INTERPOLATION_LSF_NEW[11:4],k[3:0]};
			nextstate = FOR_LOOP1_MEM_WAIT2;
		end//FOR_LOOP1_BODY1
		
		FOR_LOOP1_MEM_WAIT2:				//state4
		begin
			memReadAddr = {INTERPOLATION_LSF_NEW[11:4],k[3:0]};
			shlVar1Out = memIn[15:0];
			shlVar2Out = 16'd1;
			memWriteAddr = {INTERPOLATION_LSF_NEW[11:4],k[3:0]};
			memOut = {16'd0,shlIn[15:0]};
			memWrite = 1;
			nextstate = FOR_LOOP1;
			addOutA = {12'd0,k[3:0]};
			addOutB = 16'd1;
			nextk = addIn;
			kLD = 1;
		end//FOR_LOOP1_MEM_WAIT2
		
		//"LarNew = &Lar[2]" This line is executed by default in the memory allocation
		
		/*This state and the next state perfom
		"for (i=0; i<2; 2++)" and
		"cur_rc = abs_s(rc[i])" */
		FOR_LOOP2:			//state5
		begin
			if(i>=2)
			begin
				nextstate = LAR_INTERPOL1;
				iReset = 1;
			end
			else if(i<2)
			begin
				memReadAddr = {LEVINSON_DURBIN_RC[11:2],i[1:0]};
				nextstate = FOR_LOOP2_MEM_WAIT1;
			end		
		end//FOR_LOOP2
		
		FOR_LOOP2_MEM_WAIT1:			//state6
		begin
			memReadAddr = {LEVINSON_DURBIN_RC[11:2],i[1:0]};
			if(memIn[15] == 1)
			begin
				subOutA = 16'd0;
				subOutB = memIn[15:0];
				addOutA = subIn;
				addOutB = 16'd1;
				nextcur_rc = addIn;
			end
			else
				nextcur_rc = memIn[15:0];
			cur_rcLD = 1;
			nextstate = FOR_LOOP2_BODY1;
		end//FOR_LOOP2_MEM_WAIT1
		
		/*cur_rc = shr(cur_rc, 4);
		  if (sub(cur_rc ,SEG1)<= 0)
		  {
			LarNew[i] = cur_rc;
		  }
		  else (nextstate)
		*/
		FOR_LOOP2_BODY1:			//state7
		begin
			shrVar1Out = cur_rc;
			shrVar2Out = 16'd4;
			nextcur_rc = shrIn;
			cur_rcLD = 1;
			subOutA = shrIn;
			subOutB = SEG1;
			if(subIn [15] == 1)
			begin
				addOutA = {12'd0,i[3:0]};
				addOutB = 16'd2;
				memWriteAddr = {PERC_VAR_LAR[11:2],addIn[1:0]};
				memOut = {16'd0,shrIn[15:0]};
				memWrite = 1;
				nextstate = FOR_LOOP2;
				nextstate = FOR_LOOP2_BODY5;
			end
			else
				nextstate = FOR_LOOP2_BODY2;			
		end//FOR_LOOP2_BODY1
		
		/* if(sub(cur_rc,SEG2)<= 0)
		   { 
			  cur_rc = shr(cur_rc, 1);
           L_temp = L_mult(cur_rc, A1);
           L_temp = L_sub(L_temp, L_B1);
			  L_temp = L_shr(L_temp, 11);
           LarNew[i] = extract_l(L_temp);
      }
		else
		{
		*/
		FOR_LOOP2_BODY2:			//state8
		begin
			subOutA = cur_rc;
			subOutB = SEG2;
			if(subIn[15] == 1)
			begin
				shrVar1Out = cur_rc;
				shrVar2Out = 16'd1;
				nextcur_rc = shrIn;
				cur_rcLD = 1;
				L_multOutA = shrIn;
				L_multOutB = A1;
				L_subOutA = L_multIn;
				L_subOutB = L_B1;
				L_shrOutVar1 = L_subIn;
				L_shrOutNumShift = 16'd11;
				addOutA = {12'd0,i[3:0]};
				addOutB = 16'd2;
				memWriteAddr = {PERC_VAR_LAR[11:2],addIn[1:0]};
				memOut = {16'd0,L_shrIn[15:0]};
				memWrite = 1;
				nextstate = FOR_LOOP2_BODY5;
			end
			else
				nextstate = FOR_LOOP2_BODY3;
		end//FOR_LOOP2_BODY2
		
		/*if (sub(cur_rc ,SEG3)<= 0) 
		  {
          cur_rc = shr(cur_rc, 1);
          L_temp = L_mult(cur_rc, A2);
          L_temp = L_sub(L_temp, L_B2);
          L_temp = L_shr(L_temp, 1);
          LarNew[i] = extract_l(L_temp);
        }
       else {*/
		FOR_LOOP2_BODY3:			//state9
		begin
			subOutA = cur_rc;
			subOutB = SEG3;
			if(subIn[15] == 1)
			begin
				shrVar1Out = cur_rc;
				shrVar2Out = 16'd1;
				nextcur_rc = shrIn;
				cur_rcLD = 1;
				L_multOutA = shrIn;
				L_multOutB = A2;
				L_subOutA = L_multIn;
				L_subOutB = L_B2;
				L_shrOutVar1 = L_subIn;
				L_shrOutNumShift = 16'd11;
				addOutA = {12'd0,i[3:0]};
				addOutB = 16'd2;
				memWriteAddr = {PERC_VAR_LAR[11:2],addIn[1:0]};
				memOut = {16'd0,L_shrIn[15:0]};
				memWrite = 1;
				nextstate = FOR_LOOP2_BODY5;
			end
			else
				nextstate = FOR_LOOP2_BODY4;
		end//FOR_LOOP2_BODY3
		
		/*
			cur_rc = shr(cur_rc, 1);
         L_temp = L_mult(cur_rc, A3);
         L_temp = L_sub(L_temp, L_B3);
         L_temp = L_shr(L_temp, 11);
         LarNew[i] = extract_l(L_temp);
        }	}    }
	   */
		FOR_LOOP2_BODY4:			//state10
		begin
			shrVar1Out = cur_rc;
			shrVar2Out = 16'd1;
			nextcur_rc = shrIn;
			cur_rcLD = 1;
			L_multOutA = shrIn;
			L_multOutB = A3;
			L_subOutA = L_multIn;
			L_subOutB = L_B3;
			L_shrOutVar1 = L_subIn;
			L_shrOutNumShift = 16'd11;
			addOutA = {12'd0,i[3:0]};
			addOutB = 16'd2;
			memWriteAddr = {PERC_VAR_LAR[11:2],addIn[1:0]};
			memOut = {16'd0,L_shrIn[15:0]};
			memWrite = 1;
			nextstate = FOR_LOOP2_BODY5;
		end//FOR_LOOP2_BODY4
		
		/* The next three states execute the following code
		 if (r_c[i] < 0)
			LarNew[i] = sub(0, LarNew[i]);
		*/
		FOR_LOOP2_BODY5:			//state11
		begin
			memReadAddr = {LEVINSON_DURBIN_RC[11:2],i[1:0]};
			nextstate = FOR_LOOP2_BODY5_MEM_WAIT1;
		end//FOR_LOOP2_BODY5
		
		FOR_LOOP2_BODY5_MEM_WAIT1:			//state12
		begin
			memReadAddr = {LEVINSON_DURBIN_RC[11:2],i[1:0]};
			if(memIn[15] == 1)
			begin
				addOutA = {12'd0,i[3:0]};
				addOutB = 16'd2;
				memReadAddr = {PERC_VAR_LAR[11:2],addIn[1:0]};
				nextstate = FOR_LOOP2_BODY5_MEM_WAIT2;
			end
			else
			begin
				L_addOutA = {28'd0,i[3:0]}; 
				L_addOutB = 32'd1;
				nexti = L_addIn;
				iLD = 1;
				nextstate = FOR_LOOP2;
			end
		end//FOR_LOOP2_BODY5_MEM_WAIT1
		
		FOR_LOOP2_BODY5_MEM_WAIT2:			//state13
		begin
			subOutA = 16'd0;
			subOutB = memIn;
			addOutA = {12'd0,i[3:0]};
			addOutB = 16'd2;
			memWriteAddr = {PERC_VAR_LAR[11:2],addIn[1:0]};
			memOut = {16'd0,subIn[15:0]};
			memWrite = 1;
			L_addOutA = {28'd0,i[3:0]}; 
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			nextstate = FOR_LOOP2;
		end//FOR_LOOP2_BODY5_MEM_WAIT2
		
		/*	The next 4 states execute
			temp = add(LarNew[0], LarOld[0]);
			Lar[0] = shr(temp, 1);
			LarOld[0] = LarNew[0];
		*/
		LAR_INTERPOL1:			//state14
		begin
			memReadAddr = {PERC_VAR_LAR[11:2],2'd2};
			nextstate = LAR_INTERPOL1_MEM_WAIT1;
		end//LAR_INTERPOL1
		
		LAR_INTERPOL1_MEM_WAIT1:			//state15
		begin
			nexttemp = memIn[15:0];
			tempLD = 1;
			memReadAddr = {PERC_VAR_LAR_OLD[11:2],2'd0};
			nextstate = LAR_INTERPOL1_MEM_WAIT2;
		end//LAR_INTERPOL1_MEM_WAIT1
		
		LAR_INTERPOL1_MEM_WAIT2:			//state16
		begin
			addOutA = temp;
			addOutB = memIn[15:0];
			shrVar1Out = addIn;
			shrVar2Out = 16'd1;
			memOut = shrIn;
			memWrite = 1;
			memWriteAddr = {PERC_VAR_LAR[11:2],2'd0};
			nextstate = LAR_INTERPOL1_MEM_WAIT3;
		end//LAR_INTERPOL1_MEM_WAIT2
		
		LAR_INTERPOL1_MEM_WAIT3:			//state17
		begin
			memOut = temp;
			memWrite = 1;
			memWriteAddr = {PERC_VAR_LAR_OLD[11:2],2'd0};
			nextstate = LAR_INTERPOL2;
		end//LAR_INTERPOL1_MEM_WAIT3
		  /*	The next four states execute
		  temp = add(LarNew[1], LarOld[1]);
		  Lar[1] = shr(temp, 1);
		  LarOld[1] = LarNew[1];
		  */
		LAR_INTERPOL2:			//state18
		begin
			memReadAddr = {PERC_VAR_LAR[11:2],2'd3};
			nextstate = LAR_INTERPOL2_MEM_WAIT1;
		end//LAR_INTERPOL2
		
		LAR_INTERPOL2_MEM_WAIT1:			//state19
		begin
			nexttemp = memIn[15:0];
			tempLD = 1;
			memReadAddr = {PERC_VAR_LAR_OLD[11:2],2'd1};
			nextstate = LAR_INTERPOL2_MEM_WAIT2;
		end//LAR_INTERPOL2_MEM_WAIT1
		
		LAR_INTERPOL2_MEM_WAIT2:			//state20
		begin
			addOutA = temp;
			addOutB = memIn[15:0];
			shrVar1Out = addIn;
			shrVar2Out = 16'd1;
			memOut = shrIn;
			memWrite = 1;
			memWriteAddr = {PERC_VAR_LAR[11:2],2'd1};
			nextstate = LAR_INTERPOL2_MEM_WAIT3;
		end//LAR_INTERPOL2_MEM_WAIT2
		
		LAR_INTERPOL2_MEM_WAIT3:			//state21
		begin
			memOut = temp;
			memWrite = 1;
			memWriteAddr = {PERC_VAR_LAR_OLD[11:2],2'd1};
			nextstate = FOR_LOOP3;
		end//LAR_INTERPOL2_MEM_WAIT3
		
		//	for (k=0; k<2; k++) {       
		FOR_LOOP3:			//state22
		begin
			if(k>=2)
			begin
				kReset = 1;
				nextstate = INIT;
				done = 1;
			end
			
			else if(k<2)
			begin
				multOutA = k;
				multOutB = 2;
				memReadAddr = {PERC_VAR_LAR[11:2],multIn[1:0]};
				nextstate = FOR_LOOP3_MEM_WAIT1;
			end
		end//FOR_LOOP3
		
		//CritLar0 = Lar[2*k];
		FOR_LOOP3_MEM_WAIT1:			//state23
		begin
			nextcritLar0 = memIn[15:0];
			critLar0LD = 1;
			multOutA = k;
			multOutB = 2;
			addOutA = multIn;
			addOutB = 16'd1;
			memReadAddr = {PERC_VAR_LAR[11:2],addIn[1:0]};
			nextstate = FOR_LOOP3_BODY1;
		end//FOR_LOOP3_MEM_WAIT1
	
		/*CritLar1 = Lar[2*k+1];
		  if (smooth != 0) 
		  {
			if ((sub(CritLar0,THRESH_L1)<0)&&( sub(CritLar1,THRESH_H1)>0)) 
			{
				smooth = 0;
         }}
		  else {
		*/
		FOR_LOOP3_BODY1:			//state24
		begin
			nextcritLar1 = memIn[15:0];
			critLar1LD = 1;	
			if(smooth != 0)
			begin
				subOutA = critLar0;
				subOutB = THRESH_L1;
				L_subOutA = {16'd0,nextcritLar1[15:0]};
				L_subOutB = THRESH_H1;
				if((subIn[15] == 1) && (L_subIn[15] != 1))
				begin
					nextsmooth = 0;
					smoothLD = 1;					
				end
				nextstate = FOR_LOOP3_BODY3;
			end
			else
				nextstate = FOR_LOOP3_BODY2;
		end//FOR_LOOP3_BODY1
		
		/*
		 else {
        if ( (sub(CritLar0 ,THRESH_L2)>0) || (sub(CritLar1,THRESH_H2) <0) ) 
		  {
			smooth = 1;
        }}
		*/
		FOR_LOOP3_BODY2:			//state25
		begin
			subOutA = critLar0;
			subOutB = THRESH_L2;
			L_subOutA = {16'd0,critLar1[15:0]};
			L_subOutB = THRESH_H2;
			if((subIn[15] != 1) || (L_subIn[15] == 1))
			begin
				nextsmooth = 1;
				smoothLD = 1;				
			end
			nextstate = FOR_LOOP3_BODY3;
		end//FOR_LOOP3_BODY2
		
		/*
		if (smooth == 0)		{
			gamma1[k] = GAMMA1_0;
			if (k == 0)			{
				Lsf = LsfInt;	}
			else 					{
				Lsf = LsfNew;  }      
		*/
		FOR_LOOP3_BODY3:			//state26
		begin			
			if(smooth == 0)
			begin
				memWriteAddr = {PERC_VAR_GAMMA1[11:4],k[3:0]};
				memOut = GAMMA1_0;
				memWrite = 1;
				if(k == 0)
				begin				
					nextLsf = INTERPOLATION_LSF_INT;
					LsfLD = 1;
				end
			
				else
				begin
					nextLsf = INTERPOLATION_LSF_NEW;
					LsfLD = 1;
				end		
				nextstate = FOR_LOOP3_BODY3_MEM_WAIT1;				
			end
			else
				nextstate = GAMMA_SET1;
		end//FOR_LOOP3_BODY3
		
		/* next three states perform
			d_min = sub(Lsf[1], Lsf[0]);
		*/
		FOR_LOOP3_BODY3_MEM_WAIT1:			//state27
		begin
			memReadAddr = {Lsf[11:1],1'd0};					
			nextstate = FOR_LOOP3_BODY3_MEM_WAIT1_5;	
		end//FOR_LOOP3_BODY3_MEM_WAIT1
		
		FOR_LOOP3_BODY3_MEM_WAIT1_5:	//state28
		begin
			nexttemp = memIn[15:0];
			tempLD = 1;	
			memReadAddr = {Lsf[11:1],1'd1};
			nextstate = FOR_LOOP3_BODY3_MEM_WAIT2;
		end//FOR_LOOP3_BODY3_MEM_WAIT1_5:
		
		FOR_LOOP3_BODY3_MEM_WAIT2:			//state29
		begin
			memReadAddr = {Lsf[11:1],1'd1};
			subOutA = memIn[15:0];
			subOutB = temp;
			nextd_min = subIn;
			d_minLD = 1;
			nexti = 1;
			iLD = 1;
			nextstate = FOR_LOOP4;
		end//FOR_LOOP3_BODY3_MEM_WAIT2
		
		//for (i=1; i<M-1; i++) {
		FOR_LOOP4:			//state30
		begin
			if(i>=9)
			begin
				iReset = 1;
				nextstate = FOR_LOOP3_BODY4;
			end
			else if(i<9)
			begin
				memReadAddr = {Lsf[11:4],i[3:0]};
				nextstate = FOR_LOOP4_MEM_WAIT1;
			end
		end//FOR_LOOP4
		
		/*	next two states perform
			temp = sub(Lsf[i+1],Lsf[i]);
			if (sub(temp,d_min)<0) {
            d_min = temp;       }
		*/
		FOR_LOOP4_MEM_WAIT1:			//state31
		begin
			nexttemp = memIn[15:0];
			tempLD = 1;
			addOutA = {12'd0,i[3:0]};
			addOutB = 16'd1;
			memReadAddr = {Lsf[11:4],addIn[3:0]};
			nextstate = FOR_LOOP4_MEM_WAIT2;
		end//FOR_LOOP4_MEM_WAIT1
		
		FOR_LOOP4_MEM_WAIT2:			//state32
		begin
			subOutA = memIn[15:0];
			subOutB = temp;
			L_subOutA = {16'd0,subIn};
			L_subOutB = {16'd0,d_min};
			if(L_subIn[15] == 1)
			begin
				nextd_min = subIn;
				d_minLD = 1;
			end
			addOutA = {12'd0,i[3:0]};
			addOutB = 16'd1;
			nexti = addIn;
			iLD = 1;
			nextstate = FOR_LOOP4;
		end//FOR_LOOP4_MEM_WAIT2
		
		/*
			temp = mult(ALPHA, d_min);
			temp = sub(BETA, temp);
			temp = shl(temp, 5);
			gamma2[k] = temp;
		*/
		FOR_LOOP3_BODY4:			//state33
		begin
			multOutA = ALPHA;
			multOutB = d_min;
			subOutA = BETA;
			subOutB = multIn;
			shlVar1Out = subIn;
			shlVar2Out = 16'd5;
			memWriteAddr = {PERC_VAR_GAMMA2[11:1],k[0]};
			memOut = shlIn;
			memWrite = 1;
			nextstate = FOR_LOOP3_BODY5;
			nexttemp = shlIn;
			tempLD = 1;
		end//FOR_LOOP3_BODY4
		
		/*if (sub(gamma2[k] , GAMMA2_0_H)>0) {
        gamma2[k] = GAMMA2_0_H;		       }
		*/
		FOR_LOOP3_BODY5:			//state34
		begin
			subOutA = temp;
			subOutB = GAMMA2_0_H;
			if(subIn[15] != 1)
			begin
				memWriteAddr = {PERC_VAR_GAMMA2[11:1],k[0]};
				memOut = GAMMA2_0_H;
				memWrite = 1;
			end
			nextstate = FOR_LOOP3_BODY6;
		end//FOR_LOOP3_BODY5
		
		/*if (sub(gamma2[k] ,GAMMA2_0_L)<0) {
        gamma2[k] = GAMMA2_0_L;		      }
		*/
		FOR_LOOP3_BODY6:			//state35
		begin
			subOutA = temp;
			subOutB = GAMMA2_0_L;
			if(subIn[15] == 1)
			begin
				memWriteAddr = {PERC_VAR_GAMMA2[11:1],k[0]};
				memOut = GAMMA2_0_L;
				memWrite = 1;
			end
			addOutA = {12'd0,k[3:0]};
			addOutB = 16'd1;
			nextk = addIn;
			kLD = 1;
			nextstate = FOR_LOOP3;
		end//FOR_LOOP3_BODY6
		
		GAMMA_SET1:			//state36
		begin
			memWriteAddr = {PERC_VAR_GAMMA1[11:1],k[0]};
			memOut = GAMMA1_1;
			memWrite = 1;
			nextstate = GAMMA_SET2;
		end//GAMMA_SET1
		
		GAMMA_SET2:				//state37
		begin
			memWriteAddr = {PERC_VAR_GAMMA2[11:1],k[0]};
			memOut = GAMMA2_1;
			memWrite = 1;
			addOutA = {12'd0,k[3:0]};
			addOutB = 16'd1;
			nextk = addIn;
			kLD = 1;
			nextstate = FOR_LOOP3;
		end//GAMMA_SET2

	endcase
end//always block

endmodule 