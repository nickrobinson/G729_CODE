`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
//	ECE 4532-4542 Senior Design
// Engineer: Sean Owens
//
// Create Date:   22:13:29 04/12/2011
// Module Name:  	G_pitch_tb
// Target Device: Virtex 5 - XC5VLX110T
// Tool versions: Xilinx ISE 12.4
// Description: 	
//
// Dependencies:	G_pitch_pipe.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module G_pitch_tb;

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
	wire [15:0] out;
	wire [31:0] scratch_mem_in;

	// Instantiate the Unit Under Test (UUT)
	G_pitch_pipe uut (
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.done(done), 
		.out(out), 
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

	reg [31:0] xn_in [0:4999];
	reg [31:0] g_coeff_in [0:4999];
	reg [31:0] y1_in [0:4999];
	reg [31:0] gain_pit_out [0:4999];

	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("g_pitch_xn_in.out", xn_in);
		$readmemh("g_pitch_g_coeff_in.out", g_coeff_in);
		$readmemh("g_pitch_y1_in.out", y1_in);
		$readmemh("g_pitch_gain_pit_out.out", gain_pit_out);
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
				test_write_addr = {XN[11:6],i[5:0]};
				test_write = xn_in[40*j+i];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
			end
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
				test_write_addr = {Y1[11:6],i[5:0]};
				test_write = y1_in[40*j+i];
				test_write_en = 1;	
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
			end
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
				test_write_addr = {G_COEFF[11:2],i[1:0]};
				test_write = g_coeff_in[4*j+i];
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
			
			//Check gain_pit outputs
					#50;
					if (out != gain_pit_out[j])
						$display($time, " ERROR: gain_pit[%d] = %x, expected = %x", j, out, gain_pit_out[j]);
					else if (out == gain_pit_out[j])
						$display($time, " CORRECT:  gain_pit[%d] = %x", j, out);
					@(posedge clock);

			@(posedge clock);
			@(posedge clock);
			@(posedge clock) #5;

		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule