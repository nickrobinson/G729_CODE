`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    10:25:36 04/11/2011 
// Module Name:    Qua_gain_pipe 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T
// Tool versions:  Xilinx ISE 12.4
// Description: 
//
// Dependencies: 	 Qua_gain.v
//						 L_mac.v
//						 L_mult.v
//						 mult.v
//						 L_shl.v
//						 norm_l.v
//						 L_shr.v
//						 add.v
//						 sub.v
//						 L_msu.v
//						 L_add.v
//						 L_sub.v
//						 shl.v
//						 shr.v
//						 L_negate.v
//						 Scratch_Memory_Controller.v
//						 Constant_Memory_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Qua_gain_pipe(clock,reset,start,done,out,tame_flag,scratch_mem_in,mem_Mux1Sel,mem_Mux2Sel,
					mem_Mux3Sel,mem_Mux4Sel,test_write_addr,test_read_addr,test_write,test_write_en
    );

	input clock,reset,start,tame_flag;
	output done;
	output [15:0] out;
	output [31:0] scratch_mem_in;

	input mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,mem_Mux4Sel;
	input [11:0] test_write_addr,test_read_addr;
	input [31:0] test_write;
	input test_write_en;
	reg [11:0] mem_Mux1Out,mem_Mux4Out;
	reg [31:0] mem_Mux2Out;
	reg mem_Mux3Out;

	wire [11:0] scratch_mem_write_addr,scratch_mem_read_addr;
	wire [31:0] scratch_mem_out;
	wire scratch_mem_write_en;

	wire [11:0] constant_mem_read_addr;
	wire [31:0] constant_mem_in;
	
	wire norm_l_done,L_shl_done;
	wire L_mult_overflow,mult_overflow,L_mac_overflow,sub_overflow,add_overflow,L_msu_overflow;
	wire [15:0] norm_l_in,mult_in,sub_in,add_in;
	wire [31:0] L_shr_in,L_shl_in,L_mac_in,L_mult_in,L_msu_in;
	
	wire norm_l_start,L_shl_start;
	wire [15:0] L_shr_outb,L_shl_outb,sub_outa,sub_outb,add_outa,add_outb;
	wire [31:0] L_shr_outa,norm_l_out,L_shl_outa;
	
	wire [15:0] mult_outa,mult_outb,L_mult_outa,L_mult_outb,L_mac_outa,L_mac_outb,L_msu_outa,L_msu_outb;
	wire [31:0] L_mac_outc,L_msu_outc;
	
	wire L_add_overflow,L_sub_overflow;
	wire [31:0] L_add_outa,L_add_outb,L_add_in,L_sub_outa,L_sub_outb,L_sub_in;
	
	wire shl_overflow;
	wire [15:0] shl_outa,shl_outb,shl_in,shr_outa,shr_outb,shr_in;
	
	wire [31:0] L_negate_out,L_negate_in;
	
	Qua_gain i_qua_gain(
						clock,reset,start,done,out,tame_flag,
						L_mac_outa,L_mac_outb,L_mac_outc,L_mac_overflow,L_mac_in,
						L_msu_outa,L_msu_outb,L_msu_outc,L_msu_overflow,L_msu_in,
						L_mult_outa,L_mult_outb,L_mult_overflow,L_mult_in,
						L_add_outa,L_add_outb,L_add_overflow,L_add_in,
						L_sub_outa,L_sub_outb,L_sub_overflow,L_sub_in,
						L_shr_outa,L_shr_outb,L_shr_overflow,L_shr_in,
						L_shl_outa,L_shl_outb,L_shl_start,L_shl_in,L_shl_done,L_shl_overflow,
						norm_l_out,norm_l_start,norm_l_in,norm_l_done,
						mult_outa,mult_outb,mult_overflow,mult_in,
						shl_outa,shl_outb,shl_overflow,shl_in,
						add_outa,add_outb,add_overflow,add_in,
						sub_outa,sub_outb,sub_overflow,sub_in,
						scratch_mem_write_addr,scratch_mem_read_addr,
						scratch_mem_write_en,scratch_mem_out,scratch_mem_in,
						constant_mem_read_addr,constant_mem_in,
						L_negate_out,L_negate_in,
						shr_outa,shr_outb,shr_in
    );
	 
	L_mac i_L_mac_1(.a(L_mac_outa),.b(L_mac_outb),.c(L_mac_outc),.overflow(L_mac_overflow),.out(L_mac_in));
	
	L_mult i_L_mult_1(.a(L_mult_outa),.b(L_mult_outb),.overflow(L_mult_overflow),.product(L_mult_in));
	
	mult i_mult_1(.a(mult_outa),.b(mult_outb),.overflow(mult_overflow),.product(mult_in));
	
	L_shl i_L_shl_1(.clk(clock),.reset(reset),.ready(L_shl_start),.var1(L_shl_outa),.numShift(L_shl_outb),
							.done(L_shl_done),.out(L_shl_in),.overflow(L_shl_overflow));
	
	norm_l i_norm_l_1(.var1(norm_l_out),.norm(norm_l_in),.clk(clock),.ready(norm_l_start),.reset(reset),.done(norm_l_done));
	
	L_shr i_L_shr_1(.var1(L_shr_outa),.numShift(L_shr_outb),.out(L_shr_in),.overflow(L_shr_overflow));
	
	add i_add_1(.a(add_outa),.b(add_outb),.overflow(add_overflow),.sum(add_in));
	
	sub i_sub_1(.a(sub_outa),.b(sub_outb),.overflow(sub_overflow),.diff(sub_in));
	
	L_msu i_L_msu_1(.a(L_msu_outa),.b(L_msu_outb),.c(L_msu_outc),.overflow(L_msu_overflow),.out(L_msu_in));
	
	L_add i_L_add_1(.a(L_add_outa),.b(L_add_outb),.overflow(L_add_overflow),.sum(L_add_in));
	
	L_sub i_L_sub_1(.a(L_sub_outa),.b(L_sub_outb),.overflow(L_sub_overflow),.diff(L_sub_in));
	
	shl i_shl_1(.var1(shl_outa),.var2(shl_outb),.overflow(shl_overflow),.result(shl_in));
	
	shr i_shr_1(.var1(shr_outa),.var2(shr_outb),.result(shr_in));
	
	L_negate i_L_negate(.var_in(L_negate_out),.var_out(L_negate_in));
	
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
