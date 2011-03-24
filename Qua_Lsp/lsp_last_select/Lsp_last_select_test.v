`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:44:20 02/19/2011 
// Design Name: 
// Module Name:    Lsp_last_select_test 
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
module Lsp_last_select_test;
`include "paramList.v"

	reg start;
	reg clk;
	reg reset;
	reg [11:0] L_tdist;
	
	wire done;
	wire [31:0] readIn;
	wire [11:0] readAddr;
	wire [11:0] writeAddr;
	wire [31:0] writeOut;	
	integer i, j;

	reg Mux0Sel;
	reg [11:0] testReadRequested;
	reg Mux1Sel;
	reg [11:0] testWriteRequested;
	reg Mux2Sel;
	reg [31:0] testWriteOut;
	reg Mux3Sel;
	reg testWrite;
	
	//I/O regs
	reg [31:0] L_tdistc [0:999];
	reg [15:0] mode_indexc [0:999];
	
		//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("LSP_LAST_SELECT_L_TDIST_IN.out", L_tdistc);
			$readmemh("LSP_LAST_SELECT_MODE_INDEX_OUT.out", mode_indexc);
		end
	
		Lsp_last_select_pipe i_pipe(
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
		.L_tdist(L_tdist)
		);
		
		initial begin
		// Initialize Inputs
		start = 0;
		clk = 0;
		reset = 0;
		L_tdist = 12'd288;
		
		@(posedge clk);
		@(posedge clk);
		reset = 1;
		// Wait 50 ns for global reset to finish
		@(posedge clk);
		@(posedge clk);
		reset = 0;
		
		for(j=0;j<60;j=j+1)
		begin
			//TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 
			Mux0Sel = 1;
			Mux1Sel = 0;
			Mux2Sel = 0;
			Mux3Sel = 0;
			testWrite = 0;
			
			for(i=0;i<2;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk);
				testWriteRequested = {L_tdist[11:1],i[0]};
				testWriteOut = L_tdistc[2*j+i];
				testWrite = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk);				
			end
			
			Mux1Sel = 1;
			Mux2Sel = 1;
			Mux3Sel = 1;		
	
			@(posedge clk);
			@(posedge clk);		
			start = 1;
			@(posedge clk);
			start = 0;
			// Add stimulus here	
			wait(done);
			Mux0Sel = 0;
			

			
			
					testReadRequested = QUA_LSP_MODE_INDEX;
					@(posedge clk);
					@(posedge clk);
					if (readIn != mode_indexc[j])
						$display($time, " ERROR: mode_indexc[%d] = %x, expected = %x", j, readIn, mode_indexc[j]);
					else if (readIn == mode_indexc[j])
						$display($time, " CORRECT:  mode_indexc[%d] = %x", j, readIn);
					@(posedge clk);
		
				
			end
	end
      initial forever #10 clk = ~clk;	     
	
	
endmodule
