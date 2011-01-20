`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:07:00 10/02/2010
// Design Name:   L_shl
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Fall 2010/Senior Design I/G729 Verilog Code/Autocorrelation and Windowing/autocorr/L_shl_test.v
// Project Name:  autocorr
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: L_shl
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module L_shl_test_v;

	// Inputs
	reg clk;
	reg reset;
	reg ready;
	reg [31:0] var1;
	reg [15:0] numShift;

	// Outputs
	wire overflow;
	wire done;
	wire [31:0] out;

	// Instantiate the Unit Under Test (UUT)
	L_shl uut (
		.clk(clk), 
		.reset(reset), 
		.ready(ready), 
		.overflow(overflow), 
		.var1(var1), 
		.numShift(numShift), 
		.done(done), 
		.out(out)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		ready = 0;
		var1 = 0;
		numShift = 0;

		// Wait 100 ns for global reset to finish
		#100;

      reset = 1; 
      #50 reset = 0; 
      // Add stimulus here
		
		#50;		
		ready = 1;
		var1 = 32'hf663597e;
		numShift = 15'h3;
		#50;
		ready = 0;
		
		#50;		
		ready = 1;
		var1 = 32'h194e3c;
		numShift = 15'h3;
		#50;
		ready = 0;
		
		#50;		
		ready = 1;
		var1 = 32'h94f2b22;
		numShift = 15'h3;
		#50;
		ready = 0;
		
		#50;		
		ready = 1;
		var1 = 32'hf2dc57f2;
		numShift = 15'h3;
		#50;
		ready = 0;
		
		#50;		
		ready = 1;
		var1 = 32'h944537a;
		numShift = 15'h3;
		#50;
		ready = 0;

	end
   initial forever #10 clk = ~clk; 
endmodule

