`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:26:34 10/28/2010
// Module Name:    Az_LSP_Test
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: Az_toLSP_FSM
// Dependencies: 	 L_mac.v, L_msu.v,L_shl,L_sub,add,mult,norm_s
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Az_LSP_Test_v;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;	
	reg lspMuxSel;
	reg [10:0] testReadRequested;
	//mux1 regs
	reg [10:0] testWriteRequested;
	//mux2 regs
	reg [31:0] testLspOut;
	//mux3regs
	reg testLspWrite;
	
	//Outputs
   wire [31:0] lspIn;
	
	//working regs
	reg [15:0] aSubI_in [0:9999];
	reg [15:0] lspOutMem [0:9999];
	reg [10:0] temp;
	
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("lsp_az_lsp_in.out", aSubI_in);
		$readmemh("lsp_az_lsp_out.out", lspOutMem);
	end							 
	
	// Instantiate the Unit Under Test (UUT)	
   Az_LSP_Top uut(
						.clk(clk),
						.reset(reset),
						.start(start),
						.lspMuxSel(lspMuxSel),
						.testReadRequested(testReadRequested),
						.testWriteRequested(testWriteRequested),
						.testLspOut(testLspOut),
						.testLspWrite(testLspWrite),
						.done(done),
						.lspIn(lspIn)
						);
	initial begin
		// Initialize Input
		
		clk = 0;
		reset = 0;
		start = 0;
		testReadRequested = 0;	
		testWriteRequested = 0;	
	   testLspWrite = 0;
		lspMuxSel = 0;
		testLspOut = 0;

		#100;
		// Wait 100 ns for global reset to finish
		
		#50;
		reset = 1;
		#50;
		reset = 0;
		#50;
		
		for(j=0;j<120;j=j+1)
		begin
		
		//writing the previous modules to memory
			lspMuxSel = 0;
					
			for(i=0;i<11;i=i+1)
			begin
				#100;
				lspMuxSel = 1;
				#100					//Added Delay BY PARKER
				temp = A_T + 11'd11;
				testWriteRequested = {temp[10:4],i[3:0]};
				testLspOut = aSubI_in[j*11+i];
				testLspWrite = 1;	
				#100;
			end
			
			lspMuxSel = 0;
			 
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here		
		
			wait(done);
			#100;
			lspMuxSel = 1;
			for (i = 0; i<10;i=i+1)
			begin				
					testReadRequested = {LSP_NEW[10:4],i[3:0]};
					#50;
					if (lspIn != lspOutMem[10*j+i])
						$display($time, " ERROR: lsp[%d] = %x, expected = %x", 10*j+i, lspIn, lspOutMem[10*j+i]);
					else if (lspIn == lspOutMem[10*j+i])
						$display($time, " CORRECT:  lsp[%d] = %x", 10*j+i, lspIn);
					@(posedge clk);
	
				end
		end// for loop j

	end//initial
     
initial forever #10 clk = ~clk;	  
endmodule


