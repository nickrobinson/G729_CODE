			`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:26:39 10/10/2011 
// Design Name: 
// Module Name:    lsp_decw_reset_pipe 
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
module lsp_decw_reset_pipe(clk, reset, start, done, memInTest, memReadAddrTest
	);

	//inputs
	input clk;
	input reset;
	input start;
	input [11:0] memReadAddrTest;
	
	output done;
	output [31:0] memInTest;

	wire [15:0] add_a, add_b;
	wire [31:0] L_add_a, L_add_b;
	wire [15:0] addIn;
	wire [31:0] L_addIn;
	
	wire [31:0] memIn;
	wire [31:0] memOut;
	wire [11:0] memReadAddr;
	wire [11:0] memWriteAddr;
	wire memWriteEn;

	add lsp_reset_add(
	.a(add_a),
	.b(add_b),
	.overflow(),
	.sum(addIn));
	
	L_add lsp_reset_L_add(
	.a(L_add_a),
	.b(L_add_b), 
	.overflow(),
	.sum(L_addIn)
	);
	
	//Instantited Modules	
	Scratch_Memory_Controller testMem(
	.addra(memWriteAddr),
	.dina(memOut),
	.wea(memWriteEn),
   .clk(clk),
   .addrb(memReadAddrTest),
   .doutb(memInTest)
   );
	
	Const_Memory_Controller constMem(
	.addra(memReadAddr),
	.dina(),
	.douta(memIn),
	.wea(0),
	.clock(clk)
	);
 	
	lsp_decw_reset i_fsm(
	.clk(clk), 
	.reset(reset), 
	.start(start), 
	.addIn(addIn), 
	.L_addIn(L_addIn),  
	.add_a(add_a), 
	.add_b(add_b), 
   .L_add_a(L_add_a), 
	.L_add_b(L_add_b),
	.memIn(memIn),	
	.memReadAddr(memReadAddr), 
	.memWriteAddr(memWriteAddr), 
	.memOut(memOut), 
	.memWriteEn(memWriteEn), 
	.done(done)
	);

endmodule
