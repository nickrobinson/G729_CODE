`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer:  Zach Thornton
// 
// Create Date:    13:42:37 11/13/2010
// Module Name:    L_mult_test
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: L_mult
// Dependencies: 	none 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module L_mult_test_v;

	// Inputs
	reg [15:0] a;
	reg [15:0] b;

	// Outputs
	wire overflow;
	wire [31:0] product;
	wire [31:0] product1,product2;
	assign product1 = (32'd50*32'd50)*32'd2;
	assign product2 = (32'h8000*32'h8000)*32'd2;
	// Instantiate the Unit Under Test (UUT)
	L_mult uut (
		.a(a), 
		.b(b), 
		.overflow(overflow), 
		.product(product)
	);

	initial begin
		// Initialize Inputs
		a = 0;
		b = 0;

		// Wait 100 ns for global reset to finish
		//test1
		#100;
		
		a = 32'd50;
      b = 32'd50;
		
		#25;
		
		if(overflow)
					$display($time, " ERROR: Overflow");
		else if (product!= product1)
					$display($time, " ERROR: product = %x, expected = %x", product, product1);
		else
					$display($time, " CORRECT:  product = %x", product);
					
		//test2
		#100;		
		a = 32'h4292;
		b = 32'h3017;		
		#25;		
		if(overflow)
					$display($time, " ERROR: Overflow");
		else if (product!= 32'h1902b63c)
					$display($time, " ERROR: product = %x, expected = %x", product, 32'h1902b63c);		
		else
					$display($time, " CORRECT:  product = %x", product);
		//test3
		#100;		
		a = 32'ha242;
		b = 32'h0400;		
		#25;		
		if(overflow)
					$display($time, " ERROR: Overflow");		
		else if (product!= 32'hfd121000)
					$display($time, " ERROR: product = %x, expected = %x", product, 32'hfd121000);		
		else
					$display($time, " CORRECT:  product = %x", product);						
					
		// Add stimulus here

	end
      
endmodule

