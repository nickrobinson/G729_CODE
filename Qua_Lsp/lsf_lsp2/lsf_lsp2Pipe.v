`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    19:45:40 02/28/2011
// Module Name:    lsf_lspPipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is an module to instantiate all the math and memory needed for lsf_lsp2, 
//						 as well as the FSM
// 
// Dependencies: 	 L_mult.v, L_shr.v, add.v, lsf_lsp2FSM, mult.v,sub.v,shr.v Scratch_Memory_Controller.v,
//						 Constant_Memory_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lsf_lspPipe(start,clk,reset,lsfAddr,lspAddr,testReadAddr,testWriteAddr,testMemOut,testWriteEn,memMuxSel,
						 done,memIn);

//Inputs
input start,clk,reset;
input [11:0] lsfAddr,lspAddr;
input [11:0] testReadAddr,testWriteAddr;
input [31:0] testMemOut;
input testWriteEn;
input memMuxSel;

//Wires
wire [15:0] subIn;
wire [31:0] L_multIn;
wire [15:0] addIn;
wire [15:0] shrIn;
wire [31:0] L_shrIn;
wire [15:0] multIn;
wire [31:0] constantMemIn;
wire [15:0] subOutA,subOutB;
wire [15:0] L_multOutA,L_multOutB;
wire [15:0] addOutA,addOutB;
wire [31:0] L_shrVar1Out;
wire [15:0] L_shrNumShiftOut;
wire [15:0] multOutA,multOutB;
wire [15:0] shrVar1Out,shrVar2Out;
wire [11:0] memReadAddr,memWriteAddr;
wire [31:0] memOut;
wire memWriteEn;
wire [11:0] constantMemAddr;

//Outputs
output done;
output [31:0] memIn;

//Internal regs
reg [11:0] Mux0Out,Mux1Out;
reg [31:0] Mux2Out;
reg Mux3Out;

//Instantiated modules
lsf_lsp2FSM fsm(
					  .start(start),
					  .clk(clk),
					  .reset(reset),
					  .subIn(subIn),					  
					  .L_multIn(L_multIn),
					  .addIn(addIn),					  
					  .L_shrIn(L_shrIn),
					  .multIn(multIn),
					  .shrIn(shrIn),
					  .memIn(memIn),
					  .constantMemIn(constantMemIn),
					  .lspAddr(lspAddr),
					  .lsfAddr(lsfAddr),
					  .subOutA(subOutA),
					  .subOutB(subOutB),					  
					  .L_multOutA(L_multOutA),
					  .L_multOutB(L_multOutB),
					  .addOutA(addOutA),
					  .addOutB(addOutB),					  
					  .L_shrVar1Out(L_shrVar1Out),
					  .L_shrNumShiftOut(L_shrNumShiftOut),
					  .multOutA(multOutA),
					  .multOutB(multOutB),
					  .shrVar1Out(shrVar1Out),
					  .shrVar2Out(shrVar2Out),
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

L_mult lsfLSP2_L_mult(
							  .a(L_multOutA),
							  .b(L_multOutB),
							  .overflow(),
							  .product(L_multIn)							
							);
									
L_shr lsfLSP2_L_shr(
							 .var1(L_shrVar1Out),
							 .numShift(L_shrNumShiftOut),
							 .overflow(),
							 .out(L_shrIn)
							 );
							 
add lsfLSP2_add(
						.a(addOutA),
						.b(addOutB),
						.overflow(),
						.sum(addIn)
						);
						
mult lsfLSP2_mult(
							.a(multOutA),
							.b(multOutB),
							.multRsel(1'd0),
							.overflow(),
							.product(multIn)
						);
					
shr lsfLSP2_shr
					(
					  .var1(shrVar1Out),
					  .var2(shrVar2Out),
					  .overflow(),
					  .result(shrIn)
					);
					
sub lsfLSP2_sub(
						.a(subOutA),
						.b(subOutB),
						.overflow(),
						.diff(subIn)
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

