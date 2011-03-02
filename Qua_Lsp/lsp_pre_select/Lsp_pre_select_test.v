`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:30:41 02/26/2011 
// Design Name: 
// Module Name:    Lsp_pre_select_test 
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
module Lsp_pre_select_test;
`include "paramList.v"
`include "constants_param_list.v"

	reg start;
	reg clk;
	reg reset;
	reg [10:0] rbuf;

	//Outputs
	wire done;
	wire [31:0] readIn, const_in;
	wire [10:0] readAddr;
	wire [11:0] const_addr;
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
	reg [15:0] rbufc [0:4000];
	reg [15:0] candc [0:4000];
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("LSP_PRE_SELECT_RBUF_IN.out", rbufc);
			$readmemh("LSP_PRE_SELECT_CAND_OUT.out", candc);
		end
		
	Lsp_pre_select_pipe i_pipe(
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
		.const_addr(const_addr),
		.const_in(const_in),
		.rbuf(rbuf));
	
		initial begin
		// Initialize Inputs
		start = 0;
		clk = 0;
		reset = 0;
		rbuf = 11'd288;
		
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
				testWriteRequested = {rbuf[10:4],i[3:0]};
				testWriteOut = rbufc[10*j+i];
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
			

				
					testReadRequested = QUA_LSP_CAND;
					@(posedge clk);
					@(posedge clk);
					if (readIn != candc[j])
						$display($time, " ERROR: candc[%d] = %x, expected = %x", j, readIn, candc[j]);
					else if (readIn == candc[j])
						$display($time, " CORRECT:  candc[%d] = %x", j, readIn);
					@(posedge clk);	
				
		end//j for loop
			
	end
      initial forever #10 clk = ~clk;	       
	
endmodule
