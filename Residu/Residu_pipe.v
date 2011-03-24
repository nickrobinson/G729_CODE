`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:09:47 02/14/2011 
// Design Name: 
// Module Name:    Residu_pipe 
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
module Residu_pipe(
	input clk,
	input reset,
	input start,
	input [11:0] A,
	input [11:0] X,
	input [11:0] Y,
	input MuxSel,
	input [11:0] TBwriteAddr1,
	input [11:0] TBwriteAddr2,
	input [31:0] TBdataOut1,
	input [31:0] TBdataOut2,
	input TBwriteEn1,
	input TBwriteEn2,
	input [11:0] TBreadAddr,
	
	output done,
	output [31:0] FSMdataIn1
);
	
	//mux regs
	reg [11:0] writeAddrMuxOut;
	reg [31:0] dataInMuxOut;
	reg writeEnMuxOut;
	reg [11:0] readAddrMuxOut;
	
	wire [31:0] FSMdataIn2;
	wire [31:0] L_multIn;
	wire [31:0] L_macIn;
	wire [15:0] subIn;
	wire [31:0] L_shlIn;
	wire L_shlDone;
	wire L_shlReady;
	wire [15:0] addIn;
	wire [31:0] L_addIn;
	wire FSMwriteEn;
	wire [11:0] FSMreadAddr1;
	wire [11:0] FSMreadAddr2;
	wire [11:0] FSMwriteAddr;
	wire [31:0] FSMdataOut;
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire [15:0] subOutA;
	wire [15:0] subOutB;
	wire [31:0] L_shlOutA;
	wire [15:0] L_shlOutB;
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	
		// Instantiate the Unit Under Test (UUT)
	Residu uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.done(done), 
		.A(A), 
		.X(X), 
		.Y(Y), 
		.LG(6'd40), 
		.FSMdataIn1(FSMdataIn1), 
		.FSMdataIn2(FSMdataIn2), 
		.FSMwriteEn(FSMwriteEn), 
		.FSMreadAddr1(FSMreadAddr1), 
		.FSMreadAddr2(FSMreadAddr2), 
		.FSMwriteAddr(FSMwriteAddr), 
		.FSMdataOut(FSMdataOut), 
		.L_multOutA(L_multOutA), 
		.L_multOutB(L_multOutB), 
		.L_multIn(L_multIn), 
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC), 
		.L_macIn(L_macIn), 
		.subOutA(subOutA), 
		.subOutB(subOutB), 
		.subIn(subIn), 
		.L_shlOutA(L_shlOutA), 
		.L_shlOutB(L_shlOutB), 
		.L_shlIn(L_shlIn), 
		.L_shlReady(L_shlReady),
		.L_shlDone(L_shlDone),
		.addOutA(addOutA), 
		.addOutB(addOutB), 
		.addIn(addIn), 
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.L_addIn(L_addIn)
	);
	
	//memory A,Y
	Scratch_Memory_Controller Mem1(
		 .addra(writeAddrMuxOut),
		 .dina(dataInMuxOut),
		 .wea(writeEnMuxOut),
		 .clk(clk),
		 .addrb(readAddrMuxOut),
		 .doutb(FSMdataIn1)
		 );
	
	//memory X
	Scratch_Memory_Controller Mem2(
		 .addra(TBwriteAddr2),
		 .dina(TBdataOut2),
		 .wea(TBwriteEn2),
		 .clk(clk),
		 .addrb(FSMreadAddr2),
		 .doutb(FSMdataIn2)
		 );
	
	
	add _add(
		.a(addOutA),
		.b(addOutB),
		.overflow(),
		.sum(addIn)
		);
	
	sub _sub(
		.a(subOutA),
		.b(subOutB),
		.overflow(),
		.diff(subIn)
		);
	
	L_mult _L_mult(
		.a(L_multOutA),
		.b(L_multOutB),
		.overflow(),
		.product(L_multIn)
		);
	
	L_mac _L_mac(
		.a(L_macOutA),
		.b(L_macOutB),
		.c(L_macOutC),
		.overflow(),
		.out(L_macIn)
		);
	
	L_shl _L_shl(
		.clk(clk),
		.reset(reset),
		.ready(L_shlReady),
		.overflow(),
		.var1(L_shlOutA),
		.numShift(L_shlOutB),
		.done(L_shlDone),
		.out(L_shlIn)
		);

	L_add _L_add(
		.a(L_addOutA),
		.b(L_addOutB),
		.overflow(),
		.sum(L_addIn)
		);
	
	//write address mux for Memory A,Y
	always @(*)
	begin
		case	(MuxSel)	
			'd0:	writeAddrMuxOut = TBwriteAddr1;
			'd1:	writeAddrMuxOut = FSMwriteAddr;
		endcase
	end
	
	//data in mux for Memory A,Y
	always @(*)
	begin
		case	(MuxSel)	
			'd0:	dataInMuxOut = TBdataOut1;
			'd1:	dataInMuxOut = FSMdataOut;
		endcase
	end
		
	//write enable mux for Memory A,Y
	always @(*)
	begin
		case	(MuxSel)	
			'd0:	writeEnMuxOut = TBwriteEn1;
			'd1:	writeEnMuxOut = FSMwriteEn;
		endcase
	end
			
	//read address mux for Memory A,Y
	always @(*)
	begin
		case	(MuxSel)	
			'd0:	readAddrMuxOut = TBreadAddr;
			'd1:	readAddrMuxOut = FSMreadAddr1;
		endcase
	end
	
endmodule
