`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:25:35 03/24/2011 
// Design Name: 
// Module Name:    Lag_max_test 
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
module Lag_max_test;

`include "paramList.v"
`include "constants_param_list.v"

	reg start;
	reg clk;
	reg reset;
	reg [11:0] signal, scaled_signal;
	reg [15:0] L_frame, lag_max, lag_min;
	
	//Outputs
	wire done;
	wire [31:0] readIn;	
	wire [15:0] cor_max;
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
	reg [15:0] lag_maxc [0:4000];
	reg [15:0] lag_minc [0:40000];
	reg [15:0] cor_maxc [0:4000];

	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("LAG_MAX_SCALED_SIGNAL.out", scaled_signalc);
			$readmemh("LAG_MAX_L_FRAME_IN.out", L_framec);
			$readmemh("LAG_MAX_LAG_MAX_IN.out", lag_maxc);
			$readmemh("LAG_MAX_LAG_MIN_IN.out", lag_minc);
			$readmemh("LAG_MAX_COR_MAX_OUT.out", cor_maxc);
		end
	
	Lag_max_pipe i_pipe(
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
		.lag_max(lag_max), 
		.lag_min(lag_min), 
		.cor_max(cor_max));
	
	
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
					testWriteOut = scaled_signalc[i+(j/3)*223];
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
			lag_max = lag_maxc[j];
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
			lag_min = lag_minc[j];	
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
			if (cor_max != cor_maxc[j])
				$display($time, " ERROR: cor_maxc[%d] = %x, expected = %x", j, cor_max, cor_maxc[j]);
			else if (cor_max == cor_maxc[j])
				$display($time, " CORRECT:  cor_maxc[%d] = %x", j, cor_max);
			@(posedge clk);

		end//j for loop
			
	end
      initial forever #10 clk = ~clk;	   

endmodule
