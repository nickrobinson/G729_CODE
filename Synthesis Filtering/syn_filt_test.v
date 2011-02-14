	`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:23:48 01/23/2011
// Design Name:   Synthesis Filtering
// Module Name:   C:/Users/Nick/Documents/Spring2010/G.729 Verilog Code/Convolve/syn_filt_test.v
// Project Name:  Synthesis Filtering
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Synthesis Filtering
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module syn_filt_test;

`include "paramList.v"

	// Inputs
	reg clk;
	reg reset;
	reg start;
	wire [31:0] memIn;
	wire [31:0] L_addIn;
	wire [31:0] L_multIn;
	wire [31:0] L_shlIn;
	wire [31:0] L_msuIn;
	
	reg [10:0] xAddr;
	reg [10:0] aAddr;
	reg [10:0] yAddr;
	reg [10:0] fMemAddr;
	reg [10:0] updateAddr;

	// Outputs
	wire memWriteEn;
	wire [10:0] memWriteAddr;
	wire [31:0] memOut;
	wire done;
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire [31:0] L_shlOutVar1;
	wire [15:0] L_shlNumShiftOut;
	wire L_shlReady;
	wire [15:0] L_msuOutA;
	wire [15:0] L_msuOutB;
	wire [31:0] L_msuOutC;
	
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
	syn_filt uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.memIn(memIn), 
		.memWriteEn(memWriteEn), 
		.memWriteAddr(memWriteAddr), 
		.memOut(memOut), 
		.done(done),
		.xAddr(xAddr),
		.aAddr(aAddr),
		.yAddr(yAddr),
		.updateAddr(updateAddr),
		.fMemAddr(fMemAddr),
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.L_addIn(L_addIn),
		.L_multOutA(L_multOutA),
		.L_multOutB(L_multOutB),
		.L_multIn(L_multIn),
		.L_shlIn(L_shlIn), 
		.L_shlDone(L_shlDone),
		.L_shlOutVar1(L_shlOutVar1), 
		.L_shlNumShiftOut(L_shlNumShiftOut), 
		.L_shlReady(L_shlReady),
		.L_msuIn(L_msuIn), 
		.L_msuOutA(L_msuOutA), 
		.L_msuOutB(L_msuOutB), 
		.L_msuOutC(L_msuOutC)
	);
	
	//Instanitiate the Multiply and Add block
					
	L_add conv_L_add(
					.a(L_addOutA),
					.b(L_addOutB),
					.overflow(),
					.sum(L_addIn));
					
	L_mult conv_L_mult(
					.a(L_multOutA),
					.b(L_multOutB),
					.overflow(),
					.product(L_multIn));
	
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
	
	L_msu conv_L_msu(
						 .a(L_msuOutA),
						 .b(L_msuOutB),
						 .c(L_msuOutC),
						 .overflow(unusedOverflow),
						 .out(L_msuIn)
						 );		
					
	reg [15:0] predictionVector[0:9999];
	reg [15:0] inVector[0:9999];
	reg [15:0] outVector[0:9999];
	reg [15:0] filterMemVector[0:9999];
	reg [15:0] updateVector[0:9999];
					 
	initial 
		begin
			// samples out are samples from ITU G.729 test vectors
			$readmemh("syn_filt_mem.out", filterMemVector);
			$readmemh("syn_filt_x_in.out", inVector);
			$readmemh("syn_filt_out.out", outVector);
			$readmemh("syn_filt_coeff.out", predictionVector);
			$readmemh("syn_filt_update.out", updateVector);
			//add update file here
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
	
	Scratch_Memory_Controller convMem(
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
		xAddr = 11'd560;
		aAddr = 11'd624;
		yAddr = 11'd688;
		fMemAddr = 11'd816;
		updateAddr = 11'd944;
		
		#50 ;		
		reset = 1;		
		#50;		
		reset = 0;
		// Wait 100 ns for global reset to finish
		#100;
        
		for(j=0;j<2;j=j+1)
		begin
			//Test # 1
			lagMuxSel = 0;
			lagMux1Sel = 1;
			lagMux2Sel = 1;
			lagMux3Sel = 1;
			
			for(i=0;i<10;i=i+1)
			begin			
				#40;
				testWriteRequested = {fMemAddr[10:6],i[5:0]};
				testWriteOut = filterMemVector[(j*10)+i];
				testWriteEnable = 1;
				#40;
			end
			
			for(i=0;i<40;i=i+1)
			begin			
				#40;
				testWriteRequested = {xAddr[10:6],i[5:0]};
				testWriteOut = inVector[(j*40)+i];
				testWriteEnable = 1;
				#40;
			end
			
			for(i=0;i<11;i=i+1)
			begin			
				#40;
				testWriteRequested = {aAddr[10:6],i[5:0]};
				testWriteOut = predictionVector[(j*11)+i];
				testWriteEnable = 1;
				#40;
			end
			
			for(i=0;i<40;i=i+1)
			begin			
				#40;
				testWriteRequested = {yAddr[10:6],i[5:0]};
				testWriteOut = outVector[(j*40)+i];
				testWriteEnable = 1;
				#40;
			end
			
			for(i=0;i<1;i=i+1)
			begin			
				#40;
				testWriteRequested = {updateAddr[10:0]};
				testWriteOut = updateVector[(j*1)];
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
				testReadRequested = {yAddr[10:6],i[5:0]};
				@(posedge clk);
				@(posedge clk);
				if (memIn != outVector[(j*40)+i])
						$display($time, " ERROR: y'[%d] = %x, expected = %x", (j*40)+i, memIn, outVector[(j*40)+i]);
					else
						$display($time, " CORRECT:  y'[%d] = %x", (j*40)+i, memIn);
			end
		end	// end j loop

	end
	
initial forever #10 clk = ~clk; 
endmodule

