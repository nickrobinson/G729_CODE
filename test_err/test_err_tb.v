`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
//
// Create Date:   23:50:58 04/13/2011
// Module Name:   test_err_tb
// Project Name:  ITU G.729 Hardware Implementation
// Target Device: Virtex 5 - XC5VLX110T
// Tool versions: Xilinx ISE 12.4
// Description: 
//
// Dependencies:  test_err_pipe.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_err_tb;

	`include "paramList.v"

	// Inputs
	reg clock;
	reg reset;
	reg start;
	reg [15:0] T0;
	reg [15:0] T0_frac;
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

	// Instantiate the Unit Under Test (UUT)
	test_err_pipe uut (
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.done(done), 
		.out(out), 
		.T0(T0), 
		.T0_frac(T0_frac), 
		.mem_Mux1Sel(mem_Mux1Sel), 
		.mem_Mux2Sel(mem_Mux2Sel), 
		.mem_Mux3Sel(mem_Mux3Sel), 
		.mem_Mux4Sel(mem_Mux4Sel), 
		.test_write_addr(test_write_addr), 
		.test_read_addr(test_read_addr), 
		.test_write(test_write), 
		.test_write_en(test_write_en)
	);

	reg [31:0] T0_in [0:4999];
	reg [31:0] T0_frac_in [0:4999];
	reg [31:0] L_exc_err_in [0:4999];
	reg [31:0] flag_out [0:4999];

	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("test_err_t0_in.out", T0_in);
		$readmemh("test_err_t0_frac_in.out", T0_frac_in);
		$readmemh("test_err_L_exc_err_in.out", L_exc_err_in);
		$readmemh("test_err_flag_out.out", flag_out);
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
	
		
		@(posedge clock) #5;
		for(j=0;j<256;j=j+1)
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
				test_write_addr = {L_EXC_ERR[11:2],i[1:0]};
				test_write = L_exc_err_in[4*j+i];
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
			T0 = T0_in[j];
			T0_frac = T0_frac_in[j];
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
			if (out != flag_out[j])
				$display($time, " ERROR: out[%d] = %x, expected = %x", j, out, flag_out[j]);
			else if (out == flag_out[j])
				$display($time, " CORRECT:  out[%d] = %x", j, out);
			@(posedge clock);

			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;

		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule
