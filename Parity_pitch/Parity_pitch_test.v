`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:32:38 04/12/2011 
// Design Name: 
// Module Name:    Parity_pitch_test 
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
	
	//Outputs
	wire done;
	wire [31:0] readIn;
	wire [15:0] sum;
	integer i, j, k;

	reg Mux0Sel;
	reg [11:0] testReadRequested;
	reg Mux1Sel;
	reg [11:0] testWriteRequested;
	reg Mux2Sel;
	reg [31:0] testWriteOut;
	reg Mux3Sel;
	reg testWrite;
	

	//I/O regs
	reg [15:0] pitch_indexc [0:40000];
	reg [15:0] sumc [0:40000];


	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("SPEECH_PARITY_PITCH_IN.out", pitch_indexc);
			$readmemh("SPEECH_PARITY_PITCH_OUT.out", sumc);
		end
	
	Parity_pitch_pipe i_pipe(
		.start(start),
		.clk(clk), 
		.reset(reset), 
		.done(done),
		.Mux0Sel(Mux0Sel), 
		.Mux1Sel(Mux1Sel), 
		.Mux2Sel(Mux2Sel), 
		.Mux3Sel(Mux3Sel), 		
		.testReadRequested(testReadRequested), 
		.testWriteRequested(testWriteRequested), 
		.testWriteOut(testWriteOut), 
		.testWrite(testWrite), 
		.readIn(readIn),
		.pitch_index(pitch_index), 
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
		
		for(j=0;j<128;j=j+1)
		begin
			//TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 
			Mux0Sel = 1;
			Mux1Sel = 0;
			Mux2Sel = 0;
			Mux3Sel = 0;
			testWrite = 0;
				

			@(posedge clk);
			@(posedge clk);
			@(posedge clk);		
			pitch_index = pitch_indexc[j];
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
			
			Mux1Sel = 1;
			Mux2Sel = 1;
			Mux3Sel = 1;	
			
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
			Mux0Sel = 0;
			

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
