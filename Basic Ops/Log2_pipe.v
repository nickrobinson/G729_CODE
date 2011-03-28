`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    14:28:09 03/27/2011 
// Module Name:    Log2_pipe 
// Project Name:   ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description:    This module instantiates the Log2 and math modules necessary to
//							test the Log2 module.
//
// Dependencies: 	 Log2.v
//						 L_shl.v
//						 L_shr.v
//						 sub.v
//						 L_msu.v
//						 norm_l.v
//						 add.v
//						 Constant_Memory_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Log2_pipe(clock,start,reset,done,in,exponent,fraction
    );

input clock,start,reset;

output done;

input [31:0] in;

output [15:0] exponent,fraction;

wire L_shl_start,L_shl_done,L_shl_overflow,L_shr_overflow,sub_overflow,L_msu_overflow,norm_l_start,norm_l_done;

wire [11:0] constant_mem_read_addr;

wire [15:0] L_shl_outb,L_shr_outb,sub_outa,sub_outb,sub_in,L_msu_outa,L_msu_outb,norm_l_in,add_outa,add_outb,add_in;

wire [31:0] L_shl_outa,L_shl_in,L_shr_outa,L_shr_in,L_msu_outc,L_msu_in,norm_l_out,constant_mem_in;



Log2 i_Log2_1(
		.clock(clock),
		.reset(reset),
		.start(start),
		.done(done),
		.L_x(in),
		.exponent(exponent),
		.fraction(fraction),
		.L_shl_outa(L_shl_outa),.L_shl_outb(L_shl_outb),.L_shl_start(L_shl_start),.L_shl_done(L_shl_done),.L_shl_overflow(L_shl_overflow),
			.L_shl_in(L_shl_in),
		.L_shr_outa(L_shr_outa),.L_shr_outb(L_shr_outb),.L_shr_in(L_shr_in),.L_shr_overflow(L_shr_overflow),
		.sub_outa(sub_outa),.sub_outb(sub_outb),.sub_in(sub_in),.sub_overflow(sub_overflow),
		.L_msu_outa(L_msu_outa),.L_msu_outb(L_msu_outb),.L_msu_outc(L_msu_outc),.L_msu_in(L_msu_in),.L_msu_overflow(L_msu_overflow),
		.norm_l_out(norm_l_out),.norm_l_start(norm_l_start),.norm_l_done(norm_l_done),.norm_l_in(norm_l_in),
		.constant_mem_read_addr(constant_mem_read_addr),.constant_mem_in(constant_mem_in),
		.add_outa(add_outa),.add_outb(add_outb),.add_in(add_in),.add_overflow(add_overflow)
    );

L_shl i_L_shl_1(.clk(clock),.reset(reset),.ready(L_shl_start),.overflow(L_shl_overflow),.var1(L_shl_outa),.numShift(L_shl_outb),
						.done(L_shl_done),.out(L_shl_in));

L_shr i_L_shr_1(.var1(L_shr_outa),.numShift(L_shr_outb),.overflow(L_shr_overflow),.out(L_shr_in));

sub i_sub_1(.a(sub_outa),.b(sub_outb),.overflow(sub_overflow),.diff(sub_in));

L_msu i_L_msu_1(.a(L_msu_outa),.b(L_msu_outb),.c(L_msu_outc),.overflow(L_msu_overflow),.out(L_msu_in));

norm_l i_norm_l_1(.var1(norm_l_out),.norm(norm_l_in),.clk(clock),.ready(norm_l_start),.reset(reset),.done(norm_l_done));

add i_add_1(.a(add_outa),.b(add_outb),.overflow(add_overflow),.sum(add_in));

Constant_Memory_Controller test_constant_mem(
												.addra(constant_mem_read_addr),
												.dina('d0),
												.wea(1'd0),
												.clock(clock),
												.douta(constant_mem_in)
	);
	
endmodule
