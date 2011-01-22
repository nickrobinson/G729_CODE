`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:35:58 10/01/2010
// Design Name:   mult_r
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Fall 2010/Senior Design I/G729 Verilog Code/Autocorrelation and Windowing/autocorr/mult_r_test.v
// Project Name:  autocorr
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mult_r
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mult_test;

	// Inputs
	reg [15:0] a;
	reg [15:0] b;
	reg mclk;
	reg reset;
	
	// Outputs
	wire overflow;
	wire [15:0] product;	
  
	integer i;
	
	// Instantiate the Unit Under Test (UUT)
	mult uut (
		.a(a), 
		.b(b), 
		.overflow(overflow), 
		.product(product)
	);
	

	initial begin
		// Initialize Inputs
		a = 0;
		b = 0;
		mclk = 0;
		reset = 0;
		
		// Wait 100 ns for global reset to finish
		#100;		
		reset = 1;		
		#100		
		reset = 0;
		// Add stimulus here
		 a = 1;
		 b = 2;
		
	end

	
	
		
 initial forever #10 mclk = ~mclk;     
endmodule

