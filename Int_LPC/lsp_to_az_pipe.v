`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:08:57 02/14/2011 
// Design Name: 
// Module Name:    lsp_to_az_pipe 
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
module lsp_to_az_pipe(
					start,
					reset,
					test_write_addr,
					test_write_en,
					test_write,
					test_read_addr,
					mem_Mux1Sel,
					mem_Mux2Sel,
					mem_Mux3Sel,
					mem_Mux4Sel,
					done,
					scratch_mem_in,
					clock
			);
	
	`include "paramList.v"	
	input start;
	input reset;
	input clock;
	input [10:0] test_write_addr;
	input test_write_en;
	input [31:0] test_write;
	input [10:0] test_read_addr;
	input mem_Mux1Sel;
	input mem_Mux2Sel;
	input mem_Mux3Sel;
	input mem_Mux4Sel;
	output done;
	output [31:0] scratch_mem_in;

	wire norm_L_done,L_shl_done;
	wire L_mult_overflow,mult_overflow,L_mac_overflow,L_add_overflow,sub_overflow,add_overflow,L_msu_overflow;
	wire [15:0] norm_L_in,mult_in,sub_in,add_in;
	wire [31:0] abs_in,negate_in,L_shr_in,L_sub_in,L_shl_in,L_mac_in,L_mult_in,L_add_in,L_msu_in;
	
	wire norm_L_start,L_shl_start;
	wire [15:0] L_shr_outb,L_shl_outb,sub_outa,sub_outb,add_outa,add_outb;
	wire [31:0] abs_out,negate_out,L_shr_outa,L_sub_outa,L_sub_outb,norm_L_out,L_shl_outa,L_add_outa,L_add_outb;
	
	wire [15:0] mult_outa,mult_outb,L_mult_outa,L_mult_outb,L_mac_outa,L_mac_outb,L_msu_outa,L_msu_outb;
	wire [31:0] L_mac_outc,L_msu_outc;
	
	wire [10:0] scratch_mem_read_addr,scratch_mem_write_addr;
	
	wire [31:0] scratch_mem_out;
	
	reg [10:0] mem_Mux1Out;
	reg [31:0] mem_Mux2Out;
	reg mem_Mux3Out;
	reg [10:0] mem_Mux4Out;

LSP_to_Az lsp_to_az(
	.clock(clock),
	.reset(reset),
	.start(start),
	.done(done),
	.abs_in(abs_in),.abs_out(abs_out),
	.negate_out(negate_out),.negate_in(negate_in),
	.L_shr_outa(L_shr_outa),.L_shr_outb(L_shr_outb),.L_shr_in(L_shr_in),
	.L_sub_outa(L_sub_outa),.L_sub_outb(L_sub_outb),.L_sub_in(L_sub_in),
	.norm_L_out(norm_L_out),.norm_L_in(norm_L_in),.norm_L_start(norm_L_start),.norm_L_done(norm_L_done),
	.L_shl_outa(L_shl_outa),.L_shl_outb(L_shl_outb),.L_shl_in(L_shl_in),.L_shl_start(L_shl_start),.L_shl_done(L_shl_done),
	.L_mult_outa(L_mult_outa),.L_mult_outb(L_mult_outb),.L_mult_in(L_mult_in),.L_mult_overflow(L_mult_overflow),
	.L_mac_outa(L_mac_outa),.L_mac_outb(L_mac_outb),.L_mac_outc(L_mac_outc),.L_mac_in(L_mac_in),.L_mac_overflow(L_mac_overflow),
	.mult_outa(mult_outa),.mult_outb(mult_outb),.mult_in(mult_in),.mult_overflow(mult_overflow),
	.L_add_outa(L_add_outa),.L_add_outb(L_add_outb),.L_add_overflow(L_add_overflow),.L_add_in(L_add_in),
	.sub_outa(sub_outa),.sub_outb(sub_outb),.sub_in(sub_in),.sub_overflow(sub_overflow),
	.scratch_mem_read_addr(scratch_mem_read_addr),
	.scratch_mem_write_addr(scratch_mem_write_addr),.scratch_mem_out(scratch_mem_out),
	.scratch_mem_write_en(scratch_mem_write_en),.scratch_mem_in(scratch_mem_in),
	.add_outa(add_outa),.add_outb(add_outb),.add_overflow(add_overflow),.add_in(add_in),
	.L_msu_outa(L_msu_outa),.L_msu_outb(L_msu_outb),.L_msu_outc(L_msu_outc),.L_msu_overflow(L_msu_overflow),.L_msu_in(L_msu_in));
	
	L_sub i_L_sub_1(.a(L_sub_outa),.b(L_sub_outb),.overflow(L_sub_overflow),.diff(L_sub_in));

	L_mac i_L_mac_1(.a(L_mac_outa),.b(L_mac_outb),.c(L_mac_outc),.overflow(L_mac_overflow),.out(L_mac_in));
	
	L_mult i_L_mult_1(.a(L_mult_outa),.b(L_mult_outb),.overflow(L_mult_overflow),.product(L_mult_in));
	
	mult i_mult_1(.a(mult_outa),.b(mult_outb),.overflow(mult_overflow),.product(mult_in));
	
	L_shl i_L_shl_1(.clk(clock),.reset(reset),.ready(L_shl_start),.var1(L_shl_outa),.numShift(L_shl_outb),
							.done(L_shl_done),.out(L_shl_in));
	
	norm_l i_norm_l_1(.var1(norm_L_out),.norm(norm_L_in),.clk(clock),.ready(norm_L_start),.reset(reset),.done(norm_L_done));
	
	L_shr i_L_shr_1(.var1(L_shr_outa),.numShift(L_shr_outb),.out(L_shr_in));
	
	L_negate i_L_negate_1(.var_in(negate_out),.var_out(negate_in));
	
	L_abs i_L_abs_1(.var_in(abs_out),.var_out(abs_in));
	
	L_add i_L_add_1(.a(L_add_outa),.b(L_add_outb),.overflow(L_add_overflow),.sum(L_add_in));
	
	add i_add_1(.a(add_outa),.b(add_outb),.overflow(add_overflow),.sum(add_in));
	
	sub i_sub_1(.a(sub_outa),.b(sub_outb),.overflow(sub_overflow),.diff(sub_in));
	
	L_msu i_L_msu_1(.a(L_msu_outa),.b(L_msu_outb),.c(L_msu_outc),.overflow(L_msu_overflow),.out(L_msu_in));
	
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
	
	Scratch_Memory_Controller testMem(
												 .addra(mem_Mux1Out),
												 .dina(mem_Mux2Out),
												 .wea(mem_Mux3Out),
												 .clk(clock),
												 .addrb(mem_Mux4Out),
												 .doutb(scratch_mem_in)
	);
endmodule
