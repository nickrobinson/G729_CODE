`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:47:24 03/31/2011
// Design Name:   ACELP_Codebook_pipe
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Spring 2011/Senior Design II/G729 Verilog Code/ACELP_Codebook/ACELP_Codebook_test.v
// Project Name:  ACELP_Codebook
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ACELP_Codebook_pipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ACELP_Codebook_test;
`include "paramList.v"

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [15:0] T0;
	reg [15:0] pitch_sharp;
	reg [15:0] i_subfr;
	reg codebookMuxSel;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;
	reg testMemWriteEn;

	// Outputs
	wire [15:0] index;
	wire [31:0] memIn;
	wire done;
	
	//temp regs
	reg [15:0] xMem [0:9999];
	reg [15:0] hMem [0:9999];
	reg [15:0] T0Mem[0:9999];
	reg [15:0] pitchMem[0:9999];
	reg [15:0] i_subfrMem[0:9999];
	reg [15:0] codeMem[0:99999];
	reg [15:0] signMem[0:9999];
	reg [15:0] yMem[0:9999];
	reg [15:0] indexMem[0:9999];
   //loop integers
	integer i,j;
	
	//file read in for inputs and output tests
	initial 
		begin// samples out are samples from ITU G.729 test vectors
			$readmemh("lsp_acelp_x_in.out", xMem);			
			$readmemh("lsp_acelp_h_in.out", hMem);
			$readmemh("lsp_acelp_t0_in.out", T0Mem);
			$readmemh("lsp_acelp_pitch_in.out", pitchMem);
			$readmemh("lsp_acelp_isubfr_in.out", i_subfrMem);
			$readmemh("lsp_acelp_code_out.out", codeMem);
			$readmemh("lsp_acelp_y_out.out", yMem);
			$readmemh("lsp_acelp_sign_out.out", signMem);
			$readmemh("lsp_acelp_index_out.out", indexMem);
		end
		
	// Instantiate the Unit Under Test (UUT)
	ACELP_Codebook_pipe uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.T0(T0), 
		.pitch_sharp(pitch_sharp), 
		.i_subfr(i_subfr), 
		.codebookMuxSel(codebookMuxSel), 
		.testReadAddr(testReadAddr), 
		.testWriteAddr(testWriteAddr), 
		.testMemOut(testMemOut), 
		.testMemWriteEn(testMemWriteEn), 
		.index(index), 
		.memIn(memIn), 
		.done(done)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		T0 = 0;
		pitch_sharp = 0;
		i_subfr = 0;
		codebookMuxSel = 1;
		testReadAddr = 0;
		testWriteAddr = 0;
		testMemOut = 0;
		testMemWriteEn = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
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
			pitch_sharp = pitchMem[j];
			T0 = T0Mem[j];
			
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
				testMemOut = xMem[40*j+i];				
				testWriteAddr = {XN2[11:6], i[5:0]};				
				testMemWriteEn = 1;				
			end          
		  
			@(posedge clk);
			@(posedge clk) #5;
			
			codebookMuxSel = 0;	
			testMemWriteEn = 0;
			testWriteAddr = 0;
			
			@(posedge clk);
			@(posedge clk) #5;		
			start = 1;
			@(posedge clk);
			@(posedge clk) #5;
			start = 0;
			@(posedge clk);
			@(posedge clk) #5;
			
			wait(done);
			codebookMuxSel = 1;
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
				if(memIn != codeMem[j*40+i])
					$display($time, " ERROR: cod[%d] = %x, expected = %x", j*40+i, memIn, codeMem[j*40+i]);
				else if (memIn == codeMem[j*40+i])
					$display($time, " CORRECT:  cod[%d] = %x", j*40+i, memIn);
				@(posedge clk)#5; 
			end
			
			@(posedge clk)#5; 
			testReadAddr = TOP_LEVEL_I;
			@(posedge clk);
			@(posedge clk) #5;
			if(memIn != signMem[j])
				$display($time, " ERROR: sign[%d] = %x, expected = %x", j, memIn,signMem[j]);
			else if (memIn == signMem[j])
				$display($time, " CORRECT:  sign[%d] = %x", j, memIn);
			@(posedge clk)#5;				
			
			if(index != indexMem[j])
				$display($time, " ERROR: index[%d] = %x, expected = %x", j, index,indexMem[j]);
			else if (index == indexMem[j])
				$display($time, " CORRECT:  index[%d] = %x", j, index);
			@(posedge clk)#5;
			
			@(posedge clk);
			@(posedge clk);
			@(posedge clk) #5;
		end//j loop

	end//initial

initial forever #10 clk = ~clk;	         
 
endmodule

