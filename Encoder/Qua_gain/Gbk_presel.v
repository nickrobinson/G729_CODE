`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design 
// Engineer: Sean Owens
// 
// Create Date:    15:46:27 03/30/2011 
// Module Name:    Gbk_presel 
// Project Name:   ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description: 	 This module implements the Gbk_presel function.
//
// Dependencies: 	
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Gbk_presel(clock,reset,start,done,cand1,cand2,gcode0,constant_mem_read_addr,
							constant_mem_in,scratch_mem_read_addr,scratch_mem_in,scratch_mem_write_addr,
							scratch_mem_write_en,scratch_mem_out,L_mult_outa,L_mult_outb,L_mult_in,
							L_mult_overflow,L_shr_outa,L_shr_outb,L_shr_overflow,L_shr_in,L_add_outa,
							L_add_outb,L_add_in,L_add_overflow,L_shl_outa,L_shl_outb,L_shl_start,L_shl_done,
							L_shl_in,L_shl_overflow,L_sub_outa,L_sub_outb,L_sub_in,L_sub_overflow,
							mult_outa,mult_outb,mult_in,mult_overflow,add_outa,add_outb,add_in,add_overflow,
							sub_outa,sub_outb,sub_in,sub_overflow
    );

	`include "paramList.v"
	`include "constants_param_list.v"
	
	input clock,reset,start;
	input [15:0] gcode0;
	output reg done;
	output reg [15:0] cand1,cand2;
	
	input [31:0] scratch_mem_in,constant_mem_in;
	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_write_addr,constant_mem_read_addr,scratch_mem_read_addr;
	output reg [31:0] scratch_mem_out;
	
	input L_mult_overflow,L_shr_overflow,L_shl_overflow,L_add_overflow,L_sub_overflow,mult_overflow,add_overflow,
				sub_overflow,L_shl_done;
	input [15:0] mult_in,add_in,sub_in;
	input [31:0] L_mult_in,L_shr_in,L_add_in,L_shl_in,L_sub_in;
	output reg L_shl_start;
	output reg [15:0] L_mult_outa,L_mult_outb,L_shr_outb,L_shl_outb,mult_outa,mult_outb,add_outa,add_outb,sub_outa,sub_outb;
	output reg [31:0] L_shr_outa,L_add_outa,L_add_outb,L_shl_outa,L_sub_outa,L_sub_outb;
	
	reg next_done;
	
	reg [15:0] next_cand1,next_cand2,acc_h,next_acc_h,sft_x,next_sft_x,sft_y,next_sft_y;
	
	reg [31:0] L_acc,next_L_acc,L_preg,next_L_preg,L_cfbg,next_L_cfbg,L_temp,next_L_temp,L_temp_x,next_L_temp_x,L_temp_y,
						next_L_temp_y,L_tmp,next_L_tmp;
	
	always@(posedge clock) begin
		if(reset)
			done = 'd0;
		else
			done = next_done;
	end
	
	always@(posedge clock) begin
		if(reset)
			cand1 = 'd0;
		else
			cand1 = next_cand1;
	end
	
	always@(posedge clock) begin
		if(reset)
			cand2 = 'd0;
		else
			cand2 = next_cand2;
	end
	
	always@(posedge clock) begin
		if(reset)
			acc_h = 'd0;
		else
			acc_h = next_acc_h;
	end
	
	always@(posedge clock) begin
		if(reset)
			sft_x = 'd0;
		else
			sft_x = next_sft_x;
	end
	
	always@(posedge clock) begin
		if(reset)
			sft_y = 'd0;
		else
			sft_y = next_sft_y;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_acc = 'd0;
		else
			L_acc = next_L_acc;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_preg = 'd0;
		else
			L_preg = next_L_preg;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_cfbg = 'd0;
		else
			L_cfbg = next_L_cfbg;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_temp = 'd0;
		else
			L_temp = next_L_temp;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_temp_x = 'd0;
		else
			L_temp_x = next_L_temp_x;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_temp_y = 'd0;
		else
			L_temp_y = next_L_temp_y;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_tmp = 'd0;
		else
			L_tmp = next_L_tmp;
	end
	
	parameter INIT = 5'd0;
	parameter state1 = 5'd1;
	parameter state2 = 5'd2;
	parameter state3 = 5'd3;
	parameter state4 = 5'd4;
	parameter state5 = 5'd5;
	parameter state6 = 5'd6;
	parameter state7 = 5'd7;
	parameter state8 = 5'd8;
	parameter state9 = 5'd9;
	parameter state10 = 5'd10;
	parameter state11 = 5'd11;
	parameter state12 = 5'd12;
	parameter state13 = 5'd13;
	parameter state14 = 5'd14;
	parameter state15 = 5'd15;
	parameter state16 = 5'd16;
	parameter done_state = 5'd17;
	parameter state4_5 = 5'd18;
	parameter state17 = 5'd19;
	
	reg [4:0] currentstate, nextstate;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = INIT;
		else
			currentstate = nextstate;
	end
	
	always@(*) begin
		
		nextstate = currentstate;
		next_cand1 = cand1;
		next_cand2 = cand2;
		next_done = done;
		next_acc_h = acc_h;
		next_sft_x = sft_x;
		next_sft_y = sft_y;
		next_L_acc = L_acc;
		next_L_preg = L_preg;
		next_L_cfbg = L_cfbg;
		next_L_temp = L_temp;
		next_L_temp_x = L_temp_x;
		next_L_temp_y = L_temp_y;
		next_L_tmp = L_tmp;
		
		scratch_mem_write_en = 'd0;
		scratch_mem_write_addr = 'd0;
		constant_mem_read_addr = 'd0;
		scratch_mem_read_addr = 'd0;
		scratch_mem_out = 'd0;
		
		L_shl_start = 'd0;
		L_mult_outa = 'd0;
		L_mult_outb = 'd0;
		L_shr_outb = 'd0;
		L_shl_outb = 'd0;
		mult_outa = 'd0;
		mult_outb = 'd0;
		add_outa = 'd0;
		add_outb = 'd0;
		sub_outa = 'd0;
		sub_outb = 'd0;
		L_shr_outa = 'd0;
		L_add_outa = 'd0;
		L_add_outb = 'd0;
		L_shl_outa = 'd0;
		L_sub_outa = 'd0;
		L_sub_outb = 'd0;
		
		case(currentstate)
			
			INIT: begin
				if(start)
					nextstate = state1;
				else
					nextstate = INIT;
			end
			
			state1: begin
				constant_mem_read_addr = {COEF[11:2],1'd0,1'd0};
				scratch_mem_read_addr = {BEST_GAIN[11:1],1'd0};
				nextstate = state2;
			end
			
			state2: begin
				constant_mem_read_addr = {L_COEF[11:2],1'd1,1'd1};
				scratch_mem_read_addr = {BEST_GAIN[11:1],1'd1};
				L_mult_outa = constant_mem_in[15:0];
				L_mult_outb = scratch_mem_in[15:0];
				next_L_cfbg = L_mult_in;
				nextstate = state3;
			end
			
			state3: begin
				L_shr_outa = constant_mem_in;
				L_shr_outb = 'd15;
				L_add_outa = L_cfbg;
				L_add_outb = L_shr_in;
				next_L_acc = L_add_in;
				next_acc_h = L_add_in[31:16];
				L_mult_outa =  L_add_in[31:16];
				L_mult_outb = gcode0;
				next_L_preg =  L_mult_in;
				if(scratch_mem_in[15] == 'd1)
					next_L_temp = {16'hFFFF,scratch_mem_in[15:0]};
				else
					next_L_temp = {16'd0,scratch_mem_in[15:0]};
				L_shl_outa = next_L_temp;
				L_shl_outb = 'd7;
				L_shl_start = 'd1;
				nextstate = state4;
			end
			
			state4: begin
				if(L_shl_done == 'd1) begin
					L_sub_outa = L_shl_in;
					L_sub_outb = L_preg;
					next_L_acc = L_sub_in;
					nextstate = state4_5;
				end
				else begin
					L_shl_outa = L_temp;
					L_shl_outb = 'd7;
					nextstate = state4;
				end
			end
			
			state4_5: begin
				L_shl_outa = L_acc;
				L_shl_outb = 'd2;
				L_shl_start = 'd1;
				nextstate = state5;
			end
			
			state5: begin
				if(L_shl_done == 'd1) begin
					next_acc_h = L_shl_in[31:16];
					L_mult_outa = L_shl_in[31:16];
					L_mult_outb = 16'hBD31;
					next_L_temp_x = L_mult_in;
					constant_mem_read_addr = {L_COEF[11:2],1'd0,1'd1};
					nextstate = state6;
				end
				else begin
					L_shl_outa = L_acc;
					L_shl_outb = 'd2;
					nextstate = state5;
				end
			end
				
			state6: begin
				L_shr_outa = constant_mem_in;
				L_shr_outb = 'd10;
				L_sub_outa = L_cfbg;
				L_sub_outb = L_shr_in;
				next_L_acc = L_sub_in;
				mult_outa = L_sub_in[31:16];
				mult_outb = gcode0;
				next_acc_h = mult_in;
				constant_mem_read_addr = {COEF[11:2],1'd1,1'd0};
				nextstate = state7;
			end
			
			state7: begin
				scratch_mem_read_addr = {BEST_GAIN[11:1],1'd1};
				constant_mem_read_addr = {COEF[11:2],1'd0,1'd0};
				L_mult_outb = constant_mem_in[15:0];
				L_mult_outa = acc_h;
				next_L_tmp = L_mult_in;
				nextstate = state8;
			end
			
			state8: begin
				L_mult_outa = constant_mem_in[15:0];
				L_mult_outb = scratch_mem_in[15:0];
				next_L_preg = L_mult_in;
				L_shr_outa = L_mult_in;
				L_shr_outb = 'd3;
				L_sub_outa = L_tmp;
				L_sub_outb = L_shr_in;
				next_L_acc = L_sub_in;
				L_shl_outa = L_sub_in;
				L_shl_outb = 'd2;
				L_shl_start = 'd1;
				nextstate = state9;
			end
			
			state9: begin
				if(L_shl_done == 'd1) begin
					next_acc_h = L_shl_in[31:16];
					L_mult_outa = L_shl_in[31:16];
					L_mult_outb = 16'hBD31;
					next_L_temp_y = L_mult_in;
					next_sft_y = 'd3;
					next_sft_x = 'd5;
					next_cand1 ='d0;
					if(gcode0[15] == 'd1 || gcode0 == 'd0) begin
						next_cand1 = 'd0;
						next_cand2 = 'd0;
						nextstate = state14;
					end
					else begin
						next_cand1 = 'd0;
						next_cand2 = 'd0;
						nextstate = state10;
					end
				end
				else begin
					L_shl_outa = L_acc;
					L_shl_outb = 'd2;
					nextstate = state9;
				end
			end
			
			state10: begin
				constant_mem_read_addr = {THR1[11:2],cand1[1:0]};
				nextstate = state11;
			end
			
			state11: begin
				L_mult_outa = constant_mem_in[15:0];
				L_mult_outb = gcode0;
				L_shr_outa = L_mult_in;
				L_shr_outb = sft_y;
				L_sub_outa = L_temp_y;
				L_sub_outb = L_shr_in;
				next_L_temp = L_sub_in;
				if(L_sub_in[31] != 'd1 && L_sub_in != 'd0) begin
					add_outa = cand1;
					add_outb = 'd1;
					next_cand1 = add_in;
					sub_outa = add_in;
					sub_outb = 'd4;
					if(sub_in[15] == 'd1)
						nextstate = state10;
					else
						nextstate = state12;
				end
				else begin
					nextstate = state12;
				end
			end
			
			state12: begin
				constant_mem_read_addr = {THR2[11:3],cand2[2:0]};
				nextstate = state13;
			end
			
			state13: begin
				L_mult_outa = constant_mem_in[15:0];
				L_mult_outb = gcode0;
				L_shr_outa = L_mult_in;
				L_shr_outb = sft_x;
				L_sub_outa = L_temp_x;
				L_sub_outb = L_shr_in;
				next_L_temp = L_sub_in;
				if(L_sub_in[31] != 'd1 && L_sub_in != 'd0) begin
					add_outa = cand2;
					add_outb = 'd1;
					next_cand2 = add_in;
					sub_outa = add_in;
					sub_outb = 'd8;
					if(sub_in[15] == 'd1)
						nextstate = state12;
					else begin
						next_done = 'd1;
						nextstate = done_state;
					end
				end
				else begin
					next_done = 'd1;
					nextstate = done_state;
				end
			end
			
			state14: begin
				constant_mem_read_addr = {THR1[11:2],cand1[1:0]};
				nextstate = state15;
			end
			
			state15: begin
				L_mult_outa = constant_mem_in[15:0];
				L_mult_outb = gcode0;
				L_shr_outa = L_mult_in;
				L_shr_outb = sft_y;
				L_sub_outa = L_temp_y;
				L_sub_outb = L_shr_in;
				next_L_temp = L_sub_in;
				if(L_sub_in[31] == 'd1) begin
					add_outa = cand1;
					add_outb = 'd1;
					next_cand1 = add_in;
					sub_outa = add_in;
					sub_outb = 'd4;
					if(sub_in != 'd0)
						nextstate = state14;
					else
						nextstate = state16;
				end
				else begin
					nextstate = state16;
				end
			end
			
			state16: begin
				constant_mem_read_addr = {THR2[11:3],cand2[2:0]};
				nextstate = state17;
			end
			
			state17: begin
				L_mult_outa = constant_mem_in[15:0];
				L_mult_outb = gcode0;
				L_shr_outa = L_mult_in;
				L_shr_outb = sft_x;
				L_sub_outa = L_temp_x;
				L_sub_outb = L_shr_in;
				next_L_temp = L_sub_in;
				if(L_sub_in[31] == 'd1) begin
					add_outa = cand2;
					add_outb = 'd1;
					next_cand2 = add_in;
					sub_outa = add_in;
					sub_outb = 'd8;
					if(sub_in == 'd0)
						nextstate = state16;
					else begin
						next_done = 'd1;
						nextstate = done_state;
					end
				end
				else begin
					next_done = 'd1;
					nextstate = done_state;
				end
			end
				
			done_state: begin
				next_done = 'd0;
				nextstate =INIT;
			end
		endcase
	end
				
	
endmodule
