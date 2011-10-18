`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:45:05 02/26/2011 
// Design Name: 
// Module Name:    Convolve_Top_Level 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Convolve_Top_Level(clk,reset,start,done,memIn,lagMuxSel,lagMux1Sel,
								  xAddr,hAddr,yAddr,testWriteRequested,testWriteOut,
								  testWriteEnable,testReadRequested
								  );

	// Inputs
	input clk;
	input reset;
	input start;
	input lagMuxSel;
	input lagMux1Sel;
	input [11:0] xAddr;
	input [11:0] hAddr;
	input [11:0] yAddr;
	input [11:0] testReadRequested;
	input [11:0] testWriteRequested;
	input [31:0] testWriteOut;
	input testWriteEnable;		

	output done;	
	output [31:0] memIn;
	
	wire memWriteEn;
	wire [11:0] memWriteAddr;
	wire [31:0] memOut;
	wire [31:0] L_macIn;
	wire [31:0] L_subIn;
	wire [31:0] L_addIn;
	wire [31:0] L_shlIn;
	wire L_shlDone;
	wire L_shlReady;
	wire [31:0] L_shlOutVar1;
	wire [15:0] L_shlNumShiftOut;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	wire [31:0] L_subOutA;
	wire [31:0] L_subOutB;
	wire unusedOverflow;
	wire [15:0] addOutA,addOutB,addIn;
	
	convolve uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.memIn(memIn), 
		.memWriteEn(memWriteEn), 
		.memWriteAddr(memWriteAddr), 
		.memOut(memOut), 
		.done(done),
		.L_macIn(L_macIn),
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC),
		.L_shlIn(L_shlIn), 
		.L_shlDone(L_shlDone),
		.L_shlOutVar1(L_shlOutVar1), 
		.L_shlNumShiftOut(L_shlNumShiftOut), 
		.L_shlReady(L_shlReady),
		.xAddr(xAddr),
		.hAddr(hAddr),
		.yAddr(yAddr),
		.L_subOutA(L_subOutA),
		.L_subOutB(L_subOutB), 
		.L_subIn(L_subIn), 
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.L_addIn(L_addIn),
		.addOutA(addOutA),
		.addOutB(addOutB),
		.addIn(addIn)
	);

	Convolve_Pipe iPipe (
	.clk(clk),
	.reset(reset),
	.lagMuxSel(lagMuxSel),
	.lagMux1Sel(lagMux1Sel),
	.testReadRequested(testReadRequested),
	.testWriteRequested(testWriteRequested),
	.testWriteOut(testWriteOut),
	.testWriteEnable(testWriteEnable),
	.memWriteEn(memWriteEn),
	.memWriteAddr(memWriteAddr),
	.memOut(memOut),
	.L_addOutA(L_addOutA),
	.L_addOutB(L_addOutB),
	.L_subOutA(L_subOutA),
	.L_subOutB(L_subOutB),
	.L_macOutA(L_macOutA),
	.L_macOutB(L_macOutB),
	.L_macOutC(L_macOutC),
	.L_shlOutVar1(L_shlOutVar1),
	.L_shlNumShiftOut(L_shlNumShiftOut),
	.L_shlReady(L_shlReady),
	.memIn(memIn),
	.L_macIn(L_macIn),
	.L_subIn(L_subIn),
	.L_addIn(L_addIn),
	.L_shlIn(L_shlIn),
	.L_shlDone(L_shlDone),
	.addOutA(addOutA),
	.addOutB(addOutB),
	.addIn(addIn)
	);
	
endmodule
