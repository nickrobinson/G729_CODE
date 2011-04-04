`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    17:15:12 03/31/2011  
// Module Name:    ACELP_Codebook_pipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for ACELP_Codebook
// 
// Dependencies: 	 ACELP_Codebook.v, Scratch_Memory_Controller.v, shl.v, sub.v, add.v, mult.v, 
//						 L_mac.v, L_abs.v, L_sub.v, norm_l.v, L_shr.v, L_negate.v, L_mult.v, L_msu.v,
//						 L_add.v
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ACELP_Codebook_pipe(clk,reset,start,T0,pitch_sharp,i_subfr,codebookMuxSel,testReadAddr,
								   testWriteAddr,testMemOut,testMemWriteEn,index,memIn,done);

//Inputs
input clk,reset,start;
input [15:0] T0;
input [15:0] pitch_sharp;
input [15:0] i_subfr;
input codebookMuxSel;
input [11:0] testReadAddr,testWriteAddr;
input [31:0] testMemOut;
input testMemWriteEn;

//Outputs
output [15:0] index;
output [31:0] memIn;
output done;

//Internal wires
wire [15:0] shlIn;
wire [15:0] subIn;
wire [15:0] addIn;
wire [15:0] multIn;
wire [31:0] L_macIn;
wire [31:0] L_absIn;
wire [31:0] L_subIn;
wire [15:0] norm_lIn;
wire norm_lDone;
wire [31:0] L_shrIn;
wire [31:0] L_negateIn;
wire [31:0] L_multIn;
wire [31:0] L_msuIn;
wire [15:0] shrIn;
wire [31:0] L_addIn;
wire [31:0] L_add2In;
wire [31:0] L_add3In;
wire [31:0] L_add4In;
wire [15:0] shlVar1Out,shlVar2Out;
wire [15:0] subOutA,subOutB;
wire [15:0] addOutA,addOutB;
wire [15:0] multOutA,multOutB;
wire [15:0] L_macOutA,L_macOutB;
wire [31:0] L_macOutC;
wire [31:0] L_absOut;
wire [31:0] L_subOutA,L_subOutB;
wire [31:0] norm_lVar1Out;
wire norm_lReady;
wire [31:0] L_shrVar1Out;
wire [15:0] L_shrNumShiftOut;
wire [31:0] L_negateOut;
wire [15:0] L_multOutA,L_multOutB;
wire [15:0] L_msuOutA,L_msuOutB;
wire [31:0] L_msuOutC;
wire [15:0] shrVar1Out,shrVar2Out;
wire [31:0] L_addOutA,L_addOutB;
wire [31:0] L_add2OutA,L_add2OutB;
wire [31:0] L_add3OutA,L_add3OutB;
wire [31:0] L_add4OutA,L_add4OutB;
wire [11:0] memReadAddr,memWriteAddr;
wire memWriteEn;
wire [31:0] memOut;
//Internal regs
reg [11:0] codebookMuxOut,codebookMux1Out;
reg [31:0] codebookMux2Out;
reg codebookMux3Out;

ACELP_Codebook fsm(
							.clk(clk),
							.reset(reset),
							.start(start),
							.T0(T0),
							.pitch_sharp(pitch_sharp),
							.i_subfr(i_subfr),
							.shlIn(shlIn),
							.subIn(subIn),
							.addIn(addIn),
							.multIn(multIn),
							.L_macIn(L_macIn),
							.L_absIn(L_absIn),
							.L_subIn(L_subIn),
							.norm_lIn(norm_lIn),
							.norm_lDone(norm_lDone),
							.L_shrIn(L_shrIn),
							.L_negateIn(L_negateIn),
							.L_multIn(L_multIn),
							.L_msuIn(L_msuIn),
							.shrIn(shrIn),
							.L_addIn(L_addIn),
							.L_add2In(L_add2In),
							.L_add3In(L_add3In),
							.L_add4In(L_add4In),
							.memIn(memIn),
							.shlVar1Out(shlVar1Out),
							.shlVar2Out(shlVar2Out),
							.subOutA(subOutA),
							.subOutB(subOutB),
							.addOutA(addOutA),
							.addOutB(addOutB),
							.multOutA(multOutA),
							.multOutB(multOutB),
							.L_macOutA(L_macOutA),
							.L_macOutB(L_macOutB),
							.L_macOutC(L_macOutC),
							.L_absOut(L_absOut),
							.L_subOutA(L_subOutA),
							.L_subOutB(L_subOutB),
							.norm_lVar1Out(norm_lVar1Out),
							.norm_lReady(norm_lReady),
							.L_shrVar1Out(L_shrVar1Out),
							.L_shrNumShiftOut(L_shrNumShiftOut),
							.L_negateOut(L_negateOut),
							.L_multOutA(L_multOutA),
							.L_multOutB(L_multOutB),
							.L_msuOutA(L_msuOutA),
							.L_msuOutB(L_msuOutB),
							.L_msuOutC(L_msuOutC),
							.shrVar1Out(shrVar1Out),
							.shrVar2Out(shrVar2Out),
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
							.index(index),
							.done(done)
							);
	
shl codebook_shl(
					  .var1(shlVar1Out),
					  .var2(shlVar2Out),
					  .overflow(),
					  .result(shlIn)
				    );

sub codebook_sub(
						.a(subOutA),
						.b(subOutB),
						.overflow(),
						.diff(subIn)
					  );

add codebook_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
							);	

mult codebook_mult(
					.a(multOutA),
					.b(multOutB),
					.multRsel(),
					.overflow(),
					.product(multIn)
					);	

L_mac codebook_L_mac(
						.a(L_macOutA),
						.b(L_macOutB),
						.c(L_macOutC),
						.overflow(),
						.out(L_macIn)
					 );

L_abs codebook_L_abs(
							.var_in(L_absOut),
							.var_out(L_absIn)
						   );
L_sub codebook_L_sub(
							.a(L_subOutA),
							.b(L_subOutB),
							.overflow(),
							.diff(L_subIn)
							);
							
norm_l codebook_normL(
								.var1(norm_lVar1Out),
								.norm(norm_lIn),
								.clk(clk),
								.ready(norm_lReady),
								.reset(reset),
								.done(norm_lDone)	
							);							

L_shr codebook_L_shr(
							.var1(L_shrVar1Out),
							.numShift(L_shrNumShiftOut),
							.overflow(),
							.out(L_shrIn)
							);
							
L_negate codebook_L_negate(
									.var_in(L_negateOut),
									.var_out(L_negateIn)
									);
									
L_mult codebook_L_mult(
								.a(L_multOutA),
								.b(L_multOutB),					
								.overflow(),
								.product(L_multIn)
								);
								
L_msu codebook_L_msu(
							.a(L_msuOutA),
							.b(L_msuOutB),
							.c(L_msuOutC),
							.overflow(),
							.out(L_msuIn)
							);
							
shr codebook_shr(
						.var1(shrVar1Out),
						.var2(shrVar2Out),
						.overflow(),
						.result(shrIn)
						);
L_add codebook_L_add(
						.a(L_addOutA),
						.b(L_addOutB),
						.overflow(),
						.sum(L_addIn)
					 );

L_add codebook_L_add2(
						.a(L_add2OutA),
						.b(L_add2OutB),
						.overflow(),
						.sum(L_add2In)
					 );

L_add codebook_L_add3(
						.a(L_add3OutA),
						.b(L_add3OutB),
						.overflow(),
						.sum(L_add3In)
					 );

L_add codebook_L_add4(
						.a(L_add4OutA),
						.b(L_add4OutB),
						.overflow(),
						.sum(L_add4In)
					 );	

Scratch_Memory_Controller testMem(
											 .addra(codebookMux1Out),
											 .dina(codebookMux2Out),
											 .wea(codebookMux3Out),
											 .clk(clk),
											 .addrb(codebookMuxOut),
											 .doutb(memIn)
											 );

//Memory muxes
	//codebook read address mux
	always @(*)
	begin
		case	(codebookMuxSel)	
			'd0 :	codebookMuxOut = memReadAddr;
			'd1:	codebookMuxOut = testReadAddr;
		endcase
	end
	
	//codebook write address mux
	always @(*)
	begin
		case	(codebookMuxSel)	
			'd0 :	codebookMux1Out = memWriteAddr;
			'd1:	codebookMux1Out = testWriteAddr;
		endcase
	end
	
	//codebook write input mux
	always @(*)
	begin
		case	(codebookMuxSel)	
			'd0 :	codebookMux2Out = memOut;
			'd1:	codebookMux2Out = testMemOut;
		endcase
	end
	
	//codebook write enable mux
	always @(*)
	begin
		case	(codebookMuxSel)	
			'd0 :	codebookMux3Out = memWriteEn;
			'd1:	codebookMux3Out = testMemWriteEn;
		endcase
	end											 
						
endmodule
