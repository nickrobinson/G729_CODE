`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:31:36 11/10/2010
// Design Name:   shr
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Fall 2010/Senior Design I/G729 Verilog Code/A(z) to LSP/AztoLSP/shr_test.v
// Project Name:  AztoLSP
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: shr
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module shl_test_v;

	// Inputs
	reg [15:0] var1;
	reg [15:0] var2;

	// Outputs
	wire [15:0] result;
	wire overflow;

	// Instantiate the Unit Under Test (UUT)
	shl uut (
		.var1(var1), 
		.var2(var2), 
		.overflow(overflow),
		.result(result)
	);

	initial begin
		// Initialize Inputs
		var1 = 0;
		var2 = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		var1 = 16'h1cc;
		var2 = 16'h6;
		#50;
		
      var1 = 16'hf;
		var2 = 16'h9; 
		#50;
		
		var1 = 16'hfc73;
		var2 = 16'h2; 
		#50;	
		// Add stimulus here

	end
      
endmodule

