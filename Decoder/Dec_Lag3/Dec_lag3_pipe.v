`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:02:08 11/22/2011 
// Design Name: 
// Module Name:    Dec_lag3_pipe 
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
module Dec_lag3_pipe(clk, start, done, reset, index_addr, i_subfr, memOutTest,
   memReadAddrTest, memWriteAddrTest, memWriteEnTest, scratch_mem_in, muxSelect );

	input clk, start, reset;
	output done;
	
	input muxSelect;
	input [11:0] memReadAddrTest, memWriteAddrTest;
	input memWriteEnTest;
	input [31:0] memOutTest;
	output [31:0] scratch_mem_in;
	
	input [15:0] index_addr;
	input [15:0] i_subfr;
	
	wire [15:0] add_a, add_b, sub_a, sub_b, mult_a, mult_b;
	wire [15:0] add_in, sub_in, mult_in;
	
	wire [31:0] scratch_mem_out;
	wire [11:0] scratch_mem_read_addr, scratch_mem_write_addr;
	wire scratch_mem_write_en;
	
	reg [31:0] mux_scratch_mem_out;
	reg [11:0] mux_scratch_mem_read_addr, mux_scratch_mem_write_addr;
	reg mux_scratch_mem_write_en;
	
	add Dec_lag3_add(
	.a(add_a),
	.b(add_b),
	.overflow(),
	.sum(add_in));
	
	sub Dec_lag3_sub(
	.a(sub_a),
	.b(sub_b),
	.overflow(),
	.diff(sub_in));
	
	mult Dec_lag3_mult(
	.a(mult_a),
	.b(mult_b),
	.multRsel(0),
	.overflow(),
	.product(mult_in));
	
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
	
	Scratch_Memory_Controller testMem(
	.addra(mux_scratch_mem_write_addr),
	.dina(mux_scratch_mem_out),
	.wea(mux_scratch_mem_write_en),
   .clk(clk),
   .addrb(mux_scratch_mem_read_addr),
   .doutb(scratch_mem_in)
   );
	
	Dec_lag3 i_fsm( 
	.clk(clk), 
	.start(start), 
	.reset(reset), 
	.done(done), 
	.scratch_mem_read_addr(scratch_mem_read_addr), 
	.scratch_mem_in(scratch_mem_in),
	.scratch_mem_write_en(scratch_mem_write_en), 
	.scratch_mem_write_addr(scratch_mem_write_addr), 
	.scratch_mem_out(scratch_mem_out), 
	.sub_a(sub_a), 
	.sub_b(sub_b), 
	.sub_in(sub_in), 
	.add_a(add_a), 
	.add_b(add_b), 
	.add_in(add_in), 
	.mult_a(mult_a), 
	.mult_b(mult_b), 
	.mult_in(mult_in),
	.index_addr(index_addr), 
	.i_subfr(i_subfr) );

endmodule
