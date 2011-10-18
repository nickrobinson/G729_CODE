		`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    14:54:14 03/25/2011
// Module Name:    D4i40_17_pipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for D4i40_17
// 
// Dependencies: 	 D4i40_17.v, Scratch_Memory_Controller.v, add.v, L_negate.v, sub.v, L_mac.v, L_shr.v, mult.v,
//						 L_mult.v, L_msu.v, L_sub.v, shr.v
// 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module D4i40_17_pipe(clk, reset,start,i_subfr,D17MuxSel,testReadAddr,testWriteAddr,testMemOut,testMemWriteEn,
							done,i,memIn);

//Inputs
input clk, reset,start;
input [15:0] i_subfr;
input D17MuxSel;
input [11:0] testReadAddr,testWriteAddr;
input [31:0] testMemOut;
input testMemWriteEn;

//Outputs
output done;
output [15:0] i;
output [31:0] memIn;

//Internal Wires
wire [31:0] L_addIn;
wire [15:0] addIn;
wire [31:0] L_negateIn;
wire [15:0] subIn;
wire [31:0] L_macIn;
wire [31:0] L_shrIn;
wire [15:0] multIn;
wire [31:0] L_multIn;
wire [31:0] L_msuIn;
wire [31:0] L_subIn;
wire [15:0] shrIn;
wire [15:0] shlIn;
wire [15:0] addOutA,addOutB;
wire [31:0] L_addOutA,L_addOutB;
wire [31:0] L_negateOut;
wire [15:0] subOutA,subOutB;
wire [15:0] L_macOutA,L_macOutB;
wire [31:0] L_macOutC;
wire [31:0] L_shrVar1Out;
wire [15:0] L_shrNumShiftOut;
wire [15:0] multOutA,multOutB;
wire [15:0] L_multOutA,L_multOutB;
wire [15:0] L_msuOutA,L_msuOutB;
wire [31:0] L_msuOutC;
wire [31:0] L_subOutA,L_subOutB;
wire [15:0] shrVar1Out,shrVar2Out;
wire [15:0] shlVar1Out,shlVar2Out;
wire [11:0] memReadAddr,memWriteAddr;
wire memWriteEn;
wire [31:0] memOut;

//Internal regs
reg [11:0] D17MuxOut,D17Mux1Out;
reg [31:0] D17Mux2Out;
reg D17Mux3Out;

//Instantiated Modules
D4i40_17 fsm(
				 .clk(clk),
				 .reset(reset),
				 .start(start),
				 .addIn(addIn),
				 .L_addIn(L_addIn),
				 .L_negateIn(L_negateIn),
				 .subIn(subIn),
				 .L_macIn(L_macIn),
				 .L_shrIn(L_shrIn),
				 .multIn(multIn),
				 .L_multIn(L_multIn),
				 .L_msuIn(L_msuIn),
				 .L_subIn(L_subIn),
				 .shrIn(shrIn),
				 .shlIn(shlIn),
				 .memIn(memIn),
				 .i_subfr(i_subfr),
				 .addOutA(addOutA),
				 .addOutB(addOutB),
				 .L_addOutA(L_addOutA),
				 .L_addOutB(L_addOutB),
				 .L_negateOut(L_negateOut),
				 .subOutA(subOutA),
				 .subOutB(subOutB),
				 .L_macOutA(L_macOutA),
				 .L_macOutB(L_macOutB),
				 .L_macOutC(L_macOutC),
				 .L_shrVar1Out(L_shrVar1Out),
				 .L_shrNumShiftOut(L_shrNumShiftOut),
				 .multOutA(multOutA),
				 .multOutB(multOutB),
				 .L_multOutA(L_multOutA),
				 .L_multOutB(L_multOutB),
				 .L_msuOutA(L_msuOutA),
				 .L_msuOutB(L_msuOutB),
				 .L_msuOutC(L_msuOutC),
				 .L_subOutA(L_subOutA),
				 .L_subOutB(L_subOutB),
				 .shrVar1Out(shrVar1Out),
				 .shrVar2Out(shrVar2Out),
				 .shlVar1Out(shlVar1Out),
				 .shlVar2Out(shlVar2Out),
				 .memReadAddr(memReadAddr),
				 .memWriteAddr(memWriteAddr),
				 .memWriteEn(memWriteEn),
				 .memOut(memOut),
				 .i(i),
				 .done(done)
				 );
add D17_add(
				.a(addOutA),
				.b(addOutB),
				.overflow(),
				.sum(addIn)
				);
L_add D17_L_add(
						.a(L_addOutA),
						.b(L_addOutB),
						.overflow(),
						.sum(L_addIn)
					 );
L_negate D17_L_negate(
							 .var_in(L_negateOut),
							 .var_out(L_negateIn)
							 );
sub D17_sub(
				.a(subOutA),
				.b(subOutB),
				.overflow(),
				.diff(subIn)
			  );
L_mac D17_L_mac(
						.a(L_macOutA),
						.b(L_macOutB),
						.c(L_macOutC),
						.overflow(),
						.out(L_macIn)
					 );
L_shr D17_L_shr(
					  .var1(L_shrVar1Out),
					  .numShift(L_shrNumShiftOut),
					  .overflow(),
					  .out(L_shrIn)
					  );
mult D17_mult(
					.a(multOutA),
					.b(multOutB),
					.multRsel(),
					.overflow(),
					.product(multIn)
					);
L_mult D17_L_mult(
					.a(L_multOutA),
					.b(L_multOutB),					
					.overflow(),
					.product(L_multIn)
					);
L_msu D17_L_msu(
						.a(L_msuOutA),
						.b(L_msuOutB),
						.c(L_msuOutC),
						.overflow(),
						.out(L_msuIn)
					 );
L_sub D17_L_sub(
						.a(L_subOutA),
						.b(L_subOutB),
						.overflow(),
						.diff(L_subIn)
					  );
shr D17_shr(
				  .var1(shrVar1Out),
				  .var2(shrVar2Out),
				  .overflow(),
				  .result(shrIn)
				  );
shl D17_shl(
				  .var1(shlVar1Out),
				  .var2(shlVar2Out),
				  .overflow(),
				  .result(shlIn)
				  );
Scratch_Memory_Controller testMem(
											 .addra(D17Mux1Out),
											 .dina(D17Mux2Out),
											 .wea(D17Mux3Out),
											 .clk(clk),
											 .addrb(D17MuxOut),
											 .doutb(memIn)
											 );
	//Memory muxes
	//D17 read address mux
	always @(*)
	begin
		case	(D17MuxSel)	
			'd0 :	D17MuxOut = memReadAddr;
			'd1:	D17MuxOut = testReadAddr;
		endcase
	end
	
	//D17 write address mux
	always @(*)
	begin
		case	(D17MuxSel)	
			'd0 :	D17Mux1Out = memWriteAddr;
			'd1:	D17Mux1Out = testWriteAddr;
		endcase
	end
	
	//D17 write input mux
	always @(*)
	begin
		case	(D17MuxSel)	
			'd0 :	D17Mux2Out = memOut;
			'd1:	D17Mux2Out = testMemOut;
		endcase
	end
	
	//D17 write enable mux
	always @(*)
	begin
		case	(D17MuxSel)	
			'd0 :	D17Mux3Out = memWriteEn;
			'd1:	D17Mux3Out = testMemWriteEn;
		endcase
	end

endmodule
