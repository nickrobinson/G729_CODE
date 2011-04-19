`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    08:42:35 04/14/2011 
// Module Name:    Norm_Corr_pipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for Norm_Corr
// 
// Dependencies: 	 Scratch_Memory_Controller.v,Constant_Memory_Controller.v,add.v,L_add.v,L_mac.v,
//						 L_msu.v,L_negate.v,L_shl.v,L_shr.v,L_sub.v,mult.v,norm_l.v,shr.v,sub.v,
//						 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Norm_Corr_pipe(clk,start,reset,excAddr,t_min,t_max,normCorrMuxSel,testReadAddr,
						    testWriteAddr,testMemOut,testMemWriteEn,memIn,done);

//Inputs
input clk,start,reset;
input [11:0] excAddr;
input [15:0] t_min;
input [15:0] t_max;
input normCorrMuxSel;
input [11:0] testReadAddr,testWriteAddr;
input [31:0] testMemOut;
input testMemWriteEn;

//Outputs
output [31:0] memIn;
output done;

//Internal wires
wire [15:0] addIn;
wire [31:0] L_addIn;
wire [31:0] L_macIn;
wire [31:0] L_msuIn;
wire [31:0] L_multIn;
wire [31:0] L_negateIn;
wire [31:0] L_shlIn;
wire L_shlDone;
wire [31:0] L_shrIn;
wire [31:0] L_subIn;
wire [15:0] multIn;
wire [15:0] norm_lIn;
wire norm_lDone;
wire [15:0] shrIn;
wire [15:0] subIn;
wire [31:0] constantMemIn;
wire [15:0] addOutA,addOutB;
wire [31:0] L_addOutA,L_addOutB;
wire [31:0] L_negateOut;
wire [15:0] L_macOutA,L_macOutB;
wire [31:0] L_macOutC;
wire [15:0] L_msuOutA,L_msuOutB;
wire [31:0] L_msuOutC;
wire [15:0] L_multOutA,L_multOutB;
wire [31:0] L_shlVar1Out; 
wire [15:0] L_shlNumShiftOut;
wire L_shlReady;
wire [31:0] L_shrVar1Out;
wire [15:0] L_shrNumShiftOut;
wire [31:0] L_subOutA,L_subOutB;
wire [15:0] multOutA,multOutB;
wire [31:0] norm_lVar1Out;
wire norm_lReady;
wire [15:0] shrVar1Out,shrVar2Out;
wire [15:0] subOutA,subOutB;
wire [11:0] constantMemAddr;
wire memWriteEn;
wire [11:0] memReadAddr,memWriteAddr;
wire [31:0] memOut;

//Internal regs
reg [11:0] normCorrMuxOut,normCorrMux1Out;
reg [31:0] normCorrMux2Out;
reg normCorrMux3Out;

//Instantiated Modules
Scratch_Memory_Controller testMem(
											 .addra(normCorrMux1Out),
											 .dina(normCorrMux2Out),
											 .wea(normCorrMux3Out),
											 .clk(clk),
											 .addrb(normCorrMuxOut),
											 .doutb(memIn)
											 );									 

Constant_Memory_Controller ConstantMem(
													.addra(constantMemAddr),
													.dina(0),
													.wea(1'd0),
													.clock(clk),
													.douta(constantMemIn)
													);					  
add normCorr_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
							);	
L_add normCorr_L_add(
				 .a(L_addOutA),
				 .b(L_addOutB),
				 .sum(L_addIn)
				);
	
L_mac normCorr_L_mac(
							.a(L_macOutA),
							.b(L_macOutB),
							.c(L_macOutC),
							.out(L_macIn)
						 );	

L_msu normCorr_L_msu(
							.a(L_msuOutA),
							.b(L_msuOutB),
							.c(L_msuOutC),
							.overflow(),
							.out(L_msuIn)
							);
							
L_mult normCorr_L_mult(
								.a(L_multOutA),
								.b(L_multOutB),
								.overflow(),
								.product(L_multIn)
								);							
							
L_negate normCorr_L_negate(
										.var_in(L_negateOut),
										.var_out(L_negateIn)
									);
L_shl normCorr_L_shl(
							 .clk(clk),
							 .reset(reset),
							 .ready(L_shlReady),
							 .overflow(),
							 .var1(L_shlVar1Out),
							 .numShift(L_shlNumShiftOut),
							 .done(L_shlDone),
							 .out(L_shlIn)
							 );
					
L_shr normCorr_L_shr(
							 .var1(L_shrVar1Out),
							 .numShift(L_shrNumShiftOut),
							 .overflow(),
							 .out(L_shrIn)
							 );

L_sub normCorr_L_sub(
							.a(L_subOutA),
							.b(L_subOutB),
							.overflow(),
							.diff(L_subIn)
							);
							 
mult normCorr_mult(
						  .a(multOutA), 
						  .b(multOutB),
						  .multRsel(1'd0),
						  .overflow(), 
						  .product(multIn)
						  );

norm_l normCorr_norm_l(
								.var1(norm_lVar1Out),
								.norm(norm_lIn),
								.clk(clk),
								.ready(norm_lReady),
								.reset(reset),
								.done(norm_lDone)
								);	

shr normCorr_shr(
						.var1(shrVar1Out),
						.var2(shrVar2Out),
						.overflow(),
						.result(shrIn)
						);
								
sub normCorr_sub(
						.a(subOutA),
						.b(subOutB),
						.overflow(),
						.diff(subIn)
					  );

Norm_Corr fsm(
					.clk(clk),
					.start(start),
					.reset(reset),
					.excAddr(excAddr),
					.t_min(t_min),
					.t_max(t_max),
					.addIn(addIn),
					.L_addIn(L_addIn),
					.L_macIn(L_macIn),
					.L_msuIn(L_msuIn),
					.L_multIn(L_multIn),
					.L_negateIn(L_negateIn),
					.L_shlIn(L_shlIn),
					.L_shlDone(L_shlDone),
					.L_shrIn(L_shrIn),
					.L_subIn(L_subIn),
					.multIn(multIn),
					.norm_lIn(norm_lIn),
					.norm_lDone(norm_lDone),
					.shrIn(shrIn),
					.subIn(subIn),
					.constantMemIn(constantMemIn),
					.memIn(memIn),
					.addOutA(addOutA),
					.addOutB(addOutB),
					.L_addOutA(L_addOutA),
					.L_addOutB(L_addOutB),
					.L_negateOut(L_negateOut),
					.L_macOutA(L_macOutA),
					.L_macOutB(L_macOutB),
					.L_macOutC(L_macOutC),
					.L_msuOutA(L_msuOutA),
					.L_msuOutB(L_msuOutB),
					.L_msuOutC(L_msuOutC),
					.L_multOutA(L_multOutA),
					.L_multOutB(L_multOutB),
					.L_shlVar1Out(L_shlVar1Out),
					.L_shlNumShiftOut(L_shlNumShiftOut),
					.L_shlReady(L_shlReady),
					.L_shrVar1Out(L_shrVar1Out),
					.L_shrNumShiftOut(L_shrNumShiftOut),
					.L_subOutA(L_subOutA),
					.L_subOutB(L_subOutB),
					.multOutA(multOutA),
					.multOutB(multOutB),
					.norm_lVar1Out(norm_lVar1Out),
					.norm_lReady(norm_lReady),
					.shrVar1Out(shrVar1Out),
					.shrVar2Out(shrVar2Out),
					.subOutA(subOutA),
					.subOutB(subOutB),
					.constantMemAddr(constantMemAddr),
					.memWriteEn(memWriteEn),
					.memReadAddr(memReadAddr),
					.memWriteAddr(memWriteAddr),
					.memOut(memOut),
					.done(done)
					);		

	//Memory muxes
	//normCorr read address mux
	always @(*)
	begin
		case	(normCorrMuxSel)	
			'd0 :	normCorrMuxOut = memReadAddr;
			'd1:	normCorrMuxOut = testReadAddr;
		endcase
	end
	
	//normCorr write address mux
	always @(*)
	begin
		case	(normCorrMuxSel)	
			'd0 :	normCorrMux1Out = memWriteAddr;
			'd1:	normCorrMux1Out = testWriteAddr;
		endcase
	end
	
	//normCorr write input mux
	always @(*)
	begin
		case	(normCorrMuxSel)	
			'd0 :	normCorrMux2Out = memOut;
			'd1:	normCorrMux2Out = testMemOut;
		endcase
	end
	
	//normCorr write enable mux
	always @(*)
	begin
		case	(normCorrMuxSel)	
			'd0 :	normCorrMux3Out = memWriteEn;
			'd1:	normCorrMux3Out = testMemWriteEn;
		endcase
	end					
endmodule
