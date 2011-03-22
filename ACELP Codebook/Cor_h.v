				`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    13:43:07 03/09/2011 
// Module Name:    Cor_h.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "Cor_h".
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Cor_h(clk,reset,start,L_macIn,L_subIn,subIn,shrIn,norm_lIn,norm_lDone,shlIn,addIn,L_addIn,L_add2In,
				 L_add3In,L_add4In,memIn,L_macOutA,L_macOutB,L_macOutC,L_subOutA,L_subOutB,subOutA,subOutB,
				 shrVar1Out,shrVar2Out,norm_lVar1Out,norm_lReady,shlVar1Out,shlVar2Out,addOutA,addOutB,L_addOutA,
				 L_addOutB,L_add1OutA,L_add1OutB,L_add2OutA,L_add2OutB,L_add3OutA,L_add3OutB,L_add4OutA,
				 L_add4OutB,memReadAddr,memWriteAddr,memOut,memWriteEn,done);
`include "paramList.v"	 
//Inputs
input clk,reset,start;
input [31:0] L_macIn;
input [31:0] L_subIn;
input [15:0] subIn;
input [15:0] shrIn;
input [15:0] norm_lIn;
input norm_lDone;
input [15:0] shlIn;
input [15:0] addIn;
input [31:0] L_addIn;
input [31:0] L_add2In;
input [31:0] L_add3In;
input [31:0] L_add4In;
input [31:0] memIn;

//Outputs
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;
output reg [31:0] L_subOutA,L_subOutB;
output reg [15:0] subOutA,subOutB;
output reg [15:0] shrVar1Out,shrVar2Out;
output reg [31:0] norm_lVar1Out;
output reg norm_lReady;
output reg [15:0] shlVar1Out,shlVar2Out;
output reg [15:0] addOutA,addOutB;
output reg [31:0] L_addOutA,L_addOutB;
output reg [31:0] L_add1OutA,L_add1OutB;
output reg [31:0] L_add2OutA,L_add2OutB;
output reg [31:0] L_add3OutA,L_add3OutB;
output reg [31:0] L_add4OutA,L_add4OutB;
output reg [10:0] memReadAddr,memWriteAddr;
output reg [31:0] memOut;
output reg memWriteEn;
output reg done;

//internal registers
reg [6:0] state,nextstate;
reg [10:0] rri0i0,nextrri0i0;
reg rri0i0Reset,rri0i0LD;
reg [10:0] rri1i1,nextrri1i1;
reg rri1i1Reset,rri1i1LD;
reg [10:0] rri2i2,nextrri2i2;
reg rri2i2Reset,rri2i2LD;
reg [10:0] rri3i3,nextrri3i3;
reg rri3i3Reset,rri3i3LD;
reg [10:0] rri4i4,nextrri4i4;
reg rri4i4Reset,rri4i4LD;
reg [10:0] rri0i1,nextrri0i1;
reg rri0i1Reset,rri0i1LD;
reg [10:0] rri0i2,nextrri0i2;
reg rri0i2Reset,rri0i2LD;
reg [10:0] rri0i3,nextrri0i3;
reg rri0i3Reset,rri0i3LD;
reg [10:0] rri0i4,nextrri0i4;
reg rri0i4Reset,rri0i4LD;
reg [10:0] rri1i2,nextrri1i2;
reg rri1i2Reset,rri1i2LD;
reg [10:0] rri1i3,nextrri1i3;
reg rri1i3Reset,rri1i3LD;
reg [10:0] rri1i4,nextrri1i4;
reg rri1i4Reset,rri1i4LD;
reg [10:0] rri2i3,nextrri2i3;
reg rri2i3Reset,rri2i3LD;
reg [10:0] rri2i4,nextrri2i4;
reg rri2i4Reset,rri2i4LD;
reg [10:0] p0,nextp0;
reg p0Reset,p0LD;
reg [10:0] p1,nextp1;
reg p1Reset,p1LD;
reg [10:0] p2,nextp2;
reg p2Reset,p2LD;
reg [10:0] p3,nextp3;
reg p3Reset,p3LD;
reg [10:0] p4,nextp4;
reg p4Reset,p4LD;
reg [10:0] ptr_hd,nextptr_hd;
reg ptr_hdReset,ptr_hdLD;
reg [10:0] ptr_hf,nextptr_hf;
reg ptr_hfReset,ptr_hfLD;
reg [10:0] ptr_h1,nextptr_h1;
reg ptr_h1Reset,ptr_h1LD;
reg [10:0] ptr_h2,nextptr_h2;
reg ptr_h2Reset,ptr_h2LD;
reg [31:0] cor,nextcor;
reg corReset,corLD;
reg [31:0] L_temp,nextL_temp;
reg L_tempReset,L_tempLD;
reg [5:0] i,nexti;
reg iLD,iReset;
reg [3:0] k,nextk;
reg kReset,kLD;
reg [15:0] ldec,nextldec;
reg ldecReset,ldecLD;
reg [15:0] l_fin_sup,nextl_fin_sup;
reg l_fin_supReset,l_fin_supLD;
reg [15:0] l_fin_inf,nextl_fin_inf;
reg l_fin_infReset,l_fin_infLD; 
reg [31:0] temp,nexttemp;
reg tempReset,tempLD;

