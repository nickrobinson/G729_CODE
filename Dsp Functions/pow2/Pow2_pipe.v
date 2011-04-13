`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    17:12:48 03/28/2011 
// Module Name:    Pow2_pipe 
// Project Name:   ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description: 	 This module instantiates the Pow2 module, constant memory core, and
//						  all math modules neccessary for testing the Pow2 module.
//
// Dependencies:   Pow2.v
//						 L_shr.v
//						 sub.v
//						 L_msu.v
//						 L_mult.v
//						 add.v
//						 Constant_Memory_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Pow2_pipe(clock,reset,start,done,exponent,fraction,result
    );

	input clock,reset,start;
	input [15:0] exponent,fraction;
	
	output done;
	output [31:0] result;

	wire L_mult_overflow,L_shr_overflow,sub_overflow,L_msu_overflow,add_overflow;
	
	wire [11:0] constant_mem_read_addr;
	
	wire [15:0] L_mult_outa,L_mult_outb,L_shr_outb,sub_outa,sub_outb,sub_in,L_msu_outa,L_msu_outb,add_outa,add_outb,add_in;
	
	wire [31:0] L_mult_in,L_shr_outa,L_shr_in,L_msu_outc,L_msu_in,constant_mem_in;

	Pow2 i_Pow2_1(
				.clock(clock),.reset(reset),.start(start),.done(done),
				.exponent(exponent),.fraction(fraction),.result(result),
				.L_mult_outa(L_mult_outa),.L_mult_outb(L_mult_outb),.L_mult_overflow(L_mult_overflow),.L_mult_in(L_mult_in),
				.L_shr_outa(L_shr_outa),.L_shr_outb(L_shr_outb),.L_shr_overflow(L_shr_overflow),.L_shr_in(L_shr_in),
				.sub_outa(sub_outa),.sub_outb(sub_outb),.sub_overflow(sub_overflow),.sub_in(sub_in),
				.L_msu_outa(L_msu_outa),.L_msu_outb(L_msu_outb),.L_msu_outc(L_msu_outc),.L_msu_overflow(L_msu_overflow),.L_msu_in(L_msu_in),
				.constant_mem_read_addr(constant_mem_read_addr),.constant_mem_in(constant_mem_in),
				.add_outa(add_outa),.add_outb(add_outb),.add_overflow(add_overflow),.add_in(add_in)
    );
	 
	L_shr i_L_shr_1(.var1(L_shr_outa),.numShift(L_shr_outb),.overflow(L_shr_overflow),.out(L_shr_in));

	sub i_sub_1(.a(sub_outa),.b(sub_outb),.overflow(sub_overflow),.diff(sub_in));

	L_msu i_L_msu_1(.a(L_msu_outa),.b(L_msu_outb),.c(L_msu_outc),.overflow(L_msu_overflow),.out(L_msu_in));
	
	L_mult i_L_mult_1(.a(L_mult_outa),.b(L_mult_outb),.overflow(L_mult_overflow),.product(L_mult_in));
	
	add i_add_1(.a(add_outa),.b(add_outb),.overflow(add_overflow),.sum(add_in));

	Constant_Memory_Controller test_constant_mem(
												.addra(constant_mem_read_addr),
												.dina('d0),
												.wea(1'd0),
												.clock(clock),
												.douta(constant_mem_in)
	);
endmodule
