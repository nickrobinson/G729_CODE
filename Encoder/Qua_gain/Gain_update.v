`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    14:46:53 04/04/2011 
// Module Name:    Gain_update 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T
// Tool versions:  Xilinx ISE 12.4
// Description: 
//
// Dependencies: 	 Log2.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Gain_update(clock,reset,start,done,L_gbk12,scratch_mem_read_addr,scratch_mem_write_addr,
							scratch_mem_out,scratch_mem_write_en,scratch_mem_in,add_outa,add_outb,add_in,
							add_overflow,sub_outa,sub_outb,sub_in,sub_overflow,L_shl_start,L_shl_outa,
							L_shl_outb,L_shl_overflow,L_shl_in,L_shl_done,mult_outa,mult_outb,mult_in,
							mult_overflow,L_shr_outa,L_shr_outb,L_shr_overflow,L_shr_in,L_msu_outa,
							L_msu_outb,L_msu_outc,L_msu_overflow,L_msu_in,norm_l_out,norm_l_start,
							norm_l_in,norm_l_done,constant_mem_read_addr,constant_mem_in,L_mac_outa,
							L_mac_outb,L_mac_outc,L_mac_overflow,L_mac_in
    );

	`include "ParamList.v"

	input clock,reset,start;
	output reg done;
	
	input [31:0] L_gbk12;
	
	input [31:0] scratch_mem_in,constant_mem_in;
	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_read_addr,scratch_mem_write_addr,constant_mem_read_addr;
	output reg [31:0] scratch_mem_out;
	
	input add_overflow,sub_overflow,L_shl_overflow,L_shl_done,mult_overflow,L_shr_overflow,L_msu_overflow,
				L_mac_overflow,norm_l_done;
	input [15:0] add_in,sub_in,mult_in,norm_l_in;
	input [31:0] L_shl_in,L_shr_in,L_msu_in,L_mac_in;
	output reg L_shl_start,norm_l_start;
	output reg [15:0] add_outa,add_outb,sub_outa,sub_outb,L_shl_outb,L_shr_outb,L_msu_outa,L_msu_outb,
							L_mac_outa,L_mac_outb,mult_outa,mult_outb;
	output reg [31:0] L_shl_outa,L_shr_outa,L_msu_outc,L_mac_outc,norm_l_out;
	
	reg log2_start;
	reg [31:0] log2_in;
	wire log2_done,log2_L_shl_start,log2_norm_l_start;
	wire [11:0] log2_constant_mem_read_addr;
	wire [15:0] log2_exp,log2_frac,log2_L_shl_outb,log2_L_shr_outb,log2_sub_outa,log2_sub_outb,log2_L_msu_outa,log2_L_msu_outb,
					log2_add_outa,log2_add_outb;
	wire [31:0] log2_L_shl_outa,log2_L_shr_outa,log2_L_msu_outc,log2_norm_l_out;
	
	Log2 i_Log2_1(
					.clock(clock),.reset(reset),.start(log2_start),.done(log2_done),
					.L_x(log2_in),.exponent(log2_exp),.fraction(log2_frac),
					.L_shl_outa(log2_L_shl_outa),.L_shl_outb(log2_L_shl_outb),.L_shl_start(log2_L_shl_start),.L_shl_done(L_shl_done),
						.L_shl_overflow(L_shl_overflow),.L_shl_in(L_shl_in),
					.L_shr_outa(log2_L_shr_outa),.L_shr_outb(log2_L_shr_outb),.L_shr_in(L_shr_in),.L_shr_overflow(L_shr_overflow),
					.sub_outa(log2_sub_outa),.sub_outb(log2_sub_outb),.sub_in(sub_in),.sub_overflow(sub_overflow),
					.L_msu_outa(log2_L_msu_outa),.L_msu_outb(log2_L_msu_outb),.L_msu_outc(log2_L_msu_outc),.L_msu_in(L_msu_in),
						.L_msu_overflow(L_msu_overflow),
					.norm_l_out(log2_norm_l_out),.norm_l_start(log2_norm_l_start),.norm_l_done(norm_l_done),.norm_l_in(norm_l_in),
					.constant_mem_read_addr(log2_constant_mem_read_addr),.constant_mem_in(constant_mem_in),
					.add_outa(log2_add_outa),.add_outb(log2_add_outb),.add_in(add_in),.add_overflow(add_overflow)
				);
				
	reg next_done;
	reg [15:0] i,next_i,temp,next_temp,exp,next_exp,frac,next_frac;
	reg [31:0] L_acc,next_L_acc;
	
	always@(posedge clock) begin
		if(reset)
			i = 'd3;
		else
			i = next_i;
	end
	
	always@(posedge clock) begin
		if(reset)
			done = 'd0;
		else
			done = next_done;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp = 'd0;
		else
			temp = next_temp;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp = 'd0;
		else
			exp = next_exp;
	end
	
	always@(posedge clock) begin
		if(reset)
			frac = 'd0;
		else
			frac = next_frac;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_acc = 'd0;
		else
			L_acc = next_L_acc;
	end
	
	parameter INIT = 3'd0;
	parameter state1 = 3'd1;
	parameter state2 = 3'd2;
	parameter state3 = 3'd3;
	parameter state4 = 3'd4;
	parameter done_state = 3'd5;
	
	reg [2:0] currentstate,nextstate;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = INIT;
		else
			currentstate = nextstate;
	end
	
	always@(*) begin
		nextstate = currentstate;
		next_i = i;
		next_temp = temp;
		next_exp = exp;
		next_frac = frac;
		next_L_acc = L_acc;
		
		next_done = done;
	
		scratch_mem_write_en = 'd0;
		scratch_mem_read_addr = 'd0;
		scratch_mem_write_addr = 'd0;
		constant_mem_read_addr = log2_constant_mem_read_addr;
		scratch_mem_out = 'd0;
	
		L_shl_start = 'd0;
		norm_l_start = log2_norm_l_start;
		add_outa = 'd0;
		add_outb = 'd0;
		sub_outa = 'd0;
		sub_outb = 'd0;
		L_shl_outb = 'd0;
		L_shr_outb = log2_L_shr_outb;
		L_msu_outa = log2_L_msu_outa;
		L_msu_outb = log2_L_msu_outb;
		L_mac_outa = 'd0;
		L_mac_outb = 'd0;
		L_shl_outa = 'd0;
		L_shr_outa = log2_L_shr_outa;
		L_msu_outc = log2_L_msu_outc;
		L_mac_outc = 'd0;
		norm_l_out = log2_norm_l_out;
		mult_outa = 'd0;
		mult_outb = 'd0;
	
		log2_start = 'd0;
		log2_in = 'd0;
		
		case(currentstate)
		
			INIT: begin
				if(start)
					nextstate = state1;
				else
					nextstate = INIT;
			end
			
			state1: begin
				if(i == 'd0) begin
					next_i = 'd3;
					log2_in = L_gbk12;
					log2_start = 'd1;
					nextstate = state3;
				end
				else begin
					sub_outa = i;
					sub_outb = 'd1;
					scratch_mem_read_addr = {PAST_QUA_EN[11:2],sub_in[1:0]};
					nextstate = state2;
				end
			end
			
			state2: begin
				scratch_mem_write_addr = {PAST_QUA_EN[11:2], i[1:0]};
				scratch_mem_out = scratch_mem_in;
				scratch_mem_write_en = 'd1;
				sub_outa = i;
				sub_outb = 'd1;
				next_i = sub_in;
				nextstate = state1;
			end
			
			state3: begin
				if(log2_done == 'd1) begin
					next_exp = log2_exp;
					next_frac = log2_frac;
					sub_outa = log2_exp;
					sub_outb = 'd13;
					L_mac_outa = log2_frac;
					L_mac_outb = 'd1;
					L_mac_outc = {sub_in,16'd0};
					next_L_acc = L_mac_in;
					L_shl_outa = L_mac_in;
					L_shl_outb = 'd13;
					L_shl_start = 'd1;
					nextstate = state4;
				end
				else begin
					sub_outa = log2_sub_outa;
					sub_outb = log2_sub_outb;
					add_outa = log2_add_outa;
					add_outb = log2_add_outb;
					L_shl_start = log2_L_shl_start;
					L_shl_outa = log2_L_shl_outa;
					L_shl_outb = log2_L_shl_outb;
					log2_in = L_gbk12;
					nextstate = state3;
				end
			end
				
			state4: begin
				if(L_shl_done == 'd1) begin
					next_temp = L_shl_in[31:16];
					mult_outa = L_shl_in[31:16];
					mult_outb = 'd24660;
					scratch_mem_write_en = 'd1;
					scratch_mem_write_addr = PAST_QUA_EN;
					scratch_mem_out = {16'd0,mult_in};
					next_done = 'd1;
					nextstate = done_state;
				end
				else begin
					L_shl_outa = L_acc;
					L_shl_outb = 'd13;
					nextstate = state4;
				end
			end
			
			done_state: begin
				next_done = 'd0;
				nextstate = INIT;
			end
		endcase
	end
endmodule	
