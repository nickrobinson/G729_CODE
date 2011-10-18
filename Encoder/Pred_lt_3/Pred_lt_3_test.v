`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:31:08 04/13/2011 
// Design Name: 
// Module Name:    Pred_lt_3_test 
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
module Pred_lt_3_test;

`include "paramList.v"
`include "constants_param_list.v"

	reg start;
	reg clk;
	reg reset;
	reg [11:0] exc;
	reg [15:0] t0, frac, L_subfr;
	
	//Outputs
	wire done;
	wire [31:0] readIn;	
	wire [31:0] constantMemIn;
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
	reg [15:0] excc [0:60000];
	reg [15:0] t0c [0:40000];
	reg [15:0] fracc [0:40000];
	reg [15:0] L_subfrc [0:4000];
	reg [15:0] outputc [0:4000];

	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("PRED_LT_3_EXC.out", excc);
			$readmemh("PRED_LT_3_T0.out", t0c);
			$readmemh("PRED_LT_3_FRAC.out", fracc);
			$readmemh("PRED_LT_3_L_SUBFR.out", L_subfrc);
			$readmemh("PRED_LT_3_OUTPUT.out", outputc);
		end
	
	Pred_lt_3_pipe i_pipe(
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
		.constantMemIn(constantMemIn),
		.exc(exc), 
		.t0(t0), 
		.frac(frac), 
		.L_subfr(L_subfr));
	
	
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
		
		for(j=0;j<60;j=j+1)
		begin
			//TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 
			Mux0Sel = 1;
			Mux1Sel = 0;
			Mux2Sel = 0;
			Mux3Sel = 0;
			testWrite = 0;

			for(i=0; i<234; i=i+1)
				begin
					@(posedge clk);
					@(posedge clk);
					@(posedge clk);	
					testWriteRequested = {OLD_EXC[11:8],i[7:0]};
					testWriteOut = excc[i+j*234];
					testWrite = 1;	
					@(posedge clk);
					@(posedge clk);
					@(posedge clk);		
				end
	
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
			if(j%2 == 'd0)
				exc = EXC;
			else
				exc = EXC+40;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);		

			@(posedge clk);
			@(posedge clk);
			@(posedge clk);		
			t0 = t0c[j];
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
		
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
			frac = fracc[j];
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);	
			L_subfr = L_subfrc[j];	
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
		for(i=0; i<40; i=i+1)
			begin
				if(j%2 == 'd0)
					testReadRequested = EXC+i;
				else
					testReadRequested = EXC+40+i;
				@(posedge clk);
				@(posedge clk);
				if (readIn != outputc[i+j*40])
					$display($time, " ERROR: excc[%d] = %x, expected = %x", i, readIn, outputc[i+j*40]);
				else if (readIn == outputc[i+j*40])
					$display($time, " CORRECT:  excc[%d] = %x", i, readIn);
				@(posedge clk);
			end
		end//j for loop
	end
      initial forever #10 clk = ~clk;	   


endmodule
