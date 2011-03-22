`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    20:17:03 02/28/2011
// Module Name:    lsf_lsp2Test.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Verilog Test Fixture created by ISE for module: lsf_lspPipe
// 
// Dependencies: 	 lsf_lspPipe.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module lsf_lsp2Test;

	// Inputs
	reg start;
	reg clk;
	reg reset;
	reg [11:0] lspAddr;
	reg [11:0] lsfAddr;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testWriteEn;
	reg memMuxSel;

	// Outputs
	wire done;
	wire [31:0] memIn;
	
	//temp regs
	reg [31:0] lspMem [0:9999];
	reg [31:0] lsfMem [0:9999];
	
	
	//loop integers
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("speech_lsflsp2_lsp_out.out", lspMem);
			$readmemh("speech_lsflsp2_lsf_in.out", lsfMem);			
		end

	// Instantiate the Unit Under Test (UUT)
	lsf_lspPipe uut (
		.start(start), 
		.clk(clk), 
		.reset(reset), 
		.lspAddr(lspAddr), 
		.lsfAddr(lsfAddr), 
		.testReadAddr(testReadAddr), 
		.testWriteAddr(testWriteAddr), 
		.testMemOut(testMemOut), 
		.testWriteEn(testWriteEn), 
		.memMuxSel(memMuxSel), 
		.done(done), 
		.memIn(memIn)
	);

	initial begin
		// Initialize Inputs
		start = 0;
		clk = 0;
		reset = 0;
		lspAddr = 11'd512;
		lsfAddr = 11'd1024;
		testReadAddr = 0;
		testWriteAddr = 0;
		testMemOut = 0;
		testWriteEn = 0;
		memMuxSel = 0;

		@(posedge clk);
		@(posedge clk) #5;
		reset = 1;
		// Wait 45 ns for global reset to finish
		@(posedge clk);
		@(posedge clk) #5;
		reset = 0;
       
	for(j=0;j<60;j=j+1)
		begin
			
			for(i=0;i<10;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;				
				testMemOut = lsfMem[10*j+i];				
				testWriteAddr = {lsfAddr[10:4], i[3:0]};				
				testWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			memMuxSel = 1;	
	
			@(posedge clk);
			@(posedge clk) #5;		
			start = 1;
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);
			@(posedge clk) #5;
		// Add stimulus here
		wait(done);
		memMuxSel = 0;
			
			//mem read
			for (i = 0; i<10;i=i+1)
			begin				
					testReadAddr = {lspAddr[10:4],i[3:0]};
					@(posedge clk);
					@(posedge clk) #5;
					if (memIn != lspMem[j*10+i])
						$display($time, " ERROR: lsp[%d] = %x, expected = %x", j*10+i, memIn, lspMem[j*10+i]);
					else if (memIn == lspMem[j*10+i])
						$display($time, " CORRECT:  lsp[%d] = %x", j*10+i, memIn);
					@(posedge clk)#5; 
			end	
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;	
		end//j for loop

	end//initial
	
	initial forever #10 clk = ~clk;   
      
endmodule
