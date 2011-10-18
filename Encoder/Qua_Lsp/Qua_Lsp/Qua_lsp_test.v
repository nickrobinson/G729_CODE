`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Nick Robinson
// 
// Create Date:    10:13:12 02/23/2011
// Module Name:    Relspwed_test.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Verilog Test Fixture created by ISE for module: Relspwed_test
// 
// Dependencies: 	 Relspwed_test.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Qua_lsp_test;
`include "constants_param_list.v"
`include "paramList.v"

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [11:0] lsp_qAddr;
	reg [11:0] lspAddr;
	reg [11:0] anaAddr;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;
	reg quaLspMuxSel;

	// Outputs
	wire done;
	wire [31:0] memIn;
	
	//temp regs
	reg [15:0] lsp_q [0:9999];
	reg [15:0] lsp [0:9999];
	reg [15:0] ana [0:9999];		//output
	reg [15:0] freq_prev [0:9999];
	
	
	//loop integers
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			//$readmemh("lsp_lsp_get_quant_mode_index.out", code_ana);			
			$readmemh("qua_lspq.out", lsp_q);	
			$readmemh("qua_lsp.out", lsp);
			$readmemh("qua_ana.out", ana);
			$readmemh("qua_freq_prev.out", freq_prev);
		end
		
	// Instantiate the Unit Under Test (UUT)
	Qua_lsp_pipe uut(
						.clk(clk), 
						.reset(reset), 
						.start(start), 
						.lsp_qAddr(lsp_qAddr), 
						.lspAddr(lspAddr), 
						.anaAddr(anaAddr),
						.testReadAddr(testReadAddr), 
						.testWriteAddr(testWriteAddr), 
						.testMemOut(testMemOut), 
						.testMemWriteEn(testMemWriteEn), 
						.done(done), 
						.memIn(memIn), 
						.quaLspMuxSel(quaLspMuxSel)
					);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		quaLspMuxSel = 1;
		testReadAddr = 0;
		testWriteAddr = 0;
		testMemOut = 0;
		testMemWriteEn = 0;
		lspAddr = 12'd256;
		lsp_qAddr = 12'd1024;
		anaAddr = 12'd2048;

		@(posedge clk);
		@(posedge clk) #5;
		reset = 1;
		// Wait 45 ns for global reset to finish
		@(posedge clk);
		@(posedge clk) #5;
		reset = 0;
		
		for(j=0;j<10;j=j+1)
		begin		
			
			for(i=0;i<10;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;				
				testMemOut = lsp_q[10*j+i];				
				testWriteAddr = {lsp_qAddr[11:4], i[3:0]};				
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			for(i=0;i<64;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;				
				testMemOut = freq_prev[64*j+i];				
				testWriteAddr = {FREQ_PREV[11:6], i[5:0]};				
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			for(i=0;i<10;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;				
				testMemOut = lsp[10*j+i];				
				testWriteAddr = {lspAddr[11:4], i[3:0]};				
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			for(i=0;i<2;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;				
				testMemOut = ana[2*j+i];				
				testWriteAddr = {anaAddr[11:4], i[3:0]};				
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			quaLspMuxSel = 0;	
	
			@(posedge clk);
			@(posedge clk) #5;		
			start = 1;
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);
			@(posedge clk) #5;
			
			wait(done);
			quaLspMuxSel = 1;
			
			//ap read
			for (i = 0; i<10; i=i+1)
			begin				
					testReadAddr = {lsp_qAddr[11:4],i[3:0]};
					@(posedge clk);
					@(posedge clk) #5;
					if (memIn != lsp_q[j*10+i])
						$display($time, " ERROR: lsp_q[%d] = %x, expected = %x", j*10+i, memIn, lsp_q[j*10+i]);
					else if (memIn == lsp_q[j*10+i])
						$display($time, " CORRECT:  lsp_q[%d] = %x", j*10+i, memIn);
					@(posedge clk)#5; 
			end	
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;	
		end//j for loop
			
	end
      initial forever #10 clk = ~clk;	       
	
endmodule