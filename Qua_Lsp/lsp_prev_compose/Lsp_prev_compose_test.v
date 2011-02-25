`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:48:31 02/08/2011 
// Design Name: 
// Module Name:    Lsp_prev_compose_test 
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
module Lsp_prev_compose_test;
`include "paramList.v"
`include "constants_param_list.v"

	reg start;
	reg clk;
	reg reset;
	reg [10:0] lspele;
	reg [11:0] fg;
	reg [11:0] fg_sum;
	reg [10:0] freq_prev;
	reg [10:0] lsp;
	
	//Outputs
	wire done;
	wire [31:0] readIn;
	
	integer i, j;

	reg Mux0Sel;
	reg [10:0] testReadRequested;
	reg Mux1Sel;
	reg [10:0] testWriteRequested;
	reg Mux2Sel;
	reg [31:0] testWriteOut;
	reg Mux3Sel;
	reg testWrite;


	//I/O regs
	reg [15:0] lspelec [0:9999];
	reg mode_index [0:9999];
	reg [15:0] freq_prevc [0:9999];
	reg [15:0] lspc [0:9999];
	
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("LSP_PREV_COMP_LSP_ELE_IN.out", lspelec);
			$readmemh("mode_index.out", mode_index);			
			$readmemh("LSP_PREV_COMP_FREQ_PREV_IN.out", freq_prevc);
			$readmemh("LSP_PREV_COMP_LSP_OUT.out", lspc);
		end
	
	
	// Instantiate the Unit Under Test (UUT)
	Lsp_prev_compose_top uut (
		.start(start), 
		.clk(clk), 
		.done(done), 
		.reset(reset), 
		.lspele(lspele), 
		.fg(fg), 
		.fg_sum(fg_sum),
		.freq_prev(freq_prev),
		.lsp(lsp),
		.testReadRequested(testReadRequested),
		.testWriteRequested(testWriteRequested), 
		.testWriteOut(testWriteOut),
		.testWrite(testWrite),
		.Mux0Sel(Mux0Sel),
		.Mux1Sel(Mux1Sel), 
		.Mux2Sel(Mux2Sel), 
		.Mux3Sel(Mux3Sel),
		.readIn(readIn)
		);	
	
		initial begin
		// Initialize Inputs
		start = 0;
		clk = 0;
		reset = 0;
		lspele = 11'd288;		
		freq_prev = 11'd320;		
		lsp = 11'd448;
		
		#50
		reset = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 0;
		
		for(j=0;j<60;j=j+1)
		begin
			fg_sum = FG_SUM + (mode_index[j]*16);
			fg = FG + (mode_index[j]*64);
			//TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 
			Mux0Sel = 1;
			Mux1Sel = 0;
			Mux2Sel = 0;
			Mux3Sel = 0;
			testWrite = 0;
			
			for(i=0;i<10;i=i+1)
			begin
				#100;
				testWriteRequested = {lspele[10:4],i[3:0]};
				testWriteOut = lspelec[10*j+i];
				testWrite = 1;	
				#100;			

			end
			
			for(i=0;i<64;i=i+1)
			begin
				#100;
				testWriteRequested = {freq_prev[10:6], i[5:0]};
				testWriteOut = freq_prevc[64*j+i];
				testWrite = 1;	
				#100;
			end
			
			Mux1Sel = 1;
			Mux2Sel = 1;
			Mux3Sel = 1;		
	
			#50;		
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here	
			wait(done);
			Mux0Sel = 0;
			

			
			//ap read
			for (i = 0; i<10;i=i+1)
			begin				
					testReadRequested = {lsp[10:4],i[3:0]};
					@(posedge clk);
					@(posedge clk);
					if (readIn != lspc[j*10+i])
						$display($time, " ERROR: lspc[%d] = %x, expected = %x", j*10+i, readIn, lspc[j*10+i]);
					else if (readIn == lspc[j*10+i])
						$display($time, " CORRECT:  lspc[%d] = %x", j*10+i, readIn);
					@(posedge clk);
			end	
				
		end//j for loop
			
	end
      initial forever #10 clk = ~clk;	       
	
endmodule
