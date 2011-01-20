`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    16:52:45 10/21/2010 
// Module Name:    A(z)_toLSP_FSM 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an FSM to perform A(z) to LSP conversion, modeled after the C-model function "Az_lsp".
// 
// Dependencies: 	 regArraySize6.v, Chebps10_FSM.v, Chebps11_FSM.v, twoway_16bit_mux.v, gridPointsMem.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Az_toLSP_FSM(clk,reset,start,addIn,subIn,shrIn,L_shrIn,L_addIn,L_subIn,multIn,L_multIn,L_macIn, L_msuIn,L_shlIn,L_shlDone,
						  norm_sIn,norm_sDone,lspIn,L_multOverflow,L_macOverflow,L_msuOverflow,addOutA,
						  addOutB,subOutA,subOutB,shrOutVar1,shrOutVar2,L_shrOutVar1,L_shrOutNumShift,L_addOutA,L_addOutB,L_subOutA,L_subOutB,multOutA,multOutB,L_multOutA,L_multOutB,L_macOutA,L_macOutB,
						  L_macOutC,L_msuOutA,L_msuOutB,L_msuOutC,L_shlVar1Out,L_shlNumShiftOut,L_shlReady,norm_sOut,
						  norm_sReady,lspWriteRequested,lspReadRequested,lspOut,lspWrite,divErr,done);
`include "paramList.v"
//Inputs
input clk,reset,start;
input [15:0] addIn;
input [15:0] subIn;
input [15:0] shrIn;
input [31:0] L_shrIn;
input [31:0] L_addIn;
input [31:0] L_subIn;
input [15:0] multIn;
input [31:0] L_multIn;
input [31:0] L_macIn;
input [31:0] L_msuIn;
input [31:0] L_shlIn;
input L_shlDone;
input [15:0] norm_sIn;
input norm_sDone;
input [31:0] lspIn;
input L_multOverflow;
input L_macOverflow;
input L_msuOverflow;

//Outputs
output reg signed [15:0] addOutA,addOutB;
output reg signed [15:0] subOutA,subOutB;
output reg signed [15:0] shrOutVar1,shrOutVar2;
output reg signed [31:0] L_shrOutVar1;
output reg signed [15:0] L_shrOutNumShift;
output reg [31:0] L_addOutA,L_addOutB;
output reg signed [31:0] L_subOutA,L_subOutB;
output reg [15:0] multOutA,multOutB;
output reg [15:0] L_multOutA,L_multOutB;
output reg [15:0] L_macOutA,L_macOutB;
output reg [31:0] L_macOutC;
output reg [15:0] L_msuOutA,L_msuOutB;
output reg [31:0] L_msuOutC;
output reg [31:0] L_shlVar1Out;
output reg [15:0] L_shlNumShiftOut;
output reg L_shlReady;
output reg [15:0] norm_sOut;
output reg norm_sReady;
output reg [10:0] lspWriteRequested;
output reg [10:0] lspReadRequested;
output reg [31:0] lspOut;
output reg lspWrite;
output divErr;
output reg done;


//Working wires,
wire [15:0] fOneIn1,fOneIn2,fOneIn3,fOneIn4,fOneIn5,fOneIn6;
wire [15:0] fTwoIn1,fTwoIn2,fTwoIn3,fTwoIn4,fTwoIn5,fTwoIn6;
wire [15:0] mux1out, mux2out, mux3out, mux4out, mux5out, mux6out, mux7out;
wire [15:0] div_sIn;
wire div_sDone;

//cheb10 wires
wire [15:0] cheb10L_shrOutNumShift;
wire [15:0] cheb10L_shrOutVar1;
wire [15:0] cheb10addOutA,cheb10addOutB;
wire [15:0] cheb10L_multOutA, cheb10L_multOutB;
wire [15:0] cheb10L_macOutA, cheb10L_macOutB;
wire [31:0] cheb10L_macOutC;
wire [15:0] cheb10L_msuOutA, cheb10L_msuOutB;
wire [31:0] cheb10L_msuOutC;
wire [31:0] cheb10L_shlVar1Out;
wire [15:0] cheb10L_shlNumShiftOut;
wire cheb10L_shlReady;
wire [15:0] cheb10multOutA,cheb10multOutB;
wire cheb10done;
wire [15:0] cheb10out;

//cheb11 wires
wire [15:0] cheb11L_shrOutNumShift;
wire [31:0] cheb11L_shrOutVar1;
wire [15:0] cheb11addOutA,cheb11addOutB;
wire [15:0] cheb11L_multOutA, cheb11L_multOutB;
wire [15:0] cheb11L_macOutA, cheb11L_macOutB;
wire [31:0] cheb11L_macOutC;
wire [15:0] cheb11L_msuOutA, cheb11L_msuOutB;
wire [31:0] cheb11L_msuOutC;
wire [31:0] cheb11L_shlVar1Out;
wire [15:0] cheb11L_shlNumShiftOut;
wire cheb11L_shlReady;
wire [15:0] cheb11multOutA,cheb11multOutB;
wire cheb11done;
wire [15:0] cheb11out;
wire [15:0] gridOut;
wire leftShiftDone;
assign leftShiftDone = L_shlDone;
wire signed [31:0] L_multIn;

wire signed [31:0] div_sL_subOutA,div_sL_subOutB;

//Working regs
reg pChebpsSel;
reg coeffSel,nextcoeffSel,coeffSelld;
reg lowMidsel;
reg overflowReg,overflowReset,overflowld;
reg [5:0] state,nextstate;
reg countld,countReset;
reg [4:0] count,nextcount;
reg jCountld,jCountReset;
reg [5:0] jCount,nextjCount;
reg nfCountld,nfCountReset;
reg [4:0] nfCount,nextnfCount;
reg [15:0] fOneOut,fTwoOut;
reg [3:0] fOneRequested,fTwoRequested;
reg fOneld,fTwold;
reg signed [15:0] xLow,xMid,xHigh,xInt;
reg [15:0] nextxLow,nextxMid,nextxHigh,nextxInt;
reg xLowReset,xMidReset,xHighReset,xIntReset;
reg xLowld,xMidld,xHighld,xIntld;
reg [15:0] yLow,yMid,yHigh;
reg [15:0] nextyLow,nextyMid,nextyHigh;
reg yLowReset,yMidReset,yHighReset;
reg yLowld,yMidld,yHighld;
reg [31:0]tZero,nexttZero;
reg tZeroReset,tZerold;
reg [15:0] exp,nextexp;
reg expld,expReset;
reg [15:0] tempX,nexttempX;
reg [15:0] tempY,nexttempY;
reg tempXreset,tempXld;
reg tempYreset,tempYld;
reg sign,nextSign,signLd,signReset;
reg [4:0] tempSub; 
reg [15:0] div_sOutA, div_sOutB;
reg div_sReady;

