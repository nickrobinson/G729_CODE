`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:16:44 09/20/2011 
// Design Name: 
// Module Name:    CheckParityPitch_Test 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Parity_pitch_test;

	reg start;
	reg clk;
	reg reset;
	reg [15:0] pitch_index;
	reg [15:0] parity;

	//Outputs
	wire done;
	wire [31:0] readIn;
	wire [15:0] sum;
	integer i, j, k;


	//I/O regs
	reg [15:0] pitch_indexc [0:40000];
	reg [15:0] parityc [0:40000];
	reg [15:0] sumc [0:40000];


	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("Check_Parity_pitch_index.out", pitch_indexc);
			$readmemh("Check_Parity_parity.out", parityc);
			$readmemh("Check_Parity_sum.out", sumc);
		end

	CheckParityPitch_Pipe i_pipe(
		.start(start),
		.clk(clk), 
		.reset(reset), 
		.done(done),
		.pitch_index(pitch_index), 
		.parity(parity),
		.sum(sum));


		initial begin
		// Initialize Inputs
		start = 0;
		clk = 0;
		reset = 0;

		#50
		reset = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 0;

		for(j=0;j<124;j=j+1)
		begin
			//TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 


			@(posedge clk);
			@(posedge clk);
			@(posedge clk);		
			pitch_index = pitch_indexc[j];
			parity = parityc[j];
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);		

			@(posedge clk);
			@(posedge clk);		
			start = 1;
			@(posedge clk);
			@(posedge clk);	
			start = 0;
			@(posedge clk);
			@(posedge clk);	
			// Add stimulus here	
			wait(done);


		//begin test
			//testReadRequested = cor_max;
			@(posedge clk);
			@(posedge clk);
			if (sum != sumc[j])
				$display($time, " ERROR: sumc[%d] = %x, expected = %x", j, sum, sumc[j]);
			else if (sum == sumc[j])
				$display($time, " CORRECT:  sumc[%d] = %x", j, sum);
			@(posedge clk);

		end//j for loop

	end
      initial forever #10 clk = ~clk;	   


endmodule
