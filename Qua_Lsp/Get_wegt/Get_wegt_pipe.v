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
module Get_wegt_pipe(clk, reset,start,getWegtMuxSel,testReadAddr,testWriteAddr,testMemOut,
								   testMemWriteEn, memIn, done, flspAddr, wegtAddr);
									
//Inputs
	input clk, reset,start;
	input getWegtMuxSel;
	input [10:0] testReadAddr;
	input [10:0] testWriteAddr;
	input [31:0] testMemOut;
	input testMemWriteEn;	
	input [10:0] flspAddr;
	input [10:0] wegtAddr;
	
	//Outputs
	output [31:0] memIn;
	output done;
	
	//Temp wires & regs	
	reg [10:0] MuxOut;
	reg [10:0] getWegtMuxOut;
	reg [10:0] getWegtMux1Out;
	reg [31:0] getWegtMux2Out;
	reg getWegtMux3Out;
	wire [10:0] memReadAddr;
	wire [10:0] memWriteAddr;
	wire [31:0] memOut;
	wire memWriteEn;
	wire [15:0] addOutA,addOutB;
	wire [15:0] subOutA,subOutB;
	wire [15:0] L_multOutA,L_multOutB;
	wire [31:0] L_subOutA,L_subOutB;
	wire [31:0] L_addOutA,L_addOutB;
	wire [15:0] addIn;
	wire [15:0] subIn;
	wire [31:0] L_subIn;
	wire [31:0] L_addIn;
	wire [31:0] L_multIn;
	wire [31:0] L_shlOutVar1;
	wire [15:0] L_shlNumShiftOut;
	wire L_shlReady;
	wire [31:0] L_shlIn;
	wire norm_sReady;
	wire [15:0] norm_sOut; 
	wire [15:0] norm_sIn;
	wire norm_sDone;
 
	
	
	//memory muxes
	//getWegt read address mux
	always @(*)
	begin
		case	(getWegtMuxSel)	
			'd0 :	getWegtMuxOut = memReadAddr;
			'd1:	getWegtMuxOut = testReadAddr;
		endcase
	end
	
	//getWegt write address mux
	always @(*)
	begin
		case	(getWegtMuxSel)	
			'd0 :	getWegtMux1Out = memWriteAddr;
			'd1:	getWegtMux1Out = testWriteAddr;
		endcase
	end
	
	//getWegt write input mux
	always @(*)
	begin
		case	(getWegtMuxSel)	
			'd0 :	getWegtMux2Out = memOut;
			'd1:	getWegtMux2Out = testMemOut;
		endcase
	end
	
	//getWegt write enable mux
	always @(*)
	begin
		case	(getWegtMuxSel)	
			'd0 :	getWegtMux3Out = memWriteEn;
			'd1:	getWegtMux3Out = testMemWriteEn;
		endcase
	end

	//Instantiated modules
	Scratch_Memory_Controller testMem(
												 .addra(getWegtMux1Out),
												 .dina(getWegtMux2Out),
												 .wea(getWegtMux3Out),
												 .clk(clk),
												 .addrb(getWegtMuxOut),
												 .doutb(memIn)
												 );
												 
	add getWegt_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
							);
	sub getWegt_sub(
						  .a(subOutA),
						  .b(subOutB),
						  .overflow(),
						  .diff(subIn)
						);
						
	L_sub getWegt_L_sub(
						  .a(L_subOutA),
						  .b(L_subOutB),
						  .overflow(),
						  .diff(L_subIn)
						);
						
	L_add getWegt_L_add(
					  .a(L_addOutA),
					  .b(L_addOutB),
					  .overflow(),
					  .sum(L_addIn)
					);
						
	L_mult getWegt_L_mult(
						  .a(L_multOutA),
						  .b(L_multOutB),
						  .overflow(),
						  .product(L_multIn)
						);
						
	norm_s getWegt_norm_s(
						.var1(norm_sOut),
						.norm(norm_sIn),
						.clk(clk),
						.ready(norm_sReady),
						.reset(reset),
						.done(norm_sDone)
					);
						
	L_shl getWegt_L_shl(
					 .clk(clk),
					 .reset(reset),
					 .ready(L_shlReady),
					 .overflow(unusedOverflow1),
					 .var1(L_shlOutVar1),
					 .numShift(L_shlNumShiftOut),
					 .done(L_shlDone),
					 .out(L_shlIn)
					 );
						
	Get_wegt fsm (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.L_subIn(L_subIn),
		.L_addIn(L_addIn),
		.L_multIn(L_multIn),
		.subIn(subIn), 
		.addIn(addIn),
		.memIn(memIn), 
		.subOutA(subOutA), 
		.subOutB(subOutB), 
		.L_subOutA(L_subOutA), 
		.L_subOutB(L_subOutB), 
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.L_multOutA(L_multOutA), 
		.L_multOutB(L_multOutB), 
		.addOutA(addOutA), 
		.addOutB(addOutB), 
		.memOut(memOut), 
		.memReadAddr(memReadAddr), 
		.memWriteAddr(memWriteAddr), 
		.memWriteEn(memWriteEn), 
		.done(done),
		.flspAddr(flspAddr),
		.wegtAddr(wegtAddr),
		.L_shlIn(L_shlIn), 
		.L_shlDone(L_shlDone),
		.L_shlOutVar1(L_shlOutVar1), 
		.L_shlNumShiftOut(L_shlNumShiftOut), 
		.L_shlReady(L_shlReady),
		.norm_sOut(norm_sOut),
		.norm_sIn(norm_sIn),
		.norm_sReady(norm_sReady),
		.norm_sDone(norm_sDone)
	);					  
				 
endmodule