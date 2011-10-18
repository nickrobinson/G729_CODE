`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    16:51:22 03/09/2011 
// Module Name:    Cor_hPipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for Cor_hPipe
// 
// Dependencies: 	 Cor_h.v, Scratch_Memory_Controller.v, L_sub.v, L_add.v, L_mult.v, L_mac.v,
//						 shl.v,add.v,shr.v,sub.v
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Cor_hPipe(clk,reset,start,corHMuxSel,testReadAddr,testWriteAddr,testMemOut,testMemWriteEn,
					  done,memIn);
	 
//Inputs
input clk,reset,start;
input corHMuxSel;
input [11:0] testReadAddr,testWriteAddr;
input [31:0] testMemOut;
input testMemWriteEn;

//Outputs
output done;
output [31:0] memIn;

//Internal wires
wire [31:0] L_macIn;
wire [31:0] L_subIn;
wire [15:0] subIn;
wire [15:0] shrIn;
wire [15:0] norm_lIn;
wire norm_lDone;
wire [15:0] shlIn;
wire [15:0] addIn;
wire [31:0] L_addIn;
wire [31:0] L_add2In;
wire [31:0] L_add3In;
wire [31:0] L_add4In;
wire [31:0] memOut;
wire [15:0] L_macOutA,L_macOutB;
wire [31:0] L_macOutC;
wire [31:0] L_subOutA,L_subOutB;
wire [15:0] subOutA,subOutB;
wire [15:0] shrVar1Out,shrVar2Out;
wire [31:0] norm_lVar1Out;
wire norm_lReady;
wire [15:0] shlVar1Out,shlVar2Out;
wire [15:0] addOutA,addOutB;
wire [31:0] L_addOutA,L_addOutB;
wire [31:0] L_add2OutA,L_add2OutB;
wire [31:0] L_add3OutA,L_add3OutB;
wire [31:0] L_add4OutA,L_add4OutB;
wire [11:0] memReadAddr,memWriteAddr;
wire memWriteEn;

//Internal regs
reg [11:0] corHMuxOut,corHMux1Out;
reg [31:0] corHMux2Out;
reg corHMux3Out;
//Instantiated modules	
	Scratch_Memory_Controller testMem(
												 .addra(corHMux1Out),
												 .dina(corHMux2Out),
												 .wea(corHMux3Out),
												 .clk(clk),
												 .addrb(corHMuxOut),
												 .doutb(memIn)
												 );

Cor_h fsm(
			 .clk(clk),
			 .reset(reset),
			 .start(start),			 
			 .L_macIn(L_macIn),
			 .L_subIn(L_subIn),
			 .subIn(subIn),
			 .shrIn(shrIn),
			 .norm_lIn(norm_lIn),
			 .norm_lDone(norm_lDone),
			 .shlIn(shlIn),
			 .addIn(addIn),
			 .L_addIn(L_addIn),
			 .L_add2In(L_add2In),
			 .L_add3In(L_add3In),
			 .L_add4In(L_add4In),
			 .memIn(memIn),
			 .L_macOutA(L_macOutA),
			 .L_macOutB(L_macOutB),
			 .L_macOutC(L_macOutC),
			 .L_subOutA(L_subOutA),
			 .L_subOutB(L_subOutB),
			 .subOutA(subOutA),
			 .subOutB(subOutB),
			 .shrVar1Out(shrVar1Out),
			 .shrVar2Out(shrVar2Out),
			 .norm_lVar1Out(norm_lVar1Out),
			 .norm_lReady(norm_lReady),
			 .shlVar1Out(shlVar1Out),
			 .shlVar2Out(shlVar2Out),
			 .addOutA(addOutA),
			 .addOutB(addOutB),
			 .L_addOutA(L_addOutA),
			 .L_addOutB(L_addOutB),
			 .L_add2OutA(L_add2OutA),
			 .L_add2OutB(L_add2OutB),
			 .L_add3OutA(L_add3OutA),
			 .L_add3OutB(L_add3OutB),
			 .L_add4OutA(L_add4OutA),
			 .L_add4OutB(L_add4OutB),
			 .memReadAddr(memReadAddr),
			 .memWriteAddr(memWriteAddr),
			 .memOut(memOut),
			 .memWriteEn(memWriteEn),
			 .done(done)
			 );

L_mac corH_L_mac(
						.a(L_macOutA),
						.b(L_macOutB),
						.c(L_macOutC),
						.overflow(),
						.out(L_macIn)
					 );
					 
L_sub corH_L_sub(
						.a(L_subOutA),
						.b(L_subOutB),
						.overflow(),
						.diff(L_subIn)
					  );
					  
sub corH_sub(
						.a(subOutA),
						.b(subOutB),
						.overflow(),
						.diff(subIn)
					  );
					  
shr corH_shr(
				  .var1(shrVar1Out),
				  .var2(shrVar2Out),
				  .overflow(),
				  .result(shrIn)
				  );

shl corH_shl(
					  .var1(shlVar1Out),
					  .var2(shlVar2Out),
					  .overflow(),
					  .result(shlIn)
				    );

add corH_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
							);		

L_add corH_L_add(
						.a(L_addOutA),
						.b(L_addOutB),
						.overflow(),
						.sum(L_addIn)
					 );

L_add corH_L_add2(
						.a(L_add2OutA),
						.b(L_add2OutB),
						.overflow(),
						.sum(L_add2In)
					 );

L_add corH_L_add3(
						.a(L_add3OutA),
						.b(L_add3OutB),
						.overflow(),
						.sum(L_add3In)
					 );

L_add corH_L_add4(
						.a(L_add4OutA),
						.b(L_add4OutB),
						.overflow(),
						.sum(L_add4In)
					 );					 
norm_l corH_normL(
							.var1(norm_lVar1Out),
							.norm(norm_lIn),
							.clk(clk),
							.ready(norm_lReady),
							.reset(reset),
							.done(norm_lDone)
	
					  );
					  
	//Memory muxes
	//corH read address mux
	always @(*)
	begin
		case	(corHMuxSel)	
			'd0 :	corHMuxOut = memReadAddr;
			'd1:	corHMuxOut = testReadAddr;
		endcase
	end
	
	//corH write address mux
	always @(*)
	begin
		case	(corHMuxSel)	
			'd0 :	corHMux1Out = memWriteAddr;
			'd1:	corHMux1Out = testWriteAddr;
		endcase
	end
	
	//corH write input mux
	always @(*)
	begin
		case	(corHMuxSel)	
			'd0 :	corHMux2Out = memOut;
			'd1:	corHMux2Out = testMemOut;
		endcase
	end
	
	//corH write enable mux
	always @(*)
	begin
		case	(corHMuxSel)	
			'd0 :	corHMux3Out = memWriteEn;
			'd1:	corHMux3Out = testMemWriteEn;
		endcase
	end
endmodule
