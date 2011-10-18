`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:26:54 10/03/2010
// Design Name:   LPC_Mem_Ctrl
// Module Name:   C:/Xilinx92i/Auto_Corr/LPC_Mem_Ctrl_tb.v
// Project Name:  Auto_Corr
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: LPC_Mem_Ctrl
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module LPC_Mem_Ctrl_tb_v;

	// Inputs
	reg clock;
	reg reset;
	reg In_Done;
	reg [15:0] In_Sample;
	reg [7:0] Out_Count;

	// Outputs
	wire [15:0] Out_Sample;
	wire frame_done;
	

	  // filtered results memory
	  // these filtered results come from the 
	  // ITU G.729 fixed point ANSI Cimplementation
	  reg [15:0] filteredmem [0:999];

  integer i;
  integer j;
  integer k;
  
  

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
			// filter results from ITU G.729 ANSI fixed point implementation
			$readmemh("filtered.out", filteredmem);
   end
	
	initial begin
		#200;
		Out_Count = 0;
		j = 0;
		for (k=0;k<1000;k=k+1)begin			
			@(posedge clock);
			if(j == 239) begin
				Out_Count = j;
				j = 0;
			end
			else begin
				Out_Count = j;
				j = j+1;
			end
		end
	end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		In_Done = 0;
		In_Sample = 0;
		

		// Wait 100 ns for global reset to finish
		#100;
      reset = 1;
		#50 reset = 0;
		#50;
		
		// Add stimulus here
		
		
		
		
		for (i=0;i<1000;i=i+1) begin
			
			  @(posedge clock);
			  #50 In_Done = 1;
			  In_Sample = filteredmem[i];
			  @(posedge clock);
			  In_Done = 0;
			  
//			  wait (done);
//			  @(posedge mclk);
//			  if (yn != filteredmem[i])
//				  $display($time, " ERROR: x[%d] = %x, y[%d] = %x, expected = %x", i, xn, i, yn, filteredmem[i]);
//			  else
//				  $display($time, " INFO:  x[%d] = %x, y[%d] = %x", i, xn, i, yn);	
		end
	end
	
	// 50 MHz clock - 10nS Hi, 10 nS low, ...
        initial forever #10 clock = ~clock;
      
endmodule

