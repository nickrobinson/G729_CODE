`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    20:19:24 04/11/2011
// Module Name:    Corr_xy2_test
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: Corr_xy2_pipe
// Dependencies: 	 Cor_hPipe.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Corr_xy2_test;

`include "paramList.v"

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg corr_xy2MuxSel;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	// Outputs
	wire done;
	wire [31:0] memIn;
	
	//temp regs
	reg [15:0] xnMem [0:9999];
	reg [15:0] y1Mem [0:9999];
	reg [15:0] y2Mem [0:9999];
	reg [15:0] gCoeffMem [0:9999];
	reg [15:0] expGCoeffMem [0:9999];
   //loop integers
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("tame_corxy2_xn_in.out", xnMem);			
			$readmemh("tame_corxy2_y1_in.out", y1Mem);
			$readmemh("tame_corxy2_y2_in.out", y2Mem);
			$readmemh("tame_corxy2_gCoeff_out.out", gCoeffMem);
			$readmemh("tame_corxy2_expGCoeff_out.out", expGCoeffMem);
		end

	// Instantiate the Unit Under Test (UUT)
	Corr_xy2_pipe uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.corr_xy2MuxSel(corr_xy2MuxSel), 
		.testReadAddr(testReadAddr), 
		.testWriteAddr(testWriteAddr), 
		.testMemOut(testMemOut), 
		.testMemWriteEn(testMemWriteEn), 
		.done(done), 
		.memIn(memIn)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		corr_xy2MuxSel = 1;
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

		for(j=0;j<60;j=j+1)
		begin
		
			for(i=0;i<40;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;				
				testMemOut = xnMem[40*j+i];				
				testWriteAddr = {XN[11:6], i[5:0]};				
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
				testMemOut = y1Mem[40*j+i];				
				testWriteAddr = {Y1[11:6], i[5:0]};				
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
				testMemOut = y2Mem[40*j+i];				
				testWriteAddr = {Y2[11:6], i[5:0]};				
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
        
			corr_xy2MuxSel = 0;	
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
			corr_xy2MuxSel = 1;
			@(posedge clk);
			@(posedge clk) #5;
			
			for(i=2;i<5;i=i+1)
			begin
				testReadAddr = {G_COEFF_CS[11:3],i[2:0]};
				@(posedge clk);
			   @(posedge clk) #5;
				if(memIn != gCoeffMem[j*5+i])
					$display($time, " ERROR: g_coeff[%d] = %x, expected = %x", j*5+i, memIn, gCoeffMem[j*5+i]);
				else if (memIn == gCoeffMem[j*5+i])
					$display($time, " CORRECT:  g_coeff[%d] = %x", j*5+i, memIn);
				@(posedge clk)#5; 
			end
			
			for(i=2;i<5;i=i+1)
			begin
				testReadAddr = {EXP_G_COEFF_CS[11:3],i[2:0]};
				@(posedge clk);
			   @(posedge clk) #5;
				if(memIn != expGCoeffMem[j*5+i])
					$display($time, " ERROR: exp_g_coeff[%d] = %x, expected = %x", j*5+i, memIn, expGCoeffMem[j*5+i]);
				else if (memIn == expGCoeffMem[j*5+i])
					$display($time, " CORRECT:  exp_g_coeff[%d] = %x", j*5+i, memIn);
				@(posedge clk)#5; 
			end
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;	
		end//j loop
	end//initial

initial forever #10 clk = ~clk;	  
endmodule

