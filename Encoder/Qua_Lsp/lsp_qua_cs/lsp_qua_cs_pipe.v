`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Mississippi State University
// Engineer: Nick Robinson
// 
// Create Date:    14:59:32 03/26/2011 
// Design Name: 
// Module Name:    Relspwed_pipe 
// Project Name: 	 G.729 Verilog Encoder
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
module lsp_qua_cs_pipe(clk, reset, start, flspAddr, lspqAddr, freq_prevAddr,
							testReadAddr, testWriteAddr, testMemOut, testMemWriteEn, done, memIn, code_anaAddr,
							relspwedMuxSel
							);
		
		//Inputs
		input clk,reset,start;	
		input [11:0] lspqAddr;
		input [11:0] flspAddr;
		input [11:0] freq_prevAddr;
		input [11:0] code_anaAddr;
		input relspwedMuxSel; 
		input [11:0] testReadAddr;
		input [11:0] testWriteAddr; 
		input [31:0] testMemOut;
		input testMemWriteEn;
		
		//Outputs
		output done;
		output [31:0] memIn;
		
		//Wires
		wire [31:0] L_addIn;
		wire [31:0] L_subIn;
		wire [31:0] L_multIn;
		wire [31:0] L_macIn;
		wire [31:0] L_msuIn;
		wire [15:0] addIn;
		wire [15:0] subIn;
		wire [15:0] shrIn;
		wire [15:0] shlIn;
		wire [15:0] multIn;
		wire [31:0] L_shlIn;
		wire L_shlDone;
		wire [31:0] L_shlOutVar1;
      wire [15:0] L_shlNumShiftOut;
      wire L_shlReady;	
		wire [15:0] shrVar1Out;
		wire [15:0] shrVar2Out;	
		wire [15:0] shlOutVar1;
		wire [15:0] shlOutVar2;
		wire [31:0] L_addOutA, L_addOutB;
		wire [31:0] L_subOutA, L_subOutB;
		wire [15:0] L_multOutA, L_multOutB;
		wire [15:0] L_macOutA, L_macOutB;
		wire [31:0] L_macOutC;
		wire [15:0] L_msuOutA, L_msuOutB;
		wire [31:0] L_msuOutC;
		wire [15:0] addOutA, addOutB;
		wire [15:0] subOutA, subOutB;
		wire [15:0] multOutA, multOutB;
		wire norm_sReady;
		wire [15:0] norm_sOut; 
		wire [15:0] norm_sIn;
		wire norm_sDone;
		wire [31:0] memIn;
		wire [31:0] constantMemIn;
		wire [31:0] memOut;
		wire [11:0] memReadAddr;
		wire [11:0] memWriteAddr;
		wire memWriteEn;
		wire [11:0] constantMemAddr;
		
		//Regs
		reg [11:0] relspwedMuxOut;
		reg [11:0] relspwedMux1Out;
		reg [31:0] relspwedMux2Out;
		reg relspwedMux3Out;
		
		//Memory muxes
	//getQuant read address mux
	always @(*)
	begin
		case	(relspwedMuxSel)	
			'd0 :	relspwedMuxOut = memReadAddr;
			'd1:	relspwedMuxOut = testReadAddr;
		endcase
	end
	
	//getQuant write address mux
	always @(*)
	begin
		case	(relspwedMuxSel)	
			'd0 :	relspwedMux1Out = memWriteAddr;
			'd1:	relspwedMux1Out = testWriteAddr;
		endcase
	end
	
	//getQuant write input mux
	always @(*)
	begin
		case	(relspwedMuxSel)	
			'd0 :	relspwedMux2Out = memOut;
			'd1:	relspwedMux2Out = testMemOut;
		endcase
	end
	
	//getQuant write enable mux
	always @(*)
	begin
		case	(relspwedMuxSel)	
			'd0 :	relspwedMux3Out = memWriteEn;
			'd1:	relspwedMux3Out = testMemWriteEn;
		endcase
	end
	
	//Instantiated modules	
	Scratch_Memory_Controller testMem(
												 .addra(relspwedMux1Out),
												 .dina(relspwedMux2Out),
												 .wea(relspwedMux3Out),
												 .clk(clk),
												 .addrb(relspwedMuxOut),
												 .doutb(memIn)
												 );
												 
	Constant_Memory_Controller constantMem(
														.addra(constantMemAddr),
														.dina(32'd0),
														.wea(1'd0),
														.clock(clk),
														.douta(constantMemIn)
														);
														
	lsp_qua_cs_FSM lsp_fsm(
						.clk(clk), 
						.reset(reset), 
						.start(start), 
						.L_addIn(L_addIn), 
						.L_subIn(L_subIn), 
						.L_multIn(L_multIn), 
						.L_macIn(L_macIn), 
						.addIn(addIn), 
						.subIn(subIn),  
						.shrIn(shrIn), 
						.memIn(memIn), 
						.constantMemIn(constantMemIn), 
						.L_addOutA(L_addOutA), 
						.L_addOutB(L_addOutB), 
						.L_subOutA(L_subOutA), 
						.L_subOutB(L_subOutB), 
						.L_multOutA(L_multOutA), 
						.L_multOutB(L_multOutB), 
						.L_macOutA(L_macOutA), 
						.L_macOutB(L_macOutB), 
						.L_macOutC(L_macOutC),
						.addOutA(addOutA), 
						.addOutB(addOutB), 
						.subOutA(subOutA), 
						.subOutB(subOutB), 
						.shrVar1Out(shrVar1Out), 
						.shrVar2Out(shrVar2Out), 
						.L_msuOutA(L_msuOutA), 
						.L_msuOutB(L_msuOutB), 
						.L_msuOutC(L_msuOutC), 
						.L_msuIn(L_msuIn), 
						.L_shlIn(L_shlIn), 
						.L_shlOutVar1(L_shlOutVar1), 
						.L_shlReady(L_shlReady), 
						.L_shlDone(L_shlDone), 
						.L_shlNumShiftOut(L_shlNumShiftOut), 
						.multOutA(multOutA), 
						.multOutB(multOutB), 
						.memOut(memOut), 
						.multIn(multIn),
						.memReadAddr(memReadAddr), 
						.memWriteAddr(memWriteAddr), 
						.memWriteEn(memWriteEn), 
						.constantMemAddr(constantMemAddr), 
						.done(done), 
						.flspAddr(flspAddr),
						.lspqAddr(lspqAddr), 
						.code_anaAddr(code_anaAddr),
						.freq_prevAddr(freq_prevAddr),
						.shlOutVar1(shlOutVar1), 
						.shlOutVar2(shlOutVar2), 
						.shlIn(shlIn), 
						.norm_sIn(norm_sIn),
						.norm_sDone(norm_sDone),
						.norm_sOut(norm_sOut), 
						.norm_sReady(norm_sReady)
						);
							
	L_add relspwed_L_add(
							.a(L_addOutA),
							.b(L_addOutB),
							.overflow(),
							.sum(L_addIn)
							);
							
	L_sub relspwed_L_sub(
								.a(L_subOutA),
								.b(L_subOutB),
								.overflow(),
								.diff(L_subIn)
								);
								
	add relspwed_add(
							.a(addOutA),
							.b(addOutB),
							.overflow(),
							.sum(addIn)
							);
							
	sub relspwed_sub(
						  .a(subOutA),
						  .b(subOutB),
						  .overflow(),
						  .diff(subIn)
						);
						
	mult relspwed_mult(
							 .a(multOutA),
							 .b(multOutB),
							 .multRsel(),
							 .overflow(),
							 .product(multIn)
							);
						
	shr relspwed_shr(
						  .var1(shrVar1Out),
						  .var2(shrVar2Out),
						  .overflow(),
						  .result(shrIn)
						);
						
	shl relspwed_shl(
							.var1(shlOutVar1),
							.var2(shlOutVar2),
							.overflow(),
							.result(shlIn)
						);
				  
	L_mult relspwed_L_mult(
									.a(L_multOutA),
									.b(L_multOutB),
									.overflow(),
									.product(L_multIn)
								 );
								 
	L_msu relspwed_L_msu(
								.a(L_msuOutA),
								.b(L_msuOutB),
								.c(L_msuOutC),
								.overflow(),
								.out(L_msuIn)
							);
									
	L_mac relspwed_L_mac(
								.a(L_macOutA),
								.b(L_macOutB),
								.c(L_macOutC),
								.overflow(),
								.out(L_macIn)
							);
							
	L_shl relspwed_L_shl(
								.clk(clk),
								.reset(reset),
								.ready(L_shlReady),
								.overflow(),
								.var1(L_shlOutVar1),
								.numShift(L_shlNumShiftOut),
								.done(L_shlDone),
								.out(L_shlIn)
							);
							
	norm_s getWegt_norm_s(
						.var1(norm_sOut),
						.norm(norm_sIn),
						.clk(clk),
						.ready(norm_sReady),
						.reset(reset),
						.done(norm_sDone)
					);
		
								  
endmodule
