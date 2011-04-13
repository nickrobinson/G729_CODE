`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    10:45:12 03/28/2011 
// Module Name:    Gain_predict 
// Project Name:   ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description:    This module implements the Gain_predict function
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Gain_predict(clock,reset,start,done,scratch_mem_read_addr,scratch_mem_write_addr,gcode0,exp_gcode0,
							scratch_mem_write_en,scratch_mem_in,scratch_mem_out,constant_mem_read_addr,
							constant_mem_in,L_shl_outa,L_shl_outb,L_shl_start,L_shl_done,L_shl_in,L_shl_overflow,
							L_shr_outa,L_shr_outb,L_shr_in,L_shr_overflow,norm_l_out,norm_l_start,norm_l_done,
							norm_l_in,sub_outa,sub_outb,sub_overflow,sub_in,L_msu_outa,L_msu_outb,L_msu_outc,
							L_msu_overflow,L_msu_in,add_outa,add_outb,add_overflow,add_in,L_mac_outa,L_mac_outb,
							L_mac_outc,L_mac_in,L_mac_overflow,L_mult_outa,L_mult_outb,L_mult_overflow,L_mult_in,
							mult_outa,mult_outb,mult_overflow,mult_in
    );

	`include "paramList.v"
	`include "constants_param_list.v"

	input clock,reset,start;
	
	output reg [15:0] gcode0,exp_gcode0;
	
	input L_shl_overflow,L_shl_done,L_shr_overflow,norm_l_done,sub_overflow,L_msu_overflow,add_overflow,
				L_mac_overflow,L_mult_overflow,mult_overflow;
	
	input [15:0] norm_l_in,sub_in,add_in,mult_in;
	
	input [31:0] scratch_mem_in,constant_mem_in,L_shl_in,L_shr_in,L_msu_in,L_mac_in,L_mult_in;
	
	output reg done,scratch_mem_write_en,L_shl_start,norm_l_start;
	
	output reg [11:0] scratch_mem_read_addr,scratch_mem_write_addr,constant_mem_read_addr;
	
	output reg [15:0] L_shl_outb,L_shr_outb,sub_outa,sub_outb,L_msu_outa,L_msu_outb,add_outa,add_outb,L_mac_outa,
								L_mac_outb,L_mult_outa,L_mult_outb,mult_outa,mult_outb;
	
	output reg [31:0] scratch_mem_out,L_shl_outa,L_shr_outa,norm_l_out,L_msu_outc,L_mac_outc;
	
	
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
				
	reg [15:0] mpy_32_16_inb;
	
	reg [31:0] mpy_32_16_ina;
	
	wire [15:0] mpy_32_16_L_mult_outa,mpy_32_16_L_mult_outb,mpy_32_16_L_mac_outa,mpy_32_16_L_mac_outb,mpy_32_16_mult_outa,
						mpy_32_16_mult_outb;
	
	wire [31:0] mpy_32_16_out,mpy_32_16_L_mac_outc;
				
	mpy_32_16 i_mpy_32_16_1(
					.var1(mpy_32_16_ina),.var2(mpy_32_16_inb),.out(mpy_32_16_out),
					.L_mult_outa(mpy_32_16_L_mult_outa),.L_mult_outb(mpy_32_16_L_mult_outb),.L_mult_overflow(L_mult_overflow),
						.L_mult_in(L_mult_in),
					.L_mac_outa(mpy_32_16_L_mac_outa),.L_mac_outb(mpy_32_16_L_mac_outb),.L_mac_outc(mpy_32_16_L_mac_outc), 
						.L_mac_overflow(L_mac_overflow),.L_mac_in(L_mac_in),
					.mult_outa(mpy_32_16_mult_outa),.mult_outb(mpy_32_16_mult_outb),.mult_in(mult_in),.mult_overflow(mult_overflow)
				);
				
	reg pow2_start;
	
	reg [15:0] pow2_exp,pow2_frac;

	wire pow2_done;
	
	wire [11:0] pow2_constant_mem_read_addr;
	
	wire [15:0] pow2_L_mult_outa,pow2_L_mult_outb,pow2_L_shr_outb,pow2_sub_outa,pow2_sub_outb,pow2_L_msu_outa,
						pow2_L_msu_outb,pow2_add_outa,pow2_add_outb;
	
	wire [31:0] pow2_result,pow2_L_shr_outa,pow2_L_msu_outc;
				
	Pow2 i_Pow2_1(
					.clock(clock),.reset(reset),.start(pow2_start),.done(pow2_done),
					.exponent(pow2_exp),.fraction(pow2_frac),.result(pow2_result),
					.L_mult_outa(pow2_L_mult_outa),.L_mult_outb(pow2_L_mult_outb),.L_mult_overflow(L_mult_overflow),.L_mult_in(L_mult_in),
					.L_shr_outa(pow2_L_shr_outa),.L_shr_outb(pow2_L_shr_outb),.L_shr_overflow(L_shr_overflow),.L_shr_in(L_shr_in),
					.sub_outa(pow2_sub_outa),.sub_outb(pow2_sub_outb),.sub_overflow(sub_overflow),.sub_in(sub_in),
					.L_msu_outa(pow2_L_msu_outa),.L_msu_outb(pow2_L_msu_outb),.L_msu_outc(pow2_L_msu_outc),.L_msu_overflow(L_msu_overflow),
						.L_msu_in(L_msu_in),
					.constant_mem_read_addr(pow2_constant_mem_read_addr),.constant_mem_in(constant_mem_in),
					.add_outa(pow2_add_outa),.add_outb(pow2_add_outb),.add_overflow(add_overflow),.add_in(add_in)
    );
			
	reg next_done;
			
	reg [15:0] next_gcode0,next_exp_gcode0,i,next_i,exp,next_exp,frac,next_frac;
	
	reg [31:0] L_temp,next_L_temp;
	
	always@(posedge clock) begin
		if(reset)
			done = 'd0;
		else
			done = next_done;
	end
	
	always@(posedge clock) begin
		if(reset)
			gcode0 = 'd0;
		else
			gcode0 = next_gcode0;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp_gcode0 = 'd0;
		else
			exp_gcode0= next_exp_gcode0;
	end
	
	always@(posedge clock) begin
		if(reset)
			i = 'd0;
		else
			i = next_i;
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
			L_temp = 'd0;
		else
			L_temp = next_L_temp;
	end
	
	parameter INIT = 'd0;
	parameter state1 = 'd1;
	parameter state2 = 'd2;
	parameter state3 = 'd3;
	parameter state4 = 'd4;
	parameter state5 = 'd5;
	parameter state6 = 'd6;
	parameter state7 = 'd7;
	parameter state8 = 'd8;
	parameter donestate = 'd9;
	parameter state3_5 = 'd10;
	
	reg [3:0] currentstate,nextstate;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = INIT;
		else
			currentstate = nextstate;
	end
	
	always@(*) begin
		
		nextstate = currentstate;
		next_gcode0 = gcode0;
		next_exp_gcode0 = exp_gcode0;
		next_i = i;
		next_exp = exp;
		next_frac = frac;
		next_L_temp = L_temp;
		next_done = done;
		
		log2_in = 'd0;
		log2_start = 'd0;
		
		mpy_32_16_ina = 'd0;
		mpy_32_16_inb = 'd0;
		
		pow2_start = 'd0;
		pow2_exp = 'd0;
		pow2_frac = 'd0;
		
		L_shl_outa = 'd0;
		L_shl_outb = 'd0;
		L_shl_start = 'd0;
		
		L_shr_outa = 'd0;
		L_shr_outb = 'd0;
		
		norm_l_out = 'd0;
		norm_l_start = 'd0;
		
		sub_outa = 'd0;
		sub_outb = 'd0;
		
		mult_outa = 'd0;
		mult_outb = 'd0;
		
		L_mult_outa = 'd0;
		L_mult_outb = 'd0;
		
		L_msu_outa = 'd0;
		L_msu_outb = 'd0;
		L_msu_outc = 'd0;
		
		L_mac_outa = 'd0;
		L_mac_outb = 'd0;
		L_mac_outc = 'd0;
		
		add_outa = 'd0;
		add_outb = 'd0;
		
		constant_mem_read_addr = 'd0;
		
		scratch_mem_read_addr = 'd0;
		scratch_mem_write_addr = 'd0;
		scratch_mem_write_en = 'd0;
		scratch_mem_out = 'd0;
		
		case(currentstate)
		
			INIT: begin
				if(start)
					nextstate = state1;
				else
					nextstate = INIT;
			end
			
			//for(i=0;i<L_subfr;i++)
			state1: begin
				//Log2(L_tmp, &exp, &frac);
				if(i >= 40) begin
					next_i = 'd0;
					log2_in = L_temp;
					log2_start = 'd1;
					nextstate = state3;
				end
				//code[i]
				else begin
					scratch_mem_read_addr = {CODE[11:6],i[5:0]};
					nextstate = state2;
				end
			end
			
			//L_tmp = L_mac(L_tmp, code[i], code[i]);
			//i++
			state2: begin
				L_mac_outa = scratch_mem_in[15:0];
				L_mac_outb = scratch_mem_in[15:0];
				L_mac_outc = L_temp;
				next_L_temp = L_mac_in;
				add_outa = i;
				add_outb = 'd1;
				next_i = add_in;
				nextstate = state1;
			end
			
			//Log2(L_tmp, &exp, &frac);
			//L_tmp = Mpy_32_16(exp, frac, -24660);
			state3: begin
				if(log2_done == 'd1) begin
					next_exp = log2_exp;
					next_frac = log2_frac;
					mpy_32_16_ina = {log2_exp,log2_frac};
					mpy_32_16_inb = 16'h9FAC;
					L_mult_outa = mpy_32_16_L_mult_outa;
					L_mult_outb = mpy_32_16_L_mult_outb;
					L_mac_outa = mpy_32_16_L_mac_outa;
					L_mac_outb = mpy_32_16_L_mac_outb;
					mult_outa = mpy_32_16_mult_outa;
					mult_outb =	mpy_32_16_mult_outb;
					L_mac_outc = mpy_32_16_L_mac_outc;
					next_L_temp = mpy_32_16_out;
					nextstate = state3_5;
				end
				else begin
					log2_in = L_temp;
					L_shl_start = log2_L_shl_start;
					norm_l_start = log2_norm_l_start;
					constant_mem_read_addr = log2_constant_mem_read_addr;
					L_shl_outb = log2_L_shl_outb;
					L_shr_outb = log2_L_shr_outb;
					sub_outa = log2_sub_outa;
					sub_outb = log2_sub_outb;
					L_msu_outa = log2_L_msu_outa;
					L_msu_outb = log2_L_msu_outb;
					add_outa = log2_add_outa;
					add_outb = log2_add_outb;
					L_shl_outa = log2_L_shl_outa;
					L_shr_outa = log2_L_shr_outa;
					L_msu_outc = log2_L_msu_outc;
					norm_l_out = log2_norm_l_out;
					nextstate = state3;
				end
			end
			
			//L_tmp = L_mac(L_tmp, 32588, 32);
			//L_tmp = L_shl(L_tmp, 10);
			state3_5: begin
				L_mac_outa = 'd32588;
				L_mac_outb = 'd32;
				L_mac_outc = L_temp;
				L_shl_outa = L_mac_in;
				L_shl_outb = 'd10;
				L_shl_start = 'd1;
				nextstate = state4;
			end
			
			//L_tmp = L_shl(L_tmp, 10);
			state4: begin
				if(L_shl_done == 'd1) begin
					next_L_temp = L_shl_in;
					nextstate = state5;
				end
				else begin
					L_shl_outa = L_temp;
					L_shl_outb = 'd10;
					nextstate = state4;
				end
			end
			
			//for(i=0;i<4;i++);
			state5: begin
				//L_tmp = L_mult(*gcode0, 5439);
				//L_tmp = L_shr(L_tmp, 8);
				if(i >= 'd4) begin
					next_i = 'd0;
					next_gcode0 = L_temp[31:16];
					L_mult_outa = L_temp[31:16];
					L_mult_outb = 'd5439;
					L_shr_outa = L_mult_in;
					L_shr_outb = 'd8;
					next_L_temp = L_shr_in;
					nextstate = state7;
				end
				//past_qua_en[i]
				//pred[i]
				else begin
					scratch_mem_read_addr = {PAST_QUA_EN[11:2],i[1:0]};
					constant_mem_read_addr = {PRED[11:2],i[1:0]};
					nextstate = state6;
				end
			end
			
			//L_tmp = L_mac(L_tmp, pred[i], past_qua_en[i]);
			state6: begin
				L_mac_outa = constant_mem_in[15:0];
				L_mac_outb = scratch_mem_in[15:0];
				L_mac_outc = L_temp;
				next_L_temp = L_mac_in;
				add_outa = i;
				add_outb = 'd1;
				next_i = add_in;
				nextstate = state5;
			end
			
			//L_Extract(L_tmp, &exp, &frac);
			//Pow2(14, frac);
			state7: begin
				next_exp = L_temp[31:16];
				L_shr_outa = L_temp;
				L_shr_outb = 'd1;
				L_msu_outa = 16'd16384;
				L_msu_outb = L_temp[31:16];
				L_msu_outc = L_shr_in;
				next_frac = L_msu_in[15:0];
				pow2_frac = L_msu_in[15:0];
				pow2_exp = 'd14;
				pow2_start = 'd1;
				nextstate = state8;
			end
			
			state8: begin
				//*gcode0 = extract_l(Pow2(14,frac));
				//*exp_gcode0 = sub(14,exp);
				if(pow2_done == 'd1) begin
					next_gcode0 = pow2_result[15:0];
					sub_outa = 'd14;
					sub_outb = exp;
					next_exp_gcode0 = sub_in;
					next_done = 'd1;
					nextstate = donestate;
				end
				//Pow2(14,frac)
				else begin
					pow2_frac = frac;
					pow2_exp = 'd14;
					L_mult_outa = pow2_L_mult_outa;
					L_mult_outb = pow2_L_mult_outb;
					L_shr_outa = pow2_L_shr_outa;
					L_shr_outb = pow2_L_shr_outb;
					sub_outa = pow2_sub_outa;
					sub_outb = pow2_sub_outb;
					L_msu_outa = pow2_L_msu_outa;
					L_msu_outb = pow2_L_msu_outb;
					L_msu_outc = pow2_L_msu_outc;
					constant_mem_read_addr = pow2_constant_mem_read_addr;
					add_outa = pow2_add_outa;
					add_outb = pow2_add_outb;
					nextstate = state8;
				end
			end
			
			donestate: begin
				next_done = 'd0;
				next_exp = 'd0;
				next_frac = 'd0;
				next_L_temp = 'd0;
				next_i = 'd0;
				nextstate = INIT;
			end
				
		endcase
	end	
	
endmodule
