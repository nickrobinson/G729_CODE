`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
//
// Create Date:   00:10:22 03/29/2011
// Module Name:   Gain_predict_tb
// Project Name:  ITU G.729 Hardware Implementation
// Target Device: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions: Xilinx ISE 12.4
// Description: 	This module tests the Gain_predict module.
//
// Dependencies:  Gain_predict_pipe.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Gain_predict_tb;


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
	wire [15:0] cand1,cand2;
	wire [31:0] scratch_mem_in;

	// Instantiate the Unit Under Test (UUT)
	Gain_predict_pipe uut (
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
		.exp_gcode0(exp_gcode0)
	);

	reg [32:0] past_qua_en_in [0:4999];
	reg [32:0] code_in [0:4999];
	reg [32:0] gcode0_out [0:4999];
	reg [32:0] exp_gcode0_out [0:4999];

	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("gain_predict_past_qua_en_in.out",past_qua_en_in);
		$readmemh("gain_predict_code_in.out", code_in);
		$readmemh("gain_predict_gcode0_out.out", gcode0_out);
		$readmemh("gain_predict_exp_gcode0_out.out", exp_gcode0_out);
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
			for(i=0;i<40;i=i+1)
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
				test_write_addr = {CODE[11:6],i[5:0]};
				test_write = code_in[40*j+i];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
			end
			
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			for(i=0;i<4;i=i+1)
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
				test_write_addr = {PAST_QUA_EN[11:2],i[1:0]};
				test_write = past_qua_en_in[4*j+i];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
			end
			
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
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
					if (gcode0 != gcode0_out[j])
						$display($time, " ERROR: gcode0[%d] = %x, expected = %x", j, gcode0, gcode0_out[j]);
					else if (gcode0 == gcode0_out[j])
						$display($time, " CORRECT:  gcode0[%d] = %x", j, gcode0);
					@(posedge clock);

			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
		
					
					@(posedge clock);
					@(posedge clock);
					@(posedge clock) #5;
					if (exp_gcode0 != exp_gcode0_out[j])
						$display($time, " ERROR: exp_gcode0[%d] = %x, expected = %x", j, exp_gcode0, exp_gcode0_out[j]);
					else if (exp_gcode0 == exp_gcode0_out[j])
						$display($time, " CORRECT:  exp_gcode0[%d] = %x", j, exp_gcode0);
					@(posedge clock);

			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;

		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule
