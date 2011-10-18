`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    11:09:53 03/31/2011
// Module Name:    cor_h_X_Test
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: cor_h_X_Pipe
// Dependencies: 	 cor_h_X_Pipe.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module cor_h_X_Test;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg corHXMuxSel;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	// Outputs
	wire [31:0] memIn;
	wire done;
	
	//temp regs
	reg [15:0] hMem [0:9999];
	reg [15:0] xMem [0:9999];
	reg [15:0] dnMem[0:9999];
	
	 //loop integers
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("lsp_corHX_h_in.out", hMem);			
			$readmemh("lsp_corHX_x_in.out", xMem);
			$readmemh("lsp_corHX_d_out.out", dnMem);
		end

	// Instantiate the Unit Under Test (UUT)
	cor_h_X_Pipe uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.corHXMuxSel(corHXMuxSel), 
		.testReadAddr(testReadAddr), 
		.testWriteAddr(testWriteAddr), 
		.testMemOut(testMemOut), 
		.testMemWriteEn(testMemWriteEn), 
		.memIn(memIn), 
		.done(done)
	);

	initial begin
		// Initialize Inputs
                #100;
		clk = 0;
		reset = 0;
		start = 0;
		corHXMuxSel = 1;
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
				testWriteAddr = {H1[11:6], i[5:0]};				
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
				testMemOut = xMem[40*j+i];				
				testWriteAddr = {XN2[11:6], i[5:0]};				
				testMemWriteEn = 1;				
			end
        
			@(posedge clk);
			@(posedge clk) #5;	
		   corHXMuxSel = 0;	
			testMemWriteEn = 0;
			testWriteAddr = 0;
			@(posedge clk);
			@(posedge clk) #5;		
			start = 1;
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);
			@(posedge clk) #5;
			
		   wait(done);
			corHXMuxSel = 1;
			@(posedge clk);
			@(posedge clk) #5;
			
			for(i=0;i<40;i=i+1)
			begin
				testReadAddr = {ACELP_DN[11:6],i[5:0]};
				@(posedge clk);
			   @(posedge clk) #5;
				if(memIn != dnMem[j*40+i])
					$display($time, " ERROR: dn[%d] = %x, expected = %x", j*40+i, memIn, dnMem[j*40+i]);
				else if (memIn == dnMem[j*40+i])
					$display($time, " CORRECT:  dn[%d] = %x", j*40+i, memIn);
				@(posedge clk)#5; 
			end
		end//j loop
	end//initial
      
initial forever #10 clk = ~clk;	      
		
endmodule

