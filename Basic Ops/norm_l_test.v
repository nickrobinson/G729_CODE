`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:11:06 09/27/2010
// Design Name:   norm_l_test
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Fall 2010/Senior Design/G729 Verilog Code/Autocorrelation and Windowing/autocorr/test1.v
// Project Name:  autocorr
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: norm_l
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module norm_l_test;

	// Inputs
	reg [31:0] var1;
	reg clk;
	reg ready;
	reg reset;

	// Outputs
	wire [15:0] norm;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	norm_l uut (
		.var1(var1), 
		.norm(norm), 
		.clk(clk), 
		.ready(ready), 
		.reset(reset), 
		.done(done)
	);

	initial begin
		// Initialize Inputs
		var1 = 0;
		clk = 0;
		ready = 0;
		reset = 0;
		
		#100;
      reset = 1; 
      #50 reset = 0; 
      
		#50;		
		ready = 1;
		var1 = 32'hd16a497b7;			
		#50;
		ready = 0;
		/*
		#50;		
		ready = 1;
		var1 = 32'h16a497b7;			
		#50;
		ready = 0;
		
		#50;		
		ready = 1;
		var1 = 32'h1785368b;			
		#50;
		ready = 0;
		
		#50;		
		ready = 1;
		var1 = 32'h17850dd3;			
		#50;
		ready = 0;
		
		#50;		
		ready = 1;
		var1 = 32'h1784df6b;			
		#50;
		ready = 0;
			
		*/
		// Add stimulus here

	end
   initial forever #10 clk = ~clk;   
endmodule

