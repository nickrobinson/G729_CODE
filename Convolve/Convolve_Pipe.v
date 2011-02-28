`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:45:23 02/26/2011 
// Design Name: 
// Module Name:    Convolve_Pipe 
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
module Convolve_Pipe(clk,reset,lagMuxSel,lagMux1Sel,testReadRequested,testWriteRequested,
					 testWriteOut,testWriteEnable,memWriteEn,memWriteAddr,memOut,
					 L_addOutA,L_addOutB,L_subOutA,L_subOutB,L_macOutA,L_macOutB,
					 L_macOutC,L_shlOutVar1,L_shlNumShiftOut,L_shlReady,memIn,L_macIn,
					 L_subIn,L_addIn,L_shlIn,L_shlDone);

	input clk;
	input reset;
	input [31:0] L_addOutA;
	input [31:0] L_addOutB;
	input [31:0] L_subOutA;
	input [31:0] L_subOutB;
	input [15:0] L_macOutA;
	input [15:0] L_macOutB;
	input [31:0] L_macOutC;
	input [31:0] L_shlOutVar1;
	input [15:0] L_shlNumShiftOut;
	input L_shlReady;
	input memWriteEn;
	input [10:0] memWriteAddr;
	input [31:0] memOut;
	input lagMuxSel;
	input lagMux1Sel;
	input testWriteEnable;
	input [10:0] testReadRequested;
	input [10:0] testWriteRequested;
	input [31:0] testWriteOut;
	
	//output
	output [31:0] L_macIn;
	output [31:0] L_subIn;
	output [31:0] L_addIn;
	output [31:0] L_shlIn;
	output L_shlDone;
	output [31:0] memIn;
	
	wire unusedOverflow;	
	
	//working regs
	reg [10:0] lagMuxOut;
	reg [10:0] lagMux1Out;
	reg [31:0] lagMux2Out;
	reg lagMux3Out;
	
Scratch_Memory_Controller lagMem(
 .addra(lagMux1Out),
 .dina(lagMux2Out),
 .wea(lagMux3Out),
 .clk(clk),
 .addrb(lagMuxOut),
 .doutb(memIn));	
	
	//Instanitiate the Multiply and Add block
L_mac conv_L_mac(
.a(L_macOutA),
.b(L_macOutB),
.c(L_macOutC),
.overflow(),
.out(L_macIn));
					
L_add conv_L_add(
.a(L_addOutA),
.b(L_addOutB),
.overflow(),
.sum(L_addIn));
	
L_sub conv_L_sub(
.a(L_subOutA),
.b(L_subOutB),
.overflow(),
.diff(L_subIn));

L_shl L_shl1(
 .clk(clk),
 .reset(reset),
 .ready(L_shlReady),
 .overflow(unusedOverflow),
 .var1(L_shlOutVar1),
 .numShift(L_shlNumShiftOut),
 .done(L_shlDone),
 .out(L_shlIn));

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
			'd0 :	lagMux1Out = memWriteAddr;//This IS A PROBLEM
			'd1:	lagMux1Out = testWriteRequested;
		endcase
	end
	
	//lag write output mux
	always @(*)
	begin
		case	(lagMux1Sel)	
			'd0 :	lagMux2Out = memOut;
			'd1:	lagMux2Out = testWriteOut;
		endcase
	end
	
		//lag write enable mux
	always @(*)
	begin
		case	(lagMux1Sel)	
			'd0 :	lagMux3Out = memWriteEn;
			'd1:	lagMux3Out = testWriteEnable;
		endcase
	end

endmodule
