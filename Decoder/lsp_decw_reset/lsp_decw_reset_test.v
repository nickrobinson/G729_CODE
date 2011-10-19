`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:11 10/10/2011 
// Design Name: 
// Module Name:    lsp_decw_reset_test 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lsp_decw_reset_test;

	`include "paramList.v"

	reg start;
	reg reset;
	reg clk;

	wire done;
	
	reg [11:0] memReadAddrTest;
	wire [31:0] memInTest;	
	
	//I/O regs
	reg [15:0] freq_prev_data [0:40000];
	reg [15:0] prev_lsp_data [0:40000];
	
	integer i,k;
	
	//file reads for any inputs or outputs
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("lsp_decw_reset_freq_prev.out", freq_prev_data);
		$readmemh("lsp_decw_reset_prev_lsp.out", prev_lsp_data);
	end
	
	// Instantiate the Unit Under Test (UUT)
	lsp_decw_reset_pipe uut(
	.clk(clk), 
	.reset(reset), 
	.start(start), 
	.done(done), 
	.memInTest(memInTest), 
	.memReadAddrTest(memReadAddrTest)
	);
	
	
	initial begin
	// Initialize Inputs
	clk = 0;
	reset = 0;
	start = 0;
	// Wait 50 ns for global reset to finish
	#50;
	reset = 1;
	#50;
	reset = 0;
	#50;
	start = 1;
	#50;
	start = 0;
	#50;
	// Add stimulus here		
		
	wait(done);
	#100;
	
	
	for(k=0; k<4; k=k+1)
		begin
		for (i = 0; i<10;i=i+1)
			begin				
				memReadAddrTest = {FREQ_PREV[11:6],k[1:0],i[3:0]};
				#50;
				if (memInTest != freq_prev_data[(k*10)+i])
					$display($time, " ERROR: freq_prev[%d] = %x, expected = %x", (k*10)+i, memInTest, freq_prev_data[(k*10)+i]);
				else if (memInTest == freq_prev_data[(k*10)+i])
					$display($time, " CORRECT:  freq_prev[%d] = %x", (k*10)+i, memInTest);
				@(posedge clk);
		
			end//i loop
			#50;
		end//k loop
		
	for(i=0; i<10; i=i+1)
		begin				
			memReadAddrTest = {PREV_LSP[11:4],i[3:0]};
			#50;
			if (memInTest != prev_lsp_data[i])
				$display($time, " ERROR: prev_lsp[%d] = %x, expected = %x", i, memInTest, prev_lsp_data[i]);
			else if (memInTest == prev_lsp_data[i])
				$display($time, " CORRECT:  prev_lsp[%d] = %x", i, memInTest);
			@(posedge clk);
		end//i loop
		
	
	end//initial
     
initial forever #10 clk = ~clk;	 	

endmodule
