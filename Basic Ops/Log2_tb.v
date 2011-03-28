`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
//
// Create Date:   15:25:20 03/27/2011
// Module Name:   Log2_tb
// Project Name:  ITU G.729 Hardware Implementation
// Target Device: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions: Xilinx ISE 12.4
// Description:   This module tests the Log2 module
//
// Dependencies:  Log2_pipe.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Log2_tb;

	// Inputs
	reg clock;
	reg start;
	reg reset;
	reg [31:0] in;

	// Outputs
	wire done;
	wire [15:0] exponent;
	wire [15:0] fraction;

	// Instantiate the Unit Under Test (UUT)
	Log2_pipe uut (
		.clock(clock), 
		.start(start), 
		.reset(reset), 
		.done(done), 
		.in(in), 
		.exponent(exponent), 
		.fraction(fraction)
	);
	
	integer j;

	reg [32:0] log2_in [0:9999];
	reg [15:0] log2_exp_out [0:9999];
	reg [15:0] log2_frac_out [0:9999];
	
	

	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("log2_input.out", log2_in);
		$readmemh("log2_exp_out.out", log2_exp_out);
		$readmemh("log2_frac_out.out", log2_frac_out);
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
			
			in = log2_in[j];
			#50;		
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here	
			wait(done);
			
			//Check exponent outputs
			if (exponent != log2_exp_out[j])
				$display($time, " ERROR: exponent[%d] = %x, expected = %x", j, exponent, log2_exp_out[j]);
			else if (exponent == log2_exp_out[j])
				$display($time, " CORRECT:  exponent[%d] = %x", j, exponent);
				
			//Check fraction outputs
			if (fraction != log2_frac_out[j])
				$display($time, " ERROR: fraction[%d] = %x, expected = %x", j, fraction, log2_frac_out[j]);
			else if (fraction == log2_frac_out[j])
				$display($time, " CORRECT:  fraction[%d] = %x", j, fraction);
			
		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule

