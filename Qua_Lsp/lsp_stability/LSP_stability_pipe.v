`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:06:31 02/12/2011 
// Module Name:    LSP_stability_pipe .v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for Lsp_stability
// 
// Dependencies: 	 LSP_stability_FSM.v, Scratch_Memory_Controller.v, L_sub.v, L_add.v, sub.v,add.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LSP_stability_pipe(clk, reset,start,stabilityMuxSel,testReadAddr,testWriteAddr,testMemOut,
								  testMemWriteEn,bufAddr,memIn,done);
	//Inputs
	input clk, reset,start;
	input stabilityMuxSel;
	input [10:0] testReadAddr;
	input [10:0] testWriteAddr;
	input [31:0] testMemOut;
	input testMemWriteEn;	
	input [10:0] bufAddr;
	
	//Outputs
	output [31:0] memIn;
	output done;
	
	//Temp wires & regs	
	reg [10:0] stabilityMuxOut;
	reg [10:0] stabilityMux1Out;
	reg [31:0] stabilityMux2Out;
	reg stabilityMux3Out;
	wire [10:0] memReadAddr;
	wire [10:0] memWriteAddr;
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
	
	//memory muxes
	//stability read address mux
	always @(*)
	begin
		case	(stabilityMuxSel)	
			'd0 :	stabilityMuxOut = memReadAddr;
			'd1:	stabilityMuxOut = testReadAddr;
		endcase
	end
	
	//stability write address mux
	always @(*)
	begin
		case	(stabilityMuxSel)	
			'd0 :	stabilityMux1Out = memWriteAddr;
			'd1:	stabilityMux1Out = testWriteAddr;
		endcase
	end
	
	//stability write input mux
	always @(*)
	begin
		case	(stabilityMuxSel)	
			'd0 :	stabilityMux2Out = memOut;
			'd1:	stabilityMux2Out = testMemOut;
		endcase
	end
	
	//stability write enable mux
	always @(*)
	begin
		case	(stabilityMuxSel)	
			'd0 :	stabilityMux3Out = memWriteEn;
			'd1:	stabilityMux3Out = testMemWriteEn;
		endcase
	end

	//Instantiated modules
	Scratch_Memory_Controller testMem(
												 .addra(stabilityMux1Out),
												 .dina(stabilityMux2Out),
												 .wea(stabilityMux3Out),
												 .clk(clk),
												 .addrb(stabilityMuxOut),
												 .doutb(memIn)
												 );
	L_add stability_L_add(
								.a(L_addOutA),
								.b(L_addOutB),
								.overflow(),
								.sum(L_addIn)
								);
	L_sub stability_L_sub(
								.a(L_subOutA),
								.b(L_subOutB),
								.overflow(),
								.diff(L_subIn)
								);
	add stability_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
							);
	sub stability_sub(
						  .a(subOutA),
						  .b(subOutB),
						  .overflow(),
						  .diff(subIn)
						);
	Lsp_stability_FSM FSM (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.bufAddr(bufAddr), 
		.addIn(addIn), 
		.subIn(subIn), 
		.L_addIn(L_addIn), 
		.L_subIn(L_subIn), 
		.memIn(memIn), 
		.addOutA(addOutA), 
		.addOutB(addOutB), 
		.subOutA(subOutA), 
		.subOutB(subOutB), 
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.L_subOutA(L_subOutA), 
		.L_subOutB(L_subOutB), 
		.memReadAddr(memReadAddr), 
		.memWriteAddr(memWriteAddr), 
		.memOut(memOut), 
		.memWriteEn(memWriteEn), 
		.done(done)
	);	
endmodule
