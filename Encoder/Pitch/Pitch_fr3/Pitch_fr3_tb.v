`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
//
// Create Date:   20:46:21 04/19/2011
// Module Name:   Pitch_fr3_tb
// Project Name:  ITU G.729 Hardware Implementation
// Target Device: Virtex 5 - XC5VLX110T
// Tool versions: Xilinx ISE 12.4
// Description: 
//
// Dependencies:	Pitch_fr3_pipe.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Pitch_fr3_tb;

	`include "constants_param_list.v"
	`include "paramList.v"

	// Inputs
	reg clock;
	reg start;
	reg reset;
	reg [15:0] i_subfr;
	reg [11:0] exc;
	reg mem_Mux1Sel;
	reg mem_Mux2Sel;
	reg mem_Mux3Sel;
	reg mem_Mux4Sel;
	reg [11:0] test_write_addr;
	reg [11:0] test_read_addr;
	reg [31:0] test_write;
	reg test_write_en;

	// Outputs
	wire done;
	wire [15:0] out;
	wire [31:0] scratch_mem_in;

	// Instantiate the Unit Under Test (UUT)
	Pitch_fr3_pipe uut (
		.clock(clock), 
		.start(start), 
		.reset(reset), 
		.i_subfr(i_subfr), 
		.exc(exc), 
		.done(done), 
		.out(out), 
		.mem_Mux1Sel(mem_Mux1Sel), 
		.mem_Mux2Sel(mem_Mux2Sel), 
		.mem_Mux3Sel(mem_Mux3Sel), 
		.mem_Mux4Sel(mem_Mux4Sel), 
		.test_write_addr(test_write_addr), 
		.test_read_addr(test_read_addr), 
		.test_write(test_write), 
		.test_write_en(test_write_en), 
		.scratch_mem_in(scratch_mem_in)
	);
	
	reg [31:0] xn_in [0:4999];
	reg [31:0] h1_in [0:4999];
	reg [31:0] t0_min_in [0:4999];
	reg [31:0] t0_max_in [0:4999];
	reg [31:0] t0_frac_in [0:4999];
	reg [31:0] t0_frac_out [0:4999];
	reg [31:0] t0_out [0:4999];
	reg [31:0] i_subfr_in [0:4999];
	reg [31:0] exc_old_in [0:4999];

	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("pitch_fr3_xn_in.out", xn_in);
		$readmemh("pitch_fr3_h1_in.out", h1_in);
		$readmemh("pitch_fr3_t0_min_in.out", t0_min_in);
		$readmemh("pitch_fr3_t0_max_in.out", t0_max_in);
		$readmemh("pitch_fr3_t0_frac_in.out", t0_frac_in);
		$readmemh("pitch_fr3_i_subfr_in.out", i_subfr_in);
		$readmemh("pitch_fr3_t0_out.out", t0_out);
		$readmemh("pitch_fr3_t0_frac_out.out", t0_frac_out);
		$readmemh("pitch_fr3_exc_old_in.out", exc_old_in);
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
			mem_Mux1Sel = 1;
			mem_Mux2Sel = 1;
			mem_Mux3Sel = 1;
			mem_Mux4Sel = 1;
			test_read_addr = 0;
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			
			for(i=0;i<234;i=i+1)
			begin
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;	
				test_write_addr = {OLD_EXC[11:8],i[7:0]};
				test_write = exc_old_in[j*234+i];								
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
			end
			
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
				test_write_addr = {XN[11:6],i[5:0]};
				test_write = xn_in[40*j+i];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
			end
			
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
				test_write_addr = {H1[11:6],i[5:0]};
				test_write = h1_in[40*j+i];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
			end
			
			
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
				test_write_addr = T0_MIN;
				test_write = t0_min_in[j];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				
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
				test_write_addr = T0_MAX;
				test_write = t0_max_in[j];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				
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
				test_write_addr = T0_FRAC;
				test_write = t0_frac_in[j];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				
			i_subfr = i_subfr_in[j];
			if(j%2 == 0)
				exc = 12'd3226;
			else
				exc = 12'd3266;
			
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			
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
			//gamma1 read
			
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
					@(posedge clock);
					@(posedge clock);
					@(posedge clock) #5;
					test_read_addr = T0_FRAC;
					@(posedge clock);
					@(posedge clock) #5;
					if (scratch_mem_in != t0_frac_out[j])
						$display($time, " ERROR: t0_frac[%d] = %x, expected = %x", j, scratch_mem_in, t0_frac_out[j]);
					else if (scratch_mem_in == t0_frac_out[j])
						$display($time, " CORRECT:  t0_frac[%d] = %x", j, scratch_mem_in);
					@(posedge clock);
		
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			if (out != t0_out[j])
						$display($time, " ERROR: t0[%d] = %x, expected = %x", j, out, t0_out[j]);
			else if (out == t0_out[j])
						$display($time, " CORRECT:  t0[%d] = %x", j, out);
			
		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule
