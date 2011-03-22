`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:06:52 02/12/2011 
// Module Name:    Lsp_expand_1_pipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for Lsp_expand_1
// 
// Dependencies: 	 LSP_expand_1_FSM.v, Scratch_Memory_Controller.v, L_sub.v, L_add.v, sub.v,add.v,shr.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lsp_expand_1_pipe(clk, reset,start,expand1MuxSel,testReadAddr,testWriteAddr,testMemOut,
								   testMemWriteEn,memIn,done);
//Inputs
	input clk, reset,start;
	input expand1MuxSel;
	input [11:0] testReadAddr;
	input [11:0] testWriteAddr;
	input [31:0] testMemOut;
	input testMemWriteEn;	
	
	//Outputs
	output [31:0] memIn;
	output done;
	
	//Temp wires & regs	
	reg [11:0] expand1MuxOut;
	reg [11:0] expand1Mux1Out;
	reg [31:0] expand1Mux2Out;
	reg expand1Mux3Out;
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
	//expand1 read address mux
	always @(*)
	begin
		case	(expand1MuxSel)	
			'd0 :	expand1MuxOut = memReadAddr;
			'd1:	expand1MuxOut = testReadAddr;
		endcase
	end
	
	//expand1 write address mux
	always @(*)
	begin
		case	(expand1MuxSel)	
			'd0 :	expand1Mux1Out = memWriteAddr;
			'd1:	expand1Mux1Out = testWriteAddr;
		endcase
	end
	
	//expand1 write input mux
	always @(*)
	begin
		case	(expand1MuxSel)	
			'd0 :	expand1Mux2Out = memOut;
			'd1:	expand1Mux2Out = testMemOut;
		endcase
	end
	
	//expand1 write enable mux
	always @(*)
	begin
		case	(expand1MuxSel)	
			'd0 :	expand1Mux3Out = memWriteEn;
			'd1:	expand1Mux3Out = testMemWriteEn;
		endcase
	end

	//Instantiated modules
	Scratch_Memory_Controller testMem(
												 .addra(expand1Mux1Out),
												 .dina(expand1Mux2Out),
												 .wea(expand1Mux3Out),
												 .clk(clk),
												 .addrb(expand1MuxOut),
												 .doutb(memIn)
												 );
	L_add expand1_L_add(
								.a(L_addOutA),
								.b(L_addOutB),
								.overflow(),
								.sum(L_addIn)
								);
	L_sub expand1_L_sub(
								.a(L_subOutA),
								.b(L_subOutB),
								.overflow(),
								.diff(L_subIn)
								);
	add expand1_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
							);
	sub expand1_sub(
						  .a(subOutA),
						  .b(subOutB),
						  .overflow(),
						  .diff(subIn)
						);
	shr expand1_shr(
					  .var1(shrVar1Out),
					  .var2(shrVar2Out),
					  .overflow(),
					  .result(shrIn)
				  );
	Lsp_expand_1 fsm (
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

