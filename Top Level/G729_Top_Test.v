`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:41:04 11/26/2010
// Design Name:   G729_Top
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Fall 2010/Senior Design I/G729 Verilog Code/Top_Level/G729_Top_Test.v
// Project Name:  Top_Level
// Target Device:  
// Tool versions:  
// Description: 	This is a top level test to read in the inputs to the encoder, and compare the ouput
//						of the encoder with the C-model outputs
//
// Verilog Test Fixture created by ISE for module: G729_Top
//
// Dependencies: G729_Top.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module G729_Top_Test_v;

	// Inputs
	reg clock;
	reg reset;
	reg start;
	reg [15:0] in;

	// Outputs
	wire [31:0] out;
	wire done;
	
	
	//Working regs
	reg [15:0] samplesmem [0:9999];
	reg [31:0] outputmem[0:9999];
	reg [31:0] testmem[0:10];
	
	//working integers
	integer i;
	integer j;
	integer k;
	
	initial
	begin
		// samples out are samples from ITU G.729 test vectors
		$readmemh("samples.out", samplesmem);
		$readmemh("az_lsp_out.out", outputmem);
		j = 0;
	end	
		
	// Instantiate the Unit Under Test (UUT)
	G729_Top uut (
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.in(in), 
		.out(out), 
		.done(done)
	);

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		start = 0;
		in = 0;

		
		#50;
      reset = 1;
		#50;		
		reset = 0;
		#100;			// Wait 100 ns for global reset to finish
		for(k=0;k<60;k=k+1)
		begin		
			for (i=0;i<80;i=i+1)
				begin
				  @(posedge clock);
				  start = 1;
				  in = samplesmem[i+80*k];
				  @(posedge clock);
				  start = 0;			  
				  #200;
				end			
			// Add stimulus here
			wait(done);
			for (i = 0; i<10;i=i+1)
			begin					
					if (testmem[i] != outputmem[i+10*k])
						$display($time, " ERROR: output[%d] = %x, expected = %x", i, testmem[i], outputmem[i+10*k]);
					else if (testmem[i] == outputmem[i+10*k])
						$display($time, " CORRECT:  output[%d] = %x", i, testmem[i]);	
					else
						$display($time, " ERROR: output[%d] = %x, expected = %x", i, testmem[i], outputmem[i+10*k]);
			end	
		end//k for loop
	end//initial 
		
		always @(posedge clock)
		begin
			if(j%10 == 0)
				j = 0;
			if(out == outputmem[j+10*k])
			begin
				testmem[j] = out;
				j = j+1;
			end

	end//end always
	
	initial forever #10 clock = ~clock;
      
endmodule

