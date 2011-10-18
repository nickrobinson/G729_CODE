`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    09:55:21 04/14/2011
// Module Name:    Norm_Corr_test
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: Norm_Corr_pipe
// Dependencies: 	 Norm_Corr_pipe.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Norm_Corr_test;

`include "paramList.v"

	// Inputs
	reg clk;
	reg start;
	reg reset;
	reg [11:0] excAddr;
	reg [15:0] t_min;
	reg [15:0] t_max;
	reg normCorrMuxSel;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	// Outputs
	wire [31:0] memIn;
	wire done;

		//temp regs
	reg [15:0] excMem [0:9999];	
	reg [15:0] xnMem [0:9999];
	reg [15:0] hMem [0:9999];
	reg [15:0] tminMem [0:9999];
	reg [15:0] tmaxMem [0:9999];
	reg [31:0] corrvMem [0:9999];
	
	//loop integers
	integer i,j;
	
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("tame_normcorr_corrv_in.out", corrvMem);			
			$readmemh("tame_normcorr_exc_in.out", excMem);
			$readmemh("tame_normcorr_xn_in.out", xnMem);
			$readmemh("tame_normcorr_h_in.out", hMem);
			$readmemh("tame_normcorr_tmin_in.out", tminMem);
			$readmemh("tame_normcorr_tmax_in.out", tmaxMem);
		end
		
	// Instantiate the Unit Under Test (UUT)
	Norm_Corr_pipe uut (
		.clk(clk), 
		.start(start), 
		.reset(reset), 
		.excAddr(excAddr), 
		.t_min(t_min), 
		.t_max(t_max), 
		.normCorrMuxSel(normCorrMuxSel), 
		.testReadAddr(testReadAddr), 
		.testWriteAddr(testWriteAddr), 
		.testMemOut(testMemOut), 
		.testMemWriteEn(testMemWriteEn), 
		.memIn(memIn), 
		.done(done)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		start = 0;
		reset = 0;		
		t_min = 0;
		t_max = 0;
		normCorrMuxSel = 1;
		testReadAddr = 0;
		testWriteAddr = 0;
		testMemOut = 0;
		testMemWriteEn = 0;

		@(posedge clk);
		@(posedge clk) #5;
		reset = 1;
		// Wait 45 ns for global reset to finish
		@(posedge clk);
		@(posedge clk) #5;
		reset = 0;

		for(j=0;j<128;j=j+1)
		begin
			testReadAddr = 0;
			testWriteAddr = 0;
			t_min = tminMem[j];
			t_max = tmaxMem[j];
			if(j%2 == 0)
				excAddr = 12'd3226;
			else
				excAddr = 12'd3266;
				
			for(i=0;i<234;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;	
				testWriteAddr = {OLD_EXC[11:8],i[7:0]};
				testMemOut = excMem[j*234+i];								
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			for(i=0;i<40;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;	
				testWriteAddr = {XN[11:6],i[5:0]};
				testMemOut = xnMem[j*40+i];								
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
						
			for(i=0;i<40;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;	
				testWriteAddr = {H1[11:6],i[5:0]};
				testMemOut = hMem[j*40+i];								
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
        
		   testReadAddr = 0;
			testWriteAddr = 0;
			normCorrMuxSel = 0;	
			testMemWriteEn = 0;	
			@(posedge clk);
			@(posedge clk) #5;		
			start = 1;
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);
			@(posedge clk) #5;
			
			wait(done);
			normCorrMuxSel = 1;
			@(posedge clk);
			@(posedge clk) #5;
			
			for(i=0;i<t_max-t_min;i=i+1)
			begin
				testReadAddr = PITCH_FR3_CORR_V + i;
				@(posedge clk);
				@(posedge clk) #5;
				if(memIn != corrvMem[j*40+i])
					$display($time, " ERROR: corr_v[%d] = %x, expected = %x", j*40+i, memIn, corrvMem[j*40+i]);
				else if (memIn == corrvMem[j*40+i])
					$display($time, " CORRECT:  corr_v[%d] = %x", j*40+i, memIn);
				@(posedge clk)#5; 
			end			
		end//j loop
	end//initial

initial forever #10 clk = ~clk;	  
endmodule

