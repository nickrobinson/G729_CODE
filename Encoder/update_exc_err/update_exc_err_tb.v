`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:41:44 04/14/2011
// Design Name:   update_exc_err_pipe
// Module Name:   C:/Users/Sean/Documents/MSU Files/Senior Design/update_exc_err/update_exc_err_tb.v
// Project Name:  update_exc_err
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: update_exc_err_pipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module update_exc_err_tb;

	`include "constants_param_list.v"
	`include "paramList.v"

	// Inputs
	reg clock;
	reg reset,start;
	reg mem_Mux1Sel;
	reg mem_Mux2Sel;
	reg mem_Mux3Sel;
	reg mem_Mux4Sel;
	reg [11:0] test_write_addr;
	reg [11:0] test_read_addr;
	reg [31:0] test_write;
	reg test_write_en;
	reg [15:0] gain_pit;
	reg [15:0] T0;

	// Outputs
	wire done;
	wire [31:0] scratch_mem_in;

	// Instantiate the Unit Under Test (UUT)
	update_exc_err_pipe uut (
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
		.scratch_mem_in(scratch_mem_in), 
		.gain_pit(gain_pit), 
		.T0(T0)
	);

	reg [31:0] gain_pit_in [0:4999];
	reg [31:0] t0_in [0:4999];
	reg [31:0] L_exc_err_in [0:4999];
	reg [31:0] L_exc_err_out [0:4999];

	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("update_exc_err_gain_pit_in.out", gain_pit_in);
		$readmemh("update_exc_err_T0_in.out", t0_in);
		$readmemh("update_exc_err_L_exc_err_in.out", L_exc_err_in);
		$readmemh("update_exc_err_L_exc_err_out.out", L_exc_err_out);
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
			T0 = t0_in[j];
			gain_pit = gain_pit_in[j];
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
			for (i = 0; i<4;i=i+1)
			begin		
					
					@(posedge clock);
					@(posedge clock);
					@(posedge clock) #5;
					test_read_addr = {L_EXC_ERR[11:2],i[1:0]};
					@(posedge clock);
					@(posedge clock) #5;
					if (scratch_mem_in != L_exc_err_out[j*4+i])
						$display($time, " ERROR: L_exc_err[%d] = %x, expected = %x", i, scratch_mem_in, L_exc_err_out[j*4+i]);
					else if (scratch_mem_in == L_exc_err_out[j*4+i])
						$display($time, " CORRECT:  L_exc_err[%d] = %x", i, scratch_mem_in);
					@(posedge clock);
			end
		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule
