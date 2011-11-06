`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    23:24:41 03/26/2011 
// Module Name:    Log2 
// Project Name:   ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description: 	 This module performs the operations done by the Log2 function
//
// Dependencies:
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Log2(clock,reset,start,done,L_x,exponent,fraction,L_shl_outa,L_shl_outb,L_shl_start,L_shl_done,
					L_shl_overflow,L_shl_in,L_shr_outa,L_shr_outb,L_shr_in,L_shr_overflow,sub_outa,sub_outb,
					sub_in,sub_overflow,L_msu_outa,L_msu_outb,L_msu_outc,L_msu_in,L_msu_overflow,norm_l_out,
					norm_l_start,norm_l_done,norm_l_in,constant_mem_read_addr,constant_mem_in,add_outa,
					add_outb,add_in,add_overflow
    );
	 
	`include "constants_param_list.v"
	 
	input clock, reset, start;
	
	input [31:0] L_x;
	
	output reg done;
	
	output reg [15:0] exponent, fraction;
	
	input L_shl_overflow,L_shr_overflow,L_msu_overflow,sub_overflow,add_overflow;
	 
	input L_shl_done,norm_l_done;
	
	input [15:0] add_in,sub_in,norm_l_in;
	
	input [31:0] L_shl_in,L_shr_in,L_msu_in;
	
	output reg L_shl_start,norm_l_start;
	 
	output reg [15:0] L_shl_outb,L_shr_outb,sub_outa,sub_outb,L_msu_outa,L_msu_outb,add_outa,add_outb;
	 
	output reg [31:0] L_shl_outa,L_shr_outa,norm_l_out,L_msu_outc;
	
	output reg [11:0] constant_mem_read_addr;
	
	input [31:0] constant_mem_in;

	reg next_done;
	always@(posedge clock) begin
	if(reset)
		done = 0;
	else
		done = next_done;
	end

	reg [15:0] next_exponent;
	always@(posedge clock) begin
	if(reset)
		exponent = 0;
	else
		exponent = next_exponent;
	end
	
	reg [15:0] next_fraction;
	always@(posedge clock) begin
	if(reset)
		fraction = 0;
	else
		fraction = next_fraction;
	end
	
	reg [15:0] exp,next_exp,i,next_i,a,next_a,temp,next_temp;
	reg [31:0] L_y,next_L_y,temp_L_x,next_temp_L_x;
	
	always@(posedge clock) begin
	if(reset)
		exp = 0;
	else
		exp = next_exp;
	end
	
	always@(posedge clock) begin
	if(reset)
		i = 0;
	else
		i = next_i;
	end
	
	always@(posedge clock) begin
	if(reset)
		a = 0;
	else
		a = next_a;
	end
	
	always@(posedge clock) begin
	if(reset)
		temp = 0;
	else
		temp = next_temp;
	end
	
	always@(posedge clock) begin
	if(reset)
		L_y = 0;
	else
		L_y = next_L_y;
	end
	
	always@(posedge clock) begin
	if(reset)
		temp_L_x = 0;
	else
		temp_L_x = next_temp_L_x;
	end
	
	parameter INIT = 3'd0;
	parameter state1 = 3'd1;
	parameter state2 = 3'd2;
	parameter state3 = 3'd3;
	parameter state4 = 3'd4;
	parameter state5 = 3'd5;
	parameter state6 = 3'd6;
	parameter done_state = 3'd7;

	reg [2:0] currentstate, nextstate;
	
	always@(posedge clock) begin
	if(reset)
		currentstate = INIT;
	else
		currentstate = nextstate;
	end

	always@(*)begin
		
		next_exponent = exponent;
		next_fraction = fraction;
		next_exp = exp;
		next_i = i;
		next_a = a;
		next_temp = temp;
		next_L_y = L_y;
		next_temp_L_x = temp_L_x;
		nextstate = currentstate;
		
		next_done = done;
		
		L_shl_outa = 'd0;
		L_shl_outb = 'd0;
		L_shl_start = 'd0;
		
		norm_l_out = 'd0;
		norm_l_start = 'd0;
		
		L_shr_outa = 'd0;
	 	L_shr_outb = 'd0;
		
		sub_outa = 'd0;
		sub_outb = 'd0;
		
		L_msu_outa = 'd0;
		L_msu_outb = 'd0;
		L_msu_outc = 'd0;
		
		add_outa = 'd0;
		add_outb = 'd0;
		
		constant_mem_read_addr = 'd0;
		
		case(currentstate)
		
		INIT: begin
			if(start)
				nextstate = state1;
			else
				nextstate = INIT;
		end
		
		//if(L_x <= 0){
		//		*exponent = 0;
		//		*fraction = 0;
		//		return;}
		// norm_l(L_x);
		state1: begin
			if(L_x == 32'd0 || L_x[31] == 'd1) begin
				next_exponent = 16'd0;
				next_fraction = 16'd0;
				next_done = 'd1;
				nextstate = done_state;
			end
			else begin
				norm_l_out = L_x;
				norm_l_start = 1'd1;
				nextstate = state2;
			end
		end
		
		//exp = norm_l(L_x);
		//L_shl(L_x, exp);
		state2: begin
			if(norm_l_done) begin
				next_exp = norm_l_in;
				L_shl_outa = L_x;
				L_shl_outb = norm_l_in;
				L_shl_start = 'd1;
				nextstate = state3;
			end
			else begin
				norm_l_out = L_x;
				nextstate = state2;
			end
		end
		
		//L_x = L_shl(L_x, exp);
		//*exponent = sub(30, exp);
		//L_x = L_shr(L_x,9);
		//i = extract_h(L_x);
		state3: begin
			if(L_shl_done) begin
				sub_outa = 'd30;
				sub_outb = exp;
				next_exponent = sub_in;
				L_shr_outa = L_shl_in;
				L_shr_outb = 'd9;
				next_temp_L_x = L_shr_in;
				next_i = L_shr_in[31:16];
				nextstate = state4;
			end
			else begin
				L_shl_outa = L_x;
				L_shl_outb = exp;
				nextstate = state3;
			end
		end
		//L_x = L_shr(L_x, 1);
		//a = extract_l(L_x);
		//a = a & 0x7fff;
		//i = sub(i, 32);
		//tablog[i]
		state4: begin
			L_shr_outa = temp_L_x;
			L_shr_outb = 'd1;
			next_temp_L_x = L_shr_in;
			next_a = L_shr_in[15:0] & 16'h7fff;
			sub_outa = i;
			sub_outb = 'd32;
			next_i = sub_in;
			constant_mem_read_addr = {TABLOG[11:6],sub_in[5:0]};
			nextstate = state5;
		end
		
		//L_y = L_deposit_h(tablog[i]);
		//tablog[i+1]
		state5: begin
			next_L_y[31:16] = constant_mem_in[15:0];
			next_temp = constant_mem_in[15:0];
			add_outa = i;
			add_outb = 'd1;
			constant_mem_read_addr = {TABLOG[11:6],add_in[5:0]};
			nextstate = state6;
		end
		
		//tmp = sub(tablog[i], tablog[i+1]);
		//L_y = L_msu(L_y, tmp, a);
		//*fraction = extract_h(L_y);
		state6: begin
			sub_outa = temp;
			sub_outb = constant_mem_in[15:0];
			L_msu_outa = sub_in;
			L_msu_outb = a;
			L_msu_outc = L_y;
			next_fraction = L_msu_in[31:16];
			next_done = 'd1;
			nextstate = done_state;
		end
			
		done_state: begin
			next_done = 'd0;
			nextstate = INIT;
		end
	endcase
end
			
endmodule
