`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:44:38 02/07/2011 
// Design Name: 
// Module Name:    Weight_Az_Top 
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
module Weight_Az_Top(start, clk, reset, done, A, AP, gammaAddr, wazReadRequested, wazWriteRequested, wazOut, wazWrite,
							wazMuxSel, wazMux1Sel, wazMux2Sel, wazMux3Sel, readIn);
	input start;
	input clk;
	input reset;
	input [11:0] wazReadRequested;
	input [11:0] wazWriteRequested;
	input [31:0] wazOut;
	input wazWrite;
	input wazMuxSel;
	input wazMux1Sel; 
	input wazMux2Sel; 
	input wazMux3Sel;
	input [11:0] A;
	input [11:0] AP;
	input [11:0] gammaAddr;
	
	output done;
	output [31:0] readIn;

	wire [11:0] readAddr;
	wire [11:0] writeAddr;
	wire [31:0] writeOut;
	wire writeEn;
	wire [31:0] L_mult_in;
	wire [31:0] L_add_in;
	wire [15:0] add_in;
	wire [15:0] L_mult_a;
	wire [15:0] L_mult_b;
	wire [15:0] add_a;
	wire [15:0] add_b;
	wire [31:0] L_add_a;
	wire [31:0] L_add_b;
	

	Weight_Az i_fsm(
	.start(start),
	.clk(clk),
	.done(done),
	.reset(reset),
	.A(A),
	.AP(AP),
	.gammaAddr(gammaAddr),
	.readAddr(readAddr),
	.readIn(readIn),
	.writeAddr(writeAddr),
	.writeOut(writeOut),
	.writeEn(writeEn),
	.L_mult_in(L_mult_in),
	.L_add_in(L_add_in),
	.add_in(add_in),
	.L_mult_a(L_mult_a),
	.L_mult_b(L_mult_b),
	.add_a(add_a),
	.add_b(add_b),
	.L_add_a(L_add_a),
	.L_add_b(L_add_b));

	Weight_Az_Pipe i_pipe(
		.clk(clk), 
		.L_mult_a(L_mult_a), 
		.L_mult_b(L_mult_b), 
		.add_a(add_a), 
		.add_b(add_b), 
		.L_add_a(L_add_a), 
		.L_add_b(L_add_b), 
		.wazMuxSel(wazMuxSel), 
		.wazMux1Sel(wazMux1Sel), 
		.wazMux2Sel(wazMux2Sel), 
		.wazMux3Sel(wazMux3Sel),
		.readAddr(readAddr), 
		.writeAddr(writeAddr), 
		.writeOut(writeOut), 
		.writeEn(writeEn), 
		.wazReadRequested(wazReadRequested), 
		.wazWriteRequested(wazWriteRequested), 
		.wazOut(wazOut), 
		.wazWrite(wazWrite), 
		.L_add_in(L_add_in), 
		.add_in(add_in), 
		.readIn(readIn), 
		.L_mult_in(L_mult_in)
	);


endmodule
