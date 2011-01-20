`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:35:35 10/18/2010 
// Module Name:    Chebps11_FSM 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function to compute 11th degree Chebyshev polynomials. It is based on the C-model
//						funtion "Chebps_10" 
// Dependencies: 	 sixway_16bitmux.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Chebps10_FSM(clk,reset,start,coeff1,coeff2,coeff3,coeff4,coeff5,coeff6,xIn,polyOrder,addIn,L_shrIn,
							L_multIn,L_macIn,L_msuIn,L_shlIn,L_shlDone,multIn,L_multOutA,L_multOutB,L_macOutA,
							L_macOutB,L_macOutC,L_msuOutA,L_msuOutB,L_msuOutC,L_shlVar1Out,L_shlNumShiftOut,
							L_shlReady,multOutA,multOutB,done,cheb,addOutA, addOutB,L_shrOutVar1,L_shrOutNumShift);

//Inputs
input clk,reset,start;
input [15:0] coeff1,coeff2,coeff3,coeff4,coeff5,coeff6;
input [15:0] xIn;
input [15:0] addIn;
input [31:0] L_shrIn;
input [15:0] polyOrder;
input [31:0] L_multIn;
input [31:0] L_macIn;
input [31:0] L_msuIn;
input [31:0] L_shlIn;
input L_shlDone;
input [15:0] multIn;

wire [15:0] coeff1,coeff2,coeff3,coeff4,coeff5,coeff6;
wire [15:0] xIn;
wire [15:0] polyOrder;
wire [31:0] L_multIn;
wire [31:0] L_macIn;
wire [31:0] L_msuIn;
wire [31:0] L_shlIn;
wire L_shlDone;
wire [15:0] multIn;


//Outputs
output reg [15:0] L_multOutA,L_multOutB; 
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;
output reg [15:0] L_msuOutA,L_msuOutB;
output reg [31:0] L_msuOutC;
output reg [31:0] L_shlVar1Out;
output reg [15:0] L_shlNumShiftOut; 
output reg L_shlReady;
output reg done;
output reg [15:0] cheb;
output reg [15:0] multOutA,multOutB;
output reg [15:0] addOutA, addOutB;
output reg [31:0] L_shrOutVar1;
output reg [15:0] L_shrOutNumShift;

//Wires
wire unusedOverflow1,unusedOverflow2,unusedOverflow3;
wire [15:0] mux1out;
wire [31:0] mpyOut;

//temp reg
reg countld,countReset;
reg [2:0] mux1sel;
reg [4:0] state,nextstate;
reg [15:0] temp0high,temp0low,temp1high,temp1low,temp2high,temp2low;
reg [15:0] nexttemp0high,nexttemp0low,nexttemp1high,nexttemp1low,nexttemp2high,nexttemp2low;
reg temp0highld,temp0lowld,temp1highld,temp1lowld,temp2highld,temp2lowld;
reg temp0highreset,temp0lowreset,temp1highreset,temp1lowreset,temp2highreset,temp2lowreset;
reg [15:0] count,nextcount;
reg tZerold,tZeroReset;
reg [31:0] tZero, nextTZero;
reg xld;
reg [15:0] x;
reg L_shlDoneReg,L_shlReset;

//state parameters

parameter INIT = 4'd0;
parameter MATH0 = 4'd1;
parameter FOR_LOOP1 = 4'd2;
parameter FOR_LOOP2 = 4'd3;
parameter FOR_LOOP3 = 4'd4;
parameter MATH1 = 4'd5;
parameter MATH2 = 4'd6;
parameter MATH3 = 4'd7;
parameter MATH4 = 4'd8;

//instantiated modules
sixway_16bitmux mux1(
							.in0(coeff1),
							.in1(coeff2),
							.in2(coeff3),
							.in3(coeff4),
							.in4(coeff5),
							.in5(coeff6),
							.sel(mux1sel),
							.out(mux1out));
				
	
//D-flip flops

always @(posedge clk)
begin

	if(reset)
		state <=	0;
	else
		state <= nextstate;
end

always @(posedge clk)
begin

	if(reset)
		count <=	2;
	else if(countReset)
		count <= 2;
	else if(countld)
		count <= nextcount ;
end			

always @(posedge clk)
begin

	if(reset)
		tZero <=	0;
	else if(tZeroReset)
		tZero <= 0;
	else if(tZerold)
		tZero <= nextTZero;
end

always @(posedge clk)
begin

	if(reset)
		temp0high <=	0;
	else if(temp0highreset)
		temp0high <= 0;
	else if(temp0highld)
		temp0high <= nexttemp0high;
end

always @(posedge clk)
begin

	if(reset)
		temp1high <=	0;
	else if(temp1highreset)
		temp1high <= 0;
	else if(temp1highld)
		temp1high <= nexttemp1high;
end

always @(posedge clk)
begin

	if(reset)
		temp2high <=	0;
	else if(temp2highreset)
		temp2high <= 0;
	else if(temp2highld)
		temp2high <= nexttemp2high;
end

always @(posedge clk)
begin

	if(reset)
		temp0low <=	0;
	else if(temp0lowreset)
		temp0low <= 0;
	else if(temp0lowld)
		temp0low <= nexttemp0low;
end

always @(posedge clk)
begin

	if(reset)
		temp1low <=	0;
	else if(temp1lowreset)
		temp1low <= 0;
	else if(temp1lowld)
		temp1low <= nexttemp1low;
end

always @(posedge clk)
begin

	if(reset)
		temp2low <=	0;
	else if(temp2lowreset)
		temp2low <= 0;
	else if(temp2lowld)
		temp2low <= nexttemp2low;
end

always @(posedge clk)
begin

	if(reset)
		x <=	0;
	else if(xld)
		x <= xIn;
end

always @(posedge clk)
begin

	if(reset)
		L_shlDoneReg <= 0;
	else if(L_shlReset)
		L_shlDoneReg <= 0;
	else if(L_shlDone)
		L_shlDoneReg <= 1;
end


always @(*)
begin

	nextstate = state;
	nextTZero = tZero;
	countReset = 0;
	countld = 0;
	tZerold = 0;
	tZeroReset = 0;	
	mux1sel = count;
	xld = 0;
	temp0highld = 0;
	temp0lowld = 0;
	temp1highld = 0;
	temp1lowld = 0;
	temp2highld = 0;
	temp2lowld = 0;
	temp0highreset = 0;
	temp0lowreset = 0;
	temp1highreset = 0;
	temp1lowreset = 0;
	temp2highreset = 0;
	temp2lowreset = 0;
	L_shlReady = 0;
	L_shlReset = 0;
	done = 0;
	/*
	L_shlReady = 0;
	L_multOutA = 0;
	L_multOutB = 0; 
	L_macOutA = 0;
	L_macOutB = 0;
	L_macOutC = 0;
	L_msuOutA = 0;
	L_msuOutB = 0;
	L_msuOutC = 0;
	L_shlVar1Out = 0;
	L_shlNumShiftOut = 0; 
	L_shlReady = 0;
	done = 0;
	cheb = 0;
	multOutA = 0;
	multOutB = 0;
	*/
	
	case(state)
		INIT:
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin
				tZeroReset = 1;	
				countReset = 1;
				temp0highreset = 1;
				temp0lowreset = 1;
				temp1highreset = 1;
				temp1lowreset = 1;
				temp2highreset = 1;
				temp2lowreset = 1;
				L_shlReset = 1;
				xld = 1;
				nextstate = MATH0;
			end
		end//state INIT
		
		MATH0:
		begin			
			mux1sel = 1;
			nexttemp2high = 16'd128;
			nexttemp2low = 16'd0;
			temp2highld = 1;
			temp2lowld = 1;
			L_multOutA = x;
			L_multOutB = 16'd256;			
			L_macOutA = mux1out;
			L_macOutB = 16'd4096;
			L_macOutC = L_multIn;
			nextTZero = L_macIn;
			nexttemp1high = L_macIn[31:16];
			temp1highld = 1;
			L_shrOutVar1 = {0,L_macIn[15:0]};
			L_shrOutNumShift = 16'd1;
			nexttemp1low = L_shrIn;
			temp1lowld = 1;
			tZerold = 1;
			nextstate = FOR_LOOP1;
		end//state MATH0
		
		FOR_LOOP1:
		begin
			if(count >= polyOrder)
				nextstate = MATH1;
			else if (count < polyOrder)//else 1
			begin
				L_multOutA = temp1high;
				L_multOutB = x;
				multOutA = temp1low;
				multOutB = x;
				L_macOutA = multIn;
				L_macOutB = 16'd1;
				L_macOutC = L_multIn;
				nextTZero = L_macIn;
				tZerold = 1;
				L_shlReset = 1;
				nextstate = FOR_LOOP2;
			end//end else1
		end//state FOR_LOOP1
		
		FOR_LOOP2:
		begin
			
			L_shlVar1Out = tZero;
			L_shlNumShiftOut = 16'd1;
			L_shlReady = 1;
			if(L_shlDoneReg == 0)
				nextstate = FOR_LOOP2;
			else if(L_shlDoneReg == 1)
			begin
				L_shlReady = 0;
				L_macOutA = temp2high;
				L_macOutB = 16'h8000;
				L_macOutC = L_shlIn;
				L_msuOutA = temp2low;
				L_msuOutB = 16'd1;
				L_msuOutC = L_macIn;
				nextTZero = L_msuIn;
				tZerold = 1;
				nextstate = FOR_LOOP3;
			end
		end//state FOR_LOOP2
		
		FOR_LOOP3:
		begin
			L_macOutA = mux1out;
			L_macOutB = 16'd4096;
			L_macOutC = tZero;
			nextTZero = L_macIn;
			tZerold = 1;
			nexttemp0high = L_macIn[31:16];
			temp0highld = 1;
			L_shrOutVar1 = {0,L_macIn[15:0]};
			L_shrOutNumShift = 16'd1;			
			nexttemp0low = L_shrIn;
			temp0lowld = 1;
			nexttemp2low = temp1low;
			temp2lowld = 1;
			nexttemp2high = temp1high;
			temp2highld = 1;
			nexttemp1low = nexttemp0low;
			temp1lowld = 1;
			nexttemp1high = nexttemp0high;
			temp1highld = 1;
			addOutA = count;
			addOutB = 16'd1;
			nextcount = addIn;
			countld = 1;
			nextstate = FOR_LOOP1;
		end//state FOR_LOOP3
		
		MATH1:
		begin
			L_shlReset = 1;
			L_multOutA = temp1high;
			L_multOutB = x;
			multOutA = temp1low;
			multOutB = x;
			L_macOutA = multIn;
			L_macOutB = 16'd1;
			L_macOutC = L_multIn;
			nextTZero = L_macIn;
			tZerold = 1;
			nextstate = MATH2;
		end//state MATH1
		
		MATH2:
		begin
			L_macOutA = temp2high;
			L_macOutB = 16'h8000;
			L_macOutC = tZero;
			L_msuOutA = temp2low;
			L_msuOutB = 16'd1;
			L_msuOutC = L_macIn;
			nextTZero = L_msuIn;
			tZerold = 1;
			nextstate = MATH3;
		end//state MATH2
		
		MATH3:
		begin			
			L_macOutA = mux1out;
			L_macOutB = 16'd2048;
			L_macOutC = tZero;	
			nextTZero = L_macIn;
			tZerold = 1;
			nextstate = MATH4;
		end //state MATH3
		
		MATH4:
		begin
			L_shlVar1Out = tZero;
			L_shlNumShiftOut = 16'd7;
			L_shlReady = 1;
			if(L_shlDoneReg == 0)
				nextstate = MATH4;
			else if(L_shlDoneReg == 1)
			begin
				L_shlReady = 0;
				cheb = L_shlIn[31:16];
				done = 1;			
				nextstate = INIT;
			end
		end
		
endcase

end//end always
							
endmodule
