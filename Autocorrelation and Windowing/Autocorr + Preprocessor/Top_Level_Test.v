`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:55:22 10/05/2010
// Module Name:    Top_Level_Test
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A test bench to test a top level instantiation of the pre-processor, autocorellation, and 
//						 respective memory controlelrs. 
//						 					 
//	Verilog Test Fixture created by ISE for modules: g729_hpfilter,autocorr,LPC_Mem_Ctrl,LPC_Mem_Ctrl_2			
//
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Level_Test_v;
`include "paramList.v"
	//Universal inputs
	reg mclk;
	reg reset;
	
	//Pre-Processor Inputs	
	reg [15:0] xn;
	reg preProcReady;
	
	//Autocorr Inputs
	reg autocorrReady;
	wire [15:0] xIn;
	wire [31:0] memIn;
	wire [15:0] norm_lIn;
	wire norm_lDone;	
	wire overflow;
	wire [15:0] multIn;
	wire [31:0] L_macIn;
	wire [31:0] L_shlIn;
	wire [31:0] L_shrIn;
	wire [15:0] shrIn;
	wire [15:0] addIn;
	wire [15:0] subIn;
	
	// Pre-Processor Outputs
	wire [15:0] yn;
	wire preProcDone;
	
	// Autocorr Outputs
	wire [31:0] memOut;
	wire [7:0] xRequested;
	wire [10:0] writeRequested;
	wire [10:0] readRequested;
	wire writeEn;
	wire autocorrDone;
   wire [15:0] multOutA;
	wire [15:0] multOutB;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire [31:0] norm_lVar1Out;
	wire norm_lReady;
	wire norm_lReset;
	wire L_shlReady;
	wire [31:0]L_shlVar1Out;
	wire [15:0] L_shlNumShiftOut;	
	wire L_shlDone;
	wire [31:0] L_shrVar1Out;
	wire [15:0] L_shrNumShiftOut;
	wire [15:0] shrVar1Out;
	wire [15:0] shrVar2Out;
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [15:0] subOutA;
	wire [15:0] subOutB;
	wire multRselOut;	
	
	//LPC_Mem_Ctrl output	
	wire frame_done;

		
	
	reg [15:0] samplesmem [0:1998];
	reg [15:0] filteredmem [0:1998];
	reg [31:0] autocorr_out [0:43];
	reg frameDoneState, nextFrameDoneState;
	reg [2:0] frameDoneCount,frameDoneCountLoad,frameDoneCountReset;
	//Mux0 regs
	reg mux0sel;	
	reg [10:0] testReadRequested;
	reg [10:0] mux0out;
	integer i;
	integer j;
	wire [3:0] i_11;
	assign i_11 = i[3:0] - 11;
	
	parameter INIT = 2'd0;
	parameter S1 = 2'd1;
	
	always @(posedge mclk)
	begin
		if(reset)
			frameDoneState <= 0;
		else
			frameDoneState <= nextFrameDoneState;	
	end
	
	always @(posedge mclk)
	begin
		if(reset)
			frameDoneCount <= 0;
		else if(frameDoneCountReset)
			frameDoneCount <= 0;
		else if(frameDoneCountLoad)
			frameDoneCount <= frameDoneCount + 1;
	end
	
	always @(*)
	begin	//always
		nextFrameDoneState = frameDoneState;
		frameDoneCountReset = 0;
		frameDoneCountLoad = 0;
		autocorrReady = 0;
		case(frameDoneState)
		
		INIT: 
		begin	//INIT
		
			if(frame_done)
				frameDoneCountLoad = 1;
				
			if(frameDoneCount == 2'd2)
			begin	//count
					frameDoneCountReset = 1;
					autocorrReady = 1;
					nextFrameDoneState = S1;
			end	//count
			
			else
				nextFrameDoneState = INIT;
		end	//INIT
		
		S1: 
		begin //S1
		
			if(frame_done)
					frameDoneCountLoad = 1;
					
			if(frameDoneCount == 2'd2)
			begin	//count
					frameDoneCountReset = 1;
					autocorrReady = 1;
					nextFrameDoneState = S1;
			end//count
			
			else
				nextFrameDoneState = S1;
		
		end	//S1
		endcase
	end	//always
		
	
	initial 
	begin
		// samples out are samples from ITU G.729 test vectors
		$readmemh("samples.out", samplesmem);
		// filter results from ITU G.729 ANSI fixed point implementation
      $readmemh("filtered.out", filteredmem);
		//autocorr results from ITU G.729 ANSI fixed point implementation
		$readmemh("autocorr_out.out", autocorr_out);
   end
	
	// Instantiate the Pre-Processor (UUT1)
	g729_hpfilter uut1 (
		.mclk(mclk), 
		.reset(reset), 
		.xn(xn), 
		.ready(preProcReady), 
		.yn(yn), 
		.done(preProcDone)
	);

	// Instantiate the Autocorellation Sub-Module (UUT2)
	
	autocorrFSM uut2(
					 .clk(mclk),
					 .reset(reset),
					 .ready(autocorrReady),
					 .xIn(xIn),
					 .memIn(memIn),
					 .norm_lIn(norm_lIn),
					 .norm_lDone(norm_lDone),
					 .overflow(overflow),
					 .multIn(multIn),
					 .L_macIn(L_macIn),
					 .L_shlIn(L_shlIn),
					 .L_shrIn(L_shrIn),
					 .shrIn(shrIn),
					 .addIn(addIn),
					 .subIn(subIn),
					 .L_shlDone(L_shlDone),
					 .memOut(memOut),
					 .xRequested(xRequested),
					 .readRequested(readRequested),
					 .writeRequested(writeRequested),
					 .writeEn(writeEn),
					 .done(autocorrDone),
					 .multOutA(multOutA),
					 .multOutB(multOutB),
					 .multRselOut(multRselOut),
					 .L_macOutA(L_macOutA),
					 .L_macOutB(L_macOutB),
					 .L_macOutC(L_macOutC),
					 .norm_lVar1Out(norm_lVar1Out),
					 .norm_lReady(norm_lReady),
					 .norm_lReset(norm_lReset),
					 .L_shlReady(L_shlReady),
					 .L_shlVar1Out(L_shlVar1Out),
					 .L_shlNumShiftOut(L_shlNumShiftOut),
					 .L_shrVar1Out(L_shrVar1Out),
					 .L_shrNumShiftOut(L_shrNumShiftOut),
					 .shrVar1Out(shrVar1Out),
					 .shrVar2Out(shrVar2Out),
					 .addOutA(addOutA),
					 .addOutB(addOutB),
					 .subOutA(subOutA),
					 .subOutB(subOutB)		 
					 );

	// Instantiate the Pre-Processor Memory (UUT3)
	LPC_Mem_Ctrl uut3 (
		.clock(mclk), 
		.reset(reset), 
		.In_Done(preProcDone), 
		.In_Sample(yn), 
		.Out_Count(xRequested), 
		.Out_Sample(xIn), 
		.frame_done(frame_done)
	);
	always@(*)
	begin
		case(mux0sel)
			'd0:	mux0out = readRequested;
			'd1:  mux0out = testReadRequested; 
		endcase
	end

	//Scratch memory
	Scratch_Memory_Controller scratch_mem(
										.addra(writeRequested),
										.dina(memOut),
										.wea(writeEn),
										.clk(mclk),
										.addrb(mux0out),
										.doutb(memIn)
										);
	
	mult multRound(
							.a(multOutA),
							.b(multOutB),
							.multRsel(multRselOut),
							.overflow(),
							.product(multIn)
							);
					
	L_mac multAdd(
						.a(L_macOutA),
						.b(L_macOutB),
						.c(L_macOutC),
						.overflow(overflow),
						.out(L_macIn)
					);					
	norm_l normalizer(
							.var1(norm_lVar1Out),
							.norm(norm_lIn),
							.clk(mclk),
							.ready(norm_lReady),
							.reset(reset||norm_lReset), 
							.done(norm_lDone)
							);
	L_shl leftShifter(
							.clk(mclk),
							.reset(reset),
							.ready(L_shlReady),
							.overflow(),
							.var1(L_shlVar1Out), 
							.numShift(L_shlNumShiftOut),	
							.done(L_shlDone),
							.out(L_shlIn)
							);	
	L_shr longRightShifter (
									.var1(L_shrVar1Out),
									.numShift(L_shrNumShiftOut),
									.overflow(),
									.out(L_shrIn)
									);
	shr shortRightShifter(
								 .var1(shrVar1Out),
								 .var2(shrVar2Out),
								 .overflow(),
								 .result(shrIn)
								 );
	add shortAdder(
						.a(addOutA),
						.b(addOutB),
						.overflow(),
						.sum(addIn)
						);
	sub shortSubtractor(
								.a(subOutA),
								.b(subOutB),
								.overflow(),
								.diff(subIn)
								);
	initial begin
		// Initialize Inputs
		mclk = 0;
		reset = 0; 
		xn = 0;
		preProcReady = 0;
		mux0sel = 0;
		//xIn = 0;
		//yIn = 0;

		// Wait 100 ns for global reset to finish
		#100;
      reset = 1;
		#50;
		reset = 0;
		#50;	

			for (i=0;i<80;i=i+1)
			begin
			  @(posedge mclk);
			  preProcReady = 1;
			  xn = samplesmem[i];
			  @(posedge mclk);
			  preProcReady = 0;
			  wait (preProcDone);
			  @(posedge mclk);
			  if (yn != filteredmem[i])
					$display($time, " ERROR: x[%d] = %x, y[%d] = %x, expected = %x", i, xn, i, yn, filteredmem[i]);
           else
               $display($time, " CORRECT:  x[%d] = %x, y[%d] = %x", i, xn, i, yn);
				#50;
			end			
			
			wait (autocorrDone);
			mux0sel=1;
			for (i = 0; i<11;i=i+1)
			begin
				testReadRequested = {AUTOCORR_R[10:4],i[3:0]};
				@(posedge mclk);
				@(posedge mclk);
				if (memIn!= autocorr_out[i])
					$display($time, " ERROR: r'[%d] = %x, expected = %x", i, memIn, autocorr_out[i]);
				else
					$display($time, " CORRECT:  r'[%d] = %x", i, memIn);
			end
		// 80 more(test#2)
			mux0sel = 0;
			for (i=80;i<160;i=i+1)
			begin
			  @(posedge mclk);
			  preProcReady = 1;
			  xn = samplesmem[i];
			  @(posedge mclk);
			  preProcReady = 0;
			  wait (preProcDone);
			  @(posedge mclk);
			  if (yn != filteredmem[i])
					$display($time, " ERROR: x[%d] = %x, y[%d] = %x, expected = %x", i, xn, i, yn, filteredmem[i]);
           else
               $display($time, " CORRECT:  x[%d] = %x, y[%d] = %x", i, xn, i, yn);
				#50;
			end			
			
			wait (autocorrDone);
			mux0sel=1;
			for (i = 11; i<22;i=i+1)
			begin
				testReadRequested = {AUTOCORR_R[10:5],i[4:0]}-11;
				@(posedge mclk);
				@(posedge mclk);
				if (memIn!= autocorr_out[i])
					$display($time, " ERROR: r'[%d] = %x, expected = %x", i, memIn, autocorr_out[i]);
				else
					$display($time, " CORRECT:  r'[%d] = %x", i, memIn);
			end
		// another 80(test#3)
			mux0sel = 0;
			for (i=160;i<240;i=i+1)
			begin
			  @(posedge mclk);
			  preProcReady = 1;
			  xn = samplesmem[i];
			  @(posedge mclk);
			  preProcReady = 0;
			  wait (preProcDone);
			  @(posedge mclk);
			  if (yn != filteredmem[i])
					$display($time, " ERROR: x[%d] = %x, y[%d] = %x, expected = %x", i, xn, i, yn, filteredmem[i]);
           else
               $display($time, " CORRECT:  x[%d] = %x, y[%d] = %x", i, xn, i, yn);
				#50;
			end			
			
			wait (autocorrDone);
			mux0sel=1;
			for (i = 22; i<33;i=i+1)
			begin
				testReadRequested = {AUTOCORR_R[10:6],i[5:0]}-22;
				@(posedge mclk);
				@(posedge mclk);
				if (memIn!= autocorr_out[i])
					$display($time, " ERROR: r'[%d] = %x, expected = %x", i, memIn, autocorr_out[i]);
				else
					$display($time, " CORRECT:  r'[%d] = %x", i, memIn);
			end
			// another 80(test#4)
			mux0sel = 0;
			for (i=240;i<320;i=i+1)
			begin
			  @(posedge mclk);
			  preProcReady = 1;
			  xn = samplesmem[i];
			  @(posedge mclk);
			  preProcReady = 0;
			  wait (preProcDone);
			  @(posedge mclk);
			  if (yn != filteredmem[i])
					$display($time, " ERROR: x[%d] = %x, y[%d] = %x, expected = %x", i, xn, i, yn, filteredmem[i]);
           else
               $display($time, " CORRECT:  x[%d] = %x, y[%d] = %x", i, xn, i, yn);
				#50;
			end			
			
			wait (autocorrDone);
			mux0sel=1;
			for (i = 33; i<44;i=i+1)
			begin
				testReadRequested = {AUTOCORR_R[10:6],i[5:0]}-33;
				@(posedge mclk);
				@(posedge mclk);
				if (memIn!= autocorr_out[i])
					$display($time, " ERROR: r'[%d] = %x, expected = %x", i, memIn, autocorr_out[i]);
				else
					$display($time, " CORRECT:  r'[%d] = %x", i, memIn);
			end
	end//always

initial forever #10 mclk = ~mclk; //50MHz clk
      
endmodule

