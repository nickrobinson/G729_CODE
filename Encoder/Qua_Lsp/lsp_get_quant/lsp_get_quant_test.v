`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    10:13:12 02/23/2011
// Module Name:    lsp_get_quant_pipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Verilog Test Fixture created by ISE for module: lsp_get_quant_pipe
// 
// Dependencies: 	 lsp_get_quant_pipe.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module lsp_get_quant_test;
`include "constants_param_list.v"
`include "paramList.v"

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [15:0] code0;
	reg [15:0] code1;
	reg [15:0] code2;
	reg [11:0] fgAddr;
	reg [11:0] freq_prevAddr;
	reg [11:0] fg_sumAddr;
	reg [11:0] lspqAddr;
	reg getQuantMuxSel;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	// Outputs
	wire done;
	wire [31:0] memIn;
	
	//temp regs
	reg [15:0] code0Mem [0:9999];
	reg [15:0] code1Mem [0:9999];
	reg [15:0] code2Mem [0:9999];
	reg mode_index [0:9999];
	reg [15:0] freq_prev [0:9999];
	reg [15:0] lspq [0:9999];

	//loop integers
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("lsp_lsp_get_quant_code0_in.out", code0Mem);
			$readmemh("lsp_lsp_get_quant_code1_in.out", code1Mem);
			$readmemh("lsp_lsp_get_quant_code2_in.out", code2Mem);
			$readmemh("lsp_lsp_get_quant_mode_index.out", mode_index);			
			$readmemh("lsp_lsp_get_quant_freq_prev_in.out", freq_prev);
			$readmemh("lsp_lsp_get_quant_lspq_out.out", lspq);
		end
	// Instantiate the Unit Under Test (UUT)
	lsp_get_quant_pipe uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.code0(code0), 
		.code1(code1), 
		.code2(code2), 
		.fgAddr(fgAddr), 
		.freq_prevAddr(freq_prevAddr), 
		.fg_sumAddr(fg_sumAddr), 
		.lspqAddr(lspqAddr), 
		.getQuantMuxSel(getQuantMuxSel), 
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
		getQuantMuxSel = 1;
		testReadAddr = 0;
		testWriteAddr = 0;
		testMemOut = 0;
		testMemWriteEn = 0;
		lspqAddr = 12'd256;
		freq_prevAddr = 12'd512;				

		@(posedge clk);
		@(posedge clk) #5;
		reset = 1;
		// Wait 45 ns for global reset to finish
		@(posedge clk);
		@(posedge clk) #5;
		reset = 0;
		
		for(j=0;j<60;j=j+1)
		begin
			fg_sumAddr = FG_SUM + (mode_index[j]*16);
			fgAddr = FG + (mode_index[j]*64);
			code0 = code0Mem[j];
			code1 = code1Mem[j];
			code2 = code2Mem[j];				
			
			for(i=0;i<64;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;				
				testMemOut = freq_prev[64*j+i];				
				testWriteAddr = {freq_prevAddr[10:6], i[5:0]};				
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			getQuantMuxSel = 0;	
	
			@(posedge clk);
			@(posedge clk) #5;		
			start = 1;
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);
			@(posedge clk) #5;
			
			wait(done);
			getQuantMuxSel = 1;
			
			//ap read
			for (i = 0; i<10;i=i+1)
			begin				
					testReadAddr = {lspqAddr[10:4],i[3:0]};
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
