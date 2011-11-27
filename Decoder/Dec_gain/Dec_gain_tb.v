`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:06:06 11/25/2011
// Design Name:   Dec_gain_pipe
// Module Name:   C:/XilinxProjects/Dec_gain/Dec_gain_tb.v
// Project Name:  Dec_gain
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Dec_gain_pipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Dec_gain_tb;

	`include "paramList.v"
	`include "constants_param_list.v"

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
	Dec_gain_pipe uut (
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
	
	reg [31:0] index_in[0:9999];
	reg [31:0] code_in[0:9999];
	reg [31:0] L_subfr_in[0:9999];
	reg [31:0] bfi_in[0:9999];
	reg [31:0] gain_pit_out[0:9999];
	reg [31:0] gain_cod_out[0:9999];
	reg [31:0] gain_pit_in[0:9999];
	reg [31:0] gain_cod_in[0:9999];
	
	// file read in for inputs and output tests
	initial
	begin // samples out are samples from ITU G.729 test vectors
		$readmemh("Dec_gain_index.out", index_in);
		$readmemh("Dec_gain_code.out", code_in);
		$readmemh("Dec_gain_L_subfr.out", L_subfr_in);
		$readmemh("Dec_gain_bfi.out", bfi_in);
		$readmemh("Dec_gain_gain_pit_out.out", gain_pit_out);
		$readmemh("Dec_gain_gain_cod_out.out", gain_cod_out);
		$readmemh("Dec_gain_gain_pit_in.out", gain_pit_in);
		$readmemh("Dec_gain_gain_cod_in.out", gain_cod_in);
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
		
		mem_Mux1Sel = 1;
		mem_Mux2Sel = 1;
		mem_Mux3Sel = 1;
		mem_Mux4Sel = 1;
		
		@(posedge clk);
		@(posedge clk);
		@(posedge clk) #5;
		
		for(i=0;i<4;i=i+1)
		begin
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			test_write_addr = {PAST_QUA_EN[11:2],i[1:0]};
			test_write = -32'd14336;
			test_write_en = 1;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
		end
		
		@(posedge clk);
		@(posedge clk);
		@(posedge clk) #5;
		reset = 1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk) #5;
		reset = 0;

		@(posedge clk) #5;
		for(j=0;j<248;j=j+1)
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
			
			// Write index (i) into memory
			test_write_addr = INDEX;
			test_write = index_in[j];
			test_write_en = 1;
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			// Write code[] (i) into memory
			for(i=0;i<40;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
				test_write_addr = {CODE[11:6],i[5:0]};
				test_write = code_in[40*j+i];
				test_write_en = 1;
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			// Write L_subfr (i) into memory
			test_write_addr = L_SUBFR;
			test_write = L_subfr_in[j];
			test_write_en = 1;
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			// Write bfi (i) into memory
			test_write_addr = BFI;
			test_write = bfi_in[j];
			test_write_en = 1;
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			// Write initial gain_pit into memory
			test_write_addr = GAIN_PIT;
			test_write = gain_pit_in[j];
			test_write_en = 1;
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			// Write initial gain_cod into memory
			test_write_addr = GAIN_CODE;
			test_write = gain_cod_in[j];
			test_write_en = 1;
			
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
			
			test_read_addr = GAIN_PIT;
			@(posedge clk);
			@(posedge clk) #5;
			if(scratch_mem_in != gain_pit_out[j])
				$display($time, " ERROR: gain_pit[%d] = %x, expected = %x", j, scratch_mem_in, gain_pit_out[j]);
			else if(scratch_mem_in == gain_pit_out[j])
				$display($time, " CORRECT: gain_pit[%d] = %x", j, scratch_mem_in);
						
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			test_read_addr = GAIN_CODE;
			@(posedge clk);
			@(posedge clk) #5;
			if(scratch_mem_in != gain_cod_out[j])
				$display($time, " ERROR: gain_cod[%d] = %x, expected = %x", j, scratch_mem_in, gain_cod_out[j]);
			else if(scratch_mem_in == gain_cod_out[j])
				$display($time, " CORRECT: gain_cod[%d] = %x", j, scratch_mem_in);
						
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			
		end

	end
      
endmodule

