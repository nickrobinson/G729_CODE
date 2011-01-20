`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    15:26:34 10/28/2010
// Module Name:    Az_LSP_Test
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Verilog Test Fixture created by ISE for module: Az_toLSP_FSM
// Dependencies: 	 L_mac.v, L_msu.v,L_shl,L_sub,add,mult,norm_s
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Az_LSP_Test_v;
`include "paramList.v"
	// Inputs
	reg clk;
	reg reset;
	reg start;	
	
	// Outputs
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [15:0] subOutA;
	wire [15:0] subOutB;
	wire [15:0] shrOutVar1;
	wire [15:0] shrOutVar2;
	wire [31:0] L_shrOutVar1;
	wire [15:0] L_shrOutNumShift;
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	wire [31:0] L_subOutA;
	wire [31:0] L_subOutB;
	wire [15:0] multOutA;
	wire [15:0] multOutB;
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire L_multOverflow;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire L_macOverflow;
	wire [15:0] L_msuOutA;
	wire [15:0] L_msuOutB;
	wire [31:0] L_msuOutC;
	wire L_msuOverflow;
	wire [31:0] L_shlVar1Out;
	wire [15:0] L_shlNumShiftOut;
	wire L_shlReady;
	wire [15:0] norm_sOut;
	wire norm_sReady;
	wire [10:0] lspWriteRequested;
	wire [10:0] lspReadRequested;
	wire [31:0] lspOut;
	wire lspWrite;
	wire divErr;   
	wire [15:0] addIn;
	wire [15:0] subIn;
	wire [15:0] shrIn;
	wire [31:0] L_shrIn;
	wire [31:0] L_addIn;
	wire [31:0] L_subIn;
	wire [15:0] multIn;
	wire [31:0] L_multIn;
	wire [31:0] L_macIn;
	wire [31:0] L_msuIn;
	wire [31:0] L_shlIn;
	wire L_shlDone;
	wire [15:0] norm_sIn;
	wire norm_sDone;
	wire done;
	
	//working wires
   wire [31:0] lspIn;
	
	//working regs
	reg [15:0] aSubI_in [0:10];
	reg [15:0] lspOutMem [0:9];
	//Mux0 regs	
	reg lspMuxSel;
	reg [10:0] lspMuxOut;
	reg [10:0] testReadRequested;
	//mux1 regs
	reg lspMux1Sel;
	reg [10:0] lspMux1Out;
	reg [10:0] testWriteRequested;
	//mux2 regs
	reg lspMux2Sel;
	reg [31:0] lspMux2Out;
	reg [31:0] testLspOut;
	//mux3regs
	reg lspMux3Sel;
	reg lspMux3Out;
	reg testLspWrite;

	integer i;
	
	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("az_lsp_in.out", aSubI_in);
		$readmemh("az_lsp_out.out", lspOutMem);
	end
	
	//lsp read address mux
	always @(*)
	begin
		case	(lspMuxSel)	
			'd0 :	lspMuxOut = lspReadRequested;
			'd1:	lspMuxOut = testReadRequested;
		endcase
	end
	
	//lsp write address mux
	always @(*)
	begin
		case	(lspMux1Sel)	
			'd0 :	lspMux1Out = lspWriteRequested;
			'd1:	lspMux1Out = testWriteRequested;
		endcase
	end
	
	//lsp write input mux
	always @(*)
	begin
		case	(lspMux2Sel)	
			'd0 :	lspMux2Out = lspOut;
			'd1:	lspMux2Out = testLspOut;
		endcase
	end
	
	//lsp write enable mux
	always @(*)
	begin
		case	(lspMux3Sel)	
			'd0 :	lspMux3Out = lspWrite;
			'd1:	lspMux3Out = testLspWrite;
		endcase
	end
	
	Scratch_Memory_Controller testMem(
												 .addra(lspMux1Out),
												 .dina(lspMux2Out),
												 .wea(lspMux3Out),
												 .clk(clk),
												 .addrb(lspMuxOut),
												 .doutb(lspIn)
												 );
												 
	
	// Instantiate the Unit Under Test (UUT)
	Az_toLSP_FSM uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.addIn(addIn), 
		.subIn(subIn),
		.shrIn(shrIn),
		.L_shrIn(L_shrIn),
		.L_addIn(L_addIn),
		.L_subIn(L_subIn), 
		.multIn(multIn), 
		.L_multIn(L_multIn), 
		.L_macIn(L_macIn), 
		.L_msuIn(L_msuIn), 
		.L_shlIn(L_shlIn), 
		.L_shlDone(L_shlDone), 
		.norm_sIn(norm_sIn), 
		.norm_sDone(norm_sDone), 
		.lspIn(lspIn), 
		.addOutA(addOutA), 
		.addOutB(addOutB), 
		.subOutA(subOutA),
		.subOutB(subOutB),
		.shrOutVar1(shrOutVar1),
		.shrOutVar2(shrOutVar2),
		.L_shrOutVar1(L_shrOutVar1),
		.L_shrOutNumShift(L_shrOutNumShift),
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.L_subOutA(L_subOutA), 
		.L_subOutB(L_subOutB), 
		.multOutA(multOutA), 
		.multOutB(multOutB), 
		.L_multOutA(L_multOutA), 
		.L_multOutB(L_multOutB), 
		.L_multOverflow(L_multOverflow), 
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC), 
		.L_macOverflow(L_macOverflow), 
		.L_msuOutA(L_msuOutA), 
		.L_msuOutB(L_msuOutB), 
		.L_msuOutC(L_msuOutC), 
		.L_msuOverflow(L_msuOverflow), 
		.L_shlVar1Out(L_shlVar1Out), 
		.L_shlNumShiftOut(L_shlNumShiftOut), 
		.L_shlReady(L_shlReady), 
		.norm_sOut(norm_sOut), 
		.norm_sReady(norm_sReady), 
		.lspWriteRequested(lspWriteRequested), 
		.lspReadRequested(lspReadRequested), 
		.lspOut(lspOut), 
		.lspWrite(lspWrite), 
		.divErr(divErr),
		.done(done)
	);
	
	
	//Instantiated modules
	L_mult Az_L_mult(
						 .a(L_multOutA),
						 .b(L_multOutB),
						 .overflow(L_multOverflow),
						 .product(L_multIn)
						 );
	L_mac Az_L_mac(
						.a(L_macOutA),
						.b(L_macOutB),
						.c(L_macOutC),
						.overflow(L_macOverflow),
						.out(L_macIn)
						);
	L_msu Az_L_msu(
						.a(L_msuOutA),
						.b(L_msuOutB),
						.c(L_msuOutC),
						.overflow(L_msuOverflow),
						.out(L_msuIn)
						);
   L_shl Az_L_shl(
						.clk(clk),
						.reset(reset),
						.ready(L_shlReady),
						.overflow(),
						.var1(L_shlVar1Out),
						.numShift(L_shlNumShiftOut),
						.done(L_shlDone),
						.out(L_shlIn)
						);
   L_sub Az_L_sub(
						.a(L_subOutA),
						.b(L_subOutB),
						.overflow(),
						.diff(L_subIn)
						);
	L_add Az_L_add(
					.a(L_addOutA),
					.b(L_addOutB),
					.overflow(),
					.sum(L_addIn)
					);	
	
	add Az_add(
					.a(addOutA),
					.b(addOutB),
					.overflow(),
					.sum(addIn)
					);
   mult Az_mult(
					 .a(multOutA),
					 .b(multOutB),
					 .overflow(),
					 .product(multIn)
					 );
	norm_s Az_norm_s(
							.var1(norm_sOut),
							.norm(norm_sIn),
							.clk(clk),
							.ready(norm_sReady),
							.reset(reset),
							.done(norm_sDone)
							);		
	sub Az_sub(
				  .a(subOutA),
				  .b(subOutB),
				  .overflow(),
				  .diff(subIn)
					);	
   shr Az_shr(
				  .var1(shrOutVar1),
				  .var2(shrOutVar2),
				  .overflow(),
				  .result(shrIn)
				  );
	L_shr Az_L_shr(
						.var1(L_shrOutVar1),
						.numShift(L_shrOutNumShift),
						.overflow(),
						.out(L_shrIn)
						);
			
	initial begin
		// Initialize Input
		
		clk = 0;
		reset = 0;
		start = 0;
		lspMuxSel = 0;
		lspMux1Sel = 0;
		lspMux2Sel = 0;
		lspMux3Sel = 0;
		testReadRequested = 0;
		
		//writing the previous modules to memory
		for(i=0;i<11;i=i+1)
		begin
			#100;
			lspMux1Sel = 1;
			lspMux2Sel = 1;
			lspMux3Sel = 1;
			testWriteRequested = {LEVINSON_DURBIN_A[10:5],i[4:0]};
			testLspOut = aSubI_in[i];
			testLspWrite = 1;	
			#100;
		end
		lspMux1Sel = 0;
		lspMux2Sel = 0;
		lspMux3Sel = 0;	
		
		// Wait 100 ns for global reset to finish
		#50;
		reset = 1;
		#50;
		reset = 0;
		#50;
       
		start = 1;
		#50;
		start = 0;
		#50;
		// Add stimulus here		
	
		wait(done);
		#100;
		lspMuxSel = 1;
		for (i = 0; i<10;i=i+1)
		begin				
				testReadRequested = {AZ_TO_LSP_CURRENT[11:5],i[4:0]};
				@(posedge clk);
				@(posedge clk);
				if (lspIn != lspOutMem[i])
					$display($time, " ERROR: lsp[%d] = %x, expected = %x", i, lspIn, lspOutMem[i]);
				else if (lspIn == lspOutMem[i])
					$display($time, " CORRECT:  lsp[%d] = %x", i, lspIn);
				@(posedge clk);

			end
			
			//round 2 test
		$readmemh("az_lsp_in1.out", aSubI_in);
		$readmemh("az_lsp_out1.out", lspOutMem);
		for(i=0;i<11;i=i+1)
		begin
			#100;

			lspMux1Sel = 1;
			lspMux2Sel = 1;
			lspMux3Sel = 1;
			testWriteRequested = {LEVINSON_DURBIN_A[10:5],i[4:0]};
			testLspOut = aSubI_in[i];
			testLspWrite = 1;	
			#100;
		end
		lspMuxSel = 0;
		lspMux1Sel = 0;
		lspMux2Sel = 0;
		lspMux3Sel = 0;	
		
		#50;       
		start = 1;
		#50;
		start = 0;
		#50;
		wait(done);
		#100;
		lspMuxSel = 1;
		for (i = 0; i<10;i=i+1)
		begin				
				testReadRequested = {AZ_TO_LSP_CURRENT[11:5],i[4:0]};
				@(posedge clk);
				@(posedge clk);
				if (lspIn != lspOutMem[i])
					$display($time, " ERROR: lsp[%d] = %x, expected = %x", i, lspIn, lspOutMem[i]);
				else if (lspIn == lspOutMem[i])
					$display($time, " CORRECT:  lsp[%d] = %x", i, lspIn);
				@(posedge clk);

			end

