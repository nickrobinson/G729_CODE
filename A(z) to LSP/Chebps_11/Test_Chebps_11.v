`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    13:49:56 10/20/2010
// Module Name:    Test_Chebps__11 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module Chebps11_FSM
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module Test_Chebps_11_v;

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [15:0] coeff1;
	reg [15:0] coeff2;
	reg [15:0] coeff3;
	reg [15:0] coeff4;
	reg [15:0] coeff5;
	reg [15:0] coeff6;
	reg [15:0] xIn;
	reg [15:0] polyOrder;
	wire [31:0] L_multIn;
	wire [31:0] L_macIn;
	wire [31:0] L_msuIn;
	wire [31:0] L_shlIn;
	wire L_shlDone;
	wire [15:0] multIn;

	// Outputs
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire [15:0] L_msuOutA;
	wire [15:0] L_msuOutB;
	wire [31:0] L_msuOutC;
	wire [31:0] L_shlVar1Out;
	wire [15:0] L_shlNumShiftOut;
	wire L_shlReady;
	wire [15:0] multOutA,multOutB;
	wire done;
	wire [15:0] cheb;
	
	wire unusedOverflow0,unusedOverflow1, unusedOverflow2, unusedOverflow3;

	// Instantiate the Unit Under Test (UUT)
	Chebps11_FSM uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.coeff1(coeff1), 
		.coeff2(coeff2), 
		.coeff3(coeff3), 
		.coeff4(coeff4), 
		.coeff5(coeff5), 
		.coeff6(coeff6), 
		.xIn(xIn), 
		.polyOrder(polyOrder),
		.L_multIn(L_multIn),
		.L_macIn(L_macIn), 
		.L_msuIn(L_msuIn), 
		.L_shlIn(L_shlIn), 
		.L_shlDone(L_shlDone),
		.multIn(multIn), 
		.L_multOutA(L_multOutA), 
		.L_multOutB(L_multOutB), 
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC), 
		.L_msuOutA(L_msuOutA), 
		.L_msuOutB(L_msuOutB), 
		.L_msuOutC(L_msuOutC), 
		.L_shlVar1Out(L_shlVar1Out), 
		.L_shlNumShiftOut(L_shlNumShiftOut), 
		.L_shlReady(L_shlReady),
		.multOutA(multOutA), 
		.multOutB(multOutB), 
		.done(done), 
		.cheb(cheb)
	);
	
	L_mult L_mult1(
						.a(L_multOutA),
						.b(L_multOutB),
						.overflow(unusedOverflow0),
						.product(L_multIn)
						);
	
	L_mac L_mac1(
					 .a(L_macOutA),
					 .b(L_macOutB),
					 .c(L_macOutC),
					 .overflow(unusedOverflow1),
					 .out(L_macIn)
					);
	mult mult1(
				  .a(multOutA),
				  .b(multOutB),
				  .overflow(unusedOverflow2),
				  .product(multIn)
				  );
	L_msu L_msu1(
					 .a(L_msuOutA),
					 .b(L_msuOutB),
					 .c(L_msuOutC),
					 .overflow(unusedOverflow3),
					 .out(L_msuIn)
					 );
	L_shl L_shl1(
					 .clk(clk),
					 .reset(reset),
					 .ready(L_shlReady),
					 .overflow(unusedOverflow4),
					 .var1(L_shlVar1Out),
					 .numShift(L_shlNumShiftOut),
					 .done(L_shlDone),
					 .out(L_shlIn)
					 );
	

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		coeff1 = 0;
		coeff2 = 0;
		coeff3 = 0;
		coeff4 = 0;
		coeff5 = 0;
		coeff6 = 0;
		xIn = 0;
		polyOrder = 0;
		
		//reset
		#50;
		reset = 1;
		#50;
		reset = 0;
		#50;
		
		//set initial test coefficients
		xIn = 16'h7fd3;
		polyOrder = 16'h5;
		coeff1 = 16'h800;
		coeff2 = 16'h375;
		coeff3 = 16'h5ba;
		coeff4 = 16'hfb3a;
		coeff5 = 16'h565;
		coeff6 = 16'hfba9;
		start = 1;
		#50;
		start = 0;
		// Wait 100 ns for global reset to finish
		wait(done);
		/*reset = 1;
		#50;
		reset = 0;
		#50;*/
		xIn = 16'h7f4c;
		polyOrder = 16'h5;
		coeff1 = 16'h800;
		coeff2 = 16'h375;
		coeff3 = 16'h5ba;
		coeff4 = 16'hfb3a;
		coeff5 = 16'h565;
		coeff6 = 16'hfba9;
		start = 1;
		#50;
		start = 0;
        
		// Add stimulus here

	end
    initial forever #10 clk = ~clk;
  
endmodule

