`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:41:57 11/23/2011
// Design Name:   Gain_update_erasure_pipe
// Module Name:   C:/XilinxProjects/Gain_update_erasure/Gain_update_erasure_tb.v
// Project Name:  Gain_update_erasure
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Gain_update_erasure_pipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Gain_update_erasure_tb;

	`include "paramList.v"

	// Inputs
	reg clk;
	reg start;
	reg reset;
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
	Gain_update_erasure_pipe uut (
		.clk(clk), 
		.start(start), 
		.reset(reset), 
		.done(done), 
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
	
	reg [31:0] past_qua_en_in[0:14999];
	reg [31:0] past_qua_en_out[0:14999];
	
	// file read in for inputs and output tests
	initial
	begin // samples out are samples from ITU G.729 test vectors
		$readmemh("Gain_update_erasure_pastquaen_in.out", past_qua_en_in);
		$readmemh("Gain_update_erasure_pastquaen_out.out", past_qua_en_out);
	end
	
	integer i, j;
	
	initial forever #10 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		start = 0;
		reset = 0;
		mem_Mux1Sel = 0;
		mem_Mux2Sel = 0;
		mem_Mux3Sel = 0;
		mem_Mux4Sel = 0;
		test_write_addr = 0;
		test_read_addr = 0;
		test_write = 0;
		test_write_en = 0;
		
		@(posedge clk);
		@(posedge clk);
		@(posedge clk) #5;
		reset = 1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk) #5;
		reset = 0;
		
		@(posedge clk) #5;
		for(j=0;j<3704;j=j+1)
		begin
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			mem_Mux1Sel = 0;
			mem_Mux2Sel = 0;
			mem_Mux3Sel = 0;
			mem_Mux4Sel = 0;
			test_read_addr = 0;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			mem_Mux1Sel = 1;
			mem_Mux2Sel = 1;
			mem_Mux3Sel = 1;
			mem_Mux4Sel = 1;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			// read in past_qua_en
			for(i=0;i<4;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
				test_write_addr = {PAST_QUA_EN[11:2],i[1:0]};
				test_write = past_qua_en_in[4*j+i];
				test_write_en = 1;
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			mem_Mux1Sel = 0;
			mem_Mux2Sel = 0;
			mem_Mux3Sel = 0;
			mem_Mux4Sel = 0;
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			start = 1;
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			start = 0;
			
			wait(done);
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			mem_Mux4Sel = 1;
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			for(i=0;i<4;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
				test_read_addr = {PAST_QUA_EN[11:2],i[1:0]};
				@(posedge clk);
				@(posedge clk) #5;
				if(scratch_mem_in != past_qua_en_out[4*j+i])
					$display($time, " ERROR: past_qua_en[%d] = %x, expected = %x", 4*j+i, scratch_mem_in, past_qua_en_out[4*j+i]);
				else if(scratch_mem_in == past_qua_en_out[4*j+i])
					$display($time, " CORRECT: past_qua_en[%d] = %x", 4*j+i, scratch_mem_in);
				@(posedge clk)#5;
			end
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
		end

	end
      
endmodule

