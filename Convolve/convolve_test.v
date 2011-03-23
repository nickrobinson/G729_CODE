	`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:23:48 01/23/2011
// Design Name:   convolve
// Module Name:   C:/Users/Nick/Documents/Spring2010/G.729 Verilog Code/Convolve/convolve_test.v
// Project Name:  Convolve
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: convolve
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module convolve_test_v;
`include "paramList.v"

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg lagMuxSel;
	reg lagMux1Sel;
	reg [11:0] testReadRequested;
	reg [11:0] testWriteRequested;
	reg [31:0] testWriteOut;
	reg testWriteEnable;
	
	wire done;
	wire [31:0] memIn;	

	reg [11:0] xAddr;
	reg [11:0] hAddr;
	reg [11:0] yAddr;	
	
	reg [15:0] inVector[0:9999];
	reg [15:0] impulse[0:9999];
	reg [15:0] outVector[0:9999];
	
	integer i, j;
									 
	initial 
		begin
			// samples out are samples from ITU G.729 test vectors
			$readmemh("convolve_input_vector.out", inVector);
			$readmemh("convolve_impulse_response.out", impulse);
			$readmemh("convolve_out.out", outVector);
		end

	// Instantiate the Unit Under Test (UUT)
	Convolve_Top_Level uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.memIn(memIn), 
		.done(done),
		.lagMuxSel(lagMuxSel),
		.lagMux1Sel(lagMux1Sel),
		.xAddr(xAddr),
		.hAddr(hAddr),
		.yAddr(yAddr),
		.testWriteRequested(testWriteRequested),
		.testWriteOut(testWriteOut),
		.testWriteEnable(testWriteEnable),
		.testReadRequested(testReadRequested)
	);		
					 
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;		
		lagMuxSel = 1;
		lagMux1Sel = 0;
		testReadRequested = 0;
		testWriteRequested = 0;
		testWriteOut = 0;
		testWriteEnable = 0;		
		xAddr = 12'd560;
		hAddr = 12'd624;
		yAddr = 12'd688;
		
		
		@(posedge clk) #5;
		reset = 1;		
		@(posedge clk) #5;		
		reset = 0;
		// Wait 100 ns for global reset to finish
		@(posedge clk) #10;
		@(posedge clk);
        
		for(j=0;j<10;j=j+1)
		begin
			//Test # 1
			@(posedge clk);
			@(posedge clk) #5;			
			lagMuxSel = 0;
			lagMux1Sel = 1;
			
			for(i=0;i<40;i=i+1)
			begin			
				@(posedge clk);
				@(posedge clk) #5;
				testWriteRequested = {xAddr[11:6],i[5:0]};
				testWriteOut = inVector[(j*40)+i];
				testWriteEnable = 1;
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			for(i=0;i<40;i=i+1)
			begin			
				@(posedge clk);			
				@(posedge clk) #5;
				testWriteRequested = {hAddr[11:6],i[5:0]};
				testWriteOut = impulse[(j*40)+i];
				testWriteEnable = 1;
				@(posedge clk);			
				@(posedge clk) #5;
			end
			
			lagMux1Sel = 0;	
			
			// Add stimulus here
			start = 1;
			@(posedge clk);			
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);			
			@(posedge clk) #5;
			
			wait(done);
			lagMuxSel = 1;
			for(i = 0; i<40;i=i+1)
			begin			
				testReadRequested = {yAddr[11:6],i[5:0]};
				@(posedge clk);
				@(posedge clk) #5;
				if (memIn != outVector[(j*40)+i])
						$display($time, " ERROR: r'[%d] = %x, expected = %x", (j*40)+i, memIn, outVector[(j*40)+i]);
					else
						$display($time, " CORRECT:  r'[%d] = %x", (j*40)+i, memIn);
			end
		end	// end j loop

	end
	
initial forever #10 clk = ~clk; 
endmodule

