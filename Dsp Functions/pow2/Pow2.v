`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    14:35:36 03/28/2011
// Module Name:    Pow2 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description:    This module implements the POW2 function
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Pow2(clock,reset,start,done,exponent,fraction,result,L_mult_outa,L_mult_outb,
				L_mult_overflow,L_mult_in,L_shr_outa,L_shr_outb,L_shr_overflow,L_shr_in,
				sub_outa,sub_outb,sub_overflow,sub_in,L_msu_outa,L_msu_outb,L_msu_outc,
				L_msu_overflow,L_msu_in,constant_mem_read_addr,constant_mem_in,add_outa,
				add_outb,add_overflow,add_in
    );

	`include "constants_param_list.v"

	input clock,reset,start;
	
	output reg done;
	
	input L_mult_overflow,L_shr_overflow,sub_overflow,L_msu_overflow,add_overflow;
	
	input [15:0] sub_in,exponent,fraction,add_in;
	
	input [31:0] L_mult_in,L_shr_in,L_msu_in,constant_mem_in;
	
	output reg [11:0] constant_mem_read_addr;
	
	output reg [15:0] L_mult_outa,L_mult_outb,L_shr_outb,sub_outa,sub_outb,L_msu_outa,
						L_msu_outb,add_outa,add_outb;
		
	output reg [31:0] result,L_shr_outa,L_msu_outc;
	
	reg next_done;
	
	reg [15:0] exp,next_exp,i,next_i,a,next_a,temp,next_temp;
	
	reg [31:0] next_result,L_x,next_L_x;

	always@(posedge clock) begin
		if(reset)
			done = 'd0;
		else
			done = next_done;
	end

	always@(posedge clock) begin
		if(reset)
			exp = 'd0;
		else
			exp = next_exp;
	end
	
	always@(posedge clock) begin
		if(reset)
			i = 'd0;
		else
			i = next_i;
	end
	
	always@(posedge clock) begin
		if(reset)
			a = 'd0;
		else
			a = next_a;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp = 'd0;
		else
			temp = next_temp;
	end
	
	always@(posedge clock) begin
		if(reset)
			result = 'd0;
		else
			result = next_result;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_x = 'd0;
		else
			L_x = next_L_x;
	end
	
	parameter INIT = 3'd0;
	parameter state1 = 3'd1;
	parameter state2 = 3'd2;
	parameter state3 = 3'd3;
	parameter state4 = 3'd4;
	parameter state5 = 3'd5;
	parameter donestate = 3'd6;
	
	reg [2:0] currentstate,nextstate;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = INIT;
		else
			currentstate = nextstate;
	end
	
	always@(*) begin
		nextstate = currentstate;
		next_done = done;
		next_exp = exp;
		next_i = i;
		next_a = a;
		next_temp = temp;
		next_result = result;
		next_L_x = L_x;
		
		L_mult_outa = 'd0;
		L_mult_outb = 'd0;
		
		L_shr_outa = 'd0;
		L_shr_outb = 'd0;
		
		sub_outa = 'd0;
		sub_outb = 'd0;
		
		add_outa = 'd0;
		add_outb = 'd0;
		
		L_msu_outa = 'd0;
		L_msu_outb = 'd0;
		L_msu_outc = 'd0;
		
		constant_mem_read_addr = 'd0;
		
		case(currentstate)
		
			INIT: begin
				if(start)
					nextstate = state1;
				else
					nextstate = INIT;
			end
			
			state1: begin
				L_mult_outa = fraction;
				L_mult_outb = 'd32;
				next_i = L_mult_in[31:16];
				L_shr_outa = L_mult_in;
				L_shr_outb = 'd1;
				next_L_x = L_shr_in;
				next_a = L_shr_in[15:0] & 16'h7fff;
				constant_mem_read_addr = {TABPOW[11:6],L_mult_in[21:16]};
				nextstate = state2;
			end
			
			state2: begin
				next_L_x = {constant_mem_in[15:0],16'd0};
				add_outa = i;
				add_outb = 'd1;
				constant_mem_read_addr = {TABPOW[11:6],add_in[5:0]};
				nextstate = state3;
			end
			
			state3: begin
				sub_outa = L_x[31:16];
				sub_outb = constant_mem_in[15:0];
				L_msu_outa = sub_in;
				L_msu_outb = a;
				L_msu_outc = L_x;
				next_L_x = L_msu_in;
				nextstate = state4;
			end
			
			state4: begin
				sub_outa = 'd30;
				sub_outb = exponent;
				next_exp = sub_in;
				if(sub_in > 'd31 && sub_in[15] != 'd1) begin
					next_result = 'd0;
					next_done = 'd1;
					nextstate = donestate;
				end
				else begin
					L_shr_outa = L_x;
					L_shr_outb = sub_in;
					next_result = L_shr_in;
					if(sub_in[15] == 0 && sub_in != 0) begin
						nextstate = state5;
					end
				end
			end
			
			state5: begin
				sub_outa = exp;
				sub_outb = 'd1;
				if((L_x & (32'd1 << sub_in)) != 0) begin
					add_outa = result;
					add_outb = 'd1;
					next_result = add_in;
					next_done = 'd1;
					nextstate = donestate;
				end
				else
					next_done = 'd1;
					nextstate = donestate;
			end
			
			donestate: begin
				next_done = 'd0;
				nextstate = INIT;
			end
		endcase
	end	
endmodule
