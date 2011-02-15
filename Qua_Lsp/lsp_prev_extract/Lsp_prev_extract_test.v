`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:25:47 02/14/2011 
// Design Name: 
// Module Name:    Lsp_prev_extract_test 
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
module Lsp_prev_extract_test;
`include "paramList.v"

	reg start;
	reg clk;
	reg reset;
	reg [10:0] lspele;
	reg [10:0] fg;
	reg [10:0] fg_sum_inv;
	reg [10:0] freq_prev;
	reg [10:0] lsp;
	
	//Outputs
	wire done;
	wire [31:0] readIn;
	wire [10:0] readAddr;
	wire [10:0] writeAddr;
	wire [31:0] writeOut;	
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
	reg [15:0] lspelec [0:40000];
	reg [15:0] fgc [0:40000];
	reg [15:0] fg_sum_invc [0:4000];
	reg [15:0] freq_prevc [0:40000];
	reg [15:0] lspc [0:4000];

	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("LSP_PREV_EXTRACT_LSP_IN.out", lspc);
			$readmemh("LSP_PREV_EXTRACT_FG_IN.out", fgc);
			$readmemh("LSP_PREV_EXTRACT_FG_SUM_INV_IN.out", fg_sum_invc);
			$readmemh("LSP_PREV_EXTRACT_FREQ_PREV_IN.out", freq_prevc);
			$readmemh("LSP_PREV_EXTRACT_LSP_ELE_OUT.out", lspelec);
		end
	
	Lsp_prev_extract_pipe i_pipe(
		.start(start),
		.clk(clk), 
		.reset(reset), 
		.done(done),
		.Mux0Sel(Mux0Sel), 
		.Mux1Sel(Mux1Sel), 
		.Mux2Sel(Mux2Sel), 
		.Mux3Sel(Mux3Sel), 
		.readAddr(readAddr), 
		.writeAddr(writeAddr), 
		.writeOut(writeOut), 
		.writeEn(writeEn), 
		.testReadRequested(testReadRequested), 
		.testWriteRequested(testWriteRequested), 
		.testWriteOut(testWriteOut), 
		.testWrite(testWrite), 
		.readIn(readIn),
		.lspele(lspele),
		.fg(fg),
		.fg_sum_inv(fg_sum_inv),
		.freq_prev(freq_prev),
		.lsp(lsp)
		);
	
		initial begin
		// Initialize Inputs
		start = 0;
		clk = 0;
		reset = 0;
		lspele = 11'd288;
		fg = 11'd384;
		freq_prev = 11'd320;
		fg_sum_inv = 11'd304;
		lsp = 11'd448;
		
		#50
		reset = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 0;
		
		for(j=0;j<60;j=j+1)
		begin
			//TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 
			Mux0Sel = 1;
			Mux1Sel = 0;
			Mux2Sel = 0;
			Mux3Sel = 0;
			testWrite = 0;
			
			for(i=0;i<10;i=i+1)
			begin
				#100;
				testWriteRequested = {lsp[10:4],i[3:0]};
				testWriteOut = lspc[10*j+i];
				testWrite = 1;	
				#100;			

			
				#100;
				testWriteRequested = {fg_sum_inv[10:4], i[3:0]};
				testWriteOut = fg_sum_invc[10*j+i];
				testWrite = 1;	
				#100;
			end
			
			for(i=0;i<40;i=i+1)
			begin
				#100;
				testWriteRequested = {fg[10:6],i[5:0]};
				testWriteOut = fgc[40*j+i];
				testWrite = 1;	
				#100;			

			
				#100;
				testWriteRequested = {freq_prev[10:6], i[5:0]};
				testWriteOut = freq_prevc[40*j+i];
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
					testReadRequested = {lspele[10:4],i[3:0]};
					@(posedge clk);
					@(posedge clk);
					if (readIn != lspelec[j*10+i])
						$display($time, " ERROR: lspelec[%d] = %x, expected = %x", j*11+i, readIn, lspelec[j*10+i]);
					else if (readIn == lspelec[j*10+i])
						$display($time, " CORRECT:  lspelec[%d] = %x", j*11+i, readIn);
					@(posedge clk);
			end	
				
		end//j for loop
			
	end
      initial forever #10 clk = ~clk;	       
	
endmodule

