`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    13:08:31 10/12/2010 
// Module Name:    lag_window 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function to compute the lag window multiplication and return the r'(k) coefficients
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lag_window(clk,reset,start,rPrimeIn,L_multIn,multIn,L_macIn,L_msuIn,addIn,L_shrIn,rPrimeWrite,
						rPrimeRequested,rPrimeReadAddr,L_multOutA,L_multOutB,multOutA,multOutB,L_macOutA,
						L_macOutB,L_macOutC,L_msuOutA,L_msuOutB,L_msuOutC,rPrimeOut,addOutA, addOutB,
						L_shrOutVar1,L_shrOutNumShift,done);
`include "paramList.v"
//inputs 
input clk, reset,start;
input [31:0] rPrimeIn;
input [31:0] L_multIn;
input [15:0] multIn;
input [31:0] L_macIn;
input [31:0] L_msuIn;
input [15:0] addIn;
input [31:0] L_shrIn;

//outputs
output reg rPrimeWrite;
output reg [11:0] rPrimeReadAddr; 
output reg [11:0] rPrimeRequested;
output [15:0] L_multOutA,L_multOutB;
output [15:0] multOutA,multOutB;
output [15:0] L_macOutA,L_macOutB;
output [31:0] L_macOutC;
output reg [15:0] L_msuOutA,L_msuOutB;
output reg [31:0] L_msuOutC;
output reg [31:0] rPrimeOut;
output reg [15:0] addOutA, addOutB;
output reg [31:0] L_shrOutVar1;
output reg [15:0] L_shrOutNumShift;
output reg done;

//internal regs
reg [2:0] state,nextstate;
reg [15:0] i,nexti;
reg iLD,iReset;
reg [31:0] xReg,nextx;
reg xLD,xReset;
reg [31:0] temp,nexttemp;
reg tempLD,tempReset;

//Lag constant regs
reg [31:0] lagConstant;
reg [3:0] lagSel;

//mpy32 wires and regs
reg mpy32Start;
reg [31:0] mpy32Var1,mpy32Var2;
wire mpy32Done;
wire [31:0] mpy32Out;

//state parameters
parameter INIT = 3'd0;
parameter S1 = 3'd1;
parameter S2 = 3'd2;
parameter S3 = 3'd3;
parameter S4 = 3'd4;
parameter S5 = 3'd5;
parameter S6 = 3'd6;
parameter S7 = 3'd7;

//Instantiated Modules
Mpy_32 mpy32(
				 .clock(clk),
				 .reset(reset),
				 .start(mpy32Start), 
				 .done(mpy32Done),
				 .var1(mpy32Var1),
				 .var2(mpy32Var2),
				 .out(mpy32Out),
				 .L_mult_outa(L_multOutA),
				 .L_mult_outb(L_multOutB),
				 .L_mult_overflow(),
				 .L_mult_in(L_multIn),
				 .L_mac_outa(L_macOutA),
				 .L_mac_outb(L_macOutB),
				 .L_mac_outc(L_macOutC),
				 .L_mac_overflow(),
				 .L_mac_in(L_macIn),
				 .mult_outa(multOutA),
				 .mult_outb(multOutB),
				 .mult_in(multIn),
				 .mult_overflow()
				 ); 

//state, i, and x flops
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
		xReg <= 0;
	else if(xReset)
		xReg <= 0;
	else if(xLD)
		xReg <= nextx;
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
	nexti = i;
	nextx = xReg;
	nexttemp = temp;
	iLD = 0;
	xLD = 0;
	tempLD = 0;
	iReset = 0;
	xReset = 0;	
	tempReset = 0;	
	lagSel = 0;
	mpy32Start = 0;
	mpy32Var1 = 0;
	mpy32Var2 = 0;
	rPrimeReadAddr = 0;
	rPrimeRequested = 0;
	rPrimeWrite = 0;
	rPrimeOut = 0;   
   L_msuOutA = 0;
	L_msuOutB = 0;
   L_msuOutC = 0;	
   addOutA = 0; 
	addOutB = 0;
   L_shrOutVar1 = 0;
	L_shrOutNumShift = 0;
   done = 0;
	
	case(state)
	
		INIT:
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin
				iReset = 1;
				xReset = 1;
				tempReset = 1;
				rPrimeReadAddr = AUTOCORR_R;
				nextstate = S1;
			end
		end//INIT
		
		//writes the first values of Autocorr_R straight to lag_window_r_prime
		S1:
		begin
			rPrimeRequested = LAG_WINDOW_R_PRIME;
			rPrimeWrite = 1;
			rPrimeOut = rPrimeIn;
			nexti = 1;
			iLD = 1;
			nextstate = S2;
		end//S1
		
		//for(i=1; i<=m; i++)
		S2:
		begin
			if(i>10)
			begin
				nextstate = INIT;
				done = 1;
			end
			else if(i<=10)
			begin
				rPrimeReadAddr = {AUTOCORR_R[11:4],i[3:0]};
				nextstate = S3;
			end			
		end//S2
		
		//x  = Mpy_32(r_h[i], r_l[i], lag_h[i-1], lag_l[i-1]);
		S3:
		begin
			rPrimeReadAddr = {AUTOCORR_R[11:4],i[3:0]};
			lagSel = i[3:0];
			mpy32Start = 1;
			mpy32Var1 = rPrimeIn;
			mpy32Var2 = lagConstant;
			nextstate = S4;
		end//S3
		
		////x  = Mpy_32(r_h[i], r_l[i], lag_h[i-1], lag_l[i-1]);
		S4:
		begin
			rPrimeReadAddr = {AUTOCORR_R[11:4],i[3:0]};
			lagSel = i[3:0];			
			mpy32Var1 = rPrimeIn;
			mpy32Var2 = lagConstant;
			if(mpy32Done == 0)
				nextstate = S4;
			else if(mpy32Done == 1)
			begin
				nextx = mpy32Out;
				xLD = 1;
				nextstate = S5;
			end
		end//S4
		
		//L_Extract(x, &r_h[i], &r_l[i]);
		S5:
		begin
			L_shrOutVar1 = xReg;
			L_shrOutNumShift = 16'd1;
			nexttemp = L_shrIn;
			tempLD = 1;
			nextstate = S6;
		end//S5
		
		//L_Extract(x, &r_h[i], &r_l[i]);
		S6:
		begin
			L_msuOutA = xReg[31:16];
			L_msuOutB = 16'd16384;
			L_msuOutC = temp;
			rPrimeRequested = {LAG_WINDOW_R_PRIME[11:4],i[3:0]};
			rPrimeWrite = 1;
			rPrimeOut = {xReg[31:16],L_msuIn[15:0]};
			addOutA = i;
			addOutB = 16'd1;
			nexti = addIn;
			iLD = 1;
			nextstate = S2;
		end//S6	
	endcase
end	//end always

always @(*)	begin				 

	case(lagSel)
		
		4'd1:	lagConstant = 32'h7fd82e80;
		4'd2:	lagConstant = 32'h7f6b4380;
		4'd3:	lagConstant = 32'h7eb67800;
		4'd4:	lagConstant = 32'h7dbb6500;
		4'd5:	lagConstant = 32'h7c7b5e80;
		4'd6:	lagConstant = 32'h7af87140;
		4'd7:	lagConstant = 32'h79355f40;
		4'd8:	lagConstant = 32'h77351cc0;
		4'd9:	lagConstant = 32'h74fa4c40;
		4'd10: lagConstant = 32'h728939c0;
		default: lagConstant = 32'h0;
	endcase

end//end always

endmodule
