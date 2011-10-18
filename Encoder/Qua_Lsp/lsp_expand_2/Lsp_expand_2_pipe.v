`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:06:52 02/12/2011 
// Module Name:    Lsp_expand_2_pipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for Lsp_expand_2
// 
// Dependencies: 	 Lsp_expand_2_FSM.v, Scratch_Memory_Controller.v, L_sub.v, L_add.v, sub.v,add.v,shr.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lsp_expand_2_pipe(clk, reset,start,expand2MuxSel,testReadAddr,testWriteAddr,testMemOut,
								   testMemWriteEn,memIn,done);
//Inputs
	input clk, reset,start;
	input expand2MuxSel;
	input [11:0] testReadAddr;
	input [11:0] testWriteAddr;
	input [31:0] testMemOut;
	input testMemWriteEn;	
	
	//Outputs
	output [31:0] memIn;
	output done;
	
	//Temp wires & regs	
	reg [11:0] expand2MuxOut;
	reg [11:0] expand2Mux1Out;
	reg [31:0] expand2Mux2Out;
	reg expand2Mux3Out;
	wire [11:0] memReadAddr;
	wire [11:0] memWriteAddr;
	wire [31:0] memOut;
	wire memWriteEn;
	wire [31:0] L_addOutA,L_addOutB;
	wire [31:0] L_subOutA,L_subOutB;
	wire [15:0] addOutA,addOutB;
	wire [15:0] subOutA,subOutB;
	wire [31:0] L_addIn;
	wire [31:0] L_subIn;
	wire [15:0] addIn;
	wire [15:0] subIn;
	wire [15:0] shrVar1Out;
	wire [15:0] shrVar2Out;
	wire [15:0] shrIn;
	
	//memory muxes
	//expand2 read address mux
	always @(*)
	begin
		case	(expand2MuxSel)	
			'd0 :	expand2MuxOut = memReadAddr;
			'd1:	expand2MuxOut = testReadAddr;
		endcase
	end
	
	//expand2 write address mux
	always @(*)
	begin
		case	(expand2MuxSel)	
			'd0 :	expand2Mux1Out = memWriteAddr;
			'd1:	expand2Mux1Out = testWriteAddr;
		endcase
	end
	
	//expand2 write input mux
	always @(*)
	begin
		case	(expand2MuxSel)	
			'd0 :	expand2Mux2Out = memOut;
			'd1:	expand2Mux2Out = testMemOut;
		endcase
	end
	
	//expand2 write enable mux
	always @(*)
	begin
		case	(expand2MuxSel)	
			'd0 :	expand2Mux3Out = memWriteEn;
			'd1:	expand2Mux3Out = testMemWriteEn;
		endcase
	end

	//Instantiated modules
	Scratch_Memory_Controller testMem(
												 .addra(expand2Mux1Out),
												 .dina(expand2Mux2Out),
												 .wea(expand2Mux3Out),
												 .clk(clk),
												 .addrb(expand2MuxOut),
												 .doutb(memIn)
												 );
	L_add expand2_L_add(
								.a(L_addOutA),
								.b(L_addOutB),
								.overflow(),
								.sum(L_addIn)
								);
	L_sub expand2_L_sub(
								.a(L_subOutA),
								.b(L_subOutB),
								.overflow(),
								.diff(L_subIn)
								);
	add expand2_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
							);
	sub expand2_sub(
						  .a(subOutA),
						  .b(subOutB),
						  .overflow(),
						  .diff(subIn)
						);
	shr expand2_shr(
					  .var1(shrVar1Out),
					  .var2(shrVar2Out),
					  .overflow(),
					  .result(shrIn)
				  );
	Lsp_Expand_2 fsm (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.subIn(subIn), 
		.L_subIn(L_subIn), 
		.shrIn(shrIn), 
		.addIn(addIn),
		.L_addIn(L_addIn),
		.memIn(memIn), 
		.subOutA(subOutA), 
		.subOutB(subOutB), 
		.L_subOutA(L_subOutA), 
		.L_subOutB(L_subOutB), 
		.shrVar1Out(shrVar1Out), 
		.shrVar2Out(shrVar2Out), 
		.addOutA(addOutA), 
		.addOutB(addOutB), 
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.memOut(memOut), 
		.memReadAddr(memReadAddr), 
		.memWriteAddr(memWriteAddr), 
		.memWriteEn(memWriteEn), 
		.done(done)
	);					  
				 
endmodule
