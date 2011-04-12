`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:37:41 01/27/2011
// Design Name:   Weight_Az
// Module Name:   C:/XilinxProjects/weight_az/Weight_Az_test.v
// Project Name:  weight_az
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Weight_Az
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Weight_Az_test_v;
`include "paramList.v"

	// Inputs
	reg start;
	reg clk;
	reg reset;
	reg [11:0] A;
	reg [11:0] AP;
	reg [11:0] gammaAddr;	
	
	//Outputs
	wire done;

	//intermediary wires
	wire [31:0] readIn;
	
		
	integer i, j;
	
	reg wazMuxSel;
	reg [11:0] wazReadRequested;
	reg wazMux1Sel;
	reg [11:0] wazWriteRequested;
	reg wazMux2Sel;
	reg [31:0] wazOut;
	reg wazMux3Sel;
	reg wazWrite;
	

	//I/O regs
	//working regs
	reg [15:0] ac [0:9999];
	reg [15:0] gammac [0:9999];
	reg [15:0] apc [0:399];


	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("WEIGHT_AZ_A_IN.out", ac);
			$readmemh("WEIGHT_AZ_GAMMA_IN.out", gammac);
			$readmemh("WEIGHT_AZ_AP_OUT.out", apc);
		end
		
		
		

	// Instantiate the Unit Under Test (UUT)
	Weight_Az_Top uut (
		.start(start), 
		.clk(clk), 
		.done(done), 
		.reset(reset), 
		.A(A), 
		.AP(AP), 
		.gammaAddr(gammaAddr),
		.wazReadRequested(wazReadRequested),
		.wazWriteRequested(wazWriteRequested), 
		.wazOut(wazOut),
		.wazWrite(wazWrite),
		.wazMuxSel(wazMuxSel),
		.wazMux1Sel(wazMux1Sel), 
		.wazMux2Sel(wazMux2Sel), 
		.wazMux3Sel(wazMux3Sel),
		.readIn(readIn)
		);	
	
	

	initial begin
		// Initialize Inputs
                #100;
		start = 0;
		clk = 0;
		reset = 0;
		A = 12'd768;
		AP = 12'd528;
		gammaAddr = 12'd448;
		
		#50
		reset = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 0;
		
		for(j=0;j<60;j=j+1)
		begin
			//TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 
			wazMuxSel = 1;
			wazMux1Sel = 0;
			wazMux2Sel = 0;
			wazMux3Sel = 0;
			wazWrite = 0;
			
			for(i=0;i<11;i=i+1)
			begin
				#100;
				wazWriteRequested = {A_T[11:4],i[3:0]};
				wazOut = ac[11*j+i];
				wazWrite = 1;	
				#100;			
			end
			
			#100;
				wazWriteRequested = {PERC_VAR_GAMMA1[11:0]};
				wazOut = gammac[j];
				wazWrite = 1;	
				#100;
			
			wazMux1Sel = 1;
			wazMux2Sel = 1;
			wazMux3Sel = 1;		
	
			#50;		
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here	
			wait(done);
			wazMuxSel = 0;
			

			
			//ap read
			for (i = 0; i<11;i=i+1)
			begin				
					wazReadRequested = {WEIGHT_AZ_AP_OUT[11:4],i[3:0]};
					@(posedge clk);
					@(posedge clk);
					if (readIn != apc[j*11+i])
						$display($time, " ERROR: apc[%d] = %x, expected = %x", j*11+i, readIn, apc[j*11+i]);
					else if (readIn == apc[j*11+i])
						$display($time, " CORRECT:  apc[%d] = %x", j*11+i, readIn);
					@(posedge clk);
			end	
				
		end//j for loop
			
	end
      initial forever #10 clk = ~clk;	       
endmodule

