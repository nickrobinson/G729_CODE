`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:37:21 03/09/2011
// Design Name:   Cor_hPipe
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Spring 2011/Senior Design II/G729 Verilog Code/ACELP_Codebook/Cor_hTest.v
// Project Name:  ACELP_Codebook
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Cor_hPipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Cor_hTest;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg corHMuxSel;
	reg [10:0] testReadAddr;
	reg [10:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	// Outputs
	wire done;
	wire [31:0] memIn;

	//temp regs
	reg [15:0] hMem [0:9999];
	reg [15:0] rrMem [0:9999];
   //loop integers
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("lsp_Cor_h_in.out", hMem);			
			$readmemh("lsp_Cor_h_out.out", rrMem);
		end
	// Instantiate the Unit Under Test (UUT)
	Cor_hPipe uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 		
		.corHMuxSel(corHMuxSel), 
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
		corHMuxSel = 1;
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
				testMemOut = hMem[40*j+i];				
				testWriteAddr = {ACELP_H[10:6], i[5:0]};				
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
        
			corHMuxSel = 0;	
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
			corHMuxSel = 1;
			@(posedge clk);
			@(posedge clk) #5;
			
			for(i=0;i<616;i=i+1)
			begin
				testReadAddr = {ACELP_RR[10],i[9:0]};
				@(posedge clk);
			   @(posedge clk) #5;
				if(memIn != rrMem[j*616+i])
					$display($time, " ERROR: rr[%d] = %x, expected = %x", j*616+i, memIn, rrMem[j*616+i]);
				else if (memIn == rrMem[j*616+i])
					$display($time, " CORRECT:  rr[%d] = %x", j*616+i, memIn);
				@(posedge clk)#5; 
			end
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;	
		end//j loop
	end//initial

initial forever #10 clk = ~clk;	     
endmodule

