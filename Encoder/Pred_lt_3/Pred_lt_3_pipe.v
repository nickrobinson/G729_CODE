`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:30:52 04/13/2011 
// Design Name: 
// Module Name:    Pred_lt_3_pipe 
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
module Pred_lt_3_pipe(clk, start, reset, done, Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel, testReadRequested, testWriteRequested, 
						testWriteOut, testWrite, readIn, constantMemIn, exc, t0, frac, L_subfr);
						
	//Inputs
	input clk;
	input reset;
	input start;
	input Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel;
	wire [11:0] readAddr;
	wire [11:0] constantMemAddr;
	wire [11:0] writeAddr;
	wire [31:0] writeOut;
	wire writeEn;
	input [11:0] testReadRequested;
	input [11:0] testWriteRequested;
	input [31:0] testWriteOut;
	input testWrite;
	
	input [15:0] t0, frac, L_subfr;
	input [11:0] exc;
	input [31:0] readIn;
	input [31:0] constantMemIn;

	//Outputs 
	output done;
	
	wire [15:0] add_in, sub_in;
	wire [31:0] L_mac_in, L_add_in;
	wire [31:0] L_negate_in;
	wire [15:0] add_a, add_b;
	wire [15:0] sub_a, sub_b;
	wire [15:0] L_mac_a, L_mac_b;
	wire [31:0] L_mac_c;
	wire [31:0] L_add_a, L_add_b;
	wire [31:0] L_negate_out;
	
	
	
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
	
	Constant_Memory_Controller constmem(
	.addra(constantMemAddr),
	.dina(32'd0),
	.wea(1'd0),
	.clock(clk),
	.douta(constantMemIn));
	
	add Pred_lt_3_add(
	.a(add_a),
	.b(add_b),
	.overflow(),
	.sum(add_in));
	
	sub Pred_lt_3_sub(
	.a(sub_a),
	.b(sub_b),
	.overflow(),
	.diff(sub_in));
	
	L_add Pred_lt_3_L_add(
	.a(L_add_a),
	.b(L_add_b),
	.overflow(),
	.sum(L_add_in));
	
	L_mac Pred_lt_3_L_mac(
	.a(L_mac_a),
	.b(L_mac_b),
	.c(L_mac_c),
	.overflow(),
	.out(L_mac_in));
	
	L_negate Pred_lt_3_L_negate(
	.var_in(L_negate_out),
	.var_out(L_negate_in));
	
	Pred_lt_3 i_fsm(
	.clk(clk), 
	.start(start), 
	.reset(reset), 
	.done(done), 
	.exc(exc), 
	.t0(t0), 
	.frac(frac), 
	.L_subfr(L_subfr), 
	.writeAddr(writeAddr), 
	.writeOut(writeOut), 
	.writeEn(writeEn), 
	.readAddr(readAddr), 
	.readIn(readIn), 
	.add_a(add_a), 
	.add_b(add_b), 
	.add_in(add_in), 
	.L_mac_a(L_mac_a), 
	.L_mac_b(L_mac_b), 
	.L_mac_c(L_mac_c), 
	.L_mac_in(L_mac_in), 
	.L_add_a(L_add_a), 
	.L_add_b(L_add_b), 
	.L_add_in(L_add_in), 
	.L_negate_out(L_negate_out), 
	.L_negate_in(L_negate_in), 
	.sub_a(sub_a), 
	.sub_b(sub_b), 
	.sub_in(sub_in), 
	.constantMemAddr(constantMemAddr),
	.constantMemIn(constantMemIn));
	
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
