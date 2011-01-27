`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    13:21:02 10/17/2010
// Module Name:    lag_window
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A test bench to test the lag window module, which performs
//						 the computation of the r'(k) coefficients
//
// Dependencies: 	 lag_window,L_mult,L_mac,mult
//						 Verilog Test Fixture created by ISE for module: lag_window
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module lag_window_test_v;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;	
	wire [31:0] L_multIn;
	wire [15:0] multIn;
	wire [31:0] L_macIn;
	wire [31:0] L_msuIn;
	wire [15:0] addIn;
	wire [31:0] L_shrIn;

	// Outputs
	wire rPrimeWrite;
	wire [10:0] rPrimeRequested;
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire [15:0] multOutA;
	wire [15:0] multOutB;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire [15:0] L_msuOutA;
	wire [15:0] L_msuOutB;
	wire [31:0] L_msuOutC;
	wire [31:0] rPrimeOut;
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [15:0] L_shrOutNumShift;
	wire [31:0] L_shrOutVar1;
	wire done;
	
	//working wires
	wire [31:0] rPrimeIn;

	//working regs
	reg [31:0] rMem [0:9999];		  
	reg [31:0] rPrimeMem [0:9999];
	//Mux0 regs	
	reg lagMuxSel;
	reg [10:0] lagMuxOut;
	reg [10:0] testReadRequested;
	//Mux1 regs	
	reg lagMux1Sel;
	reg [10:0] lagMux1Out;
	reg [10:0] testWriteRequested;
	//Mux2 regs	
	reg lagMux2Sel;
	reg [31:0] lagMux2Out;
	reg [31:0] testWriteOut;
	//Mux3 regs	
	reg lagMux3Sel;
	reg lagMux3Out;
	reg testWriteEnable;
	integer i,j;
	
	// Instantiate the Unit Under Test (UUT)
	lag_window uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.rPrimeIn(rPrimeIn), 
		.L_multIn(L_multIn), 
		.multIn(multIn), 
		.L_macIn(L_macIn),
		.L_msuIn(L_msuIn), 
		.addIn(addIn),
		.L_shrIn(L_shrIn),
		.rPrimeWrite(rPrimeWrite), 
		.rPrimeRequested(rPrimeRequested), 
		.L_multOutA(L_multOutA), 
		.L_multOutB(L_multOutB), 
		.multOutA(multOutA), 
		.multOutB(multOutB), 
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC),
		.L_msuOutA(L_msuOutA), 
		.L_msuOutB(L_msuOutB), 
		.L_msuOutC(L_msuOutC), 		
		.rPrimeOut(rPrimeOut), 
		.addOutA(addOutA),
		.addOutB(addOutB),
		.L_shrOutVar1(L_shrOutVar1),
		.L_shrOutNumShift(L_shrOutNumShift),
		.done(done)
	);
	
	L_mult lag_L_mult(
			 .a(L_multOutA),
			 .b(L_multOutB),
			 .overflow(),
			 .product(L_multIn));
			 
	mult lag_mult(
					.a(multOutA), 
					.b(multOutB),
					.overflow(),
					.product(multIn));
	
			 
	L_mac lag_L_mac(
					.a(L_macOutA),
					.b(L_macOutB),
					.c(L_macOutC),
					.overflow(),
					.out(L_macIn));
	add lag_add(
					.a(addOutA),
					.b(addOutB),
					.overflow(),
					.sum(addIn)
					);
	L_shr lag_L_shr(
						 .var1(L_shrOutVar1),
						 .numShift(L_shrOutNumShift),
						 .overflow(),
						 .out(L_shrIn)
						 );				
	L_msu lag_L_msu(
						 .a(L_msuOutA),
						 .b(L_msuOutB),
						 .c(L_msuOutC),
						 .overflow(),
						 .out(L_msuIn)
						 );				
	initial 
	begin
		// samples out are samples from ITU G.729 test vectors
		$readmemh("1lag_window_in.out", rMem);
		// filter results from ITU G.729 ANSI fixed point implementation
		$readmemh("1lag_window_out.out", rPrimeMem);
   end
	
	//lag read address mux
	always @(*)
	begin
		case	(lagMuxSel)	
			'd0 :	lagMuxOut = rPrimeRequested;
			'd1:	lagMuxOut = testReadRequested;
		endcase
	end
	
	//lag write address mux
	always @(*)
	begin
		case	(lagMux1Sel)	
			'd0 :	lagMux1Out = rPrimeRequested;
			'd1:	lagMux1Out = testWriteRequested;
		endcase
	end
	
	//lag write output mux
	always @(*)
	begin
		case	(lagMux2Sel)	
			'd0 :	lagMux2Out = rPrimeOut;
			'd1:	lagMux2Out = testWriteOut;
		endcase
	end
	
		//lag write enable mux
	always @(*)
	begin
		case	(lagMux3Sel)	
			'd0 :	lagMux3Out = rPrimeWrite;
			'd1:	lagMux3Out = testWriteEnable;
		endcase
	end
	
		Scratch_Memory_Controller lagMem(
												 .addra(lagMux1Out),
												 .dina(lagMux2Out),
												 .wea(lagMux3Out),
												 .clk(clk),
												 .addrb(lagMuxOut),
												 .doutb(rPrimeIn)
												 );
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;		
		lagMuxSel = 0;
		
		#50 ;		
		reset = 1;		
		#50;		
		reset = 0;
		// Wait 100 ns for global reset to finish
		#100;
	for(j=0;j<100;j=j+1)
	begin	
		//Test # 1
		lagMux1Sel = 1;
		lagMux2Sel = 1;
		lagMux3Sel = 1;
		
		for(i=0;i<11;i=i+1)
		begin			
			#40;
			testWriteRequested = {AUTOCORR_R[10:4],i[3:0]};
			testWriteOut = rMem[j*11+i];
			testWriteEnable = 1;
			#40;
		end
		
		lagMux1Sel = 0;
		lagMux2Sel = 0;
		lagMux3Sel = 0;		
		
		// Add stimulus here
		start = 1;
		#50
		start = 0;
		#50;
		
		wait(done);
      lagMuxSel = 1;
		for(i = 0; i<11;i=i+1)
		begin			
			testReadRequested = {LAG_WINDOW_R_PRIME[10:4],i[3:0]};
			#35;
			if (rPrimeIn != rPrimeMem[j*11+i])
					$display($time, " ERROR: r'[%d] = %x, expected = %x", j*11+i, rPrimeIn, rPrimeMem[j*11+i]);
				else
					$display($time, " CORRECT:  r'[%d] = %x", j*11+i, rPrimeIn);
		end
		lagMuxSel = 0;
		#100;
	end//	for joop j
	
	end//always
   initial forever #10 clk = ~clk;     
endmodule

