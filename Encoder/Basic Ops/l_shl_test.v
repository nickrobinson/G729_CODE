			`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:07:00 10/02/2010
// Design Name:   L_shl
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Fall 2010/Senior Design I/G729 Verilog Code/Autocorrelation and Windowing/autocorr/L_shl_test.v
// Project Name:  autocorr
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: L_shl
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module L_shl_test_v;

	// Inputs
	reg clk;
	reg reset;
	reg ready;
	reg [31:0] var1;
	reg [15:0] numShift;

	// Outputs
	wire overflow;
	wire done;
	wire [31:0] out;

   integer i;
	
	reg [31:0] mem [0:9999];
	
	initial
	begin
		$readmemh("a_L_shl.out", mem);
	end
	
	// Instantiate the Unit Under Test (UUT)
	L_shl uut (
		.clk(clk), 
		.reset(reset), 
		.ready(ready), 
		.overflow(overflow), 
		.var1(var1), 
		.numShift(numShift), 
		.done(done), 
		.out(out)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		ready = 0;
		var1 = 0;
		numShift = 0;

		// Wait 100 ns for global reset to finish
		#100;

      reset = 1; 
      #50 
		reset = 0; 
      // Add stimulus here
		
		for(i=0;i<2000;i=i+1)
		begin
		
			@(posedge clk);
			@(posedge clk); #5;
			var1 = mem[i*3];
			numShift = mem[i*3+1];
			
			ready = 1;
			@(posedge clk);
			@(posedge clk); #5;
			ready = 0;			
			@(posedge clk);
			@(posedge clk); #5;
			
			wait(done);
			@(posedge clk);
			@(posedge clk); #5;
			
			if (out != mem[i*3+2])
				$display($time, " ERROR: output[%d] = %x, expected = %x", i, out, mem[i*3+2]);
			else if (out == mem[i*3+2])
				$display($time, " CORRECT:  output[%d] = %x", i, out);	
		end

	end
   initial forever #10 clk = ~clk; 
endmodule

