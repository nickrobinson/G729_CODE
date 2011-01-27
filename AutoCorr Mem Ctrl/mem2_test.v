`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    10:20:50 10/07/2010
// Module Name:    mem2_test
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A test bench to test a "scratch pad" memory controller
//						 					 
//	Verilog Test Fixture created by ISE for module: LPC_Mem_Ctrl_2			
//
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module mem2_test_v;

	// Inputs
	reg clock;
	reg reset;
	reg In_Write;
	reg [7:0] In_Count;
	reg [15:0] In_Sample;
	reg [7:0] Out_Count;

	// Outputs
	wire [15:0] Out_Sample;
	
	integer i;
	reg [15:0] samplesmem [0:999];
	
	initial 
	begin
		// samples out are samples from ITU G.729 test vectors
		$readmemh("samples1000.out", samplesmem);
   end

	// Instantiate the Unit Under Test (UUT)
	LPC_Mem_Ctrl_2 uut (
		.clock(clock), 
		.reset(reset), 
		.In_Write(In_Write), 
		.In_Count(In_Count), 
		.In_Sample(In_Sample), 
		.Out_Count(Out_Count), 
		.Out_Sample(Out_Sample)
	);

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		In_Write = 0;
		In_Count = 0;
		In_Sample = 0;
		Out_Count = 0;

		// Wait 100 ns for global reset to finish
	#100;
		
		reset = 1;
		
		#50;
		
		reset = 0;
		
		#50;
		
		for (i=0;i<240;i=i+1)
			begin
			  @(posedge clock);			 
			  In_Sample = samplesmem[i];
			  In_Write = 1;
			  In_Count = i;
			  #50;
			  In_Write = 0;
			  #50;
			end
			
		for (i=0;i<240;i=i+1)
			begin
			  @(posedge clock);
			  Out_Count = i;		  
			end
	
        
		// Add stimulus here

	end
initial forever #10 clock = ~clock;      
endmodule
