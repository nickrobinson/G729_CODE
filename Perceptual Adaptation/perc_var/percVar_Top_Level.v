`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Parker Jacobs
// 
// Create Date:    13:08:31 01/11/2011 
// Module Name:    percVar_Top_Level 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 12.4
// Description: 	This is the top level of percVar.
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module percVar_Top_Level(clk,reset,start,percVarMuxSel,testMemWrite,testMemOut,
								 testWriteAddr,testReadAddr,memIn,done);

	//Inputs
	input clk;
	input reset;
	input start;
	input percVarMuxSel;
	input testMemWrite;
	input [31:0] testMemOut;
	input [10:0] testWriteAddr;
	input [10:0] testReadAddr;
	
	//Outputs
	output done;
	output [31:0] memIn;

	wire [15:0] shlVar1Out;
	wire [15:0] shlVar2Out;
	wire [15:0] shrVar1Out;
	wire [15:0] shrVar2Out;
	wire [15:0] subOutA;
	wire [15:0] subOutB;
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire [31:0] L_subOutA;
	wire [31:0] L_subOutB;
	wire [31:0] L_shrOutVar1;
	wire [15:0] L_shrOutNumShift;
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [15:0] multOutA;
	wire [15:0] multOutB;
	wire [10:0] memReadAddr;
	wire [10:0] memWriteAddr;
	wire memWrite;
	wire [31:0] memOut;
	wire done;

	//intermediary wires
	wire [15:0] shlIn;
	wire [15:0] shrIn;
	wire [15:0] subIn;
	wire [31:0] L_multIn;
	wire [31:0] L_subIn;
	wire [31:0] L_shrIn;
	wire [31:0] L_addIn;
	wire [15:0] addIn;
	wire [15:0] multIn;
	wire [31:0] memIn;

percVarFSM ipercVarFSM(
.clk(clk),
.reset(reset),
.start(start),
.shlIn(sh1In),
.shrIn(shrIn),
.subIn(subIn),
.L_multIn(L_multIn),
.L_subIn(L_subIn),
.L_shrIn(L_shrIn),
.L_addIn(L_addIn),
.addIn(addIn),
.multIn(multIn),
.memIn(memIn),
.shlVar1Out(shlVar1Out),
.shlVar2Out(shlVar2Out),
.shrVar1Out(shrVar1Out),
.shrVar2Out(shrVar2Out),
.subOutA(subOutA),
.subOutB(subOutB),
.L_multOutA(L_multOutA),
.L_multOutB(L_multOutB),
.L_subOutA(L_subOutA),
.L_subOutB(L_subOutB),
.L_shrOutVar1(L_shrOutVar1),
.L_shrOutNumShift(L_shrOutNumShift),
.L_addOutA(L_addOutA),
.L_addOutB(L_addOutB),
.addOutA(addOutA),
.addOutB(addOutB),
.multOutA(multOutA),
.multOutB(multOutB),
.memReadAddr(memReadAddr),
.memWriteAddr(memWriteAddr),
.memWrite(memWrite),
.memOut(memOut),
.done(done));



percVar_Pipe iPipe(
	.clk(clk),
	.shlVar1Out(shlVar1Out),
	.shlVar2Out(shlVar2Out),
	.shrVar1Out(shrVar1Out),
	.shrVar2Out(shrVar2Out),
	.subOutA(subOutA),
	.subOutB(subOutB),
	.L_multOutA(L_multOutA),
	.L_multOutB(L_multOutB),
	.L_subOutA(L_subOutA),
	.L_subOutB(L_subOutB),
	.L_shrOutVar1(L_shrOutVar1),
	.L_shrOutNumShift(L_shrOutNumShift),
	.L_addOutA(L_addOutA),
	.L_addOutB(L_addOutB),
	.addOutA(addOutA),
	.addOutB(addOutB),
	.multOutA(multOutA),
	.multOutB(multOutB),
	.memReadAddr(memReadAddr),
	.memWriteAddr(memWriteAddr),
	.memWrite(memWrite),
	.memOut(memOut),
	.L_multIn(L_multIn),
	.multIn(multIn),
	.shlIn(shlIn),
	.shrIn(shrIn),
	.subIn(subIn),
	.L_subIn(L_subIn),
	.L_addIn(L_addIn),
	.memIn(memIn),
	.addIn(addIn),
	.L_shrIn(L_shrIn),	
	.percVarMuxSel(percVarMuxSel),
	.testMemWrite(testMemWrite),
	.testMemOut(testMemOut),
	.testWriteAddr(testWriteAddr),
	.testReadAddr(testReadAddr)
	);

endmodule
