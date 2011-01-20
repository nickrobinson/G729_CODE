`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:32:35 09/16/2010 
// Module Name:    filterb_v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A test bench to model the memeory handingling between the preprocessing and autocorrelation blocks
//
// Dependencies: 	 autocorr.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module filtertb_v;

	// Inputs
	reg mclk;
   reg reset;
	reg [15:0] xn,yn;
	reg ready;

	// Outputs
	wire [7:0] xReq,yReadReq,yWriteReq,rReq;
	wire [15:0] yOut;
	wire [31:0] rOut;
	wire done;
	wire rWrite;
	wire yWrite;

		
        // input memory
        reg [15:0] xMem [0:239];
		  
		  //intermediary memory
		  reg [15:0] yMem [0:239];

        // r'(k) results memory
        // these filtered results come from the 
        // ITU G.729 fixed point ANSI Cimplementation
        reg [31:0] rMem [0:10];
		  
		  reg [31:0] rTempMem [0:10];

        integer i;

	// Instantiate the Unit Under Test (UUT)
	autocorr uut(
					.clk(mclk),
					.reset(reset),
					.ready(ready),
					.xIn(xn),
					.yIn(yn),
					.rOut(rOut),
					.yOut(yOut),
					.xRequested(xReq),
					.yReadRequested(yReadReq),
					.yWriteRequested(yWriteReq),
					.rRequested(rReq),					
					.rWrite(rWrite),
					.yWrite(yWrite),
					.done(done)
					);

       initial begin
                  // samples out are samples from ITU G.729 test vectors
                  $readmemh("autocorr_in.out", xMem);
                  // filter results from ITU G.729 ANSI fixed point implementation
                  $readmemh("autocorr_out.out", rMem);
        end 

   always@(*) begin
		yn = yMem[yReadReq];
   end
	
	always@(*) begin
		xn = xMem[xReq];
   end
	
	always@(posedge mclk) begin
	   if (yWrite)
	     yMem[yWriteReq] <= yOut;
	end

always@(posedge mclk) begin
	   if (rWrite)
	     rTempMem[rReq] <= rOut;
	end
   
	
	initial begin
		// Initialize Inputs
		mclk = 0;
		ready = 0;
      reset = 0;
		// Wait 100 ns for global reset to finish
		#100;
      reset = 1; 
      #50 reset = 0; 
      #50;
        
		// Add stimulus here
               
      @(posedge mclk);
			ready = 1;
      @(posedge mclk);
         ready = 0;							 
						  
      wait (done);
		@(posedge mclk);
			for (i = 0; i<11;i=i+1) begin
				if (rTempMem[i]!= rMem[i])
					$display($time, " ERROR: r'[%d] = %x, expected = %x", i, rTempMem[i], rMem[i]);
				else
					$display($time, " INFO:  r'[%d] = %x", i, rTempMem[i]);
			end

	end

        // 50 MHz clock - 10nS Hi, 10 nS low, ...
        initial forever #10 mclk = ~mclk;
      
endmodule
