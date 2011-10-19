`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:31:35 10/11/2011
// Design Name:   de_acelp_pipe
// Module Name:   C:/XilinxProjects/Decod_ACELP/de_acelp_tb.v
// Project Name:  Decod_ACELP
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: de_acelp_pipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module de_acelp_tb;

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
	de_acelp_pipe uut (
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
	
	reg [31:0] sign_in [0:4999];
	reg [31:0] index_in [0:4999];
	reg [31:0] pos [0:4999];
	reg [31:0] cod [0:4999];
	
	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("de_acelp_sign.out", sign_in);
		$readmemh("de_acelp_index.out", index_in);
		$readmemh("de_acelp_cod.out", cod);
	end
	
	integer i, j;

	initial begin
		/*// Initialize Inputs
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
		
		@(posedge clk) #5;
//		for(j=0;j<60;j=j+1)
//		begin
			//TEST1
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			mem_Mux1Sel = 1;
			mem_Mux2Sel = 1;
			mem_Mux3Sel = 1;
			mem_Mux4Sel = 1;
		   test_write_addr = {}; //address of index in scratch mem (probably a parameter) 
			test_write = index;
			test_write_en = 1;			
			@(posedge clk);
			test_write_addr = {}; //address of sign in scratch mem (probably a parameter) 
			test_write = sign;
			test_write_en = 1;			
			@(posedge clk);
			test_write_en = 0;	
			@(posedge clk);
			@(posedge clk) #5;

			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			mem_Mux1Sel = 0; // giving your model control memory
			mem_Mux2Sel = 0;
			mem_Mux3Sel = 0;
			mem_Mux4Sel = 0;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;		
			start = 1;        // start your FSM
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			// Add stimulus here	
			wait(done);
			
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

		   test_read_addr = {}; //address of cod[0] in scratch mem (probably a parameter) 
			@(posedge clk);
         if (scratch_mem_in != cod0)
			  $display("error");

		   test_read_addr = {}; //address of cod[1] in scratch mem (probably a parameter) 
			@(posedge clk);
         if (scratch_mem_in != cod1)
			  $display("error");
			  
		   test_read_addr = {}; //address of cod[2] in scratch mem (probably a parameter) 
			@(posedge clk);
         if (scratch_mem_in != cod2)
			  $display("error");
			  
		   test_read_addr = {}; //address of cod[3] in scratch mem (probably a parameter) 
			@(posedge clk);
         if (scratch_mem_in != cod3)
			  $display("error");
			
			@(posedge clk);
			@(posedge clk) #5;
			


//		end//j for loop*/

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
		
		@(posedge clk) #5;
		for(j=0;j<34;j=j+1)
		begin
			//TEST1
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
			//for(i=0;i<40;i=i+1)
			//begin
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
				//test_write_addr = {INDEX_IN[11:6],j[5:0]};
				test_write_addr = {INDEX_IN[11:6],6'd0};
				test_write = index_in[j];
				test_write_en = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			//end
			@(posedge clk);
			@(posedge clk) #5;
			//for(i=0;i<40;i=i+1)
			//begin
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
				//test_write_addr = {SIGN_IN[11:6],j[5:0]};
				test_write_addr = {SIGN_IN[11:6],6'd0};
				test_write = sign_in[j];
				test_write_en = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			//end
			/*for(i=0;i<4;i=i+1)
			begin
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
				test_write_addr = {G_COEFF[11:2],i[1:0]};
				test_write = g_coeff_in[4*j+i];
				test_write_en = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
			end*/
			
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
			// Add stimulus here	
			wait(done);
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			mem_Mux4Sel = 1;
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
			
			//Check gain_pit outputs
					//#50;
				for(i = 0; i < 40; i = i + 1) begin
					@(posedge clk);
					@(posedge clk);
					@(posedge clk) #5;
					
					test_read_addr = {COD[11:6],i[5:0]};
					
					@(posedge clk);
					@(posedge clk) #5;
					
					if (scratch_mem_in != cod[40*j+i])
						$display($time, " ERROR: cod[%d] = %x, expected = %x", i, scratch_mem_in, cod[40*j+i]);
					else if (scratch_mem_in == cod[40*j+i])
						$display($time, " CORRECT:  cod[%d] = %x", i, scratch_mem_in);
					@(posedge clk);
				end
			/*@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;*/

		end//j for loop

	end
	
	initial forever #10 clk = ~clk;
      
endmodule

