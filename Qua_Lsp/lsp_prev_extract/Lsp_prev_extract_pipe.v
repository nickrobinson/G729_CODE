`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
 // Mississippi State University 
 // ECE 4532-4542 Senior Design
 // Engineer: Troy Huguet
 //
 // Create Date:    16:52:45 10/21/2010
 // Module Name:    Lsp_prev_extract_pipe 
 // Project Name:    ITU G.729 Hardware Implementation
 // Target Devices: Virtex 5
 // Tool versions:  Xilinx 9.2i
 // Description:     
 // 
 // Dependencies:    
 //
 // Revision: 
 // Revision 0.01 - File Created
 // Additional Comments: 
 //
 //////////////////////////////////////////////////////////////////////////////////

module Lsp_prev_extract_pipe(clk, reset, start, done, Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel,fgAddr,
								     fg_sum_invAddr,testReadRequested, testWriteRequested, testWriteOut, 
									  testWrite,readIn,lspele,freq_prev, lsp);
										
	//Inputs
	input clk;
	input reset;
	input start;
	input Mux0Sel, Mux1Sel, Mux2Sel, Mux3Sel;	
	input [11:0] testReadRequested;
	input [11:0] testWriteRequested;
	input [31:0] testWriteOut;
	input testWrite;	
	input [11:0] lspele;
	input [11:0] freq_prev;
	input [11:0] lsp;
	input [11:0] fgAddr;
	input [11:0] fg_sum_invAddr;
	
	//Outputs
	output [31:0] readIn;	
	output done;
	
	wire L_shl_ready;
	wire [15:0] L_mult_a;
	wire [15:0] L_mult_b;
	wire [15:0] add_a;
	wire [15:0] add_b;
	wire [31:0] L_msu_c;
	wire [15:0] L_msu_b;
	wire [15:0] L_msu_a;
	wire [31:0] L_shl_a;
	wire [15:0] L_shl_b;
	wire [31:0] L_mult_in;
	wire [31:0] L_msu_in;
	wire [15:0] add_in;
	wire [31:0] L_shl_in;
	wire L_shl_done;
	wire [31:0] constantMemIn;
	wire [11:0] constantMemAddr;
	wire [11:0] readAddr;
	wire [11:0] writeAddr;
	wire [31:0] writeOut;
	wire writeEn;
	
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
	
	Constant_Memory_Controller constMem(
													.addra(constantMemAddr),
													.dina(32'd0),
													.wea(1'd0),
													.clock(clk),
													.douta(constantMemIn)
													);
		
	L_mult Lsp_prev_extract_L_mult(
	.a(L_mult_a),
	.b(L_mult_b),
	.overflow(),
	.product(L_mult_in));
	
	add Lsp_prev_extract_add(
	.a(add_a),
	.b(add_b),
	.overflow(),
	.sum(add_in));

	L_msu Lsp_prev_extract_L_msu(
	.a(L_msu_a),
	.b(L_msu_b),
	.c(L_msu_c),
	.overflow(),
	.out(L_msu_in));
	
	L_shl Lsp_prev_extract_L_shl(
	.clk(clk),
	.reset(reset),
	.ready(L_shl_ready),
	.overflow(),
	.var1(L_shl_a),
	.numShift(L_shl_b),
	.done(L_shl_done),
	.out(L_shl_in)
	);
	
	Lsp_prev_extract i_fsm(
		.start(start), 
		.clk(clk), 
		.done(done), 
		.reset(reset), 
		.lspele(lspele), 		
		.freq_prev(freq_prev), 
		.lsp(lsp), 
		.fgAddr(fgAddr),
		.fg_sum_invAddr(fg_sum_invAddr),
		.readAddr(readAddr), 
		.readIn(readIn), 
		.writeAddr(writeAddr), 
		.writeOut(writeOut), 
		.writeEn(writeEn),
		.constantMemAddr(constantMemAddr),
		.constantMemIn(constantMemIn),
		.L_msu_a(L_msu_a), 
		.L_msu_b(L_msu_b), 
		.L_msu_c(L_msu_c), 
		.L_msu_in(L_msu_in), 
		.L_mult_a(L_mult_a),
		.L_mult_b(L_mult_b), 
		.L_mult_in(L_mult_in), 
		.L_shl_a(L_shl_a), 
		.L_shl_b(L_shl_b), 
		.L_shl_in(L_shl_in), 
		.add_a(add_a), 
		.add_b(add_b), 
		.add_in(add_in), 
		.L_shl_ready(L_shl_ready), 
		.L_shl_done(L_shl_done)
		);
	
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
