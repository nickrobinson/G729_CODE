`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    10:02:13 03/31/2011 
// Module Name:    Cor_h_X_Pipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 A pipe to instantiate the FSM and math and memories needed for Cor_h_X
// 
// Dependencies: 	 Cor_h_X.v, Scratch_Memory_Controller.v, L_mac.v, L_abs.v, L_sub.v, add.v, 
//						 norm_l.v, sub.v, L_shr.v
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cor_h_X_Pipe(clk,reset,start,corHXMuxSel,testReadAddr,testWriteAddr,testMemOut,
						  testMemWriteEn,memIn,done);

//Inputs
input clk,reset,start;
input corHXMuxSel;
input [11:0] testReadAddr,testWriteAddr;
input [31:0] testMemOut;
input testMemWriteEn;

//Outputs
output [31:0] memIn;
output done;

//Internal wires
wire [31:0] L_macIn;
wire [31:0] L_absIn;
wire [31:0] L_subIn;
wire [15:0] addIn;
wire [15:0] norm_lIn;
wire norm_lDone;
wire [15:0] subIn;
wire [31:0] L_shrIn;
wire [15:0] L_macOutA,L_macOutB;
wire [31:0] L_macOutC;
wire [31:0] L_absOut;
wire [31:0] L_subOutA,L_subOutB;
wire [15:0] addOutA,addOutB;
wire [31:0] norm_lVar1Out;
wire norm_lReady;
wire [15:0] subOutA,subOutB;
wire [31:0] L_shrVar1Out;
wire [15:0] L_shrNumShiftOut;
wire [11:0] memReadAddr,memWriteAddr;
wire [31:0] memOut;
wire memWriteEn;

//Internal regs
reg [11:0] corHXMuxOut,corHXMux1Out;
reg [31:0] corHXMux2Out;
reg corHXMux3Out;

//Instantiated modules	
	Scratch_Memory_Controller testMem(
												 .addra(corHXMux1Out),
												 .dina(corHXMux2Out),
												 .wea(corHXMux3Out),
												 .clk(clk),
												 .addrb(corHXMuxOut),
												 .doutb(memIn)
												 );
											
Cor_h_X fsm(
				.clk(clk),
				.reset(reset),
				.start(start),
				.L_macIn(L_macIn),
				.L_absIn(L_absIn),
				.L_subIn(L_subIn),
				.addIn(addIn),
				.norm_lIn(norm_lIn),
				.norm_lDone(norm_lDone),
				.subIn(subIn),
				.L_shrIn(L_shrIn),
				.memIn(memIn),
				.L_macOutA(L_macOutA),
				.L_macOutB(L_macOutB),
				.L_macOutC(L_macOutC),
				.L_absOut(L_absOut),
				.L_subOutA(L_subOutA),
				.L_subOutB(L_subOutB),
				.addOutA(addOutA),
				.addOutB(addOutB),
				.norm_lVar1Out(norm_lVar1Out),
				.norm_lReady(norm_lReady),
				.subOutA(subOutA),
				.subOutB(subOutB),
				.L_shrVar1Out(L_shrVar1Out),
				.L_shrNumShiftOut(L_shrNumShiftOut),
				.memReadAddr(memReadAddr),
				.memWriteAddr(memWriteAddr),
				.memOut(memOut),
				.memWriteEn(memWriteEn),
				.done(done)
				);
				
L_mac corHX_L_mac(
						.a(L_macOutA),
						.b(L_macOutB),
						.c(L_macOutC),
						.overflow(),
						.out(L_macIn)
					 );
					
L_abs corHX_L_abs(
						.var_in(L_absOut),
						.var_out(L_absIn)
						);
				
L_sub corHX_L_sub(
						.a(L_subOutA),
						.b(L_subOutB),
						.overflow(),
						.diff(L_subIn)
					  );
					 
add corHX_add(
					.a(addOutA),
					.b(addOutB),
					.overflow(),
					.sum(addIn)
				);	

sub corHX_sub(
						.a(subOutA),
						.b(subOutB),
						.overflow(),
						.diff(subIn)
					  );

norm_l corHX_normL(
							.var1(norm_lVar1Out),
							.norm(norm_lIn),
							.clk(clk),
							.ready(norm_lReady),
							.reset(reset),
							.done(norm_lDone)
	
					  );
					  
L_shr corHX_L_shr(
					  .var1(L_shrVar1Out),
					  .numShift(L_shrNumShiftOut),
					  .overflow(),
					  .out(L_shrIn)
					  );
					 
	//Memory muxes
	//corHX read address mux
	always @(*)
	begin
		case	(corHXMuxSel)	
			'd0 :	corHXMuxOut = memReadAddr;
			'd1:	corHXMuxOut = testReadAddr;
		endcase
	end
	
	//corHX write address mux
	always @(*)
	begin
		case	(corHXMuxSel)	
			'd0 :	corHXMux1Out = memWriteAddr;
			'd1:	corHXMux1Out = testWriteAddr;
		endcase
	end
	
	//corHX write input mux
	always @(*)
	begin
		case	(corHXMuxSel)	
			'd0 :	corHXMux2Out = memOut;
			'd1:	corHXMux2Out = testMemOut;
		endcase
	end
	
	//corHX write enable mux
	always @(*)
	begin
		case	(corHXMuxSel)	
			'd0 :	corHXMux3Out = memWriteEn;
			'd1:	corHXMux3Out = testMemWriteEn;
		endcase
	end

endmodule
