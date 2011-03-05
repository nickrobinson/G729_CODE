`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:55:27 02/26/2011 
// Design Name: 
// Module Name:    Lsp_pre_select_pipe 
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
module Lsp_pre_select_pipe(clk, reset, start, done, Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel, readAddr, writeAddr, writeOut, 
									writeEn, testReadRequested, testWriteRequested, testWriteOut, testWrite,  readIn, const_addr,
									const_in, rbuf, cand);

	//Inputs
	input clk;
	input reset;
	input start;
	input Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel;
	input [10:0] testReadRequested;
	input [10:0] testWriteRequested;
	input [31:0] testWriteOut;
	input testWrite;
	
	input [10:0] rbuf;
	
	//Outputs
	output [10:0] readAddr;
	output [31:0] readIn;
	output [11:0] const_addr;	
	output [31:0] const_in;
	output done;
	output [10:0] writeAddr;
	output [31:0] writeOut;
	output writeEn;
	output [6:0] cand;
	
	wire [31:0] L_mac_in, L_sub_in;
	wire [15:0] add_in, sub_in;
	wire [15:0] L_mac_a, L_mac_b, add_a, add_b, sub_a, sub_b;
	wire [31:0] L_mac_c, L_sub_a, L_sub_b;
	
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
	
	Constant_Memory_Controller constMem(
	.addra(const_addr),
	.dina(),
	.wea(),
	.clock(clk),
	.douta(const_in)
	);
	
	add Lsp_pre_select_add(
	.a(add_a),
	.b(add_b),
	.overflow(),
	.sum(add_in));
	
	L_mac Lsp_pre_select_L_mac(
	.a(L_mac_a),
	.b(L_mac_b),
	.c(L_mac_c),
	.overflow(),
	.out(L_mac_in));
	
	sub Lsp_pre_select_sub(
	.a(sub_a),
	.b(sub_b),
	.overflow(),
	.diff(sub_in));
	
	L_sub Lsp_pre_select_L_sub(
	.a(L_sub_a),
	.b(L_sub_b),
	.overflow(),
	.diff(L_sub_in));
	
	Lsp_pre_select i_fsm(
	.clk(clk), 
	.start(start), 
	.reset(reset), 
	.done(done), 
	.rbuf(rbuf), 
	.sub_a(sub_a), 
	.sub_b(sub_b), 
	.sub_in(sub_in), 
	.L_mac_a(L_mac_a), 
	.L_mac_b(L_mac_b), 
	.L_mac_c(L_mac_c),
	.L_mac_in(L_mac_in), 
	.add_a(add_a), 
	.add_b(add_b), 
	.add_in(add_in), 
	.L_sub_a(L_sub_a), 
	.L_sub_b(L_sub_b), 
	.L_sub_in(L_sub_in), 
	.readIn(readIn), 
	.const_in(const_in), 
	.writeAddr(writeAddr), 
	.writeOut(writeOut), 
	.writeEn(writeEn), 
	.readAddr(readAddr), 
	.const_addr(const_addr),
	.cand(cand));
	
	
	
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
