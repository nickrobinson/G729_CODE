`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    17:40:12 02/14/2011
// Module Name:    lsp_to_az_tb 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description: 	 This module tests the lsp_to_az module.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Updated to support 12 bit memory addresses
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lsp_to_az_tb;

	`include "paramList.v"
	
	reg clock,start,reset;
	
	wire done;
	
	wire [31:0] scratch_mem_in;
	
	reg [11:0] test_write_addr,test_read_addr;
	
	reg [11:0] lsp_az_addr1,lsp_az_addr2;
	
	reg [31:0] test_write;
	
	reg test_write_en,mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,mem_Mux4Sel;
	
	reg [32:0] lsp_in [0:4999];
	reg [32:0] az_out [0:4999];
	
	integer i,j;
	
	lsp_to_az_pipe lsp_to_az_pipe(
					.start(start),
					.reset(reset),
					.done(done),
					.clock(clock),
					.scratch_mem_in(scratch_mem_in),
					.test_write_addr(test_write_addr),
					.test_write_en(test_write_en),
					.test_write(test_write),
					.test_read_addr(test_read_addr),
					.mem_Mux1Sel(mem_Mux1Sel),
					.mem_Mux2Sel(mem_Mux2Sel),
					.mem_Mux3Sel(mem_Mux3Sel),
					.mem_Mux4Sel(mem_Mux4Sel),
					.lsp_az_addr1(lsp_az_addr1),
					.lsp_az_addr2(lsp_az_addr2)
			);
			
	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("lsp_az_lsp_in.out", lsp_in);
		$readmemh("lsp_az_az_out.out", az_out);
	end

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
				test_write_addr = {INT_LPC_LSP_TEMP[11:4],i[3:0]};
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
			lsp_az_addr1 = INT_LPC_LSP_TEMP;
			lsp_az_addr2 = A_T_LOW;
			
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
			for (i = 0; i<10;i=i+1)
			begin		
					
					@(posedge clock);
					@(posedge clock);
					@(posedge clock) #5;
					test_read_addr = {A_T_LOW[11:4],i[3:0]};
					@(posedge clock);
					@(posedge clock) #5;
					if (scratch_mem_in != az_out[j*10+i])
						$display($time, " ERROR: f[%d] = %x, expected = %x", i, scratch_mem_in, az_out[j*10+i]);
					else if (scratch_mem_in == az_out[j*10+i])
						$display($time, " CORRECT:  f[%d] = %x", i, scratch_mem_in);
					@(posedge clock);
			end	
			
		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule
