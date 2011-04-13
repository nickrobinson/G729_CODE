`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:   16:30:35 04/04/2011
// Module Name:   Gain_update_tb
// Project Name:  ITU G.729 Hardware Implementation
// Target Device: Virtex 5 - XC5VLX110T
// Tool versions: Xilinx ISE 12.4
// Description: 
//
// Dependencies:	Gain_update_pipe.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Gain_update_tb;

	`include "ParamList.v"

	// Inputs
	reg clock;
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
	reg [31:0] L_gbk12;

	// Outputs
	wire done;
	wire [31:0] scratch_mem_in;


	// Instantiate the Unit Under Test (UUT)
	Gain_update_pipe uut (
		.clock(clock), 
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
		.test_write_en(test_write_en), 
		.L_gbk12(L_gbk12)
	);
	
	reg [31:0] past_qua_en_in [0:4999];
	reg [31:0] L_gbk12_in [0:4999];
	reg [31:0] past_qua_en_out [0:4999];

	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("gain_update_past_qua_en_in.out", past_qua_en_in);
		$readmemh("gain_update_L_gbk12_in.out", L_gbk12_in);
		$readmemh("gain_update_past_qua_en_out.out", past_qua_en_out);
	end
	
	integer i,j;
	
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		start = 0;

		#50
		reset = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 0;
		
		for(j=0;j<60;j=j+1)
		begin
			//TEST1
			mem_Mux1Sel = 0;
			mem_Mux2Sel = 0;
			mem_Mux3Sel = 0;
			mem_Mux4Sel = 0;
			test_read_addr = 0;
			
			for(i=0;i<4;i=i+1)
			begin
				#100;
				mem_Mux1Sel = 1;
				mem_Mux2Sel = 1;
				mem_Mux3Sel = 1;
				test_write_addr = {PAST_QUA_EN[11:2],i[1:0]};
				test_write = past_qua_en_in[4*j+i];
				test_write_en = 1;	
				#100;			
			end
			
			mem_Mux1Sel = 0;
			mem_Mux2Sel = 0;
			mem_Mux3Sel = 0;
			mem_Mux4Sel = 0;
			L_gbk12 = L_gbk12_in[j];
			#50;		
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here	
			wait(done);
			mem_Mux4Sel = 1;
			
			//Check past_qua_en array outputs
			for (i = 0; i<4;i=i+1)
			begin				
					test_read_addr = {PAST_QUA_EN[11:2],i[1:0]};
					#50;
					if (scratch_mem_in[15:0] != past_qua_en_out[j*4+i][15:0])
						$display($time, " ERROR: past_qua_en[%d] = %x, expected = %x", i, scratch_mem_in[15:0], past_qua_en_out[j*4+i][15:0]);
					else if (scratch_mem_in[15:0] == past_qua_en_out[j*4+i][15:0])
						$display($time, " CORRECT:  past_qua_en[%d] = %x", i, scratch_mem_in[15:0]);
					@(posedge clock);
			end	
			
		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule

