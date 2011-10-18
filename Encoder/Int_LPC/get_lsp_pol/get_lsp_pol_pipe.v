`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    10:49:33 02/08/2011
// Module Name:    get_lsp_pol_top 
// Project Name:   ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description: 	 This module instantiates the get_lsp_pol module and math functions
//							necessary to test the get_lsp_pol module
//
// Dependencies:   get_lsp_pol.v
//						 L_sub.v
//						 L_mac.v
//						 L_mult.v
//						 mult.v
//                 L_shl.v
//						 norm_l.v
//						 L_shr.v
//						 L_negate.v
//						 L_abs.v
//						 L_add.v
//						 add.v
//						 sub.v
//						 L_msu.v
//						 Scratch_Memory_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.01 - Updated to support memory addr inputs and 12 bit memory address wires
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module get_lsp_pol_pipe(clock,reset,start,mem_Mux4Sel,mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,
				test_write_addr,test_read_addr,test_write,test_write_en,
				done,scratch_mem_in,F_OPT,get_lsp_pol_addr1);

	input clock,reset,start;
	input mem_Mux4Sel;
	input mem_Mux1Sel;
	input mem_Mux2Sel;
	input mem_Mux3Sel;
	input [11:0] get_lsp_pol_addr1;
	input [11:0] test_write_addr;
	input [11:0] test_read_addr;
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
	wire [11:0] scratch_mem_read_addr;
	wire [11:0] scratch_mem_write_addr;
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
		.get_lsp_pol_addr1(get_lsp_pol_addr1),
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
	
	
	reg [11:0] mem_Mux4Out;
	reg [11:0] mem_Mux1Out;
	reg [31:0] mem_Mux2Out;
	reg mem_Mux3Out;
	
	Scratch_Memory_Controller testMem(
												 .addra(mem_Mux1Out),
												 .dina(mem_Mux2Out),
												 .wea(mem_Mux3Out),
												 .clk(clock),
												 .addrb(mem_Mux4Out),
												 .doutb(scratch_mem_in)
	);
	

												 
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
	
endmodule
