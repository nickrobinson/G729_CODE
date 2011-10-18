`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:04:16 11/04/2010
// Design Name:   norm_s
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Fall 2010/Senior Design I/G729 Verilog Code/A(z) to LSP/AztoLSP/norm_s_test.v
// Project Name:  AztoLSP
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: norm_s
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module norm_s_test_v;

	// Inputs
	reg [15:0] var1;
	reg clk;
	reg ready;
	reg reset;

	// Outputs
	wire [15:0] norm;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	norm_s uut (
		.var1(var1), 
		.norm(norm), 
		.clk(clk), 
		.ready(ready), 
		.reset(reset), 
		.done(done)
	);

	initial begin
		// Initialize Inputs
		var1 = 0;
		clk = 0;
		ready = 0;
		reset = 0;

		// Wait 100 ns for global reset to finish
		//Test1
		#100;
      reset = 1;
		#50;	
		reset = 0;
		#50;		
		var1 = 16'h0001;
		#50;
		ready = 1;		
		#50;
		ready = 0;
		wait(done);		
		if (norm != 16'd14)
					$display($time, " ERROR: norm = %x, expected = %x", norm, 16'd14);
		else
					$display($time, " CORRECT:  norm = %x", norm);
		//test2
		#10;
      reset = 1;
		#50;	
		reset = 0;
		#50;		
		var1 = 16'h4375;
		#50;
		ready = 1;		
		#50;
		ready = 0;
		wait(done);		
		if (norm != 16'd0)
					$display($time, " ERROR: norm = %x, expected = %x", norm, 16'd0);
		else
					$display($time, " CORRECT:  norm = %x", norm);
					
		//Test3			
		#10;
      reset = 1;
		#50;	
		reset = 0;
		#50;		
		var1 = 16'h0040;
		#50;
		ready = 1;		
		#50;
		ready = 0;
		wait(done);		
		if (norm != 16'd8)
					$display($time, " ERROR: norm = %x, expected = %x", norm, 16'd8);
		else
					$display($time, " CORRECT:  norm = %x", norm);			
	end
initial forever #10 clk = ~clk;	        
endmodule

