`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:49:20 02/19/2011 
// Design Name: 
// Module Name:    Lsp_get_tdist_pipe 
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
module Lsp_get_tdist_pipe(
	input clk,
	input reset,
	input start,
	input [10:0] wegt,
	input [10:0] buff,
	input [10:0] L_tdist,
	input [10:0] rbuf,
	input [12:0] fg_sum,
	input [10:0] TBwriteAddrScratch,
	input [31:0] TBwriteDataScratch,
	input TBwriteEnScratch,
	input [10:0] TBreadAddrScratch,
	input writeAddrScratchSel,
	input writeDataScratchSel,
	input writeEnScratchSel,
	input readAddrScratchSel,
	
	
	output [31:0] dataInScratch,
	output done	
	);
	
	wire [15:0] subIn;
	wire [15:0] subOutA;
	wire [15:0] subOutB;
	wire [15:0] multIn;
	wire [15:0] multOutA;
	wire [15:0] multOutB;
	wire [31:0] L_multIn;
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire [31:0] L_shlIn;
	wire L_shlDone;
	wire [31:0] L_shlOutA;
	wire [15:0] L_shlOutB;
	wire L_shlReady;
	wire [31:0] L_macIn;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire [15:0] addIn;
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [12:0] readAddrConstant;
	wire [31:0] dataInConstant;
	
	//Memory Wires
	wire [10:0] FSMwriteAddrScratch;
	wire [31:0] FSMwriteDataScratch;
	wire FSMwriteEnScratch;
	wire [10:0] FSMreadAddrScratch;
	
	//Mux Regs
	reg [10:0] writeAddrScratch;
	reg [31:0] writeDataScratch;
	reg writeEnScratch;
	reg [10:0] readAddrScratch;
	
	Lsp_get_tdist uut(
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.wegt(wegt), 
		.buff(buff), 
		.L_tdist(L_tdist), 
		.rbuf(rbuf), 
		.fg_sum(fg_sum), 
		.subIn(subIn), 
		.multIn(multIn), 
		.L_multIn(L_multIn), 
		.L_shlIn(L_shlIn),
		.L_shlDone(L_shlDone),
		.L_macIn(L_macIn), 
		.addIn(addIn), 
		.dataInScratch(dataInScratch),
		.dataInConstant(dataInConstant), 
		.subOutA(subOutA), 
		.subOutB(subOutB), 
		.multOutA(multOutA), 
		.multOutB(multOutB), 
		.L_multOutA(L_multOutA),	
		.L_multOutB(L_multOutB), 
		.L_shlOutA(L_shlOutA), 
		.L_shlOutB(L_shlOutB), 
		.L_shlReady(L_shlReady), 
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC), 
		.addOutA(addOutA), 
		.addOutB(addOutB), 
		.FSMwriteAddrScratch(FSMwriteAddrScratch), 
		.FSMwriteDataScratch(FSMwriteDataScratch), 
		.FSMwriteEnScratch(FSMwriteEnScratch), 
		.FSMreadAddrScratch(FSMreadAddrScratch), 
		.readAddrConstant(readAddrConstant),
		.done(done)
		);
	
	always @ (*)
	begin
		case (writeAddrScratchSel)
		'd0: writeAddrScratch = FSMwriteAddrScratch;
		'd1: writeAddrScratch = TBwriteAddrScratch;
		endcase
	end
	
	always @ (*)
	begin
		case (writeDataScratchSel)
		'd0: writeDataScratch = FSMwriteDataScratch;
		'd1: writeDataScratch = TBwriteDataScratch;
		endcase
	end
	
	always @ (*)
	begin
		case (writeEnScratchSel)
		'd0: writeEnScratch = FSMwriteEnScratch;
		'd1: writeEnScratch = TBwriteEnScratch;
		endcase
	end
	
	always @ (*)
	begin
		case (readAddrScratchSel)
		'd0: readAddrScratch = FSMreadAddrScratch;
		'd1: readAddrScratch = TBreadAddrScratch;
		endcase
	end
	
	Scratch_Memory_Controller _scratch(
		.addra(writeAddrScratch),
		.dina(writeDataScratch),
		.wea(writeEnScratch),
		.clk(clk),
		.addrb(readAddrScratch),
		.doutb(dataInScratch)
		);
	
	Constant_Memory_Controller _constant(
		.addra(readAddrConstant),
		.dina(0),
		.wea(0),
		.clock(clk),
		.douta(dataInConstant)
		);
	
	sub _sub(
		.a(subOutA),
		.b(subOutB),
		.diff(subIn)
		);
	
	mult _mult(
		.a(multOutA),
		.b(multOutB),
		.multRsel(0),
		.product(multIn)
		);
	
	L_shl _L_shl(
		.clk(clk),
		.reset(reset),
		.ready(L_shlReady),
		.var1(L_shlOutA),
		.numShift(L_shlOutB),
		.done(L_shlDone),
		.out(L_shlIn)
		);
	
	L_mac _L_mac(
		.a(L_macOutA),
		.b(L_macOutB),
		.c(L_macOutC),
		.out(L_macIn)
		);
	
	add _add(
		.a(addOutA),
		.b(addOutB),
		.sum(addIn)
		);
	
	L_mult _L_mult(
		.a(L_multOutA),
		.b(L_multOutB),
		.product(L_multIn)
		);
	
	
	
	
	
	
	
	
	
	










endmodule
