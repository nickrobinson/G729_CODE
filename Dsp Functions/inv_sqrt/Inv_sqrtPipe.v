`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    16:16:52 03/01/2011 
// Module Name:    Inv_sqrtPipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an module to instantiate all the math and memory needed for Inv_sqrtPipe, 
//						 as well as the FSM
// 
// Dependencies: 	 L_msu.v,L_shl.v,L_shr.v, add.v, norm_l.v,shr.v,sub.v, Scratch_Memory_Controller.v,
//						 Constant_Memory_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Inv_sqrtPipe(clk,start,reset,in,done,out);
	
	//Inputs
	input clk,start,reset;
	input [31:0] in;	
	
	//Internal Wires
	wire [15:0] norm_lIn;
	wire norm_lDone;
	wire [31:0] L_shlIn;
	wire L_shlDone;
	wire [15:0] subIn;
	wire [31:0] L_shrIn;
	wire [15:0] shrIn;
	wire [15:0] addIn;
	wire [31:0] L_msuIn;	
	wire [31:0] constantMemIn;
	wire [31:0] norm_lVar1Out;
	wire norm_lReady;
	wire [31:0] L_shlVar1Out;
	wire [15:0] L_shlNumShift;
	wire L_shlReady;
	wire [15:0] subOutA,subOutB;
	wire [31:0] L_shrVar1Out;
	wire [15:0]  L_shrNumShiftOut;
	wire [15:0] shrVar1Out,shrVar2Out;
	wire [15:0] addOutA,addOutB;
	wire [15:0] L_msuOutA,L_msuOutB;
	wire [31:0] L_msuOutC;
	wire [11:0] constantMemAddr;
	
	//Outputs
	output done;
	output [31:0] out;
	
Inv_sqrt fsm(
				  .clk(clk),
				  .start(start),
				  .reset(reset),
				  .in(in),
				  .norm_lIn(norm_lIn),
				  .norm_lDone(norm_lDone),
				  .L_shlIn(L_shlIn),
				  .L_shlDone(L_shlDone),
				  .subIn(subIn),
				  .L_shrIn(L_shrIn),
				  .shrIn(shrIn),
				  .addIn(addIn),
				  .L_msuIn(L_msuIn),				  
				  .constantMemIn(constantMemIn),
				  .norm_lVar1Out(norm_lVar1Out),
				  .norm_lReady(norm_lReady),
				  .L_shlVar1Out(L_shlVar1Out),
				  .L_shlNumShiftOut(L_shlNumShift),
				  .L_shlReady(L_shlReady),
				  .subOutA(subOutA),
				  .subOutB(subOutB),
				  .L_shrVar1Out(L_shrVar1Out),
				  .L_shrNumShiftOut(L_shrNumShiftOut),
				  .shrVar1Out(shrVar1Out),
				  .shrVar2Out(shrVar2Out),
				  .addOutA(addOutA),
				  .addOutB(addOutB),
				  .L_msuOutA(L_msuOutA),
				  .L_msuOutB(L_msuOutB),
				  .L_msuOutC(L_msuOutC),				  
				  .constantMemAddr(constantMemAddr),
				  .done(done),
				  .out(out)
				  );
				  
L_msu sqrt_Lmsu(
					.a(L_msuOutA),
					.b(L_msuOutB),
					.c(L_msuOutC),
					.overflow(),
					.out(L_msuIn)
					);
			
L_shl sqrt_L_shl(
					  .clk(clk),
					  .reset(reset),
					  .ready(L_shlReady),
					  .overflow(overflow),
					  .var1(L_shlVar1Out),
					  .numShift(L_shlNumShift),
					  .done(L_shlDone),
					  .out(L_shlIn)
					  );
					  
L_shr sqrt_L_shr(
						.var1(L_shrVar1Out),
						.numShift(L_shrNumShiftOut),
						.overflow(),
						.out(L_shrIn)
						);	
						
add sqrt_add(
					.a(addOutA),
					.b(addOutB),
					.overflow(),
					.sum(addIn)
					);
norm_l sqrt_norm_l(
						.var1(norm_lVar1Out),
						.norm(norm_lIn),
						.clk(clk),
						.ready(norm_lReady),
						.reset(reset),
						.done(norm_lDone)
					);
					
shr sqrt_shr(
				  .var1(shrVar1Out),
				  .var2(shrVar2Out),
				  .overflow(),
				  .result(shrIn)
			);
			
sub sqrt_sub(
			  .a(subOutA),
			  .b(subOutB),
			  .overflow(),
			  .diff(subIn)
			);
			
Constant_Memory_Controller constantMem(
													 .addra(constantMemAddr),
													 .dina(32'd0),
													 .wea(1'd0),
													 .clock(clk),
													 .douta(constantMemIn)
													);

endmodule