//state parameters
parameter INIT = 7'd0;
parameter S1 = 7'd1;
parameter S2 = 7'd2;
parameter S3 = 7'd3;
parameter S4 = 7'd4;
parameter S5 = 7'd5;
parameter S6 = 7'd6;
parameter S7 = 7'd7;
parameter S8 = 7'd8;
parameter S9 = 7'd9;
parameter S10 = 7'd10;
parameter S11 = 7'd11;
parameter S12 = 7'd12;
parameter S13 = 7'd13;
parameter S14 = 7'd14;
parameter S15 = 7'd15;
parameter S16 = 7'd16;
parameter S17 = 7'd17;
parameter S18 = 7'd18;
parameter S19 = 7'd19;
parameter S20 = 7'd20;
parameter S21 = 7'd21;
parameter S22 = 7'd22;
parameter S23 = 7'd23;
parameter S24 = 7'd24;
parameter S25 = 7'd25;
parameter S26 = 7'd26;
parameter S27 = 7'd27;
parameter S28 = 7'd28;
parameter S29 = 7'd29;
parameter S30 = 7'd30;
parameter S31 = 7'd31;
parameter S32 = 7'd32;
parameter S33 = 7'd33;
parameter S34 = 7'd34;
parameter S35 = 7'd35;
parameter S36 = 7'd36;
parameter S37 = 7'd37;
parameter S38 = 7'd38;
parameter S39 = 7'd39;
parameter S40 = 7'd40;
parameter S41 = 7'd41;
parameter S42 = 7'd42;
parameter S43 = 7'd43;
parameter S44 = 7'd44;
parameter S45 = 7'd45;
parameter S46 = 7'd46;
parameter S47 = 7'd47;
parameter S48 = 7'd48;
parameter S49 = 7'd49;
parameter S50 = 7'd50;
parameter S51 = 7'd51;
parameter S52 = 7'd52;
parameter S53 = 7'd53;
parameter S54 = 7'd54;
parameter S55 = 7'd55;
parameter S56 = 7'd56;
parameter S57 = 7'd57;
parameter S58 = 7'd58;
parameter S59 = 7'd59;
parameter S60 = 7'd60;
parameter S61 = 7'd61;
parameter S62 = 7'd62;
parameter S63 = 7'd63;
parameter S64 = 7'd64;
parameter S65 = 7'd65;
parameter S66 = 7'd66;
parameter S67 = 7'd67;
parameter S68 = 7'd68;
parameter S69 = 7'd69;
parameter S70 = 7'd70;
parameter S71 = 7'd71;
parameter S72 = 7'd72;
parameter S73 = 7'd73;
parameter S74 = 7'd74;
parameter S75 = 7'd75;
parameter S76 = 7'd76;
parameter S77 = 7'd77;
parameter S78 = 7'd78;
parameter S79 = 7'd79;
parameter S80 = 7'd80;
parameter S81 = 7'd81;
parameter S82 = 7'd82;
parameter S83 = 7'd83;
parameter S84 = 7'd84;
parameter S85 = 7'd85;
parameter S86 = 7'd86;
parameter S87 = 7'd87;
parameter S88 = 7'd88;
parameter S89 = 7'd89;
parameter S90 = 7'd90;
parameter S91 = 7'd91;
parameter S92 = 7'd92;
parameter S93 = 7'd93;
parameter S94 = 7'd94;
parameter S95 = 7'd95;
parameter S96 = 7'd96;
parameter S97 = 7'd97;
parameter S98 = 7'd98;
parameter S99 = 7'd99;
parameter S100 = 7'd100;
parameter S101 = 7'd101;
parameter S102 = 7'd102;
parameter S103 = 7'd103;

//internal Flip flops
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
		rri0i0 <= 0;
	else if(rri0i0Reset)
		rri0i0 <= 0;
	else if(rri0i0LD)
		rri0i0 <= nextrri0i0;
end

always @(posedge clk)
begin
	if(reset)
		rri1i1 <= 0;
	else if(rri1i1Reset)
		rri1i1 <= 0;
	else if(rri1i1LD)
		rri1i1 <= nextrri1i1;
end

always @(posedge clk)
begin
	if(reset)
		rri2i2 <= 0;
	else if(rri2i2Reset)
		rri2i2 <= 0;
	else if(rri2i2LD)
		rri2i2 <= nextrri2i2;
end

always @(posedge clk)
begin
	if(reset)
		rri3i3 <= 0;
	else if(rri3i3Reset)
		rri3i3 <= 0;
	else if(rri3i3LD)
		rri3i3 <= nextrri3i3;
end

always @(posedge clk)
begin
	if(reset)
		rri4i4 <= 0;
	else if(rri4i4Reset)
		rri4i4 <= 0;
	else if(rri4i4LD)
		rri4i4 <= nextrri4i4;
end

always @(posedge clk)
begin
	if(reset)
		rri0i1 <= 0;
	else if(rri0i1Reset)
		rri0i1 <= 0;
	else if(rri0i1LD)
		rri0i1 <= nextrri0i1;
end

always @(posedge clk)
begin
	if(reset)
		rri0i2 <= 0;
	else if(rri0i2Reset)
		rri0i2 <= 0;
	else if(rri0i2LD)
		rri0i2 <= nextrri0i2;
end

always @(posedge clk)
begin
	if(reset)
		rri0i3 <= 0;
	else if(rri0i3Reset)
		rri0i3 <= 0;
	else if(rri0i3LD)
		rri0i3 <= nextrri0i3;
end

always @(posedge clk)
begin
	if(reset)
		rri0i4 <= 0;
	else if(rri0i4Reset)
		rri0i4 <= 0;
	else if(rri0i4LD)
		rri0i4 <= nextrri0i4;
end

always @(posedge clk)
begin
	if(reset)
		rri1i2 <= 0;
	else if(rri1i2Reset)
		rri1i2 <= 0;
	else if(rri1i2LD)
		rri1i2 <= nextrri1i2;
end

always @(posedge clk)
begin
	if(reset)
		rri1i3 <= 0;
	else if(rri1i3Reset)
		rri1i3 <= 0;
	else if(rri1i3LD)
		rri1i3 <= nextrri1i3;
end

always @(posedge clk)
begin
	if(reset)
		rri1i4 <= 0;
	else if(rri1i4Reset)
		rri1i4 <= 0;
	else if(rri1i4LD)
		rri1i4 <= nextrri1i4;
end

always @(posedge clk)
begin
	if(reset)
		rri2i3 <= 0;
	else if(rri2i3Reset)
		rri2i3 <= 0;
	else if(rri2i3LD)
		rri2i3 <= nextrri2i3;
end

always @(posedge clk)
begin
	if(reset)
		rri2i4 <= 0;
	else if(rri2i4Reset)
		rri2i4 <= 0;
	else if(rri2i4LD)
		rri2i4 <= nextrri2i4;
end

always @(posedge clk)
begin
	if(reset)
		p0 <= 0;
	else if(p0Reset)
		p0 <= 0;
	else if(p0LD)
		p0 <= nextp0;
end

always @(posedge clk)
begin
	if(reset)
		p1 <= 0;
	else if(p1Reset)
		p1 <= 0;
	else if(p1LD)
		p1 <= nextp1;
end

always @(posedge clk)
begin
	if(reset)
		p2 <= 0;
	else if(p2Reset)
		p2 <= 0;
	else if(p2LD)
		p2 <= nextp2;
end

always @(posedge clk)
begin
	if(reset)
		p3 <= 0;
	else if(p3Reset)
		p3 <= 0;
	else if(p3LD)
		p3 <= nextp3;
end

always @(posedge clk)
begin
	if(reset)
		p4 <= 0;
	else if(p4Reset)
		p4 <= 0;
	else if(p4LD)
		p4 <= nextp4;
end

always @(posedge clk)
begin
	if(reset)
		ptr_hd <= 0;
	else if(ptr_hdReset)
		ptr_hd <= 0;
	else if(ptr_hdLD)
		ptr_hd <= nextptr_hd;
end

always @(posedge clk)
begin
	if(reset)
		ptr_hf <= 0;
	else if(ptr_hfReset)
		ptr_hf <= 0;
	else if(ptr_hfLD)
		ptr_hf <= nextptr_hf;
end

always @(posedge clk)
begin
	if(reset)
		ptr_h1 <= 0;
	else if(ptr_h1Reset)
		ptr_h1 <= 0;
	else if(ptr_h1LD)
		ptr_h1 <= nextptr_h1;
end

always @(posedge clk)
begin
	if(reset)
		ptr_h2 <= 0;
	else if(ptr_h2Reset)
		ptr_h2 <= 0;
	else if(ptr_h2LD)
		ptr_h2 <= nextptr_h2;
end

always @(posedge clk)
begin
	if(reset)
		cor <= 0;
	else if(corReset)
		cor <= 0;
	else if(corLD)
		cor <= nextcor;
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
		i <= 0;
	else if(iReset)
		i <= 0;
	else if(iLD)
		i <= nexti;
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
		ldec <= 0;
	else if(ldecReset)
		ldec <= 0;
	else if(ldecLD)
		ldec <= nextldec;
end

always @(posedge clk)
begin
	if(reset)
		l_fin_sup <= 0;
	else if(l_fin_supReset)
		l_fin_sup <= 0;
	else if(l_fin_supLD)
		l_fin_sup <= nextl_fin_sup;
end

always @(posedge clk)
begin
	if(reset)
		l_fin_inf <= 0;
	else if(l_fin_infReset)
		l_fin_inf <= 0;
	else if(l_fin_infLD)
		l_fin_inf <= nextl_fin_inf;
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

