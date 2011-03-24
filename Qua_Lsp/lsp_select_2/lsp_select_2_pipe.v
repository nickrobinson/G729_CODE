`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Nick Robinson
// 
// Create Date:    13:08:31 2/8/2011 
// Module Name:    LSP Select 2
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 12.3
// Description: 	 
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lsp_select_2_pipe(clk, reset, start, memIn, done, lagMuxSel, lagMux1Sel, lagMux2Sel, 
                          lagMux3Sel, testReadRequested, testWriteRequested, testWriteOut, 
								  testWriteEnable, lspcb1Addr);
	 
	 // Inputs
	input clk;
	input reset;
	input start;
	input [11:0] lspcb1Addr;

	// Outputs
	output done;
	output [31:0] memIn;
	
	wire [31:0] L_subOutA;
	wire [31:0] L_subOutB;
	wire [31:0] L_subIn;
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	wire [31:0] L_addIn;
	wire [15:0] subOutA;
	wire [15:0] subOutB;
	wire [15:0] subIn;
	wire [15:0] multOutA;
	wire [15:0] multOutB;
	wire [15:0] multIn;
	wire [31:0] memOut;
	wire [31:0] L_macIn;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire memWriteEn;
	wire [11:0] memWriteAddr;
	wire [11:0] constMemAddr;
	wire [31:0] constMemIn;
	
	wire unusedOverflow;
	
	//Mux0 regs	
	input lagMuxSel;
	reg [11:0] lagMuxOut;
	input [11:0] testReadRequested;
	//Mux1 regs	
	input lagMux1Sel;
	reg [11:0] lagMux1Out;
	input [11:0] testWriteRequested;
	//Mux2 regs	
	input lagMux2Sel;
	reg [31:0] lagMux2Out;
	input [31:0] testWriteOut;
	//Mux3 regs	
	input lagMux3Sel;
	reg lagMux3Out;
	input testWriteEnable;

	// Instantiate the Unit Under Test (UUT)
	lsp_select_2 fsm(
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.memIn(memIn), 
		.memWriteEn(memWriteEn), 
		.memWriteAddr(memWriteAddr), 
		.memOut(memOut), 
		.done(done),
		.L_subOutA(L_subOutA), 
		.L_subOutB(L_subOutB), 
		.L_subIn(L_subIn),
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.L_addIn(L_addIn),
		.subOutA(subOutA), 
		.subOutB(subOutB), 
		.subIn(subIn),
		.multOutA(multOutA), 
		.multOutB(multOutB), 
		.multIn(multIn),
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC), 
		.L_macIn(L_macIn),
		.lspcb1Addr(lspcb1Addr),
		.constMemIn(constMemIn),
		.constMemAddr(constMemAddr)
	);
	
	Scratch_Memory_Controller lspSelect2Mem(
												 .addra(lagMux1Out),
												 .dina(lagMux2Out),
												 .wea(lagMux3Out),
												 .clk(clk),
												 .addrb(lagMuxOut),
												 .doutb(memIn)
												 );
												 
	Constant_Memory_Controller constantMem(
														.addra(constMemAddr),
														.dina(32'd0),
														.wea(1'd0),
														.clock(clk),
														.douta(constMemIn)
													  );
					
	L_sub lsp_sel_L_sub(
					.a(L_subOutA),
					.b(L_subOutB),
					.overflow(),
					.diff(L_subIn));
	
	L_add lsp_sel_add(
					.a(L_addOutA),
					.b(L_addOutB),
					.overflow(),
					.sum(L_addIn));
					
	sub lsp_sel_sub(
					.a(subOutA),
					.b(subOutB),
					.overflow(),
					.diff(subIn));
					
	mult lsp_sel_mult(
					.a(multOutA),
					.b(multOutB),
					.multRsel(),
					.overflow(),
					.product(multIn));
					
	L_mac lsp_sel_L_mac(
					.a(L_macOutA),
					.b(L_macOutB),
					.c(L_macOutC),
					.overflow(),
					.out(L_macIn));
			
					 
	//lag read address mux
	always @(*)
	begin
		case	(lagMuxSel)	
			'd0 :	lagMuxOut = memWriteAddr;
			'd1:	lagMuxOut = testReadRequested;
		endcase
	end
	
	//lag write address mux
	always @(*)
	begin
		case	(lagMux1Sel)	
			'd0 :	lagMux1Out = memWriteAddr;
			'd1:	lagMux1Out = testWriteRequested;
		endcase
	end
	
	//lag write output mux
	always @(*)
	begin
		case	(lagMux2Sel)	
			'd0 :	lagMux2Out = memOut;
			'd1:	lagMux2Out = testWriteOut;
		endcase
	end
	
		//lag write enable mux
	always @(*)
	begin
		case	(lagMux3Sel)	
			'd0 :	lagMux3Out = memWriteEn;
			'd1:	lagMux3Out = testWriteEnable;
		endcase
	end


endmodule
