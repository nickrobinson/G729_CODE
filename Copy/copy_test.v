`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:48:46 02/07/2011
// Module Name:    copy.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Verilog Test Fixture created by ISE for module: copy
// 
// Dependencies: 	 coyp.v, Scratch_Memory_Controller.v, add.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module copy_test;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [10:0] xAddr,yAddr;
	reg [15:0] L;
	wire [31:0] L_addIn;
	wire [15:0] addIn;
	wire [31:0] memIn;

	// Outputs
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;	
	wire [15:0] addOutA;
	wire [15:0] addOutB;	
	wire [31:0] memOut;
	wire [10:0] memReadAddr;
	wire [10:0] memWriteAddr;
	wire memWriteEn;
	wire done;
	
	//working regs
	reg [31:0] copyInMem [0:9999];
	reg [31:0] copyOutMem [0:9999];
	reg [15:0] copyLMem [0:9999];
	
	//Mux0 regs	
	reg copyMuxSel;
	reg [10:0] copyMuxOut;
	reg [10:0] testReadAddr;
	//mux1 regs
	reg copyMux1Sel;
	reg [10:0] copyMux1Out;
	reg [10:0] testWriteAddr;
	//mux2 regs
	reg copyMux2Sel;
	reg [31:0] copyMux2Out;
	reg [31:0] testMemOut;
	//mux3regs
	reg copyMux3Sel;
	reg copyMux3Out;
	reg testMemWriteEn;

	integer i,j,counter;
	
		//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("copy_in.out", copyInMem);
		$readmemh("copy_out.out", copyOutMem);
		$readmemh("copy_l.out", copyLMem);
	end
	
	//copy read address mux
	always @(*)
	begin
		case	(copyMuxSel)	
			'd0 :	copyMuxOut = memReadAddr;
			'd1:	copyMuxOut = testReadAddr;
		endcase
	end
	
	//copy write address mux
	always @(*)
	begin
		case	(copyMux1Sel)	
			'd0 :	copyMux1Out = memWriteAddr;
			'd1:	copyMux1Out = testWriteAddr;
		endcase
	end
	
	//copy write input mux
	always @(*)
	begin
		case	(copyMux2Sel)	
			'd0 :	copyMux2Out = memOut;
			'd1:	copyMux2Out = testMemOut;
		endcase
	end
	
	//copy write enable mux
	always @(*)
	begin
		case	(copyMux3Sel)	
			'd0 :	copyMux3Out = memWriteEn;
			'd1:	copyMux3Out = testMemWriteEn;
		endcase
	end
	
	// Instantiate the Unit Under Test (UUT)
	copy uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 		
		.addIn(addIn),	
		.L_addIn(L_addIn),
		.memIn(memIn),  
		.addOutA(addOutA), 
		.addOutB(addOutB),
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB),
		.xAddr(xAddr),
		.yAddr(yAddr),
		.L(L),
		.memOut(memOut), 
		.memReadAddr(memReadAddr), 
		.memWriteAddr(memWriteAddr), 
		.memWriteEn(memWriteEn), 
		.done(done)
	);

		Scratch_Memory_Controller testMem(
												 .addra(copyMux1Out),
												 .dina(copyMux2Out),
												 .wea(copyMux3Out),
												 .clk(clk),
												 .addrb(copyMuxOut),
												 .doutb(memIn)
												 );	
	
	add copy_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
						);
						
	L_add copy_L_add(
							.a(L_addOutA),
							.b(L_addOutB),
							.overflow(),
							.sum(L_addIn)
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
		xAddr = 11'd16;
		yAddr = 11'd1024;
		counter = 0;
		
		// Wait 50 ns for global reset to finish
		#50;
		reset = 1;
		#50;
		reset = 0;
		#50;
		for(j=0;j<1200;j=j+1)
		begin
		
		L = copyLMem[j];		
		//writing the previous modules to memory
			copyMuxSel = 0;
			copyMux1Sel = 0;
			copyMux2Sel = 0;
			copyMux3Sel = 0;
			
			for(i=0;i<L;i=i+1)
			begin
				#100;
				copyMux1Sel = 1;
				copyMux2Sel = 1;
				copyMux3Sel = 1;
				testWriteAddr = xAddr + i;
				testMemOut = copyInMem[counter+i];
				testMemWriteEn = 1;	
				#100;
			end
			copyMux1Sel = 0;
			copyMux2Sel = 0;
			copyMux3Sel = 0;
			testMemWriteEn = 0;
			
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here		
		
			wait(done);
			#100;
			copyMuxSel = 1;
			for (i = 0; i<10;i=i+1)
			begin				
					testReadAddr = {yAddr[10:4],i[3:0]};
					#50;
					if (memIn != copyOutMem[counter+i])
						$display($time, " ERROR: copy[%d] = %x, expected = %x", counter+i, memIn, copyOutMem[counter+i]);
					else if (memIn == copyOutMem[counter+i])
						$display($time, " CORRECT:  copy[%d] = %x", counter+i, memIn);
					@(posedge clk);
	
				end
				counter = counter+L;
				#100;
		end// for loop j

	end//initial
     
initial forever #10 clk = ~clk;	  
endmodule