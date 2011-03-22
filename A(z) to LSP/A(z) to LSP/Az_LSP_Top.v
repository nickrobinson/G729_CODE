`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    17:19:35 02/09/2011 
// Module Name:    Az_LSP_Top 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Top level to instantiate the Az_LSP FSM and Pipe
// Dependencies: 	 Az_LSP_Pipe.v, Az_toLSP_FSM.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Az_LSP_Top(clk,reset,start,lspMuxSel,testReadRequested,testWriteRequested,testLspOut,testLspWrite,
						done,lspIn);

//Inputs
input clk,reset,start;
input lspMuxSel;
input [11:0] testReadRequested;
input [11:0] testWriteRequested;
input [31:0] testLspOut;
input testLspWrite;

//Outputs
output done;
output [31:0] lspIn;

//Wires
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [15:0] subOutA;
	wire [15:0] subOutB;
	wire [15:0] shrOutVar1;
	wire [15:0] shrOutVar2;
	wire [31:0] L_shrOutVar1;
	wire [15:0] L_shrOutNumShift;
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	wire [31:0] L_subOutA;
	wire [31:0] L_subOutB;
	wire [15:0] multOutA;
	wire [15:0] multOutB;
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire L_multOverflow;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire L_macOverflow;
	wire [15:0] L_msuOutA;
	wire [15:0] L_msuOutB;
	wire [31:0] L_msuOutC;
	wire L_msuOverflow;
	wire [31:0] L_shlVar1Out;
	wire [15:0] L_shlNumShiftOut;
	wire L_shlReady;
	wire [15:0] norm_sOut;
	wire norm_sReady;
	wire [11:0] lspWriteRequested;
	wire [11:0] lspReadRequested;
	wire [31:0] lspOut;
	wire lspWrite;
	wire divErr;   
	wire [15:0] addIn;
	wire [15:0] subIn;
	wire [15:0] shrIn;
	wire [31:0] L_shrIn;
	wire [31:0] L_addIn;
	wire [31:0] L_subIn;
	wire [15:0] multIn;
	wire [31:0] L_multIn;
	wire [31:0] L_macIn;
	wire [31:0] L_msuIn;
	wire [31:0] L_shlIn;
	wire L_shlDone;
	wire [15:0] norm_sIn;
	wire norm_sDone;
	
//Instantiated Modules
Az_toLSP_FSM uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.addIn(addIn), 
		.subIn(subIn),
		.shrIn(shrIn),
		.L_shrIn(L_shrIn),
		.L_addIn(L_addIn),
		.L_subIn(L_subIn), 
		.multIn(multIn), 
		.L_multIn(L_multIn), 
		.L_macIn(L_macIn), 
		.L_msuIn(L_msuIn), 
		.L_shlIn(L_shlIn), 
		.L_shlDone(L_shlDone), 
		.norm_sIn(norm_sIn), 
		.norm_sDone(norm_sDone), 
		.lspIn(lspIn), 
		.addOutA(addOutA), 
		.addOutB(addOutB), 
		.subOutA(subOutA),
		.subOutB(subOutB),
		.shrOutVar1(shrOutVar1),
		.shrOutVar2(shrOutVar2),
		.L_shrOutVar1(L_shrOutVar1),
		.L_shrOutNumShift(L_shrOutNumShift),
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.L_subOutA(L_subOutA), 
		.L_subOutB(L_subOutB), 
		.multOutA(multOutA), 
		.multOutB(multOutB), 
		.L_multOutA(L_multOutA), 
		.L_multOutB(L_multOutB), 
		.L_multOverflow(L_multOverflow), 
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC), 
		.L_macOverflow(L_macOverflow), 
		.L_msuOutA(L_msuOutA), 
		.L_msuOutB(L_msuOutB), 
		.L_msuOutC(L_msuOutC), 
		.L_msuOverflow(L_msuOverflow), 
		.L_shlVar1Out(L_shlVar1Out), 
		.L_shlNumShiftOut(L_shlNumShiftOut), 
		.L_shlReady(L_shlReady), 
		.norm_sOut(norm_sOut), 
		.norm_sReady(norm_sReady), 
		.lspWriteRequested(lspWriteRequested), 
		.lspReadRequested(lspReadRequested), 
		.lspOut(lspOut), 
		.lspWrite(lspWrite), 
		.divErr(divErr),
		.done(done)
	);
Az_LSP_Pipe pipey(
						.clk(clk), 
						.reset(reset), 
						.lspMuxSel(lspMuxSel),
						.testWriteRequested(testWriteRequested),
						.testReadRequested(testReadRequested),
						.testLspOut(testLspOut),
						.testLspWrite(testLspWrite),
						.addIn(addIn), 
						.subIn(subIn),
						.shrIn(shrIn),
						.L_shrIn(L_shrIn),
						.L_addIn(L_addIn),
						.L_subIn(L_subIn), 
						.multIn(multIn), 
						.L_multIn(L_multIn), 
						.L_macIn(L_macIn), 
						.L_msuIn(L_msuIn), 
						.L_shlIn(L_shlIn), 
						.L_shlDone(L_shlDone), 
						.norm_sIn(norm_sIn), 
						.norm_sDone(norm_sDone), 
						.lspIn(lspIn), 
						.addOutA(addOutA), 
						.addOutB(addOutB), 
						.subOutA(subOutA),
						.subOutB(subOutB),
						.shrOutVar1(shrOutVar1),
						.shrOutVar2(shrOutVar2),
						.L_shrOutVar1(L_shrOutVar1),
						.L_shrOutNumShift(L_shrOutNumShift),
						.L_addOutA(L_addOutA), 
						.L_addOutB(L_addOutB), 
						.L_subOutA(L_subOutA), 
						.L_subOutB(L_subOutB), 
						.multOutA(multOutA), 
						.multOutB(multOutB), 
						.L_multOutA(L_multOutA), 
						.L_multOutB(L_multOutB), 
						.L_multOverflow(L_multOverflow), 
						.L_macOutA(L_macOutA), 
						.L_macOutB(L_macOutB), 
						.L_macOutC(L_macOutC), 
						.L_macOverflow(L_macOverflow), 
						.L_msuOutA(L_msuOutA), 
						.L_msuOutB(L_msuOutB), 
						.L_msuOutC(L_msuOutC), 
						.L_msuOverflow(L_msuOverflow), 
						.L_shlVar1Out(L_shlVar1Out), 
						.L_shlNumShiftOut(L_shlNumShiftOut), 
						.L_shlReady(L_shlReady), 
						.norm_sOut(norm_sOut), 
						.norm_sReady(norm_sReady), 
						.lspWriteRequested(lspWriteRequested), 
						.lspReadRequested(lspReadRequested), 
						.lspOut(lspOut), 
						.lspWrite(lspWrite)
					);
endmodule
