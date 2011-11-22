`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:17:27 10/31/2011 
// Design Name: 
// Module Name:    bits2int_tb 
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
module bits2prm_tb(
    );

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
	
	//I/O regs
	reg [15:0] bitstream_data [0:400000];
	reg [15:0] prm_data [0:400000];
	
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("bits2prm_prm_data.out", prm_data);
			$readmemh("bits2prm_bitstream.out", bitstream_data);
		end

	bits2prm_ld8k_pipe i_pipe(
		.start(start),
		.clk(clk), 
		.reset(reset), 
		.done(done),
		.muxSelect(muxSelect),
		.scratch_mem_in(memInTest),
		.memReadAddrTest(memReadAddrTest),
		.memWriteAddrTest(memWriteAddrTest),
		.memOutTest(memOutTest),
		.memWriteEnTest(memWriteEnTest));
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;

		@(posedge clk);
		@(posedge clk);
		@(posedge clk) #5;
		reset = 1;
		// Wait 50 ns for global reset to finish
		@(posedge clk);
		@(posedge clk);
		@(posedge clk) #5;
		reset = 0;
		
		@(posedge clk);
		@(posedge clk);
		@(posedge clk) #5;
		for(j=0;j<3658;j=j+1)
		begin
			//TEST1
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			muxSelect = 0;
			memReadAddrTest = 0;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			for(i=0;i<80;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
				muxSelect = 1;
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
				memWriteAddrTest = {SERIAL[11:4],i[3:0]};
				memOutTest = bitstream_data[80*j+i];
				memWriteEnTest = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			muxSelect = 0;
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
			for (i = 0; i<11;i=i+1)
			begin		
					
					@(posedge clk);
					@(posedge clk);
					@(posedge clk) #5;
					memReadAddrTest = {PRM[11:4],i[3:0]};
					@(posedge clk);
					@(posedge clk) #5;
					if (memInTest != {16'd0, prm_data[j*11+i]})
						$display($time, " ERROR: prm_data[%d] = %x, expected = %x", i, memInTest, prm_data[j*11+i]);
					else if (memInTest == {16'd0, prm_data[j*11+i]})
						$display($time, " CORRECT:  prm_data[%d] = %x", i, memInTest);
					@(posedge clk);
			end
		end//j for loop
      
	end
      
		initial forever #10 clk = ~clk;
	
endmodule
