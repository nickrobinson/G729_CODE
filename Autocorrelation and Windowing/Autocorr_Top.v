`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    21:57:35 02/09/2011 
// Module Name:    Autocorr_Top .v  
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A top level to instantiate the autocorrFSM and the AutocorrPipe 
//
// Dependencies: 	 autocorrFSM.v,AutocorrPipe.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Autocorr_Top(clk,reset,start,xMemAddr,xMemOut,xMemEn,autocorrMuxSel,testReadRequested,testWriteRequested,
						  testMemOut,testMemWrite,done,memIn);

//Inputs	 
input clk,reset,start; 
input [7:0] xMemAddr;
input [31:0] xMemOut;
input xMemEn;
input autocorrMuxSel;
input [11:0] testReadRequested;
input [11:0] testWriteRequested;
input [31:0] testMemOut;
input testMemWrite;

//Outputs
output done;
output [31:0] memIn; 

//Temp wires
wire [15:0] L_macOutA; 
wire [15:0] L_macOutB; 
wire [31:0] L_macOutC; 
wire [15:0] L_msuOutA; 
wire [15:0] L_msuOutB; 
wire [31:0] L_msuOutC;  
wire [15:0] multOutA; 
wire [15:0] multOutB; 
wire multRselOut;  
wire [31:0] L_shrVar1Out;
wire [15:0]L_shrNumShiftOut; 
wire [15:0] shrVar1Out; 
wire [15:0] shrVar2Out; 
wire [15:0] addOutA; 
wire [15:0] addOutB; 
wire [15:0] subOutA; 
wire [15:0] subOutB;
wire writeEn;
wire [11:0] readRequested; 
wire [11:0] writeRequested; 
wire [31:0] memOut;
wire [7:0] xRequested;
wire [31:0] L_shrIn; 
wire [15:0] shrIn; 
wire [15:0] addIn; 
wire [15:0] subIn;
wire [15:0] multIn; 
wire [31:0] L_macIn;
wire [31:0] L_msuIn;
wire [15:0] xIn;
wire overflow;

wire L_shlReady; 
wire [31:0] L_shlVar1Out; 
wire [15:0] L_shlNumShiftOut;	
wire [31:0] L_shlIn; 
wire L_shlDone; 

wire [31:0] norm_lVar1Out;
wire norm_lReady; 
wire norm_lReset;
wire [15:0] norm_lIn; 
wire norm_lDone;

	autocorrFSM fsm (
							.clk(clk), 
							.reset(reset), 
							.ready(start), 
							.xIn(xIn), 
							.memIn(memIn), 
							.L_shlDone(L_shlDone), 
							.norm_lDone(norm_lDone), 
							.L_shlIn(L_shlIn), 
							.L_shrIn(L_shrIn), 
							.shrIn(shrIn), 
							.addIn(addIn), 
							.subIn(subIn), 
							.overflow(overflow), 
							.norm_lIn(norm_lIn), 
							.multIn(multIn), 
							.L_macIn(L_macIn), 
							.L_macOutA(L_macOutA), 
							.L_macOutB(L_macOutB), 
							.L_macOutC(L_macOutC),
							.L_msuIn(L_msuIn),
							.L_msuOutA(L_msuOutA), 
							.L_msuOutB(L_msuOutB), 
							.L_msuOutC(L_msuOutC), 
							.norm_lVar1Out(norm_lVar1Out), 
							.multOutA(multOutA), 
							.multOutB(multOutB), 
							.multRselOut(multRselOut), 
							.L_shlReady(L_shlReady), 
							.L_shlVar1Out(L_shlVar1Out), 
							.L_shlNumShiftOut(L_shlNumShiftOut), 
							.L_shrVar1Out(L_shrVar1Out), 
							.L_shrNumShiftOut(L_shrNumShiftOut), 
							.shrVar1Out(shrVar1Out), 
							.shrVar2Out(shrVar2Out), 
							.addOutA(addOutA), 
							.addOutB(addOutB), 
							.subOutA(subOutA), 
							.subOutB(subOutB), 
							.norm_lReady(norm_lReady), 
							.norm_lReset(norm_lReset), 
							.writeEn(writeEn), 
							.xRequested(xRequested), 
							.readRequested(readRequested), 
							.writeRequested(writeRequested), 
							.memOut(memOut), 
							.done(done)
						);
						
		AutocorrPipe pipey(
								 .clk(clk),
								 .reset(reset),
								 .L_macOutA(L_macOutA),
								 .L_macOutB(L_macOutB),
								 .L_macOutC(L_macOutC),
								 .L_msuOutA(L_msuOutA),
								 .L_msuOutB(L_msuOutB),
								 .L_msuOutC(L_msuOutC),
								 .norm_lVar1Out(norm_lVar1Out),
								 .multOutA(multOutA),
								 .multOutB(multOutB),
								 .multRselOut(multRselOut),
								 .L_shlReady(L_shlReady),
								 .L_shlVar1Out(L_shlVar1Out),
								 .L_shlNumShiftOut(L_shlNumShiftOut),
								 .L_shrVar1Out(L_shrVar1Out),
								 .L_shrNumShiftOut(L_shrNumShiftOut),
								 .shrVar1Out(shrVar1Out), 
								 .shrVar2Out(shrVar2Out),
								 .addOutA(addOutA),
								 .addOutB(addOutB),
								 .subOutA(subOutA),
								 .subOutB(subOutB),
								 .norm_lReady(norm_lReady),
								 .norm_lReset(norm_lReset),
								 .writeEn(writeEn),
								 .readRequested(readRequested), 
								 .writeRequested(writeRequested),
								 .memOut(memOut),
								 .autocorrMuxSel(autocorrMuxSel),
								 .testReadRequested(testReadRequested),
								 .testWriteRequested(testWriteRequested),
								 .testMemOut(testMemOut),
								 .testMemWrite(testMemWrite),
								 .xRequested(xRequested),
								 .xMemAddr(xMemAddr),
								 .xMemOut(xMemOut),
								 .xMemEn(xMemEn),
								 .L_shlDone(L_shlDone),
								 .norm_lDone(norm_lDone),
								 .L_shlIn(L_shlIn),
								 .L_shrIn(L_shrIn),
								 .shrIn(shrIn),
								 .addIn(addIn),
								 .subIn(subIn),
								 .norm_lIn(norm_lIn),
								 .multIn(multIn),
								 .L_macIn(L_macIn),
								 .L_msuIn(L_msuIn),
								 .memIn(memIn), 
								 .xIn(xIn),
								 .overflow(overflow)
								 );
endmodule
