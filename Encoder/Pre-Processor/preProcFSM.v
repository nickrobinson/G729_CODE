`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    17:37:12 08/25/2010
// Module Name:    preProcFSM.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This module implements the Finite State Machine that operates the Pre_Processor.
//
//
// Dependencies: 	 mpy_32_16.v,L_add.v,L_mac.v,L_shl.v,L_msu.v,L_shr.v

//
//////////////////////////////////////////////////////////////////////////////////
module preProcFSM(clk,reset,ready,xn,yn,done);

//Inputs	
input clk,reset,ready;
input [15:0] xn;

//Outputs
output reg [15:0] yn;
output reg done;

//Internal wires
wire [31:0] mpy_32_16In;
wire [31:0] L_addIn;
wire [31:0] L_macIn;
wire [31:0] L_shlIn;
wire L_shlDone;
wire [31:0] L_msuIn;
wire [31:0] L_shrIn;
wire [15:0] multIn;
wire [31:0] L_multIn;
wire [15:0] mpy_L_multOutA,mpy_L_multOutB;
wire [15:0] mpy_L_macOutA,mpy_L_macOutB;
wire [31:0] mpy_L_macOutC;
wire [15:0] mpy_multOutA,mpy_multOutB;					  
				
//Internal regs
reg [31:0] mpy_32_16Var1;
reg [15:0] mpy_32_16Var2;
reg [31:0] L_addOutA,L_addOutB;
reg [15:0] L_macOutA,L_macOutB;
reg [31:0] L_macOutC;
reg [31:0] L_shlVar1Out;
reg [15:0] L_shlNumShiftOut;
reg L_shlReady;
reg [15:0] L_msuOutA,L_msuOutB;
reg [31:0] L_msuOutC;
reg [31:0] L_shrVar1Out;
reg [15:0] L_shrNumShiftOut;
reg [15:0] multOutA,multOutB;
reg [15:0] L_multOutA,L_multOutB;

//Flip flop regs
reg [3:0]  state, nextstate;

reg [15:0] y2_hi,nexty2_hi;
reg y2_hiLD;

reg [15:0] y2_lo,nexty2_lo;
reg y2_loLD;

reg [15:0] y1_hi,nexty1_hi;
reg y1_hiLD;

reg [15:0] y1_lo,nexty1_lo;
reg y1_loLD;

reg [15:0] x0,nextx0;
reg x0LD;

reg [15:0] x1,nextx1;
reg x1LD;

reg [15:0] x2,nextx2;
reg x2LD,x2Reset;

reg [31:0] L_temp,nextL_temp;
reg L_tempLD,L_tempReset;

reg [31:0] temp,nexttemp;
reg tempLD,tempReset;

reg [15:0] nextyn;
reg ynLD,ynReset;

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

always @(posedge clk) 
begin
	if (reset)
		state <= INIT;
	else 
		state <= nextstate;
end

always @(posedge clk)
begin
	if(reset)
		y2_hi <= 0;
	else if(y2_hiLD)
		y2_hi <= nexty2_hi;
end

always @(posedge clk)
begin
	if(reset)
		y2_lo <= 0;
	else if(y2_loLD)
		y2_lo <= nexty2_lo;
end

always @(posedge clk)
begin
	if(reset)
		y1_hi <= 0;
	else if(y1_hiLD)
		y1_hi <= nexty1_hi;
end

always @(posedge clk)
begin
	if(reset)
		y1_lo <= 0;
	else if(y1_loLD)
		y1_lo <= nexty1_lo;
end

always @(posedge clk)
begin
	if(reset)
		x0 <= 0;
	else if(x0LD)
		x0 <= nextx0;
end

always @(posedge clk)
begin
	if(reset)
		x1 <= 0;
	else if(x1LD)
		x1 <= nextx1;
end

always @(posedge clk)
begin
	if(reset)
		x2 <= 0;
	else if(x2Reset)
		x2 <= 0;
	else if(x2LD)
		x2 <= nextx2;
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

always @(posedge clk)
begin
	if(reset)
		yn <= 0;
	else if(ynReset)
		yn <= 0;
	else if(ynLD)
		yn <= nextyn;
end
//Instantiated Modules

L_add preproc_L_add(
							.a(L_addOutA),
							.b(L_addOutB),
							.overflow(),
							.sum(L_addIn)
							);
				
L_mac preproc_L_mac(
							.a(L_macOutA),
							.b(L_macOutB),
							.c(L_macOutC),
							.overflow(),
							.out(L_macIn)
							);
L_shl preproc_L_shl(
						  .clk(clk),
						  .reset(reset),
						  .ready(L_shlReady),
						  .overflow(),
						  .var1(L_shlVar1Out),
						  .numShift(L_shlNumShiftOut),
						  .done(L_shlDone),
						  .out(L_shlIn)
						  );
						  
L_msu preproc_L_msu(
							.a(L_msuOutA),
							.b(L_msuOutB),
							.c(L_msuOutC),
							.overflow(),
							.out(L_msuIn)
							);
L_shr preproc_L_shr(
							.var1(L_shrVar1Out),
							.numShift(L_shrNumShiftOut),
							.overflow(),
							.out(L_shrIn)
							);
							
mult preproc_mult(
						 .a(multOutA),
						 .b(multOutB),
						 .multRsel(1'd0),
						 .overflow(),
						 .product(multIn)
						 );
							
L_mult preproc_L_mult(
							 .a(L_multOutA),
							 .b(L_multOutB),
							 .overflow(),
							 .product(L_multIn)
							 );

mpy_32_16 preproc_mpy(
								.var1(mpy_32_16Var1),
								.var2(mpy_32_16Var2),
								.out(mpy_32_16In),
								.L_mult_outa(mpy_L_multOutA),
								.L_mult_outb(mpy_L_multOutB),
								.L_mult_overflow(),
								.L_mult_in(L_multIn),
								.L_mac_outa(mpy_L_macOutA),
								.L_mac_outb(mpy_L_macOutB),
								.L_mac_outc(mpy_L_macOutC), 
								.L_mac_overflow(),
								.L_mac_in(L_macIn),
								.mult_outa(mpy_multOutA),
								.mult_outb(mpy_multOutB),
								.mult_in(multIn),
								.mult_overflow()
								);
  always @(*) begin	 
		nextstate = state;
		nexty2_hi = y2_hi;
		nexty2_lo = y2_lo;
		nexty1_hi = y1_hi;
		nexty1_lo = y1_lo;
		nextx0 = x0;
		nextx1 = x1;
		nextx2 = x2;
		nextL_temp = L_temp;
		nexttemp = temp;
		nextyn = yn;
		y2_hiLD = 0;
		y2_loLD = 0;
		y1_hiLD = 0;
		y1_loLD = 0;
		x0LD = 0;
		x1LD = 0;
		x2LD = 0;
		L_tempLD = 0;
		tempLD = 0;
		ynLD = 0;
		x2Reset = 0;
		L_tempReset = 0;
		tempReset = 0;
		ynReset = 0;
		mpy_32_16Var1 = 0;
		mpy_32_16Var2 = 0;
		L_addOutA = 0;
		L_addOutB = 0;
		L_macOutA = 0;
		L_macOutB = 0;
		L_macOutC = 0;
		L_shlVar1Out = 0;
		L_shlNumShiftOut = 0;
		L_shlReady = 0;
		L_msuOutA = 0;
		L_msuOutB = 0;
		L_msuOutC = 0;
		L_shrVar1Out = 0;
		L_shrNumShiftOut = 0;
		multOutA = 0;
		multOutB = 0;
		L_multOutA = 0;
		L_multOutB = 0;
		done = 0;
		
		case(state)
			INIT:
			begin
				if(ready == 0)
					nextstate = INIT;
				else if(ready == 1)
				begin
					x2Reset = 1;
					L_tempReset = 1;
					tempReset = 1;
					ynReset = 1;
					nextstate = S1;
				end
			end//INIT
			
			/* x2 = x1;
				x1 = x0;
				x0 = signal[i];*/
			S1:
			begin
				nextx2 = x1;
				x2LD = 1;
				nextx1 = x0;
				x1LD = 1;
				nextx0 = xn;
				x0LD = 1;
				nextstate = S2;
			end//S1
			
			//L_tmp = Mpy_32_16(y1_hi, y1_lo, a140[1]);
			S2:
			begin
				L_multOutA = mpy_L_multOutA;
				L_multOutB = mpy_L_multOutB;
				L_macOutA = mpy_L_macOutA;
				L_macOutB = mpy_L_macOutB;
				L_macOutC = mpy_L_macOutC;
				multOutA = mpy_multOutA;
				multOutB = mpy_multOutB ;					  
				mpy_32_16Var1 = {y1_hi[15:0],y1_lo[15:0]};
				mpy_32_16Var2 = 16'd7807;
				nextL_temp = mpy_32_16In;
				L_tempLD = 1;
				nextstate = S3;
			end//S2
			
			// Mpy_32_16(y2_hi, y2_lo, a140[2]);
			S3:
			begin
				L_multOutA = mpy_L_multOutA;
				L_multOutB = mpy_L_multOutB;
				L_macOutA = mpy_L_macOutA;
				L_macOutB = mpy_L_macOutB;
				L_macOutC = mpy_L_macOutC;
				multOutA = mpy_multOutA;
				multOutB = mpy_multOutB ;					  
				mpy_32_16Var1 = {y2_hi[15:0],y2_lo[15:0]};
				mpy_32_16Var2 = 16'hf16b;
				nexttemp = mpy_32_16In;
				tempLD = 1;
				nextstate = S4;
			end//S3
			
			//L_tmp     = L_add(L_tmp, Mpy_32_16(y2_hi, y2_lo, a140[2]));
			S4:
			begin
				L_addOutA = L_temp;
				L_addOutB = temp;
				nextL_temp = L_addIn;
				L_tempLD = 1;
				nextstate = S5;
			end//S4
			
			// L_tmp     = L_mac(L_tmp, x0, b140[0]);
			S5:
			begin
				L_macOutA = x0;
				L_macOutB = 16'd1899;
				L_macOutC = L_temp;
				nextL_temp = L_macIn;
				L_tempLD = 1;
				nextstate = S6;
			end//S5
			
			//L_tmp = L_mac(L_tmp, x1, b140[1]);
			S6:
			begin
				L_macOutA = x1;
				L_macOutB = 16'hf12a;
				L_macOutC = L_temp;
				nextL_temp = L_macIn;
				L_tempLD = 1;
				nextstate = S7;
			end//S6
			
			//L_tmp = L_mac(L_tmp, x2, b140[2]);
			S7:
			begin
				L_macOutA = x2;
				L_macOutB = 16'd1899;
				L_macOutC = L_temp;
				nextL_temp = L_macIn;
				L_tempLD = 1;
				nextstate = S8;
			end//S7
			
			//L_tmp = L_shl(L_tmp, 3); 
			S8:
			begin
				L_shlVar1Out = L_temp;
				L_shlNumShiftOut = 16'd3;
				L_shlReady = 1;
				if(L_shlDone == 1)
				begin
					nextL_temp = L_shlIn;
					L_tempLD = 1;
					nextstate = S10;
				end
				else
					nextstate = S9;
			end//S8
			
			//L_tmp = L_shl(L_tmp, 3); 
			S9:
			begin
				L_shlVar1Out = L_temp;
				L_shlNumShiftOut = 16'd3;
				if(L_shlDone == 0)
					nextstate = S9;
				else if(L_shlDone == 1)
				begin
					nextL_temp = L_shlIn;
					L_tempLD = 1;
					nextstate = S10;
				end
			end//S9
			
			//signal[i] = round(L_tmp);
			S10:
			begin
				L_addOutA = L_temp;
				L_addOutB = 32'h0000_8000;				
				nextyn = L_addIn[31:16];
				ynLD = 1;
				nextstate = S11;
			end//S10
			
			/* y2_hi = y1_hi;
				y2_lo = y1_lo;*/
			S11:
			begin
				nexty2_hi = y1_hi;
				y2_hiLD = 1;
				nexty2_lo = y1_lo;
				y2_loLD = 1;
				L_shrVar1Out = L_temp;
				L_shrNumShiftOut = 16'd1;
				nexttemp = L_shrIn;
				tempLD = 1;
				nextstate = S12;
			end//S11
			
			//L_Extract(L_tmp, &y1_hi, &y1_lo);
			S12:
			begin
				L_msuOutA = L_temp[31:16];
				L_msuOutB = 16'd16384;
				L_msuOutC = temp;
				nexty1_hi = L_temp[31:16];
				y1_hiLD = 1;
				nexty1_lo = L_msuIn[15:0];
				y1_loLD = 1;
				done = 1;
				nextstate = INIT;
			end//S12
		endcase
	
	end //end always block
endmodule
