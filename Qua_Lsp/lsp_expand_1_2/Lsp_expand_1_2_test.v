`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:24:58 02/05/2011
// Module Name:    Lsp_Expand_1_2_test.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: Lsp_expand_1_2
// 
// Dependencies: 	 Lsp_Expand_1_2.v, Scratch_Memory_Controller.v, L_sub.v, L_add.v, sub.v, shr.v, add.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Lsp_expand_1_2_test;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;
	wire [15:0] subIn;
	wire [31:0] L_subIn;
	wire [15:0] shrIn;
	wire [15:0] addIn;
	wire [31:0] L_addIn;
	wire [31:0] memIn;
	reg [10:0] bufAddr;
	reg [3:0]  gap;

	// Outputs
	wire [15:0] subOutA;
	wire [15:0] subOutB;
	wire [31:0] L_subOutA;
	wire [31:0] L_subOutB;
	wire [15:0] shrVar1Out;
	wire [15:0] shrVar2Out;
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	wire [31:0] memOut;
	wire [10:0] memReadAddr;
	wire [10:0] memWriteAddr;
	wire memWriteEn;
	wire done;
	
	//working regs
	reg [15:0] expandInMem [0:9999];
	reg [15:0] expandOutMem [0:9999];
	reg [15:0] expandGapMem [0:9999];
	
	//Mux0 regs	
	reg expandMuxSel;
	reg [10:0] expandMuxOut;
	reg [10:0] testReadAddr;
	//mux1 regs
	reg expandMux1Sel;
	reg [10:0] expandMux1Out;
	reg [10:0] testWriteAddr;
	//mux2 regs
	reg expandMux2Sel;
	reg [31:0] expandMux2Out;
	reg [31:0] testMemOut;
	//mux3regs
	reg expandMux3Sel;
	reg expandMux3Out;
	reg testMemWriteEn;

	integer i,j;
	
		//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("speech_lsp_expand_1_2_in.out", expandInMem);
		$readmemh("speech_lsp_expand_1_2_out.out", expandOutMem);
		$readmemh("speech_lsp_expand_1_2_gap.out", expandGapMem);
	end
	
	//expand read address mux
	always @(*)
	begin
		case	(expandMuxSel)	
			'd0 :	expandMuxOut = memReadAddr;
			'd1:	expandMuxOut = testReadAddr;
		endcase
	end
	
	//expand write address mux
	always @(*)
	begin
		case	(expandMux1Sel)	
			'd0 :	expandMux1Out = memWriteAddr;
			'd1:	expandMux1Out = testWriteAddr;
		endcase
	end
	
	//expand write input mux
	always @(*)
	begin
		case	(expandMux2Sel)	
			'd0 :	expandMux2Out = memOut;
			'd1:	expandMux2Out = testMemOut;
		endcase
	end
	
	//expand write enable mux
	always @(*)
	begin
		case	(expandMux3Sel)	
			'd0 :	expandMux3Out = memWriteEn;
			'd1:	expandMux3Out = testMemWriteEn;
		endcase
	end
	
	// Instantiate the Unit Under Test (UUT)
	Lsp_expand_1_2 uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.subIn(subIn), 
		.L_subIn(L_subIn), 
		.shrIn(shrIn), 
		.addIn(addIn),
		.L_addIn(L_addIn),
		.memIn(memIn), 
		.bufAddr(bufAddr),
		.gap(gap),
		.subOutA(subOutA), 
		.subOutB(subOutB), 
		.L_subOutA(L_subOutA), 
		.L_subOutB(L_subOutB), 
		.shrVar1Out(shrVar1Out), 
		.shrVar2Out(shrVar2Out), 
		.addOutA(addOutA), 
		.addOutB(addOutB), 
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.memOut(memOut), 
		.memReadAddr(memReadAddr), 
		.memWriteAddr(memWriteAddr), 
		.memWriteEn(memWriteEn), 
		.done(done)
	);

		Scratch_Memory_Controller testMem(
												 .addra(expandMux1Out),
												 .dina(expandMux2Out),
												 .wea(expandMux3Out),
												 .clk(clk),
												 .addrb(expandMuxOut),
												 .doutb(memIn)
												 );
	L_sub expand_L_sub(
								.a(L_subOutA),
								.b(L_subOutB),
								.overflow(),
								.diff(L_subIn)
							);
	
	L_add expand_L_add(
								.a(L_addOutA),
								.b(L_addOutB),
								.overflow(),
								.sum(L_addIn)
								);
							
	sub expand_sub(
						  .a(subOutA),
						  .b(subOutB),
						  .overflow(),
						  .diff(subIn)
						);	
						
	 shr expand_shr(
					  .var1(shrVar1Out),
					  .var2(shrVar2Out),
					  .overflow(),
					  .result(shrIn)
				  );
	
	add expand_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
						);
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		testReadAddr = 0;
		testWriteAddr = 0;
		testMemOut = 0;
		testMemWriteEn = 0;
		bufAddr = RELSPWED_BUF;
		
		// Wait 50 ns for global reset to finish
		#50;
		reset = 1;
		#50;
		reset = 0;
		#50;
		for(j=0;j<120;j=j+1)
		begin
		
		//writing the previous modules to memory
			expandMuxSel = 0;
			expandMux1Sel = 0;
			expandMux2Sel = 0;
			expandMux3Sel = 0;
			gap = expandGapMem[j];
			
			for(i=0;i<11;i=i+1)
			begin
				#100;
				expandMux1Sel = 1;
				expandMux2Sel = 1;
				expandMux3Sel = 1;
				testWriteAddr = {RELSPWED_BUF[10:4],i[3:0]};
				testMemOut = expandInMem[j*10+i];
				testMemWriteEn = 1;	
				#100;
			end
			expandMux1Sel = 0;
			expandMux2Sel = 0;
			expandMux3Sel = 0;
			 
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here		
		
			wait(done);
			#100;
			expandMuxSel = 1;
			for (i = 0; i<10;i=i+1)
			begin				
					testReadAddr = {RELSPWED_BUF[10:4],i[3:0]};
					@(posedge clk);
					@(posedge clk);
					if (memIn != expandOutMem[10*j+i])
						$display($time, " ERROR: buf[%d] = %x, expected = %x", 10*j+i, memIn, expandOutMem[10*j+i]);
					else if (memIn == expandOutMem[10*j+i])
						$display($time, " CORRECT:  buf[%d] = %x", 10*j+i, memIn);
					@(posedge clk);
	
				end
		end// for loop j

	end//initial
     
initial forever #10 clk = ~clk;	  
endmodule