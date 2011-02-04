`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:23:48 01/23/2011
// Design Name:   convolve
// Module Name:   C:/Users/Nick/Documents/Spring2010/G.729 Verilog Code/Convolve/convolve_test.v
// Project Name:  Convolve
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: convolve
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module convolve_test;

`include "paramList.v"

	// Inputs
	reg clk;
	reg reset;
	reg start;
	wire [31:0] memIn;
	wire [31:0] L_macIn;
	wire [31:0] L_shlIn;
	wire L_shlDone;

	// Outputs
	wire memWriteEn;
	wire [10:0] memWriteAddr;
	wire [31:0] memOut;
	wire done;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire [31:0] L_shlOutVar1;
	wire [15:0] L_shlNumShiftOut;
	wire L_shlReady;
	
	wire unusedOverflow;
	
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
	integer i, j;

	// Instantiate the Unit Under Test (UUT)
	convolve uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.memIn(memIn), 
		.memWriteEn(memWriteEn), 
		.memWriteAddr(memWriteAddr), 
		.memOut(memOut), 
		.done(done),
		.L_macIn(L_macIn),
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC),
		.L_shlIn(L_shlIn), 
		.L_shlDone(L_shlDone),
		.L_shlOutVar1(L_shlOutVar1), 
		.L_shlNumShiftOut(L_shlNumShiftOut), 
		.L_shlReady(L_shlReady)
	);
	
	//Instanitiate the Multiply and Add block
	L_mac lag_L_mac(
					.a(L_macOutA),
					.b(L_macOutB),
					.c(L_macOutC),
					.overflow(),
					.out(L_macIn));
					
	L_shl L_shl1(
					 .clk(clk),
					 .reset(reset),
					 .ready(L_shlReady),
					 .overflow(unusedOverflow),
					 .var1(L_shlOutVar1),
					 .numShift(L_shlNumShiftOut),
					 .done(L_shlDone),
					 .out(L_shlIn)
					 );
					 
	reg [15:0] inVector[0:9999];
	reg [15:0] impulse[0:9999];
	reg [15:0] outVector[0:9999];
					 
	initial 
		begin
			// samples out are samples from ITU G.729 test vectors
			$readmemh("convolve_input_vector.out", inVector);
			$readmemh("convolve_impulse_response.out", impulse);
			$readmemh("convolve_out.out", outVector);
		end
					 
	//lag read address mux
	always @(*)
	begin
		case	(lagMuxSel)	
			'd0 :	lagMuxOut = memWriteAddr;
			'd1:	lagMuxOut = testReadRequested;
		endcase
	end
	
	//lag write address mux
	always @(*)
	begin
		case	(lagMux1Sel)	
			'd0 :	lagMux1Out = memWriteAddr;
			'd1:	lagMux1Out = testWriteRequested;
		endcase
	end
	
	//lag write output mux
	always @(*)
	begin
		case	(lagMux2Sel)	
			'd0 :	lagMux2Out = memOut;
			'd1:	lagMux2Out = testWriteOut;
		endcase
	end
	
		//lag write enable mux
	always @(*)
	begin
		case	(lagMux3Sel)	
			'd0 :	lagMux3Out = memWriteEn;
			'd1:	lagMux3Out = testWriteEnable;
		endcase
	end
	
	Scratch_Memory_Controller lagMem(
												 .addra(lagMux1Out),
												 .dina(lagMux2Out),
												 .wea(lagMux3Out),
												 .clk(clk),
												 .addrb(lagMuxOut),
												 .doutb(memIn)
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
        
		for(j=0;j<10;j=j+1)
		begin
			//Test # 1
			lagMuxSel = 0;
			lagMux1Sel = 1;
			lagMux2Sel = 1;
			lagMux3Sel = 1;
			
			for(i=0;i<40;i=i+1)
			begin			
				#40;
				testWriteRequested = {CONVOLVE_INPUT_VECTOR[10:6],i[5:0]};
				testWriteOut = inVector[(j*40)+i];
				testWriteEnable = 1;
				#40;
			end
			
			for(i=0;i<40;i=i+1)
			begin			
				#40;
				testWriteRequested = {CONVOLVE_IMPULSE_RESPONSE[10:6],i[5:0]};
				testWriteOut = impulse[(j*40)+i];
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
			for(i = 0; i<40;i=i+1)
			begin			
				testReadRequested = {CONVOLVE_OUTPUT_VECTOR[10:6],i[5:0]};
				@(posedge clk);
				@(posedge clk);
				if (memIn != outVector[(j*40)+i])
						$display($time, " ERROR: r'[%d] = %x, expected = %x", (j*40)+i, memIn, outVector[(j*40)+i]);
					else
						$display($time, " CORRECT:  r'[%d] = %x", (j*40)+i, memIn);
			end
		end	// end j loop

	end
	
initial forever #10 clk = ~clk; 
endmodule