//cheb10 regs
reg cheb10start;

//cheb11 regs
reg cheb11start;

//D flip flops
//State flip-flop
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
		coeffSel <= 0;
	else if(coeffSelld)
		coeffSel <= nextcoeffSel;
end

//counter flip flop
always @(posedge clk)
begin
	if(reset)
		count <= 0;
	else if(countReset)
		count <= 0;
	else if(countld)
		count <= nextcount;
end

//j counter flip flop
always @(posedge clk)
begin
	if(reset)
		jCount <= 0;
	else if(jCountReset)
		jCount <= 0;
	else if(jCountld)
		jCount <= nextjCount;
end

//nf counter flip flop
always @(posedge clk)
begin
	if(reset)
		nfCount <= 0;
	else if(nfCountReset)
		nfCount <= 0;
	else if(nfCountld)
		nfCount <= nextnfCount;
end

//overflow flipflop
always @(posedge clk)
begin
	if(reset)
		overflowReg <= 0;
	else if(overflowReset)
		overflowReg <= 0;
	else if(overflowld)
		overflowReg <=  1;
end

always @(posedge clk)
begin
	if(reset)
		xLow <= 0;
	else if(xLowReset)
		xLow <= 0;
	else if(xLowld)
		xLow <=  nextxLow;
end

always @(posedge clk)
begin
	if(reset)
		xMid <= 0;
	else if(xMidReset)
		xMid <= 0;
	else if(xMidld)
		xMid <=  nextxMid;
end

always @(posedge clk)
begin
	if(reset)
		xHigh <= 0;
	else if(xHighReset)
		xHigh <= 0;
	else if(xHighld)
		xHigh <=  nextxHigh;
end

always @(posedge clk)
begin
	if(reset)
		xInt <= 0;
	else if(xIntReset)
		xInt <= 0;
	else if(xIntld)
		xInt <=  nextxInt;
end

always @(posedge clk)
begin
	if(reset)
		yLow <= 0;
	else if(yLowReset)
		yLow <= 0;
	else if(yLowld)
		yLow <=  nextyLow;
end

always @(posedge clk)
begin
	if(reset)
		yMid <= 0;
	else if(yMidReset)
		yMid <= 0;
	else if(yMidld)
		yMid <=  nextyMid;
end

always @(posedge clk)
begin
	if(reset)
		yHigh <= 0;
	else if(yHighReset)
		yHigh <= 0;
	else if(yHighld)
		yHigh <=  nextyHigh;
end

always @(posedge clk)
begin
	if(reset)
		tZero <= 0;
	else if(tZeroReset)
		tZero <= 0;
	else if(tZerold)
		tZero <=  nexttZero;
end

always @(posedge clk)
begin
	if(reset)
		exp <= 0;
	else if(expReset)
		exp <= 0;
	else if(expld)
		exp <=  nextexp;
end

always @(posedge clk)
begin
	if(reset)
		tempX <= 0;
	else if(tempXreset)
		tempX <= 0;
	else if(tempXld)
		tempX <=  nexttempX;
end

always @(posedge clk)
begin
	if(reset)
		tempY <= 0;
	else if(tempYreset)
		tempY <= 0;
	else if(tempYld)
		tempY <=  nexttempY;
end

always @(posedge clk)
begin
	if(reset)
		sign <= 0;
	else if(signReset)
		sign <= 0;
	else if(signLd)
		sign <=  nextSign;
end

//state parameters
parameter INIT = 6'd0;
parameter MATH_INIT = 6'd1;
parameter FOR_LOOP_CHECK1 = 6'd2;
parameter MATH0 = 6'd3;
parameter MATH1 = 6'd4;
parameter MATH2 = 6'd5;
parameter CHEB1 = 6'd6;
parameter FOR_LOOP_CHECK2 = 6'd7;
parameter MATH3 = 6'd8;
parameter MATH4 = 6'd9;
parameter MATH5 = 6'd10;
parameter CHEB2 = 6'd11;
parameter WHILE_LOOP_CHECK1 = 6'd12;
parameter XLOW_WAIT = 6'd13;
parameter CHEB3 = 6'd14;
parameter FOR_LOOP_CHECK3 = 6'd15;
parameter INTERPOLATION1 = 6'd16;
parameter INTERPOLATION1_5 = 6'd17;
parameter INTERPOLATION2 = 6'd18;
parameter INTERPOLATION3 = 6'd19;
parameter INTERPOLATION3_25 = 6'd20;
parameter INTERPOLATION3_5 = 6'd21;
parameter INTERPOLATION4 = 6'd22;
parameter INTERPOLATION5 = 6'd23;
parameter INTERPOLATION6 = 6'd24;
parameter CHEB4 = 6'd25;
parameter ROOTS_CHECK = 6'd26;
parameter COUNT_INCREMENT0 = 6'd27;
parameter COUNT_INCREMENT1 = 6'd28;
parameter COUNT_INCREMENT2 = 6'd29;
parameter ROOTS_CHECK_WAIT1 = 6'd30;
parameter ROOTS_CHECK_WAIT2 = 6'd31; 
parameter MEM_WAIT1 = 6'd32;
parameter MEM_WAIT2 = 6'd33;
parameter MEM_WAIT3 = 6'd34;
parameter MEM_WAIT4 = 6'd35;
parameter MEM_WAIT5 = 6'd36;
parameter MEM_WAIT6 = 6'd37;
parameter MEM_WAIT7 = 6'd38;
parameter MEM_WAIT8 = 6'd39;
parameter CHEB3_5 = 6'd30;
parameter CHEBPS_10 = 1'd0;
parameter CHEBPS_11 = 1'd1;

