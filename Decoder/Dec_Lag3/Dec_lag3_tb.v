`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:44:08 11/22/2011 
// Design Name: 
// Module Name:    Dec_lag3_tb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Dec_lag3_tb;

	`include "paramList.v"
	
	reg start;
	reg reset;
	reg clk;

	wire done;
	
	reg muxSelect;
	reg [11:0] memReadAddrTest;
	wire [31:0] memInTest;
	reg [11:0] memWriteAddrTest;
	reg [31:0] memOutTest;
	reg memWriteEnTest;
	wire [31:0] scratch_mem_in;
	
	reg [15:0] index_addr, i_subfr;
	
	//I/O regs
	reg [3:0] index_addr_data [0:400000];
	reg [15:0] i_subfr_data [0:400000];
	reg [15:0] T0_frac_data [0:400000];
	reg [15:0] T0_data [0:400000];
	reg [15:0] T0_frac_value_data [0:400000];
	reg [15:0] T0_value_data [0:400000];
	reg [15:0] index_value_data [0:400000];
	
	integer i,j;

	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("dec_lag3_index_addr.out", index_addr_data);
			$readmemh("dec_lag3_i_subfr.out", i_subfr_data);
			$readmemh("dec_lag3_T0_frac.out", T0_frac_data);
			$readmemh("dec_lag3_T0.out", T0_data);
			$readmemh("dec_lag3_T0_frac_value.out", T0_frac_value_data);
			$readmemh("dec_lag3_T0_value.out", T0_value_data);
			$readmemh("dec_lag3_index_value.out", index_value_data);
		end
		
	Dec_lag3_pipe i_pipe(
	.clk(clk), 
	.start(start), 
	.done(done), 
	.reset(reset), 
	.index_addr(index_addr), 
	.i_subfr(i_subfr), 
	.memOutTest(memOutTest),
   .memReadAddrTest(memReadAddrTest), 
	.memWriteAddrTest(memWriteAddrTest), 
	.memWriteEnTest(memWriteEnTest), 
	.scratch_mem_in(scratch_mem_in), 
	.muxSelect(muxSelect) );
	
	initial forever #10 clk = ~clk;
	
	initial begin
		// Initialize Inputs
		start = 0;
		clk = 0;
		reset = 0;
		muxSelect = 0;
		memReadAddrTest = 0;
		memWriteAddrTest = 0;
		#50
		reset = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk) #5;
		for(j=0;j<1806;j=j+1)
		begin
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			muxSelect = 0;
			memReadAddrTest = 0;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			muxSelect = 1;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			memWriteAddrTest = T0;
			memOutTest = T0_value_data[j];
			memWriteEnTest = 1;	
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			@(posedge clk) #5;
			muxSelect = 1;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			memWriteAddrTest = T0_FRAC;
			memOutTest = T0_frac_value_data[j];
			memWriteEnTest = 1;
			@(posedge clk) #5;
			@(posedge clk) #5;
			muxSelect = 1;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			memWriteAddrTest = {PRM[11:4], index_addr_data[j]};
			memOutTest = index_value_data[j];
			memWriteEnTest = 1;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			muxSelect = 0;
			index_addr = index_addr_data[j];
			i_subfr = i_subfr_data[j];
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;		
			start = 1;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			// Add stimulus here	
			wait(done);
			
			@(posedge clk);
			@(posedge clk);
			memWriteAddrTest = 0;
			memOutTest = 0;
			memWriteEnTest = 0;	
			@(posedge clk) #5;
			muxSelect = 1;
			//gamma1 read
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;	
					
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			memReadAddrTest = T0;
			@(posedge clk);
			@(posedge clk) #5;
			if (scratch_mem_in != {16'd0, T0_data[j]})
				$display($time, " ERROR: T0_data[%d] = %x, expected = %x", j, scratch_mem_in, T0_data[j]);
			else if (scratch_mem_in == {16'd0, T0_data[j]})
				$display($time, " CORRECT:  T0_data[%d] = %x", j, scratch_mem_in);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			memReadAddrTest = T0_FRAC;
			@(posedge clk);
			@(posedge clk) #5;
			if (scratch_mem_in != {16'd0, T0_frac_data[j]})
				$display($time, " ERROR: T0_frac_data[%d] = %x, expected = %x", j, scratch_mem_in, T0_frac_data[j]);
			else if (scratch_mem_in == {16'd0, T0_frac_data[j]})
				$display($time, " CORRECT:  T0_frac_data[%d] = %x", j, scratch_mem_in);
			@(posedge clk);
			
		end//j for loop
	end

endmodule
