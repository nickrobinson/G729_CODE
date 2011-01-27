`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    17:30:58 10/06/2010
// Module Name:    mem_test
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A test bench to test the memory controller that saves in memory the output 
//						 of the preprocessor and gives this to the autocorellation as requeseted. 
//						 					 
//	Verilog Test Fixture created by ISE for module: LPC_Mem_Ctrl			
//
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module mem_test_v;

	// Inputs
	reg clock;
	reg reset;
	reg In_Done;
	reg [15:0] In_Sample;
	reg [7:0] Out_Count;

	// Outputs
	wire [15:0] Out_Sample;
	wire frame_done;
	
	integer i;
	integer j;
	reg [15:0] samplesmem [0:999];
	
	initial 
	begin
		// samples out are samples from ITU G.729 test vectors
		$readmemh("autocorr_in.out", samplesmem);
   end

	// Instantiate the Unit Under Test (UUT)
	LPC_Mem_Ctrl uut (
		.clock(clock), 
		.reset(reset), 
		.In_Done(In_Done), 
		.In_Sample(In_Sample), 
		.Out_Count(Out_Count), 
		.Out_Sample(Out_Sample), 
		.frame_done(frame_done)
	);

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		In_Done = 0;
		In_Sample = 0;
		Out_Count = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		reset = 1;
		
		#50;
		
		reset = 0;
		
		#50;
		
		for (i=0;i<80;i=i+1)
			begin
			  @(posedge clock);
			  In_Done = 1;
			  In_Sample = samplesmem[i];
			  @(posedge clock);
			  In_Done = 0;
			end
			
		for (j=0;j<80;j=j+1)
			begin			  
			  @(posedge clock);
			  Out_Count = j;				
			end
	
        
		// Add stimulus here

	end
initial forever #10 clock = ~clock;      
endmodule