//round 3 test
		$readmemh("az_lsp_in2.out", aSubI_in);
		$readmemh("az_lsp_out2.out", lspOutMem);
		for(i=0;i<11;i=i+1)
		begin
			#100;

			lspMux1Sel = 1;
			lspMux2Sel = 1;
			lspMux3Sel = 1;
			testWriteRequested = {LEVINSON_DURBIN_A[10:5],i[4:0]};
			testLspOut = aSubI_in[i];
			testLspWrite = 1;	
			#100;
		end
		lspMuxSel = 0;
		lspMux1Sel = 0;
		lspMux2Sel = 0;
		lspMux3Sel = 0;	
		
		#50;       
		start = 1;
		#50;
		start = 0;
		#50;
		wait(done);
		#100;
		lspMuxSel = 1;
		for (i = 0; i<10;i=i+1)
		begin				
				testReadRequested = {AZ_TO_LSP_CURRENT[11:5],i[4:0]};
				@(posedge clk);
				@(posedge clk);
				if (lspIn != lspOutMem[i])
					$display($time, " ERROR: lsp[%d] = %x, expected = %x", i, lspIn, lspOutMem[i]);
				else if (lspIn == lspOutMem[i])
					$display($time, " CORRECT:  lsp[%d] = %x", i, lspIn);
				@(posedge clk);

			end	

	end//initial
     
initial forever #10 clk = ~clk;	  
endmodule


