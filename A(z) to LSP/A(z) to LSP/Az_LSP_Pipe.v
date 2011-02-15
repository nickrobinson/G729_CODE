`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:03:21 02/09/2011 
// Module Name:    Az_LSP_Pipe 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Pipe to contain Az_toLSP's math and memory modules
// Dependencies: 	 L_mult,L_mac.v, L_msu.v,L_shl,L_sub,L_add,add,mult,norm_s,sub,shr,L_shr,Scratch_Mem_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Az_LSP_Pipe(clk,reset,lspMuxSel,testReadRequested,testWriteRequested,testLspOut,testLspWrite,
						 L_multOutA,L_multOutB,L_macOutA,L_macOutB,L_macOutC,L_msuOutA,L_msuOutB,L_msuOutC,
						 L_shlReady,L_shlVar1Out,L_shlNumShiftOut,L_subOutA,L_subOutB,L_addOutA,L_addOutB,
						 addOutA,addOutB,multOutA,multOutB,norm_sIn,norm_sReady,subOutA,subOutB,shrOutVar1,shrOutVar2,
						 L_shrOutVar1,L_shrOutNumShift,lspReadRequested,lspWriteRequested,lspOut,lspWrite,
						 L_multOverflow,L_multIn,L_macOverflow,L_macIn,L_msuOverflow,L_msuIn,L_shlDone,L_shlIn,
						 L_subIn,L_addIn,addIn,multIn,norm_sOut,norm_sDone,subIn,shrIn,L_shrIn,lspIn);
//Inputs
input clk,reset;
input lspMuxSel;
input [10:0] testReadRequested;
input [10:0] testWriteRequested;
input [31:0] testLspOut;
input testLspWrite;
input [15:0] L_multOutA,L_multOutB;
input [15:0] L_macOutA,L_macOutB;
input [31:0] L_macOutC;
input [15:0] L_msuOutA,L_msuOutB;
input [31:0] L_msuOutC;
input L_shlReady;
input [31:0] L_shlVar1Out;
input [15:0] L_shlNumShiftOut;
input [31:0] L_subOutA,L_subOutB;
input [31:0] L_addOutA,L_addOutB;
input [15:0] addOutA,addOutB;
input [15:0] multOutA,multOutB;
input norm_sReady;
input [15:0] subOutA,subOutB;
input [15:0] shrOutVar1,shrOutVar2;
input [31:0] L_shrOutVar1;
input [15:0] L_shrOutNumShift;
input [10:0] lspReadRequested;
input [10:0] lspWriteRequested;
input [31:0] lspOut;
input lspWrite;


output [15:0] norm_sIn;						//CHANGED FROM INPUT TO OUTPUT!!!
input [15:0] norm_sOut;     				//CHANGED FROM OUTPUT TO INPUT

//Outputs
output L_multOverflow;
output [31:0] L_multIn;
output L_macOverflow;
output [31:0] L_macIn;
output L_msuOverflow;
output [31:0] L_msuIn;
output L_shlDone;
output [31:0] L_shlIn;
output [31:0] L_subIn;
output [31:0] L_addIn;
output [15:0] addIn;
output [15:0] multIn;
output norm_sDone;
output [15:0] subIn;
output [15:0] shrIn;
output [31:0] L_shrIn;
output [31:0] lspIn;
					
//mux regs 
reg [10:0] lspMuxOut;
reg [10:0] lspMux1Out;
reg [31:0] lspMux2Out;
reg lspMux3Out;

//lsp read address mux
	always @(*)
	begin
		case	(lspMuxSel)	
			'd0 :	lspMuxOut = lspReadRequested;
			'd1:	lspMuxOut = testReadRequested;
		endcase
	end
	
	//lsp write address mux
	always @(*)
	begin
		case	(lspMuxSel)	
			'd0 :	lspMux1Out = lspWriteRequested;
			'd1:	lspMux1Out = testWriteRequested;
		endcase
	end
	
	//lsp write input mux
	always @(*)
	begin
		case	(lspMuxSel)	
			'd0 :	lspMux2Out = lspOut;
			'd1:	lspMux2Out = testLspOut;
		endcase
	end
	
	//lsp write enable mux
	always @(*)
	begin
		case	(lspMuxSel)	
			'd0 :	lspMux3Out = lspWrite;
			'd1:	lspMux3Out = testLspWrite;
		endcase
	end			

//Memory controller	
Scratch_Memory_Controller testMem(
												 .addra(lspMux1Out),
												 .dina(lspMux2Out),
												 .wea(lspMux3Out),
												 .clk(clk),
												 .addrb(lspMuxOut),
												 .doutb(lspIn)
												 );
												 
	L_mult Az_L_mult(
						 .a(L_multOutA),
						 .b(L_multOutB),
						 .overflow(L_multOverflow),
						 .product(L_multIn)
						 );
						 

	L_mac Az_L_mac(
						.a(L_macOutA),
						.b(L_macOutB),
						.c(L_macOutC),
						.overflow(L_macOverflow),
						.out(L_macIn)
						);

	L_msu Az_L_msu(
						.a(L_msuOutA),
						.b(L_msuOutB),
						.c(L_msuOutC),
						.overflow(L_msuOverflow),
						.out(L_msuIn)
						);
	 L_shl Az_L_shl(
						.clk(clk),
						.reset(reset),
						.ready(L_shlReady),
						.overflow(),
						.var1(L_shlVar1Out),
						.numShift(L_shlNumShiftOut),
						.done(L_shlDone),
						.out(L_shlIn)
						);
   L_sub Az_L_sub(
						.a(L_subOutA),
						.b(L_subOutB),
						.overflow(),
						.diff(L_subIn)
						);
	L_add Az_L_add(
					.a(L_addOutA),
					.b(L_addOutB),
					.overflow(),
					.sum(L_addIn)
					);	
	add Az_add(
					.a(addOutA),
					.b(addOutB),
					.overflow(),
					.sum(addIn)
					);
   mult Az_mult(
					 .a(multOutA),
					 .b(multOutB),
					 .multRsel(1'd0),
					 .overflow(),
					 .product(multIn)
					 );
norm_s Az_norm_s(
						.var1(norm_sOut),
						.norm(norm_sIn),
						.clk(clk),
						.ready(norm_sReady),
						.reset(reset),
						.done(norm_sDone)
					);
sub Az_sub(
			  .a(subOutA),
			  .b(subOutB),
			  .overflow(),
			  .diff(subIn)
			);
shr Az_shr(
				  .var1(shrOutVar1),
				  .var2(shrOutVar2),
				  .overflow(),
				  .result(shrIn)
			);
L_shr Az_L_shr(
					.var1(L_shrOutVar1),
					.numShift(L_shrOutNumShift),
					.overflow(),
					.out(L_shrIn)
					);			
endmodule
