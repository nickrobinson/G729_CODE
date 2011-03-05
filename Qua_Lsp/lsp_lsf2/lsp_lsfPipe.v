`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    19:45:40 02/28/2011
// Module Name:    lsp_lsfPipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an module to instantiate all the math and memory needed for lsp_lsf2, 
//						 as well as the FSM
// 
// Dependencies: 	 L_mult.v, L_shr.v, add.v, lsp_lsf2FSM, mult.v,shl.v,sub.v, Scratch_Memory_Controller.v,
//						 Constant_Memory_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lsp_lsfPipe(start,clk,reset,lspAddr,lsfAddr,testReadAddr,testWriteAddr,testMemOut,testWriteEn,memMuxSel,
						 done,memIn);

//Inputs
input start,clk,reset;
input [10:0] lspAddr,lsfAddr;
input [10:0] testReadAddr,testWriteAddr;
input [31:0] testMemOut;
input testWriteEn;
input memMuxSel;

//Wires
wire [15:0] subIn;
wire [31:0] L_subIn;
wire [31:0] L_multIn;
wire [15:0] addIn;
wire [15:0] shlIn;
wire [31:0] L_shrIn;
wire [15:0] multIn;
wire [31:0] constantMemIn;
wire [15:0] subOutA,subOutB;
wire [31:0] L_subOutA,L_subOutB;
wire [15:0] L_multOutA,L_multOutB;
wire [15:0] addOutA,addOutB;
wire [15:0] shlOutA,shlOutB;
wire [31:0] L_shrVar1Out;
wire [15:0] L_shrNumShiftOut;
wire [15:0] multOutA,multOutB;
wire [15:0] shlVar1Out,shlVar2Out;
wire [10:0] memReadAddr,memWriteAddr;
wire [31:0] memOut;
wire memWriteEn;
wire [11:0] constantMemAddr;

//Outputs
output done;
output [31:0] memIn;

//Internal regs
reg [10:0] Mux0Out,Mux1Out;
reg [31:0] Mux2Out;
reg Mux3Out;

//Instantiated modules
lsp_lsf2FSM fsm(
					  .start(start),
					  .clk(clk),
					  .reset(reset),
					  .subIn(subIn),
					  .L_subIn(L_subIn),
					  .L_multIn(L_multIn),
					  .addIn(addIn),					  
					  .L_shrIn(L_shrIn),
					  .multIn(multIn),
					  .shlIn(shlIn),
					  .memIn(memIn),
					  .constantMemIn(constantMemIn),
					  .lspAddr(lspAddr),
					  .lsfAddr(lsfAddr),
					  .subOutA(subOutA),
					  .subOutB(subOutB),
					  .L_subOutA(L_subOutA),
					  .L_subOutB(L_subOutB),
					  .L_multOutA(L_multOutA),
					  .L_multOutB(L_multOutB),
					  .addOutA(addOutA),
					  .addOutB(addOutB),
					  .shlOutA(shlOutA),
					  .shlOutB(shlOutB),
					  .L_shrVar1Out(L_shrVar1Out),
					  .L_shrNumShiftOut(L_shrNumShiftOut),
					  .multOutA(multOutA),
					  .multOutB(multOutB),
					  .shlVar1Out(shlVar1Out),
					  .shlVar2Out(shlVar2Out),
					  .memReadAddr(memReadAddr),
					  .memWriteAddr(memWriteAddr),
					  .memOut(memOut),
					  .memWriteEn(memWriteEn),
					  .constantMemAddr(constantMemAddr),
					  .done(done)
					  );

Constant_Memory_Controller constantMem(
													.addra(constantMemAddr),
													.dina(32'd0),
													.wea(1'd0),
													.clock(clk),
													.douta(constantMemIn)
													);
													
Scratch_Memory_Controller scratchMem(
												 .addra(Mux1Out),
												 .dina(Mux2Out),
												 .wea(Mux3Out),
												 .clk(clk),
												 .addrb(Mux0Out),
												 .doutb(memIn)
												 );

L_mult lspLSF2_L_mult(
							  .a(L_multOutA),
							  .b(L_multOutB),
							  .overflow(),
							  .product(L_multIn)							
							);
									
L_shr lspLSF2_L_shr(
							 .var1(L_shrVar1Out),
							 .numShift(L_shrNumShiftOut),
							 .overflow(),
							 .out(L_shrIn)
							 );
							 
add lspLSF2_add(
						.a(addOutA),
						.b(addOutB),
						.overflow(),
						.sum(addIn)
						);
						
mult lspLSF2_mult(
							.a(multOutA),
							.b(multOutB),
							.multRsel(1'd0),
							.overflow(),
							.product(multIn)
						);
					
shl lspLSF2_shl
					(
					  .var1(shlVar1Out),
					  .var2(shlVar2Out),
					  .overflow(),
					  .result(shlIn)
					);
					
sub lspLSF2_sub(
						.a(subOutA),
						.b(subOutB),
						.overflow(),
						.diff(subIn)
					);
L_sub lspLSF2_L_sub(
							.a(L_subOutA),
							.b(L_subOutB),
							.overflow(),
							.diff(L_subIn)
						);
					
//Memory Muxes
always @(*)
		begin
			case	(memMuxSel)	
				'd0 :	Mux0Out = testReadAddr;
				'd1:	Mux0Out = memReadAddr;
			endcase
		end
		
		//write address mux
		always @(*)
		begin
			case	(memMuxSel)	
				'd0 :	Mux1Out = testWriteAddr;
				'd1:	Mux1Out = memWriteAddr;
			endcase
		end
		
		//write input mux
		always @(*)
		begin
			case	(memMuxSel)	
				'd0 :	Mux2Out = testMemOut;
				'd1:	Mux2Out = memOut;
			endcase
		end
		
		//write enable mux
		always @(*)
		begin
			case	(memMuxSel)	
				'd0 :	Mux3Out = testWriteEn;
				'd1:	Mux3Out = memWriteEn;
			endcase
		end
					  

endmodule
