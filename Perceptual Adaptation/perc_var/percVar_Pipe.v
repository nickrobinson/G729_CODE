`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Parker Jacobs
// 
// Create Date:    13:08:31 01/11/2011 
// Module Name:    percVar_Pipe 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 12.4
// Description: 	This is the datapath of the percVar function.
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module percVar_Pipe(clk,percVarMuxSel,testMemWrite,testMemOut,testWriteAddr,testReadAddr,
						  shlVar1Out,shlVar2Out,shrVar1Out,shrVar2Out,subOutA,subOutB,L_multOutA,
						  L_multOutB,L_subOutA,L_subOutB,L_shrOutVar1,L_shrOutNumShift,L_addOutA,
						  L_addOutB,addOutA,addOutB,multOutA,multOutB,memReadAddr,memWriteAddr,
						  memWrite,memOut,L_multIn,multIn,shlIn,shrIn,subIn,L_subIn,L_addIn,memIn,
						  addIn,L_shrIn);

	//Inputs
	input clk;
	input percVarMuxSel;
	input testMemWrite;
	input [31:0] testMemOut;
	input [11:0] testWriteAddr;
	input [11:0] testReadAddr;

	input [15:0] shlVar1Out;
	input [15:0] shlVar2Out;
	input [15:0] shrVar1Out;
	input [15:0] shrVar2Out;
	input [15:0] subOutA;
	input [15:0] subOutB;
	input [15:0] L_multOutA;
	input [15:0] L_multOutB;
	input [31:0] L_subOutA;
	input [31:0] L_subOutB;
	input [31:0] L_shrOutVar1;
	input [15:0] L_shrOutNumShift;
	input [31:0] L_addOutA;
	input [31:0] L_addOutB;
	input [15:0] addOutA;
	input [15:0] addOutB;
	input [15:0] multOutA;
	input [15:0] multOutB;
	input [11:0] memReadAddr;
	input [11:0] memWriteAddr;
	input memWrite;
	input [31:0] memOut;

	
	//Outputs
	output [31:0] L_multIn;	
	output [15:0] multIn;
	//intermediary wires
	output [15:0] shlIn;
	output [15:0] shrIn;
	output [15:0] subIn;
	output [31:0] L_subIn;
	output [31:0] L_addIn;
	output [15:0] addIn;
	output [31:0] L_shrIn;	
	output [31:0] memIn;
	
	//working regs		
	reg [11:0] percVarMuxOut;
	reg [11:0] percVarMux1Out;	
	reg [31:0] percVarMux2Out;
	reg percVarMux3Out;

Scratch_Memory_Controller testMem(
	.addra(percVarMux1Out),
	.dina(percVarMux2Out),
	.wea(percVarMux3Out),
	.clk(clk),
	.addrb(percVarMuxOut),
	.doutb(memIn)
);

L_mult percVar_L_mult(
	.a(L_multOutA),
	.b(L_multOutB),
	.overflow(),
	.product(L_multIn)
);
						 
L_shr percVar_L_shr(
	.var1(L_shrOutVar1),
	.numShift(L_shrOutNumShift),
	.overflow(),
	.out(L_shrIn)
);

L_sub percVar_L_sub(
	.a(L_subOutA),
	.b(L_subOutB),
	.overflow(),
	.diff(L_subIn)
);
	
L_add percVar_L_add (
	.a(L_addOutA),
	.b(L_addOutB),
	.overflow(),
	.sum(L_addIn)
);
	
add percVar_add(
	.a(addOutA),
	.b(addOutB),
	.overflow(),
	.sum(addIn)
);

mult percVar_mult(
	.a(multOutA),
	.b(multOutB),
	.multRsel(1'd0),
	.overflow(),
	.product(multIn)
 );

sub percVar_sub(
	.a(subOutA),
	.b(subOutB),
	.overflow(),
	.diff(subIn)
);	

shr percVar_shr(
	.var1(shrVar1Out),
	.var2(shrVar2Out),
	.overflow(),
	.result(shrIn)
);

shl percVar_shl(
	.var1(shlVar1Out),
	.var2(shlVar2Out),
	.overflow(),
	.result(shlIn)
);
						
//lsp read address mux
	always @(*)
	begin
		case	(percVarMuxSel)	
			'd0 :	percVarMuxOut = memReadAddr;
			'd1:	percVarMuxOut = testReadAddr;
		endcase
	end
	
	//lsp write address mux
	always @(*)
	begin
		case	(percVarMuxSel)	
			'd0 :	percVarMux1Out = memWriteAddr;
			'd1:	percVarMux1Out = testWriteAddr;
		endcase
	end
	
	//lsp write input mux
	always @(*)
	begin
		case	(percVarMuxSel)	
			'd0 :	percVarMux2Out = memOut;
			'd1:	percVarMux2Out = testMemOut;
		endcase
	end
	
	//lsp write enable mux
	always @(*)
	begin
		case	(percVarMuxSel)	
			'd0 :	percVarMux3Out = memWrite;
			'd1:	percVarMux3Out = testMemWrite;
		endcase
	end
	

endmodule
