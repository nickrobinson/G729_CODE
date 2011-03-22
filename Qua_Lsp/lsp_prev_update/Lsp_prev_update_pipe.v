`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    16:26:13 02/12/2011 
// Module Name:    Lsp_prev_update_pipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for Lsp_prev_update
// 
// Dependencies: 	 Lsp_expand_2_FSM.v, Scratch_Memory_Controller.v, L_sub.v, L_add.v, sub.v,add.v,shr.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lsp_prev_update_pipe(clk,reset,start,updateMuxSel,testReadAddr,testWriteAddr,testMemOut,
									 testMemWriteEn,lsp_eleAddr,freq_prevAddr,memIn,done);
									 
//Inputs
	input clk,reset,start;
	input updateMuxSel;
	input [11:0] testReadAddr;	
	input [11:0] testWriteAddr;
	input [31:0] testMemOut;	
	input testMemWriteEn;
   input [11:0] lsp_eleAddr;
	input [11:0] freq_prevAddr;
	
//Outputs
	output [31:0] memIn;
	output done;
	
//Internal Wires
	wire [31:0] L_addOutA,L_addOutB;
	wire [31:0] L_addIn;
	wire [15:0] subOutA,subOutB;
	wire [15:0] subIn;
	wire [15:0] addOutA,addOutB;
	wire [15:0] addIn;	
	wire [31:0] memOut;
	wire [11:0] memReadAddr;
	wire [11:0] memWriteAddr;
	wire memWriteEn;
	
//Internal regs
	reg [11:0] updateMuxOut;
   reg [11:0] updateMux1Out;
	reg [31:0] updateMux2Out;
	reg updateMux3Out;
	
	//Memory muxes
	//update read address mux
	always @(*)
	begin
		case	(updateMuxSel)	
			'd0 :	updateMuxOut = memReadAddr;
			'd1:	updateMuxOut = testReadAddr;
		endcase
	end
	
	//update write address mux
	always @(*)
	begin
		case	(updateMuxSel)	
			'd0 :	updateMux1Out = memWriteAddr;
			'd1:	updateMux1Out = testWriteAddr;
		endcase
	end
	
	//update write input mux
	always @(*)
	begin
		case	(updateMuxSel)	
			'd0 :	updateMux2Out = memOut;
			'd1:	updateMux2Out = testMemOut;
		endcase
	end
	
	//update write enable mux
	always @(*)
	begin
		case	(updateMuxSel)	
			'd0 :	updateMux3Out = memWriteEn;
			'd1:	updateMux3Out = testMemWriteEn;
		endcase
	end
//Instantited Modules	
Scratch_Memory_Controller testMem(
												 .addra(updateMux1Out),
												 .dina(updateMux2Out),
												 .wea(updateMux3Out),
												 .clk(clk),
												 .addrb(updateMuxOut),
												 .doutb(memIn)
												 );
	L_add update_L_add(
								.a(L_addOutA),
								.b(L_addOutB),
								.overflow(),
								.sum(L_addIn)
								);
							
	sub update_sub(
						  .a(subOutA),
						  .b(subOutB),
						  .overflow(),
						  .diff(subIn)
						);		 
	
	add update_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
						);
 Lsp_prev_update fsm( 
								.clk(clk), 
								.reset(reset), 
								.start(start), 
								.addIn(addIn),
								.subIn(subIn),		
								.L_addIn(L_addIn),
								.memIn(memIn),
								.lsp_eleAddr(lsp_eleAddr),
								.freq_prevAddr(freq_prevAddr),
								.addOutA(addOutA), 
								.addOutB(addOutB), 
								.subOutA(subOutA), 
								.subOutB(subOutB), 		
								.L_addOutA(L_addOutA), 
								.L_addOutB(L_addOutB), 
								.memOut(memOut), 
								.memReadAddr(memReadAddr), 
								.memWriteAddr(memWriteAddr), 
								.memWriteEn(memWriteEn), 
								.done(done)
								);						
endmodule
