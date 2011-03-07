`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:45:12 02/28/2011
// Design Name:   lsp_lsf_pipe
// Module Name:   C:/Users/Sean/Documents/MSU Files/Senior Design/INT_LPC/lsp_lsf_tb.v
// Project Name:  INT_LPC
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: lsp_lsf_pipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module lsp_lsf_tb;

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
	reg [10:0] lsf_addr;
	reg [10:0] test_write_addr;
	reg [10:0] test_read_addr;
	reg [31:0] test_write;
	reg test_write_en;

	// Outputs
	wire done;
	wire [31:0] scratch_mem_in;

	// Instantiate the Unit Under Test (UUT)
	lsp_lsf_pipe lsp_lsf_pipe(
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.mem_Mux1Sel(mem_Mux1Sel), 
		.mem_Mux2Sel(mem_Mux2Sel), 
		.mem_Mux3Sel(mem_Mux3Sel), 
		.mem_Mux4Sel(mem_Mux4Sel), 
		.lsf_addr(lsf_addr), 
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
		$readmemh("lsp_lsf_lsp_in.out", lsp_in);
		$readmemh("lsp_lsf_lsf_out.out", lsf_out);
	end

	reg [32:0] lsp_in [0:4999];
	reg [32:0] lsf_out [0:4999];
	
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
				test_write_addr = {INT_LPC_LSP_TEMP[10:4],i[3:0]};
				test_write = lsp_in[10*j+i];
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
			lsf_addr = INTERPOLATION_LSF_INT;
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
					test_read_addr = {INTERPOLATION_LSF_INT[10:4],i[3:0]};
					@(posedge clock);
					@(posedge clock) #5;
					if (scratch_mem_in != lsf_out[j*10+i])
						$display($time, " ERROR: f[%d] = %x, expected = %x", i, scratch_mem_in, lsf_out[j*10+i]);
					else if (scratch_mem_in == lsf_out[j*10+i])
						$display($time, " CORRECT:  f[%d] = %x", i, scratch_mem_in);
					@(posedge clock);
			end	
			
		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule

