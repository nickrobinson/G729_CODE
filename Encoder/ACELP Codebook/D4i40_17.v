	`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:20:52 03/24/2011
// Module Name:    D4i40_17.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform the C-model function "D4i40_17".
// 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module D4i40_17(clk, reset,start,addIn,L_addIn,L_negateIn,subIn,L_macIn,L_shrIn,multIn,L_multIn,L_msuIn,
					 L_subIn,shrIn,shlIn,memIn,i_subfr,addOutA,addOutB,L_addOutA,L_addOutB,L_negateOut,subOutA,
					 subOutB,L_macOutA,L_macOutB,L_macOutC,L_shrVar1Out,L_shrNumShiftOut,multOutA,multOutB,
					 L_multOutA,L_multOutB,L_msuOutA,L_msuOutB,L_msuOutC,L_subOutA,L_subOutB,shrVar1Out,shrVar2Out,
					 shlVar1Out,shlVar2Out,memReadAddr,memWriteAddr, memWriteEn,memOut,i,done);
					 
`include "paramList.v"	
 
//Inputs
input clk, reset,start;
input [15:0] addIn;
input [31:0] L_addIn;
input [31:0] L_negateIn;
input [15:0] subIn;
input [31:0] L_macIn;
input [31:0] L_shrIn;
input [15:0] multIn;
input [31:0] L_multIn;
input [31:0] L_msuIn;
input [31:0] L_subIn;
input [15:0] shrIn;
input [15:0] shlIn;
input [31:0] memIn;
input [15:0] i_subfr;

//Outputs
output reg [15:0] addOutA,addOutB;
output reg [31:0] L_addOutA,L_addOutB;
output reg [31:0] L_negateOut;
output reg [15:0] subOutA,subOutB;
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;
output reg [31:0] L_shrVar1Out;
output reg [15:0] L_shrNumShiftOut;
output reg [15:0] multOutA,multOutB;
output reg [15:0] L_multOutA,L_multOutB;
output reg [15:0] L_msuOutA,L_msuOutB;
output reg [31:0] L_msuOutC;
output reg [31:0] L_subOutA,L_subOutB;
output reg [15:0] shrVar1Out,shrVar2Out;
output reg [15:0] shlVar1Out,shlVar2Out;
output reg [11:0] memReadAddr,memWriteAddr;
output reg memWriteEn;
output reg [31:0] memOut;
output [15:0] i;
output reg done;

//internal registers
reg [7:0] state,nextstate;
reg [11:0] rri0i0,nextrri0i0;
reg rri0i0Reset,rri0i0LD;
reg [11:0] rri1i1,nextrri1i1;
reg rri1i1Reset,rri1i1LD;
reg [11:0] rri2i2,nextrri2i2;
reg rri2i2Reset,rri2i2LD;
reg [11:0] rri3i3,nextrri3i3;
reg rri3i3Reset,rri3i3LD;
reg [11:0] rri4i4,nextrri4i4;
reg rri4i4Reset,rri4i4LD;
reg [11:0] rri0i1,nextrri0i1;
reg rri0i1Reset,rri0i1LD;
reg [11:0] rri0i2,nextrri0i2;
reg rri0i2Reset,rri0i2LD;
reg [11:0] rri0i3,nextrri0i3;
reg rri0i3Reset,rri0i3LD;
reg [11:0] rri0i4,nextrri0i4;
reg rri0i4Reset,rri0i4LD;
reg [11:0] rri1i2,nextrri1i2;
reg rri1i2Reset,rri1i2LD;
reg [11:0] rri1i3,nextrri1i3;
reg rri1i3Reset,rri1i3LD;
reg [11:0] rri1i4,nextrri1i4;
reg rri1i4Reset,rri1i4LD;
reg [11:0] rri2i3,nextrri2i3;
reg rri2i3Reset,rri2i3LD;
reg [11:0] rri2i4,nextrri2i4;
reg rri2i4Reset,rri2i4LD;

reg [11:0] ptr_ri0i0,nextptr_ri0i0;
reg ptr_ri0i0Reset,ptr_ri0i0LD;
reg [11:0] ptr_ri1i1,nextptr_ri1i1;
reg ptr_ri1i1Reset,ptr_ri1i1LD;
reg [11:0] ptr_ri2i2,nextptr_ri2i2;
reg ptr_ri2i2Reset,ptr_ri2i2LD;
reg [11:0] ptr_ri3i3,nextptr_ri3i3;
reg ptr_ri3i3Reset,ptr_ri3i3LD;
reg [11:0] ptr_ri4i4,nextptr_ri4i4;
reg ptr_ri4i4Reset,ptr_ri4i4LD;
reg [11:0] ptr_ri0i1,nextptr_ri0i1;
reg ptr_ri0i1Reset,ptr_ri0i1LD;
reg [11:0] ptr_ri0i2,nextptr_ri0i2;
reg ptr_ri0i2Reset,ptr_ri0i2LD;
reg [11:0] ptr_ri0i3,nextptr_ri0i3;
reg ptr_ri0i3Reset,ptr_ri0i3LD;
reg [11:0] ptr_ri0i4,nextptr_ri0i4;
reg ptr_ri0i4Reset,ptr_ri0i4LD;
reg [11:0] ptr_ri1i2,nextptr_ri1i2;
reg ptr_ri1i2Reset,ptr_ri1i2LD;
reg [11:0] ptr_ri1i3,nextptr_ri1i3;
reg ptr_ri1i3Reset,ptr_ri1i3LD;
reg [11:0] ptr_ri1i4,nextptr_ri1i4;
reg ptr_ri1i4Reset,ptr_ri1i4LD;
reg [11:0] ptr_ri2i3,nextptr_ri2i3;
reg ptr_ri2i3Reset,ptr_ri2i3LD;
reg [11:0] ptr_ri2i4,nextptr_ri2i4;
reg ptr_ri2i4Reset,ptr_ri2i4LD;

reg [15:0] i0,nexti0;
reg i0LD,i0Reset;
reg [15:0] i1,nexti1;
reg i1LD,i1Reset;
reg [15:0] i2,nexti2;
reg i2LD,i2Reset;
reg [15:0] i3,nexti3;
reg i3LD,i3Reset;
reg [15:0] i4,nexti4;
reg i4LD,i4Reset;
reg [15:0] ip0,nextip0;
reg ip0LD,ip0Reset;
reg [15:0] ip1,nextip1;
reg ip1LD,ip1Reset;
reg [15:0] ip2,nextip2;
reg ip2LD,ip2Reset;
reg [15:0] ip3,nextip3;
reg ip3LD,ip3Reset;
reg [15:0] i,nexti;
reg iLD,iReset;
reg [15:0] j,nextj;
reg jLD,jReset;
reg [15:0] timeReg,nexttimeReg;
reg timeRegLD,timeRegReset;
reg [15:0] ps0,nextps0;
reg ps0LD,ps0Reset;
reg [15:0] ps1,nextps1;
reg ps1LD,ps1Reset;
reg [15:0] ps2,nextps2;
reg ps2LD,ps2Reset;
reg [15:0] ps3,nextps3;
reg ps3LD,ps3Reset;
reg [15:0] alp,nextalp;
reg alpLD,alpReset;
reg [15:0] alp0,nextalp0;
reg alp0LD,alp0Reset;
reg [15:0] psc,nextpsc;
reg pscLD,pscReset;
reg [15:0] ps3c,nextps3c;
reg ps3cLD, ps3cReset;
reg [15:0] alpha,nextalpha;
reg alphaLD,alphaReset;
reg [15:0] average,nextaverage;
reg averageLD,averageReset;
reg [15:0] max0,nextmax0;
reg max0LD,max0Reset;
reg [15:0] max1,nextmax1;
reg max1LD,max1Reset;
reg [15:0] max2,nextmax2;
reg max2LD,max2Reset;
reg [15:0] thres,nextthres;
reg thresLD,thresReset;
reg [31:0] alp1,nextalp1;
reg alp1LD, alp1Reset;
reg [31:0] alp2,nextalp2;
reg alp2LD,alp2Reset;
reg [31:0] alp3,nextalp3;
reg alp3LD,alp3Reset;
reg [31:0] L32,nextL32;
reg L32LD,L32Reset;
reg [31:0] L_temp,nextL_temp;
reg L_tempLD,L_tempReset;
reg [15:0] i_subfrReg,nexti_subfrReg;
reg i_subfrRegLD,i_subfrRegReset;
reg [31:0] temp,nexttemp;
reg tempLD,tempReset;

//state parameters
parameter INIT = 8'd0;
parameter S1 = 8'd1;
parameter S2 = 8'd2;
parameter S3 = 8'd3;
parameter S4 = 8'd4;
parameter S5 = 8'd5;
parameter S6 = 8'd6;
parameter S7 = 8'd7;
parameter S8 = 8'd8;
parameter S9 = 8'd9;
parameter S10 = 8'd10;
parameter S11 = 8'd11;
parameter S12 = 8'd12;
parameter S13 = 8'd13;
parameter S14 = 8'd14;
parameter S15 = 8'd15;
parameter S16 = 8'd16;
parameter S17 = 8'd17;
parameter S18 = 8'd18;
parameter S19 = 8'd19;
parameter S20 = 8'd20;
parameter S21 = 8'd21;
parameter S22 = 8'd22;
parameter S23 = 8'd23;
parameter S24 = 8'd24;
parameter S25 = 8'd25;
parameter S26 = 8'd26;
parameter S27 = 8'd27;
parameter S28 = 8'd28;
parameter S29 = 8'd29;
parameter S30 = 8'd30;
parameter S31 = 8'd31;
parameter S32 = 8'd32;
parameter S33 = 8'd33;
parameter S34 = 8'd34;
parameter S35 = 8'd35;
parameter S36 = 8'd36;
parameter S37 = 8'd37;
parameter S38 = 8'd38;
parameter S39 = 8'd39;
parameter S40 = 8'd40;
parameter S41 = 8'd41;
parameter S42 = 8'd42;
parameter S43 = 8'd43;
parameter S44 = 8'd44;
parameter S45 = 8'd45;
parameter S46 = 8'd46;
parameter S47 = 8'd47;
parameter S48 = 8'd48;
parameter S49 = 8'd49;
parameter S50 = 8'd50;
parameter S51 = 8'd51;
parameter S52 = 8'd52;
parameter S53 = 8'd53;
parameter S54 = 8'd54;
parameter S55 = 8'd55;
parameter S56 = 8'd56;
parameter S57 = 8'd57;
parameter S58 = 8'd58;
parameter S59 = 8'd59;
parameter S60 = 8'd60;
parameter S61 = 8'd61;
parameter S62 = 8'd62;
parameter S63 = 8'd63;
parameter S64 = 8'd64;
parameter S65 = 8'd65;
parameter S66 = 8'd66;
parameter S67 = 8'd67;
parameter S68 = 8'd68;
parameter S69 = 8'd69;
parameter S70 = 8'd70;
parameter S71 = 8'd71;
parameter S72 = 8'd72;
parameter S73 = 8'd73;
parameter S74 = 8'd74;
parameter S75 = 8'd75;
parameter S76 = 8'd76;
parameter S77 = 8'd77;
parameter S78 = 8'd78;
parameter S79 = 8'd79;
parameter S80 = 8'd80;
parameter S81 = 8'd81;
parameter S82 = 8'd82;
parameter S83 = 8'd83;
parameter S84 = 8'd84;
parameter S85 = 8'd85;
parameter S86 = 8'd86;
parameter S87 = 8'd87;
parameter S88 = 8'd88;
parameter S89 = 8'd89;
parameter S90 = 8'd90;
parameter S91 = 8'd91;
parameter S92 = 8'd92;
parameter S93 = 8'd93;
parameter S94 = 8'd94;
parameter S95 = 8'd95;
parameter S96 = 8'd96;
parameter S97 = 8'd97;
parameter S98 = 8'd98;
parameter S99 = 8'd99;
parameter S100 = 8'd100;
parameter S101 = 8'd101;
parameter S102 = 8'd102;
parameter S103 = 8'd103;
parameter S104 = 8'd104;
parameter S105 = 8'd105;
parameter S106 = 8'd106;
parameter S107 = 8'd107;
parameter S108 = 8'd108;
parameter S109 = 8'd109;
parameter S110 = 8'd110;
parameter S111 = 8'd111;
parameter S112 = 8'd112;
parameter S113 = 8'd113;
parameter S114 = 8'd114;
parameter S115 = 8'd115;
parameter S116 = 8'd116;
parameter S117 = 8'd117;
parameter S118 = 8'd118;
parameter S119 = 8'd119;
parameter S120 = 8'd120;
parameter S121 = 8'd121;
parameter S122 = 8'd122;
parameter S123 = 8'd123;
parameter S124 = 8'd124;
parameter S125 = 8'd125;
parameter S126 = 8'd126;
parameter S127 = 8'd127;
parameter S128 = 8'd128;
parameter S129 = 8'd129;
parameter S130 = 8'd130;
parameter S131 = 8'd131;
parameter S132 = 8'd132;
parameter S133 = 8'd133;
parameter S134 = 8'd134;
parameter S135 = 8'd135;
parameter S136 = 8'd136;
parameter S137 = 8'd137;
parameter S138 = 8'd138;
parameter S139 = 8'd139;
parameter S140 = 8'd140;
parameter S141 = 8'd141;
parameter S142 = 8'd142;
parameter S143 = 8'd143;
parameter S144 = 8'd144;
parameter S145 = 8'd145;
parameter S146 = 8'd146;
parameter S147 = 8'd147;
parameter S148 = 8'd148;
parameter S149 = 8'd149;
parameter S150 = 8'd150;
parameter S151 = 8'd151;
parameter S152 = 8'd152;
parameter S153 = 8'd153;
parameter S154 = 8'd154;
parameter S155 = 8'd155;
parameter S156 = 8'd156;
parameter S157 = 8'd157;
parameter S158 = 8'd158;
parameter S159 = 8'd159;
parameter S160 = 8'd160;

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
		ptr_ri0i0 <= 0;
	else if(ptr_ri0i0Reset)
		ptr_ri0i0 <= 0;
	else if(ptr_ri0i0LD)
		ptr_ri0i0 <= nextptr_ri0i0;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri1i1 <= 0;
	else if(ptr_ri1i1Reset)
		ptr_ri1i1 <= 0;
	else if(ptr_ri1i1LD)
		ptr_ri1i1 <= nextptr_ri1i1;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri2i2 <= 0;
	else if(ptr_ri2i2Reset)
		ptr_ri2i2 <= 0;
	else if(ptr_ri2i2LD)
		ptr_ri2i2 <= nextptr_ri2i2;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri3i3 <= 0;
	else if(ptr_ri3i3Reset)
		ptr_ri3i3 <= 0;
	else if(ptr_ri3i3LD)
		ptr_ri3i3 <= nextptr_ri3i3;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri4i4 <= 0;
	else if(ptr_ri4i4Reset)
		ptr_ri4i4 <= 0;
	else if(ptr_ri4i4LD)
		ptr_ri4i4 <= nextptr_ri4i4;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri0i1 <= 0;
	else if(ptr_ri0i1Reset)
		ptr_ri0i1 <= 0;
	else if(ptr_ri0i1LD)
		ptr_ri0i1 <= nextptr_ri0i1;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri0i2 <= 0;
	else if(ptr_ri0i2Reset)
		ptr_ri0i2 <= 0;
	else if(ptr_ri0i2LD)
		ptr_ri0i2 <= nextptr_ri0i2;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri0i3 <= 0;
	else if(ptr_ri0i3Reset)
		ptr_ri0i3 <= 0;
	else if(ptr_ri0i3LD)
		ptr_ri0i3 <= nextptr_ri0i3;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri0i4 <= 0;
	else if(ptr_ri0i4Reset)
		ptr_ri0i4 <= 0;
	else if(ptr_ri0i4LD)
		ptr_ri0i4 <= nextptr_ri0i4;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri1i2 <= 0;
	else if(ptr_ri1i2Reset)
		ptr_ri1i2 <= 0;
	else if(ptr_ri1i2LD)
		ptr_ri1i2 <= nextptr_ri1i2;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri1i3 <= 0;
	else if(ptr_ri1i3Reset)
		ptr_ri1i3 <= 0;
	else if(ptr_ri1i3LD)
		ptr_ri1i3 <= nextptr_ri1i3;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri1i4 <= 0;
	else if(ptr_ri1i4Reset)
		ptr_ri1i4 <= 0;
	else if(ptr_ri1i4LD)
		ptr_ri1i4 <= nextptr_ri1i4;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri2i3 <= 0;
	else if(ptr_ri2i3Reset)
		ptr_ri2i3 <= 0;
	else if(ptr_ri2i3LD)
		ptr_ri2i3 <= nextptr_ri2i3;
end

always @(posedge clk)
begin
	if(reset)
		ptr_ri2i4 <= 0;
	else if(ptr_ri2i4Reset)
		ptr_ri2i4 <= 0;
	else if(ptr_ri2i4LD)
		ptr_ri2i4 <= nextptr_ri2i4;
end

always @(posedge clk)
begin
	if(reset)
		i0 <= 0;
	else if(i0Reset)
		i0 <= 0;
	else if(i0LD)
		i0 <= nexti0;
end

always @(posedge clk)
begin
	if(reset)
		i1 <= 0;
	else if(i1Reset)
		i1 <= 0;
	else if(i1LD)
		i1 <= nexti1;
end

always @(posedge clk)
begin
	if(reset)
		i2 <= 0;
	else if(i2Reset)
		i2 <= 0;
	else if(i2LD)
		i2 <= nexti2;
end

always @(posedge clk)
begin
	if(reset)
		i3 <= 0;
	else if(i3Reset)
		i3 <= 0;
	else if(i3LD)
		i3 <= nexti3;
end

always @(posedge clk)
begin
	if(reset)
		i4 <= 0;
	else if(i4Reset)
		i4 <= 0;
	else if(i4LD)
		i4 <= nexti4;
end

always @(posedge clk)
begin
	if(reset)
		ip0 <= 0;
	else if(ip0Reset)
		ip0 <= 0;
	else if(ip0LD)
		ip0 <= nextip0;
end

always @(posedge clk)
begin
	if(reset)
		ip1 <= 0;
	else if(ip1Reset)
		ip1 <= 0;
	else if(ip1LD)
		ip1 <= nextip1;
end

always @(posedge clk)
begin
	if(reset)
		ip2 <= 0;
	else if(ip2Reset)
		ip2 <= 0;
	else if(ip2LD)
		ip2 <= nextip2;
end

always @(posedge clk)
begin
	if(reset)
		ip3 <= 0;
	else if(ip3Reset)
		ip3 <= 0;
	else if(ip3LD)
		ip3 <= nextip3;
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
		timeReg <= 0;
	else if(timeRegReset)
		timeReg <= 0;
	else if(timeRegLD)
		timeReg <= nexttimeReg;
end

always @(posedge clk)
begin
	if(reset)
		ps0 <= 0;
	else if(ps0Reset)
		ps0 <= 0;
	else if(ps0LD)
		ps0 <= nextps0;
end

always @(posedge clk)
begin
	if(reset)
		ps1 <= 0;
	else if(ps1Reset)
		ps1 <= 0;
	else if(ps1LD)
		ps1 <= nextps1;
end

always @(posedge clk)
begin
	if(reset)
		ps2 <= 0;
	else if(ps2Reset)
		ps2 <= 0;
	else if(ps2LD)
		ps2 <= nextps2;
end

always @(posedge clk)
begin
	if(reset)
		ps3 <= 0;
	else if(ps3Reset)
		ps3 <= 0;
	else if(ps3LD)
		ps3 <= nextps3;
end

always @(posedge clk)
begin
	if(reset)
		psc <= 0;
	else if(pscReset)
		psc <= 0;
	else if(pscLD)
		psc <= nextpsc;
end

always @(posedge clk)
begin
	if(reset)
		ps3c <= 0;
	else if(ps3cReset)
		ps3c <= 0;
	else if(ps3cLD)
		ps3c <= nextps3c;
end

always @(posedge clk)
begin
	if(reset)
		alp <= 0;
	else if(alpReset)
		alp <= 0;
	else if(alpLD)
		alp <= nextalp;
end

always @(posedge clk)
begin
	if(reset)
		alp0 <= 0;
	else if(alp0Reset)
		alp0 <= 0;
	else if(alp0LD)
		alp0 <= nextalp0;
end

always @(posedge clk)
begin
	if(reset)
		alp1 <= 0;
	else if(alp1Reset)
		alp1 <= 0;
	else if(alp1LD)
		alp1 <= nextalp1;
end

always @(posedge clk)
begin
	if(reset)
		alp2 <= 0;
	else if(alp2Reset)
		alp2 <= 0;
	else if(alp2LD)
		alp2 <= nextalp2;
end

always @(posedge clk)
begin
	if(reset)
		alp3 <= 0;
	else if(alp3Reset)
		alp3 <= 0;
	else if(alp3LD)
		alp3 <= nextalp3;
end

always @(posedge clk)
begin
	if(reset)
		alpha <= 0;
	else if(alphaReset)
		alpha <= 0;
	else if(alphaLD)
		alpha <= nextalpha;
end

always @(posedge clk)
begin
	if(reset)
		max0 <= 0;
	else if(max0Reset)
		max0 <= 0;
	else if(max0LD)
		max0 <= nextmax0;
end

always @(posedge clk)
begin
	if(reset)
		max1 <= 0;
	else if(max1Reset)
		max1 <= 0;
	else if(max1LD)
		max1 <= nextmax1;
end

always @(posedge clk)
begin
	if(reset)
		max2 <= 0;
	else if(max2Reset)
		max2 <= 0;
	else if(max2LD)
		max2 <= nextmax2;
end

always @(posedge clk)
begin
	if(reset)
		average <= 0;
	else if(averageReset)
		average <= 0;
	else if(averageLD)
		average <= nextaverage;
end

always @(posedge clk)
begin
	if(reset)
		thres <= 0;
	else if(thresReset)
		thres <= 0;
	else if(thresLD)
		thres <= nextthres;
end

