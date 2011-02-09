`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    20:22:47 02/08/2011
// Module Name:    Lsp_prev_update.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Verilog Test Fixture created by ISE for module: Lsp_prev_update
// 
// Dependencies: 	 Lsp_prev_update.v, Scratch_Memory_Controller.v,  L_add.v, sub.v,  add.v, copy.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Lsp_prev_update_test;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [10:0] lsp_eleAddr;
	reg [10:0] freq_prevAddr;
	wire [15:0] subIn;
	wire [15:0] addIn;
	wire [31:0] L_addIn;
	wire [31:0] memIn;


	// Outputs
	wire [15:0] subOutA;
	wire [15:0] subOutB;
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
	reg [15:0] updateInFreqMem [0:9999];
	reg [15:0] updateInEleMem [0:9999];
	reg [15:0] updateOutMem [0:9999];
	
	//Mux0 regs	
	reg updateMuxSel;
	reg [10:0] updateMuxOut;
	reg [10:0] testReadAddr;
	//mux1 regs
	reg updateMux1Sel;
	reg [10:0] updateMux1Out;
	reg [10:0] testWriteAddr;
	//mux2 regs
	reg updateMux2Sel;
	reg [31:0] updateMux2Out;
	reg [31:0] testMemOut;
	//mux3regs
	reg updateMux3Sel;
	reg updateMux3Out;
	reg testMemWriteEn;

	integer i,j,k;
	
		//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("lsp_lsp_update_freq_in.out", updateInFreqMem);
		$readmemh("lsp_lsp_update_ele_in.out", updateInEleMem);
		$readmemh("lsp_lsp_update_out.out", updateOutMem);
	end
	
	//update read address mux
	always @(*)
	begin
		case	(updateMuxSel)	
			'd0 :	updateMuxOut = memReadAddr;
			'd1:	updateMuxOut = testReadAddr;
		endcase
	end
	
	//update write address mux
	always @(*)
	begin
		case	(updateMux1Sel)	
			'd0 :	updateMux1Out = memWriteAddr;
			'd1:	updateMux1Out = testWriteAddr;
		endcase
	end
	
	//update write input mux
	always @(*)
	begin
		case	(updateMux2Sel)	
			'd0 :	updateMux2Out = memOut;
			'd1:	updateMux2Out = testMemOut;
		endcase
	end
	
	//update write enable mux
	always @(*)
	begin
		case	(updateMux3Sel)	
			'd0 :	updateMux3Out = memWriteEn;
			'd1:	updateMux3Out = testMemWriteEn;
		endcase
	end
	
	// Instantiate the Unit Under Test (UUT)
    Lsp_prev_update uut( 
								.clk(clk), 
								.reset(reset), 
								.start(start), 
								.addIn(addIn),
								.subIn(subIn),		
								.L_addIn(L_addIn),
								.memIn(memIn),
								.lsp_eleAddr(lsp_eleAddr),
								.freq_prevAddr(freq_prevAddr),
								.addOutA(addOutA), 
								.addOutB(addOutB), 
								.subOutA(subOutA), 
								.subOutB(subOutB), 		
								.L_addOutA(L_addOutA), 
								.L_addOutB(L_addOutB), 
								.memOut(memOut), 
								.memReadAddr(memReadAddr), 
								.memWriteAddr(memWriteAddr), 
								.memWriteEn(memWriteEn), 
								.done(done)
								);

		Scratch_Memory_Controller testMem(
												 .addra(updateMux1Out),
												 .dina(updateMux2Out),
												 .wea(updateMux3Out),
												 .clk(clk),
												 .addrb(updateMuxOut),
												 .doutb(memIn)
												 );
	
	L_add update_L_add(
								.a(L_addOutA),
								.b(L_addOutB),
								.overflow(),
								.sum(L_addIn)
								);
							
	sub update_sub(
						  .a(subOutA),
						  .b(subOutB),
						  .overflow(),
						  .diff(subIn)
						);		 
	
	add update_add(
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
		freq_prevAddr = 11'd64;
		lsp_eleAddr = 11'd1024;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 1;
		#50;
		reset = 0;
		#50;
		for(j=0;j<120;j=j+1)
		begin
		
		//writing the previous modules to memory
			updateMuxSel = 0;
			updateMux1Sel = 0;
			updateMux2Sel = 0;
			updateMux3Sel = 0;
			
			for(k=0;k<4;k=k+1)
			begin
				for(i=0;i<10;i=i+1)
				begin
					#100;
					updateMux1Sel = 1;
					updateMux2Sel = 1;
					updateMux3Sel = 1;
					testWriteAddr = {freq_prevAddr[10:6],k[1:0],i[3:0]};
					testMemOut = updateInFreqMem[40*j+(k*10+i)];
					testMemWriteEn = 1;	
					#100;
				end
			end
			
			for(i=0;i<10;i=i+1)
			begin
				#100;
				updateMux1Sel = 1;
				updateMux2Sel = 1;
				updateMux3Sel = 1;
				testWriteAddr = {lsp_eleAddr[10:4],i[3:0]};
				testMemOut = updateInEleMem[j*10+i];
				testMemWriteEn = 1;	
				#100;
			end
			updateMux1Sel = 0;
			updateMux2Sel = 0;
			updateMux3Sel = 0;
			 
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here		
		
			wait(done);
			#100;
			updateMuxSel = 1;
			for(k=0; k<4; k=k+1)
				begin
				for (i = 0; i<10;i=i+1)
				begin				
						testReadAddr = {freq_prevAddr[10:6],k[1:0],i[3:0]};
						@(posedge clk);
						@(posedge clk);
						if (memIn != updateOutMem[40*j+(k*10+i)])
							$display($time, " ERROR: freq_prev[%d] = %x, expected = %x", 40*j+(k*10+i), memIn, updateOutMem[40*j+(k*10+i)]);
						else if (memIn == updateOutMem[40*j+(k*10+i)])
							$display($time, " CORRECT:  freq_prev[%d] = %x", 40*j+(k*10+i), memIn);
						@(posedge clk);
		
					end
					#50;
				end//k loop
		end// for loop j

	end//initial
     
initial forever #10 clk = ~clk;	  
endmodule