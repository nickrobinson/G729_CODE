`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:49:08 09/20/2011 
// Design Name: 
// Module Name:    de_acelp_pipe 
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
module de_acelp_pipe(clk, start, reset, done, scratch_mem_in,
							mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,mem_Mux4Sel,
							test_write_addr, test_read_addr, test_write, test_write_en);

	input clk, start, reset;
	
	output done;
	
	output [31:0] scratch_mem_in;
	
	input mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,mem_Mux4Sel;
	input [11:0] test_write_addr,test_read_addr;
	input [31:0] test_write;
	input test_write_en;
	reg [11:0] mem_Mux1Out,mem_Mux4Out;
	reg [31:0] mem_Mux2Out;
	reg mem_Mux3Out;

	wire [15:0] add_a, add_b;
	wire [15:0] shr_a, shr_b;
	wire [15:0] shl_a, shl_b;
	wire [15:0] add_in, shr_in, shl_in;
	//wire [15:0] shr_a, shr_b, shl_a, shl_b, add_a, add_b;
	
	wire scratch_mem_write_en;
	wire [11:0] scratch_mem_read_addr, scratch_mem_write_addr;
	wire [31:0] scratch_mem_out;
	
	//wire [15:0] sign, index;
	
	de_acelp i_de_acelp(
	.clk(clk), .start(start), .reset(reset), .done(done),
	/*.sign(sign), .index(index),*/ .add_in(add_in), .shr_in(shr_in),
	.shl_in(shl_in), .add_a(add_a), .add_b(add_b), .shr_a(shr_a),
	.shr_b(shr_b), .shl_a(shl_a), .shl_b(shl_b), .scratch_mem_write_en(scratch_mem_write_en),
	.scratch_mem_read_addr(scratch_mem_read_addr), .scratch_mem_write_addr(scratch_mem_write_addr),
	.scratch_mem_out(scratch_mem_out), .scratch_mem_in(scratch_mem_in));
	
	add i_add(.a(add_a), .b(add_b), .overflow(), .sum(add_in));
	shl i_shl(.var1(shl_a), .var2(shl_b), .overflow(), .result(shl_in));
	shr i_shr(.var1(shr_a), .var2(shl_b), .overflow(), .result(shr_in));
	
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
