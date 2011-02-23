`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:48:19 02/08/2011 
// Design Name: 
// Module Name:    Lsp_prev_compose_pipe 
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
module Lsp_prev_compose_pipe(clk, L_mult_a, L_mult_b, add_a, add_b, L_mac_a, L_mac_b, L_mac_c, Mux0Sel, Mux1Sel, Mux2Sel, 
										Mux3Sel, readAddr, writeAddr, writeOut, writeEn, testReadRequested, testWriteRequested, 
										testWriteOut, testWrite, constantMemAddr,L_mac_in, add_in, readIn, L_mult_in,constantMemIn);


	//Inputs
	input clk;
	input [15:0] L_mult_a;
	input [15:0] L_mult_b;
	input [15:0] add_a;
	input [15:0] add_b;
	input [31:0] L_mac_c;
	input [15:0] L_mac_b;
	input [15:0] L_mac_a;
	input Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel;
	input [10:0] readAddr;
	input [10:0] writeAddr;
	input [31:0] writeOut;
	input writeEn;
	input [10:0] testReadRequested;
	input [10:0] testWriteRequested;
	input [31:0] testWriteOut;
	input testWrite;
	input [11:0] constantMemAddr;
	//Outputs
	output [31:0] L_mult_in;
	output [31:0] L_mac_in;
	output [15:0] add_in;
	output [31:0] readIn;
	output [31:0] constantMemIn;
	
		//working regs
	reg [10:0] Mux0Out;
	reg [10:0] Mux1Out;
	reg [31:0] Mux2Out;
	reg Mux3Out;
	
	Constant_Memory_Controller constantMem(
														.addra(constantMemAddr),
														.dina(32'd0),
														.wea(1'd0),
														.clock(clk),
														.douta(constantMemIn)
														);
	
	Scratch_Memory_Controller testMem(
	.addra(Mux1Out),
	.dina(Mux2Out),
	.wea(Mux3Out),
	.clk(clk),
	.addrb(Mux0Out),
	.doutb(readIn));
		
	L_mult Lsp_prev_compose_L_mult(
	.a(L_mult_a),
	.b(L_mult_b),
	.overflow(),
	.product(L_mult_in));
							 
	L_mac Lsp_prev_compose_L_mac(
	.a(L_mac_a),
	.b(L_mac_b),
	.c(L_mac_c),
	.overflow(),
	.out(L_mac_in));	
		
	add Lsp_prev_compose_add(
	.a(add_a),
	.b(add_b),
	.overflow(),
	.sum(add_in));

	always @(*)
		begin
			case	(Mux0Sel)	
				'd0 :	Mux0Out = testReadRequested;
				'd1:	Mux0Out = readAddr;
			endcase
		end
		
		//lsp write address mux
		always @(*)
		begin
			case	(Mux1Sel)	
				'd0 :	Mux1Out = testWriteRequested;
				'd1:	Mux1Out = writeAddr;
			endcase
		end
		
		//lsp write input mux
		always @(*)
		begin
			case	(Mux2Sel)	
				'd0 :	Mux2Out = testWriteOut;
				'd1:	Mux2Out = writeOut;
			endcase
		end
		
		//lsp write enable mux
		always @(*)
		begin
			case	(Mux3Sel)	
				'd0 :	Mux3Out = testWrite;
				'd1:	Mux3Out = writeEn;
			endcase
		end

endmodule
