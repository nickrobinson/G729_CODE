`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    12:49:31 01/15/2011 
// Module Name:    percVarFSM 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a test bench for the percVarFSM
// Dependencies: 	 L_mult.v, L_shr.v, L_sub.v, add.v, mult.v, percVarFSM.v, shl.v, sub.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module perc_var_test_v;

`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;


	wire [31:0] memIn;
	wire done;	
	
	//Memory Mux regs
	reg percVarMuxSel;
	reg testMemWrite;
	reg [10:0] testWriteAddr;
	reg [10:0] testReadAddr;
	reg [31:0] testMemOut;
	
	//I/O regs
	//working regs
	reg [15:0] gamma1 [0:4999];
	reg [15:0] gamma2 [0:4999];
	reg [15:0] lsfInt [0:9999];
	reg [15:0] lsfNew [0:9999];
	reg [15:0] rc [0:399];
	
	

	integer i,j;
	// Instantiate the Unit Under Test (UUT)
	percVar_Top_Level uut (
		.clk(clk), 
		.reset(reset), 
		.start(start),
		.percVarMuxSel(percVarMuxSel),
		.testMemWrite(testMemWrite),
		.testMemOut(testMemOut),
		.testWriteAddr(testWriteAddr),
		.testReadAddr(testReadAddr),
		.memIn(memIn),
		.done(done)
	);
	


	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("tame_percvar_lsf_int_in.out", lsfInt);
		$readmemh("tame_percvar_lsf_new_in.out", lsfNew);
		$readmemh("tame_percvar_rc_in.out", rc);
		$readmemh("tame_percvar_gamma1_out.out", gamma1);
		$readmemh("tame_percvar_gamma2_out.out", gamma2);
	end
	


	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		percVarMuxSel = 0;
		testMemWrite = 0;
		testWriteAddr = 0;
		testReadAddr = 0;
		testMemOut = 0;		
		
		#100;
		// Wait 100 ns for global reset to finish
		
		#50;
		reset = 1;
		#50;
		reset = 0;
		#50;
			
		for(j=0;j<60;j=j+1)
		begin
			//TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 
			percVarMuxSel = 0;
			testReadAddr = 0;
			
			for(i=0;i<10;i=i+1)
			begin
				#100;
				percVarMuxSel = 1;
				testWriteAddr = {LEVINSON_DURBIN_RC[10:5],i[4:0]};
				testMemOut = rc[10*j+i];
				testMemWrite = 1;	
				#100;			
			end
			
			for(i=0;i<10;i=i+1)
			begin
				#100;
				percVarMuxSel = 1;
				testWriteAddr = {INTERPOLATION_LSF_INT[10:5],i[4:0]};
				testMemOut = lsfInt[10*j+i];
				testMemWrite = 1;	
				#100;
			end
			
			for(i=0;i<10;i=i+1)
			begin
				#100;
				percVarMuxSel = 1;
				testWriteAddr = {INTERPOLATION_LSF_NEW[10:4],i[3:0]};
				testMemOut = lsfNew[10*j+i];
				testMemWrite = 1;	
				#100;
			end
			
			percVarMuxSel = 0;	
	
			#50;		
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here	
			wait(done);
			percVarMuxSel = 1;
			//gamma1 read
			for (i = 0; i<2;i=i+1)
			begin				
					testReadAddr = {PERC_VAR_GAMMA1[10:1],i[0]};
					@(posedge clk);
					@(posedge clk);
					if (memIn != gamma1[j*2+i])
						$display($time, " ERROR: gamma1[%d] = %x, expected = %x", i, memIn, gamma1[j*2+i]);
					else if (memIn == gamma1[j*2+i])
						$display($time, " CORRECT:  gamma1[%d] = %x", i, memIn);
					@(posedge clk);
			end	
			
			//gamma2 read
			for (i = 0; i<2;i=i+1)
			begin				
					testReadAddr = {PERC_VAR_GAMMA2[10:1],i[0]};
					@(posedge clk);
					@(posedge clk);
					if (memIn != gamma2[j*2+i])
						$display($time, " ERROR: gamma2[%d] = %x, expected = %x", i, memIn, gamma2[j*2+i]);
					else if (memIn == gamma2[j*2+i])
						$display($time, " CORRECT:  gamma2[%d] = %x", i, memIn);
					@(posedge clk);
			end
			
		end//j for loop
	end
 initial forever #10 clk = ~clk;	       
endmodule

