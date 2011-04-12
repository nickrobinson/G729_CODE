`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:13:33 04/12/2011
// Module Name:    Enc_lag3_test
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: Enc_lag3_pipe
// Dependencies: 	 Enc_lag3.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Enc_lag3_test;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg Enc_lag3MuxSel;
	reg [15:0] T0;
	reg [15:0] T0_frac;
	reg [15:0] pit_flag;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	// Outputs
	wire done;
	wire [15:0] index;
	wire [31:0] memIn;

	//temp regs
	reg [15:0] pitFlagMem [0:9999];
	reg [15:0] T0Mem [0:9999];
	reg [15:0] T0FracMem [0:9999];
	reg [15:0] T0MaxInMem [0:9999];
	reg [15:0] T0MinInMem [0:9999];
	reg [15:0] T0MaxOutMem [0:9999];
	reg [15:0] T0MinOutMem [0:9999];
	
   //loop integers
	integer j;
	
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("speech_encLag3_pitFlag_in.out", pitFlagMem);			
			$readmemh("speech_encLag3_T0_in.out", T0Mem);
			$readmemh("speech_encLag3_T0frac_in.out", T0FracMem);
			$readmemh("speech_encLag3_T0max_in.out", T0MaxInMem);
			$readmemh("speech_encLag3_T0min_in.out", T0MinInMem);
			$readmemh("speech_encLag3_T0max_out.out", T0MaxOutMem);
			$readmemh("speech_encLag3_T0min_out.out", T0MinOutMem);
		end

	
	// Instantiate the Unit Under Test (UUT)
	Enc_lag3_pipe uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.Enc_lag3MuxSel(Enc_lag3MuxSel), 
		.T0(T0), 
		.T0_frac(T0_frac), 
		.pit_flag(pit_flag), 
		.testReadAddr(testReadAddr), 
		.testWriteAddr(testWriteAddr), 
		.testMemOut(testMemOut), 
		.testMemWriteEn(testMemWriteEn), 
		.done(done), 
		.index(index),
		.memIn(memIn)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		Enc_lag3MuxSel = 1;
		T0 = 0;
		T0_frac = 0;
		pit_flag = 0;
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
			T0 = T0Mem[j];
			T0_frac = T0FracMem[j]; 
			pit_flag = pitFlagMem[j]; 
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;				
			testMemOut = T0MaxInMem[j];				
			testWriteAddr = T0_MAX;				
			testMemWriteEn = 1;	
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;

			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;				
			testMemOut = T0MinInMem[j];				
			testWriteAddr = T0_MIN;				
			testMemWriteEn = 1;	
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
        
		   testReadAddr = 0;
			testWriteAddr = 0;
			Enc_lag3MuxSel = 0;	
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
			Enc_lag3MuxSel = 1;
			@(posedge clk);
			@(posedge clk) #5;
			
			testReadAddr = T0_MIN;
			@(posedge clk);
			@(posedge clk) #5;
			if(memIn != T0MinOutMem[j])
				$display($time, " ERROR: T0_min[%d] = %x, expected = %x", j, memIn, T0MinOutMem[j]);
			else if (memIn == T0MinOutMem[j])
				$display($time, " CORRECT:  T0_min[%d] = %x", j, memIn);
			@(posedge clk)#5; 

			testReadAddr = T0_MAX;
			@(posedge clk);
			@(posedge clk) #5;
			if(memIn != T0MaxOutMem[j])
				$display($time, " ERROR: T0_max[%d] = %x, expected = %x", j, memIn, T0MaxOutMem[j]);
			else if (memIn == T0MaxOutMem[j])
				$display($time, " CORRECT:  T0_max[%d] = %x", j, memIn);			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;	
		end//j loop
	end//initial

initial forever #10 clk = ~clk;	  
      
endmodule

