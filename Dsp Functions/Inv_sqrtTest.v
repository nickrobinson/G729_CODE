`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    16:46:14 03/01/2011
// Module Name:    Inv_sqrtTest.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Verilog Test Fixture created by ISE for module: Inv_sqrtPipe.v
// 
// Dependencies: 	 Inv_sqrtPipe.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Inv_sqrtTest;

	// Inputs
	reg clk;
	reg start;
	reg reset;
	reg [10:0] L_xAddr;
	reg [10:0] L_yAddr;
	reg sqrtMuxSel;
	reg [10:0] testReadAddr;
	reg [10:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	// Outputs
	wire done;
	wire [31:0] memIn;

	// Instantiate the Unit Under Test (UUT)
	Inv_sqrtPipe uut (
		.clk(clk), 
		.start(start), 
		.reset(reset), 
		.L_xAddr(L_xAddr), 
		.L_yAddr(L_yAddr), 
		.sqrtMuxSel(sqrtMuxSel), 
		.testReadAddr(testReadAddr), 
		.testWriteAddr(testWriteAddr), 
		.testMemOut(testMemOut), 
		.testMemWriteEn(testMemWriteEn), 
		.done(done), 
		.memIn(memIn)
	);
	
	//temp regs
	reg [31:0] sqrtInMem [0:9999];
	reg [31:0] sqrtOutMem [0:9999];
	
	
	//loop integers
	integer j;
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("speech_inv_sqrt_in.out", sqrtInMem);
			$readmemh("speech_inv_sqrt_out.out", sqrtOutMem);			
		end

	initial begin
		// Initialize Inputs
		clk = 0;
		start = 0;
		reset = 0;
		L_xAddr = 512;
		L_yAddr = 1024;
		sqrtMuxSel = 1;
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
		
		for(j=0;j<600;j=j+1)
		begin
						
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;				
			testMemOut = sqrtInMem[j];				
			testWriteAddr = L_xAddr;				
			testMemWriteEn = 1;	
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;

         sqrtMuxSel = 0;	
			start = 1;			
			@(posedge clk) #5;
			start = 0;			
			// Add stimulus here
			wait(done);			
			@ (posedge clk);
			@ (posedge clk);
			@ (posedge clk) #5;
			sqrtMuxSel = 1;
			testReadAddr = L_yAddr;
			@(posedge clk);
			@(posedge clk) #5;
			if (memIn != sqrtOutMem[j])
				$display($time, " ERROR: sqrt[%d] = %x, expected = %x", j, memIn, sqrtOutMem[j]);
			else if (memIn == sqrtOutMem[j])
				$display($time, " CORRECT:  sqrt[%d] = %x", j, memIn);
			@(posedge clk)#5; 
	
		end//j for loop

	end//initial
	
	initial forever #10 clk = ~clk;   

endmodule