//Instantiated Modules
regArraySize6 fOne(
						 .clk(clk),
						 .reset(reset),
						 .q(fOneOut),
						 .d1(fOneIn1),
						 .d2(fOneIn2),
						 .d3(fOneIn3),
						 .d4(fOneIn4),
						 .d5(fOneIn5),
						 .d6(fOneIn6),	
						 .ld(fOneld),
						 .sel(fOneRequested)
						);
						
regArraySize6 fTwo(
						 .clk(clk),
						 .reset(reset),
						 .q(fTwoOut),
						 .d1(fTwoIn1),
						 .d2(fTwoIn2),
						 .d3(fTwoIn3),
						 .d4(fTwoIn4),
						 .d5(fTwoIn5),
						 .d6(fTwoIn6),	
						 .ld(fTwold),
						 .sel(fTwoRequested)
						);	
Chebps10_FSM cheb10(
							 .clk(clk),
							 .reset(reset||cheb10reset),
							 .start(cheb10start),
							 .coeff1(mux1out),
							 .coeff2(mux2out),
							 .coeff3(mux3out),
							 .coeff4(mux4out),
							 .coeff5(mux5out),
							 .coeff6(mux6out),
							 .xIn(mux7out),
							 .polyOrder(16'd5),
							 .addIn(addIn),
							 .L_shrIn(L_shrIn),
							 .L_multIn(L_multIn),
							 .L_macIn(L_macIn),
							 .L_msuIn(L_msuIn),
							 .L_shlIn(L_shlIn),
							 .L_shlDone(L_shlDone),
							 .multIn(multIn),
							 .L_shrOutVar1(cheb10L_shrOutVar1),
							 .L_shrOutNumShift(cheb10L_shrOutNumShift),
							 .addOutA(cheb10addOutA),
							 .addOutB(cheb10addOutB),
							 .L_multOutA(cheb10L_multOutA),
							 .L_multOutB(cheb10L_multOutB),
							 .L_macOutA(cheb10L_macOutA),
							 .L_macOutB(cheb10L_macOutB),
							 .L_macOutC(cheb10L_macOutC),
							 .L_msuOutA(cheb10L_msuOutA),
							 .L_msuOutB(cheb10L_msuOutB),
							 .L_msuOutC(cheb10L_msuOutC),
							 .L_shlVar1Out(cheb10L_shlVar1Out),
							 .L_shlNumShiftOut(cheb10L_shlNumShiftOut),
							 .L_shlReady(cheb10L_shlReady),
							 .multOutA(cheb10multOutA),
							 .multOutB(cheb10multOutB),
							 .done(cheb10done),
							 .cheb(cheb10out)
							);		
Chebps11_FSM cheb11(
							 .clk(clk),
							 .reset(reset||cheb11reset),
							 .start(cheb11start),
							 .coeff1(mux1out),
							 .coeff2(mux2out),
							 .coeff3(mux3out),
							 .coeff4(mux4out),
							 .coeff5(mux5out),
							 .coeff6(mux6out),
							 .xIn(mux7out),
							 .polyOrder(16'd5),
							 .addIn(addIn),
							 .L_shrIn(L_shrIn),
							 .L_multIn(L_multIn),
							 .L_macIn(L_macIn),
							 .L_msuIn(L_msuIn),
							 .L_shlIn(L_shlIn),
							 .L_shlDone(L_shlDone),
							 .multIn(multIn),
							 .L_shrOutVar1(cheb11L_shrOutVar1),
							 .L_shrOutNumShift(cheb11L_shrOutNumShift),
							 .addOutA(cheb11addOutA),
							 .addOutB(cheb11addOutB),
							 .L_multOutA(cheb11L_multOutA),
							 .L_multOutB(cheb11L_multOutB),
							 .L_macOutA(cheb11L_macOutA),
							 .L_macOutB(cheb11L_macOutB),
							 .L_macOutC(cheb11L_macOutC),
							 .L_msuOutA(cheb11L_msuOutA),
							 .L_msuOutB(cheb11L_msuOutB),
							 .L_msuOutC(cheb11L_msuOutC),
							 .L_shlVar1Out(cheb11L_shlVar1Out),
							 .L_shlNumShiftOut(cheb11L_shlNumShiftOut),
							 .L_shlReady(cheb11L_shlReady),
							 .multOutA(cheb11multOutA),
							 .multOutB(cheb11multOutB),
							 .done(cheb11done),
							 .cheb(cheb11out)
							);
								
twoway_16bit_mux mux1(
							 .in0(fOneIn1),
							 .in1(fTwoIn1),
							 .sel(coeffSel),
							 .out(mux1out)
							 );
twoway_16bit_mux mux2(
							 .in0(fOneIn2),
							 .in1(fTwoIn2),
							 .sel(coeffSel),
							 .out(mux2out)
							 );
twoway_16bit_mux mux3(
							 .in0(fOneIn3),
							 .in1(fTwoIn3),
							 .sel(coeffSel),
							 .out(mux3out)
							 );
twoway_16bit_mux mux4(
							 .in0(fOneIn4),
							 .in1(fTwoIn4),
							 .sel(coeffSel),
							 .out(mux4out)
							 );
twoway_16bit_mux mux5(
							 .in0(fOneIn5),
							 .in1(fTwoIn5),
							 .sel(coeffSel),
							 .out(mux5out)
							 );
twoway_16bit_mux mux6(
							 .in0(fOneIn6),
							 .in1(fTwoIn6),
							 .sel(coeffSel),
							 .out(mux6out)
							 );
twoway_16bit_mux mux7(
							 .in0(nextxLow),
							 .in1(nextxMid),
							 .sel(lowMidsel),
							 .out(mux7out)
							 );
gridPointsMem gridMem(
							 .in(jCount),
							 .out(gridOut)
							);
div_s divS(
				.clock(clk),
				.reset(reset),
				.a(div_sOutA),
				.b(div_sOutB),
				.div_err(divErr),
				.out(div_sIn),
				.start(div_sReady),
				.done(div_sDone),
				.subouta(div_sL_subOutA),
				.suboutb(div_sL_subOutB),
				.subin(L_subIn),
				.overflow()
			);				
							

//overflow always block
always @(*)
begin
	if(L_multOverflow||L_macOverflow||L_msuOverflow)
		overflowld = 1;
	else 
		overflowld = 0;
end

//FSM always block
always@(*)
begin
	countld = 0;
	countReset = 0;	
	overflowReset = 0;
	jCountld = 0;
	jCountReset = 0;
	nfCountld = 0;
	nfCountReset = 0;
	cheb10start = 0;
	cheb11start = 0;
	fOneld = 0;
	fTwold = 0;
	xLowReset = 0;
	xMidReset = 0;
	xHighReset = 0;
	xIntReset = 0;
	xLowld = 0;
	xMidld = 0;
	xHighld = 0;	
	xIntld = 0;
	yLowReset = 0;
	yMidReset = 0;
	yHighReset = 0;
	yLowld = 0;
	yMidld = 0;
	yHighld = 0;	
	tZeroReset = 0;
	tZerold = 0;
	expld = 0;
	expReset = 0;
	tempXreset = 0;
	tempYreset = 0;
	tempXld = 0;
	tempYld = 0;
	nextxLow = xLow;
	nextxMid = xMid;
	nextxHigh = xHigh;	
	nextxInt = xInt;
	nextyLow = yLow;
	nextyMid = yMid;
	nextyHigh = yHigh;
	nexttZero = tZero;
	nextexp = exp;
	nextstate = state;
	lowMidsel = 0;
	coeffSelld = 0;
	lspWrite = 0;
	addOutA = 0;
	addOutB = 0;
	multOutA = 0;
	multOutB = 0;
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
	//norm_sOut = 0;
	norm_sReady = 0;
	div_sReady = 0;
	nextSign = sign;
	signLd = 0;
	signReset = 0;
	nextcount = count;
	nextjCount = jCount;
	nextnfCount = nfCount;
	done = 0;
	
	case(state)
		INIT: 
		begin
			if(start == 0)
				nextstate = INIT;
			else if(start == 1)
			begin
				countReset = 1;
				jCountReset = 1;
				nfCountReset = 1;
				overflowReset = 1;
				xLowReset = 1;
				xMidReset = 1;
				xHighReset = 1;			
				xIntReset = 1;
				yLowReset = 1;
				yMidReset = 1;
				yHighReset = 1;
				tZeroReset = 1;
				expReset = 1;
				tempXreset = 1;
				tempYreset = 1;	
				signReset = 1;  
				nextstate = MATH_INIT;
			end
		end//INIT
		
		MATH_INIT:
		begin
			pChebpsSel = CHEBPS_11;
			fOneRequested = 0;
			fOneOut = 16'd2048;
			fOneld = 1;
			fTwoRequested = 0;
			fTwoOut = 16'd2048;
			fTwold = 1;
			nextstate = FOR_LOOP_CHECK1;
		end//MATH_INIT
		
		FOR_LOOP_CHECK1:
		begin
			if(count >= 5)
				nextstate = CHEB1;
			else if(count < 5)
			begin
				addOutA = count;
				addOutB = 16'd1;
				lspReadRequested = {LEVINSON_DURBIN_A[10:5],addIn[4:0]};
				nextstate = MEM_WAIT1;
			end
		end//FOR_LOOP_CHECK1
		
		MEM_WAIT1:
		begin
			addOutA = count;
			addOutB = 16'd1;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],addIn[4:0]};
			L_multOutA = lspIn[15:0];
			L_multOutB = 16'd16384;
			nexttZero = L_multIn;
			tZerold = 1;
			nextstate = MATH0;	
		end//MEM_WAIT1
		
		MATH0:
		begin
			L_subOutA = 32'd10;
			L_subOutB = count;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],L_subIn[4:0]};
			nextstate = MEM_WAIT2;
		end//MATH0
		
		MEM_WAIT2:
		begin
			L_subOutA = 32'd10;
			L_subOutB = count;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],L_subIn[4:0]};
			L_macOutB = 16'd16384;
			L_macOutC = tZero;
			L_macOutA = lspIn[15:0];
			nexttZero = L_macIn;
			tZerold = 1;
			nextstate = MATH1;
			addOutA = count;
			addOutB = 16'd1;
			fOneRequested = addIn;
			
			case(count)
				'd0:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn1;
						fOneOut = subIn;
					end
				'd1:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn2;
						fOneOut = subIn;
					end
				'd2:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn3;
						fOneOut = subIn;
					end
				'd3:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn4;
						fOneOut = subIn;
					end
				'd4:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn5;
						fOneOut = subIn;
					end
				'd5:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn6;
						fOneOut = subIn;
					end
			endcase
			fOneld = 1;		
		end
		
		MATH1:
		begin
			addOutA = count;
			addOutB = 16'd1;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],addIn[4:0]};
			nextstate = MEM_WAIT3;
		end//MATH1
		
		MEM_WAIT3:
		begin
			addOutA = count;
			addOutB = 16'd1;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],addIn[4:0]};
			L_multOutA = lspIn[15:0];
			L_multOutB = 16'd16384;
			nexttZero = L_multIn;
			tZerold = 1;
			nextstate = MATH2;
		end//MEM_WAIT3:
		
		MATH2:
		begin
			subOutA = 16'd10;
			subOutB = count;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],subIn[4:0]};
			nextstate = MEM_WAIT4;			
		end//MATH2
		
		MEM_WAIT4:
		begin
			subOutA = 16'd10;
			subOutB = count;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],subIn[4:0]};
			L_msuOutA = lspIn[15:0];
			L_msuOutB = 16'd16384;
			L_msuOutC = tZero;			
			nexttZero = L_msuIn;
			tZerold = 1;
			L_addOutA = count;
			L_addOutB = 32'd1;
			fTwoRequested = L_addIn;
			case(count)
				'd0:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn1;
						fTwoOut = addIn;
					end
				'd1:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn2;
						fTwoOut = addIn;
					end
				'd2:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn3;
						fTwoOut = addIn;
					end
				'd3:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn4;
						fTwoOut = addIn;
					end
				'd4:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn5;
						fTwoOut = addIn;
					end
				'd5:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn6;
						fTwoOut = addIn;
					end
			endcase
			fTwold = 1;
			L_macOutA = 16'd1;
			L_macOutB = 16'd1;
			L_macOutC = count;
			nextcount = L_macIn;
						
			nextstate = COUNT_INCREMENT0;
		
		end//MEM_WAIT4
		
		COUNT_INCREMENT0:
		begin
			addOutA = count;
			addOutB = 16'd1;
			nextcount = addIn;
			countld = 1;
			nextstate = FOR_LOOP_CHECK1;
		end
		
		CHEB1:
		begin
			if(overflowReg)
			begin
				pChebpsSel = CHEBPS_10;
				fOneRequested = 0;
				fTwoRequested = 0;
				fOneOut = 16'd1024;
				fTwoOut = 16'd1024;
				overflowReset = 1;
				countReset = 1;
				nextstate = FOR_LOOP_CHECK2;
				end
			else
				nextstate = CHEB2;
		end //CHEB1
		
		FOR_LOOP_CHECK2:
		begin
			if(count >= 5)
			begin
				nextstate = CHEB2;
			end
			
			else if(count < 5)
			begin
				addOutA = count;
				addOutB = 16'd1;
				lspReadRequested = {LEVINSON_DURBIN_A[10:5],addIn[4:0]};
				nextstate = MEM_WAIT5;
			end
		end//FOR_LOOP_CHECK2
		
		MEM_WAIT5:
		begin
			addOutA = count;
			addOutB = 16'd1;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],addIn[4:0]};
			L_multOutA = lspIn;
			L_multOutB = 16'd8192;
			nexttZero = L_multIn;
			tZerold = 1;
			nextstate = MATH3;
		end//MEM_WAIT5
		
		MATH3:
		begin
			L_subOutA = 32'd10;
			L_subOutB = count;			
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],L_subIn[4:0]};
			nextstate = MEM_WAIT6;
		end	//MATH3
		
		MEM_WAIT6:
		begin
			L_subOutA = 32'd10;
			L_subOutB = count;			
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],L_subIn[4:0]};
			L_macOutA = lspIn[15:0];
			L_macOutB = 16'd8192;
			L_macOutC = tZero;
			nexttZero = L_macIn;
			tZerold = 1;
			addOutA = count;
			addOutB = 16'd1;
			fOneRequested = addIn;
			case(count)
				'd0:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn1;
						fOneOut = subIn;
					end
				'd1:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn2;
						fOneOut = subIn;
					end
				'd2:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn3;
						fOneOut = subIn;
					end
				'd3:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn4;
						fOneOut = subIn;
					end
				'd4:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn5;
						fOneOut = subIn;
					end
				'd5:
					begin
						subOutA = L_macIn[31:16];
						subOutB = fOneIn6;
						fOneOut = subIn;
					end
			endcase
			fOneld = 1;	
			nextstate = MATH4;		
		end//MEM_WAIT6
		
		MATH4:
		begin
			addOutA = count;
			addOutB = 16'd1;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],addIn[4:0]};
			nextstate = MEM_WAIT7;
		end//MATH4
		
		MEM_WAIT7:
		begin
			addOutA = count;
			addOutB = 16'd1;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],addIn[4:0]};
			L_multOutA = lspIn[15:0];
			L_multOutB = 8192;
			nexttZero = L_multIn;
			tZerold = 1;
			nextstate = MATH5;
		end//MEM_WAIT7
		
		MATH5:
		begin
			subOutA = 16'd10;
			subOutB = count;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],subIn[4:0]};
			nextstate = MEM_WAIT8;
		end//MATH5
		
		MEM_WAIT8:
		begin
			subOutA = 16'd10;
			subOutB = count;
			lspReadRequested = {LEVINSON_DURBIN_A[10:5],subIn[4:0]};
			L_msuOutA = lspIn;
			L_msuOutB = 16'd8192;
			L_msuOutC = tZero;
			nexttZero = L_msuIn;
			tZerold = 1;
			L_addOutA = count;
			L_addOutB = 32'd1;
			fTwoRequested = L_addIn;
			case(count)
				'd0:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn1;
						fTwoOut = addIn;
					end
				'd1:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn2;
						fTwoOut = addIn;
					end
				'd2:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn3;
						fTwoOut = addIn;
					end
				'd3:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn4;
						fTwoOut = addIn;
					end
				'd4:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn5;
						fTwoOut = addIn;
					end
				'd5:
					begin
						addOutA = L_msuIn[31:16];
						addOutB = fTwoIn6;
						fTwoOut = addIn;
					end
			endcase
			fTwold = 1;
			L_macOutA = 16'd1;
			L_macOutB = 16'd1;
			L_macOutC = count;
			nextcount = L_macIn;						
			nextstate = COUNT_INCREMENT1;
		end//MEM_WAIT8
		
		COUNT_INCREMENT1:
		begin
			addOutA = count;
			addOutB = 16'd1;
			nextcount = addIn;
			countld = 1;
			nextstate = FOR_LOOP_CHECK2;
		end
		
		CHEB2:
		begin
			nextxLow = gridOut;
			if(pChebpsSel == CHEBPS_11)
			begin
				 lowMidsel = 0;	
				 addOutA = cheb11addOutA;
				 addOutB = cheb11addOutB;
				 L_shrOutVar1 = cheb11L_shrOutVar1;
				 L_shrOutNumShift = cheb11L_shrOutNumShift;
				 L_multOutA = cheb11L_multOutA;
				 L_multOutB = cheb11L_multOutB;
				 L_macOutA = cheb11L_macOutA;
				 L_macOutB = cheb11L_macOutB;
				 L_macOutC = cheb11L_macOutC;
				 L_msuOutA = cheb11L_msuOutA;
				 L_msuOutB = cheb11L_msuOutB;
				 L_msuOutC = cheb11L_msuOutC;
				 L_shlVar1Out = cheb11L_shlVar1Out;
				 L_shlNumShiftOut = cheb11L_shlNumShiftOut;
				 L_shlReady = cheb11L_shlReady;
				 multOutA = cheb11multOutA;
				 multOutB = cheb11multOutB;
				 cheb11start = 1;
				 if(cheb11done == 0)
					nextstate = CHEB2;
				else if(cheb11done == 1)
				begin
					cheb11start = 0;
					nextyLow = cheb11out;
					yLowld = 1;
					nextxLow = gridOut;
					xLowld = 1;
					nfCountReset = 1;
					jCountReset = 1;	
					nextstate = WHILE_LOOP_CHECK1;
				end
			end	//if(pChebpsSel = CHEBPS_11)
			else if (pChebpsSel == CHEBPS_10)						
			begin
				 lowMidsel = 0;
				 addOutA = cheb10addOutA;
				 addOutB = cheb10addOutB;
				 L_shrOutVar1 = cheb10L_shrOutVar1;
				 L_shrOutNumShift = cheb10L_shrOutNumShift;
				 L_multOutA = cheb10L_multOutA;
				 L_multOutB = cheb10L_multOutB;
				 L_macOutA = cheb10L_macOutA;
				 L_macOutB = cheb10L_macOutB;
				 L_macOutC = cheb10L_macOutC;
				 L_msuOutA = cheb10L_msuOutA;
				 L_msuOutB = cheb10L_msuOutB;
				 L_msuOutC = cheb10L_msuOutC;
				 L_shlVar1Out = cheb10L_shlVar1Out;
				 L_shlNumShiftOut = cheb10L_shlNumShiftOut;
				 L_shlReady = cheb10L_shlReady;
				 multOutA = cheb10multOutA;
				 multOutB = cheb10multOutB;
				 cheb10start = 1;
				 if(cheb10done == 0)
					nextstate = CHEB2;
				else if(cheb10done == 1)
				begin
					cheb10start = 0;
					nextyLow = cheb10out;
					yLowld = 1;
					nextxLow = gridOut;
					xLowld = 1;
					nfCountReset = 1;
					jCountReset = 1;					
					nextstate = WHILE_LOOP_CHECK1;
				end
			end///if(pChebpsSel = CHEBPS_10)
		end//CHEB2
		
		WHILE_LOOP_CHECK1:
		begin	
			if((nfCount>=10) &&(jCount >=60))
			begin
				nextstate = ROOTS_CHECK;
				countReset = 1;
			end
			
			else if((nfCount<10)||(jCount<60))
			begin			
				addOutA = jCount;
				addOutB = 16'd1;
				nextjCount = addIn;
				jCountld = 1;
				nextxHigh = xLow;
				xHighld = 1;
				nextyHigh = yLow;
				yHighld = 1;
				nextstate = XLOW_WAIT;
				signReset = 1;
			end
			end//WHILE_LOOP_CHECK1:
		
		XLOW_WAIT:
		begin
			nextxLow = gridOut;
			xLowld = 1;
			nextstate = CHEB3;
		end//XLOW_WAIT		
		
		CHEB3:
		begin
			if(pChebpsSel == CHEBPS_11)
			begin
				 lowMidsel = 0;
				 addOutA = cheb11addOutA;
				 addOutB = cheb11addOutB;
				 L_shrOutVar1 = cheb11L_shrOutVar1;
				 L_shrOutNumShift = cheb11L_shrOutNumShift;			 
				 L_multOutA = cheb11L_multOutA;
				 L_multOutB = cheb11L_multOutB;
				 L_macOutA = cheb11L_macOutA;
				 L_macOutB = cheb11L_macOutB;
				 L_macOutC = cheb11L_macOutC;
				 L_msuOutA = cheb11L_msuOutA;
				 L_msuOutB = cheb11L_msuOutB;
				 L_msuOutC = cheb11L_msuOutC;
				 L_shlVar1Out = cheb11L_shlVar1Out;
				 L_shlNumShiftOut = cheb11L_shlNumShiftOut;
				 L_shlReady = cheb11L_shlReady;
				 multOutA = cheb11multOutA;
				 multOutB = cheb11multOutB;
				 cheb11start = 1;
				 if(cheb11done == 0)
					nextstate = CHEB3;
				else if(cheb11done == 1)
				begin
					cheb11start = 0;
					nextyLow = cheb11out;
					yLowld = 1;
					L_multOutA = nextyLow;
					L_multOutB = yHigh;
					if(L_multIn == 0 || L_multIn[31] == 1)
					begin
						nextstate = FOR_LOOP_CHECK3;
						countReset = 1;
					end	
					else
						nextstate = WHILE_LOOP_CHECK1;
				end
			end	//if(pChebpsSel = CHEBPS_11)
			else if (pChebpsSel == CHEBPS_10)						
			begin
				 lowMidsel = 0;
				 addOutA = cheb10addOutA;
				 addOutB = cheb10addOutB;
				 L_shrOutVar1 = cheb10L_shrOutVar1;
				 L_shrOutNumShift = cheb10L_shrOutNumShift;
				 L_multOutA = cheb10L_multOutA;
				 L_multOutB = cheb10L_multOutB;
				 L_macOutA = cheb10L_macOutA;
				 L_macOutB = cheb10L_macOutB;
				 L_macOutC = cheb10L_macOutC;
				 L_msuOutA = cheb10L_msuOutA;
				 L_msuOutB = cheb10L_msuOutB;
				 L_msuOutC = cheb10L_msuOutC;
				 L_shlVar1Out = cheb10L_shlVar1Out;
				 L_shlNumShiftOut = cheb10L_shlNumShiftOut;
				 L_shlReady = cheb10L_shlReady;
				 multOutA = cheb10multOutA;
				 multOutB = cheb10multOutB;
				 cheb10start = 1;
				 if(cheb10done == 0)
					nextstate = CHEB3;
				else if(cheb10done == 1)
				begin
					cheb10start = 0;
					nextyLow = cheb10out;
					yLowld = 1;
					L_multOutA = nextyLow;
					L_multOutB = yHigh;
					if((L_multIn == 0 )|| (L_multIn[31] == 1))
					begin
						nextstate = FOR_LOOP_CHECK3;
						countReset = 1;
					end	
					else
						nextstate = WHILE_LOOP_CHECK1;
				end
			end///if(pChebpsSel = CHEBPS_10)
		end//CHEB3
		
		FOR_LOOP_CHECK3:
		begin
			if(count >= 4)
				nextstate = INTERPOLATION1;
			else if(count < 4)
			begin
				//nextstate = FOR_LOOP_CHECK3;
				L_shrOutVar1 = xLow;
				L_shrOutNumShift = 16'd1;
				addOutA = L_shrIn[15:0];
				shrOutVar1 = xHigh;
				shrOutVar2 = 16'd1;
				addOutB = shrIn;				
				nextxMid = addIn;
				xMidld = 1;
				nextstate = CHEB3_5;
		end//else if(count<4)		
	end//FOR_LOOP_CHECK3
	
	CHEB3_5:
	begin
	if(pChebpsSel == CHEBPS_11)
				begin
				 lowMidsel = 1;
				 addOutA = cheb11addOutA;
				 addOutB = cheb11addOutB;
				 L_shrOutVar1 = cheb11L_shrOutVar1;
				 L_shrOutNumShift = cheb11L_shrOutNumShift;			 
				 L_multOutA = cheb11L_multOutA;
				 L_multOutB = cheb11L_multOutB;
				 L_macOutA = cheb11L_macOutA;
				 L_macOutB = cheb11L_macOutB;
				 L_macOutC = cheb11L_macOutC;
				 L_msuOutA = cheb11L_msuOutA;
				 L_msuOutB = cheb11L_msuOutB;
				 L_msuOutC = cheb11L_msuOutC;
				 L_shlVar1Out = cheb11L_shlVar1Out;
				 L_shlNumShiftOut = cheb11L_shlNumShiftOut;
				 L_shlReady = cheb11L_shlReady;
				 multOutA = cheb11multOutA;
				 multOutB = cheb11multOutB;
				 cheb11start = 1;
				 if(cheb11done == 0)
					nextstate = CHEB3_5;
				else if(cheb11done == 1)
				begin
					cheb11start = 0;					
					nextstate = COUNT_INCREMENT2;
					nextyMid = cheb11out;
					yMidld = 1;
					L_multOutA = yLow;
					L_multOutB = cheb11out;
					if((L_multIn == 0) || (L_multIn[31] == 1))
					begin
						nextyHigh = nextyMid;
						yHighld = 1;
						nextxHigh = xMid;
						xHighld = 1;
					end	
					else
					begin
						nextyLow = nextyMid;
						yLowld = 1;
						nextxLow = xMid;
						xLowld = 1;
					end
				end//(cheb11done == 1)
			end	//if(pChebpsSel = CHEBPS_11)
			else if (pChebpsSel == CHEBPS_10)						
			begin
				 lowMidsel = 1;
				 addOutA = cheb10addOutA;
				 addOutB = cheb10addOutB;
				 L_shrOutVar1 = cheb10L_shrOutVar1;
				 L_shrOutNumShift = cheb10L_shrOutNumShift;		 
				 L_multOutA = cheb10L_multOutA;
				 L_multOutB = cheb10L_multOutB;
				 L_macOutA = cheb10L_macOutA;
				 L_macOutB = cheb10L_macOutB;
				 L_macOutC = cheb10L_macOutC;
				 L_msuOutA = cheb10L_msuOutA;
				 L_msuOutB = cheb10L_msuOutB;
				 L_msuOutC = cheb10L_msuOutC;
				 L_shlVar1Out = cheb10L_shlVar1Out;
				 L_shlNumShiftOut = cheb10L_shlNumShiftOut;
				 L_shlReady = cheb10L_shlReady;
				 multOutA = cheb10multOutA;
				 multOutB = cheb10multOutB;
				 cheb10start = 1;
				 if(cheb10done == 0)
					nextstate = CHEB3_5;
				else if(cheb10done == 1)
				begin
					cheb10start = 0;
					countld = 1;
					nextstate = COUNT_INCREMENT2;
					nextyMid = cheb10out;
					yMidld = 1;
					L_multOutA = yLow;
					L_multOutB = cheb10out;
					if((L_multIn == 0 )|| (L_multIn[31] == 1))
					begin
						nextyHigh = nextyMid;
						yHighld = 1;
						nextxHigh = xMid;
						xHighld = 1;
					end	
					else
					begin
						nextyLow = nextyMid;
						yLowld = 1;
						nextxLow = xMid;
						xLowld = 1;
					end
				end
			end///if(pChebpsSel = CHEBPS_10)			
	end//CHEB3_5
	
	COUNT_INCREMENT2:
	begin
		addOutA = count;
		addOutB = 16'd1;
		nextcount = addIn;
		countld = 1;
		nextstate = FOR_LOOP_CHECK3;
	end
	
	INTERPOLATION1:
	begin
		subOutA = xHigh;
		subOutB = xLow;
		nexttempX =  subIn;
		tempXld = 1;
		nextstate = INTERPOLATION1_5;
	end//INTERPOLATION1
	
	INTERPOLATION1_5:
	begin
		subOutA = yHigh;
		subOutB = yLow;
		nexttempY = subIn;
		tempYld = 1;
		if(nexttempY == 0)
		begin
			nextxInt = xLow;
			xIntld = 1;
			nextstate = INTERPOLATION5;
		end
		else
			nextstate = INTERPOLATION2;
	end//INTERPOLATION1_5:
	
	INTERPOLATION2:
	begin
		nextSign = tempY[15];
		signLd = 1;
		if(tempY[15] == 1)
		begin
			subOutA = 16'd0;
			subOutB = tempY;
			nexttempY = subIn;
		end
		else
			nexttempY = tempY;
		tempYld = 1;
		norm_sOut = nexttempY;
		norm_sReady = 1;
		nextstate = INTERPOLATION3;
	end//INTERPOLATION2
	
	INTERPOLATION3:
	begin
		norm_sOut = nexttempY;
		if(norm_sDone == 0)
		begin
			nextstate = INTERPOLATION3;
			norm_sOut = nexttempY;
		end
		else if(norm_sDone == 1)
		begin
			nextexp = norm_sIn;
			expld = 1;
			nextstate = INTERPOLATION3_25;			
		end		
	end //INTERPOLATION3
	
	INTERPOLATION3_25:
	begin
		L_shlVar1Out = tempY;
		L_shlNumShiftOut = exp;
		L_shlReady = 1;
		if(leftShiftDone == 0)
			nextstate = INTERPOLATION3_25;
		else if(leftShiftDone == 1)
		begin		
			L_shlReady = 0;
			nexttempY = L_shlIn;
			tempYld = 1;			
			nextstate = INTERPOLATION3_5;
		end
	end//INTERPOLATION3_25
	
	INTERPOLATION3_5:
	begin
		div_sOutA = 16'd16383;
		div_sOutB = tempY;
		div_sReady = 1;
		L_subOutA = div_sL_subOutA;
		L_subOutB = div_sL_subOutB;
		if(div_sDone == 0)		
			nextstate = INTERPOLATION3_5;
		else if(div_sDone == 1)
		begin
			div_sReady = 0;
			nexttempY = div_sIn;
			tempYld = 1;
			L_multOutA = tempX;
			L_multOutB = nexttempY;
			nexttZero = L_multIn;
			tZerold = 1;
			nextstate = INTERPOLATION4;
		end
	
	end//INTERPOLATION3_5
	
	INTERPOLATION4:
	begin
		subOutA = 16'd20;
		subOutB = exp;
		L_shrOutVar1 = tZero;
		L_shrOutNumShift = subIn;
		nexttZero = L_shrIn;
		tZerold = 1;
		nexttempY = nexttZero[15:0];
		tempYld = 1;		
		nextstate = INTERPOLATION5;
	end//INTERPOLATION4
	
	INTERPOLATION5:
	begin
		if(sign == 1)
		begin
			L_subOutA = 32'd0;
			L_subOutB = tempY;
			nexttempY = L_subIn;
			tempYld = 1;
		end
		L_multOutA = yLow;
		L_multOutB = nexttempY;
		L_shrOutVar1 = L_multIn;
		L_shrOutNumShift = 32'd11;
		nexttZero =  L_shrIn;
		tZerold = 1;
		subOutA = xLow;
		subOutB = nexttZero[15:0];
		nextxInt =  subIn ;
		xIntld = 1;
		nextstate = INTERPOLATION6;
	end//INTERPOLATION5
	
	INTERPOLATION6:
	begin
		lspWriteRequested = {AZ_TO_LSP_CURRENT[10:5],nfCount};
		lspOut = {16'd0,xInt};
		lspWrite = 1;
		nextxLow = xInt;
		xLowld = 1;
		addOutA = nfCount;
		addOutB = 16'd1;
		nextnfCount = addIn;
		nfCountld = 1;
		if(coeffSel == 0)
		begin
			nextcoeffSel = 1;
			coeffSelld = 1;
		end
		else if(coeffSel == 1)
		begin
			nextcoeffSel = 0;
			coeffSelld = 1;
		end
		nextstate = CHEB4;		
	end//INTERPOLATION6
	
	CHEB4:
	begin		
		if(pChebpsSel == CHEBPS_11)
		begin
		 lowMidsel = 0;
		 addOutA = cheb11addOutA;
		 addOutB = cheb11addOutB;
		 L_shrOutVar1 = cheb11L_shrOutVar1;
		 L_shrOutNumShift = cheb11L_shrOutNumShift;	 
		 L_multOutA = cheb11L_multOutA;
		 L_multOutB = cheb11L_multOutB;
		 L_macOutA = cheb11L_macOutA;
		 L_macOutB = cheb11L_macOutB;
		 L_macOutC = cheb11L_macOutC;
		 L_msuOutA = cheb11L_msuOutA;
		 L_msuOutB = cheb11L_msuOutB;
		 L_msuOutC = cheb11L_msuOutC;
		 L_shlVar1Out = cheb11L_shlVar1Out;
		 L_shlNumShiftOut = cheb11L_shlNumShiftOut;
		 L_shlReady = cheb11L_shlReady;
		 multOutA = cheb11multOutA;
		 multOutB = cheb11multOutB;
		 cheb11start = 1;
		 if(cheb11done == 0)
			nextstate = CHEB4;
		else if(cheb11done == 1)
		begin
			nextyLow = cheb11out;
			yLowld = 1;
			nextstate = WHILE_LOOP_CHECK1;
		end	
	end	//if(pChebpsSel = CHEBPS_11)
		else if (pChebpsSel == CHEBPS_10)						
		begin
			 lowMidsel = 0;
			 addOutA = cheb10addOutA;
			 addOutB = cheb10addOutB;
			 L_shrOutVar1 = cheb10L_shrOutVar1;
			 L_shrOutNumShift = cheb10L_shrOutNumShift;			 
			 L_multOutA = cheb10L_multOutA;
			 L_multOutB = cheb10L_multOutB;
			 L_macOutA = cheb10L_macOutA;
			 L_macOutB = cheb10L_macOutB;
			 L_macOutC = cheb10L_macOutC;
			 L_msuOutA = cheb10L_msuOutA;
			 L_msuOutB = cheb10L_msuOutB;
			 L_msuOutC = cheb10L_msuOutC;
			 L_shlVar1Out = cheb10L_shlVar1Out;
			 L_shlNumShiftOut = cheb10L_shlNumShiftOut;
			 L_shlReady = cheb10L_shlReady;
			 multOutA = cheb10multOutA;
			 multOutB = cheb10multOutB;
			 cheb10start = 1;
			 if(cheb10done == 0)
				nextstate = CHEB4;
			else if(cheb11done == 1)
			begin
				nextyLow = cheb11out;
				yLowld = 1;
				nextstate = WHILE_LOOP_CHECK1;
			end
		end///if(pChebpsSel = CHEBPS_10)
	end//CHEB4
	
	ROOTS_CHECK:
	begin
		subOutA = nfCount;
		subOutB = 16'd10;
		tempSub = subIn;		
		if(tempSub[3] == 1)
		begin		
			if(count >=10)
			begin
				nextstate = INIT;
				done = 1;
			end
			else if(count < 10)
			begin
				lspReadRequested = {AZ_TO_LSP_OLD[10:5],count};	//reading from old LSP
				nextstate = ROOTS_CHECK_WAIT1;
			end		
		end
		
		else
		begin
			if(count >=10)
			begin
				nextstate = INIT;
				done = 1;
			end
			else if(count < 10)
			begin
				lspReadRequested = {AZ_TO_LSP_CURRENT[10:5],count};
				nextstate = ROOTS_CHECK_WAIT2;				
			end	
		end
	end//ROOTS_CHECK
	
	ROOTS_CHECK_WAIT1:
	begin
		lspReadRequested = {AZ_TO_LSP_OLD[10:5],count};	//reading from old LSP
		lspOut = {16'd0,lspIn};
		lspWriteRequested = {AZ_TO_LSP_CURRENT[10:5],count};
		lspWrite = 1;
		addOutA = count;
		addOutB = 16'd1;
		nextcount = addIn;
		countld = 1;
		nextstate = ROOTS_CHECK;
	end//ROOTS_CHECK_WAIT1
	
	ROOTS_CHECK_WAIT2:
	begin
		lspReadRequested = {AZ_TO_LSP_CURRENT[10:5],count};
		lspOut = {16'd0,lspIn};
		lspWriteRequested = {AZ_TO_LSP_OLD[10:5],count};
		lspWrite = 1;
		addOutA = count;
		addOutB = 16'd1;
		nextcount = addIn;
		countld = 1;
		nextstate = ROOTS_CHECK;
	end//ROOTS_CHECK_WAIT2
	endcase

end

endmodule
