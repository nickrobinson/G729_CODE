`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:32:11 04/12/2011 
// Design Name: 
// Module Name:    Parity_pitch_pipe 
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
module Parity_pitch_pipe(clk, start, reset, done, Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel, testReadRequested, testWriteRequested, 
						testWriteOut, testWrite, readIn, pitch_index, sum);
	//Inputs
	input clk;
	input reset;
	input start;
	input Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel;
	wire [11:0] readAddr;
	wire [11:0] writeAddr;
	wire [31:0] writeOut;
	wire writeEn;
	input [11:0] testReadRequested;
	input [11:0] testWriteRequested;
	input [31:0] testWriteOut;
	input testWrite;

	input [15:0] pitch_index;
	
	output [31:0] readIn;
	output done;
	output [15:0] sum;
	
	wire [15:0] add_a, add_b;
	wire [15:0] shr_a, shr_b;
	wire [15:0] add_in, shr_in;
	
		//working regs
	reg [11:0] Mux0Out;
	reg [11:0] Mux1Out;
	reg [31:0] Mux2Out;
	reg Mux3Out;
	
	Scratch_Memory_Controller testMem(
	.addra(Mux1Out),
	.dina(Mux2Out),
	.wea(Mux3Out),
	.clk(clk),
	.addrb(Mux0Out),
	.doutb(readIn));
	
	add Parity_pitch_add(
	.a(add_a),
	.b(add_b),
	.overflow(),
	.sum(add_in));
	
	shr Parity_pitch_shr(
	.var1(shr_a),
	.var2(shr_b),
	.overflow(),
	.result(shr_in));

	Parity_pitch i_fsm(
	.clk(clk), 
	.start(start), 
	.reset(reset), 
	.done(done), 
	.pitch_index(pitch_index), 
	.sum(sum), 
	.add_a(add_a), 
	.add_b(add_b), 
	.add_in(add_in), 
	.shr_a(shr_a), 
	.shr_b(shr_b), 
	.shr_in(shr_in));



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
