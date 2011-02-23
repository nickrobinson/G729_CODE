`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:47:28 02/08/2011 
// Design Name: 
// Module Name:    Lsp_prev_compose_top 
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
module Lsp_prev_compose_top(clk, start, reset, done, Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel, testReadRequested, testWriteRequested, 
										testWriteOut, testWrite, readIn, lspele, fg, fg_sum, freq_prev, lsp);

	input start;
	input clk;
	input reset;
	input [10:0] testReadRequested;
	input [10:0] testWriteRequested;
	input [31:0] testWriteOut;
	input testWrite;
	input Mux0Sel;
	input Mux1Sel; 
	input Mux2Sel; 
	input Mux3Sel;
	input [10:0] lspele;
	input [11:0] fg;
	input [11:0] fg_sum;
	input [10:0] freq_prev;
	input [10:0] lsp;
	output done;
	output [31:0] readIn;

	wire [10:0] readAddr;
	wire [10:0] writeAddr;
	wire [31:0] writeOut;
	wire writeEn;
	wire [31:0] L_mult_in;
	wire [31:0] L_mac_in;
	wire [15:0] add_in;
	wire [15:0] L_mult_a;
	wire [15:0] L_mult_b;
	wire [15:0] add_a;
	wire [15:0] add_b;
	wire [15:0] L_mac_a;
	wire [15:0] L_mac_b;
	wire [31:0] L_mac_c;
	wire [11:0] constantMemAddr;
	wire [31:0] constantMemIn;
Lsp_prev_compose_pipe i_pipe(
	.clk(clk), 
	.L_mult_a(L_mult_a), 
	.L_mult_b(L_mult_b), 
	.add_a(add_a), 
	.add_b(add_b), 
	.L_mac_a(L_mac_a), 
	.L_mac_b(L_mac_b), 
	.L_mac_c(L_mac_c),
	.Mux0Sel(Mux0Sel), 
	.Mux1Sel(Mux1Sel), 
	.Mux2Sel(Mux2Sel), 
	.Mux3Sel(Mux3Sel),
	.readAddr(readAddr), 
	.writeAddr(writeAddr), 
	.writeOut(writeOut), 
	.writeEn(writeEn), 
	.testReadRequested(testReadRequested), 
	.testWriteRequested(testWriteRequested), 
	.testWriteOut(testWriteOut), 
	.testWrite(testWrite), 
	.L_mac_in(L_mac_in), 
	.add_in(add_in), 
	.readIn(readIn), 
	.L_mult_in(L_mult_in),
	.constantMemIn(constantMemIn),
	.constantMemAddr(constantMemAddr)
	);

Lsp_prev_compose i_fsm(
	.start(start), 
	.clk(clk), 
	.done(done), 
	.reset(reset), 
	.lspele(lspele), 
	.fg(fg), 
	.fg_sum(fg_sum), 
	.freq_prev(freq_prev), 
	.lsp(lsp), 
	.readAddr(readAddr), 
	.readIn(readIn), 
	.writeAddr(writeAddr), 
	.writeOut(writeOut), 
	.writeEn(writeEn),
	.L_mult_in(L_mult_in), 
	.add_in(add_in), 
	.L_mult_a(L_mult_a), 
	.L_mult_b(L_mult_b), 
	.add_a(add_a), 
	.add_b(add_b), 
	.L_mac_a(L_mac_a), 
	.L_mac_b(L_mac_b), 
	.L_mac_c(L_mac_c), 
	.L_mac_in(L_mac_in),
	.constantMemIn(constantMemIn),
	.constantMemAddr(constantMemAddr)
	);


endmodule
