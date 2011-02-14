`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Nick Robinson
// 
// Create Date:    13:08:31 2/8/2011 
// Module Name:    Synthesis Filtering
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 12.3
// Description: 	 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module syn_filt_pipe(clk, reset, start, memIn, xAddr, aAddr, yAddr, fMemAddr, updateAddr, 
                     done, lagMuxSel, lagMux1Sel, lagMux2Sel, lagMux3Sel, testReadRequested, 
							testWriteRequested, testWriteOut, testWriteEnable);
	 
	 // Inputs
	input clk;
	input reset;
	input start;
	
	
	input [10:0] xAddr;
	input [10:0] aAddr;
	input [10:0] yAddr;
	input [10:0] fMemAddr;
	input [10:0] updateAddr;

	// Outputs
	output done;
	output [31:0] memIn;
	
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire [31:0] L_shlOutVar1;
	wire [15:0] L_shlNumShiftOut;
	wire L_shlReady;
	wire [15:0] L_msuOutA;
	wire [15:0] L_msuOutB;
	wire [31:0] L_msuOutC;
	wire [31:0] L_addIn;
	wire [31:0] L_multIn;
	wire [31:0] L_shlIn;
	wire [31:0] L_msuIn;
	wire [31:0] memOut;
	wire memWriteEn;
	wire [10:0] memWriteAddr;
	
	wire unusedOverflow;
	
	//Mux0 regs	
	input lagMuxSel;
	reg [10:0] lagMuxOut;
	input [10:0] testReadRequested;
	//Mux1 regs	
	input lagMux1Sel;
	reg [10:0] lagMux1Out;
	input [10:0] testWriteRequested;
	//Mux2 regs	
	input lagMux2Sel;
	reg [31:0] lagMux2Out;
	input [31:0] testWriteOut;
	//Mux3 regs	
	input lagMux3Sel;
	reg lagMux3Out;
	input testWriteEnable;
	integer i, j;

	// Instantiate the Unit Under Test (UUT)
	syn_filt fsm(
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.memIn(memIn), 
		.memWriteEn(memWriteEn), 
		.memWriteAddr(memWriteAddr), 
		.memOut(memOut), 
		.done(done),
		.xAddr(xAddr),
		.aAddr(aAddr),
		.yAddr(yAddr),
		.updateAddr(updateAddr),
		.fMemAddr(fMemAddr),
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.L_addIn(L_addIn),
		.L_multOutA(L_multOutA),
		.L_multOutB(L_multOutB),
		.L_multIn(L_multIn),
		.L_shlIn(L_shlIn), 
		.L_shlDone(L_shlDone),
		.L_shlOutVar1(L_shlOutVar1), 
		.L_shlNumShiftOut(L_shlNumShiftOut), 
		.L_shlReady(L_shlReady),
		.L_msuIn(L_msuIn), 
		.L_msuOutA(L_msuOutA), 
		.L_msuOutB(L_msuOutB), 
		.L_msuOutC(L_msuOutC)
	);
	
	Scratch_Memory_Controller convMem(
												 .addra(lagMux1Out),
												 .dina(lagMux2Out),
												 .wea(lagMux3Out),
												 .clk(clk),
												 .addrb(lagMuxOut),
												 .doutb(memIn)
												 );
					
	L_add conv_L_add(
					.a(L_addOutA),
					.b(L_addOutB),
					.overflow(),
					.sum(L_addIn));
					
	L_mult conv_L_mult(
					.a(L_multOutA),
					.b(L_multOutB),
					.overflow(),
					.product(L_multIn));
	
	L_shl L_shl1(
					 .clk(clk),
					 .reset(reset),
					 .ready(L_shlReady),
					 .overflow(unusedOverflow),
					 .var1(L_shlOutVar1),
					 .numShift(L_shlNumShiftOut),
					 .done(L_shlDone),
					 .out(L_shlIn)
					 );
	
	L_msu conv_L_msu(
						 .a(L_msuOutA),
						 .b(L_msuOutB),
						 .c(L_msuOutC),
						 .overflow(unusedOverflow),
						 .out(L_msuIn)
						 );		
					 
	//lag read address mux
	always @(*)
	begin
		case	(lagMuxSel)	
			'd0 :	lagMuxOut = memWriteAddr;
			'd1:	lagMuxOut = testReadRequested;
		endcase
	end
	
	//lag write address mux
	always @(*)
	begin
		case	(lagMux1Sel)	
			'd0 :	lagMux1Out = memWriteAddr;
			'd1:	lagMux1Out = testWriteRequested;
		endcase
	end
	
	//lag write output mux
	always @(*)
	begin
		case	(lagMux2Sel)	
			'd0 :	lagMux2Out = memOut;
			'd1:	lagMux2Out = testWriteOut;
		endcase
	end
	
		//lag write enable mux
	always @(*)
	begin
		case	(lagMux3Sel)	
			'd0 :	lagMux3Out = memWriteEn;
			'd1:	lagMux3Out = testWriteEnable;
		endcase
	end


endmodule
