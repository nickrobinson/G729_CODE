`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:20:34 02/03/2011
// Design Name:   Residu
// Module Name:   C:/Users/Cooper/Documents/_SeniorDesign/Residu/Residu_test.v
// Project Name:  Residu
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Residu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Residu_test;

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [10:0] A;
	reg [10:0] X;
	reg [10:0] Y;
	reg [5:0] LG;
	wire [31:0] FSMdataIn1;
	wire [31:0] FSMdataIn2;
	wire [31:0] L_multIn;
	wire [31:0] L_macIn;
	wire [15:0] subIn;
	wire [31:0] L_shlIn;
	wire L_shlDone;
	wire L_shlReady;
	wire [15:0] addIn;
	wire [31:0] L_addIn;

	// Outputs
	wire done;
	wire FSMwriteEn;
	wire [10:0] FSMreadAddr1;
	wire [10:0] FSMreadAddr2;
	wire [10:0] FSMwriteAddr;
	wire [15:0] FSMdataOut;
	wire [15:0] L_multOutA;
	wire [15:0] L_multOutB;
	wire [15:0] L_macOutA;
	wire [15:0] L_macOutB;
	wire [31:0] L_macOutC;
	wire [15:0] subOutA;
	wire [15:0] subOutB;
	wire [31:0] L_shlOutA;
	wire [15:0] L_shlOutB;
	wire [15:0] addOutA;
	wire [15:0] addOutB;
	wire [31:0] L_addOutA;
	wire [31:0] L_addOutB;
	
	//regs/wires inside TB
	reg MuxSel;	//0 = TB, 1 = FSM
	reg [10:0] TBwriteAddr1;
	reg [10:0] TBwriteAddr2;
	reg [31:0] TBdataOut1;
	reg [31:0] TBdataOut2;
	reg TBwriteEn1;
	reg TBwriteEn2;
	reg [10:0] TBreadAddr;
	reg [10:0] writeAddrMuxOut;
	reg [31:0] dataInMuxOut;
	reg writeEnMuxOut;
	reg [10:0] readAddrMuxOut;
	
	//Memory Regs
	reg [31:0] RESIDU_IN_A [0:9999];		  
	reg [31:0] RESIDU_IN_X [0:9999];
	reg [31:0] RESIDU_OUT_Y [0:9999];
	
	//Integers/Chars/Strings/etc
	integer i,j;
	
	// Instantiate the Unit Under Test (UUT)
	Residu uut (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.done(done), 
		.A(A), 
		.X(X), 
		.Y(Y), 
		.LG('d40), 
		.FSMdataIn1(FSMdataIn1), 
		.FSMdataIn2(FSMdataIn2), 
		.FSMwriteEn(FSMwriteEn), 
		.FSMreadAddr1(FSMreadAddr1), 
		.FSMreadAddr2(FSMreadAddr2), 
		.FSMwriteAddr(FSMwriteAddr), 
		.FSMdataOut(FSMdataOut), 
		.L_multOutA(L_multOutA), 
		.L_multOutB(L_multOutB), 
		.L_multIn(L_multIn), 
		.L_macOutA(L_macOutA), 
		.L_macOutB(L_macOutB), 
		.L_macOutC(L_macOutC), 
		.L_macIn(L_macIn), 
		.subOutA(subOutA), 
		.subOutB(subOutB), 
		.subIn(subIn), 
		.L_shlOutA(L_shlOutA), 
		.L_shlOutB(L_shlOutB), 
		.L_shlIn(L_shlIn), 
		.L_shlReady(L_shlReady),
		.L_shlDone(L_shlDone),
		.addOutA(addOutA), 
		.addOutB(addOutB), 
		.addIn(addIn), 
		.L_addOutA(L_addOutA), 
		.L_addOutB(L_addOutB), 
		.L_addIn(L_addIn)
	);
	
	//memory A,Y
	Scratch_Memory_Controller Mem1(
		 .addra(writeAddrMuxOut),
		 .dina(dataInMuxOut),
		 .wea(writeEnMuxOut),
		 .clk(clk),
		 .addrb(readAddrMuxOut),
		 .doutb(FSMdataIn1)
		 );
	
	//memory X
	Scratch_Memory_Controller Mem2(
		 .addra(TBwriteAddr2),
		 .dina(TBdataOut2),
		 .wea(TBwriteEn2),
		 .clk(clk),
		 .addrb(FSMreadAddr2),
		 .doutb(FSMdataIn2)
		 );
	
	
	add _add(
		.a(addOutA),
		.b(addOutB),
		.overflow(),
		.sum(addIn)
		);
	
	sub _sub(
		.a(subOutA),
		.b(subOutB),
		.overflow(),
		.diff(subIn)
		);
	
	L_mult _L_mult(
		.a(L_multOutA),
		.b(L_multOutB),
		.overflow(),
		.product(L_multIn)
		);
	
	L_mac _L_mac(
		.a(L_macOutA),
		.b(L_macOutB),
		.c(L_macOutC),
		.overflow(),
		.out(L_macIn)
		);
	
	L_shl _L_shl(
		.clk(clk),
		.reset(reset),
		.ready(L_shlReady),
		.overflow(),
		.var1(L_shlOutA),
		.numShift(L_shlOutB),
		.done(L_shlDone),
		.out(L_shlIn)
		);

	L_add _L_add(
		.a(L_addOutA),
		.b(L_addOutB),
		.overflow(),
		.sum(L_addIn)
		);
	
	//write address mux for Memory A,Y
	always @(*)
	begin
		case	(MuxSel)	
			'd0:	writeAddrMuxOut = TBwriteAddr1;
			'd1:	writeAddrMuxOut = FSMwriteAddr;
		endcase
	end
	
	//data in mux for Memory A,Y
	always @(*)
	begin
		case	(MuxSel)	
			'd0:	dataInMuxOut = TBdataOut1;
			'd1:	dataInMuxOut = FSMdataOut;
		endcase
	end
		
	//write enable mux for Memory A,Y
	always @(*)
	begin
		case	(MuxSel)	
			'd0:	writeEnMuxOut = TBwriteEn1;
			'd1:	writeEnMuxOut = FSMwriteEn;
		endcase
	end
			
	//read address mux for Memory A,Y
	always @(*)
	begin
		case	(MuxSel)	
			'd0:	readAddrMuxOut = TBreadAddr;
			'd1:	readAddrMuxOut = FSMreadAddr1;
		endcase
	end
	
	initial 
	begin
		// samples out are samples from ITU G.729 test vectors
		$readmemh("residu_in_a.out", RESIDU_IN_A);
		$readmemh("residu_in_x.out", RESIDU_IN_X);
		$readmemh("residu_out_y.out", RESIDU_OUT_Y);
    end
	
	initial forever #10 clk = ~clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		A = 'd0;
		X = 'd10;
		Y = 'd16;
		LG = 'd40;
		MuxSel = 0;
		
		#100;
		reset = 1;
		// Wait 100 ns for global reset to finish
		#100;
		reset = 0;
		#100;
		
		for(j=0;j<120;j=j+1)
		begin
			#100;
			// Add stimulus here
			for(i = 0; i < 11; i = i + 1)
			begin
				#100;
				TBwriteAddr1 = (j*11+i);
				TBdataOut1 = RESIDU_IN_A[j*11+i];
				TBwriteEn1 = 1;
				@(posedge clk);
			end
			
			for(i = 0; i < 49; i = i + 1)
			begin
				#100;
				TBwriteAddr2 = (j*49+i);
				TBdataOut2 = RESIDU_IN_X[j*49+i];
				TBwriteEn2 = 1;
				@(posedge clk);
			end
			
			TBwriteEn1 = 0;
			TBwriteEn2 = 0;
			MuxSel = 1;
			
			#100;
			start = 1;
			#100;
			start = 0;
			#100;
			
			wait(done);
			
			MuxSel = 0;
			for(i = 0; i < 40; i = i + 1)
			begin
				TBreadAddr = {Y[10:6], i[5:0]};
				#50;
				if (FSMdataIn1 != RESIDU_OUT_Y[40*j+i])
					$display($time, " ERROR: y[%d] = %x, expected = %x", 40*j+i, FSMdataIn1, RESIDU_OUT_Y[40*j+i]);
				else
					$display($time, " CORRECT:  y[%d] = %x", 40*j+i, FSMdataIn1);
			end
		end//j loop
	end//always 
      
endmodule

