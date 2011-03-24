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
	reg [11:0] A;
	reg [11:0] X;
	reg [11:0] Y;	

	// Outputs
	wire done;
	wire [31:0] FSMdataIn1;	
	
	//regs/wires inside TB
	reg MuxSel;	//0 = TB, 1 = FSM
	reg [11:0] TBwriteAddr1;
	reg [11:0] TBwriteAddr2;
	reg [31:0] TBdataOut1;
	reg [31:0] TBdataOut2;
	reg TBwriteEn1;
	reg TBwriteEn2;
	reg [11:0] TBreadAddr;
	
	//Memory Regs
	reg [31:0] RESIDU_IN_A [0:9999];		  
	reg [31:0] RESIDU_IN_X [0:9999];
	reg [31:0] RESIDU_OUT_Y [0:9999];
	
	//Integers/Chars/Strings/etc
	integer i,j;
	reg [11:0] temp;
	
	Residu_pipe _pipe(
	.clk(clk),
	.reset(reset),
	.start(start),
	.A(A),
	.X(X),
	.Y(Y),
	.MuxSel(MuxSel),
	.TBwriteAddr1(TBwriteAddr1),
	.TBwriteAddr2(TBwriteAddr2),
	.TBdataOut1(TBdataOut1),
	.TBdataOut2(TBdataOut2),
	.TBwriteEn1(TBwriteEn1),
	.TBwriteEn2(TBwriteEn2),
	.TBreadAddr(TBreadAddr),	
	.done(done),
	.FSMdataIn1(FSMdataIn1)
);	
	
	initial 
	begin
		// samples out are samples from ITU G.729 test vectors
		$readmemh("residu_a_in.out", RESIDU_IN_A);
		$readmemh("residu_x_in.out", RESIDU_IN_X);
		$readmemh("residu_y_out.out", RESIDU_OUT_Y);
    end
	
	initial forever #10 clk = ~clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		A = 'd256;
		X = 'd64;
		Y = 'd16;
		MuxSel = 0;
		
		@(posedge clk) #5;
		reset = 1;
		// Wait 100 ns for global reset to finish
		@(posedge clk) #5;
		reset = 0;

		@(posedge clk);
		@(posedge clk) #5;
		
		for(j=0;j<120;j=j+1)
		begin
		@(posedge clk);
		@(posedge clk) #5;
			// Add stimulus here
			for(i = 0; i < 11; i = i + 1)
			begin
				@(posedge clk);
				@(posedge clk) #5;
				TBwriteAddr1 = {A[11:4],i[3:0]};
				TBdataOut1 = RESIDU_IN_A[j*11+i];
				TBwriteEn1 = 1;
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			for(i = 0; i < 50; i = i + 1)
			begin
				@(posedge clk);
				@(posedge clk) #5;
				temp = X - 10 + i;
				TBwriteAddr2 = temp[11:0];
				TBdataOut2 = RESIDU_IN_X[j*50+i];
				TBwriteEn2 = 1;
				@(posedge clk);
				@(posedge clk) #5;
			end
			
			@(posedge clk);
			@(posedge clk) #5;
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
			#100;
		end//j loop
	end//always 
      
endmodule

