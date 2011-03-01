`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:59:51 02/19/2011 
// Design Name: 
// Module Name:    Lsp_last_select_pipe 
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
module Lsp_last_select_pipe(clk, start, reset, done, Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel, readAddr, writeAddr, writeOut, 
										writeEn, testReadRequested, testWriteRequested, testWriteOut, testWrite, readIn, L_tdist);

	//Inputs
	input clk;
	input reset;
	input start;
	input Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel;
	input [10:0] testReadRequested;
	input [10:0] testWriteRequested;
	input [31:0] testWriteOut;
	input testWrite;
	input [10:0] L_tdist;
		
	//Outputs
	output [10:0] readAddr;
	output [31:0] readIn;	
	output done;
	output [10:0] writeAddr;
	output [31:0] writeOut;
	output writeEn;

	
	wire [31:0] L_sub_a;
	wire [31:0] L_sub_b;
	wire [31:0] L_sub_in;
	
		
	//working regs
	reg [10:0] Mux0Out;
	reg [10:0] Mux1Out;
	reg [31:0] Mux2Out;
	reg Mux3Out;
	
	Scratch_Memory_Controller testMem(
	.addra(Mux1Out),
	.dina(Mux2Out),
	.wea(Mux3Out),
	.clk(clk),
	.addrb(Mux0Out),
	.doutb(readIn));
	
	L_sub Lsp_last_select_L_sub(
		.a(L_sub_a),
		.b(L_sub_b),
		.overflow(),
		.diff(L_sub_in));
	
	Lsp_last_select i_fsm(
		.clk(clk), 
		.start(start), 
		.reset(reset), 
		.done(done), 
		.L_tdist(L_tdist),  
		.readIn(readIn), 
		.writeAddr(writeAddr), 
		.writeOut(writeOut), 
		.writeEn(writeEn), 
		.readAddr(readAddr),
		.L_sub_in(L_sub_in), 
		.L_sub_a(L_sub_a), 
		.L_sub_b(L_sub_b));
	
	
		//read adddress mux
		always @(*)
		begin
			case	(Mux0Sel)	
				'd0 :	Mux0Out = testReadRequested;
				'd1:	Mux0Out = readAddr;
			endcase
		end
		
		//write address mux
		always @(*)
		begin
			case	(Mux1Sel)	
				'd0 :	Mux1Out = testWriteRequested;
				'd1:	Mux1Out = writeAddr;
			endcase
		end
		
		//write input mux
		always @(*)
		begin
			case	(Mux2Sel)	
				'd0 :	Mux2Out = testWriteOut;
				'd1:	Mux2Out = writeOut;
			endcase
		end
		
		//write enable mux
		always @(*)
		begin
			case	(Mux3Sel)	
				'd0 :	Mux3Out = testWrite;
				'd1:	Mux3Out = writeEn;
			endcase
		end
endmodule
