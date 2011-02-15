`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:36:31 02/04/2011 
// Design Name: 
// Module Name:    Lag_Window_Pipe 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lag_Window_Pipe(clk,L_multOutA,L_multOutB,multOutA,multOutB,L_macOutA,L_macOutB,L_macOutC,
							  L_msuOutA,L_msuOutB,L_msuOutC,addOutA,addOutB,L_shrOutNumShift,L_shrOutVar1,
							  rPrimeWrite,rPrimeRequested,rPrimeOut,lagMuxSel,L_multIn,multIn,L_macIn,
							  L_msuIn,addIn,L_shrIn,rPrimeIn,testWriteEnable,testWriteOut,testWriteRequested,
							  testReadRequested
							  );
	 
	// Inputs
	input clk;
	input [15:0] L_multOutA;
	input [15:0] L_multOutB;
	input [15:0] multOutA;
	input [15:0] multOutB;
	input [15:0] L_macOutA;
	input [15:0] L_macOutB;
	input [31:0] L_macOutC;
	input [15:0] L_msuOutA;
	input [15:0] L_msuOutB;
	input [31:0] L_msuOutC;
	input [15:0] addOutA;
	input [15:0] addOutB;
	input [15:0] L_shrOutNumShift;
	input [31:0] L_shrOutVar1;
	input rPrimeWrite;
	input [10:0] rPrimeRequested;
	input [31:0] rPrimeOut;
	input lagMuxSel;
	input testWriteEnable;
	input [31:0] testWriteOut;
	input [10:0] testWriteRequested;
	input [10:0] testReadRequested;
	
	//output
	output [31:0] L_multIn;
	output [15:0] multIn;
	output [31:0] L_macIn;
	output [31:0] L_msuIn;
	output [15:0] addIn;
	output [31:0] L_shrIn;
	output [31:0] rPrimeIn;
	
	//working regs		
	reg [10:0] lagMuxOut;
	reg [10:0] lagMux1Out;	
	reg [31:0] lagMux2Out;
	reg lagMux3Out;


	 
	 L_mult lag_L_mult(
							 .a(L_multOutA),
							 .b(L_multOutB),
							 .overflow(),
							 .product(L_multIn)
							 );
			 
	 mult lag_mult(
						.a(multOutA), 
						.b(multOutB),
						.multRsel(1'd0),
						.overflow(),
						.product(multIn)
						);
						
	L_mac lag_L_mac(
							.a(L_macOutA),
							.b(L_macOutB),
							.c(L_macOutC),
							.overflow(),
							.out(L_macIn)
						);
						
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
						 
	Scratch_Memory_Controller lagMem(
												 .addra(lagMux1Out),
												 .dina(lagMux2Out),
												 .wea(lagMux3Out),
												 .clk(clk),
												 .addrb(lagMuxOut),
												 .doutb(rPrimeIn)
												 );
												 
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
		case	(lagMuxSel)	
			'd0 :	lagMux1Out = rPrimeRequested;
			'd1:	lagMux1Out = testWriteRequested;
		endcase
	end
	
	//lag write output mux
	always @(*)
	begin
		case	(lagMuxSel)	
			'd0 :	lagMux2Out = rPrimeOut;
			'd1:	lagMux2Out = testWriteOut;
		endcase
	end
	
		//lag write enable mux
	always @(*)
	begin
		case	(lagMuxSel)	
			'd0 :	lagMux3Out = rPrimeWrite;
			'd1:	lagMux3Out = testWriteEnable;
		endcase
	end

endmodule
