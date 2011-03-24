`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:28:49 02/07/2011 
// Design Name: 
// Module Name:    Weight_Az_Pipe 
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
module Weight_Az_Pipe(clk, L_mult_a, L_mult_b, add_a, add_b, L_add_a, L_add_b, wazMuxSel, wazMux1Sel, wazMux2Sel, wazMux3Sel,
								readAddr, writeAddr, writeOut, writeEn, wazReadRequested, wazWriteRequested, wazOut, wazWrite, L_add_in, 
								add_in, readIn, L_mult_in);
	// Inputs
	input clk;
	input [15:0] L_mult_a;
	input [15:0] L_mult_b;
	input [15:0] add_a;
	input [15:0] add_b;
	input [31:0] L_add_a;
	input [31:0] L_add_b;
	input wazMuxSel, wazMux1Sel, wazMux2Sel, wazMux3Sel;
	input [11:0] readAddr;
	input [11:0] writeAddr;
	input [31:0] writeOut;
	input writeEn;
	input [11:0] wazReadRequested;
	input [11:0] wazWriteRequested;
	input [31:0] wazOut;
	input wazWrite;

	// Outputs
	output [31:0] L_add_in;
	output [15:0] add_in;	 
	output [31:0] readIn;
	output [31:0] L_mult_in;	

	//working regs
	reg [11:0] wazMuxOut;
	reg [11:0] wazMux1Out;
	reg [31:0] wazMux2Out;
	reg wazMux3Out;
	



Scratch_Memory_Controller testMem(
.addra(wazMux1Out),
.dina(wazMux2Out),
.wea(wazMux3Out),
.clk(clk),
.addrb(wazMuxOut),
.doutb(readIn));
	
L_mult Weight_Az_L_mult(
.a(L_mult_a),
.b(L_mult_b),
.overflow(),
.product(L_mult_in));
						 
L_add Weight_Az_L_add(
.a(L_add_a),
.b(L_add_b),
.overflow(),
.sum(L_add_in));	
	
add Weight_Az_add(
.a(add_a),
.b(add_b),
.overflow(),
.sum(add_in));



	always @(*)
		begin
			case	(wazMuxSel)	
				'd0 :	wazMuxOut = wazReadRequested;
				'd1:	wazMuxOut = readAddr;
			endcase
		end
		
		//lsp write address mux
		always @(*)
		begin
			case	(wazMux1Sel)	
				'd0 :	wazMux1Out = wazWriteRequested;
				'd1:	wazMux1Out = writeAddr;
			endcase
		end
		
		//lsp write input mux
		always @(*)
		begin
			case	(wazMux2Sel)	
				'd0 :	wazMux2Out = wazOut;
				'd1:	wazMux2Out = writeOut;
			endcase
		end
		
		//lsp write enable mux
		always @(*)
		begin
			case	(wazMux3Sel)	
				'd0 :	wazMux3Out = wazWrite;
				'd1:	wazMux3Out = writeEn;
			endcase
		end





endmodule
