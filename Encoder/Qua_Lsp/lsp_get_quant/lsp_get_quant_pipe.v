`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    10:22:30 02/21/2011 
// Module Name:    lsp_get_quant_pipe .v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for lsp_get_quant_pipe
// 
// Dependencies: 	 lsp_get_quantFSM.v, Scratch_Memory_Controller.v, L_sub.v, L_add.v, L_mult.v, L_macIn.v,
//						 sub.v,add.v,shr.v,Constant_Memory_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lsp_get_quant_pipe(clk,reset,start,code0,code1,code2,fgAddr,freq_prevAddr,fg_sumAddr,lspqAddr,
								  getQuantMuxSel,testReadAddr,testWriteAddr,testMemOut,testMemWriteEn,done,memIn);
	
	//Inputs
	input clk,reset,start;	
	input [15:0] code0,code1,code2;
	input [11:0] fgAddr;
	input [11:0] freq_prevAddr;
	input [11:0] fg_sumAddr;
	input [11:0] lspqAddr;	
	input getQuantMuxSel;
	input [11:0] testReadAddr;	
	input [11:0] testWriteAddr;
	input [31:0] testMemOut;	
	input testMemWriteEn;
	//Outputs
	output done;
	output [31:0] memIn;
	
	//Wires
	wire [31:0] L_addIn;
	wire [31:0] L_subIn;
	wire [31:0] L_multIn;
	wire [31:0] L_macIn;
	wire [15:0] addIn;
	wire [15:0] subIn;
	wire [15:0] shrIn;
	wire [31:0] constantMemIn;
	wire [31:0] L_addOutA,L_addOutB;
	wire [31:0] L_subOutA,L_subOutB;
	wire [15:0] L_multOutA,L_multOutB;
	wire [15:0] L_macOutA,L_macOutB;
	wire [31:0] L_macOutC;
	wire [15:0] addOutA,addOutB;
	wire [15:0] subOutA,subOutB;
	wire [15:0] shrVar1Out;
	wire [15:0] shrVar2Out;		
	wire [31:0] memOut;
	wire [11:0] memReadAddr;
	wire [11:0] memWriteAddr;
	wire memWriteEn;
	wire [11:0] constantMemAddr;
	
	reg [11:0] getQuantMuxOut;
	reg [11:0] getQuantMux1Out;
	reg [31:0] getQuantMux2Out;
	reg getQuantMux3Out;
	
	//Memory muxes
	//getQuant read address mux
	always @(*)
	begin
		case	(getQuantMuxSel)	
			'd0 :	getQuantMuxOut = memReadAddr;
			'd1:	getQuantMuxOut = testReadAddr;
		endcase
	end
	
	//getQuant write address mux
	always @(*)
	begin
		case	(getQuantMuxSel)	
			'd0 :	getQuantMux1Out = memWriteAddr;
			'd1:	getQuantMux1Out = testWriteAddr;
		endcase
	end
	
	//getQuant write input mux
	always @(*)
	begin
		case	(getQuantMuxSel)	
			'd0 :	getQuantMux2Out = memOut;
			'd1:	getQuantMux2Out = testMemOut;
		endcase
	end
	
	//getQuant write enable mux
	always @(*)
	begin
		case	(getQuantMuxSel)	
			'd0 :	getQuantMux3Out = memWriteEn;
			'd1:	getQuantMux3Out = testMemWriteEn;
		endcase
	end
	
	//Instantiated modules	
	Scratch_Memory_Controller testMem(
												 .addra(getQuantMux1Out),
												 .dina(getQuantMux2Out),
												 .wea(getQuantMux3Out),
												 .clk(clk),
												 .addrb(getQuantMuxOut),
												 .doutb(memIn)
												 );
	Constant_Memory_Controller constantMem(
														.addra(constantMemAddr),
														.dina(32'd0),
														.wea(1'd0),
														.clock(clk),
														.douta(constantMemIn)
														);
	lsp_get_quantFSM fsm(
								.clk(clk),
								.reset(reset),
								.start(start),
								.L_addIn(L_addIn),
								.L_subIn(L_subIn),
								.L_multIn(L_multIn),
								.L_macIn(L_macIn),
								.addIn(addIn),
								.subIn(subIn),
								.shrIn(shrIn),
								.memIn(memIn),
								.code0(code0),
								.code1(code1),
								.code2(code2),
								.fgAddr(fgAddr),
								.freq_prevAddr(freq_prevAddr),
								.fg_sumAddr(fg_sumAddr),
								.lspqAddr(lspqAddr),
								.constantMemIn(constantMemIn),
								.L_addOutA(L_addOutA),
								.L_addOutB(L_addOutB),
								.L_subOutA(L_subOutA),
								.L_subOutB(L_subOutB),
								.L_multOutA(L_multOutA),
								.L_multOutB(L_multOutB),
								.L_macOutA(L_macOutA),
								.L_macOutB(L_macOutB),
								.L_macOutC(L_macOutC),
								.addOutA(addOutA),
								.addOutB(addOutB),
								.subOutA(subOutA),
								.subOutB(subOutB),
								.shrVar1Out(shrVar1Out),
								.shrVar2Out(shrVar2Out),
								.memOut(memOut),
								.memReadAddr(memReadAddr),
								.memWriteAddr(memWriteAddr),
								.memWriteEn(memWriteEn),
								.constantMemAddr(constantMemAddr),
								.done(done)
								);
	L_add getQuant_L_add(
								.a(L_addOutA),
								.b(L_addOutB),
								.overflow(),
								.sum(L_addIn)
								);
	L_sub getQuant_L_sub(
								.a(L_subOutA),
								.b(L_subOutB),
								.overflow(),
								.diff(L_subIn)
								);
	add getQuant_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
							);
	sub getQuant_sub(
						  .a(subOutA),
						  .b(subOutB),
						  .overflow(),
						  .diff(subIn)
						);
	shr getQuant_shr(
					  .var1(shrVar1Out),
					  .var2(shrVar2Out),
					  .overflow(),
					  .result(shrIn)
				  );
	L_mult getQuant_L_mult(
									.a(L_multOutA),
									.b(L_multOutB),
									.overflow(),
									.product(L_multIn)
									);
	L_mac getQuant_L_mac(
								.a(L_macOutA),
								.b(L_macOutB),
								.c(L_macOutC),
								.overflow(),
								.out(L_macIn)
								);
		
endmodule
