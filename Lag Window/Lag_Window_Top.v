`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:10:28 02/04/2011 
// Design Name: 
// Module Name:    Lag_Window_Top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lag_Window_Top(clk,reset,start,lagMuxSel,testWriteEnable,testWriteOut,testWriteRequested,
							 testReadRequested,done,rPrimeIn);
   
	input clk;
	input reset;
	input start;
	input lagMuxSel;
	input testWriteEnable;
	input [31:0] testWriteOut;
	input [10:0] testWriteRequested;
	input [10:0] testReadRequested;
	
	//Outputs
	output done;
	output [31:0] rPrimeIn;
	
	wire [31:0] L_multIn;
	wire [15:0] multIn;
	wire [31:0] L_macIn;
	wire [31:0] L_msuIn;
	wire [15:0] addIn;
	wire [31:0] L_shrIn;
	wire rPrimeWrite;
	wire [10:0] rPrimeRequested;
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire [15:0] multOutA;
	wire [15:0] multOutB;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire [15:0] L_msuOutA;
	wire [15:0] L_msuOutB;
	wire [31:0] L_msuOutC;
	wire [31:0] rPrimeOut;
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [15:0] L_shrOutNumShift;
	wire [31:0] L_shrOutVar1;


	// Instantiate the Unit Under Test (UUT)
	lag_window lagy(
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.rPrimeIn(rPrimeIn), 
		.L_multIn(L_multIn), 
		.multIn(multIn), 
		.L_macIn(L_macIn),
		.L_msuIn(L_msuIn), 
		.addIn(addIn),
		.L_shrIn(L_shrIn),
		.rPrimeWrite(rPrimeWrite), 
		.rPrimeRequested(rPrimeRequested), 
		.L_multOutA(L_multOutA), 
		.L_multOutB(L_multOutB), 
		.multOutA(multOutA), 
		.multOutB(multOutB), 
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC),
		.L_msuOutA(L_msuOutA), 
		.L_msuOutB(L_msuOutB), 
		.L_msuOutC(L_msuOutC), 		
		.rPrimeOut(rPrimeOut), 
		.addOutA(addOutA),
		.addOutB(addOutB),
		.L_shrOutVar1(L_shrOutVar1),
		.L_shrOutNumShift(L_shrOutNumShift),
		.done(done)
	);	
	
	Lag_Window_Pipe pipey(.clk(clk),
						 .L_multOutA(L_multOutA),
						 .L_multOutB(L_multOutB),
						 .multOutA(multOutA),
						 .multOutB(multOutB),
						 .L_macOutA(L_macOutA),
						 .L_macOutB(L_macOutB),
						 .L_macOutC(L_macOutC),
						 .L_msuOutA(L_msuOutA),
						 .L_msuOutB(L_msuOutB),
						 .L_msuOutC(L_msuOutC),
						 .addOutA(addOutA),
						 .addOutB(addOutB),
						 .L_shrOutNumShift(L_shrOutNumShift),
						 .L_shrOutVar1(L_shrOutVar1),
						 .rPrimeWrite(rPrimeWrite),
						 .rPrimeRequested(rPrimeRequested),
						 .rPrimeOut(rPrimeOut),
						 .lagMuxSel(lagMuxSel),
						 .L_multIn(L_multIn),
						 .multIn(multIn),
						 .L_macIn(L_macIn),
						 .L_msuIn(L_msuIn),
						 .addIn(addIn),
						 .L_shrIn(L_shrIn),
						 .rPrimeIn(rPrimeIn),
						 .testWriteEnable(testWriteEnable),
						 .testWriteOut(testWriteOut),
						 .testWriteRequested(testWriteRequested),
						 .testReadRequested(testReadRequested)
						);

endmodule
