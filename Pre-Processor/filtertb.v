`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Tommy Morris, PhD
// Assistant Professor
// Electrical and Computer Engineering
// Mississippi State University 
// morris@ece.msstate.edu          
//
// This Verilog HDL was developed with funding from NASA ESMD Space Grant.
//
// Create Date:   11:17:50 06/18/2010
// Module Name:   filtertb.v
// Project Name:  g729_hpfilter
//
// Verilog Test Fixture created by ISE for module: g729_hpfilter
//
////////////////////////////////////////////////////////////////////////////////

module filtertb_v;

	// Inputs
	reg clk;
        reg reset;
	reg [15:0] xn;
	reg ready;

	// Outputs
	wire [15:0] yn;
	wire done;

        // samples memory
        reg [15:0] samplesmem [0:9999];

        // filtered results memory
        // these filtered results come from the 
        // ITU G.729 fixed point ANSI C implementation
        reg [15:0] filteredmem [0:9999];

        integer i;

	// Instantiate the Unit Under Test (UUT)
	g729_hpfilter uut (
		.clk(clk), 
		.reset(reset), 
		.xn(xn), 
		.yn(yn), 
		.ready(ready), 
		.done(done)
	);

        initial begin
                  // samples out are samples from ITU G.729 test vectors
                  $readmemh("samples.out", samplesmem);
                  // filter results from ITU G.729 ANSI fixed point implementation
                  $readmemh("filtered.out", filteredmem);
        end

	initial begin
		// Initialize Inputs
		clk = 0;
		xn = 0;
		ready = 0;
      reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
                reset = 1; 
                #50 reset = 0; 
                #50;
        
		// Add stimulus here
                for (i=0;i<1000;i=i+1)
                  begin
                    @(posedge clk);
                    ready = 1;
                    xn = samplesmem[i];
                    @(posedge clk);
                    ready = 0;
                    wait (done);
                    @(posedge clk);
                    if (yn != filteredmem[i])
                       $display($time, " ERROR: y[%d] = %x, expected = %x", i, yn, filteredmem[i]);
                    else
                       $display($time, " CORRECT:y[%d] = %x", i, yn);
                  end

	end

        // 50 MHz clock - 10nS Hi, 10 nS low, ...
        initial forever #10 clk = ~clk;
      
endmodule
