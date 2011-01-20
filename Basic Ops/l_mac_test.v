`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   08:45:01 09/30/2010
// Design Name:   L_mac
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Fall 2010/Senior Design I/G729 Verilog Code/Autocorrelation and Windowing/autocorr/l_mac_test.v
// Project Name:  autocorr
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: L_mac
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module l_mac_test_v;

	// Inputs
	reg [15:0] a;
	reg [15:0] b;
	reg [31:0] c;

	// Outputs
	wire overflow;
	wire [31:0] out;

	// Instantiate the Unit Under Test (UUT)
	L_mac uut (
		.a(a), 
		.b(b), 
		.c(c), 
		.overflow(overflow), 
		.out(out)
	);

	initial begin
		#100
		// Initialize Inputs
		a = 16'h1343;
		b = 16'h1343;
		c = 32'h1;
		#100
		// Initialize Inputs
		a = 16'he2d2;
		b = 16'he2d2;
		c = 32'h2e60713;
		#100
		// Initialize Inputs
		a = 16'h1441;
		b = 16'h1441;
		c = 32'h98cef9b;
      #100
		// Initialize Inputs
		a = 16'hea7d;
		b = 16'hea7d;
		c = 32'h7f7ea5c2;
        
		// Add stimulus here

	end
      
endmodule

