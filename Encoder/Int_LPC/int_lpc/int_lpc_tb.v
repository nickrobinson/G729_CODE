`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:   19:42:25 03/09/2011
//	Module Name:   int_lpc_tb
// Project Name:  ITU G.729 Hardware Implementation
// Target Device: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions: Xilinx ISE 12.4
// Description:   This module tests the int_lpc module
//
// Dependencies:  int_lpc_pipe.v
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Updated to support 12 bit scratch memory address wires
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module int_lpc_tb;

	`include "constants_param_list.v"
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
	reg [31:0] test_write;
	reg test_write_en;

	// Outputs
	wire done;
	wire [31:0] scratch_mem_in;

	// Instantiate the Unit Under Test (UUT)
	int_lpc_pipe int_lpc_pipe_uut(
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.mem_Mux1Sel(mem_Mux1Sel), 
		.mem_Mux2Sel(mem_Mux2Sel), 
		.mem_Mux3Sel(mem_Mux3Sel), 
		.mem_Mux4Sel(mem_Mux4Sel), 
		.test_write_addr(test_write_addr), 
		.test_read_addr(test_read_addr), 
		.test_write(test_write), 
		.test_write_en(test_write_en), 
		.done(done), 
		.scratch_mem_in(scratch_mem_in)
	);
	
	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("int_lpc_lsp_old_in.out", int_lpc_lsp_old_in);
		$readmemh("int_lpc_lsp_new_in.out", int_lpc_lsp_new_in);
		$readmemh("int_lpc_lsf_int_out.out", int_lpc_lsf_int_out);
		$readmemh("int_lpc_lsf_new_out.out", int_lpc_lsf_new_out);
		$readmemh("int_lpc_A_t_out.out", int_lpc_A_t_out);
	end

	reg [32:0] int_lpc_lsp_old_in [0:4999];
	reg [32:0] int_lpc_lsp_new_in [0:4999];
	reg [32:0] int_lpc_lsf_int_out [0:4999];
	reg [32:0] int_lpc_lsf_new_out [0:4999];
	reg [32:0] int_lpc_A_t_out [0:4999];
	
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
			for(i=0;i<10;i=i+1)
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
				test_write_addr = {LSP_OLD[11:4],i[3:0]};
				test_write = int_lpc_lsp_old_in[10*j+i];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
			end
			
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			for(i=0;i<10;i=i+1)
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
				test_write_addr = {LSP_NEW[11:4],i[3:0]};
				test_write = int_lpc_lsp_new_in[10*j+i];
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
			//gamma1 read
			
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			for (i = 0; i<10;i=i+1)
			begin		
					
					@(posedge clock);
					@(posedge clock);
					@(posedge clock) #5;
					test_read_addr = {INTERPOLATION_LSF_INT[11:4],i[3:0]};
					@(posedge clock);
					@(posedge clock) #5;
					if (scratch_mem_in != int_lpc_lsf_int_out[j*10+i])
						$display($time, " ERROR: lsf_int[%d] = %x, expected = %x", i, scratch_mem_in, int_lpc_lsf_int_out[j*10+i]);
					else if (scratch_mem_in == int_lpc_lsf_int_out[j*10+i])
						$display($time, " CORRECT:  lsf_int[%d] = %x", i, scratch_mem_in);
					@(posedge clock);
			end
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			for (i = 0; i<10;i=i+1)
			begin		
					
					@(posedge clock);
					@(posedge clock);
					@(posedge clock) #5;
					test_read_addr = {INTERPOLATION_LSF_NEW[11:4],i[3:0]};
					@(posedge clock);
					@(posedge clock) #5;
					if (scratch_mem_in != int_lpc_lsf_new_out[j*10+i])
						$display($time, " ERROR: lsf_new[%d] = %x, expected = %x", i, scratch_mem_in, int_lpc_lsf_new_out[j*10+i]);
					else if (scratch_mem_in == int_lpc_lsf_new_out[j*10+i])
						$display($time, " CORRECT:  lsf_new[%d] = %x", i, scratch_mem_in);
					@(posedge clock);
			end
			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;
			for (i = 0; i<10;i=i+1)
			begin		
					
					@(posedge clock);
					@(posedge clock);
					@(posedge clock) #5;
					test_read_addr = {A_T_LOW[11:4],i[3:0]};
					@(posedge clock);
					@(posedge clock) #5;
					if (scratch_mem_in != int_lpc_A_t_out[j*10+i])
						$display($time, " ERROR: A_t[%d] = %x, expected = %x", i, scratch_mem_in, int_lpc_A_t_out[j*10+i]);
					else if (scratch_mem_in == int_lpc_A_t_out[j*10+i])
						$display($time, " CORRECT:  A_t[%d] = %x", i, scratch_mem_in);
					@(posedge clock);
			end
		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule