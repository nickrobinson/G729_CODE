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

module lsp_qua_cs_test;
`include "constants_param_list.v"
`include "paramList.v"

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [11:0] freq_prevAddr;
	reg [11:0] lspAddr;
	reg [11:0] code_anaAddr;
	reg [11:0] lspqAddr;
	reg [11:0] flspAddr;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;
	reg relspwedMuxSel;

	// Outputs
	wire done;
	wire [31:0] memIn;
	
	//temp regs
	reg [15:0] flsp [0:9999];
	reg [15:0] freq_prev [0:9999];
	reg [15:0] lspq [0:9999];		//output
	reg [15:0] code_ana [0:9999]; //output
	reg [15:0] wegt [0:9999];
	
	
	//loop integers
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			//$readmemh("lsp_lsp_get_quant_mode_index.out", code_ana);			
			$readmemh("lsp_qua_cs_flsp.out", flsp);	
			$readmemh("lsp_qua_cs_freq_prev.out", freq_prev);
			$readmemh("lsp_qua_cs_lspq.out", lspq);
			$readmemh("lsp_qua_cs_wegt.out", wegt);	
		end
		
	// Instantiate the Unit Under Test (UUT)
	lsp_qua_cs_pipe uut (.clk(clk), 
							 .reset(reset), 
							 .start(start), 
							 .flspAddr(flspAddr),
							 .freq_prevAddr(freq_prevAddr), 
							 .lspqAddr(lspqAddr), 
							 .code_anaAddr(code_anaAddr),
							 .testReadAddr(testReadAddr), 
							 .testWriteAddr(testWriteAddr), 
							 .testMemOut(testMemOut), 
							 .testMemWriteEn(testMemWriteEn), 
							 .done(done),
							 .relspwedMuxSel(relspwedMuxSel),
							 .memIn(memIn)
							 );

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		relspwedMuxSel = 1;
		testReadAddr = 0;
		testWriteAddr = 0;
		testMemOut = 0;
		testMemWriteEn = 0;
		lspAddr = 12'd256;
		freq_prevAddr = 12'd1024;
		code_anaAddr = 12'd2048;
		lspqAddr = 12'd3072;
		flspAddr = 12'd3584;

		@(posedge clk);
		@(posedge clk) #5;
		reset = 1;
		// Wait 45 ns for global reset to finish
		@(posedge clk);
		@(posedge clk) #5;
		reset = 0;
		
		for(j=0;j<10;j=j+1)
		begin		
			
			for(i=0;i<64;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;				
				testMemOut = freq_prev[64*j+i];				
				testWriteAddr = {freq_prevAddr[11:6], i[5:0]};				
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
				testMemOut = flsp[10*j+i];				
				testWriteAddr = {flspAddr[11:4], i[3:0]};				
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			relspwedMuxSel = 0;	
	
			@(posedge clk);
			@(posedge clk) #5;		
			start = 1;
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);
			@(posedge clk) #5;
			
			wait(done);
			relspwedMuxSel = 1;
			
			//ap read
			for (i = 0; i<10; i=i+1)
			begin				
					testReadAddr = {lspqAddr[11:4],i[3:0]};
					@(posedge clk);
					@(posedge clk) #5;
					if (memIn != lspq[j*10+i])
						$display($time, " ERROR: lspq[%d] = %x, expected = %x", j*10+i, memIn, lspq[j*10+i]);
					else if (memIn == lspq[j*10+i])
						$display($time, " CORRECT:  lspq[%d] = %x", j*10+i, memIn);
					@(posedge clk)#5; 
			end	
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;	
		end//j for loop
			
	end
      initial forever #10 clk = ~clk;	       
	
endmodule