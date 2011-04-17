`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   03:14:13 03/20/2011
// Design Name:   Interpol_3_pipe
// Module Name:   C:/Users/Cooper/Documents/_SeniorDesign/Interpol_3/Interpol_3_test.v
// Project Name:  Interpol_3
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Interpol_3_pipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Interpol_3_test;

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [11:0] x;
	reg [15:0] frac;
	reg [11:0] inter_3;
	reg [11:0] TBwriteAddrScratch;
	reg [31:0] TBwriteDataScratch;
	reg TBwriteEnScratch;

	// Outputs
	wire [15:0] returnS;
	wire done;
	
	// TB Ints
	integer i, j;

	// Instantiate the Unit Under Test (UUT)
	Interpol_3_pipe _pipe (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.x(x), 
		.frac(frac), 
		.inter_3(inter_3), 
		.TBwriteAddrScratch(TBwriteAddrScratch), 
		.TBwriteDataScratch(TBwriteDataScratch), 
		.TBwriteEnScratch(TBwriteEnScratch), 
		.returnS(returnS), 
		.done(done)
	);

	//Memory Regs
	reg [31:0] Interpol_3_x [0:50000];
	reg [31:0] Interpol_3_frac [0:9999];
	reg [31:0] Interpol_3_frac2 [0:9999];
	reg [31:0] Interpol_3_round [0:9999];
	reg [31:0] Interpol_3_s1 [0:9999];
	reg [31:0] Interpol_3_s2 [0:9999];

	initial 
	begin
		// samples out are samples from ITU G.729 test vectors
		$readmemh("Interpol_3_x.out", Interpol_3_x);
		$readmemh("Interpol_3_frac.out", Interpol_3_frac);
		$readmemh("Interpol_3_frac2.out", Interpol_3_frac2);
		$readmemh("Interpol_3_round.out", Interpol_3_round);
		$readmemh("Interpol_3_s1.out", Interpol_3_s1);
		$readmemh("Interpol_3_s2.out", Interpol_3_s2);
   end

	initial forever #10 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		x = 'd16;
		frac = 'd0;
		inter_3 = 'd3952;
		TBwriteAddrScratch = 0;
		TBwriteDataScratch = 0;
		TBwriteEnScratch = 0;

		// Wait 100 ns for global reset to finish
		@(posedge clk);
		reset = 1;
		@(posedge clk);
		reset = 0;
        
		// Add stimulus here
		for(j=0;j<1280;j=j+1)
		begin
			@(posedge clk);
			for(i = -16; i < 16; i = i + 1)
			begin
				@(posedge clk);
				TBwriteAddrScratch = x + i;
				TBwriteDataScratch = Interpol_3_x[j*32+(i+16)];
				TBwriteEnScratch = 1;
				@(posedge clk);
			end
			
			frac = Interpol_3_frac[j];
			
			@(posedge clk);
			
			TBwriteEnScratch = 0;
			
			@(posedge clk);

			start = 1;
			
			@(posedge clk);
			
			start = 0;
			
			wait(done);

			if (returnS != Interpol_3_round[j])
				$display($time, " ERROR: returnS = %x, expected = %x", returnS, Interpol_3_round[j]);
			else
				$display($time, " CORRECT:  returnS = %x", returnS);
			@(posedge clk);
		end//j loop
	end
      
endmodule

