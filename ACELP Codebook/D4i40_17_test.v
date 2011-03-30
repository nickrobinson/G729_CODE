`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:36:51 03/25/2011
// Design Name:   D4i40_17_pipe
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Spring 2011/Senior Design II/G729 Verilog Code/ACELP_Codebook/D4i40_17_test.v
// Project Name:  ACELP_Codebook
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: D4i40_17_pipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module D4i40_17_test;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [15:0] i_subfr;
	reg D17MuxSel;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	// Outputs
	wire done;
	wire [15:0] iIn;
	wire [31:0] memIn;
	
	//temp regs
	reg [15:0] codMem [0:9999];
	reg [15:0] dnMem [0:9999];
	reg [15:0] extraMem[0:9999];
	reg [15:0] hMem[0:9999];
	reg [15:0] i_subfrMem[0:9999];
	reg [15:0] rrMem[0:99999];
	reg [15:0] signMem[0:9999];
	reg [15:0] yMem[0:9999];
	reg [15:0] outMem[0:9999];
	
   //loop integers
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("lsp_D17_h_in.out", hMem);			
			$readmemh("lsp_D17_r_in.out", rrMem);
			$readmemh("lsp_D17_dn_in.out", dnMem);
			$readmemh("lsp_D17_i_subfr_in.out", i_subfrMem);
			$readmemh("lsp_D17_extra_out.out", extraMem);
			$readmemh("lsp_D17_cod_out.out", codMem);
			$readmemh("lsp_D17_y_out.out", yMem);
			$readmemh("lsp_D17_sign_out.out", signMem);
			$readmemh("lsp_D17_out.out", outMem);
		end

	// Instantiate the Unit Under Test (UUT)
	D4i40_17_pipe uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.i_subfr(i_subfr), 
		.D17MuxSel(D17MuxSel), 
		.testReadAddr(testReadAddr), 
		.testWriteAddr(testWriteAddr), 
		.testMemOut(testMemOut), 
		.testMemWriteEn(testMemWriteEn), 
		.done(done), 
		.i(iIn), 
		.memIn(memIn)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		i_subfr = 0;
		D17MuxSel = 1;
		testReadAddr = 0;
		testWriteAddr = 0;
		testMemOut = 0;
		testMemWriteEn = 0;
		
		@(posedge clk);
		@(posedge clk) #5;
		reset = 1;
		// Wait 45 ns for global reset to finish
		@(posedge clk);
		@(posedge clk) #5;
		reset = 0;

		for(j=0;j<60;j=j+1)
		begin
			
			i_subfr = i_subfrMem[j];
			
			for(i=0;i<40;i=i+1)
			begin
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;				
				testMemOut = hMem[40*j+i];				
				testWriteAddr = {H1[11:6], i[5:0]};				
				testMemWriteEn = 1;	
				@(posedge clk);
				@(posedge clk);
				@(posedge clk) #5;
				testMemOut = dnMem[40*j+i];				
				testWriteAddr = {ACELP_DN[11:6], i[5:0]};				
				testMemWriteEn = 1;				
			end
        
		  for(i=0;i<616;i=i+1)
		  begin
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;				
			testMemOut = rrMem[616*j+i];				
			testWriteAddr = {ACELP_RR[11:10], i[9:0]};				
			testMemWriteEn = 1;	
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;	
		  end
		  
			D17MuxSel = 0;	
			testMemWriteEn = 0;	
			@(posedge clk);
			@(posedge clk) #5;		
			start = 1;
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);
			@(posedge clk) #5;
			
			wait(done);
			D17MuxSel = 1;
			@(posedge clk);
			@(posedge clk) #5;
			
			for(i=0;i<40;i=i+1)
			begin
				testReadAddr = {Y2[11:6],i[5:0]};
				@(posedge clk);
			   @(posedge clk) #5;
				if(memIn != yMem[j*40+i])
					$display($time, " ERROR: y[%d] = %x, expected = %x", j*40+i, memIn, yMem[j*40+i]);
				else if (memIn == yMem[j*40+i])
					$display($time, " CORRECT:  y[%d] = %x", j*40+i, memIn);
				@(posedge clk)#5; 
			end
			
			for(i=0;i<40;i=i+1)
			begin
				@(posedge clk)#5; 
				testReadAddr = {CODE[11:6],i[5:0]};
				@(posedge clk);
			   @(posedge clk) #5;
				if(memIn != codMem[j*40+i])
					$display($time, " ERROR: cod[%d] = %x, expected = %x", j*40+i, memIn, codMem[j*40+i]);
				else if (memIn == codMem[j*40+i])
					$display($time, " CORRECT:  cod[%d] = %x", j*40+i, memIn);
				@(posedge clk)#5; 
			end
			
			@(posedge clk)#5; 
			testReadAddr = ACELP_EXTRA;
			@(posedge clk);
			@(posedge clk) #5;
			if(memIn != extraMem[j])
				$display($time, " ERROR: extra[%d] = %x, expected = %x", j, memIn,extraMem[j]);
			else if (memIn == extraMem[j])
				$display($time, " CORRECT:  extra[%d] = %x", j, memIn);
			@(posedge clk)#5; 
			
			@(posedge clk)#5; 
			testReadAddr = TOP_LEVEL_I;
			@(posedge clk);
			@(posedge clk) #5;
			if(memIn != signMem[j])
				$display($time, " ERROR: sign[%d] = %x, expected = %x", j, memIn,signMem[j]);
			else if (memIn == signMem[j])
				$display($time, " CORRECT:  sign[%d] = %x", j, memIn);
			@(posedge clk)#5;				
			
			if(iIn != outMem[j])
				$display($time, " ERROR: i[%d] = %x, expected = %x", j, iIn,outMem[j]);
			else if (iIn == outMem[j])
				$display($time, " CORRECT:  i[%d] = %x", j, iIn);
			@(posedge clk)#5;
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
		end//j loop
	end//initial

initial forever #10 clk = ~clk;	        
endmodule

