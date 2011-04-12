`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:43:34 04/07/2011 
// Design Name: 
// Module Name:    Pitch_ol_pipe 
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
module Pitch_ol_pipe(clk, start, reset, done, Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel, testReadRequested, testWriteRequested, 
						testWriteOut, testWrite, readIn, signal, L_frame, pit_max, pit_min, p_max1);
						
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
	
	input [11:0] signal;
	input [15:0] L_frame, pit_max, pit_min;
	output [15:0] p_max1;
	
	//Outputs
	output [31:0] readIn;	
	output done;
	
	wire [31:0] L_sub_a;
	wire [31:0] L_sub_b;
	wire [15:0] add_a, add_b, L_mult_a, L_mult_b;
	wire [15:0] sub_a, sub_b;
	wire [31:0] L_mac_c, L_msu_c;
	wire [15:0] L_mac_b, L_msu_b;
	wire [15:0] L_mac_a, L_msu_a;
	wire [31:0] L_shr_a;
	wire [15:0] L_shr_b;
	wire [31:0] L_sub_in;
	wire [31:0] L_mac_in, L_msu_in,L_mult_in;
	wire [15:0] add_in, sub_in;
	wire [31:0] L_shr_in;
	wire [15:0] mult_a, mult_b, mult_in;
	wire [31:0] L_add_a, L_add_b, L_add_in;
	wire [15:0] shr_a, shr_b, shr_in;
	wire [15:0] shl_a, shl_b, shl_in;
	wire [31:0] norm_l_var1;
	wire [15:0] norm_l_in;
	wire [31:0] L_shl_var1;
	wire [15:0] L_shl_numshift;
	wire [31:0] L_shl_in;
	wire [11:0] constantMemAddr;
	wire [31:0] constantMemIn;
	wire [11:0] Lag_max_readAddr;
	wire [31:0] Lag_max_readIn;
		
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
	
	add Pitch_ol_add(
	.a(add_a),
	.b(add_b),
	.overflow(),
	.sum(add_in));
	
	sub Pitch_ol_sub(
	.a(sub_a),
	.b(sub_b),
	.overflow(),
	.diff(sub_in));

	L_msu Pitch_ol_L_msu(
	.a(L_msu_a),
	.b(L_msu_b),
	.c(L_msu_c),
	.overflow(),
	.out(L_msu_in));
	
	mult Pitch_ol_mult(
	.a(mult_a), 
	.b(mult_b),
	.multRsel(),
	.overflow(), 
	.product(mult_in));
	
	L_sub Pitch_ol_L_sub(
	.a(L_sub_a),
	.b(L_sub_b),
	.overflow(),
	.diff(L_sub_in));
	
	L_add Pitch_ol_L_add(
	.a(L_add_a),
	.b(L_add_b),
	.overflow(),
	.sum(L_add_in));
	
	L_mac Pitch_ol_L_mac(
	.a(L_mac_a),
	.b(L_mac_b),
	.c(L_mac_c),
	.overflow(L_mac_overflow),
	.out(L_mac_in));
	
	L_shr Pitch_ol_L_shr(
	.var1(L_shr_a),
	.numShift(L_shr_b),
	.overflow(),
	.out(L_shr_in));
	
	L_mult Pitch_ol_L_mult(
	.a(L_mult_a),
	.b(L_mult_b),
	.overflow(),
	.product(L_mult_in));
	
	shr Pitch_ol_shr(
	.var1(shr_a),
	.var2(shr_b),
	.overflow(),
	.result(shr_in));
	
	shl Pitch_ol_shl(
	.var1(shl_a),
	.var2(shl_b),
	.overflow(),
	.result(shl_in));
	
	norm_l Pitch_ol_norm_l(
	.var1(norm_l_var1),
	.norm(norm_l_in),
	.clk(clk),
	.ready(norm_l_ready),
	.reset(reset),
	.done(norm_l_done));
	
	L_shl Pitch_ol_L_shl(
	.clk(clk),
	.reset(reset),
	.ready(L_shl_ready),
	.overflow(),
	.var1(L_shl_var1),
	.numShift(L_shl_numshift),
	.done(L_shl_done),
	.out(L_shl_in));
	
	Pitch_ol i_fsm(
	.clk(clk), 
	.start(start), 
	.reset(reset), 
	.done(done), 
	.signal(signal), 
	.pit_min(pit_min), 
	.pit_max(pit_max), 
	.L_frame(L_frame), 
	.p_max1(p_max1), 
	.writeAddr(writeAddr),
	.writeOut(writeOut), 
	.writeEn(writeEn),
	.readAddr(readAddr), 
	.readIn(readIn), 
	.L_mac_a(L_mac_a), 
	.L_mac_b(L_mac_b), 
	.L_mac_c(L_mac_c), 
	.L_mac_overflow(L_mac_overflow), 
	.L_mac_in(L_mac_in), 
	.mult_a(mult_a), 
	.mult_b(mult_b), 
	.mult_in(mult_in),
	.shr_a(shr_a), 
	.shr_b(shr_b), 
	.shr_in(shr_in), 
	.shl_a(shl_a), 
	.shl_b(shl_b), 
	.shl_in(shl_in), 
	.add_a(add_a), 
	.add_b(add_b), 
	.add_in(add_in),
	.sub_a(sub_a),
	.sub_b(sub_b),
	.sub_in(sub_in), 
	.L_sub_a(L_sub_a), 
	.L_sub_b(L_sub_b), 
	.L_sub_in(L_sub_in), 
	.Lag_max_readAddr(Lag_max_readAddr), 
//	.Lag_max_readIn(Lag_max_readIn), 
	.L_msu_a(L_msu_a), 
	.L_msu_b(L_msu_b), 
	.L_shr_b(L_shr_b), 
	.L_msu_c(L_msu_c), 
	.L_shr_a(L_shr_a),
	.L_add_a(L_add_a), 
	.L_add_b(L_add_b), 
	.L_mult_a(L_mult_a), 
	.L_mult_b(L_mult_b), 
	.L_mult_in(L_mult_in), 
	.L_msu_in(L_msu_in), 
	.L_shr_in(L_shr_in), 
	.L_add_in(L_add_in), 
	.norm_l_in(norm_l_in), 
	.norm_l_done(norm_l_done), 
	.L_shl_in(L_shl_in), 
	.L_shl_done(L_shl_done), 
	.constantMemIn(constantMemIn), 
	.norm_l_var1(norm_l_var1), 
	.norm_l_ready(norm_l_ready), 
	.L_shl_var1(L_shl_var1), 
	.L_shl_numshift(L_shl_numshift), 
	.L_shl_ready(L_shl_ready), 
	.constantMemAddr(constantMemAddr));

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
