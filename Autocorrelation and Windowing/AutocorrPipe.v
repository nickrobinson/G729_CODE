`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    21:11:12 02/09/2011 
// Module Name:    AutocorrPipe.v  
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the Math and memory modules of Autocorrelation
//
// Dependencies: 	 L_mac.v, norm_l.v, mult.v, L_shl.v, shr.v, add.v, sub.v, Scratch_Mem_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module AutocorrPipe(clk,reset,L_macOutA,L_macOutB,L_macOutC,norm_lVar1Out,multOutA,multOutB,multRselOut,
						  L_shlReady,L_shlVar1Out,L_shlNumShiftOut,L_shrVar1Out,L_shrNumShiftOut,shrVar1Out, 
						  shrVar2Out,addOutA,addOutB,subOutA,subOutB,norm_lReady,norm_lReset,writeEn,readRequested, 
						  writeRequested,memOut,autocorrMuxSel,testReadRequested,testWriteRequested,testMemOut,
						  testMemWrite,xRequested,xMemAddr,xMemOut,xMemEn,
						  L_shlDone,norm_lDone,L_shlIn,L_shrIn,shrIn,addIn,subIn,norm_lIn,multIn,L_macIn,memIn, 
						  xIn,overflow);
	 
//Inputs
input clk,reset; 
input [15:0] L_macOutA; 
input [15:0] L_macOutB; 
input [31:0] L_macOutC;
input [15:0] multOutA; 
input [15:0] multOutB; 
input multRselOut; 
input [31:0] L_shrVar1Out;
input [15:0]L_shrNumShiftOut; 
input [15:0] shrVar1Out; 
input [15:0] shrVar2Out; 
input [15:0] addOutA; 
input [15:0] addOutB; 
input [15:0] subOutA; 
input [15:0] subOutB;
input writeEn;
input [10:0] readRequested; 
input [10:0] writeRequested; 
input [31:0] memOut;
input autocorrMuxSel;
input [10:0] testReadRequested;
input [10:0] testWriteRequested;
input [31:0] testMemOut;
input testMemWrite;
input [7:0] xRequested;
input [7:0] xMemAddr;
input [31:0] xMemOut;
input xMemEn;

input [31:0] norm_lVar1Out;
input norm_lReady; 
input norm_lReset;

input L_shlReady; 
input [31:0] L_shlVar1Out; 
input [15:0] L_shlNumShiftOut; 
 	
//Outputs		
output L_shlDone; 
output norm_lDone; 
output [31:0] L_shlIn;
output [15:0] norm_lIn; 
output [31:0] L_shrIn; 
output [15:0] shrIn; 
output [15:0] addIn; 
output [15:0] subIn; 
output [15:0] multIn; 
output [31:0] L_macIn; 
output [31:0] memIn; 
output [15:0] xIn;
output overflow;
	
	//mux regs 
reg [10:0] autocorrMuxOut;
reg [10:0] autocorrMux1Out;
reg [31:0] autocorrMux2Out;
reg autocorrMux3Out;

//temp wire
wire [31:0] memTemp;
assign xIn = {16'd0,memTemp[15:0]};

Scratch_Memory_Controller testMem(
											 .addra(autocorrMux1Out),
											 .dina(autocorrMux2Out),
											 .wea(autocorrMux3Out),
											 .clk(clk),
											 .addrb(autocorrMuxOut),
											 .doutb(memIn)
											);
Scratch_Memory_Controller testMem2(
											 .addra({3'd0,xMemAddr[7:0]}),
											 .dina(xMemOut),
											 .wea(xMemEn),
											 .clk(clk),
											 .addrb({3'd0,xRequested[7:0]}),
											 .doutb(memTemp)
											);
											
	L_mac autocorr_L_mac(
								.a(L_macOutA),
								.b(L_macOutB),
								.c(L_macOutC),
								.overflow(overflow),
								.out(L_macIn)
								);
	norm_l auto_norm_l(
								.var1(norm_lVar1Out),
								.norm(norm_lIn),
								.clk(clk),
								.ready(norm_lReady),
								.reset(reset||norm_lReset),
								.done(norm_lDone)
								);
   mult auto_mult(
					 .a(multOutA),
					 .b(multOutB),
					 .multRsel(multRselOut),
					 .overflow(),
					 .product(multIn)
					 );
	 L_shl auto_L_shl(
						.clk(clk),
						.reset(reset),
						.ready(L_shlReady),
						.overflow(),
						.var1(L_shlVar1Out),
						.numShift(L_shlNumShiftOut),
						.done(L_shlDone),
						.out(L_shlIn)
						);
	L_shr auto_L_shr(
					.var1(L_shrVar1Out),
					.numShift(L_shrNumShiftOut),
					.overflow(),
					.out(L_shrIn)
					);	
	sub auto_sub(
				  .a(subOutA),
				  .b(subOutB),
				  .overflow(),
				  .diff(subIn)
				);
	shr auto_shr(
					  .var1(shrVar1Out),
					  .var2(shrVar2Out),
					  .overflow(),
					  .result(shrIn)
				);					
	add auto_add(
						.a(addOutA),
						.b(addOutB),
						.overflow(),
						.sum(addIn)
					);

//autocorr read address mux
	always @(*)
	begin
		case	(autocorrMuxSel)	
			'd0 :	autocorrMuxOut = readRequested;
			'd1:	autocorrMuxOut = testReadRequested;
		endcase
	end	
	
 	//autocorr write address mux
	always @(*)
	begin
		case	(autocorrMuxSel)	
			'd0 :	autocorrMux1Out = writeRequested;
			'd1:	autocorrMux1Out = testWriteRequested;
		endcase
	end
	
	//autocorr write input mux
	always @(*)
	begin
		case	(autocorrMuxSel)	
			'd0 :	autocorrMux2Out = memOut;
			'd1:	autocorrMux2Out = testMemOut;
		endcase
	end
	
	//autocorr write enable mux
	always @(*)
	begin
		case	(autocorrMuxSel)	
			'd0 :	autocorrMux3Out = writeEn;
			'd1:	autocorrMux3Out = testMemWrite;
		endcase
	end


endmodule
