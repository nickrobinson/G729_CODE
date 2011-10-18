`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:46:40 03/19/2011 
// Design Name: 
// Module Name:    Interpol_3_pipe 
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
module Interpol_3_pipe(
	input clk,
	input reset,
	input start,
	input [11:0] x,
	input [15:0] frac,
	input [11:0] inter_3,
	input [11:0] TBwriteAddrScratch,
	input [31:0] TBwriteDataScratch,
	input TBwriteEnScratch,
	output [15:0] returnS,
	output done
   );
	
	wire [15:0] addIn;
	wire [15:0] subIn;
	wire [31:0] L_addIn;
	wire [31:0] L_macIn;
	wire [31:0] FSMdataInScratch;
	wire [31:0] FSMdataInConstant;	
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [15:0] subOutA;
	wire [15:0] subOutB;
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire [11:0] FSMreadAddrScratch;
	wire [11:0] FSMreadAddrConstant;

	Interpol_3 uut(
	.clk(clk),
	.reset(reset),
	.start(start),
	.x(x),
	.frac(frac),
	.inter_3(inter_3),
	.addIn(addIn),
	.subIn(subIn),
	.L_addIn(L_addIn),
	.L_macIn(L_macIn),
	.FSMdataInScratch(FSMdataInScratch),
	.FSMdataInConstant(FSMdataInConstant),	
	.addOutA(addOutA),
	.addOutB(addOutB),
	.subOutA(subOutA),
	.subOutB(subOutB),
	.L_addOutA(L_addOutA),
	.L_addOutB(L_addOutB),
	.L_macOutA(L_macOutA),
	.L_macOutB(L_macOutB),
	.L_macOutC(L_macOutC),
	.FSMreadAddrScratch(FSMreadAddrScratch),
	.FSMreadAddrConstant(FSMreadAddrConstant),
	.returnS(returnS),
	.done(done)
   );
	
	add _add(
	.a(addOutA),
	.b(addOutB),
	.sum(addIn)
	);
	
	sub _sub(
	.a(subOutA),
	.b(subOutB),
	.diff(subIn)
	);
	
	L_add _L_add(
	.a(L_addOutA),
	.b(L_addOutB),
	.sum(L_addIn)
	);
	
	L_mac _L_mac(
	.a(L_macOutA),
	.b(L_macOutB),
	.c(L_macOutC),
	.out(L_macIn)
	);
	
	Scratch_Memory_Controller _ScratchMem(
	.addra(TBwriteAddrScratch),
	.dina(TBwriteDataScratch),
	.wea(TBwriteEnScratch),
	.clk(clk),
	.addrb(FSMreadAddrScratch),
	.doutb(FSMdataInScratch)
	);
	
	Constant_Memory_Controller _ConstantMem(
	.addra(FSMreadAddrConstant),
	.dina(0),
	.wea(1'd0),
	.clock(clk),
	.douta(FSMdataInConstant)
	);
	
endmodule
