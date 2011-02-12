`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:24:58 02/05/2011
// Module Name:    Lsp_Expand_1_2_test.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: Lsp_expand_1_2
// 
// Dependencies: 	 Lsp_Expand_1_2.v, Scratch_Memory_Controller.v, L_sub.v, L_add.v, sub.v, shr.v, add.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Lsp_expand_1_2_test;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;	
	reg [10:0] bufAddr;
	reg [3:0]  gap;

	// Outputs	
	wire [31:0] memIn;
	wire done;
	
	//working regs
	reg [15:0] expandInMem [0:9999];
	reg [15:0] expandOutMem [0:9999];
	reg [15:0] expandGapMem [0:9999];
	
	//Mux0 regs	
	reg expandMuxSel;
	reg [10:0] testReadAddr;
	reg [10:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	integer i,j;
	
		//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("speech_lsp_expand_1_2_in.out", expandInMem);
		$readmemh("speech_lsp_expand_1_2_out.out", expandOutMem);
		$readmemh("speech_lsp_expand_1_2_gap.out", expandGapMem);
	end
	
	
	
	// Instantiate the Unit Under Test (UUT)
	Lsp_expand_1_2_pipe uut(
								.clk(clk),
								.reset(reset),
								.start(start),
								.expandMuxSel(expandMuxSel),
								.testReadAddr(testReadAddr),
								.testWriteAddr(testWriteAddr),
								.testMemOut(testMemOut),
								.testMemWriteEn(testMemWriteEn),
								.bufAddr(bufAddr),
								.gap(gap),
								.memIn(memIn),
								.done(done)
								);
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		testReadAddr = 0;
		testWriteAddr = 0;
		testMemOut = 0;
		testMemWriteEn = 0;
		bufAddr = RELSPWED_BUF;
		expandMuxSel = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 1;
		#50;
		reset = 0;
		#50;
		for(j=0;j<120;j=j+1)
		begin
		
		//writing the previous modules to memory
			gap = expandGapMem[j];
			
			for(i=0;i<10;i=i+1)
			begin
				#100;
				testWriteAddr = {RELSPWED_BUF[10:4],i[3:0]};
				testMemOut = expandInMem[j*10+i];
				testMemWriteEn = 1;	
				#100;
			end
			
			expandMuxSel = 0;			 
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here		
		
			wait(done);
			#100;
			expandMuxSel = 1;
			for (i = 0; i<10;i=i+1)
			begin				
					testReadAddr = {RELSPWED_BUF[10:4],i[3:0]};
					#50;
					if (memIn != expandOutMem[10*j+i])
						$display($time, " ERROR: buf[%d] = %x, expected = %x", 10*j+i, memIn, expandOutMem[10*j+i]);
					else if (memIn == expandOutMem[10*j+i])
						$display($time, " CORRECT:  buf[%d] = %x", 10*j+i, memIn);
					@(posedge clk);
	
				end
		end// for loop j

	end//initial
     
initial forever #10 clk = ~clk;	  
endmodule