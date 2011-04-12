`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:43:45 04/07/2011 
// Design Name: 
// Module Name:    Pitch_ol_test 
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
module Pitch_ol_test;
`include "paramList.v"
`include "constants_param_list.v"

	reg start;
	reg clk;
	reg reset;
	reg [11:0] signal, scaled_signal;
	reg [15:0] L_frame, pit_max, pit_min;
	
	//Outputs
	wire done;
	wire [31:0] readIn;	
	wire [15:0] p_max1;
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
	reg [15:0] signalc [0:60000];
	reg [15:0] scaled_signalc [0:40000];
	reg [15:0] L_framec [0:40000];
	reg [15:0] pit_maxc [0:4000];
	reg [15:0] pit_minc [0:40000];
	reg [15:0] p_max1c [0:4000];

	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("PITCH_OL_SIGNAL.out", scaled_signalc);
			$readmemh("PITCH_OL_L_FRAME.out", L_framec);
			$readmemh("PITCH_OL_PIT_MAX.out", pit_maxc);
			$readmemh("PITCH_OL_PIT_MIN.out", pit_minc);
			$readmemh("PITCH_OL_P_MAX1.out", p_max1c);
		end
	
	Pitch_ol_pipe i_pipe(
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
		.signal(signal), 
		.L_frame(L_frame), 
		.pit_max(pit_max), 
		.pit_min(pit_min), 
		.p_max1(p_max1));
	
	
		initial begin
		// Initialize Inputs
		start = 0;
		clk = 0;
		reset = 0;
		scaled_signal = 'd0;
		signal = 'd143;
		
		#50
		reset = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 0;
		
		for(j=0;j<60;j=j+1)
		begin
			//TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 
			Mux0Sel = 1;
			Mux1Sel = 0;
			Mux2Sel = 0;
			Mux3Sel = 0;
			testWrite = 0;

			for(i=0; i<223; i=i+1)
				begin
					@(posedge clk);
					@(posedge clk);
					@(posedge clk);	
					testWriteRequested = i;
					testWriteOut = scaled_signalc[i+j*223];
					testWrite = 1;	
					@(posedge clk);
					@(posedge clk);
					@(posedge clk);		
				end
				

			@(posedge clk);
			@(posedge clk);
			@(posedge clk);		
			L_frame = L_framec[j];
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
		
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
			pit_max = pit_maxc[j];
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
			pit_min = pit_minc[j];	
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
			if (p_max1 != p_max1c[j])
				$display($time, " ERROR: p_max1c[%d] = %x, expected = %x", j, p_max1, p_max1c[j]);
			else if (p_max1 == p_max1c[j])
				$display($time, " CORRECT:  p_max1c[%d] = %x", j, p_max1);
			@(posedge clk);

		end//j for loop
			
	end
      initial forever #10 clk = ~clk;	   

endmodule
