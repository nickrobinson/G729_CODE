`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Nick Robinson
// 
// Create Date:    22:00:07 02/01/2011
// Module Name:    Get_wegt.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: Lsp_Expand_2
// 
// Dependencies: 	 Lsp_Expand_2.v, Scratch_Memory_Controller.v, L_sub.v, L_add.v, sub.v, shr.v, add.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Get_wegt_test;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [11:0] flspAddr;
	reg [11:0] wegtAddr;

	// Outputs	
	wire [31:0] memIn;
	wire done;
	
	//working regs
	reg [15:0] flspMem [0:9999];
	reg [15:0] wegtMem [0:9999];

	
	//Mux0 regs	
	reg getWegtMuxSel;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	integer i,j;
	
		//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("input_flsp.out", flspMem);
		$readmemh("output_wegt.out", wegtMem);
	end
	
	
	
	// Instantiate the Unit Under Test (UUT)
	Get_wegt_pipe uut123(
								.clk(clk),
								.reset(reset),
								.start(start),
								.getWegtMuxSel(getWegtMuxSel),
								.testReadAddr(testReadAddr),
								.testWriteAddr(testWriteAddr),
								.testMemOut(testMemOut),
								.testMemWriteEn(testMemWriteEn),
								.memIn(memIn),
								.done(done),
								.flspAddr(flspAddr), 
								.wegtAddr(wegtAddr)
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
		getWegtMuxSel = 1;
		flspAddr = 11'd560;
		wegtAddr = 11'd624;
		// Wait 50 ns for global reset to finish
		@(posedge clk);
		@(posedge clk) #5;
		reset = 1;
		@(posedge clk);
		@(posedge clk) #5;
		reset = 0;
		@(posedge clk);
		@(posedge clk) #5;
		
		for(j=0;j<100;j=j+1)
		begin
		
		//writing the previous modules to memory		
			
			for(i=0;i<10;i=i+1)
			begin
				#100;
				testWriteAddr = {flspAddr[11:4],i[3:0]};
				testMemOut = flspMem[(j*10)+i];
				testMemWriteEn = 1;	
				#100;
			end
			
			getWegtMuxSel = 0;
				
			@(posedge clk);
			@(posedge clk) #5;
			start = 1;
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);
			@(posedge clk) #5;
			// Add stimulus here		
		
			wait(done);
			#100;
			getWegtMuxSel = 1;
			for (i = 0; i<10;i=i+1)
			begin				
					testReadAddr = {wegtAddr[11:4],i[3:0]};
					#50;
					if (memIn != wegtMem[(j*10)+i])
						$display($time, " ERROR: wegt[%d] = %x, expected = %x", (j*10)+i, memIn, wegtMem[(j*10)+i]);
					else if (memIn == wegtMem[(j*10)+i])
						$display($time, " CORRECT:  wegt[%d] = %x", (j*10)+i, memIn);
					@(posedge clk);
	
				end
		end// for loop j

	end//initial
     
initial forever #10 clk = ~clk;	  
endmodule