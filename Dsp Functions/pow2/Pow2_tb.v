`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design 
// Engineer: Sean Owens
//
// Create Date:   17:28:27 03/28/2011
// Module Name:   Pow2_tb
// Project Name:  ITU G.729 Hardware Implementation
// Target Device: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions: Xilinx ISE 12.4
// Description: 	This module tests the Pow2 module.
//
// Dependencies:  Pow2_pipe.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Pow2_tb;

	// Inputs
	reg clock;
	reg reset;
	reg start;
	reg [15:0] exponent;
	reg [15:0] fraction;

	// Outputs
	wire done;
	wire [31:0] result;

	// Instantiate the Unit Under Test (UUT)
	Pow2_pipe uut (
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.done(done), 
		.exponent(exponent), 
		.fraction(fraction), 
		.result(result)
	);

	integer j;

	reg [32:0] pow2_frac_in [0:9999];
	reg [15:0] pow2_out [0:9999];
	
	

	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("pow2_frac_in.out", pow2_frac_in);
		$readmemh("pow2_out.out", pow2_out);
	end
	
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		start = 0;

		#50
		reset = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 0;
		
		for(j=0;j<1000;j=j+1)
		begin
			
			exponent = 'd14;
			fraction = pow2_frac_in[j];
			#50;		
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here	
			wait(done);
			
			//Check outputs
			if (result != pow2_out[j])
				$display($time, " ERROR: result[%d] = %x, expected = %x", j, result, pow2_out[j]);
			else if (result == pow2_out[j])
				$display($time, " CORRECT:  result[%d] = %x", j, result);
			
		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule

