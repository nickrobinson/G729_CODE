`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:49:33 02/08/2011 
// Design Name: 
// Module Name:    get_lsp_pol_top 
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
module get_lsp_pol_test_top(clock,reset,start,mem_Mux4Sel,mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,
				test_write_addr,test_read_addr,test_write,test_write_en,
				done,scratch_mem_in,F_OPT);

	input clock,reset,start;
	input mem_Mux4Sel;
	input mem_Mux1Sel;
	input mem_Mux2Sel;
	input mem_Mux3Sel;
	input [10:0] test_write_addr;
	input [10:0] test_read_addr;
	input [31:0] test_write;
	input test_write_en;
	input F_OPT;

	wire [31:0] abs_in;
	wire [31:0] negate_in;
	wire [31:0] L_shr_in;
	wire [31:0] L_sub_in;
	wire [15:0] norm_L_in;
	wire norm_L_done;
	wire [31:0] L_shl_in;
	wire L_shl_done;
	wire [31:0] L_mult_in;
	wire L_mult_overflow;
	wire [31:0] L_mac_in;
	wire L_mac_overflow;
	wire [15:0] mult_in;
	wire mult_overflow;
	wire L_add_overflow;
	wire [31:0] L_add_in;
	wire [15:0] sub_in;
	wire sub_overflow;
	wire add_overflow;
	wire [15:0] add_in;
	wire L_msu_overflow;
	wire [31:0] L_msu_in;
	wire [31:0] abs_out;
	wire [31:0] negate_out;
	wire [31:0] L_shr_outa;
	wire [15:0] L_shr_outb;
	wire [31:0] L_sub_outa;
	wire [31:0] L_sub_outb;
	wire [31:0] norm_L_out;
	wire norm_L_start;
	wire [31:0] L_shl_outa;
	wire [15:0] L_shl_outb;
	wire L_shl_start;
	wire [15:0] L_mult_outa;
	wire [15:0] L_mult_outb;
	wire [15:0] L_mac_outa;
	wire [15:0] L_mac_outb;
	wire [31:0] L_mac_outc;
	wire [15:0] mult_outa;
	wire [15:0] mult_outb;
	wire [31:0] L_add_outa;
	wire [31:0] L_add_outb;
	wire [15:0] sub_outa;
	wire [15:0] sub_outb;
	wire [10:0] scratch_mem_read_addr;
	wire [10:0] scratch_mem_write_addr;
	wire [31:0] scratch_mem_out;
	wire scratch_mem_write_en;
	wire [15:0] add_outa;
	wire [15:0] add_outb;
	wire [15:0] L_msu_outa;
	wire [15:0] L_msu_outb;
	wire [31:0] L_msu_outc;
	
	output done;
	output [31:0] scratch_mem_in;

	get_lsp_pol uut (
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.F_OPT(F_OPT),
		.done(done), 
		.abs_in(abs_in), 
		.abs_out(abs_out), 
		.negate_out(negate_out), 
		.negate_in(negate_in), 
		.L_shr_outa(L_shr_outa), 
		.L_shr_outb(L_shr_outb), 
		.L_shr_in(L_shr_in), 
		.L_sub_outa(L_sub_outa), 
		.L_sub_outb(L_sub_outb), 
		.L_sub_in(L_sub_in), 
		.norm_L_out(norm_L_out), 
		.norm_L_in(norm_L_in), 
		.norm_L_start(norm_L_start), 
		.norm_L_done(norm_L_done), 
		.L_shl_outa(L_shl_outa), 
		.L_shl_outb(L_shl_outb), 
		.L_shl_in(L_shl_in), 
		.L_shl_start(L_shl_start), 
		.L_shl_done(L_shl_done), 
		.L_mult_outa(L_mult_outa), 
		.L_mult_outb(L_mult_outb), 
		.L_mult_in(L_mult_in), 
		.L_mult_overflow(L_mult_overflow), 
		.L_mac_outa(L_mac_outa), 
		.L_mac_outb(L_mac_outb), 
		.L_mac_outc(L_mac_outc), 
		.L_mac_in(L_mac_in), 
		.L_mac_overflow(L_mac_overflow), 
		.mult_outa(mult_outa), 
		.mult_outb(mult_outb), 
		.mult_in(mult_in), 
		.mult_overflow(mult_overflow), 
		.L_add_outa(L_add_outa), 
		.L_add_outb(L_add_outb), 
		.L_add_overflow(L_add_overflow), 
		.L_add_in(L_add_in), 
		.sub_outa(sub_outa), 
		.sub_outb(sub_outb), 
		.sub_in(sub_in), 
		.sub_overflow(sub_overflow), 
		.scratch_mem_read_addr(scratch_mem_read_addr), 
		.scratch_mem_write_addr(scratch_mem_write_addr), 
		.scratch_mem_out(scratch_mem_out), 
		.scratch_mem_write_en(scratch_mem_write_en), 
		.scratch_mem_in(scratch_mem_in), 
		.add_outa(add_outa), 
		.add_outb(add_outb), 
		.add_overflow(add_overflow), 
		.add_in(add_in), 
		.L_msu_outa(L_msu_outa), 
		.L_msu_outb(L_msu_outb), 
		.L_msu_outc(L_msu_outc), 
		.L_msu_overflow(L_msu_overflow), 
		.L_msu_in(L_msu_in)
	);
	
	get_lsp_pol_test_pipe get_lsp_pol_test_pipe_1(
		.L_sub_outa(L_sub_outa),.L_sub_outb(L_sub_outb),.L_sub_overflow(L_sub_overflow),.L_sub_in(L_sub_in),
		.L_mac_outa(L_mac_outa),.L_mac_outb(L_mac_outb),.L_mac_outc(L_mac_outc),.L_mac_overflow(L_mac_overflow),.L_mac_in(L_mac_in),
		.L_mult_outa(L_mult_outa),.L_mult_outb(L_mult_outb),.L_mult_overflow(L_mult_overflow),.L_mult_in(L_mult_in),
		.mult_outa(mult_outa),.mult_outb(mult_outb),.mult_overflow(mult_overflow),.mult_in(mult_in),
		.clock(clock),
		.reset(reset),
		.L_shl_start(L_shl_start),.L_shl_outa(L_shl_outa),.L_shl_outb(L_shl_outb),.L_shl_done(L_shl_done),.L_shl_in(L_shl_in),
		.norm_L_out(norm_L_out),.norm_L_in(norm_L_in),.norm_L_start(norm_L_start),.norm_L_done(norm_L_done),
		.L_shr_outa(L_shr_outa),.L_shr_outb(L_shr_outb),.L_shr_in(L_shr_in),
		.negate_out(negate_out),.negate_in(negate_in),
		.abs_out(abs_out),.abs_in(abs_in),
		.L_add_outa(L_add_outa),.L_add_outb(L_add_outb),.L_add_overflow(L_add_overflow),.L_add_in(L_add_in),
		.add_outa(add_outa),.add_outb(add_outb),.add_overflow(add_overflow),.add_in(add_in),
		.sub_outa(sub_outa),.sub_outb(sub_outb),.sub_overflow(sub_overflow),.sub_in(sub_in),
		.L_msu_outa(L_msu_outa),.L_msu_outb(L_msu_outb),.L_msu_outc(L_msu_outc),.L_msu_overflow(L_msu_overflow),.L_msu_in(L_msu_in),
		.scratch_mem_write_addr(scratch_mem_write_addr),.scratch_mem_read_addr(scratch_mem_read_addr),
		.scratch_mem_out(scratch_mem_out),.scratch_mem_in(scratch_mem_in),.scratch_mem_write_en(scratch_mem_write_en),
		.test_write_addr(test_write_addr),.test_read_addr(test_read_addr),.test_write(test_write),.test_write_en(test_write_en),
		.mem_Mux1Sel(mem_Mux1Sel),.mem_Mux2Sel(mem_Mux2Sel),.mem_Mux3Sel(mem_Mux3Sel),.mem_Mux4Sel(mem_Mux4Sel)
	);
	
endmodule
