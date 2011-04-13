`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design 
// Engineer: Sean Owens
//
// Create Date:   23:06:55 03/31/2011
// Module Name:   Gbk_presel_tb
// Project Name:  ITU G.729 Hardware Implementation
// Target Device: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions: Xilinx ISE 12.4
// Description: 	This module tests the Gbk_presel module.
//
// Dependencies:	Gbk_presel_pipe.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Gbk_presel_tb;

	`include "paramList.v"
	
	// Inputs
	reg clock;
	reg reset;
	reg start;
	reg mem_Mux1Sel;
	reg mem_Mux2Sel;
	reg mem_Mux3Sel;
	reg mem_Mux4Sel;
	reg [11:0] test_write_addr;
	reg [11:0] test_read_addr;
	reg [15:0] gcode0;
	reg [31:0] test_write;
	reg test_write_en;

	// Outputs
	wire done;
	wire [31:0] scratch_mem_in;
	wire [15:0] cand1,cand2;

	// Instantiate the Unit Under Test (UUT)
	Gbk_presel_pipe i_Gbk_presel_pipe(
		.clock(clock),
		.reset(reset),
		.start(start),
		.done(done),
		.scratch_mem_in(scratch_mem_in),
		.mem_Mux1Sel(mem_Mux1Sel),
		.mem_Mux2Sel(mem_Mux2Sel),
		.mem_Mux3Sel(mem_Mux3Sel),
		.mem_Mux4Sel(mem_Mux4Sel),
		.test_write_addr(test_write_addr),
		.test_read_addr(test_read_addr),
		.test_write(test_write),
		.test_write_en(test_write_en),
		.gcode0(gcode0),
		.cand1(cand1),
		.cand2(cand2)
    );


	reg [15:0] best_gain_in [0:4999];
	reg [15:0] gcode0_in [0:4999];
	reg [15:0] cand1_out [0:4999];
	reg [15:0] cand2_out [0:4999];

	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("gbk_presel_best_gain_in.out",best_gain_in);
		$readmemh("gbk_presel_gcode0_in.out", gcode0_in);
		$readmemh("gbk_presel_cand1_out.out", cand1_out);
		$readmemh("gbk_presel_cand2_out.out", cand2_out);
	end
	
	integer i,j;

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		start = 0;

		@(posedge clock);
		@(posedge clock);
		@(posedge clock) #5;
		reset = 1;
		// Wait 50 ns for global reset to finish
		@(posedge clock);
		@(posedge clock);
		@(posedge clock) #5;
		reset = 0;
		
		@(posedge clock);
		@(posedge clock);
		@(posedge clock) #5;
		for(j=0;j<60;j=j+1)
		begin
			//TEST1
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			mem_Mux1Sel = 0;
			mem_Mux2Sel = 0;
			mem_Mux3Sel = 0;
			mem_Mux4Sel = 0;
			test_read_addr = 0;
			
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			for(i=0;i<2;i=i+1)
			begin
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				mem_Mux1Sel = 1;
				mem_Mux2Sel = 1;
				mem_Mux3Sel = 1;
				mem_Mux4Sel = 1;
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				test_write_addr = {BEST_GAIN[11:2],i[1:0]};
				test_write = best_gain_in[2*j+i];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
			end
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			gcode0 = gcode0_in[j];
			mem_Mux1Sel = 0;
			mem_Mux2Sel = 0;
			mem_Mux3Sel = 0;
			mem_Mux4Sel = 0;
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;		
			start = 1;
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			start = 0;
			// Add stimulus here	
			wait(done);
			
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			mem_Mux4Sel = 1;
			
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			
					
					@(posedge clock);
					@(posedge clock);
					@(posedge clock) #5;
					if (cand1 != cand1_out[j])
						$display($time, " ERROR: cand1[%d] = %x, expected = %x", j, cand1, cand1_out[j]);
					else if (cand1 == cand1_out[j])
						$display($time, " CORRECT:  cand1[%d] = %x", j, cand1);
					@(posedge clock);

			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
		
					
					@(posedge clock);
					@(posedge clock);
					@(posedge clock) #5;
					if (cand2 != cand2_out[j])
						$display($time, " ERROR: cand2[%d] = %x, expected = %x", j, cand2, cand2_out[j]);
					else if (cand2 == cand2_out[j])
						$display($time, " CORRECT:  cand2[%d] = %x", j, cand2);
					@(posedge clock);

			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;

		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
		
endmodule 
