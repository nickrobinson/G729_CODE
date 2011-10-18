`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    13:32:56 02/12/2011
// Module Name:    Lsp_Expand_1_2_test.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: Lsp_stability_FSM
// 
// Dependencies: 	 LSP_stability_pipe.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module LSP_stability_test;
`include "constants_param_list.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [11:0] bufAddr;
	
	// Outputs
	wire done;
	wire [31:0] memIn;
	
	//working regs
	reg [15:0] stabilityInMem [0:9999];
	reg [15:0] stabilityOutMem [0:9999];	

	reg stabilityMuxSel;
	reg [11:0] testReadAddr;
	reg [11:0] testWriteAddr;
	reg [31:0] testMemOut;	
	reg testMemWriteEn;
	
	integer i,j;
	
		//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("speech_lsp_stability_in.out", stabilityInMem);
		$readmemh("speech_lsp_stability_out.out", stabilityOutMem);
	end   
	
	// Instantiate the Unit Under Test (UUT)
	LSP_stability_pipe pipey(
									 .clk(clk),
									 .reset(reset),
									 .start(start),
									 .stabilityMuxSel(stabilityMuxSel),
									 .testReadAddr(testReadAddr),
									 .testWriteAddr(testWriteAddr),
									 .testMemOut(testMemOut),
									 .testMemWriteEn(testMemWriteEn),
									 .bufAddr(bufAddr),
									 .memIn(memIn),
									 .done(done) 
									 );
						
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		bufAddr = 256;
		testReadAddr = 0;
		testWriteAddr = 0;
		testMemOut = 0;
		testMemWriteEn = 0;
		stabilityMuxSel = 1;
		
		// Wait 50 ns for global reset to finish
		#50;
		reset = 1;
		#50;
		reset = 0;
		#50;
		for(j=0;j<120;j=j+1)
		begin		
		//writing the previous modules to memory
					
			for(i=0;i<10;i=i+1)
			begin
				#100;				
				testWriteAddr = {bufAddr[11:4],i[3:0]};
				testMemOut = stabilityInMem[j*10+i];
				testMemWriteEn = 1;	
				#100;
			end
			
			stabilityMuxSel = 0;		
			#100;			
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here		
         wait(done);
			#100;
			stabilityMuxSel = 1;
			for (i = 0; i<10;i=i+1)
			begin				
					testReadAddr = {bufAddr[11:4],i[3:0]};
					#50;
					if (memIn != stabilityOutMem[10*j+i])
						$display($time, " ERROR: buf[%d] = %x, expected = %x", 10*j+i, memIn, stabilityOutMem[10*j+i]);
					else if (memIn == stabilityOutMem[10*j+i])
						$display($time, " CORRECT:  buf[%d] = %x", 10*j+i, memIn);
					@(posedge clk);	
				end
		// Add stimulus here
		end//j loop
	end//initial
	
initial forever #10 clk = ~clk;	       
endmodule

