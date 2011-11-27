`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	   Mississippi State University
// Engineer: 	   David Mudd
// 
// Create Date:    23:00:03 11/23/2011 
// Design Name: 
// Module Name:    Gain_update_erasure_pipe 
// Project Name:   ITU G.729 Decoder
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
module Gain_update_erasure_pipe(clk, start, reset, done, scratch_mem_in,
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
	
	wire [15:0] add_in, add_a, add_b;
	wire [15:0] sub_in, sub_a, sub_b;
	wire [31:0] L_add_in, L_add_a, L_add_b;
	wire [31:0] L_shr_in, L_shr_a;
	wire [15:0] L_shr_b;
	
	wire scratch_mem_write_en;
	wire [11:0] scratch_mem_write_addr, scratch_mem_read_addr;
	wire [31:0] scratch_mem_out;
	
	Gain_update_erasure i_Gain_update_erasure(.clk(clk), .start(start), .reset(reset), .done(done),
												.add_in(add_in), .add_a(add_a), .add_b(add_b),
												.sub_in(sub_in), .sub_a(sub_a), .sub_b(sub_b),
												.L_add_in(L_add_in), .L_add_a(L_add_a), .L_add_b(L_add_b),
												.L_shr_in(L_shr_in), .L_shr_a(L_shr_a), .L_shr_b(L_shr_b),
												.scratch_mem_in(scratch_mem_in), .scratch_mem_write_en(scratch_mem_write_en),
												.scratch_mem_read_addr(scratch_mem_read_addr), .scratch_mem_write_addr(scratch_mem_write_addr),
												.scratch_mem_out(scratch_mem_out));
												
	add i_add(.a(add_a), .b(add_b), .overflow(), .sum(add_in));
	sub i_sub(.a(sub_a), .b(sub_b), .overflow(), .diff(sub_in));
	L_add i_L_add(.a(L_add_a), .b(L_add_b), .overflow(), .sum(L_add_in));
	L_shr i_L_shr(.var1(L_shr_a), .numShift(L_shr_b), .overflow(), .out(L_shr_in));
	
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
								
endmodule
