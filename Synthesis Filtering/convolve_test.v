`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:23:48 01/23/2011
// Design Name:   convolve
// Module Name:   C:/Users/Nick/Documents/Spring2010/G.729 Verilog Code/Convolve/convolve_test.v
// Project Name:  Convolve
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: convolve
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module convolve_test;

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [31:0] rPrimeIn;
	wire [31:0] L_macIn;

	// Outputs
	wire rPrimeWrite;
	wire [10:0] rPrimeRequested;
	wire [31:0] rPrimeOut;
	wire done;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;

	// Instantiate the Unit Under Test (UUT)
	convolve uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.rPrimeIn(rPrimeIn), 
		.rPrimeWrite(rPrimeWrite), 
		.rPrimeRequested(rPrimeRequested), 
		.rPrimeOut(rPrimeOut), 
		.done(done),
		.L_macIn(L_macIn),
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC)
	);
	
	//Instanitiate the Multiply and Add block
	L_mac lag_L_mac(
					.a(L_macOutA),
					.b(L_macOutB),
					.c(L_macOutC),
					.overflow(),
					.out(L_macIn));

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		rPrimeIn = 0;

		// Wait 100 ns for global reset to finish
		#100;
		start = 1;
		#100 
		start = 0;
        
		// Add stimulus here

	end
	
initial forever #10 clk = ~clk; 
endmodule