always @(*)
begin

	nextstate = state;
	nextrri0i0 = rri0i0;
	nextrri1i1 = rri1i1;
	nextrri2i2 = rri2i2;
	nextrri3i3 = rri3i3;
	nextrri4i4 = rri4i4;
	nextrri0i1 = rri0i1;
	nextrri0i2 = rri0i2;
	nextrri0i3 = rri0i3;
	nextrri0i4 = rri0i4;
	nextrri1i2 = rri1i2;
	nextrri1i3 = rri1i3;
	nextrri1i4 = rri1i4;
	nextrri2i3 = rri2i3;
	nextrri2i4 = rri2i4;
	nextp0 = p0;
	nextp1 = p1;
	nextp2 = p2;
	nextp3 = p3;
	nextp4 = p4;
	nextptr_hd = ptr_hd;
	nextptr_hf = ptr_hf;
	nextptr_h1 = ptr_h1;
	nextptr_h2 = ptr_h2;
	nextcor = cor;
	nextL_temp = L_temp;
	nexti = i;
	nextk = k;
	nextldec = ldec;
	nextl_fin_sup = l_fin_sup;
	nextl_fin_inf = l_fin_inf;
	nexttemp = temp;
	rri0i0Reset = 0;
	rri1i1Reset = 0;
	rri2i2Reset = 0;
	rri3i3Reset = 0;
	rri4i4Reset = 0;
	rri0i1Reset = 0;
	rri0i2Reset = 0;
	rri0i3Reset = 0;
	rri0i4Reset = 0;
	rri1i2Reset = 0;
	rri1i3Reset = 0;
	rri1i4Reset = 0;
	rri2i3Reset = 0;
	rri2i4Reset = 0;
	p0Reset = 0;
	p1Reset = 0;
	p2Reset = 0;
	p3Reset = 0;
	p4Reset = 0;
	ptr_hdReset = 0;
	ptr_hfReset = 0;
	ptr_h1Reset = 0;
	ptr_h2Reset = 0;
	corReset = 0;
	L_tempReset = 0;
	iReset = 0;
	kReset = 0;
	ldecReset = 0;
	l_fin_supReset = 0;
	l_fin_infReset = 0;
	tempReset = 0;
	rri0i0LD = 0;
	rri1i1LD = 0;
	rri2i2LD = 0;
	rri3i3LD = 0;
	rri4i4LD = 0;
	rri0i1LD = 0;
	rri0i2LD = 0;
	rri0i3LD = 0;
	rri0i4LD = 0;
	rri1i2LD = 0;
	rri1i3LD = 0;
	rri1i4LD = 0;
	rri2i3LD = 0;
	rri2i4LD = 0;
	p0LD = 0;
	p1LD = 0;
	p2LD = 0;
	p3LD = 0;
	p4LD = 0;
	ptr_hdLD = 0;
	ptr_hfLD = 0;
	ptr_h1LD = 0;
	ptr_h2LD = 0;
	corLD = 0;
	L_tempLD = 0;
	iLD = 0;
	kLD = 0;
	ldecLD = 0;
	l_fin_supLD = 0;
	l_fin_infLD = 0;
	tempLD = 0;
	L_macOutA = 0;
	L_macOutB = 0;
	L_macOutC = 0;
	L_subOutA = 0;
	L_subOutB = 0;
	shrVar1Out = 0;
	shrVar2Out = 0;
	norm_lVar1Out = 0;
	norm_lReady = 0;
	shlVar1Out = 0;
	shlVar2Out = 0;
	addOutA = 0;
	addOutB = 0;
	subOutA = 0;
	subOutB = 0;
	L_addOutA = 0;
	L_addOutB = 0;
	L_add1OutA = 0;
	L_add1OutB = 0;
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
	done = 0;
	
	case(state)	
	INIT:
	begin
		if(start == 0)
			nextstate = INIT;
		else if(start == 1)
		begin
				rri0i0Reset = 1;
				rri1i1Reset = 1;
				rri2i2Reset = 1;
				rri3i3Reset = 1;
				rri4i4Reset = 1;
				rri0i1Reset = 1;
				rri0i2Reset = 1;
				rri0i3Reset = 1;
				rri0i4Reset = 1;
				rri1i2Reset = 1;
				rri1i3Reset = 1;
				rri1i4Reset = 1;
				rri2i3Reset = 1;
				rri2i4Reset = 1;
				p0Reset = 1;
				p1Reset = 1;
				p2Reset = 1;
				p3Reset = 1;
				p4Reset = 1;
				ptr_hdReset = 1;
				ptr_hfReset = 1;
				ptr_h1Reset = 1;
				ptr_h2Reset = 1;
				corReset = 1;
				L_tempReset = 1;
				iReset = 1;
				kReset = 1;
				ldecReset = 1;
				l_fin_supReset = 1;
				l_fin_infReset = 1;
				tempReset = 1;
				nextstate = S1;
		end
	end//INIT
	
	//for(i=0; i<L_SUBFR; i++)    
	S1:
	begin
		if(i>=40)
			nextstate = S3;
		else if(i<40)
		begin
			memReadAddr = {ACELP_H[10:6],i[5:0]};
			nextstate = S2;
		end		
	end//S1
	
	//cor = L_mac(cor, H[i], H[i]);
	S2:
	begin
		L_macOutA = memIn;
		L_macOutB = memIn;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = {10'd0,i[5:0]};
		addOutB = 16'd1;
		nexti = addIn;
		iLD = 1;
		nextstate = S1;
	end//S2
	
	/*L_tmp = L_sub(extract_h(cor),32000);
     if(L_tmp>0L )*/ 
	S3:
	begin
		iReset = 1;
		L_subOutA = cor[31:16];
		L_subOutB = 32'd32000;
		if(L_subIn[31] == 0)
			nextstate = S4;		
		else if(L_subIn[31] == 1)
		begin			
			norm_lVar1Out = cor;
			norm_lReady = 1;
			nextstate = S6;
		end
	end//S3
	
	//for(i=0; i<L_SUBFR; i++) {      
	S4:
	begin
		if(i>=40)
			nextstate = S9;
		else if(i<40)
		begin
			memReadAddr = {ACELP_H[10:6],i[5:0]};
			nextstate = S5;
		end
	end//S4
	
	// h[i] = shr(H[i], 1);}
	S5:
	begin
		shrVar1Out = memIn[15:0];
		shrVar2Out = 16'd1;
		memOut = shrIn;
		memWriteEn = 1;
		memWriteAddr = {COR_H[10:6],i[5:0]};
		addOutA = i;
		addOutB = 16'd1;
		nexti = addIn[5:0];
		iLD = 1;
		nextstate = S4;
	end//S5
	
	/* k = norm_l(cor);
      k = shr(k, 1);
	*/
	S6:
	begin
		norm_lVar1Out = cor;
		norm_lReady = 1;
		if(norm_lDone == 0)
			nextstate = S6;
		else if(norm_lDone == 1)
		begin
			norm_lReady = 0;
			shrVar1Out = norm_lIn;
			shrVar2Out = 16'd1;
			nextk = shrIn[3:0];
			kLD = 1;
			nextstate = S7;
		end
	end//S6
	
	//for(i=0; i<L_SUBFR; i++) 
	S7:
	begin
		if(i>=40)
			nextstate = S9;
		else if(i<40)
		begin
			memReadAddr = {ACELP_H[10:6],i[5:0]};
			nextstate = S8;
		end
	end//S7
	
	//h[i] = shl(H[i], k);
	S8:
	begin
		shlVar1Out = memIn[15:0];
		shlVar2Out = k;
		memOut = shlIn;
		memWriteEn = 1;
		memWriteAddr = {COR_H[10:6],i[5:0]};
		addOutA = i;
		addOutB = 16'd1;
		nexti = addIn[5:0];
		iLD = 1;
		nextstate = S7;
	end//S8	
	
	  /*rri0i0 = rr;
	  rri1i1 = rri0i0 + NB_POS;
	  rri2i2 = rri1i1 + NB_POS;
	  rri3i3 = rri2i2 + NB_POS;
	  rri4i4 = rri3i3 + NB_POS;
	  rri0i1 = rri4i4 + NB_POS;
	  rri0i2 = rri0i1 + MSIZE;
	  rri0i3 = rri0i2 + MSIZE;
	  rri0i4 = rri0i3 + MSIZE;
	  rri1i2 = rri0i4 + MSIZE;
	  rri1i3 = rri1i2 + MSIZE;
	  rri1i4 = rri1i3 + MSIZE;
	  rri2i3 = rri1i4 + MSIZE;
	  rri2i4 = rri2i3 + MSIZE;
	  p0 = rri0i0 + NB_POS-1;   
	  p1 = rri1i1 + NB_POS-1;
	  p2 = rri2i2 + NB_POS-1;
	  p3 = rri3i3 + NB_POS-1;
	  p4 = rri4i4 + NB_POS-1;
	  ptr_h1 = h;
	  cor    = 0;*/	
	S9:
	begin
	   nextrri0i0 = ACELP_RR;
		rri0i0LD = 1;
		nextrri1i1 = {ACELP_RR[10:4],4'd8};
		rri1i1LD = 1;
		nextrri2i2 = {ACELP_RR[10:5],5'd16};
		rri2i2LD = 1;
		nextrri3i3 = {ACELP_RR[10:5],5'd24};
		rri3i3LD = 1;
		nextrri4i4 = {ACELP_RR[10:6],6'd32};
		rri4i4LD = 1;
		nextrri0i1 = {ACELP_RR[10:6],6'd40};
		rri0i1LD = 1;			
		nextrri0i2 = {ACELP_RR[10:7],7'd104};
		rri0i2LD = 1;
		nextrri0i3 = {ACELP_RR[10:8],8'd168};
		rri0i3LD = 1;		
		nextrri0i4 = {ACELP_RR[10:8],8'd232};
		rri0i4LD = 1;		
		nextrri1i2 = {ACELP_RR[10:9],9'd296};
		rri1i2LD = 1;
		nextrri1i3 = {ACELP_RR[10:9],9'd360};
		rri1i3LD = 1;
		nextrri1i4 = {ACELP_RR[10:9],9'd424};
		rri1i4LD = 1;
		nextrri2i3 = {ACELP_RR[10:9],9'd488}; 
		rri2i3LD = 1;
		nextrri2i4 = {ACELP_RR[10],10'd552}; 
		rri2i4LD = 1;
		nextp0 = {ACELP_RR[10:3],3'd7};
		p0LD = 1;
		nextp1 = {ACELP_RR[10:4],4'd15};
		p1LD = 1;
		nextp2 = {ACELP_RR[10:5],5'd23};
		p2LD = 1;
		nextp3 = {ACELP_RR[10:5],5'd31};
		p3LD = 1;
		nextp4 = {ACELP_RR[10:6],6'd39};
		p4LD = 1;
		nextptr_h1 = COR_H;
		ptr_h1LD = 1;
		corReset = 1;
		iReset = 1;
		nextstate = S10;
	end//S9
	
	//for(i=0;  i<NB_POS; i++)
	S10:
	begin
		if(i>=8)
		begin
			nextstate = S16;
			iReset = 1;
		end
		else if(i<8)
		begin			
			memReadAddr = ptr_h1;
			nextstate = S11;
		end
	end//S10
	
	/*cor = L_mac(cor, *ptr_h1, *ptr_h1); ptr_h1++;
    *p4-- = extract_h(cor);*/
	S11:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = memIn[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p4;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		L_subOutA = {21'd0,p4[10:0]};
		L_subOutB = 32'd1;
		nextp4 = L_subIn[10:0];
		p4LD = 1;
		memReadAddr = addIn[10:0];
		nextstate = S12;
	end//S11
	
	/*cor = L_mac(cor, *ptr_h1, *ptr_h1); ptr_h1++;
    *p3-- = extract_h(cor);*/
	S12:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = memIn[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;		
		memWriteAddr = p3;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		L_subOutA = {21'd0,p3[10:0]};
		L_subOutB = 32'd1;
		nextp3 = L_subIn[10:0];
		p3LD = 1;
		memReadAddr = addIn[10:0];
		nextstate = S13;
	end//S12
	
	/*cor = L_mac(cor, *ptr_h1, *ptr_h1); ptr_h1++;
    *p2-- = extract_h(cor);*/
	S13:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = memIn[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;		
		memWriteAddr = p2;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		L_subOutA = {21'd0,p2[10:0]};
		L_subOutB = 32'd1;
		nextp2 = L_subIn[10:0];
		p2LD = 1;
		memReadAddr = addIn[10:0];
		nextstate = S14;
	end//S13
	
	/*cor = L_mac(cor, *ptr_h1, *ptr_h1); ptr_h1++;
    *p1-- = extract_h(cor);*/
	S14:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = memIn[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;		
		memWriteAddr = p1;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		L_subOutA = {21'd0,p1[10:0]};
		L_subOutB = 32'd1;
		nextp1 = L_subIn[10:0];
		p1LD = 1;
		memReadAddr = addIn[10:0];
		nextstate = S15;
	end//S14
	
	/*cor = L_mac(cor, *ptr_h1, *ptr_h1); ptr_h1++;
    *p0-- = extract_h(cor);*/
	S15:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = memIn[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;		
		memWriteAddr = p0;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		L_subOutA = {21'd0,p0[10:0]};
		L_subOutB = 32'd1;
		nextp0 = L_subIn[10:0];
		p0LD = 1;
		memReadAddr = addIn[10:0];
		L_addOutA = i;
		L_addOutB = 32'd1;
		nexti = L_addIn;
		iLD = 1;		
		nextstate = S10;
	end//S15
	
	/*	l_fin_sup = MSIZE-1;
		l_fin_inf = l_fin_sup-(Word16)1;
		ldec = NB_POS+1;
		ptr_hd = h;
		ptr_hf = ptr_hd + 1;*/
	S16:
	begin			
		nextl_fin_sup = 16'd63;
		l_fin_supLD = 1;
		nextl_fin_inf = 16'd62;
		l_fin_infLD = 1;
		nextldec = 16'd9;
		ldecLD = 1;
		nextptr_hd = COR_H;
		ptr_hdLD = 1;
		nextptr_hf = 11'd961;
		ptr_hfLD = 1;
		kReset = 1;
		nextstate = S17;
	end//S16
	
	/* for(k=0; k<NB_POS; k++) {
      p3 = rri2i3 + l_fin_sup;
	   p2 = rri1i2 + l_fin_sup;
	   p1 = rri0i1 + l_fin_sup;
	   p0 = rri0i4 + l_fin_inf;
	   cor = 0;
	   ptr_h1 = ptr_hd;
	   ptr_h2 =  ptr_hf;*/
	S17:
	begin
		if(k >= 8)
			nextstate = S40;
		else if(k<8)
		begin
			L_addOutA = rri2i3;
			L_addOutB = l_fin_sup;
			nextp3 = L_addIn[10:0];
			p3LD = 1;
			L_add2OutA = rri1i2;
			L_add2OutB = l_fin_sup;
			nextp2 = L_add2In[10:0];
			p2LD = 1;
			L_add3OutA = rri0i1;
			L_add3OutB = l_fin_sup;
			nextp1 = L_add3In[10:0];
			p1LD = 1;
			L_add4OutA = rri0i4;
			L_add4OutB = l_fin_inf;
			nextp0 = L_add4In[10:0];
			p0LD = 1;
			corReset = 1;
			nextptr_h1 = ptr_hd;
			ptr_h1LD = 1;
			nextptr_h2 =  ptr_hf;
			ptr_h2LD = 1;			
			addOutA = k;
			addOutB = 16'd1;
			nexti = addIn[3:0];
			iLD = 1;
			nextstate = S18;
		end
	end//S17
	
	//for(i=k+(Word16)1; i<NB_POS; i++ ) 
	S18:
	begin
		if(i>=8)
		begin		
			nextstate = S31;
			memReadAddr = ptr_h2;
		end
		else if(i<8)
		begin
			memReadAddr = ptr_h2;
			nextstate = S19;
		end		
	end//S18
	
	S19:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S20;
	end//S19
	
	//cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
	S20:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = temp[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memReadAddr = ptr_h2;
		nextstate = S21;
	end//S20
	
	S21:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S22;
	end//S21
	
	/*cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
     *p3 = extract_h(cor);*/
	S22:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = temp[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memReadAddr = ptr_h2;
		memWriteAddr = p3;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		nextstate = S23;
	end//S22	
	
	S23:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S24;
	end//S23
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p2 = extract_h(cor);*/
	S24:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = temp[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memReadAddr = ptr_h2;
		memWriteAddr = p2;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		nextstate = S25;
	end//S24
	
	S25:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S26;
	end//S25
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p1 = extract_h(cor);*/
	S26:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = temp[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memReadAddr = ptr_h2;
		memWriteAddr = p1;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		nextstate = S27;
	end//S26
	
	S27:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S28;
	end//S27
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p0 = extract_h(cor);*/
	S28:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = temp[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p0;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		nextstate = S29;
	end//S28
	
	/* p3 -= ldec;
      p2 -= ldec;*/
	S29:
	begin
		subOutA = p3;
		subOutB = ldec;
		nextp3 = subIn[10:0];
		p3LD = 1;
		L_subOutA = p2;
		L_subOutB = ldec;
		nextp2 = L_subIn[10:0];
		p2LD = 1;
		nextstate = S30;
	end//S29
	
	/*p1 -= ldec;
     p0 -= ldec;*/
	S30:
	begin
		subOutA = p1;
		subOutB = ldec;
		nextp1 = subIn[10:0];
		p1LD = 1;
		L_subOutA = p0;
		L_subOutB = ldec;
		nextp0 = L_subIn[10:0];
		p0LD = 1;
		addOutA = i;
		addOutB = 16'd1;
		nexti = addIn[3:0];
		iLD = 1;
		nextstate = S18;		
	end//S30
	
	S31:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S32;
	end//S31
	
	//cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
	S32:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = temp[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memReadAddr = ptr_h2;
		nextstate = S33;
	end//S32
	
	S33:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S34;
	end//S33
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p3 = extract_h(cor);*/
	S34:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = temp[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memReadAddr = ptr_h2;
		memWriteAddr = p3;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		nextstate = S35;
	end//S34
	
	S35:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S36;
	end//S35
	
	/*  cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
       *p2 = extract_h(cor);*/
	S36:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = temp[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memReadAddr = ptr_h2;
		memWriteAddr = p2;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		nextstate = S37;
	end//S36
	
	S37:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S38;
	end//S37
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p1 = extract_h(cor);*/
	S38:
	begin
		L_macOutA = memIn[15:0];
		L_macOutB = temp[15:0];
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p1;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		nextstate = S39;
	end//S38
	
	/* l_fin_sup -= NB_POS;
      l_fin_inf--;
      ptr_hf += STEP;*/
	S39:
	begin
		subOutA = l_fin_sup;
		subOutB = 16'd8;
		nextl_fin_sup = subIn;
		l_fin_supLD = 1;
		L_subOutA = l_fin_inf;
		L_subOutB = 32'd1;
		nextl_fin_inf = L_subIn[15:0];
		l_fin_infLD = 1;
		addOutA = ptr_hf;
		addOutB = 16'd5;
		nextptr_hf = addIn;
		ptr_hfLD = 1;
		L_addOutA = k;
		L_addOutB = 32'd1;
		nextk = L_addIn[3:0];
		kLD = 1;
		nextstate = S17;
	end//S39
	
	/* ptr_hd = h;
      ptr_hf = ptr_hd + 2;
		l_fin_sup = MSIZE-1;
		l_fin_inf = l_fin_sup-(Word16)1;
	*/
	S40:
	begin	   
		nextptr_hd = COR_H;
		ptr_hdLD = 1;
		nextptr_hf = 11'd962;
		ptr_hfLD = 1;
		nextl_fin_sup = 16'd63;
		l_fin_supLD = 1;
		nextl_fin_inf = 16'd62;
		l_fin_infLD = 1;
		kReset = 1;
		nextstate = S41;
	end//S40
	
	/* for(k=0; k<NB_POS; k++) {
          p4 = rri2i4 + l_fin_sup;
          p3 = rri1i3 + l_fin_sup;
          p2 = rri0i2 + l_fin_sup;
          p1 = rri1i4 + l_fin_inf;
          p0 = rri0i3 + l_fin_inf;
          cor = 0;
          ptr_h1 = ptr_hd;
          ptr_h2 =  ptr_hf;
	*/
	S41:
	begin
		if(k>=8)
		begin
			kReset = 1;
			nextstate = S64;
		end
		else if(k<8)
		begin
			addOutA = rri2i4;
			addOutB = l_fin_sup;
			nextp4 = addIn;
			p4LD = 1;
			L_addOutA = rri1i3;
			L_addOutB = l_fin_sup;
			nextp3 = L_addIn;
			p3LD = 1;
			L_add2OutA = rri0i2;
			L_add2OutB = l_fin_sup;
			nextp2 = L_add2In;
			p2LD = 1;
			L_add3OutA = rri1i4;
			L_add3OutB = l_fin_inf;
			nextp1 = L_add3In;
			p1LD = 1;
			L_add4OutA = rri0i3;
			L_add4OutB = l_fin_inf;
			nextp0 = L_add4In;
			p0LD = 1;
			corReset = 1;
			nextptr_h1 = ptr_hd;
			ptr_h1LD = 1;
		   nextptr_h2 =  ptr_hf;
			ptr_h2LD = 1;			
			nextstate = S42;
		end
	end//S41
	
	S42:
	begin
		addOutA = k;
		addOutB = 16'd1;
		nexti = addIn;
		iLD = 1;
		nextstate = S43;
	end//S42
	
	//for(i=k+(Word16)1; i<NB_POS; i++ ) {
	S43:
	begin
		if(i>=8)
		begin
			iReset = 1;
			nextstate = S57;
			memReadAddr = ptr_h2;
		end
		else if(i<8)
		begin
			memReadAddr = ptr_h2;
			nextstate = S44;
		end
	end//S43
	
	S44:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S45;
	end//S44
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p4 = extract_h(cor);
	*/
	S45:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p4;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S46;
	end//S45
	
	S46:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S47;
	end //S46
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p3 = extract_h(cor); */

	S47:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p3;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S48;
	end//S47
	
	S48:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S49;
	end//S48
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p2 = extract_h(cor); */
	S49:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p2;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S50;
	end//S49
	
	S50:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S51;
	end//S50
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p1 = extract_h(cor); */
	S51:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p1;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S52;
	end//S51
	
	S52:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S53;
	end//S52
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p0 = extract_h(cor); */
	S53:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p0;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		nextstate = S54;
	end//S53
	
	/* p4 -= ldec;
      p3 -= ldec; */
	S54:
	begin
		subOutA = p4;
		subOutB = ldec;
		nextp4 = subIn;
		p4LD = 1;
		L_subOutA = p3;
		L_subOutB = ldec;
		nextp3 = L_subIn;
		p3LD = 1;
		nextstate = S55;
	end //S54
	
	/* p2 -= ldec;
      p1 -= ldec; */
	S55:
	begin
		subOutA = p2;
		subOutB = ldec;
		nextp2 = subIn;
		p2LD = 1;
		L_subOutA = p1;
		L_subOutB = ldec;
		nextp1 = L_subIn;
		p1LD = 1;
		nextstate = S56;
	end//S55
	
	//p0 -= ldec;
	S56:
	begin
		subOutA = p0;
		subOutB = ldec;
		nextp0 = subIn;
		p0LD = 1;
		addOutA = i;
		addOutB = 16'd1;
		nexti = addIn;
		iLD = 1;
		nextstate = S43;
	end//S56
	
	S57:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S58;
	end//S57
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p4 = extract_h(cor);
	*/
	S58:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p4;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S59;
	end//S58
	
	S59:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S60;
	end//S59
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p3 = extract_h(cor);
	*/
	S60:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p3;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S61;
	end//S60
	
	S61:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S62;
	end//S61
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p2 = extract_h(cor);
	*/
	S62:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p2;
		memOut = L_macIn[31:16];
		memWriteEn = 1;		
		nextstate = S63;
	end//S62
	
	/* l_fin_sup -= NB_POS;
      l_fin_inf--;
      ptr_hf += STEP; */
	S63:
	begin
		subOutA = l_fin_sup;
		subOutB = 16'd8;
		nextl_fin_sup = subIn;
		l_fin_supLD = 1;
		L_subOutA = l_fin_inf;
		L_subOutB = 32'd1;
		nextl_fin_inf = L_subIn;
		l_fin_infLD = 1;
		addOutA = ptr_hf;
		addOutB = 16'd5;
		nextptr_hf = addIn;
		ptr_hfLD = 1;
		L_addOutA = k;
		L_addOutB = 32'd1;
		nextk = L_addIn;
		kLD = 1;
		nextstate = S41;
	end//S63
	
	/* ptr_hd = h;
		ptr_hf = ptr_hd + 3;
		l_fin_sup = MSIZE-1;
		l_fin_inf = l_fin_sup-(Word16)1; */
	S64:
	begin	   
		nextptr_hd = COR_H;
		ptr_hdLD = 1;
		nextptr_hf = 11'd963;
		ptr_hfLD = 1;
		nextl_fin_sup = 16'd63;
		l_fin_supLD = 1;
		nextl_fin_inf = 16'd62;
		l_fin_infLD = 1;
		kReset = 1;
		nextstate = S65;
	end//S64
	
	/* for(k=0; k<NB_POS; k++) {
	   p4 = rri1i4 + l_fin_sup;
	   p3 = rri0i3 + l_fin_sup;
	   p2 = rri2i4 + l_fin_inf;
	   p1 = rri1i3 + l_fin_inf;
	   p0 = rri0i2 + l_fin_inf;
	   ptr_h1 = ptr_hd;
	   ptr_h2 =  ptr_hf;
	   cor = 0; */
	S65:
	begin
		if(k>=8)
		begin
			nextstate = S86;
			kReset = 1;
		end
		
		else if(k<8)
		begin
			addOutA = rri1i4;
			addOutB = l_fin_sup;
			nextp4 = addIn;
			p4LD = 1;
			L_addOutA = rri0i3;
			L_addOutB = l_fin_sup;
			nextp3 = L_addIn;
			p3LD = 1;
			L_add2OutA = rri2i4;
			L_add2OutB = l_fin_inf;
			nextp2 = L_add2In;
			p2LD = 1;
			L_add3OutA = rri1i3;
			L_add3OutB = l_fin_inf;
			nextp1 = L_add3In;
			p1LD = 1;
			L_add4OutA = rri0i2;
			L_add4OutB = l_fin_inf;
			nextp0 = L_add4In;
			p0LD = 1;
			nextptr_h1 = ptr_hd;
			ptr_h1LD = 1;
			nextptr_h2 =  ptr_hf;
			ptr_h2LD = 1;
			corReset = 1;
			nextstate = S66;
		end
	end//S65	
	
	S66:
	begin
		addOutA = k;
		addOutB = 16'd1;
		nexti = addIn;
		iLD = 1;
		nextstate = S67;
	end //S66
	
	//for(i=k+(Word16)1; i<NB_POS; i++ ) {
	S67:
	begin
		if(i>=8)
		begin			
			iReset = 1;
			memReadAddr = ptr_h2;
			nextstate = S81;
		end
		
		else if(i<8)
		begin			
			memReadAddr = ptr_h2;
			nextstate = S68;
		end
	end//S67
	
	S68:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S69;
	end//S68
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p4 = extract_h(cor); */
	S69:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p4;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S70;
	end//S69
	
	S70:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S71;
	end//S70
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p3 = extract_h(cor);
	*/
	S71:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p3;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S72;
	end//S71
	
	S72:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S73;
	end//S72
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p2 = extract_h(cor); */
	S73:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p2;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S74;
	end//S73
	
	S74:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S75;
	end//S74
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p1 = extract_h(cor);*/
	S75:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p1;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S76;
	end//S75
	
	S76:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S77;
	end//S76
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p0 = extract_h(cor); */
	S77:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p0;
		memOut = L_macIn[31:16];
		memWriteEn = 1;		
		nextstate = S78;
	end//S77
	
	/* p4 -= ldec;
      p3 -= ldec;
	*/
	S78:
	begin
		subOutA = p4;
		subOutB = ldec;
		nextp4 = subIn;
		p4LD = 1;
		L_subOutA = p3;
		L_subOutB = ldec;
		nextp3 = L_subIn;
		p3LD = 1;
		nextstate = S79;
	end//S78
	
	/* p2 -= ldec;
      p1 -= ldec; */
	S79:
	begin
		subOutA = p2;
		subOutB = ldec;
		nextp2 = subIn;
		p2LD = 1;
		L_subOutA = p1;
		L_subOutB = ldec;
		nextp1 = L_subIn;
		p1LD = 1;
		nextstate = S80;
	end//S79
	
	// p0 -= ldec;
	S80:
	begin
		subOutA = p0;
		subOutB = ldec;
		nextp0 = subIn;
		p0LD = 1;
		addOutA = i;
		addOutB = 16'd1;
		nexti = addIn;
		iLD = 1;
		nextstate = S67;
	end//S80	
	
	S81:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S82;
	end//S81
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p4 = extract_h(cor); */
	S82:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p4;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S83;
	end//S82
	
	S83:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S84;
	end//S83
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p3 = extract_h(cor); */
	S84:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p3;
		memOut = L_macIn[31:16];
		memWriteEn = 1;		
		nextstate = S85;
	end//S84
	
	/* l_fin_sup -= NB_POS;
      l_fin_inf--;
      ptr_hf += STEP; */
	S85:
	begin
		subOutA = l_fin_sup;
		subOutB = 16'd8;
		nextl_fin_sup = subIn;
		l_fin_supLD = 1;
		L_subOutA = l_fin_inf;
		L_subOutB = 32'd1;
		nextl_fin_inf = L_subIn;
		l_fin_infLD = 1;
		addOutA = ptr_hf;
		addOutB = 16'd5;
		nextptr_hf = addIn;
		ptr_hfLD = 1;
		L_addOutA = k;
		L_addOutB = 32'd1;
		nextk = L_addIn;
		kLD = 1;
		nextstate = S65;
	end//S85
	
	/*
	  ptr_hd = h;
     ptr_hf = ptr_hd + 4;
     l_fin_sup = MSIZE-1;
     l_fin_inf = l_fin_sup-(Word16)1; */
	S86:
	begin
		nextptr_hd  = COR_H;
		ptr_hdLD = 1;
		nextptr_hf = 11'd964;
		ptr_hfLD = 1;
		nextl_fin_sup = 16'd63;
		l_fin_supLD = 1;
		nextl_fin_inf = 16'd62;
		l_fin_infLD = 1;
		kReset = 1;
		nextstate = S87;
	end//S86
	
	/*for(k=0; k<NB_POS; k++) {
		p3 = rri0i4 + l_fin_sup;
      p2 = rri2i3 + l_fin_inf;
      p1 = rri1i2 + l_fin_inf;
      p0 = rri0i1 + l_fin_inf;
      ptr_h1 = ptr_hd;
      ptr_h2 =  ptr_hf;
      cor = 0; */
	S87:
	begin	
		if(k>=8)
		begin
			done = 1;
			nextstate = INIT;
		end
		else if(k<8)
		begin
			addOutA = rri0i4;
			addOutB = l_fin_sup;
			nextp3 = addIn;
			p3LD = 1;
			L_addOutA = rri2i3;
			L_addOutB = l_fin_inf;
			nextp2 = L_addIn;
			p2LD = 1;
			L_add2OutA = rri1i2;
			L_add2OutB = l_fin_inf;
			nextp1 = L_add2In;
			p1LD = 1;
			L_add3OutA = rri0i1;
			L_add3OutB = l_fin_inf;
			nextp0 = L_add3In;
			p0LD = 1;
			nextptr_h1 = ptr_hd;
			ptr_h1LD = 1;
			nextptr_h2 =  ptr_hf;
			ptr_h2LD = 1;
			corReset = 1;
			L_add4OutA = k;
			L_add4OutB = 32'd1;
			nexti = L_add4In;
			iLD = 1;
			nextstate = S88;
		end
	end//S87
	
	//for(i=k+(Word16)1; i<NB_POS; i++ ) {
	S88:
	begin
		if(i>=8)
		begin
			iReset = 1;
			memReadAddr = ptr_h2;
			nextstate = S101;
		end
		
		else if(i<8)
		begin
			memReadAddr = ptr_h2;
			nextstate = S89;
		end
	end//S88
	
	S89:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S90;
	end//S89
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p3 = extract_h(cor); */
	S90:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p3;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S91;
	end//S90
	
	S91:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S92;
	end//S91
	
	//cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
	S92:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;		
		memReadAddr = ptr_h2;
		nextstate = S93;
	end//S92
	
	S93:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S94;
	end//S93
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p2 = extract_h(cor); */
	S94:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p2;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S95;
	end//S94
	
	S95:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S96;
	end//S95
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p1 = extract_h(cor); */
	S96:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p1;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		memReadAddr = ptr_h2;
		nextstate = S97;
	end//S96
	
	S97:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S98;
	end//S97
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p0 = extract_h(cor); */
	S98:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p0;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		nextstate = S99;
	end//S98
	
	/* p3 -= ldec;
      p2 -= ldec; */
	S99:
	begin
		subOutA = p3;
		subOutB = ldec;
		nextp3 = subIn;
		p3LD = 1;
		L_subOutA = p2;
		L_subOutB = ldec;
		nextp2 = L_subIn;
		p2LD = 1;
		nextstate = S100;
	end//S99
	
	/* p1 -= ldec;
      p0 -= ldec; */
	S100:
	begin
		subOutA = p1;
		subOutB = ldec;
		nextp1 = subIn;
		p1LD = 1;
		L_subOutA = p0;
		L_subOutB = ldec;
		nextp0 = L_subIn;
		p0LD = 1;
		addOutA = i;
		addOutB = 16'd1;
		nexti = addIn;
		iLD = 1;
		nextstate = S88;
	end//S100
	
	S101:
	begin
		nexttemp = memIn;
		tempLD = 1;
		addOutA = ptr_h2;
		addOutB = 16'd1;
		nextptr_h2 = addIn;
		ptr_h2LD = 1;
		memReadAddr = ptr_h1;
		nextstate = S102;
	end//S101
	
	/* cor = L_mac(cor, *ptr_h1, *ptr_h2); ptr_h1++; ptr_h2++;
      *p3 = extract_h(cor); */
	S102:
	begin
		L_macOutA = memIn;
		L_macOutB = temp;
		L_macOutC = cor;
		nextcor = L_macIn;
		corLD = 1;
		addOutA = ptr_h1;
		addOutB = 16'd1;
		nextptr_h1 = addIn;
		ptr_h1LD = 1;
		memWriteAddr = p3;
		memOut = L_macIn[31:16];
		memWriteEn = 1;
		nextstate = S103;
	end//S102
	
	/* l_fin_sup -= NB_POS;
      l_fin_inf--;
      ptr_hf += STEP; */
	S103:
	begin
		subOutA = l_fin_sup;
		subOutB = 16'd8;
		nextl_fin_sup = subIn;
		l_fin_supLD = 1;
		L_subOutA = l_fin_inf;
		L_subOutB = 32'd1;
		nextl_fin_inf = L_subIn;
		l_fin_infLD = 1;
		addOutA = ptr_hf;
		addOutB = 16'd5;
		nextptr_hf = addIn;
		ptr_hfLD = 1;
      L_addOutA = k;
		L_addOutB = 32'd1;
		nextk = L_addIn;
		kLD = 1;
		nextstate = S87;
	end//S103
	endcase	
end//always
endmodule
