	`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:23:48 01/23/2011
// Design Name:   Synthesis Filtering
// Module Name:   C:/Users/Nick/Documents/Spring2010/G.729 Verilog Code/Convolve/syn_filt_test.v
// Project Name:  Synthesis Filtering
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Synthesis Filtering
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module syn_filt_test;

`include "paramList.v"

	// Inputs
	reg clk;
	reg reset;
	reg start;		
	reg [11:0] xAddr;
	reg [11:0] aAddr;
	reg [11:0] yAddr;
	reg [11:0] fMemAddr;
	reg [11:0] updateAddr;

	// Outputs	
	wire done;
	wire [31:0] memIn;
	
	//Mux0 regs	
	reg lagMuxSel;
	reg [11:0] lagMuxOut;
	reg [11:0] testReadRequested;
	//Mux1 regs	
	reg lagMux1Sel;
	reg [11:0] lagMux1Out;
	reg [11:0] testWriteRequested;
	//Mux2 regs	
	reg lagMux2Sel;
	reg [31:0] lagMux2Out;
	reg [31:0] testWriteOut;
	//Mux3 regs	
	reg lagMux3Sel;
	reg lagMux3Out;
	reg testWriteEnable;
	integer i, j;

	// Instantiate the Unit Under Test (UUT)
	syn_filt_pipe uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.memIn(memIn), 
		.xAddr(xAddr), 
		.aAddr(aAddr), 
		.yAddr(yAddr), 
		.fMemAddr(fMemAddr), 
		.updateAddr(updateAddr),  
		.done(done), 
		.lagMuxSel(lagMuxSel), 
		.lagMux1Sel(lagMux1Sel), 
		.lagMux2Sel(lagMux2Sel), 
		.lagMux3Sel(lagMux3Sel), 
		.testReadRequested(testReadRequested), 
		.testWriteRequested(testWriteRequested), 
		.testWriteOut(testWriteOut), 
		.testWriteEnable(testWriteEnable)
	);
					
	reg [15:0] predictionVector[0:9999];
	reg [15:0] inVector[0:9999];
	reg [15:0] outVector[0:9999];
	reg [15:0] filterMemVector[0:9999];
	reg [15:0] updateVector[0:9999];
					 
	initial 
		begin
			// samples out are samples from ITU G.729 test vectors
			$readmemh("syn_filt_mem.out", filterMemVector);
			$readmemh("syn_filt_x_in.out", inVector);
			$readmemh("syn_filt_out.out", outVector);
			$readmemh("syn_filt_coeff.out", predictionVector);
			$readmemh("syn_filt_update.out", updateVector);
			//add update file here
		end

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;		
		lagMuxSel = 0;
		xAddr = 12'd560;
		aAddr = 12'd624;
		yAddr = 12'd688;
		fMemAddr = 12'd816;
		updateAddr = 12'd944;
		
		@(posedge clk) #5; 	
		reset = 1;		
		@(posedge clk) #5; 	
		reset = 0;
		// Wait 100 ns for global reset to finish
		@(posedge clk); 		
		@(posedge clk) #10; 
        
		for(j=0;j<2;j=j+1)
		begin
			//Test # 1
			@(posedge clk); 
			@(posedge clk) #5; 			
			lagMuxSel = 0;
			lagMux1Sel = 1;
			lagMux2Sel = 1;
			lagMux3Sel = 1;
			
			for(i=0;i<10;i=i+1)
			begin			
				@(posedge clk); 
				@(posedge clk) #5; 
				testWriteRequested = {fMemAddr[11:6],i[5:0]};
				testWriteOut = filterMemVector[(j*10)+i];
				testWriteEnable = 1;
				@(posedge clk); 
				@(posedge clk) #5; 
			end
			
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
			
			for(i=0;i<11;i=i+1)
			begin			
				@(posedge clk); 
				@(posedge clk) #5; 
				testWriteRequested = {aAddr[11:6],i[5:0]};
				testWriteOut = predictionVector[(j*11)+i];
				testWriteEnable = 1;
				@(posedge clk); 
				@(posedge clk) #5; 
			end
			
			for(i=0;i<40;i=i+1)
			begin			
				@(posedge clk); 
				@(posedge clk) #5; 
				testWriteRequested = {yAddr[11:6],i[5:0]};
				testWriteOut = outVector[(j*40)+i];
				testWriteEnable = 1;
				@(posedge clk); 
				@(posedge clk) #5; 
			end
			
			for(i=0;i<1;i=i+1)
			begin			
				@(posedge clk); 
				@(posedge clk) #5; 
				testWriteRequested = {updateAddr[11:0]};
				testWriteOut = updateVector[(j*1)];
				testWriteEnable = 1;
				@(posedge clk); 
				@(posedge clk) #5; 
			end
			
			@(posedge clk); 
			@(posedge clk) #5; 			
			lagMux1Sel = 0;
			lagMux2Sel = 0;
			lagMux3Sel = 0;
	
			
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
						$display($time, " ERROR: y'[%d] = %x, expected = %x", (j*40)+i, memIn, outVector[(j*40)+i]);
					else
						$display($time, " CORRECT:  y'[%d] = %x", (j*40)+i, memIn);
			end
		end	// end j loop

	end
	
initial forever #10 clk = ~clk; 
endmodule

