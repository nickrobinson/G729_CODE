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


	// Outputs
	wire [15:0] shlVar1Out;
	wire [15:0] shlVar2Out;
	wire [15:0] shrVar1Out;
	wire [15:0] shrVar2Out;
	wire [15:0] subOutA;
	wire [15:0] subOutB;
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire [31:0] L_subOutA;
	wire [31:0] L_subOutB;
	wire [31:0] L_shrOutVar1;
	wire [15:0] L_shrOutNumShift;
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [15:0] multOutA;
	wire [15:0] multOutB;
	wire [10:0] memReadAddr;
	wire [10:0] memWriteAddr;
	wire memWrite;
	wire [31:0] memOut;
	wire done;
	
	//intermediary wires
	wire [15:0] shlIn;
	wire [15:0] shrIn;
	wire [15:0] subIn;
	wire [31:0] L_multIn;
	wire [31:0] L_subIn;
	wire [31:0] L_shrIn;
	wire [31:0] L_addIn;
	wire [15:0] addIn;
	wire [15:0] multIn;
	wire [31:0] memIn;
	
	//Memory Mux regs
	reg percVarMuxSel;
	reg percVarMux1Sel;
	reg percVarMux2Sel;
	reg percVarMux3Sel;
	reg [10:0] percVarMuxOut;
	reg [10:0] testWriteAddr;
	reg [10:0] percVarMux1Out;
	reg [10:0] testReadAddr;
	reg [31:0] percVarMux2Out;
	reg [31:0] testMemOut;
	reg percVarMux3Out;
	reg testMemWrite;
	
	//I/O regs
	//working regs
	reg [15:0] gamma1 [0:99];
	reg [15:0] gamma2 [0:99];
	reg [15:0] lsfInt [0:399];
	reg [15:0] lsfNew [0:399];
	reg [15:0] rc [0:399];
	
	

	integer i;
	// Instantiate the Unit Under Test (UUT)
	percVarFSM uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.shlIn(shlIn), 
		.shrIn(shrIn), 
		.subIn(subIn), 
		.L_multIn(L_multIn), 
		.L_subIn(L_subIn), 
		.L_shrIn(L_shrIn), 
		.L_addIn(L_addIn),
		.addIn(addIn), 
		.multIn(multIn), 
		.memIn(memIn), 
		.shlVar1Out(shlVar1Out), 
		.shlVar2Out(shlVar2Out), 
		.shrVar1Out(shrVar1Out), 
		.shrVar2Out(shrVar2Out), 
		.subOutA(subOutA), 
		.subOutB(subOutB), 
		.L_multOutA(L_multOutA), 
		.L_multOutB(L_multOutB), 
		.L_subOutA(L_subOutA), 
		.L_subOutB(L_subOutB), 
		.L_shrOutVar1(L_shrOutVar1), 
		.L_shrOutNumShift(L_shrOutNumShift),
		.L_addOutA(L_addOutA),
		.L_addOutB(L_addOutB),
		.addOutA(addOutA), 
		.addOutB(addOutB), 
		.multOutA(multOutA), 
		.multOutB(multOutB), 
		.memReadAddr(memReadAddr), 
		.memWriteAddr(memWriteAddr), 
		.memWrite(memWrite), 
		.memOut(memOut), 
		.done(done)
	);

	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("1lsf_int_in.out", lsfInt);
		$readmemh("1lsf_new_in.out", lsfNew);
		$readmemh("1rc_in.out", rc);
		$readmemh("1gamma1_out.out", gamma1);
		$readmemh("1gamma2_out.out", gamma2);
	end
	
	//Instantiated modules
	
	//lsp read address mux
	always @(*)
	begin
		case	(percVarMuxSel)	
			'd0 :	percVarMuxOut = memReadAddr;
			'd1:	percVarMuxOut = testReadAddr;
		endcase
	end
	
	//lsp write address mux
	always @(*)
	begin
		case	(percVarMux1Sel)	
			'd0 :	percVarMux1Out = memWriteAddr;
			'd1:	percVarMux1Out = testWriteAddr;
		endcase
	end
	
	//lsp write input mux
	always @(*)
	begin
		case	(percVarMux2Sel)	
			'd0 :	percVarMux2Out = memOut;
			'd1:	percVarMux2Out = testMemOut;
		endcase
	end
	
	//lsp write enable mux
	always @(*)
	begin
		case	(percVarMux3Sel)	
			'd0 :	percVarMux3Out = memWrite;
			'd1:	percVarMux3Out = testMemWrite;
		endcase
	end
	
	Scratch_Memory_Controller testMem(
												 .addra(percVarMux1Out),
												 .dina(percVarMux2Out),
												 .wea(percVarMux3Out),
												 .clk(clk),
												 .addrb(percVarMuxOut),
												 .doutb(memIn)
												 );
	L_mult percVar_L_mult(
								 .a(L_multOutA),
								 .b(L_multOutB),
								 .overflow(),
								 .product(L_multIn)
								);
						 
	L_shr percVar_L_shr(
								.var1(L_shrOutVar1),
								.numShift(L_shrOutNumShift),
								.overflow(),
								.out(L_shrIn)
							);
  
  L_sub percVar_L_sub(
								.a(L_subOutA),
								.b(L_subOutB),
								.overflow(),
								.diff(L_subIn)
								);
								
  L_add percVar_L_add (
								.a(L_addOutA),
								.b(L_addOutB),
								.overflow(),
								.sum(L_addIn)
								);
								
	add percVar_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
						);
						
   mult percVar_mult(
							 .a(multOutA),
							 .b(multOutB),
							 .overflow(),
							 .product(multIn)
							 );
						
	sub percVar_sub(
							.a(subOutA),
							.b(subOutB),
							.overflow(),
							.diff(subIn)
						);	
	shr percVar_shr(
						  .var1(shrVar1Out),
						  .var2(shrVar2Out),
						  .overflow(),
						  .result(shrIn)
						);
						
	shl percVar_shl(
						  .var1(shlVar1Out),
						  .var2(shlVar2Out),
						  .overflow(),
						  .result(shlIn)
						);
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		
		//TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 TEST1 
		percVarMuxSel = 0;
		percVarMux1Sel = 0;
		percVarMux2Sel = 0;
		percVarMux3Sel = 0;
		testReadAddr = 0;
		
		for(i=0;i<10;i=i+1)
		begin
			#100;
			percVarMux1Sel = 1;
			percVarMux2Sel = 1;
			percVarMux3Sel = 1;
			testWriteAddr = {LEVINSON_DURBIN_RC[10:5],i[4:0]};
			testMemOut = rc[i];
			testMemWrite = 1;	
			#100;			
		end
		
		for(i=0;i<10;i=i+1)
		begin
			#100;
			percVarMux1Sel = 1;
			percVarMux2Sel = 1;
			percVarMux3Sel = 1;
			testWriteAddr = {INTERPOLATION_LSF_INT[10:5],i[4:0]};
			testMemOut = lsfInt[i];
			testMemWrite = 1;	
			#100;
		end
		
		for(i=0;i<10;i=i+1)
		begin
			#100;
			percVarMux1Sel = 1;
			percVarMux2Sel = 1;
			percVarMux3Sel = 1;
			testWriteAddr = {INTERPOLATION_LSF_NEW[10:4],i[3:0]};
			testMemOut = lsfNew[i];
			testMemWrite = 1;	
			#100;
		end
		
		percVarMux1Sel = 0;
		percVarMux2Sel = 0;
		percVarMux3Sel = 0;		

		#50
		reset = 1;
		// Wait 50 ns for global reset to finish
		#50;
      reset = 0;
		
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
				testReadAddr = {PERC_VAR_GAMMA1[11:1],i[0]};
				@(posedge clk);
				@(posedge clk);
				if (memIn != gamma1[i])
					$display($time, " ERROR: gamma1[%d] = %x, expected = %x", i, memIn, gamma1[i]);
				else if (memIn == gamma1[i])
					$display($time, " CORRECT:  gamma1[%d] = %x", i, memIn);
				@(posedge clk);
		end	
		
		//gamma2 read
		for (i = 0; i<2;i=i+1)
		begin				
				testReadAddr = {PERC_VAR_GAMMA2[11:1],i[0]};
				@(posedge clk);
				@(posedge clk);
				if (memIn != gamma2[i])
					$display($time, " ERROR: gamma2[%d] = %x, expected = %x", i, memIn, gamma2[i]);
				else if (memIn == gamma2[i])
					$display($time, " CORRECT:  gamma2[%d] = %x", i, memIn);
				@(posedge clk);
		end
		
		//TEST2  TEST2 TEST2 TEST2 TEST2 TEST2 TEST2 TEST2 TEST2 TEST2 TEST2 TEST2 TEST2 TEST2 TEST2 TEST2 TEST2 
		#100;
		percVarMuxSel = 0;
		percVarMux1Sel = 0;
		percVarMux2Sel = 0;
		percVarMux3Sel = 0;
		testReadAddr = 0;
		
		for(i=0;i<10;i=i+1)
		begin
			#100;
			percVarMux1Sel = 1;
			percVarMux2Sel = 1;
			percVarMux3Sel = 1;
			testWriteAddr = {LEVINSON_DURBIN_RC[10:4],i[3:0]};
			testMemOut = rc[i+300];
			testMemWrite = 1;	
			#100;			
		end
		
		for(i=0;i<10;i=i+1)
		begin
			#100;
			percVarMux1Sel = 1;
			percVarMux2Sel = 1;
			percVarMux3Sel = 1;
			testWriteAddr = {INTERPOLATION_LSF_INT[10:4],i[3:0]};
			testMemOut = lsfInt[i+300];
			testMemWrite = 1;	
			#100;
		end
		
		for(i=0;i<10;i=i+1)
		begin
			#100;
			percVarMux1Sel = 1;
			percVarMux2Sel = 1;
			percVarMux3Sel = 1;
			testWriteAddr = {INTERPOLATION_LSF_NEW[10:4],i[3:0]};
			testMemOut = lsfNew[i+300];
			testMemWrite = 1;	
			#100;
		end
		
		percVarMux1Sel = 0;
		percVarMux2Sel = 0;
		percVarMux3Sel = 0;		

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
				testReadAddr = {PERC_VAR_GAMMA1[11:1],i[0]};
				@(posedge clk);
				@(posedge clk);
				if (memIn != gamma1[i+60])
					$display($time, " ERROR: gamma1[%d] = %x, expected = %x", i, memIn, gamma1[i+60]);
				else if (memIn == gamma1[i+60])
					$display($time, " CORRECT:  gamma1[%d] = %x", i, memIn);
				@(posedge clk);
		end	
		
		//gamma2 read
		for (i = 0; i<2;i=i+1)
		begin				
				testReadAddr = {PERC_VAR_GAMMA2[11:1],i[0]};
				@(posedge clk);
				@(posedge clk);
				if (memIn != gamma2[i+60])
					$display($time, " ERROR: gamma2[%d] = %x, expected = %x", i, memIn, gamma2[i+60]);
				else if (memIn == gamma2[i+60])
					$display($time, " CORRECT:  gamma2[%d] = %x", i, memIn);
				@(posedge clk);
		end
		

	end
 initial forever #10 clk = ~clk;	       
endmodule

