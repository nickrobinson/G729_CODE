`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    22:00:07 02/01/2011
// Module Name:    Lsp_Expand_1_test.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: Lsp_Expand_1
// 
// Dependencies: 	 Lsp_Expand_1.v, Scratch_Memory_Controller.v, L_sub.v, L_add.v, sub.v, shr.v, add.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Lsp_expand_1_test;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;	

	// Outputs	
	wire [31:0] memIn;
	wire done;
	
	//working regs
	reg [15:0] expand1InMem [0:9999];
	reg [15:0] expand1OutMem [0:9999];

	
	//Mux0 regs	
	reg expand1MuxSel;
	reg [10:0] testReadAddr;
	reg [10:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	integer i,j;
	
		//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("speech_lsp_expand_1_in.out", expand1InMem);
		$readmemh("speech_lsp_expand_1_out.out", expand1OutMem);
	end
	
	
	
	// Instantiate the Unit Under Test (UUT)
	Lsp_expand_1_pipe uut(
								.clk(clk),
								.reset(reset),
								.start(start),
								.expand1MuxSel(expand1MuxSel),
								.testReadAddr(testReadAddr),
								.testWriteAddr(testWriteAddr),
								.testMemOut(testMemOut),
								.testMemWriteEn(testMemWriteEn),
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
		expand1MuxSel = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 1;
		#50;
		reset = 0;
		#50;
		for(j=0;j<120;j=j+1)
		begin
		
		//writing the previous modules to memory			
			for(i=0;i<10;i=i+1)
			begin
				#100;
				testWriteAddr = {RELSPWED_BUF[10:4],i[3:0]};
				testMemOut = expand1InMem[j*10+i];
				testMemWriteEn = 1;	
				#100;
			end
			
			expand1MuxSel = 0;			 
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here		
		
			wait(done);
			#100;
			expand1MuxSel = 1;
			for (i = 0; i<10;i=i+1)
			begin				
					testReadAddr = {RELSPWED_BUF[10:4],i[3:0]};
					#50;
					if (memIn != expand1OutMem[10*j+i])
						$display($time, " ERROR: buf[%d] = %x, expected = %x", 10*j+i, memIn, expand1OutMem[10*j+i]);
					else if (memIn == expand1OutMem[10*j+i])
						$display($time, " CORRECT:  buf[%d] = %x", 10*j+i, memIn);
					@(posedge clk);
	
				end
		end// for loop j

	end//initial
     
initial forever #10 clk = ~clk;	  
endmodule