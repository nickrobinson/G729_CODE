`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:49:37 02/08/2011 
// Design Name: 
// Module Name:    Levinson_Durbin_test_pipe 
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
module Levinson_Durbin_test_pipe(clock,reset,L_sub_outa,L_sub_outb,L_sub_overflow,L_sub_in,L_mac_outa,L_mac_outb,
						L_mac_outc,L_mac_overflow,L_mac_in,L_mult_outa,L_mult_outb,L_mult_overflow,L_mult_in,
						mult_outa,mult_outb,mult_overflow,mult_in,L_shl_start,L_shl_overflow,L_shl_outa,L_shl_outb,
						L_shl_done,L_shl_in,norm_L_out,norm_L_in,norm_L_start,norm_L_done,L_shr_outa,L_shr_outb,L_shr_in,
						negate_out,negate_in,abs_out,abs_in,L_add_outa,L_add_outb,L_add_overflow,L_add_in,add_outa,
						add_outb,add_overflow,add_in,sub_outa,sub_outb,sub_overflow,sub_in,scratch_mem_write_addr,
						scratch_mem_read_addr,scratch_mem_out,scratch_mem_in,scratch_mem_write_en,testReadAddr,testWriteAddr,
						testWriteOut,testWriteEnable,mux0sel,mux1sel,mux2sel,mux3sel
    );

	input clock;
	input reset;
	output [31:0] abs_in;
	output [31:0] negate_in;
	output [31:0] L_shr_in;
	output [31:0] L_sub_in;
	output [15:0] norm_L_in;
	output norm_L_done;
	output [31:0] L_shl_in;
	output L_shl_overflow;
	output L_shl_done;
	output [31:0] L_mult_in;
	output L_mult_overflow;
	output [31:0] L_mac_in;
	output L_mac_overflow;
	output [15:0] mult_in;
	output mult_overflow;
	output [31:0] L_add_in;
	output L_add_overflow;
	output L_sub_overflow;
	output sub_overflow;
	output add_overflow;
	output [15:0] add_in;
	output [15:0] sub_in;
			
	input [31:0] abs_out;
	input [31:0] negate_out;
	input [31:0] L_shr_outa;
	input [15:0] L_shr_outb;
	input [31:0] L_sub_outa;
	input [31:0] L_sub_outb;
	input [31:0] norm_L_out;
	input norm_L_start;
	input [31:0] L_shl_outa;
	input [15:0] L_shl_outb;
	input L_shl_start;
	input [15:0] L_mult_outa;
	input [15:0] L_mult_outb;
	input [15:0] L_mac_outa;
	input [15:0] L_mac_outb;
	input [31:0] L_mac_outc;
	input [15:0] mult_outa;
	input [15:0] mult_outb;
	input [31:0] L_add_outa;
	input [31:0] L_add_outb;
	input [15:0] sub_outa;
	input [15:0] sub_outb;
	input [15:0] add_outa;
	input [15:0] add_outb;

	
	input mux0sel;
	input mux1sel;
	input mux2sel;
	input mux3sel;
	
	input [11:0] scratch_mem_write_addr;
	input [11:0] scratch_mem_read_addr;
	input [31:0] scratch_mem_out;
	input scratch_mem_write_en;
	input [11:0] testWriteAddr;
	input [11:0] testReadAddr;
	input [31:0] testWriteOut;
	input testWriteEnable;
	
	output [31:0] scratch_mem_in;

		L_sub i_L_sub_1(.a(L_sub_outa),.b(L_sub_outb),.overflow(L_sub_overflow),.diff(L_sub_in));
	
		L_mac i_L_mac_1(.a(L_mac_outa),.b(L_mac_outb),.c(L_mac_outc),.overflow(L_mac_overflow),.out(L_mac_in));
		
		L_mult i_L_mult_1(.a(L_mult_outa),.b(L_mult_outb),.overflow(L_mult_overflow),.product(L_mult_in));
		
		mult i_mult_1(.a(mult_outa),.b(mult_outb),.overflow(mult_overflow),.product(mult_in));
		
		L_shl i_L_shl_1(.clk(clock),.reset(reset),.ready(L_shl_start),.overflow(L_shl_overflow),.var1(L_shl_outa),.numShift(L_shl_outb),
								.done(L_shl_done),.out(L_shl_in));
		
		norm_l i_norm_l_1(.var1(norm_L_out),.norm(norm_L_in),.clk(clock),.ready(norm_L_start),.reset(reset),.done(norm_L_done));
		
		L_shr i_L_shr_1(.var1(L_shr_outa),.numShift(L_shr_outb),.out(L_shr_in));
		
		L_negate i_L_negate_1(.var_in(negate_out),.var_out(negate_in));
		
		L_abs i_L_abs_1(.var_in(abs_out),.var_out(abs_in));
		
		L_add i_L_add_1(.a(L_add_outa),.b(L_add_outb),.overflow(L_add_overflow),.sum(L_add_in));
		
		add i_add_1(.a(add_outa),.b(add_outb),.overflow(add_overflow),.sum(add_in));
		
		sub i_sub_1(.a(sub_outa),.b(sub_outb),.overflow(sub_overflow),.diff(sub_in));
		
	reg [11:0] mux0out;
	reg [11:0] mux1out;
	reg [31:0] mux2out;
	reg mux3out;
		
	always@(*)
	begin
		case(mux0sel)
			'd0:	mux0out = scratch_mem_read_addr;
			'd1:	mux0out = testReadAddr;
		endcase
	end
	
	//Scratch read address	
	always@(*)
	begin
		case(mux1sel)
			'd0:	mux1out = scratch_mem_write_addr;
			'd1:	mux1out = testWriteAddr;
		endcase
	end
	
	//Scratch write output	
	always@(*)
	begin
		case(mux2sel)
			'd0:	mux2out = scratch_mem_out;
			'd1:	mux2out = testWriteOut;
		endcase
	end
	
	//Scratch write enable	
	always@(*)
	begin
		case(mux3sel)
			'd0:	mux3out = scratch_mem_write_en;
			'd1:	mux3out = testWriteEnable;
		endcase
	end
	
	
	Scratch_Memory_Controller Scratch(
												.addra(mux1out),
												.dina(mux2out),
												.wea(mux3out),
												.clk(clock),
												.addrb(mux0out),
												.doutb(scratch_mem_in)
												);
endmodule