always @(posedge clk)
begin
	if(reset)
		L32 <= 0;
	else if(L32Reset)
		L32 <= 0;
	else if(L32LD)
		L32 <= nextL32;
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
		i_subfrReg <= 0;
	else if(i_subfrRegReset)
		i_subfrReg <= 0;
	else if(i_subfrRegLD)
		i_subfrReg <= nexti_subfrReg;
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
	nextptr_ri0i0 = ptr_ri0i0;
	nextptr_ri1i1 = ptr_ri1i1;
	nextptr_ri2i2 = ptr_ri2i2;
	nextptr_ri3i3 = ptr_ri3i3;
	nextptr_ri4i4 = ptr_ri4i4;
	nextptr_ri0i1 = ptr_ri0i1;
	nextptr_ri0i2 = ptr_ri0i2;
	nextptr_ri0i3 = ptr_ri0i3;
	nextptr_ri0i4 = ptr_ri0i4;
	nextptr_ri1i2 = ptr_ri1i2;
	nextptr_ri1i3 = ptr_ri1i3;
	nextptr_ri1i4 = ptr_ri1i4;
	nextptr_ri2i3 = ptr_ri2i3;
	nextptr_ri2i4 = ptr_ri2i4;
	nexti0 = i0;
	nexti1 = i1;
	nexti2 = i2;
	nexti3 = i3;
	nexti4 = i4;
	nextip0 = ip0;
	nextip1 = ip1;
	nextip2 = ip2;
	nextip3 = ip3;
	nextj = j;
	nexti = i;
	nexttimeReg = timeReg;
	nextps0 = ps0;
	nextps1 = ps1;
	nextps2 = ps2;
	nextps3 = ps3;
	nextalp = alp;
	nextalp0 = alp0;
	nextpsc = psc;
	nextps3c = ps3c;
	nextalpha = alpha;
	nextaverage = average;
	nextmax0 = max0;
	nextmax1 = max1;
	nextmax2 = max2;
	nextthres = thres;
	nextalp1 = alp1;
	nextalp2 = alp2;
	nextalp3 = alp3;
	nextL32 = L32;
	nextL_temp = L_temp;	
	nexti_subfrReg = i_subfrReg;
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
	ptr_ri0i0Reset = 0;
	ptr_ri1i1Reset = 0;
	ptr_ri2i2Reset = 0;
	ptr_ri3i3Reset = 0;
	ptr_ri4i4Reset = 0;
	ptr_ri0i1Reset = 0;
	ptr_ri0i2Reset = 0;
	ptr_ri0i3Reset = 0;
	ptr_ri0i4Reset = 0;
	ptr_ri1i2Reset = 0;
	ptr_ri1i3Reset = 0;
	ptr_ri1i4Reset = 0;
	ptr_ri2i3Reset = 0;
	ptr_ri2i4Reset = 0;	
	i_subfrRegReset = 0;
	pscReset = 0;
	ps3cReset = 0;
	alphaReset = 0;
	averageReset = 0;
	max0Reset = 0;
	max1Reset = 0;
	max2Reset = 0;
	thresReset = 0;
	alp1Reset = 0;
	alp2Reset = 0;
	alp3Reset = 0;
	L32Reset = 0;
	L_tempReset = 0;
	i0Reset = 0;
	i1Reset = 0;
	i2Reset = 0;
	i3Reset = 0;
	i4Reset = 0;
	ip0Reset = 0;
	ip1Reset  = 0;
	ip2Reset = 0;
	ip3Reset = 0;
	iReset = 0;
	jReset = 0;
	timeRegReset = 0;
	ps0Reset = 0;
	ps1Reset = 0;
	ps2Reset = 0;
	ps3Reset = 0;
	alpReset = 0;
	alp0Reset = 0;
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
	ptr_ri0i0LD = 0;
	ptr_ri1i1LD = 0;
	ptr_ri2i2LD = 0;
	ptr_ri3i3LD = 0;
	ptr_ri4i4LD = 0;
	ptr_ri0i1LD = 0;
	ptr_ri0i2LD = 0;
	ptr_ri0i3LD = 0;
	ptr_ri0i4LD = 0;
	ptr_ri1i2LD = 0;
	ptr_ri1i3LD = 0;
	ptr_ri1i4LD = 0;
	ptr_ri2i3LD = 0;
	ptr_ri2i4LD = 0;
	i0LD = 0;
	i1LD = 0;
	i2LD = 0;
	i3LD = 0;
	i4LD = 0;
	ip0LD = 0;
	ip1LD = 0;
	ip2LD = 0;
	ip3LD = 0;
	iLD = 0;
	jLD = 0;
	timeRegLD = 0;
	ps0LD = 0;
	ps1LD = 0;
	ps2LD = 0;
	ps3LD = 0;
	alpLD = 0;
	alp0LD = 0;
	pscLD = 0;
	ps3cLD = 0;
	alphaLD = 0;
	averageLD = 0;
	max0LD = 0;
	max1LD = 0;
	max2LD = 0;
	thresLD = 0;
	alp1LD = 0;
	alp2LD = 0;
	alp3LD = 0;
	L32LD = 0;
	L_tempLD = 0;
	i_subfrRegLD = 0;
	tempLD = 0;
	addOutA = 0;
	addOutB = 0;
	L_addOutA = 0;
	L_addOutB = 0;
	L_negateOut = 0;
	subOutA = 0;
	subOutB = 0;
	L_macOutA = 0;
	L_macOutB = 0;
	L_macOutC = 0;
	L_shrVar1Out = 0;
	L_shrNumShiftOut = 0;
	multOutA = 0;
	multOutB = 0;
	L_multOutA = 0;
	L_multOutB = 0;
	L_msuOutA = 0;
	L_msuOutB = 0;
	L_msuOutC = 0;
	L_subOutA = 0;
	L_subOutB = 0;
	shrVar1Out = 0;
	shrVar2Out = 0;
	shlVar1Out = 0;
	shlVar2Out = 0;
	memReadAddr = 0;
	memWriteAddr = 0;
	memWriteEn = 0;
	memOut = 0;
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
			ptr_ri0i0Reset = 1;
			ptr_ri1i1Reset = 1;
			ptr_ri2i2Reset = 1;
			ptr_ri3i3Reset = 1;
			ptr_ri4i4Reset = 1;
			ptr_ri0i1Reset = 1;
			ptr_ri0i2Reset = 1;
			ptr_ri0i3Reset = 1;
			ptr_ri0i4Reset = 1;
			ptr_ri1i2Reset = 1;
			ptr_ri1i3Reset = 1;
			ptr_ri1i4Reset = 1;
			ptr_ri2i3Reset = 1;
			ptr_ri2i4Reset = 1;	
			pscReset = 1;
			ps3cReset = 1;
			alphaReset = 1;
			averageReset = 1;
			max0Reset = 1;
			max1Reset = 1;
			max2Reset = 1;
			thresReset = 1;
			alp1Reset = 1;
			alp2Reset = 1;
			alp3Reset = 1;
			L32Reset = 1;
			L_tempReset = 1;
			i0Reset = 1;
			i1Reset = 1;
			i2Reset = 1;
			i3Reset = 1;
			i4Reset = 1;
			ip0Reset = 1;
			ip1Reset  = 1;
			ip2Reset = 1;
			ip3Reset = 1;
			iReset = 1;
			jReset = 1;
			timeRegReset = 1;
			ps0Reset = 1;
			ps1Reset = 1;
			ps2Reset = 1;
			ps3Reset = 1;
			alpReset = 1;
			alp0Reset = 1;
			tempReset = 1;
			nexti_subfrReg = i_subfr;
			i_subfrRegLD = 1;
			nextstate = S1;
		end
		end//INIT
		
	/* rri0i0 = rr;
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
		if (i_subfr == 0){ extra = 30; } */
		S1:
		begin
			nextrri0i0 = ACELP_RR;
			rri0i0LD = 1;
			nextrri1i1 = {ACELP_RR[11:4],4'd8};
			rri1i1LD = 1;
			nextrri2i2 = {ACELP_RR[11:5],5'd16};
			rri2i2LD = 1;
			nextrri3i3 = {ACELP_RR[11:5],5'd24};
			rri3i3LD = 1;
			nextrri4i4 = {ACELP_RR[11:6],6'd32};
			rri4i4LD = 1;
			nextrri0i1 = {ACELP_RR[11:6],6'd40};
			rri0i1LD = 1;			
			nextrri0i2 = {ACELP_RR[11:7],7'd104};
			rri0i2LD = 1;
			nextrri0i3 = {ACELP_RR[11:8],8'd168};
			rri0i3LD = 1;		
			nextrri0i4 = {ACELP_RR[11:8],8'd232};
			rri0i4LD = 1;		
			nextrri1i2 = {ACELP_RR[11:9],9'd296};
			rri1i2LD = 1;
			nextrri1i3 = {ACELP_RR[11:9],9'd360};
			rri1i3LD = 1;
			nextrri1i4 = {ACELP_RR[11:9],9'd424};
			rri1i4LD = 1;
			nextrri2i3 = {ACELP_RR[11:9],9'd488}; 
			rri2i3LD = 1;
			nextrri2i4 = {ACELP_RR[10],10'd552}; 
			rri2i4LD = 1;
			if(i_subfrReg == 0)
			begin
				memWriteAddr = ACELP_EXTRA;
				memOut = 31'd30;
				memWriteEn = 1;
			end
			iReset = 1;
			nextstate = S2;
		end//S1
		
		//for (i=0; i<L_SUBFR; i++)
		S2:
		begin
			if(i>=40)
			begin
				nextstate = S5;
				memReadAddr = {ACELP_DN[11:1],1'd0};
			end
			else if(i<40)
			begin
				memReadAddr = {ACELP_DN[11:6],i[5:0]};
				nextstate = S3;
			end
		end//S2
		
		/* if( Dn[i] >= 0)
        {
          p_sign[i] = 0x7fff;
        }
        else
        {
          p_sign[i] = (Word16)0x8000;*/
		S3:
		begin
			if(memIn[15] == 0)
			begin
				memWriteAddr = {D17_P_SIGN[11:6],i[5:0]};
				memOut = 32'h7fff;
				memWriteEn = 1;
				addOutA = i;
				addOutB = 16'd1;
				nexti = addIn;
				iLD = 1;
				nextstate = S2;
			end
			
			else if(memIn[15] == 1)
			begin
				memWriteAddr = {D17_P_SIGN[11:6],i[5:0]};
				memOut = 32'h8000;
				memWriteEn = 1;
				nextstate = S4; 
				nexttemp = memIn;
				tempLD = 1;
			end
		end//S3
		// Dn[i] = negate(Dn[i]);}
		S4:
		begin
			L_negateOut = temp[15:0];
			memWriteAddr = {ACELP_DN[11:6],i[5:0]};
			memOut = L_negateIn[15:0];
			memWriteEn = 1;
			addOutA = i;
			addOutB = 16'd1;
			nexti = addIn;
			iLD = 1;
			nextstate = S2;
		end//S4
		
		//max0 = Dn[0]; 
		S5:
		begin
			nextmax0 = memIn[15:0];
			max0LD = 1;
			memReadAddr = {ACELP_DN[11:1],1'd1};
			nextstate = S6;
		end//S5
		
		//max1 = Dn[1];
		S6:
		begin
			nextmax1 = memIn[15:0];
			max1LD = 1;
			memReadAddr = {ACELP_DN[11:2],2'd2};
			nextstate = S7;
		end//S6
		
		//max2 = Dn[2];
		S7:
		begin
			nextmax2 = memIn[15:0];
			max2LD = 1;
			nexti = 16'd5;
			iLD = 1;
			nextstate = S8;
		end//S7
		
		//for (i = 5; i < L_SUBFR; i+=STEP){
		S8:
		begin
			if(i>=40)
				nextstate = S12;
			else if(i<40)
			begin
				memReadAddr = {ACELP_DN[11:6],i[5:0]};
				nextstate = S9;
			end
		end//S8
		
		//if (sub(Dn[i]  , max0) > 0){ max0 = Dn[i];   }
		S9:
		begin
			subOutA = memIn[15:0];
			subOutB = max0;
			if(subIn[15] == 0 && subIn != 0)
			begin
				nextmax0 = memIn[15:0];
				max0LD = 1;
			end
			addOutA = i;
			addOutB = 16'd1;
			memReadAddr = {ACELP_DN[11:6],addIn[5:0]};
			nextstate = S10;
		end//S9
		
		//if (sub(Dn[i+1], max1) > 0){ max1 = Dn[i+1]; }
		S10:
		begin
			subOutA = memIn[15:0];
			subOutB = max1;
			if(subIn[15] == 0 && subIn != 0)
			begin
				nextmax1 = memIn[15:0];
				max1LD = 1;
			end
			addOutA = i;
			addOutB = 16'd2;
			memReadAddr = {ACELP_DN[11:6],addIn[5:0]};
			nextstate = S11;
		end//S10
		
		//if (sub(Dn[i+2], max2) > 0){ max2 = Dn[i+2]; }
		S11:
		begin
			subOutA = memIn[15:0];
			subOutB = max2;
			if(subIn[15] == 0 && subIn != 0)
			begin
				nextmax2 = memIn[15:0];
				max2LD = 1;
			end	
			addOutA = i;
			addOutB = 16'd5;
			nexti = addIn;
			iLD = 1;
			nextstate = S8;
		end//S11
		
		/* max0 = add(max0, max1);
		   max0 = add(max0, max2);
			L32 = 0; */		
		S12:
		begin
			addOutA = max0;
			addOutB = max1;
			L_addOutA = {16'd0,addIn[15:0]};
			L_addOutB = {16'd0,max2[15:0]};
			nextmax0 = L_addIn[15:0];
			max0LD = 1;
			L32Reset = 1;
			iReset = 1;
			nextstate = S13;
		end//S12
		
		//for (i = 0; i < L_SUBFR; i+=STEP)
		S13:
		begin
		 if(i>=40)
			nextstate = S17;
		 else if(i<40)
		 begin
			memReadAddr = {ACELP_DN[11:6],i[5:0]};
			nextstate = S14;
		 end
		end//S13
		
		//L32 = L_mac(L32, Dn[i], 1);
		S14:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd1;
			L_macOutC = L32;
			nextL32 = L_macIn;
			L32LD = 1;
			addOutA = i;
			addOutB = 16'd1;
			memReadAddr = {ACELP_DN[11:6],addIn[5:0]};
			nextstate = S15;
		end//S14
		
		//L32 = L_mac(L32, Dn[i+1], 1);
		S15:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd1;
			L_macOutC = L32;
			nextL32 = L_macIn;
			L32LD = 1;
			addOutA = i;
			addOutB = 16'd2;
			memReadAddr = {ACELP_DN[11:6],addIn[5:0]};
			nextstate = S16;
		end//S15
		
		//L32 = L_mac(L32, Dn[i+2], 1);
		S16:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd1;
			L_macOutC = L32;
			nextL32 = L_macIn;
			L32LD = 1;
			addOutA = i;
			addOutB = 16'd5;
			nexti = addIn;
			iLD = 1;
			nextstate = S13;
		end//S16
		
		/* average =extract_l( L_shr(L32, 4));*/         
		S17:
		begin
			L_shrVar1Out = L32;
			L_shrNumShiftOut = 16'd4;
			nextaverage = L_shrIn[15:0];
			averageLD = 1;
			nextstate = S18;
		end//S17
		
		//thres = sub(max0, average);         
		S18:
		begin
			subOutA = max0;
			subOutB = average;
			nextthres = subIn;
			thresLD = 1;
			nextstate = S19;
		end//S18
		
		//thres = mult(thres, THRESHFCB);
         
		S19:
		begin
			multOutA = thres;
			multOutB = 16'd13107;
			nextthres = multIn;
			thresLD = 1;
			nextstate = S20;
		end//S19
		
		/*thres = add(thres, average); */
		S20:
		begin
			addOutA = thres;
			addOutB = average;
			nextthres = addIn;
			thresLD = 1;
			nextstate = S21;
		end//S20
		
		/* ptr_ri0i1 = rri0i1;
			ptr_ri0i2 = rri0i2;
         ptr_ri0i3 = rri0i3;
			ptr_ri0i4 = rri0i4; */
		S21:
		begin
			nextptr_ri0i1 = rri0i1;
			ptr_ri0i1LD = 1;
			nextptr_ri0i2 = rri0i2;
			ptr_ri0i2LD = 1;
         nextptr_ri0i3 = rri0i3;
			ptr_ri0i3LD = 1;
			nextptr_ri0i4 = rri0i4;
			ptr_ri0i4LD = 1;
			i0Reset = 1;
			nextstate = S22;
		end//S21 
		
		//for(i0=0; i0<L_SUBFR; i0+=STEP)
		S22:
		begin
			if(i0>=40)
				nextstate = S38;
			else if(i0<40)
			begin				
				nextstate = S23;
				nexti1 = 1;
				i1LD = 1;
			end
		end//S22
		
		//for(i1=1; i1<L_SUBFR; i1+=STEP)
		S23:
		begin
			if(i1>=40)
				nextstate = S37;
			else if(i1<40)
			begin
				memReadAddr = {D17_P_SIGN[11:6],i0[5:0]};
				nextstate = S24;
			end
		end//S23
		
		S24:
		begin
			nexttemp = memIn[15:0];
			tempLD = 1;
			memReadAddr = {D17_P_SIGN[11:6],i1[5:0]};
			nextstate = S25;
		end//S24
		
		// mult(p_sign[i0], p_sign[i1])
		S25:
		begin
			multOutA = temp[15:0];
			multOutB = memIn[15:0];
			nexttemp = multIn;
			tempLD = 1;
			memReadAddr = ptr_ri0i1;
			nextstate = S26;
		end//S25
		
		//*ptr_ri0i1 = mult(*ptr_ri0i1, mult(p_sign[i0], p_sign[i1]));
		S26:
		begin
			multOutA = memIn[15:0];
			multOutB = temp[15:0];
			memOut = multIn[15:0];
			memWriteAddr = ptr_ri0i1;
			memWriteEn = 1;
			memReadAddr = {D17_P_SIGN[11:6],i0[5:0]};
			nextstate = S27;
		end//S26
		
		// ptr_ri0i1++;
		S27:
		begin
			addOutA = ptr_ri0i1;
			addOutB = 16'd1;
			nextptr_ri0i1 = addIn[11:0];
			ptr_ri0i1LD = 1;
			nexttemp = memIn[15:0];
			tempLD = 1;
			L_addOutA = i1;
			L_addOutB = 32'd1;
			memReadAddr = {D17_P_SIGN[11:6],L_addIn[5:0]};
			nextstate = S28;
		end//S27
		
		//mult(p_sign[i0], p_sign[i1+1])
		S28:
		begin
			multOutA = temp[15:0];
			multOutB = memIn[15:0];
			nexttemp = multIn[15:0];
			tempLD = 1;
			memReadAddr = ptr_ri0i2;
			nextstate = S29;
		end//S28
		
		//*ptr_ri0i2 = mult(*ptr_ri0i2, mult(p_sign[i0], p_sign[i1+1]));
		S29:
		begin
			multOutA = memIn[15:0];
			multOutB = temp[15:0];
			memOut = multIn[15:0];
			memWriteAddr = ptr_ri0i2;
			memWriteEn = 1;
			memReadAddr = {D17_P_SIGN[11:6],i0[5:0]};
			nextstate = S30;
		end//S29
		
		// ptr_ri0i2++;
		S30:
		begin
			addOutA = ptr_ri0i2;
			addOutB = 16'd1;
			nextptr_ri0i2 = addIn[11:0];
			ptr_ri0i2LD = 1;
			nexttemp = memIn[15:0];
			tempLD = 1;
			L_addOutA = i1;
			L_addOutB = 32'd2;
			memReadAddr = {D17_P_SIGN[11:6],L_addIn[5:0]};
			nextstate = S31;
		end//S30
		
		//*mult(p_sign[i0], p_sign[i1+2]));
		S31:
		begin
			multOutA = temp[15:0];
			multOutB = memIn[15:0];
			nexttemp = multIn[15:0];
			tempLD = 1;			
			memReadAddr = ptr_ri0i3;
			nextstate = S32;
		end//S31
		
		//*ptr_ri0i3 = mult(*ptr_ri0i3, mult(p_sign[i0], p_sign[i1+2]));
		S32:
		begin
			multOutA = memIn[15:0];
			multOutB = temp[15:0];
			memOut = multIn[15:0];
			memWriteAddr = ptr_ri0i3;
			memWriteEn = 1;
			memReadAddr = {D17_P_SIGN[11:6],i0[5:0]};
			nextstate = S33;
		end//S32
		
		//ptr_ri0i3++;
		S33:
		begin
			addOutA = ptr_ri0i3;
			addOutB = 16'd1;
			nextptr_ri0i3 = addIn[11:0];
			ptr_ri0i3LD = 1;
			nexttemp = memIn[15:0];
			tempLD = 1;
			L_addOutA = i1;
			L_addOutB = 32'd3;
			memReadAddr = {D17_P_SIGN[11:6],L_addIn[5:0]};
			nextstate = S34;
		end//S33
		
		//mult(p_sign[i0], p_sign[i1+3])
		S34:
		begin
			multOutA = temp[15:0];
			multOutB = memIn[15:0];
			nexttemp = multIn[15:0];
			tempLD = 1;			
			memReadAddr = ptr_ri0i4;
			nextstate = S35;
		end//S34
		
		// *ptr_ri0i4 = mult(*ptr_ri0i4, mult(p_sign[i0], p_sign[i1+3]));
		S35:
		begin
			multOutA = memIn[15:0];
			multOutB = temp[15:0];
			memOut = multIn[15:0];
			memWriteAddr = ptr_ri0i4;
			memWriteEn = 1;			
			nextstate = S36;
		end//S35
		
		//ptr_ri0i4++;
		S36:
		begin
			addOutA = ptr_ri0i4;
			addOutB = 16'd1;
			nextptr_ri0i4 = addIn[11:0];
			ptr_ri0i4LD = 1;
			L_addOutA = i1;
			L_addOutB = 32'd5;
			nexti1 = L_addIn;
			i1LD = 1;
			nextstate = S23;
		end//S36
		
		S37:
		begin
			addOutA = i0;
			addOutB = 16'd5;
			nexti0 = addIn;
			i0LD = 1;
			nextstate = S22;
		end//S37
		
		/* ptr_ri1i2 = rri1i2;
		   ptr_ri1i3 = rri1i3;
			ptr_ri1i4 = rri1i4; */
		S38:
		begin
			nextptr_ri1i2 = rri1i2;
			ptr_ri1i2LD = 1;
		   nextptr_ri1i3 = rri1i3;
			ptr_ri1i3LD = 1;
			nextptr_ri1i4 = rri1i4;
			ptr_ri1i4LD = 1;
			nextstate = S39;
			nexti1 = 16'd1;
			i1LD = 1;
		end//S38
		
		//for(i1=1; i1<L_SUBFR; i1+=STEP)
		S39:
		begin
			if(i1>=40)
				nextstate = S52;
			else if(i1<40)
			begin
				nexti2 = 16'd2;
				i2LD = 1;
				nextstate = S40;
			end
		end//S39
		
		//for(i2=2; i2<L_SUBFR; i2+=STEP)
		S40:
		begin
			if(i2>=40)
				nextstate = S51;
			else if(i2<40)
			begin
				memReadAddr = {D17_P_SIGN[11:6],i1[5:0]};
				nextstate = S41;
			end
		end//S40
		
		S41:
		begin
			nexttemp = memIn[15:0];
			tempLD = 1;
			memReadAddr = {D17_P_SIGN[11:6],i2[5:0]};
			nextstate = S42;
		end//S41
		
		// mult(p_sign[i1], p_sign[i2])
		S42:
		begin
			multOutA = temp[15:0];
			multOutB = memIn[15:0];
			nexttemp = multIn[15:0];
			tempLD = 1;
			memReadAddr = ptr_ri1i2;
			nextstate = S43;
		end//S42
		
		// *ptr_ri1i2 = mult(*ptr_ri1i2, mult(p_sign[i1], p_sign[i2]));
		S43:
		begin
			multOutA = memIn[15:0];
			multOutB = temp[15:0];
			memOut = multIn[15:0];
			memWriteAddr = ptr_ri1i2;
			memWriteEn = 1;
			memReadAddr = {D17_P_SIGN[11:6],i1[5:0]};
			nextstate = S44;
		end//S43
		
		//ptr_ri1i2++;
		S44:
		begin
			addOutA = ptr_ri1i2;
			addOutB = 16'd1;
			nextptr_ri1i2 = addIn;
			ptr_ri1i2LD = 1;
			nexttemp = memIn[15:0];
			tempLD = 1;
			L_addOutA = i2;
			L_addOutB = 32'd1;
			memReadAddr = {D17_P_SIGN[11:6],L_addIn[5:0]};
			nextstate = S45;
		end//S44
		
		//mult(p_sign[i1], p_sign[i2+1])
		S45:
		begin
			multOutA = temp[15:0];
			multOutB = memIn[15:0];
			nexttemp = multIn[15:0];
			tempLD = 1;
			memReadAddr = ptr_ri1i3;
			nextstate = S46;
		end//S45
		
		//*ptr_ri1i3 = mult(*ptr_ri1i3, mult(p_sign[i1], p_sign[i2+1]));
		S46:
		begin
			multOutA = memIn[15:0];
			multOutB = temp[15:0];
			memOut = multIn[15:0];
			memWriteAddr = ptr_ri1i3;
			memWriteEn = 1;
			memReadAddr = {D17_P_SIGN[11:6],i1[5:0]};
			nextstate = S47;
		end//S46
		
		//ptr_ri1i3++;
		S47:
		begin
			addOutA = ptr_ri1i3;
			addOutB = 16'd1;
			nextptr_ri1i3 = addIn;
			ptr_ri1i3LD = 1;
			nexttemp = memIn[15:0];
			tempLD = 1;
			L_addOutA = i2;
			L_addOutB = 32'd2;
			memReadAddr = {D17_P_SIGN[11:6],L_addIn[5:0]};
			nextstate = S48;
		end//S47
		
		//mult(p_sign[i1], p_sign[i2+2])
		S48:
		begin
			multOutA = temp[15:0];
			multOutB = memIn[15:0];
			nexttemp = multIn[15:0];
			tempLD = 1;
			memReadAddr = ptr_ri1i4;
			nextstate = S49;
		end//S48
		
		//*ptr_ri1i4 = mult(*ptr_ri1i4, mult(p_sign[i1], p_sign[i2+2]));
		S49:
		begin
			multOutA = memIn[15:0];
			multOutB = temp[15:0];
			memOut = multIn[15:0];
			memWriteAddr = ptr_ri1i4;
			memWriteEn = 1;
			nextstate = S50;
		end//S49
		
		//ptr_ri1i4++;
		S50:
		begin
			addOutA = ptr_ri1i4;
			addOutB = 16'd1;
			nextptr_ri1i4 = addIn;
			ptr_ri1i4LD = 1;
			L_addOutA = i2;
			L_addOutB = 32'd5;
			nexti2 = L_addIn;
			i2LD = 1;
			nextstate = S40;
		end//S50
		
		S51:
		begin
			addOutA = i1;
			addOutB = 16'd5;
			nexti1 = addIn;
			i1LD = 1;
			nextstate = S39;
		end//S51
		
	  /* ptr_ri2i3 = rri2i3;
        ptr_ri2i4 = rri2i4; */
		S52:
		begin
		  nextptr_ri2i3 = rri2i3;
		  ptr_ri2i3LD = 1;
        nextptr_ri2i4 = rri2i4;
		  ptr_ri2i4LD = 1;
		  nexti2 = 16'd2;
		  i2LD = 1;
		  nextstate = S53;
		end//S52
		
		//for(i2=2; i2<L_SUBFR; i2+=STEP)
		S53:
		begin
			if(i2>=40)
			begin
				memReadAddr = ACELP_EXTRA;
				nextstate = S63;
			end
			else if(i2<40)
			begin
				nexti3 = 3;
				i3LD = 1;
				nextstate = S54;
			end
		end//S53
		
		//for(i3=3; i3<L_SUBFR; i3+=STEP)
		S54:
		begin
			if(i3>=40)
				nextstate = S62;
			else if(i3<40)
			begin
				memReadAddr = {D17_P_SIGN[11:6],i2[5:0]};
				nextstate = S55;
			end
		end//S54
		
		S55:
		begin
			nexttemp = memIn[15:0];
			tempLD = 1;
			memReadAddr = {D17_P_SIGN[11:6],i3[5:0]};
			nextstate = S56;
		end//S55
		
		//mult(p_sign[i2], p_sign[i3])
		S56:
		begin
			multOutA = temp[15:0];
			multOutB = memIn[15:0];
			nexttemp = multIn[15:0];
			tempLD = 1;
			memReadAddr = ptr_ri2i3;
			nextstate = S57;
		end//S56
		
		//*ptr_ri2i3 = mult(*ptr_ri2i3, mult(p_sign[i2], p_sign[i3]));
		S57:
		begin
			multOutA = memIn[15:0];
			multOutB = temp[15:0];
			memOut = multIn[15:0];
			memWriteAddr = ptr_ri2i3;
			memWriteEn = 1;
			memReadAddr = {D17_P_SIGN[11:6],i2[5:0]};
			nextstate = S58;
		end//S57
		
		//ptr_ri2i3++;
		S58:
		begin
			addOutA = ptr_ri2i3;
			addOutB = 16'd1;
			nextptr_ri2i3 = addIn;
			ptr_ri2i3LD = 1;
			nexttemp = memIn[15:0];
			tempLD = 1;
			L_addOutA = i3;
			L_addOutB = 32'd1;
			memReadAddr = {D17_P_SIGN[11:6],L_addIn[5:0]};
			nextstate = S59;
		end//S58
		
		// mult(p_sign[i2], p_sign[i3+1])
		S59:
		begin
			multOutA = temp[15:0];
			multOutB = memIn[15:0];
			nexttemp = multIn[15:0];
			tempLD = 1;
			memReadAddr = ptr_ri2i4;
			nextstate = S60;
		end//S59
		
		//*ptr_ri2i4 = mult(*ptr_ri2i4, mult(p_sign[i2], p_sign[i3+1]));
		S60:
		begin
			multOutA = memIn[15:0];
			multOutB = temp[15:0];
			memOut = multIn[15:0];
			memWriteAddr = ptr_ri2i4;
			memWriteEn = 1;			
			nextstate = S61;
		end//S60
		
		//ptr_ri2i4++;
		S61:
		begin
			addOutA = ptr_ri2i4;
			addOutB = 16'd1;
			nextptr_ri2i4 = addIn;
			ptr_ri2i4LD = 1;			
			L_addOutA = i3;
			L_addOutB = 32'd5;
			nexti3 = L_addIn;
			i3LD = 1;
			nextstate = S54;
		end//S61
		
		S62:
		begin
			addOutA = i2;
			addOutB = 16'd5;
			nexti2 = addIn;
			i2LD = 1;
			nextstate = S53;
		end//S62
		
		/* ip0    = 0;
			ip1    = 1;
			ip2    = 2;
			ip3    = 3;
			psc    = 0;
			alpha  = MAX_16;
			time   = add(MAX_TIME, extra);
			ptr_ri0i0 = rri0i0; 
			ptr_ri0i1 = rri0i1;
			ptr_ri0i2 = rri0i2;
			ptr_ri0i3 = rri0i3;
			ptr_ri0i4 = rri0i4; */
		S63:
		begin
			ip0Reset = 1;
			nextip1 = 16'd1;
			ip1LD = 1;
			nextip2 = 16'd2;
			ip2LD = 1;
			nextip3 = 16'd3;
			ip3LD = 1;
			pscReset = 1;
			nextalpha = 16'h7fff;
			alphaLD = 1;
			addOutA = 16'd75;
			addOutB = memIn[15:0];
			nexttimeReg = addIn;
			timeRegLD = 1;
			nextptr_ri0i0 = rri0i0;
			ptr_ri0i0LD = 1;
			nextptr_ri0i1 = rri0i1;
			ptr_ri0i1LD = 1;
			nextptr_ri0i2 = rri0i2;
			ptr_ri0i2LD = 1;
			nextptr_ri0i3 = rri0i3;
			ptr_ri0i3LD = 1;
			nextptr_ri0i4 = rri0i4;
			ptr_ri0i4LD = 1;
			i0Reset = 1;
			nextstate = S64;
		end//S63
		
		//for (i0 = 0; i0 < L_SUBFR; i0 += STEP)
		S64:
		begin
			if(i0>=40)
				nextstate = S104;
			else if(i0<40)
			begin
				memReadAddr = {ACELP_DN[11:6],i0[5:0]};
				nextstate = S65;
			end
		end//S64
		
		//ps0  = Dn[i0];
		S65:
		begin
			nextps0 = memIn[15:0];
			ps0LD = 1;
			memReadAddr = ptr_ri0i0;
			nextstate = S66;
		end//S65
		
		//alp0 = *ptr_ri0i0++;
		S66:
		begin
			nextalp0 = memIn[15:0];
			alp0LD = 1;
			addOutA = ptr_ri0i0;
			addOutB = 16'd1;
			nextptr_ri0i0 = addIn;
			ptr_ri0i0LD = 1;
			nextstate = S67;
		end//S66
		
		/* ptr_ri1i1 = rri1i1;
		   ptr_ri1i2 = rri1i2;
			ptr_ri1i3 = rri1i3;
			ptr_ri1i4 = rri1i4; */
		S67:
		begin
			nextptr_ri1i1 = rri1i1;
			ptr_ri1i1LD = 1;
		   nextptr_ri1i2 = rri1i2;
			ptr_ri1i2LD = 1;
			nextptr_ri1i3 = rri1i3;
			ptr_ri1i3LD = 1;
			nextptr_ri1i4 = rri1i4;
			ptr_ri1i4LD = 1;
			nexti1 = 16'd1;
			i1LD = 1;
			nextstate = S68;
		end//S67
		
		//for (i1 = 1; i1 < L_SUBFR; i1 += STEP)
		S68:
		begin
			if(i1>=40)
				nextstate = S102;
			else if(i1<40)
			begin
				memReadAddr = {ACELP_DN[11:6],i1[5:0]};
				nextstate = S69;
			end
		end//S68
		
		/* ps1  = add(ps0, Dn[i1]);
        alp1 = L_mult(alp0, 1); */
		S69:
		begin
			addOutA = ps0;
			addOutB = memIn[15:0];
			nextps1 = addIn[15:0];
			ps1LD = 1;
			L_multOutA = alp0;
			L_multOutB = 16'd1;
			nextalp1 = L_multIn;
			alp1LD = 1;
			memReadAddr = ptr_ri1i1;
			nextstate = S70;
		end//S69
		
		//alp1 = L_mac(alp1, *ptr_ri1i1++, 1);
		S70:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd1;
			L_macOutC = alp1;
			nextalp1 = L_macIn;
			alp1LD = 1;
			addOutA = ptr_ri1i1;
			addOutB = 16'd1;
			nextptr_ri1i1 = addIn[11:0];
			ptr_ri1i1LD = 1;
			memReadAddr = ptr_ri0i1;
			nextstate = S71;
		end//S70
		
		/* alp1 = L_mac(alp1, *ptr_ri0i1++, 2);
         ptr_ri2i2 = rri2i2; 
         ptr_ri2i3 = rri2i3;
         ptr_ri2i4 = rri2i4; */
		S71:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd2;
			L_macOutC = alp1;
			nextalp1 = L_macIn;
			alp1LD = 1;
			addOutA = ptr_ri0i1;
			addOutB = 16'd1;
			nextptr_ri0i1 = addIn[11:0];
			ptr_ri0i1LD = 1;
			nextptr_ri2i2 = rri2i2;
			ptr_ri2i2LD = 1;
         nextptr_ri2i3 = rri2i3;
			ptr_ri2i3LD = 1;
         nextptr_ri2i4 = rri2i4;
			ptr_ri2i4LD = 1;
			nexti2 = 16'd2;
			i2LD = 1;
			nextstate = S72;
		end//S71
		
		//for (i2 = 2; i2 < L_SUBFR; i2 += STEP) 
		S72:
		begin			
			if(i2 >= 40)
				nextstate = S100;
			else if(i2<40)
			begin
				memReadAddr = {ACELP_DN[11:6],i2[5:0]};
				nextstate = S73;
			end			
		end//S72
		
		//ps2  = add(ps1, Dn[i2]);
		S73:
		begin
			addOutA = ps1;
			addOutB = memIn[15:0];
			nextps2 = addIn[15:0];
			ps2LD = 1;
			memReadAddr = ptr_ri2i2;
			nextstate = S74;
		end//S73
		
		//alp2 = L_mac(alp1, *ptr_ri2i2++, 1);
		S74:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd1;
			L_macOutC = alp1;
			nextalp2 = L_macIn;
			alp2LD = 1;
			addOutA = ptr_ri2i2;
			addOutB = 16'd1;
			nextptr_ri2i2 = addIn;
			ptr_ri2i2LD = 1;
			memReadAddr = ptr_ri0i2;
			nextstate = S75;
		end//S74
		
		//alp2 = L_mac(alp2, *ptr_ri0i2++, 2);
		S75:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd2;
			L_macOutC = alp2;
			nextalp2 = L_macIn;
			alp2LD = 1;
			addOutA = ptr_ri0i2;
			addOutB = 16'd1;
			nextptr_ri0i2 = addIn;
			ptr_ri0i2LD = 1;
			memReadAddr = ptr_ri1i2;
			nextstate = S76;
		end//S75
		
		/* alp2 = L_mac(alp2, *ptr_ri1i2++, 2);
		   if ( sub(ps2, thres) > 0){
				ptr_ri3i3 = rri3i3; */
		S76:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd2;
			L_macOutC = alp2;
			nextalp2 = L_macIn;
			alp2LD = 1;
			addOutA = ptr_ri1i2;
			addOutB = 16'd1;
			nextptr_ri1i2 = addIn;
			ptr_ri1i2LD = 1;
			subOutA = ps2;
			subOutB = thres;
			if((subIn[15] == 0) && (subIn != 0))
			begin				
				nextptr_ri3i3 = rri3i3;
				ptr_ri3i3LD = 1;
				nexti3 = 3;
				i3LD = 1;
				nextstate = S77;
			end
			else
				nextstate = S98;
		end//S76
		
		// for (i3 = 3; i3 < L_SUBFR; i3 += STEP)
		S77:
		begin					
			if(i3 >= 40)
				nextstate = S86;
			else if(i3 <40)
			begin
				memReadAddr = {ACELP_DN[11:6],i3[5:0]};
				nextstate = S78;
			end
		end//S77
		
		//ps3 = add(ps2, Dn[i3]);
		S78:
		begin
			addOutA = ps2;
			addOutB = memIn[15:0];
			nextps3 = addIn[15:0];
			ps3LD = 1;
			memReadAddr = ptr_ri3i3;
			nextstate = S79;
		end//S78
		
		//alp3 = L_mac(alp2, *ptr_ri3i3++, 1);
		S79:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd1;
			L_macOutC = alp2;
			nextalp3 = L_macIn;
			alp3LD = 1;
			addOutA = ptr_ri3i3;
			addOutB = 16'd1;
			nextptr_ri3i3 = addIn;
			ptr_ri3i3LD = 1;
			memReadAddr = ptr_ri0i3;
			nextstate = S80;
		end//S79
		
		//alp3 = L_mac(alp3, *ptr_ri0i3++, 2);
		S80:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd2;
			L_macOutC = alp3;
			nextalp3 = L_macIn;
			alp3LD = 1;
			addOutA = ptr_ri0i3;
			addOutB = 16'd1;
			nextptr_ri0i3 = addIn;
			ptr_ri0i3LD = 1;
			memReadAddr = ptr_ri1i3;
			nextstate = S81;
		end//S80
		
		//alp3 = L_mac(alp3, *ptr_ri1i3++, 2);
		S81:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd2;
			L_macOutC = alp3;
			nextalp3 = L_macIn;
			alp3LD = 1;
			addOutA = ptr_ri1i3;
			addOutB = 16'd1;
			nextptr_ri1i3 = addIn;
			ptr_ri1i3LD = 1;
			memReadAddr = ptr_ri2i3;
			nextstate = S82;
		end//S81
		
		//alp3 = L_mac(alp3, *ptr_ri2i3++, 2);
		S82:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd2;
			L_macOutC = alp3;
			nextalp3 = L_macIn;
			alp3LD = 1;	
			addOutA = ptr_ri2i3;
			addOutB = 16'd1;
			nextptr_ri2i3 = addIn;
			ptr_ri2i3LD = 1;
			nextstate = S83;
		end//S82
		
		/* alp  = extract_l(L_shr(alp3, 5));
		   ps3c = mult(ps3, ps3); */
		S83:
		begin
			L_shrVar1Out = alp3;
			L_shrNumShiftOut = 16'd5;
			nextalp = L_shrIn[15:0];
			alpLD = 1;
			multOutA = ps3;
			multOutB = ps3;
			nextps3c = multIn;
			ps3cLD = 1;
			nextstate = S84;
		end//S83
		
		//L_temp = L_mult(ps3c, alpha);
		S84:
		begin
			L_multOutA = ps3c;
			L_multOutB = alpha;
			nextL_temp = L_multIn;
			L_tempLD = 1;
			nextstate = S85;
		end//S84
		
		/*L_temp = L_msu(L_temp, psc, alp);
           if( L_temp > 0L ) {
             psc = ps3c;
             alpha = alp;
             ip0 = i0;
             ip1 = i1;
             ip2 = i2;
             ip3 = i3; } } */
		S85:
		begin
			L_msuOutA = psc;
			L_msuOutB = alp;
			L_msuOutC = L_temp;
			nextL_temp = L_msuIn;
			L_tempLD = 1;
			if((L_msuIn[31] == 0) && (L_msuIn != 0))
			begin
				nextpsc = ps3c;
            pscLD = 1;
				nextalpha = alp;
            alphaLD = 1;
				nextip0 = i0;
				ip0LD = 1;
            nextip1 = i1;
				ip1LD = 1;
            nextip2 = i2;
				ip2LD = 1;
            nextip3 = i3;
				ip3LD = 1;
			end
			
			addOutA = i3;
			addOutB = 16'd5;
			nexti3 = addIn;
			i3LD = 1;
			nextstate = S77;
		end//S85
		
		/* ptr_ri0i3 -= NB_POS;
         ptr_ri1i3 -= NB_POS;
         ptr_ri4i4 = rri4i4; */
		S86:
		begin
			subOutA = ptr_ri0i3;
			subOutB = 16'd8;
			nextptr_ri0i3 = subIn;
			ptr_ri0i3LD = 1;
			L_subOutA = ptr_ri1i3;
			L_subOutB = 32'd8;
			nextptr_ri1i3 = L_subIn;
			ptr_ri1i3LD = 1;
			nextptr_ri4i4 = rri4i4;
			ptr_ri4i4LD = 1;
			nexti3 = 16'd4;
			i3LD = 1;
			nextstate = S87;
		end//S86
		
		//for (i3 = 4; i3 < L_SUBFR; i3 += STEP)
		S87:
		begin			
			if(i3>=40)
				nextstate = S96;
			else if(i3<40)
			begin
				memReadAddr = {ACELP_DN[11:6],i3[5:0]};
				nextstate = S88;
			end
		end//S87
		
		//ps3 = add(ps2, Dn[i3]);
		S88:
		begin
			addOutA = ps2;
			addOutB = memIn[15:0];
			nextps3 = addIn;
			ps3LD = 1;
			memReadAddr = ptr_ri4i4;
			nextstate = S89;
		end//S88
		
		//alp3 = L_mac(alp2, *ptr_ri4i4++, 1);
		S89:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd1;
			L_macOutC = alp2;
			nextalp3 = L_macIn;
			alp3LD = 1;
			addOutA = ptr_ri4i4;
			addOutB = 16'd1;
			nextptr_ri4i4 = addIn;
			ptr_ri4i4LD = 1;
			memReadAddr = ptr_ri0i4;
			nextstate = S90;
		end//S89
		
		//alp3 = L_mac(alp3, *ptr_ri0i4++, 2);
		S90:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd2;
			L_macOutC = alp3;
			nextalp3 = L_macIn;
			alp3LD = 1;
			addOutA = ptr_ri0i4;
			addOutB = 16'd1;
			nextptr_ri0i4 = addIn;
			ptr_ri0i4LD = 1;
			memReadAddr = ptr_ri1i4;
			nextstate = S91;
		end//S90
		
		//alp3 = L_mac(alp3, *ptr_ri1i4++, 2);
		S91:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd2;
			L_macOutC = alp3;
			nextalp3 = L_macIn;
			alp3LD = 1;
			addOutA = ptr_ri1i4;
			addOutB = 16'd1;
			nextptr_ri1i4 = addIn;
			ptr_ri1i4LD = 1;
			memReadAddr = ptr_ri2i4;
			nextstate = S92;
		end//S91
		
		//alp3 = L_mac(alp3, *ptr_ri2i4++, 2);
		S92:
		begin
			L_macOutA = memIn[15:0];
			L_macOutB = 16'd2;
			L_macOutC = alp3;
			nextalp3 = L_macIn;
			alp3LD = 1;
			addOutA = ptr_ri2i4;
			addOutB = 16'd1;
			nextptr_ri2i4 = addIn;
			ptr_ri2i4LD = 1;
			nextstate = S93;
		end//S92
		
		/* alp  = extract_l(L_shr(alp3, 5));
		   ps3c = mult(ps3, ps3); */
		S93:
		begin
			L_shrVar1Out = alp3;
			L_shrNumShiftOut = 16'd5;
			nextalp = L_shrIn[15:0];
			alpLD = 1;
			multOutA = ps3;
			multOutB = ps3;
			nextps3c = multIn;
			ps3cLD = 1;
			nextstate = S94;
		end//S93
		
		//L_temp = L_mult(ps3c, alpha);
		S94:
		begin
			L_multOutA = ps3c;
			L_multOutB = alpha;
			nextL_temp = L_multIn;
			L_tempLD = 1;
			nextstate = S95;
		end//S94
		
		/* L_temp = L_msu(L_temp, psc, alp);
		   if( L_temp > 0L )
           {
             psc = ps3c;
             alpha = alp;
             ip0 = i0;
             ip1 = i1;
             ip2 = i2;
             ip3 = i3;
           }
         } */
		S95:
		begin
			L_msuOutA = psc;
			L_msuOutB = alp;
			L_msuOutC = L_temp;
			nextL_temp = L_msuIn;
			L_tempLD = 1;
			if((L_msuIn[31] == 0 ) && (L_msuIn != 0))
         begin
             nextpsc = ps3c;
				 pscLD = 1;
             nextalpha = alp;
				 alphaLD = 1;
             nextip0 = i0;
             ip0LD = 1;
				 nextip1 = i1;
				 ip1LD = 1;
             nextip2 = i2;
				 ip2LD = 1;
             nextip3 = i3;
				 ip3LD = 1;
          end
			 addOutA = i3;
			 addOutB = 16'd5;
			 nexti3 = addIn;
			 i3LD = 1;
			 nextstate = S87;
		end//S95
		
		/* ptr_ri0i4 -= NB_POS;
         ptr_ri1i4 -= NB_POS;
		*/
		S96:
		begin
			subOutA = ptr_ri0i4;
			subOutB = 16'd8;
			nextptr_ri0i4 = subIn;
			ptr_ri0i4LD = 1;
			L_subOutA = ptr_ri1i4;
			L_subOutB = 32'd8;
			nextptr_ri1i4 = L_subIn;
			ptr_ri1i4LD = 1;
			nextstate = S97;
		end//S96
		
		/* time = sub(time, 1);
         if(time <= 0 ) goto end_search; */
		S97:
		begin
			subOutA = timeReg;
			subOutB = 16'd1;
			nexttimeReg = subIn;
			timeRegLD = 1;
			if(subIn[15] == 1 || subIn == 0)
				nextstate = S104;
			else
			begin
				addOutA = i2;
				addOutB = 16'd5;
				nexti2 = addIn;
				i2LD = 1;
				nextstate = S72;
			end
		end//S97
		
		/* ptr_ri2i3 += NB_POS;
         ptr_ri2i4 += NB_POS; */
		S98:
		begin
			addOutA = ptr_ri2i3;
			addOutB = 16'd8;
			nextptr_ri2i3 = addIn;
			ptr_ri2i3LD = 1;
			L_addOutA = ptr_ri2i4;
			L_addOutB = 32'd8;
			nextptr_ri2i4 = L_addIn;
			ptr_ri2i4LD = 1;
			nextstate = S99;
		end//S98
		
		S99:
		begin
			addOutA = i2;
			addOutB = 16'd5;
			nexti2 = addIn;
			i2LD = 1;
			nextstate = S72;
		end//S99
		
	 /* ptr_ri0i2 -= NB_POS;
       ptr_ri1i3 += NB_POS;
       ptr_ri1i4 += NB_POS; */
		S100:
		begin
			subOutA = ptr_ri0i2;
			subOutB = 16'd8;
			nextptr_ri0i2 = subIn;
			ptr_ri0i2LD = 1;
			addOutA = ptr_ri1i3;
			addOutB = 16'd8;
			nextptr_ri1i3 = addIn;
			ptr_ri1i3LD = 1;
			L_addOutA = ptr_ri1i4;
			L_addOutB = 32'd8;
			nextptr_ri1i4 = L_addIn;
			ptr_ri1i4LD = 1;
			nextstate = S101;
		end//S100
		
		S101:
		begin
			addOutA = i1;
			addOutB = 16'd5;
			nexti1 = addIn;
			i1LD = 1;
			nextstate = S68;
		end//S101
		
		/* ptr_ri0i2 += NB_POS;
		   ptr_ri0i3 += NB_POS; */
		S102:
		begin
			addOutA = ptr_ri0i2;
			addOutB = 16'd8;
			nextptr_ri0i2 = addIn;
			ptr_ri0i2LD = 1;
			L_addOutA = ptr_ri0i3;
			L_addOutB = 32'd8;
			nextptr_ri0i3 = L_addIn;
			ptr_ri0i3LD = 1;
			nextstate = S103;
		end//S102
		
		//ptr_ri0i4 += NB_POS;
		S103:
		begin
			addOutA = ptr_ri0i4;
			addOutB = 16'd8;
			nextptr_ri0i4 = addIn;
			ptr_ri0i4LD = 1;
			L_addOutA = i0;
			L_addOutB = 32'd5;
			nexti0 = L_addIn;
			i0LD = 1;
			nextstate = S64;			
		end//S103
		
		/* end_search:
				extra = time; */
		S104:
		begin
			memOut = timeReg;
			memWriteAddr = ACELP_EXTRA;
			memWriteEn = 1;
			memReadAddr = {D17_P_SIGN[11:6],ip0[5:0]};
			nextstate = S105;
		end//S104
		
		//i0 = p_sign[ip0];
		S105:
		begin
			nexti0 = memIn[15:0];
			i0LD = 1;
			memReadAddr = {D17_P_SIGN[11:6],ip1[5:0]};
			nextstate = S106;
		end//S105
		
		//i1 = p_sign[ip1];
		S106:
		begin
			nexti1 = memIn[15:0];
			i1LD = 1;
			memReadAddr = {D17_P_SIGN[11:6],ip2[5:0]};
			nextstate = S107;
		end//S106
		
		//i2 = p_sign[ip2];
		S107:
		begin
			nexti2 = memIn[15:0];
			i2LD = 1;
			memReadAddr = {D17_P_SIGN[11:6],ip3[5:0]};
			nextstate = S108;
		end//S107
		
		//i3 = p_sign[ip3];
		S108:
		begin
			nexti3 = memIn[15:0];
			i3LD = 1;
			iReset = 1;
			nextstate = S109;
		end//S108
		
		//for(i=0; i<L_SUBFR; i++) {cod[i] = 0; }
		S109:
		begin
			if(i >= 40)
				nextstate = S110;
			else if(i < 40)
			begin
				memOut = 32'd0;
				memWriteAddr = {CODE[11:6],i[5:0]};
				memWriteEn = 1;
				addOutA = i;
				addOutB = 16'd1;
				nexti = addIn;
				iLD = 1;
				nextstate = S109;
			end
		end//S109
		
		//cod[ip0] = shr(i0, 2); 
		S110:
		begin
			shrVar1Out = i0;
			shrVar2Out = 16'd2;
			memOut = shrIn[15:0];
			memWriteEn = 1;
			memWriteAddr = {CODE[11:6],ip0[5:0]};
			nextstate = S111;
		end//S110
		
		//cod[ip1] = shr(i1, 2);
		S111:
		begin
			shrVar1Out = i1;
			shrVar2Out = 16'd2;
			memOut = shrIn[15:0];
			memWriteEn = 1;
			memWriteAddr = {CODE[11:6],ip1[5:0]};
			nextstate = S112;
		end//S111
		
		//cod[ip2] = shr(i2, 2);
		S112:
		begin
			shrVar1Out = i2;
			shrVar2Out = 16'd2;
			memOut = shrIn[15:0];
			memWriteEn = 1;
			memWriteAddr = {CODE[11:6],ip2[5:0]};
			nextstate = S113;
		end//S112
		
		//cod[ip3] = shr(i3, 2);
		S113:
		begin
			shrVar1Out = i3;
			shrVar2Out = 16'd2;
			memOut = shrIn[15:0];
			memWriteEn = 1;
			memWriteAddr = {CODE[11:6],ip3[5:0]};
			iReset = 1;
			nextstate = S114;
		end//S113
		
		//for (i = 0; i < L_SUBFR; i++) {y[i] = 0;  }
		S114:
		begin
			if(i>=40)
				nextstate = S115;
			else if(i<40)
			begin
				memOut = 32'd0;
				memWriteEn = 1;
				memWriteAddr = {Y2[11:6],i[5:0]};
				addOutA = i;
				addOutB = 16'd1;
				nexti = addIn;
				iLD = 1;
				nextstate = S114;
			end
		end//S114
		
		//if(i0 > 0)
		S115:
		begin
			nexti = ip0;
			iLD = 1;
			jReset = 1;
			if((i0[15] == 0) &&(i0 != 0))
				nextstate = S116;
			else 
				nextstate = S119;
		end//S115
		
		//for(i=ip0, j=0; i<L_SUBFR; i++, j++)
		S116:
		begin
			if(i>=40)
				nextstate = S122;
			else if(i<40)
			begin
				memReadAddr = {Y2[11:6],i[5:0]};
				nextstate = S117;
			end
		end//S116
		
		S117:
		begin
			nexttemp = memIn;
			tempLD = 1;
			memReadAddr = {H1[11:6],j[5:0]};
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S118;
		end//S117
		
		//y[i] = add(y[i], h[j]); 
		S118:
		begin
			addOutA = temp[15:0];
			addOutB = memIn[15:0];
			memOut = addIn[15:0];
			memWriteAddr = {Y2[11:6],i[5:0]};
			memWriteEn = 1;
			L_addOutA = i;
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			nextstate = S116;
		end//S118
		
		//else for(i=ip0, j=0; i<L_SUBFR; i++, j++) 
		S119:
		begin
			if(i>=40)
				nextstate = S122;
			else if(i<40)
			begin
				memReadAddr = {Y2[11:6],i[5:0]};
				nextstate = S120;
			end
		end//S119
		
		S120:
		begin
			nexttemp = memIn;
			tempLD = 1;
			memReadAddr = {H1[11:6],j[5:0]};			
			nextstate = S121;
		end//S120
		
		//y[i] = sub(y[i], h[j]); 
		S121:
		begin
			subOutA = temp[15:0];
			subOutB = memIn[15:0];
			memOut = subIn[15:0];
			memWriteAddr = {Y2[11:6],i[5:0]};
			memWriteEn = 1;
			L_addOutA = i;
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S119;
		end//S121
		
		//if(i1 > 0)
		S122:
		begin
			nexti = ip1;
			iLD = 1;
			jReset = 1;
			if((i1[15] == 0) &&(i1 != 0))
				nextstate = S123;
			else 
				nextstate = S126;
		end//S122
		
		//for(i=ip1, j=0; i<L_SUBFR; i++, j++)
		S123:
		begin
			if(i>=40)
				nextstate = S129;
			else if(i<40)
			begin
				memReadAddr = {Y2[11:6],i[5:0]};
				nextstate = S124;
			end
		end//S123
		
		S124:
		begin
			nexttemp = memIn;
			tempLD = 1;
			memReadAddr = {H1[11:6],j[5:0]};
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S125;
		end//S124
		
		//y[i] = add(y[i], h[j]); 
		S125:
		begin
			addOutA = temp[15:0];
			addOutB = memIn[15:0];
			memOut = addIn[15:0];
			memWriteAddr = {Y2[11:6],i[5:0]};
			memWriteEn = 1;
			L_addOutA = i;
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			nextstate = S123;
		end//S125
		
		//else for(i=ip1, j=0; i<L_SUBFR; i++, j++) 
		S126:
		begin
			if(i>=40)
				nextstate = S129;
			else if(i<40)
			begin
				memReadAddr = {Y2[11:6],i[5:0]};
				nextstate = S127;
			end
		end//S126
		
		S127:
		begin
			nexttemp = memIn;
			tempLD = 1;
			memReadAddr = {H1[11:6],j[5:0]};			
			nextstate = S128;
		end//S127
		
		//y[i] = sub(y[i], h[j]); }
		S128:
		begin
			subOutA = temp[15:0];
			subOutB = memIn[15:0];
			memOut = subIn[15:0];
			memWriteAddr = {Y2[11:6],i[5:0]};
			memWriteEn = 1;
			L_addOutA = i;
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S126;
		end//S128
		
		//if(i2 > 0)
		S129:
		begin
			nexti = ip2;
			iLD = 1;
			jReset = 1;
			if((i2[15] == 0) &&(i2 != 0))
				nextstate = S130;
			else 
				nextstate = S133;
		end//S129
		
		// for(i=ip2, j=0; i<L_SUBFR; i++, j++) 
		S130:
		begin
			if(i>=40)
				nextstate = S136;
			else if(i<40)
			begin
				memReadAddr = {Y2[11:6],i[5:0]};
				nextstate = S131;
			end
		end//S130
		
		S131:
		begin
			nexttemp = memIn;
			tempLD = 1;
			memReadAddr = {H1[11:6],j[5:0]};
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S132;
		end//S131
		
		//y[i] = add(y[i], h[j]);
		S132:
		begin
			addOutA = temp[15:0];
			addOutB = memIn[15:0];
			memOut = addIn[15:0];
			memWriteAddr = {Y2[11:6],i[5:0]};
			memWriteEn = 1;
			L_addOutA = i;
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			nextstate = S130;
		end//S132
		
		//else for(i=ip2, j=0; i<L_SUBFR; i++, j++) 
		S133:
		begin
			if(i>=40)
				nextstate = S136;
			else if(i<40)
			begin
				memReadAddr = {Y2[11:6],i[5:0]};
				nextstate = S134;
			end
		end//S133
		
		S134:
		begin
			nexttemp = memIn;
			tempLD = 1;
			memReadAddr = {H1[11:6],j[5:0]};			
			nextstate = S135;
		end//S134
		
		// y[i] = sub(y[i], h[j]); 
		S135:
		begin
			subOutA = temp[15:0];
			subOutB = memIn[15:0];
			memOut = subIn[15:0];
			memWriteAddr = {Y2[11:6],i[5:0]};
			memWriteEn = 1;
			L_addOutA = i;
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S133;
		end//S135
		
		//if(i3 > 0)
		S136:
		begin
			nexti = ip3;
			iLD = 1;
			jReset = 1;
			if((i3[15] == 0) &&(i3 != 0))
				nextstate = S137;
			else 
				nextstate = S140;
		end//S136
		
		//for(i=ip3, j=0; i<L_SUBFR; i++, j++)
		S137:
		begin
			if(i>=40)
			begin
				nextstate = S143;
				iReset = 1;
			end
			else if(i<40)
			begin
				memReadAddr = {Y2[11:6],i[5:0]};
				nextstate = S138;
			end
		end//S137
		
		S138:
		begin
			nexttemp = memIn;
			tempLD = 1;
			memReadAddr = {H1[11:6],j[5:0]};
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S139;
		end//S138
		
		//y[i] = add(y[i], h[j]);
		S139:
		begin
			addOutA = temp[15:0];
			addOutB = memIn[15:0];
			memOut = addIn[15:0];
			memWriteAddr = {Y2[11:6],i[5:0]};
			memWriteEn = 1;
			L_addOutA = i;
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			nextstate = S137;
		end//S139
		
		// else for(i=ip3, j=0; i<L_SUBFR; i++, j++)
		S140:
		begin
			if(i>=40)
			begin
				nextstate = S143;
				iReset = 1;
			end
			else if(i<40)
			begin
				memReadAddr = {Y2[11:6],i[5:0]};
				nextstate = S141;
			end
		end//S140		
		
		S141:
		begin
			nexttemp = memIn;
			tempLD = 1;
			memReadAddr = {H1[11:6],j[5:0]};			
			nextstate = S142;
		end//S141
		
		//y[i] = sub(y[i], h[j]);
		S142:
		begin
			subOutA = temp[15:0];
			subOutB = memIn[15:0];
			memOut = subIn[15:0];
			memWriteAddr = {Y2[11:6],i[5:0]};
			memWriteEn = 1;
			L_addOutA = i;
			L_addOutB = 32'd1;
			nexti = L_addIn;
			iLD = 1;
			addOutA = j;
			addOutB = 16'd1;
			nextj = addIn;
			jLD = 1;
			nextstate = S140;
		end//S142
		
		/* i = 0;
         if(i0 > 0) i = add(i, 1); */
		S143:
		begin			
			if((i0[15] == 0) && (i0 != 0))
			begin
				addOutA = i;
				addOutB = 16'd1;
				nexti = addIn;
				iLD = 1;
			end
			nextstate = S144;
		end//S143
		
		//if(i1 > 0) i = add(i, 2);
		S144:
		begin
			if((i1[15] == 0) && (i1 != 0))
			begin
				addOutA = i;
				addOutB = 16'd2;
				nexti = addIn;
				iLD = 1;
			end
			nextstate = S145;
		end//S144
		
		//if(i2 > 0) i = add(i, 4);
		S145:
		begin
			if((i2[15] == 0) && (i2 != 0))
			begin
				addOutA = i;
				addOutB = 16'd4;
				nexti = addIn;
				iLD = 1;
			end
			nextstate = S146;
		end//S145
		
		/* if(i3 > 0) i = add(i, 8);
		  *sign = i;*/
		S146:
		begin
			if((i3[15] == 0) && (i3 != 0))
			begin
				addOutA = i;
				addOutB = 16'd8;
				nexti = addIn;
				iLD = 1;
				memOut = addIn;
			   memWriteEn = 1;
			   memWriteAddr = TOP_LEVEL_I;
			end
			else
			begin
				memOut = i;
				memWriteEn = 1;
				memWriteAddr = TOP_LEVEL_I;
			end
			nextstate = S147;
		end//S146
		
		//ip0 = mult(ip0, 6554);
		S147:
		begin
			multOutA = ip0;
			multOutB = 16'd6554;
			nextip0 = multIn;
			ip0LD = 1;
			nextstate = S148;
		end//S147
		
		//ip1 = mult(ip1, 6554);
		S148:
		begin
			multOutA = ip1;
			multOutB = 16'd6554;
			nextip1 = multIn;
			ip1LD = 1;
			nextstate = S149;
		end//S148
		
		//ip2 = mult(ip2, 6554);
		S149:
		begin
			multOutA = ip2;
			multOutB = 16'd6554;
			nextip2 = multIn;
			ip2LD = 1;
			nextstate = S150;
		end//S149
		
		//i   = mult(ip3, 6554);
		S150:
		begin
			multOutA = ip3;
			multOutB = 16'd6554;
			nexti = multIn;
			iLD = 1;
			nextstate = S151;
		end//S150
		
		//shl(i, 2);
		S151:
		begin
			shlVar1Out = i;
			shlVar2Out = 16'd2;
			nexttemp = shlIn;
			tempLD = 1;
			nextstate = S152;
		end//S151
		
		//j = add(i, shl(i, 2));
		S152:
		begin
			addOutA = i;
			addOutB = temp[15:0];
			nextj = addIn;
			jLD = 1;
			nextstate = S153;
		end//S152
		
		//add(j, 3)
		S153:
		begin
			addOutA = j;
			addOutB = 16'd3;
			nexttemp = addIn;
			tempLD = 1;
			nextstate = S154;
		end//S153
		
		//j = sub(ip3, add(j, 3));
		S154:
		begin
			subOutA = ip3;
			subOutB = temp[15:0];
			nextj = subIn;
			jLD = 1;
			nextstate = S155;
		end//S154
		
		//shl(i, 1)
		S155:
		begin
			shlVar1Out = i;
			shlVar2Out = 16'd1;
			nexttemp = shlIn;
			tempLD = 1;
			nextstate = S156;
		end//S155
		
		//ip3 = add(shl(i, 1), j);
				//shl(ip1, 3);
		S156:
		begin
			addOutA = temp[15:0];
			addOutB = j;
			nextip3 = addIn;
			ip3LD = 1;
			shlVar1Out = ip1;
			shlVar2Out = 16'd3;
			nexttemp = shlIn;
			tempLD = 1;
			nextstate = S157;
		end//S156
		
		//i = add(ip0, shl(ip1, 3));
			//shl(ip2, 6)
		S157:
		begin
			addOutA = ip0;
			addOutB = temp[15:0];
			nexti = addIn;
			iLD = 1;
			shlVar1Out = ip2;
			shlVar2Out = 16'd6;
			nexttemp = shlIn;
			tempLD = 1;
			nextstate = S158;
		end//S157
		
		//i = add(i,shl(ip2, 6));
				//shl(ip3, 9)
		S158:
		begin
			addOutA = i;
			addOutB = temp[15:0];
			nexti = addIn;
			iLD = 1;
			shlVar1Out = ip3;
			shlVar2Out = 16'd9;
			nexttemp = shlIn;
			tempLD = 1;
			nextstate = S159;
		end//S158
		
		//i = add(i,shl(ip3, 9));
		S159:
		begin
			addOutA = i;
			addOutB = temp[15:0];
			nexti = addIn;
			iLD = 1;
			nextstate = S160;
		end//S159
		
		S160:
		begin
			done = 1;
			nextstate = INIT;
		end//S160
	endcase
end//always

endmodule
