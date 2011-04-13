`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    22:47:41 03/31/2011 
// Module Name:    Gbk_presel_pipe 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description: 	 This module instantiates the Gbk_presel module, memory cores, and
//							math modules necessary to test the Gbk_presel module.
//
// Dependencies: 	 Gbk_presel.v
//						 L_mult.v
//						 mult.v
//						 L_shl.v
//						 L_shr.v
//						 add.v
//						 sub.v
//						 L_sub.v
//						 L_add.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Gbk_presel_pipe(clock,reset,start,done,scratch_mem_in,mem_Mux1Sel,mem_Mux2Sel,
					mem_Mux3Sel,mem_Mux4Sel,test_write_addr,test_read_addr,test_write,test_write_en,
					gcode0,cand1,cand2
    );

	input clock,reset,start;
	input mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,mem_Mux4Sel;
	input [11:0] test_write_addr,test_read_addr;
	input [15:0] gcode0;
	input [31:0] test_write;
	input test_write_en;
	
	output done;
	output [31:0] scratch_mem_in;
	output [15:0] cand1,cand2;

	wire [11:0] scratch_mem_write_addr,scratch_mem_read_addr;
	wire [31:0] scratch_mem_out;
	wire scratch_mem_write_en;
	
	reg [11:0] mem_Mux1Out,mem_Mux4Out;
	reg [31:0] mem_Mux2Out;
	reg mem_Mux3Out;

	wire [11:0] constant_mem_read_addr;
	wire [31:0] constant_mem_in;
	
	wire L_shl_done;
	wire L_mult_overflow,mult_overflow,L_add_overflow,sub_overflow,add_overflow;
	wire [15:0] mult_in,sub_in,add_in;
	wire [31:0] L_shr_in,L_sub_in,L_shl_in,L_mult_in,L_add_in;
	
	wire L_shl_start;
	wire [15:0] L_shr_outb,L_shl_outb,sub_outa,sub_outb,add_outa,add_outb;
	wire [31:0] L_shr_outa,L_sub_outa,L_sub_outb,L_shl_outa,L_add_outa,L_add_outb;
	
	wire [15:0] mult_outa,mult_outb,L_mult_outa,L_mult_outb;

	Gbk_presel i_Gbk_presel(
					.clock(clock),.reset(reset),.start(start),.done(done),
					.cand1(cand1),.cand2(cand2),.gcode0(gcode0),
					.constant_mem_read_addr(constant_mem_read_addr),.constant_mem_in(constant_mem_in),
					.scratch_mem_read_addr(scratch_mem_read_addr),.scratch_mem_in(scratch_mem_in),
						.scratch_mem_write_addr(scratch_mem_write_addr),.scratch_mem_write_en(scratch_mem_write_en),
						.scratch_mem_out(scratch_mem_out),
					.L_mult_outa(L_mult_outa),.L_mult_outb(L_mult_outb),.L_mult_in(L_mult_in),.L_mult_overflow(L_mult_overflow),
					.L_shr_outa(L_shr_outa),.L_shr_outb(L_shr_outb),.L_shr_overflow(L_shr_overflow),.L_shr_in(L_shr_in),
					.L_add_outa(L_add_outa),.L_add_outb(L_add_outb),.L_add_in(L_add_in),.L_add_overflow(L_add_overflow),
					.L_shl_outa(L_shl_outa),.L_shl_outb(L_shl_outb),.L_shl_start(L_shl_start),.L_shl_done(L_shl_done),
						.L_shl_in(L_shl_in),.L_shl_overflow(L_shl_overflow),
					.L_sub_outa(L_sub_outa),.L_sub_outb(L_sub_outb),.L_sub_in(L_sub_in),.L_sub_overflow(L_sub_overflow),
					.mult_outa(mult_outa),.mult_outb(mult_outb),.mult_in(mult_in),.mult_overflow(mult_overflow),
					.add_outa(add_outa),.add_outb(add_outb),.add_in(add_in),.add_overflow(add_overflow),
					.sub_outa(sub_outa),.sub_outb(sub_outb),.sub_in(sub_in),.sub_overflow(sub_overflow)
    );
	 
	L_mult i_L_mult_1(.a(L_mult_outa),.b(L_mult_outb),.overflow(L_mult_overflow),.product(L_mult_in));
	
	mult i_mult_1(.a(mult_outa),.b(mult_outb),.overflow(mult_overflow),.product(mult_in));
	
	L_shl i_L_shl_1(.clk(clock),.reset(reset),.ready(L_shl_start),.var1(L_shl_outa),.numShift(L_shl_outb),
							.done(L_shl_done),.out(L_shl_in),.overflow(L_shl_overflow));
	
	L_shr i_L_shr_1(.var1(L_shr_outa),.numShift(L_shr_outb),.out(L_shr_in),.overflow(L_shr_overflow));
	
	add i_add_1(.a(add_outa),.b(add_outb),.overflow(add_overflow),.sum(add_in));
	
	sub i_sub_1(.a(sub_outa),.b(sub_outb),.overflow(sub_overflow),.diff(sub_in));
	
	L_sub i_L_sub_1(.a(L_sub_outa),.b(L_sub_outb),.overflow(L_sub_overflow),.diff(L_sub_in));
	
	L_add i_L_add_1(.a(L_add_outa),.b(L_add_outb),.overflow(L_sub_overflow),.sum(L_add_in));
	
	//mem write address mux
	always @(*)
	begin
		case	(mem_Mux1Sel)	
			'd0 :	mem_Mux1Out = scratch_mem_write_addr;
			'd1:	mem_Mux1Out = test_write_addr;
		endcase
	end
	
	//mem input mux
	always @(*)
	begin
		case	(mem_Mux2Sel)	
			'd0 :	mem_Mux2Out = scratch_mem_out;
			'd1:	mem_Mux2Out = test_write;
		endcase
	end
	
	//mem write enable mux
	always @(*)
	begin
		case	(mem_Mux3Sel)	
			'd0 :	mem_Mux3Out = scratch_mem_write_en;
			'd1:	mem_Mux3Out = test_write_en;
		endcase
	end
	
	//mem read address mux
	always @(*)
	begin
		case	(mem_Mux4Sel)	
			'd0 :	mem_Mux4Out = scratch_mem_read_addr;
			'd1:	mem_Mux4Out = test_read_addr;
		endcase
	end
	
	Scratch_Memory_Controller test_scratch_mem(
												 .addra(mem_Mux1Out),
												 .dina(mem_Mux2Out),
												 .wea(mem_Mux3Out),
												 .clk(clock),
												 .addrb(mem_Mux4Out),
												 .doutb(scratch_mem_in)
	);
	
	Constant_Memory_Controller test_constant_mem(
												.addra(constant_mem_read_addr),
												.dina('d0),
												.wea(1'd0),
												.clock(clock),
												.douta(constant_mem_in)
	);
endmodule
