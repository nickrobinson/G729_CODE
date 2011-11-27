`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	   Mississippi State University
// Engineer: 	   David Mudd
// 
// Create Date:    01:47:00 11/25/2011 
// Design Name: 
// Module Name:    Dec_gain_pipe 
// Project Name: 	ITU G.729 Decoder
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
module Dec_gain_pipe(clk, start, reset, done, scratch_mem_in,
					 mem_Mux1Sel, mem_Mux2Sel, mem_Mux3Sel, mem_Mux4Sel,
					 test_write_addr, test_read_addr, test_write, test_write_en);
					 
	input clk, start, reset;
	
	output done;
	
	output [31:0] scratch_mem_in;
	
	input mem_Mux1Sel, mem_Mux2Sel, mem_Mux3Sel, mem_Mux4Sel;
	input [11:0] test_write_addr, test_read_addr;
	input [31:0] test_write;
	input test_write_en;
	reg [11:0] mem_Mux1Out, mem_Mux4Out;
	reg [31:0] mem_Mux2Out;
	reg mem_Mux3Out;
	
	wire scratch_mem_write_en;
	wire [11:0] scratch_mem_write_addr, scratch_mem_read_addr;
	wire [31:0] scratch_mem_out;
	
	wire [31:0] constant_mem_in;
	wire [11:0] constant_mem_read_addr;
	
	wire [15:0] add_in;
	wire add_overflow;
	wire [15:0] add_a, add_b;
	
	wire [15:0] sub_in;
	wire sub_overflow;
	wire [15:0] sub_a, sub_b;
	
	wire [15:0] mult_in;
	wire mult_overflow;
	wire [15:0] mult_a, mult_b;
	
	wire [31:0] L_add_in;
	wire [31:0] L_add_a, L_add_b;
	
	wire [31:0] L_shr_in;
	wire L_shr_overflow;
	wire [31:0] L_shr_a;
	wire [15:0] L_shr_b;
	
	wire [31:0] L_shl_in;
	wire L_shl_done, L_shl_overflow;
	wire [31:0] L_shl_a;
	wire [15:0] L_shl_b;
	wire L_shl_start;
	
	wire [15:0] norm_l_in;
	wire norm_l_done;
	wire [31:0] norm_l_out;
	wire norm_l_start;
	
	wire [31:0] L_msu_in;
	wire L_msu_overflow;
	wire [31:0] L_msu_c;
	wire [15:0] L_msu_a, L_msu_b;
	
	wire [31:0] L_mac_in;
	wire L_mac_overflow;
	wire [31:0] L_mac_c;
	wire [15:0] L_mac_a, L_mac_b;
	
	wire [31:0] L_mult_in;
	wire L_mult_overflow;
	wire [15:0] L_mult_a, L_mult_b;
	
	wire [31:0] L_negate_in;
	wire [31:0] L_negate_out;
	
	wire[15:0] shr_in;
	wire [15:0] shr_a, shr_b;
	
	wire [15:0] gcode0, exp_gcode0;
	
	// Dec_gain Instantiation
	Dec_gain i_Dec_gain(
		.clk(clk), .start(start), .reset(reset), .done(done), .scratch_mem_in(scratch_mem_in),
		.scratch_mem_write_en(scratch_mem_write_en), .scratch_mem_read_addr(scratch_mem_read_addr),
		.scratch_mem_write_addr(scratch_mem_write_addr), .scratch_mem_out(scratch_mem_out),
		.constant_mem_in(constant_mem_in), .constant_mem_read_addr(constant_mem_read_addr),
		.add_in(add_in), .add_a(add_a), .add_b(add_b), .add_overflow(add_overflow), .sub_overflow(sub_overflow),
		.mult_overflow(mult_overflow), .L_shr_overflow(L_shr_overflow), .sub_in(sub_in), .sub_a(sub_a), .sub_b(sub_b),
		.mult_in(mult_in), .mult_a(mult_a), .mult_b(mult_b), .L_add_in(L_add_in), .L_add_a(L_add_a),
		.L_add_b(L_add_b), .L_shr_in(L_shr_in), .L_shr_a(L_shr_a), .L_shr_b(L_shr_b), .L_shl_in(L_shl_in),
		.L_shl_a(L_shl_a), .L_shl_b(L_shl_b), .L_shl_done(L_shl_done), .L_shl_overflow(L_shl_overflow), .L_shl_start(L_shl_start),
		.norm_l_in(norm_l_in), .norm_l_out(norm_l_out), .norm_l_done(norm_l_done), .norm_l_start(norm_l_start),
		.L_msu_in(L_msu_in), .L_msu_a(L_msu_a), .L_msu_b(L_msu_b), .L_msu_c(L_msu_c), .L_msu_overflow(L_msu_overflow),
		.L_mac_in(L_mac_in), .L_mac_a(L_mac_a), .L_mac_b(L_mac_b), .L_mac_c(L_mac_c), .L_mac_overflow(L_mac_overflow),
		.L_mult_in(L_mult_in), .L_mult_a(L_mult_a), .L_mult_b(L_mult_b), .L_mult_overflow(L_mult_overflow),
		.L_negate_in(L_negate_in), .L_negate_out(L_negate_out), .shr_in(shr_in), .shr_a(shr_a), .shr_b(shr_b)
	);
	
	// Basic Ops Instantiations
	add i_add(.a(add_a), .b(add_b), .overflow(add_overflow), .sum(add_in));
	sub i_sub(.a(sub_a), .b(sub_b), .overflow(sub_overflow), .diff(sub_in));
	mult i_mult(.a(mult_a), .b(mult_b), .multRsel(), .overflow(mult_overflow), .product(mult_in));
	L_add i_L_add(.a(L_add_a), .b(L_add_b), .overflow(), .sum(L_add_in));
	L_shr i_L_shr(.var1(L_shr_a), .numShift(L_shr_b), .overflow(L_shr_overflow), .out(L_shr_in));
	L_shl i_L_shl(.clk(clk), .reset(reset), .ready(L_shl_start), .overflow(L_shl_overflow), .var1(L_shl_a),
					.numShift(L_shl_b), .done(L_shl_done), .out(L_shl_in));
	norm_l i_norm_l(.var1(norm_l_out), .norm(norm_l_in), .clk(clk), .ready(norm_l_start),
					.reset(reset), .done(norm_l_done));
	L_msu i_L_msu(.a(L_msu_a), .b(L_msu_b), .c(L_msu_c), .overflow(L_msu_overflow), .out(L_msu_in));
	L_mac i_L_mac(.a(L_mac_a), .b(L_mac_b), .c(L_mac_c), .overflow(L_mac_overflow), .out(L_mac_in));
	L_mult i_L_mult(.a(L_mult_a), .b(L_mult_b), .overflow(L_mult_overflow), .product(L_mult_in));
	L_negate i_L_negate(.var_in(L_negate_out), .var_out(L_negate_in));
	shr i_shr(.var1(shr_a), .var2(shr_b), .overflow(), .result(shr_in));
	
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
												 .clk(clk),
												 .addrb(mem_Mux4Out),
												 .doutb(scratch_mem_in)
	);
	
	Constant_Memory_Controller constantMem(
												.addra(constant_mem_read_addr),
												.dina(32'd0),
												.wea(1'd0),
												.clock(clk),
												.douta(constant_mem_in)
	);

endmodule
