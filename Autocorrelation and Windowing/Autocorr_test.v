`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:10:18 02/09/2011
// Design Name:   Autocorr_Top
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Spring 2011/Senior Design II/G729 Verilog Code/Autocorelation_and_Windowing/Autocorr_test.v
// Project Name:  Autocorelation_and_Windowing
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Autocorr_Top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Autocorr_test;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [7:0] xMemAddr;
	reg [31:0] xMemOut;
	reg xMemEn;
	reg autocorrMuxSel;
	reg [11:0] testReadRequested;
	reg [11:0] testWriteRequested;
	reg [31:0] testMemOut;
	reg testMemWrite;

	// Outputs
	wire done;
	wire [31:0] memIn;

//working regs
	reg [15:0] autocorrInMem [0:9999];
	reg [31:0] autocorrOutMem [0:9999];
	
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("lsp_autocorr_in.out", autocorrInMem);
		$readmemh("lsp_autocorr_out.out", autocorrOutMem);
	end					
	
	// Instantiate the Unit Under Test (UUT)
	Autocorr_Top uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.xMemAddr(xMemAddr), 
		.xMemOut(xMemOut), 
		.xMemEn(xMemEn), 
		.autocorrMuxSel(autocorrMuxSel), 
		.testReadRequested(testReadRequested), 
		.testWriteRequested(testWriteRequested), 
		.testMemOut(testMemOut), 
		.testMemWrite(testMemWrite), 
		.done(done), 
		.memIn(memIn)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		xMemAddr = 0;
		xMemOut = 0;
		xMemEn = 0;
		autocorrMuxSel = 1;
		testReadRequested = 0;
		testWriteRequested = 0;		
		testMemOut = 0;
		testMemWrite = 0;

		// Wait 150 ns for global reset to finish
		@(posedge clk) #5;
		reset = 1;
		@(posedge clk) #5;
		reset = 0;
		@(posedge clk);
		@(posedge clk) #5;
		
		for(j=0;j<120;j=j+1)
		begin
		@(posedge clk);		
		@(posedge clk) #5;
		autocorrMuxSel = 1;		  
		//writing the previous modules to memory					
			for(i=0;i<240;i=i+1)
			begin
				@(posedge clk);	
				@(posedge clk) #5;		
				xMemAddr = i[7:0];
				xMemOut = autocorrInMem[j*240+i];
				xMemEn = 1;	
				@(posedge clk);	
				@(posedge clk) #5;	
			end
			
			autocorrMuxSel = 0;
			xMemEn = 0;
			start = 1;
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);
			@(posedge clk) #5;		
			
			wait(done);
//			@(posedge clk) #5;	
			// Add stimulus here				
			autocorrMuxSel = 1;
			
			for (i = 0; i<11;i=i+1)
			begin				
					testReadRequested = {AUTOCORR_R[10:4],i[3:0]};
					@(posedge clk);		
					@(posedge clk) #5;
					if (memIn != autocorrOutMem[11*j+i])
						$display($time, " ERROR: r[%d] = %x, expected = %x", 11*j+i, memIn, autocorrOutMem[11*j+i]);
					else if (memIn == autocorrOutMem[11*j+i])
						$display($time, " CORRECT:  r[%d] = %x", 11*j+i, memIn);
					@(posedge clk) #5;	
				end				
		end// for loop j		
	end//end initial
 
initial forever #10 clk = ~clk;	  //50MHz Clock
endmodule

