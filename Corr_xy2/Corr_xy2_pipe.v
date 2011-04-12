`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    20:02:40 04/11/2011 
// Module Name:    Corr_xy2_pipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for Cor_hPipe
// 
// Dependencies: 	 Cor_h.v, Scratch_Memory_Controller.v, L_sub.v, L_add.v, L_mult.v, L_mac.v,
//						 shl.v,add.v,shr.v,sub.v
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Corr_xy2_pipe(clk,reset,start,corr_xy2MuxSel,testReadAddr,testWriteAddr,testMemOut,
						   testMemWriteEn,done,memIn);

//Inputs
input clk,reset,start;
input corr_xy2MuxSel;
input [11:0] testReadAddr,testWriteAddr;
input [31:0] testMemOut;
input testMemWriteEn;


//Outputs
output done;
output [31:0] memIn;

//Internal Wires
wire [31:0] L_macIn;
wire [15:0] subIn;
wire [15:0] shrIn;
wire [15:0] norm_lIn;
wire norm_lDone;
wire [15:0] addIn;
wire [31:0] L_addIn;
wire [31:0] L_shlIn;
wire L_shlDone;
wire [31:0] L_negateIn;
wire [31:0] memOut;
wire [15:0] L_macOutA,L_macOutB;
wire [31:0] L_macOutC;
wire [15:0] subOutA,subOutB;
wire [15:0] shrVar1Out,shrVar2Out;
wire [31:0] norm_lVar1Out;
wire norm_lReady;
wire [15:0] addOutA,addOutB;
wire [31:0] L_addOutA,L_addOutB;
wire [31:0] L_shlVar1Out;
wire [15:0] L_shlNumShiftOut;
wire L_shlReady;
wire [31:0] L_negateOut;
wire [11:0] memReadAddr,memWriteAddr;
wire memWriteEn;

//Internal regs
reg [11:0] corr_xy2MuxOut,corr_xy2Mux1Out;
reg [31:0] corr_xy2Mux2Out;
reg corr_xy2Mux3Out;
//Instantiated modules	
Scratch_Memory_Controller testMem(
											 .addra(corr_xy2Mux1Out),
											 .dina(corr_xy2Mux2Out),
											 .wea(corr_xy2Mux3Out),
											 .clk(clk),
											 .addrb(corr_xy2MuxOut),
											 .doutb(memIn)
											 );
											 
Corr_xy2 fsm(
				 .clk(clk),
				 .reset(reset),
				 .start(start),
				 .shrIn(shrIn),
				 .L_macIn(L_macIn),
				 .addIn(addIn),
				 .norm_lIn(norm_lIn),
				 .norm_lDone(norm_lDone),
				 .L_shlIn(L_shlIn),
				 .L_shlDone(L_shlDone),
				 .L_addIn(L_addIn),
				 .subIn(subIn),
				 .L_negateIn(L_negateIn),
				 .memIn(memIn),
				 .shrVar1Out(shrVar1Out),
				 .shrVar2Out(shrVar2Out),
				 .L_macOutA(L_macOutA),
				 .L_macOutB(L_macOutB),
				 .L_macOutC(L_macOutC),
				 .addOutA(addOutA),
				 .addOutB(addOutB),
				 .norm_lVar1Out(norm_lVar1Out),
				 .norm_lReady(norm_lReady),
				 .L_shlVar1Out(L_shlVar1Out),
				 .L_shlNumShiftOut(L_shlNumShiftOut),
				 .L_shlReady(L_shlReady),
				 .L_addOutA(L_addOutA),
				 .L_addOutB(L_addOutB),
				 .subOutA(subOutA),
				 .subOutB(subOutB),
				 .L_negateOut(L_negateOut),
				 .memReadAddr(memReadAddr),
				 .memWriteAddr(memWriteAddr),
				 .memOut(memOut),
				 .memWriteEn(memWriteEn),
				 .done(done)
				 );
												 
L_mac corr_xy2_L_mac(
						.a(L_macOutA),
						.b(L_macOutB),
						.c(L_macOutC),
						.overflow(),
						.out(L_macIn)
					 );
					
L_negate corr_xy2_negate(
								 .var_in(L_negateOut),	
								 .var_out(L_negateIn)
								 );
 
L_shl corr_xy2_L_shl(
							 .clk(clk),
							 .reset(reset),
							 .ready(L_shlReady),
							 .overflow(),
							 .var1(L_shlVar1Out),
							 .numShift(L_shlNumShiftOut),
							 .done(L_shlDone),
							 .out(L_shlIn)
							 );								 
sub corr_xy2_sub(
						.a(subOutA),
						.b(subOutB),
						.overflow(),
						.diff(subIn)
					  );
					  
shr corr_xy2_shr(
				  .var1(shrVar1Out),
				  .var2(shrVar2Out),
				  .overflow(),
				  .result(shrIn)
				  );
add corr_xy2_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
							);		

L_add corr_xy2_L_add(
						.a(L_addOutA),
						.b(L_addOutB),
						.overflow(),
						.sum(L_addIn)
					 );
					 
norm_l corr_xy2_normL(
							.var1(norm_lVar1Out),
							.norm(norm_lIn),
							.clk(clk),
							.ready(norm_lReady),
							.reset(reset),
							.done(norm_lDone)
	
					  );
					  
	//Memory muxes
	//corr_xy2 read address mux
	always @(*)
	begin
		case	(corr_xy2MuxSel)	
			'd0 :	corr_xy2MuxOut = memReadAddr;
			'd1:	corr_xy2MuxOut = testReadAddr;
		endcase
	end
	
	//corr_xy2 write address mux
	always @(*)
	begin
		case	(corr_xy2MuxSel)	
			'd0 :	corr_xy2Mux1Out = memWriteAddr;
			'd1:	corr_xy2Mux1Out = testWriteAddr;
		endcase
	end
	
	//corr_xy2 write input mux
	always @(*)
	begin
		case	(corr_xy2MuxSel)	
			'd0 :	corr_xy2Mux2Out = memOut;
			'd1:	corr_xy2Mux2Out = testMemOut;
		endcase
	end
	
	//corr_xy2 write enable mux
	always @(*)
	begin
		case	(corr_xy2MuxSel)	
			'd0 :	corr_xy2Mux3Out = memWriteEn;
			'd1:	corr_xy2Mux3Out = testMemWriteEn;
		endcase
	end

endmodule
