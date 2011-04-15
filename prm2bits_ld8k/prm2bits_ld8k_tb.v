`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:39:44 04/14/2011
// Design Name:   prm2bits_ld8k_pipe
// Module Name:   C:/Users/Sean/Documents/MSU Files/Senior Design/prm2bits/prm2bits_ld8k_tb.v
// Project Name:  prm2bits
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: prm2bits_ld8k_pipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module prm2bits_ld8k_tb;

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
	prm2bits_ld8k_pipe uut (
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.done(done), 
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

	reg [31:0] prm_in [0:4999];
	reg [31:0] serial_out [0:4999];

	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("prm2bits_prm_in.out", prm_in);
		$readmemh("prm2bits_serial_out.out", serial_out);
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
			for(i=0;i<11;i=i+1)
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
				test_write_addr = {PRM[11:4],i[3:0]};
				test_write = prm_in[11*j+i];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
			end
			
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
			for (i = 0; i<82;i=i+1)
			begin		
					
					@(posedge clock);
					@(posedge clock);
					@(posedge clock) #5;
					test_read_addr = {SERIAL[11:7],i[6:0]};
					@(posedge clock);
					@(posedge clock) #5;
					if (scratch_mem_in != serial_out[j*82+i])
						$display($time, " ERROR: serial[%d] = %x, expected = %x", i, scratch_mem_in, serial_out[j*82+i]);
					else if (scratch_mem_in == serial_out[j*82+i])
						$display($time, " CORRECT:  serial[%d] = %x", i, scratch_mem_in);
					@(posedge clock);
			end
		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule

