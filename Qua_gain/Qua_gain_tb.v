`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:   10:40:01 04/11/2011
// Module Name:   Qua_gain_tb
// Project Name:  ITU G.729 Hardware Implementation
// Target Device: Virtex 5 - XC5VLX110T
// Tool versions: Xilinx ISE 12.4
// Description: 
//
// Dependencies:	Qua_gain_pipe.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Qua_gain_tb;

	`include "paramList.v"
	`include "constants_param_list.v"

	// Inputs
	reg clock;
	reg reset;
	reg start;
	reg tame_flag;
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
	Qua_gain_pipe uut (
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.done(done), 
		.out(out), 
		.tame_flag(tame_flag), 
		.scratch_mem_in(scratch_mem_in), 
		.mem_Mux1Sel(mem_Mux1Sel), 
		.mem_Mux2Sel(mem_Mux2Sel), 
		.mem_Mux3Sel(mem_Mux3Sel), 
		.mem_Mux4Sel(mem_Mux4Sel), 
		.test_write_addr(test_write_addr), 
		.test_read_addr(test_read_addr), 
		.test_write(test_write), 
		.test_write_en(test_write_en)
	);

	reg [31:0] code_in [0:4999];
	reg [31:0] g_coeff_cs_in [0:4999];
	reg [31:0] exp_g_coeff_cs_in [0:4999];
	reg [31:0] tame_flag_in [0:4999];
	reg [31:0] gain_pit_out [0:4999];
	reg [31:0] gain_code_out [0:4999];
	reg [31:0] qua_gain_out_out [0:4999];

	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("qua_gain_code_in.out", code_in);
		$readmemh("qua_gain_g_coeff_cs_in.out", g_coeff_cs_in);
		$readmemh("qua_gain_exp_g_coeff_cs_in.out", exp_g_coeff_cs_in);
		$readmemh("qua_gain_tame_flag_in.out", tame_flag_in);
		$readmemh("qua_gain_gain_pit_out.out", gain_pit_out);
		$readmemh("qua_gain_gain_code_out.out", gain_code_out);
		$readmemh("qua_gain_out.out", qua_gain_out_out);
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
				test_write = 32'hffff_c800;
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
		end
		
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
			
			for(i=0;i<5;i=i+1)
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
				test_write_addr = {G_COEFF_CS[11:3],i[2:0]};
				test_write = g_coeff_cs_in[5*j+i];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
			end
			
			for(i=0;i<5;i=i+1)
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
				test_write_addr = {EXP_G_COEFF_CS[11:3],i[2:0]};
				test_write = exp_g_coeff_cs_in[5*j+i];
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
			tame_flag = tame_flag_in[j];
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
			if (out != qua_gain_out_out[j])
				$display($time, " ERROR: out[%d] = %x, expected = %x", j, out, qua_gain_out_out[j]);
			else if (out == qua_gain_out_out[j])
				$display($time, " CORRECT:  out[%d] = %x", j, out);
			@(posedge clock);

			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			
			//Check gain_pit outputs
					test_read_addr = GAIN_PIT;
					#50;
					if (scratch_mem_in != gain_pit_out[j])
						$display($time, " ERROR: gain_pit[%d] = %x, expected = %x", j, scratch_mem_in, gain_pit_out[j]);
					else if (scratch_mem_in == gain_pit_out[j])
						$display($time, " CORRECT:  gain_pit[%d] = %x", j, scratch_mem_in);
					@(posedge clock);
					
			//Check gain_code outputs
					test_read_addr = GAIN_CODE;
					#50;
					if (scratch_mem_in != gain_code_out[j])
						$display($time, " ERROR: gain_code[%d] = %x, expected = %x", j, scratch_mem_in, gain_code_out[j]);
					else if (scratch_mem_in == gain_code_out[j])
						$display($time, " CORRECT:  gain_code[%d] = %x", j, scratch_mem_in);
					@(posedge clock);

			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;

		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule