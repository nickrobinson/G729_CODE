`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:01:10 10/31/2011 
// Design Name: 
// Module Name:    bits2int_pipe 
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
module bits2prm_ld8k_pipe( clk, reset, start, done, muxSelect,
		scratch_mem_in, memReadAddrTest, memWriteAddrTest, memOutTest, memWriteEnTest);

	//inputs
	input clk;
	input reset;
	input start;
	input muxSelect;
	input [11:0] memReadAddrTest, memWriteAddrTest;
	input memWriteEnTest;
	input [31:0] memOutTest;
	
	output [31:0] scratch_mem_in;
	output done;

	wire [15:0] add_a, add_b;
	wire [31:0] shl_a, shl_b;
	wire [15:0] add_in;
	wire [31:0] shl_in;
	
	wire scratch_mem_write_en;
	wire [31:0] scratch_mem_in, scratch_mem_out, const_mem_in;
	wire [11:0] scratch_mem_read_addr, scratch_mem_write_addr, const_mem_read_addr;
	
	reg [31:0] mux_scratch_mem_out;
	reg [11:0] mux_scratch_mem_read_addr, mux_scratch_mem_write_addr;
	reg mux_scratch_mem_write_en;

	add bits2prm_add(
	.a(add_a),
	.b(add_b),
	.overflow(),
	.sum(add_in));
	
	shl bits2prm_shl(
	.var1(shl_a),
	.var2(shl_b),
	.overflow(),
	.result(shl_in));
	
	always @(*)
	begin
		case	(muxSelect)	
			'd0: begin
				mux_scratch_mem_out = scratch_mem_out;
				mux_scratch_mem_read_addr = scratch_mem_read_addr;
				mux_scratch_mem_write_addr = scratch_mem_write_addr;
				mux_scratch_mem_write_en = scratch_mem_write_en;
				end
			'd1: begin
				mux_scratch_mem_out = memOutTest;
				mux_scratch_mem_read_addr = memReadAddrTest;
				mux_scratch_mem_write_addr = memWriteAddrTest;
				mux_scratch_mem_write_en = memWriteEnTest;
				end
		endcase
	end
	
	//Instantited Modules	
	Scratch_Memory_Controller testMem(
	.addra(mux_scratch_mem_write_addr),
	.dina(mux_scratch_mem_out),
	.wea(mux_scratch_mem_write_en),
   .clk(clk),
   .addrb(mux_scratch_mem_read_addr),
   .doutb(scratch_mem_in)
   );
	
	Const_Memory_Controller constMem(
	.addra(const_mem_read_addr),
	.dina(),
	.wea(0),
	.clock(clk),
	.douta(const_mem_in));
	
	bits2prm_ld8k i_fsm( 
		.clk(clk), 
		.start(start), 
		.reset(reset), 
		.done(done), 
		.add_a(add_a), 
		.add_b(add_b), 
		.add_in(add_in), 
		.shl_a(shl_a), 
		.shl_b(shl_b),
		.shl_in(shl_in), 
		.scratch_mem_read_addr(scratch_mem_read_addr), 
		.scratch_mem_in(scratch_mem_in), 
		.const_mem_read_addr(const_mem_read_addr), 
		.const_mem_in(const_mem_in),
		.scratch_mem_write_en(scratch_mem_write_en), 
		.scratch_mem_write_addr(scratch_mem_write_addr), 
		.scratch_mem_out(scratch_mem_out) );

endmodule
