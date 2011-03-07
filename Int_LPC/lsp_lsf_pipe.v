`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:14:07 02/23/2011 
// Design Name: 
// Module Name:    lsp_lsf_pipe 
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
module lsp_lsf_pipe(clock,reset,start,mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,mem_Mux4Sel,lsf_addr,test_write_addr,
							test_read_addr,test_write,test_write_en,done,scratch_mem_in
    );

	input clock,reset,start;
	input mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,mem_Mux4Sel;
	input [10:0] lsf_addr;
	input [10:0] test_write_addr,test_read_addr;
	input [31:0] test_write;
	input test_write_en;
	
	output done;
	output [31:0] scratch_mem_in;
	
	wire [10:0] scratch_mem_write_addr,scratch_mem_read_addr;
	wire [31:0] scratch_mem_out;
	wire scratch_mem_write_en;
	
	reg [10:0] mem_Mux1Out,mem_Mux4Out;
	reg [31:0] mem_Mux2Out;
	reg mem_Mux3Out;
	
	wire [11:0] constant_mem_read_addr;
	wire [31:0] constant_mem_in;
	
	wire [15:0] add_outa,add_outb,add_in;
	wire [15:0] sub_outa,sub_outb,sub_in;
	wire [15:0] shl_outa,shl_outb,shl_in;
	wire [31:0] L_add_outa,L_add_outb,L_add_in;
	wire [15:0] L_mult_outa,L_mult_outb;
	wire [31:0] L_mult_in;
	wire L_shl_start,L_shl_done,shl_overflow;
	wire [31:0] L_shl_outa;
	wire [15:0] L_shl_outb;
	wire [31:0] L_shl_in;
	
	lsp_lsf uut(
		.clock(clock),
		.reset(reset),
		.start(start),
		.done(done),
		.scratch_mem_read_addr(scratch_mem_read_addr),
		.scratch_mem_write_addr(scratch_mem_write_addr),
		.scratch_mem_out(scratch_mem_out),
		.scratch_mem_write_en(scratch_mem_write_en),
		.scratch_mem_in(scratch_mem_in),
		.constant_mem_read_addr(constant_mem_read_addr),
		.constant_mem_in(constant_mem_in),
		.lsf_addr(lsf_addr),
		.add_outa(add_outa),
		.add_outb(add_outb),
		.add_in(add_in),
		.sub_outa(sub_outa),
		.sub_outb(sub_outb),
		.sub_in(sub_in),
		.shl_outa(shl_outa),
		.shl_outb(shl_outb),
		.shl_in(shl_in),
		.L_add_outa(L_add_outa),
		.L_add_outb(L_add_outb),
		.L_add_in(L_add_in),
		.L_mult_outa(L_mult_outa),
		.L_mult_outb(L_mult_outb),
		.L_mult_in(L_mult_in),
		.L_shl_start(L_shl_start),
		.L_shl_outa(L_shl_outa),
		.L_shl_outb(L_shl_outb),
		.L_shl_in(L_shl_in),
		.L_shl_done(L_shl_done)
    );
	 
	add i_add_1(.a(add_outa),.b(add_outb),.overflow(add_overflow),.sum(add_in));
	
	sub i_sub_1(.a(sub_outa),.b(sub_outb),.overflow(sub_overflow),.diff(sub_in));
	
	shl i_shl_1(.var1(shl_outa),.var2(shl_outb),.overflow(shl_overflow),.result(shl_in));
	
	L_add i_L_add_1(.a(L_add_outa),.b(L_add_outb),.overflow(L_add_overflow),.sum(L_add_in));
	
	L_mult i_L_mult_1(.a(L_mult_outa),.b(L_mult_outb),.overflow(L_mult_overflow),.product(L_mult_in));
	
	L_shl i_L_shl_1(.clk(clock),.reset(reset),.ready(L_shl_start),.var1(L_shl_outa),.numShift(L_shl_outb),
							.done(L_shl_done),.out(L_shl_in));
							
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
