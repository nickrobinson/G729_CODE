`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    17:05:48 04/05/2011 
// Module Name:    Qua_gain 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T
// Tool versions:  Xilinx ISE 12.4
// Description: 
//
// Dependencies: 	 div_s.v
//						 mpy_32_16.v
//						 Gain_predict.v
//						 Gbk_presel.v
//						 Gain_update.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Qua_gain(clock,reset,start,done,out,tame_flag,
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
	 
	`include "paramList.v"
	`include "constants_param_list.v"
	 
	input clock,reset,start,tame_flag;
	output reg done;
	output reg [15:0] out;
	 
	input L_mac_overflow,L_msu_overflow,L_mult_overflow,L_add_overflow,L_sub_overflow,
			L_shr_overflow,mult_overflow,shl_overflow,add_overflow,sub_overflow,
			L_shl_done,norm_l_done,L_shl_overflow;
	output reg scratch_mem_write_en,L_shl_start,norm_l_start;
	
	output reg [11:0] scratch_mem_write_addr,scratch_mem_read_addr,constant_mem_read_addr;
	
	input [15:0] norm_l_in,mult_in,shl_in,add_in,sub_in,shr_in;
	output reg [15:0] L_mac_outa,L_mac_outb,L_msu_outa,L_msu_outb,L_mult_outa,L_mult_outb,
							L_shr_outb,L_shl_outb,mult_outa,mult_outb,shl_outa,shl_outb,add_outa,
							add_outb,sub_outa,sub_outb,shr_outa,shr_outb;

	input [31:0] L_mac_in,L_msu_in,L_mult_in,L_add_in,L_sub_in,L_shr_in,L_shl_in,
						scratch_mem_in,constant_mem_in,L_negate_in;
	output reg [31:0] L_mac_outc,L_msu_outc,L_add_outa,L_add_outb,L_sub_outa,L_sub_outb,
							L_shr_outa,L_shl_outa,norm_l_out,scratch_mem_out,L_negate_out;
						
	reg div_s_start;
	reg [15:0] div_s_ina,div_s_inb;
	wire [15:0] div_s_add_outa,div_s_add_outb;
	wire [31:0] div_s_sub_outa,div_s_sub_outb;
	
	wire div_s_div_err;
	wire [15:0] div_s_out;
					
	div_s i_div_s(
					.clock(clock),.reset(reset),.a(div_s_ina),.b(div_s_inb),.div_err(div_s_div_err),
					.out(div_s_out),.start(div_s_start),.done(div_s_done),.subouta(div_s_sub_outa),
					.suboutb(div_s_sub_outb),.subin(L_sub_in),.add_outa(div_s_add_outa),
					.add_outb(div_s_add_outb),.add_in(add_in));
	
	reg [15:0] mpy_32_16_inb;
	reg [31:0] mpy_32_16_ina;
	
	wire [15:0] mpy_32_16_L_mult_outa,mpy_32_16_L_mult_outb,mpy_32_16_L_mac_outa,mpy_32_16_L_mac_outb,
					mpy_32_16_mult_outa,mpy_32_16_mult_outb;
	wire [31:0] mpy_32_16_L_mac_outc;
	
	wire [31:0] mpy_32_16_out;
	
	mpy_32_16 i_mpy_32_16(.var1(mpy_32_16_ina),.var2(mpy_32_16_inb),.out(mpy_32_16_out),
					.L_mult_outa(mpy_32_16_L_mult_outa),.L_mult_outb(mpy_32_16_L_mult_outb),
					.L_mult_overflow(L_mult_overflow),.L_mult_in(L_mult_in),
					.L_mac_outa(mpy_32_16_L_mac_outa),.L_mac_outb(mpy_32_16_L_mac_outb),
					.L_mac_outc(mpy_32_16_L_mac_outc),.L_mac_overflow(L_mac_overflow),.L_mac_in(L_mac_in),
					.mult_outa(mpy_32_16_mult_outa),.mult_outb(mpy_32_16_mult_outb),.mult_in(mult_in),
					.mult_overflow(mult_overflow));
					
	reg gain_predict_start;
	wire gain_predict_L_shl_start,gain_predict_norm_l_start;
	wire [11:0] gain_predict_scratch_mem_write_addr,gain_predict_scratch_mem_read_addr,
					gain_predict_constant_mem_read_addr;
	wire [15:0] gain_predict_L_shl_outb,gain_predict_L_shr_outb,gain_predict_sub_outa,gain_predict_sub_outb,
					gain_predict_L_msu_outa,gain_predict_L_msu_outb,gain_predict_add_outa,gain_predict_add_outb,
					gain_predict_L_mac_outa,gain_predict_L_mac_outb,gain_predict_L_mult_outa,gain_predict_L_mult_outb,
					gain_predict_mult_outa,gain_predict_mult_outb;
	wire [31:0] gain_predict_scratch_mem_out,gain_predict_L_shl_outa,gain_predict_L_shr_outa,gain_predict_norm_l_out,
					gain_predict_L_msu_outc,gain_predict_L_mac_outc;
					
	
	wire gain_predict_done;
	wire [15:0] gain_predict_gcode0,gain_predict_exp_gcode0;
	
	Gain_predict i_Gain_predict_1(
			.clock(clock),.reset(reset),.start(gain_predict_start),.done(gain_predict_done),
			.gcode0(gain_predict_gcode0),.exp_gcode0(gain_predict_exp_gcode0),
			.scratch_mem_read_addr(gain_predict_scratch_mem_read_addr),
			.scratch_mem_write_addr(gain_predict_scratch_mem_write_addr),
			.scratch_mem_write_en(gain_predict_scratch_mem_write_en),.scratch_mem_in(scratch_mem_in),
			.scratch_mem_out(gain_predict_scratch_mem_out),
			.constant_mem_read_addr(gain_predict_constant_mem_read_addr),
			.constant_mem_in(constant_mem_in),
			.L_shl_outa(gain_predict_L_shl_outa),.L_shl_outb(gain_predict_L_shl_outb),
			.L_shl_start(gain_predict_L_shl_start),.L_shl_done(L_shl_done),.L_shl_in(L_shl_in),
			.L_shl_overflow(L_shl_overflow),
			.L_shr_outa(gain_predict_L_shr_outa),.L_shr_outb(gain_predict_L_shr_outb),.L_shr_in(L_shr_in),
			.L_shr_overflow(L_shr_overflow),
			.norm_l_out(gain_predict_norm_l_out),.norm_l_start(gain_predict_norm_l_start),.norm_l_done(norm_l_done),
			.norm_l_in(norm_l_in),
			.sub_outa(gain_predict_sub_outa),.sub_outb(gain_predict_sub_outb),.sub_overflow(sub_overflow),.sub_in(sub_in),
			.L_msu_outa(gain_predict_L_msu_outa),.L_msu_outb(gain_predict_L_msu_outb),.L_msu_outc(gain_predict_L_msu_outc),
			.L_msu_overflow(L_msu_overflow),.L_msu_in(L_msu_in),
			.add_outa(gain_predict_add_outa),.add_outb(gain_predict_add_outb),.add_overflow(add_overflow),.add_in(add_in),
			.L_mac_outa(gain_predict_L_mac_outa),.L_mac_outb(gain_predict_L_mac_outb),.L_mac_outc(gain_predict_L_mac_outc),
			.L_mac_in(L_mac_in),.L_mac_overflow(L_mac_overflow),
			.L_mult_outa(gain_predict_L_mult_outa),.L_mult_outb(gain_predict_L_mult_outb),.L_mult_overflow(L_mult_overflow),
			.L_mult_in(L_mult_in),
			.mult_outa(gain_predict_mult_outa),.mult_outb(gain_predict_mult_outb),.mult_overflow(mult_overflow),
			.mult_in(mult_in)
    );
	 
	reg gbk_presel_start;
	reg [15:0] gbk_presel_gcode0;
	wire gbk_presel_done;
	wire [15:0]  gbk_presel_cand1,gbk_presel_cand2;
	
	wire gbk_presel_scratch_mem_write_en,gbk_presel_L_shl_start;
	wire [11:0] gbk_presel_scratch_mem_read_addr,gbk_presel_scratch_mem_write_addr,gbk_presel_constant_mem_read_addr;
	wire [15:0] gbk_presel_L_mult_outa,gbk_presel_L_mult_outb,gbk_presel_L_shr_outb,gbk_presel_L_shl_outb,gbk_presel_mult_outa,gbk_presel_mult_outb,
					gbk_presel_add_outa,gbk_presel_add_outb,gbk_presel_sub_outa,gbk_presel_sub_outb;
	wire [31:0] gbk_presel_scratch_mem_out,gbk_presel_L_shr_outa,gbk_presel_L_add_outa,gbk_presel_L_add_outb,gbk_presel_L_shl_outa,
					gbk_presel_L_sub_outa,gbk_presel_L_sub_outb;
	 
	Gbk_presel i_Gbk_presel(
					.clock(clock),.reset(reset),.start(gbk_presel_start),.done(gbk_presel_done),
					.cand1(gbk_presel_cand1),.cand2(gbk_presel_cand2),.gcode0(gbk_presel_gcode0),
					.constant_mem_read_addr(gbk_presel_constant_mem_read_addr),.constant_mem_in(constant_mem_in),
					.scratch_mem_read_addr(gbk_presel_scratch_mem_read_addr),.scratch_mem_in(scratch_mem_in),
						.scratch_mem_write_addr(gbk_presel_scratch_mem_write_addr),.scratch_mem_write_en(gbk_presel_scratch_mem_write_en),
						.scratch_mem_out(gbk_presel_scratch_mem_out),
					.L_mult_outa(gbk_presel_L_mult_outa),.L_mult_outb(gbk_presel_L_mult_outb),.L_mult_in(L_mult_in),.L_mult_overflow(L_mult_overflow),
					.L_shr_outa(gbk_presel_L_shr_outa),.L_shr_outb(gbk_presel_L_shr_outb),.L_shr_overflow(L_shr_overflow),.L_shr_in(L_shr_in),
					.L_add_outa(gbk_presel_L_add_outa),.L_add_outb(gbk_presel_L_add_outb),.L_add_in(L_add_in),.L_add_overflow(L_add_overflow),
					.L_shl_outa(gbk_presel_L_shl_outa),.L_shl_outb(gbk_presel_L_shl_outb),.L_shl_start(gbk_presel_L_shl_start),.L_shl_done(L_shl_done),
						.L_shl_in(L_shl_in),.L_shl_overflow(L_shl_overflow),
					.L_sub_outa(gbk_presel_L_sub_outa),.L_sub_outb(gbk_presel_L_sub_outb),.L_sub_in(L_sub_in),.L_sub_overflow(L_sub_overflow),
					.mult_outa(gbk_presel_mult_outa),.mult_outb(gbk_presel_mult_outb),.mult_in(mult_in),.mult_overflow(mult_overflow),
					.add_outa(gbk_presel_add_outa),.add_outb(gbk_presel_add_outb),.add_in(add_in),.add_overflow(add_overflow),
					.sub_outa(gbk_presel_sub_outa),.sub_outb(gbk_presel_sub_outb),.sub_in(sub_in),.sub_overflow(sub_overflow)
    );
	 
	reg gain_update_start;
	reg [31:0] gain_update_L_gbk12;
	wire gain_update_done;
	
	wire gain_update_scratch_mem_write_en,gain_update_L_shl_start,gain_update_norm_l_start;
	wire[11:0] gain_update_scratch_mem_read_addr,gain_update_scratch_mem_write_addr,gain_update_constant_mem_read_addr;
	wire [15:0] gain_update_add_outa,gain_update_add_outb,gain_update_sub_outa,gain_update_sub_outb,gain_update_L_shl_outb,
					gain_update_mult_outa,gain_update_mult_outb,gain_update_L_shr_outb,gain_update_L_msu_outa,gain_update_L_msu_outb,
					gain_update_L_mac_outa,gain_update_L_mac_outb;
	wire [31:0] gain_update_L_shl_outa,gain_update_L_shr_outa,gain_update_L_msu_outc,gain_update_norm_l_out,gain_update_L_mac_outc,
					gain_update_scratch_mem_out;
	 
	Gain_update i_Gain_update(
					.clock(clock),.reset(reset),.start(gain_update_start),.done(gain_update_done),
					.L_gbk12(gain_update_L_gbk12),
					.scratch_mem_read_addr(gain_update_scratch_mem_read_addr),.scratch_mem_write_addr(gain_update_scratch_mem_write_addr),
						.scratch_mem_out(gain_update_scratch_mem_out),.scratch_mem_write_en(gain_update_scratch_mem_write_en),
						.scratch_mem_in(scratch_mem_in),
					.add_outa(gain_update_add_outa),.add_outb(gain_update_add_outb),.add_in(add_in),.add_overflow(add_overflow),
					.sub_outa(gain_update_sub_outa),.sub_outb(gain_update_sub_outb),.sub_in(sub_in),.sub_overflow(sub_overflow),
					.L_shl_start(gain_update_L_shl_start),.L_shl_outa(gain_update_L_shl_outa),.L_shl_outb(gain_update_L_shl_outb),
						.L_shl_overflow(L_shl_overflow),.L_shl_in(L_shl_in),.L_shl_done(L_shl_done),
					.mult_outa(gain_update_mult_outa),.mult_outb(gain_update_mult_outb),.mult_in(mult_in),.mult_overflow(mult_overflow),
					.L_shr_outa(gain_update_L_shr_outa),.L_shr_outb(gain_update_L_shr_outb),.L_shr_overflow(L_shr_overflow),.L_shr_in(L_shr_in),
					.L_msu_outa(gain_update_L_msu_outa),.L_msu_outb(gain_update_L_msu_outb),.L_msu_outc(gain_update_L_msu_outc),
						.L_msu_overflow(L_msu_overflow),.L_msu_in(L_msu_in),
					.norm_l_out(gain_update_norm_l_out),.norm_l_start(gain_update_norm_l_start),.norm_l_in(norm_l_in),.norm_l_done(norm_l_done),
					.constant_mem_read_addr(gain_update_constant_mem_read_addr),.constant_mem_in(constant_mem_in),
					.L_mac_outa(gain_update_L_mac_outa),.L_mac_outb(gain_update_L_mac_outb),.L_mac_outc(gain_update_L_mac_outc),
						.L_mac_overflow(L_mac_overflow),.L_mac_in(L_mac_in)
    );
	 
	reg next_done;
	reg [15:0] next_out,gain_pit,gain_cod,next_gain_pit,next_gain_cod;
	reg [15:0] i,next_i,j,next_j,index1,next_index1,index2,next_index2,cand1,next_cand1,cand2,next_cand2,exp,next_exp,gcode0,next_gcode0,
					exp_gcode0,next_exp_gcode0,gcode0_org,next_gcode0_org,e_min,next_e_min,nume,next_nume,denom,next_denom,inv_denom,
					next_inv_denom,exp_inv_denom,next_exp_inv_denom,sft,next_sft,temp,next_temp,g_pitch,next_g_pitch,g2_pitch,next_g2_pitch,
					g_code,next_g_code,g2_code,next_g2_code,g_pit_cod,next_g_pit_cod,exp1,next_exp1,exp2,next_exp2,exp_nume,next_exp_nume,
					exp_denom,next_exp_denom;
	reg [31:0] L_gbk12,next_L_gbk12,L_temp,next_L_temp,L_dist_min,next_L_dist_min,L_tmp,next_L_tmp,L_tmp1,next_L_tmp1,L_tmp2,next_L_tmp2,
					L_acc,next_L_acc,L_accb,next_L_accb;
					
	reg [15:0] coeff0,next_coeff0,coeff1,next_coeff1,coeff2,next_coeff2,coeff3,next_coeff3,coeff4,next_coeff4;
	
	reg [15:0] coeff_lsf0,next_coeff_lsf0,coeff_lsf1,next_coeff_lsf1,coeff_lsf2,next_coeff_lsf2,coeff_lsf3,next_coeff_lsf3,coeff_lsf4,
					next_coeff_lsf4;
	
	reg [15:0] exp_min0,next_exp_min0,exp_min1,next_exp_min1,exp_min2,next_exp_min2,exp_min3,next_exp_min3,exp_min4,next_exp_min4;

	reg [15:0] temp16,next_temp16;

	reg [31:0] temp32,next_temp32;
	
	reg [15:0] temp_g_coeff0,next_temp_g_coeff0,temp_g_coeff1,next_temp_g_coeff1,temp_g_coeff2,next_temp_g_coeff2,temp_g_coeff3,
					next_temp_g_coeff3,temp_g_coeff4,next_temp_g_coeff4;
					
	reg [15:0] temp_exp_g_coeff0,next_temp_exp_g_coeff0,temp_exp_g_coeff1,next_temp_exp_g_coeff1,temp_exp_g_coeff2,next_temp_exp_g_coeff2,
					temp_exp_g_coeff3,next_temp_exp_g_coeff3,temp_exp_g_coeff4,next_temp_exp_g_coeff4;

	always@(posedge clock) begin
		if(reset)
			done = 'd0;
		else
			done = next_done;
	end
	
	always@(posedge clock) begin
		if(reset)
			out = 'd0;
		else
			out = next_out;
	end
	
	always@(posedge clock) begin
		if(reset)
			gain_pit = 'd0;
		else
			gain_pit = next_gain_pit;
	end
	
	always@(posedge clock) begin
		if(reset)
			gain_cod = 'd0;
		else
			gain_cod = next_gain_cod;
	end
	
	always@(posedge clock) begin
		if(reset)
			i = 'd0;
		else
			i = next_i;
	end
	
	always@(posedge clock) begin
		if(reset)
			j = 'd0;
		else
			j = next_j;
	end
	
	always@(posedge clock) begin
		if(reset)
			index1 = 'd0;
		else
			index1 = next_index1;
	end
	
	always@(posedge clock) begin
		if(reset)
			index2 = 'd0;
		else
			index2 = next_index2;
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
			exp = 'd0;
		else
			exp = next_exp;
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
			exp_gcode0 = next_exp_gcode0;
	end
	
	always@(posedge clock) begin
		if(reset)
			gcode0_org = 'd0;
		else
			gcode0_org = next_gcode0_org;
	end
	
	always@(posedge clock) begin
		if(reset)
			e_min = 'd0;
		else
			e_min = next_e_min;
	end
	
	always@(posedge clock) begin
		if(reset)
			nume = 'd0;
		else
			nume = next_nume;
	end
	
	always@(posedge clock) begin
		if(reset)
			denom = 'd0;
		else
			denom = next_denom;
	end
	
	always@(posedge clock) begin
		if(reset)
			inv_denom = 'd0;
		else
			inv_denom = next_inv_denom;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp1 = 'd0;
		else
			exp1 = next_exp1;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp2 = 'd0;
		else
			exp2 = next_exp2;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp_nume = 'd0;
		else
			exp_nume = next_exp_nume;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp_denom = 'd0;
		else
			exp_denom = next_exp_denom;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp_inv_denom = 'd0;
		else
			exp_inv_denom = next_exp_inv_denom;
	end
	
	always@(posedge clock) begin
		if(reset)
			sft = 'd0;
		else
			sft = next_sft;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp = 'd0;
		else
			temp = next_temp;
	end
	
	always@(posedge clock) begin
		if(reset)
			g_pitch = 'd0;
		else
			g_pitch = next_g_pitch;
	end
	
	always@(posedge clock) begin
		if(reset)
			g2_pitch = 'd0;
		else
			g2_pitch = next_g2_pitch;
	end
	
	always@(posedge clock) begin
		if(reset)
			g_code = 'd0;
		else
			g_code = next_g_code;
	end
	
	always@(posedge clock) begin
		if(reset)
			g2_code = 'd0;
		else
			g2_code = next_g2_code;
	end
	
	always@(posedge clock) begin
		if(reset)
			g_pit_cod = 'd0;
		else
			g_pit_cod = next_g_pit_cod;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_gbk12 = 'd0;
		else
			L_gbk12 = next_L_gbk12;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_temp = 'd0;
		else
			L_temp = next_L_temp;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_dist_min = 'd0;
		else
			L_dist_min = next_L_dist_min;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_tmp = 'd0;
		else
			L_tmp = next_L_tmp;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_tmp1 = 'd0;
		else
			L_tmp1 = next_L_tmp1;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_tmp2 = 'd0;
		else
			L_tmp2 = next_L_tmp2;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_acc = 'd0;
		else
			L_acc = next_L_acc;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_accb = 'd0;
		else
			L_accb = next_L_accb;
	end
	
	always@(posedge clock) begin
		if(reset)
			coeff0 = 'd0;
		else
			coeff0 = next_coeff0;
	end
	
	always@(posedge clock) begin
		if(reset)
			coeff1 = 'd0;
		else
			coeff1 = next_coeff1;
	end
	
	always@(posedge clock) begin
		if(reset)
			coeff2 = 'd0;
		else
			coeff2 = next_coeff2;
	end
	
	always@(posedge clock) begin
		if(reset)
			coeff3 = 'd0;
		else
			coeff3 = next_coeff3;
	end
	
	always@(posedge clock) begin
		if(reset)
			coeff4 = 'd0;
		else
			coeff4 = next_coeff4;
	end
	
	always@(posedge clock) begin
		if(reset)
			coeff_lsf0 = 'd0;
		else
			coeff_lsf0 = next_coeff_lsf0;
	end
	
	always@(posedge clock) begin
		if(reset)
			coeff_lsf1 = 'd0;
		else
			coeff_lsf1 = next_coeff_lsf1;
	end
	
	always@(posedge clock) begin
		if(reset)
			coeff_lsf2 = 'd0;
		else
			coeff_lsf2 = next_coeff_lsf2;
	end
	
	always@(posedge clock) begin
		if(reset)
			coeff_lsf3 = 'd0;
		else
			coeff_lsf3 = next_coeff_lsf3;
	end
	
	always@(posedge clock) begin
		if(reset)
			coeff_lsf4 = 'd0;
		else
			coeff_lsf4 = next_coeff_lsf4;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp_min0 = 'd0;
		else
			exp_min0 = next_exp_min0;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp_min1 = 'd0;
		else
			exp_min1 = next_exp_min1;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp_min2 = 'd0;
		else
			exp_min2 = next_exp_min2;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp_min3 = 'd0;
		else
			exp_min3 = next_exp_min3;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp_min4 = 'd0;
		else
			exp_min4 = next_exp_min4;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp16 = 'd0;
		else
			temp16 = next_temp16;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp32 = 'd0;
		else
			temp32 = next_temp32;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_g_coeff0 = 'd0;
		else
			temp_g_coeff0 = next_temp_g_coeff0;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_g_coeff1 = 'd0;
		else
			temp_g_coeff1 = next_temp_g_coeff1;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_g_coeff2 = 'd0;
		else
			temp_g_coeff2 = next_temp_g_coeff2;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_g_coeff3 = 'd0;
		else
			temp_g_coeff3 = next_temp_g_coeff3;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_g_coeff4 = 'd0;
		else
			temp_g_coeff4 = next_temp_g_coeff4;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_exp_g_coeff0 = 'd0;
		else
			temp_exp_g_coeff0 = next_temp_exp_g_coeff0;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_exp_g_coeff1 = 'd0;
		else
			temp_exp_g_coeff1 = next_temp_exp_g_coeff1;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_exp_g_coeff2 = 'd0;
		else
			temp_exp_g_coeff2 = next_temp_exp_g_coeff2;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_exp_g_coeff3 = 'd0;
		else
			temp_exp_g_coeff3 = next_temp_exp_g_coeff3;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_exp_g_coeff4 = 'd0;
		else
			temp_exp_g_coeff4 = next_temp_exp_g_coeff4;
	end
	
	parameter INIT = 7'd0;
	parameter state1 = 7'd1;
	parameter state2 = 7'd2;
	parameter state3 = 7'd3;
	parameter state4 = 7'd4;
	parameter state5 = 7'd5;
	parameter state6 = 7'd6;
	parameter state7 = 7'd7;
	parameter state8 = 7'd8;
	parameter state9 = 7'd9;
	parameter state10 = 7'd10;
	parameter state11 = 7'd11;
	parameter state12 = 7'd12;
	parameter state13 = 7'd13;
	parameter state14 = 7'd14;
	parameter state15 = 7'd15;
	parameter state16 = 7'd16;
	parameter state17 = 7'd17;
	parameter state18 = 7'd18;
	parameter state19 = 7'd19;
	parameter state20 = 7'd20;
	parameter state21 = 7'd21;
	parameter state22 = 7'd22;
	parameter state23 = 7'd23;
	parameter state24 = 7'd24;
	parameter state25 = 7'd25;
	parameter state26 = 7'd26;
	parameter state27 = 7'd27;
	parameter state28 = 7'd28;
	parameter state29 = 7'd29;
	parameter state30 = 7'd30;
	parameter state31 = 7'd31;
	parameter state32 = 7'd32;
	parameter state33 = 7'd33;
	parameter state34 = 7'd34;
	parameter state35 = 7'd35;
	parameter state36 = 7'd36;
	parameter state37 = 7'd37;
	parameter state38 = 7'd38;
	parameter state39 = 7'd39;
	parameter state40 = 7'd40;
	parameter state41 = 7'd41;
	parameter state42 = 7'd42;
	parameter state43 = 7'd43;
	parameter state44 = 7'd44;
	parameter state45 = 7'd45;
	parameter state46 = 7'd46;
	parameter state47 = 7'd47;
	parameter state48 = 7'd48;
	parameter state49 = 7'd49;
	parameter state50 = 7'd50;
	parameter state51 = 7'd51;
	parameter state52 = 7'd52;
	parameter state53 = 7'd53;
	parameter state54 = 7'd54;
	parameter state55 = 7'd55;
	parameter state56 = 7'd56;
	parameter state57 = 7'd57;
	parameter state58 = 7'd58;
	parameter state59 = 7'd59;
	parameter state60 = 7'd60;
	parameter state61 = 7'd61;
	parameter state62 = 7'd62;
	parameter state63 = 7'd63;
	parameter state64 = 7'd64;
	parameter state65 = 7'd65;
	parameter state66 = 7'd66;
	parameter state67 = 7'd67;
	parameter state68 = 7'd68;
	parameter state69 = 7'd69;
	parameter state70 = 7'd70;
	parameter state71 = 7'd71;
	parameter state72 = 7'd72;
	parameter state73 = 7'd73;
	parameter state74 = 7'd74;
	parameter state75 = 7'd75;
	parameter state76 = 7'd76;
	parameter state77 = 7'd77;
	parameter state78 = 7'd78;
	parameter state79 = 7'd79;
	parameter state80 = 7'd80;
	parameter state81 = 7'd81;
	parameter state82 = 7'd82;
	parameter state83 = 7'd83;
	parameter state84 = 7'd84;
	parameter state85 = 7'd85;
	parameter state86 = 7'd86;
	parameter state87 = 7'd87;
	parameter state88 = 7'd88;
	parameter done_state = 7'd89;
	parameter state_pre17 = 7'd90;
	parameter state_pre24 = 7'd91;
	parameter state_pre9_1 = 7'd92;
	parameter state_pre9_2 = 7'd93;
	
	reg [6:0] currentstate,nextstate;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = INIT;
		else
			currentstate = nextstate;
	end
	
	always@(*)begin
		next_done = done;
		next_out = out;
		next_gain_pit = gain_pit;
		next_gain_cod = gain_cod;
		next_i = i;
		next_j = j;
		next_index1 = index1;
		next_index2 = index2;
		next_cand1 = cand1;
		next_cand2 = cand2;
		next_exp = exp;
		next_gcode0 = gcode0;
		next_exp_gcode0 = exp_gcode0;
		next_gcode0_org = gcode0_org;
		next_e_min = e_min;
		next_nume = nume;
		next_denom = denom;
		next_inv_denom = inv_denom;
		next_exp_inv_denom = exp_inv_denom;
		next_sft = sft;
		next_temp = temp;
		next_g_pitch = g_pitch;
		next_g2_pitch = g2_pitch;
		next_g_code = g_code;
		next_g2_code = g2_code;
		next_g_pit_cod = g_pit_cod;
		next_exp1 = exp1;
		next_exp2 = exp2;
		next_exp_nume = exp_nume;
		next_exp_denom = exp_denom;
		next_L_gbk12 =L_gbk12;
		next_L_temp = L_temp;
		next_L_dist_min = L_dist_min;
		next_L_tmp = L_tmp;
		next_L_tmp1 = L_tmp1;
		next_L_tmp2 = L_tmp2;
		next_L_acc = L_acc;
		next_L_accb = L_accb;
					
		next_coeff0 = coeff0;
		next_coeff1 = coeff1;
		next_coeff2 = coeff2;
		next_coeff3 = coeff3;
		next_coeff4 = coeff4;
	
		next_coeff_lsf0 = coeff_lsf0;
		next_coeff_lsf1 = coeff_lsf1;
		next_coeff_lsf2 = coeff_lsf2;
		next_coeff_lsf3 = coeff_lsf3;
		next_coeff_lsf4 = coeff_lsf4;
	
		next_exp_min0 = exp_min0;
		next_exp_min1 = exp_min1;
		next_exp_min2 = exp_min2;
		next_exp_min3 = exp_min3;
		next_exp_min4 = exp_min4;
		
		next_temp32 = temp32;
		next_temp16 = temp16;
		
		next_temp_g_coeff0 = temp_g_coeff0;
		next_temp_g_coeff1 = temp_g_coeff1;
		next_temp_g_coeff2 = temp_g_coeff2;
		next_temp_g_coeff3 = temp_g_coeff3;
		next_temp_g_coeff4 = temp_g_coeff4;
		
		next_temp_exp_g_coeff0 = temp_exp_g_coeff0;
		next_temp_exp_g_coeff1 = temp_exp_g_coeff1;
		next_temp_exp_g_coeff2 = temp_exp_g_coeff2;
		next_temp_exp_g_coeff3 = temp_exp_g_coeff3;
		next_temp_exp_g_coeff4 = temp_exp_g_coeff4;
		
		
	 
		scratch_mem_write_en = 'd0;
		L_shl_start = 'd0;
		norm_l_start = 'd0;
	
		scratch_mem_write_addr = 'd0;
		scratch_mem_read_addr = 'd0;
		constant_mem_read_addr = 'd0;
	
		L_mac_outa = 'd0;
		L_mac_outb = 'd0;
		L_msu_outa = 'd0;
		L_msu_outb = 'd0;
		L_mult_outa = 'd0;
		L_mult_outb = 'd0;
		L_shr_outb = 'd0;
		L_shl_outb = 'd0;
		mult_outa = 'd0;
		mult_outb = 'd0;
		shl_outa = 'd0;
		shl_outb = 'd0;
		add_outa = 'd0;
		add_outb = 'd0;
		sub_outa = 'd0;
		sub_outb = 'd0;
		shr_outa = 'd0;
		shr_outb = 'd0;
		L_negate_out = 'd0;

		L_mac_outc = 'd0;
		L_msu_outc = 'd0;
		L_add_outa = 'd0;
		L_add_outb = 'd0;
		L_sub_outa = 'd0;
		L_sub_outb = 'd0;
		L_shr_outa = 'd0;
		L_shl_outa = 'd0;
		norm_l_out = 'd0;
		scratch_mem_out = 'd0;
						
		div_s_start = 'd0;
		div_s_ina = 'd0;
		div_s_inb = 'd0;
		
		mpy_32_16_inb = 'd0;
		mpy_32_16_ina = 'd0;

		gain_predict_start = 'd0;
					
		gbk_presel_start = 'd0;
		gbk_presel_gcode0 = 'd0;
	
		gain_update_start = 'd0;
		gain_update_L_gbk12 = 'd0;

		case(currentstate)
			
			INIT: begin
				if(start)
					nextstate = state1;
				else
					nextstate = INIT;
			end
			
			state1: begin
				gain_predict_start = 'd1;
				nextstate = state2;
			end
			
			state2: begin
				if(gain_predict_done == 'd1) begin
					next_gcode0 = gain_predict_gcode0;
					next_exp_gcode0 = gain_predict_exp_gcode0;
					scratch_mem_read_addr = {G_COEFF_CS[11:2],2'd0};
					nextstate = state3;
				end
				else begin
					L_shl_start = gain_predict_L_shl_start;
					norm_l_start = gain_predict_norm_l_start;
					scratch_mem_write_addr = gain_predict_scratch_mem_write_addr;
					scratch_mem_read_addr = gain_predict_scratch_mem_read_addr;
					constant_mem_read_addr = gain_predict_constant_mem_read_addr;
					L_shl_outb = gain_predict_L_shl_outb;
					L_shr_outb = gain_predict_L_shr_outb;
					sub_outa = gain_predict_sub_outa;
					sub_outb = gain_predict_sub_outb;
					L_msu_outa = gain_predict_L_msu_outa;
					L_msu_outb = gain_predict_L_msu_outb;
					add_outa = gain_predict_add_outa;
					add_outb = gain_predict_add_outb;
					L_mac_outa = gain_predict_L_mac_outa;
					L_mac_outb = gain_predict_L_mac_outb;
					L_mult_outa = gain_predict_L_mult_outa;
					L_mult_outb = gain_predict_L_mult_outb;
					mult_outa = gain_predict_mult_outa;
					mult_outb = gain_predict_mult_outb;
					scratch_mem_out = gain_predict_scratch_mem_out;
					L_shl_outa = gain_predict_L_shl_outa;
					L_shr_outa = gain_predict_L_shr_outa;
					norm_l_out = gain_predict_norm_l_out;
					L_msu_outc = gain_predict_L_msu_outc;
					L_mac_outc = gain_predict_L_mac_outc;
					nextstate = state2;
				end
			end
			
			state3: begin
				next_temp_g_coeff0 = scratch_mem_in[15:0];
				scratch_mem_read_addr = {G_COEFF_CS[11:3],3'd2};
				nextstate = state4;
			end
			
			state4: begin
				next_temp_g_coeff2 = scratch_mem_in[15:0];
				L_mult_outa = temp_g_coeff0;
				L_mult_outb = scratch_mem_in[15:0];
				next_L_tmp1 = L_mult_in;
				scratch_mem_read_addr = {EXP_G_COEFF_CS[11:3],3'd0};
				nextstate = state5;
			end
			
			state5: begin
				scratch_mem_read_addr = {EXP_G_COEFF_CS[11:3],3'd2};
				next_temp_exp_g_coeff0 = scratch_mem_in[15:0];
				nextstate = state6;
			end
			
			state6: begin
				next_temp_exp_g_coeff2 = scratch_mem_in[15:0];
				add_outa = temp_exp_g_coeff0;
				add_outb = scratch_mem_in[15:0];
				next_exp1 = add_in;
				scratch_mem_read_addr = {G_COEFF_CS[11:3],3'd4};
				nextstate = state7;
			end
			
			state7: begin
				next_temp_g_coeff4 = scratch_mem_in[15:0];
				add_outa = exp1;
				add_outb = 16'hFFFF;
				next_exp1 = add_in;
				L_mult_outa = scratch_mem_in[15:0];
				L_mult_outb = scratch_mem_in[15:0];
				next_L_tmp2 = L_mult_in;
				scratch_mem_read_addr = {EXP_G_COEFF_CS[11:3],3'd4};
				nextstate = state8;
			end
			
			state8: begin
				next_temp_exp_g_coeff4 = scratch_mem_in[15:0];
				add_outa = scratch_mem_in[15:0];
				add_outb = scratch_mem_in[15:0];
				L_add_outa = {16'd0,add_in};
				L_add_outb = 'd1;
				next_exp2 = L_add_in[15:0];
				sub_outa = exp1;
				sub_outb = L_add_in[15:0];
				if(sub_in[15] != 1'd1 && sub_in != 'd0) begin
					nextstate = state_pre9_1;
				end
				else begin
					nextstate = state_pre9_2;
				end
			end
			
			state_pre9_1: begin
				sub_outa = exp1;
				sub_outb = exp2;
				L_shr_outa = L_tmp1;
				L_shr_outb = sub_in;
				L_sub_outa = L_shr_in;
				L_sub_outb = L_tmp2;
				next_L_tmp = L_sub_in;
				next_exp = exp2;
				norm_l_out = L_sub_in;
				norm_l_start = 'd1;
				nextstate = state9;
			end
			
			state_pre9_2: begin
				sub_outa = exp2;
				sub_outb = exp1;
				L_shr_outa = L_tmp2;
				L_shr_outb = sub_in;
				L_sub_outa = L_tmp1;
				L_sub_outb = L_shr_in;
				next_L_tmp = L_sub_in;
				next_exp = exp1;
				norm_l_out = L_sub_in;
				norm_l_start = 'd1;
				nextstate = state9;
			end
			
			state9: begin
				if(norm_l_done == 'd1) begin
					next_sft = norm_l_in;
					L_shl_outa = L_tmp;
					L_shl_outb = norm_l_in;
					L_shl_start = 'd1;
					nextstate = state10;
				end
				else begin
					norm_l_out = L_tmp;
					nextstate = state9;
				end
			end
			
			state10: begin
				if(L_shl_done == 'd1) begin
					next_denom = L_shl_in[31:16];
					add_outa = exp;
					add_outb = sft;
					sub_outa = add_in;
					sub_outb = 'd16;
					next_exp_denom = sub_in;
					div_s_ina = 'd16384;
					div_s_inb = L_shl_in[31:16];
					div_s_start = 'd1;
					nextstate = state11;
				end
				else begin
					L_shl_outa = L_tmp;
					L_shl_outb = sft;
					nextstate = state10;
				end
			end
			
			state11: begin
				if(div_s_done == 'd1) begin
					L_negate_out = {16'd0,div_s_out};
					next_inv_denom = L_negate_in[15:0];
					sub_outa = 'd29;
					sub_outb = exp_denom;
					next_exp_inv_denom = sub_in;
					scratch_mem_read_addr = {G_COEFF_CS[11:3],3'd1};
					nextstate = state12;
				end
				else begin
					div_s_ina = 'd16384;
					div_s_inb = denom;
					L_sub_outa = div_s_sub_outa;
					L_sub_outb = div_s_sub_outb;
					add_outa = div_s_add_outa;
					add_outb = div_s_add_outb;
					nextstate = state11;
				end
			end
			
			state12: begin
				next_temp_g_coeff1 = scratch_mem_in[15:0];
				scratch_mem_read_addr = {EXP_G_COEFF_CS[11:3],3'd1};
				L_mult_outa = temp_g_coeff2;
				L_mult_outb = scratch_mem_in[15:0];
				next_L_tmp1 = L_mult_in;
				nextstate = state13;
			end
			
			state13: begin
				next_temp_exp_g_coeff1 = scratch_mem_in[15:0];
				scratch_mem_read_addr = {G_COEFF_CS[11:3],3'd3};
				add_outa = temp_exp_g_coeff2;
				add_outb = scratch_mem_in[15:0];
				next_exp1 = add_in;
				nextstate = state14;
			end
			
			state14: begin
				next_temp_g_coeff3 = scratch_mem_in[15:0];
				scratch_mem_read_addr = {EXP_G_COEFF_CS[11:3],3'd3};
				L_mult_outa = scratch_mem_in[15:0];
				L_mult_outb = temp_g_coeff4;
				next_L_tmp2 = L_mult_in;
				nextstate = state15;
			end
			
			state15: begin
				next_temp_exp_g_coeff3 = scratch_mem_in[15:0];
				add_outa = scratch_mem_in[15:0];
				add_outb = temp_exp_g_coeff4;
				L_add_outa = {16'd0,add_in};
				L_add_outb = 'd1;
				next_exp2 = L_add_in[15:0];
				sub_outa = exp1;
				sub_outb = L_add_in[15:0];
				next_temp16 = sub_in;
				if(sub_in[15] != 1'd1 && sub_in != 'd0) begin
					L_shr_outa = L_tmp2;
					L_shr_outb = 'd1;
					next_temp32 = L_shr_in;
					nextstate = state16;
				end
				else begin
					L_shr_outa = L_tmp1;
					L_shr_outb = 'd1;
					next_temp32 = L_shr_in;
					nextstate = state_pre17;
				end
			end
			
			state16: begin 
				add_outa = temp16;
				add_outb = 'd1;
				L_shr_outa = L_tmp1;
				L_shr_outb = add_in;
				L_sub_outa = L_shr_in;
				L_sub_outb = temp32;
				next_L_tmp = L_sub_in;
				sub_outa = exp2;
				sub_outb = 'd1;
				next_exp = sub_in;
				norm_l_out = L_sub_in;
				norm_l_start = 'd1;
				nextstate = state18;
			end
			
			state_pre17: begin
				sub_outa = exp2;
				sub_outb = exp1;
				next_temp16 = sub_in;
				nextstate = state17;
			end
			
			state17: begin
				add_outa = temp16;
				add_outb = 'd1;
				L_shr_outa = L_tmp2;
				L_shr_outb = add_in;
				L_sub_outa = temp32;
				L_sub_outb = L_shr_in;
				next_L_tmp = L_sub_in;
				sub_outa = exp1;
				sub_outb = 'd1;
				next_exp = sub_in;
				norm_l_out = L_sub_in;
				norm_l_start = 'd1;
				nextstate = state18;
			end
			
			state18: begin
				if(norm_l_done == 'd1) begin
					next_sft = norm_l_in;
					L_shl_outa = L_tmp;
					L_shl_outb = norm_l_in;
					L_shl_start = 'd1;
					nextstate = state19;
				end
				else begin
					norm_l_out = L_tmp;
					nextstate = state18;
				end
			end
			
			state19: begin
				if(L_shl_done == 'd1) begin
					next_nume = L_shl_in[31:16];
					add_outa = exp;
					add_outb = sft;
					sub_outa = add_in;
					sub_outb = 'd16;
					next_exp_nume = sub_in;
					nextstate = state20;
				end
				else begin
					L_shl_outa = L_tmp;
					L_shl_outb = sft;
					nextstate = state19;
				end
			end
			
			state20: begin
				add_outa = exp_nume;
				add_outb = exp_inv_denom;
				sub_outa = add_in;
				sub_outb = 'd24;
				next_sft = sub_in;
				L_mult_outa = nume;
				L_mult_outb = inv_denom;
				L_shr_outa = L_mult_in;
				L_shr_outb = sub_in;
				next_L_acc = L_shr_in;
				scratch_mem_write_addr = {BEST_GAIN[11:1],1'd0};
				scratch_mem_out = {16'd0,L_shr_in[31:16]};
				scratch_mem_write_en = 'd1;
				nextstate = state21;
			end
			
			state21: begin
				sub_outa = L_acc[31:16];
				sub_outb = 'd481;
				if(tame_flag == 'd1) begin
					if(sub_in[15] == 1'd0 && sub_in != 'd0) begin
						scratch_mem_write_addr = {BEST_GAIN[11:1],1'd0};
						scratch_mem_out = 32'd481;
						scratch_mem_write_en = 'd1;
					end
				end
				L_mult_outa = temp_g_coeff0;
				L_mult_outb = temp_g_coeff3;
				next_L_tmp1 = L_mult_in;
				add_outa = temp_exp_g_coeff0;
				add_outb = temp_exp_g_coeff3;
				next_exp1 = add_in;
				nextstate = state22;
			end
			
			state22: begin
				L_mult_outa = temp_g_coeff1;
				L_mult_outb = temp_g_coeff4;
				next_L_tmp2 = L_mult_in;
				add_outa = temp_exp_g_coeff1;
				add_outb = temp_exp_g_coeff4;
				L_add_outa = {16'd0, add_in};
				L_add_outb = 'd1;
				next_exp2 = L_add_in[15:0];
				sub_outa = exp1;
				sub_outb = L_add_in[15:0];
				next_temp16 = sub_in;
				if(sub_in[15] == 1'd0 && sub_in != 'd0) begin
					L_shr_outa = L_mult_in;
					L_shr_outb = 'd1;
					next_temp32 = L_shr_in;
					nextstate = state23;
				end
				else begin	
					L_shr_outa = L_tmp1;
					L_shr_outb = 'd1;
					next_temp32 = L_shr_in;
					nextstate = state_pre24;
				end
			end
			
			state23: begin
				add_outa = temp16;
				add_outb = 'd1;
				L_shr_outa = L_tmp1;
				L_shr_outb = add_in;
				L_sub_outa = L_shr_in;
				L_sub_outb = temp32;
				next_L_tmp = L_sub_in;
				sub_outa = exp2;
				sub_outb = 'd1;
				next_exp = sub_in;
				norm_l_out = L_sub_in;
				norm_l_start = 'd1;
				nextstate = state25;
			end
			
			state_pre24: begin
				sub_outa = exp2;
				sub_outb = exp1;
				next_temp16 = sub_in;
				nextstate = state24;
			end
			
			state24: begin
				add_outa = temp16;
				add_outb = 'd1;
				L_shr_outa = L_tmp2;
				L_shr_outb = add_in;
				L_sub_outa = temp32;
				L_sub_outb = L_shr_in;
				next_L_tmp = L_sub_in;
				sub_outa = exp1;
				sub_outb = 'd1;
				next_exp = sub_in;
				norm_l_out = L_sub_in;
				norm_l_start = 'd1;
				nextstate = state25;
			end
			
			state25: begin
				if(norm_l_done == 'd1) begin
					next_sft = norm_l_in;
					L_shl_outa = L_tmp;
					L_shl_outb = norm_l_in;
					L_shl_start = 'd1;
					nextstate = state26;
				end
				else begin
					norm_l_out = L_tmp;
					nextstate = state25;
				end
			end
			
			state26: begin
				if(L_shl_done == 'd1) begin
					next_nume = L_shl_in[31:16];
					add_outa = exp;
					add_outb = sft;
					sub_outa = add_in;
					sub_outb = 'd16;
					next_exp_nume = sub_in;
					nextstate = state27;
				end
				else begin
					L_shl_outa = L_tmp;
					L_shl_outb = sft;
					nextstate = state26;
				end
			end
			
			state27: begin
				add_outa = exp_nume;
				add_outb = exp_inv_denom;
				sub_outa = add_in;
				sub_outb = 'd17;
				next_sft = sub_in;
				L_mult_outa = nume;
				L_mult_outb = inv_denom;
				L_shr_outa = L_mult_in;
				L_shr_outb = sub_in;
				next_L_acc = L_shr_in;
				scratch_mem_write_addr = {BEST_GAIN[11:1],1'd1};
				scratch_mem_out = {16'd0,L_shr_in[31:16]};
				scratch_mem_write_en = 'd1;
				nextstate = state28;
			end
			
			state28: begin
				sub_outa = exp_gcode0;
				sub_outb = 'd4;
				if(sub_in[15] != 1'd0) begin
					shr_outa = gcode0;
					shr_outb = sub_in;
					next_gcode0_org = shr_in;
					nextstate = state31;
				end
				else begin
					nextstate = state29;
				end
			end
			
			state29: begin
				sub_outa = 'd20;
				sub_outb = exp_gcode0;
				next_temp16 = sub_in;
				L_shl_outa = {16'd0,gcode0};
				L_shl_outb = sub_in;
				L_shl_start = 'd1;
				nextstate = state30;
			end
			
			state30: begin
				if(L_shl_done == 'd1) begin
					next_L_acc = L_shl_in;
					next_gcode0_org = L_shl_in[31:16];
					nextstate = state31;
				end
				else begin
					L_shl_outa = {16'd0,gcode0};
					L_shl_outb = temp16;
					nextstate = state30;
				end
			end
			
			state31: begin
				gbk_presel_gcode0 = gcode0_org;
				gbk_presel_start = 'd1;
				nextstate = state32;
			end
			
			state32: begin
				if(gbk_presel_done == 'd1) begin
					next_cand1 = gbk_presel_cand1;
					next_cand2 = gbk_presel_cand2;
					add_outa = temp_exp_g_coeff0;
					add_outb = 'd13;
					next_exp_min0 = add_in;
					L_add_outa = {16'd0,temp_exp_g_coeff1};
					L_add_outb = 'd14;
					next_exp_min1 = L_add_in[15:0];
					nextstate = state33;
				end
				else begin
					gbk_presel_gcode0 = gcode0_org;
					scratch_mem_write_en = gbk_presel_scratch_mem_write_en;
					L_shl_start = gbk_presel_L_shl_start;
					scratch_mem_read_addr = gbk_presel_scratch_mem_read_addr;
					scratch_mem_write_addr = gbk_presel_scratch_mem_write_addr;
					constant_mem_read_addr = gbk_presel_constant_mem_read_addr;
					L_mult_outa = gbk_presel_L_mult_outa;
					L_mult_outb = gbk_presel_L_mult_outb;
					L_shr_outb = gbk_presel_L_shr_outb;
					L_shl_outb = gbk_presel_L_shl_outb;
					mult_outa = gbk_presel_mult_outa;
					mult_outb = gbk_presel_mult_outb;
					add_outa = gbk_presel_add_outa;
					add_outb = gbk_presel_add_outb;
					sub_outa = gbk_presel_sub_outa;
					sub_outb = gbk_presel_sub_outb;
					scratch_mem_out = gbk_presel_scratch_mem_out;
					L_shr_outa = gbk_presel_L_shr_outa;
					L_add_outa = gbk_presel_L_add_outa;
					L_add_outb = gbk_presel_L_add_outb;
					L_shl_outa = gbk_presel_L_shl_outa;
					L_sub_outa = gbk_presel_L_sub_outa;
					L_sub_outb = gbk_presel_L_sub_outb;
					nextstate = state32;
				end
			end
			
			state33: begin
				shl_outa = exp_gcode0;
				shl_outb = 'd1;
				sub_outa = shl_in;
				sub_outb = 'd21;
				add_outa = temp_exp_g_coeff2;
				add_outb = sub_in;
				next_exp_min2 = add_in;
				L_sub_outa = {16'd0,exp_gcode0};
				L_sub_outb = 'd3;
				L_add_outa = {16'd0, temp_exp_g_coeff3};
				L_add_outb = {16'd0, L_sub_in[15:0]};
				next_exp_min3 = L_add_in[15:0];
				nextstate = state34;
			end
			
			state34: begin
				sub_outa = exp_gcode0;
				sub_outb = 'd4;
				add_outa = temp_exp_g_coeff4;
				add_outb = sub_in;
				next_exp_min4 = add_in;
				next_e_min = exp_min0;
				nextstate = state35;
			end
			
			state35: begin
				sub_outa = exp_min1;
				sub_outb = e_min;
				if(sub_in[15] == 1'd1) begin
					next_e_min = exp_min1;
				end
				nextstate = state36;
			end
			
			state36: begin
				sub_outa = exp_min2;
				sub_outb = e_min;
				if(sub_in[15] == 1'd1) begin
					next_e_min = exp_min2;
				end
				nextstate = state37;
			end
			
			state37: begin
				sub_outa = exp_min3;
				sub_outb = e_min;
				if(sub_in[15] == 1'd1) begin
					next_e_min = exp_min3;
				end
				nextstate = state38;
			end
			
			state38: begin
				sub_outa = exp_min4;
				sub_outb = e_min;
				if(sub_in[15] == 1'd1) begin
					next_e_min = exp_min4;
				end
				nextstate = state39;
			end
			
			state39: begin
				sub_outa = exp_min0;
				sub_outb = e_min;
				L_shr_outa = {temp_g_coeff0,16'd0};
				L_shr_outb = sub_in;
				next_L_tmp = L_shr_in;
				nextstate = state40;
			end
			
			state40: begin
				next_coeff0 = L_tmp[31:16];
				L_shr_outa = L_tmp;
				L_shr_outb = 'd1;
				L_msu_outa = L_tmp[31:16];
				L_msu_outb = 'd16384;
				L_msu_outc = L_shr_in;
				next_coeff_lsf0 = L_msu_in[15:0];
				nextstate = state41;
			end
				
			state41: begin
				sub_outa = exp_min1;
				sub_outb = e_min;
				L_shr_outa = {temp_g_coeff1,16'd0};
				L_shr_outb = sub_in;
				next_L_tmp = L_shr_in;
				nextstate = state42;
			end
			
			state42: begin
				next_coeff1 = L_tmp[31:16];
				L_shr_outa = L_tmp;
				L_shr_outb = 'd1;
				L_msu_outa = L_tmp[31:16];
				L_msu_outb = 'd16384;
				L_msu_outc = L_shr_in;
				next_coeff_lsf1 = L_msu_in[15:0];
				nextstate = state43;
			end

			state43: begin
				sub_outa = exp_min2;
				sub_outb = e_min;
				L_shr_outa = {temp_g_coeff2,16'd0};
				L_shr_outb = sub_in;
				next_L_tmp = L_shr_in;
				nextstate = state44;
			end
			
			state44: begin
				next_coeff2 = L_tmp[31:16];
				L_shr_outa = L_tmp;
				L_shr_outb = 'd1;
				L_msu_outa = L_tmp[31:16];
				L_msu_outb = 'd16384;
				L_msu_outc = L_shr_in;
				next_coeff_lsf2 = L_msu_in[15:0];
				nextstate = state45;
			end	

			state45: begin
				sub_outa = exp_min3;
				sub_outb = e_min;
				L_shr_outa = {temp_g_coeff3,16'd0};
				L_shr_outb = sub_in;
				next_L_tmp = L_shr_in;
				nextstate = state46;
			end
			
			state46: begin
				next_coeff3 = L_tmp[31:16];
				L_shr_outa = L_tmp;
				L_shr_outb = 'd1;
				L_msu_outa = L_tmp[31:16];
				L_msu_outb = 'd16384;
				L_msu_outc = L_shr_in;
				next_coeff_lsf3 = L_msu_in[15:0];
				nextstate = state47;
			end

			state47: begin
				sub_outa = exp_min4;
				sub_outb = e_min;
				L_shr_outa = {temp_g_coeff4,16'd0};
				L_shr_outb = sub_in;
				next_L_tmp = L_shr_in;
				nextstate = state48;
			end
			
			state48: begin
				next_coeff4 = L_tmp[31:16];
				L_shr_outa = L_tmp;
				L_shr_outb = 'd1;
				L_msu_outa = L_tmp[31:16];
				L_msu_outb = 'd16384;
				L_msu_outc = L_shr_in;
				next_coeff_lsf4 = L_msu_in[15:0];
				next_L_dist_min = 32'h7fff_ffff;
				next_index1 = cand1;
				next_index2 = cand2;
				if(tame_flag == 'd1)
					nextstate = state49;
				else
					nextstate = state65;
			end	
			
			state49: begin
				if(i == 'd4) begin
					next_i = 'd0;
					constant_mem_read_addr = {GBK1[11:4],index1[2:0],1'd0};
					nextstate = state79;
				end
				else
					nextstate = state50;
			end
			
			state50: begin
				if(j == 'd8) begin
					add_outa = i;
					add_outb = 'd1;
					next_i = add_in;
					next_j = 0;
					nextstate = state49;
				end
				else begin
					add_outa = cand1;
					add_outb = i;
					constant_mem_read_addr = {GBK1[11:4],add_in[2:0],1'd0};
					nextstate = state51;
				end
			end
			
			state51: begin
				next_temp16 = constant_mem_in[15:0];
				add_outa = cand2;
				add_outb = j;
				constant_mem_read_addr = {GBK2[11:5],add_in[3:0],1'd0};
				nextstate = state52;
			end
			
			state52: begin
				add_outa = temp16;
				add_outb = constant_mem_in[15:0];
				next_g_pitch = add_in;
				if(add_in < 'd16383) begin
					nextstate = state53;
				end
				else begin
					L_add_outa = {16'd0,j};
					L_add_outb = 'd1;
					next_j = L_add_in[15:0];
					nextstate = state50;
				end
			end
			
			state53: begin
				add_outa = cand1;
				add_outb = i;
				constant_mem_read_addr = {GBK1[11:4],add_in[2:0],1'd1};
				nextstate = state54;
			end
			
			state54: begin
				next_L_acc = {16'd0,constant_mem_in[15:0]};
				add_outa = cand2;
				add_outb = j;
				constant_mem_read_addr = {GBK2[11:5],add_in[3:0],1'd1};
				nextstate = state55;
			end
			
			state55: begin
				next_L_accb = {16'd0,constant_mem_in[15:0]};
				L_add_outa = L_acc;
				L_add_outb = {16'd0,constant_mem_in[15:0]};
				next_L_tmp = L_add_in;
				L_shr_outa = L_add_in;
				L_shr_outb = 'd1;
				next_temp = L_shr_in[15:0];
				mult_outa = gcode0;
				mult_outb = L_shr_in[15:0];
				next_g_code = mult_in;
				nextstate = state56;
			end
			
			state56: begin
				mult_outa = g_pitch;
				mult_outb = g_pitch;
				next_g2_pitch = mult_in;
				nextstate = state57;
			end
			
			state57: begin
				mult_outa = g_code;
				mult_outb = g_code;
				next_g2_code = mult_in;
				nextstate = state58;
			end
			
			state58: begin
				mult_outa = g_code;
				mult_outb = g_pitch;
				next_g_pit_cod = mult_in;
				nextstate = state59;
			end
			
			state59: begin
				mpy_32_16_ina = {coeff0,coeff_lsf0};
				mpy_32_16_inb = g2_pitch;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				next_L_tmp = mpy_32_16_out;
				nextstate = state60;
			end
			
			state60: begin
				mpy_32_16_ina = {coeff1,coeff_lsf1};
				mpy_32_16_inb = g_pitch;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				L_add_outa = L_tmp;
				L_add_outb = mpy_32_16_out;
				next_L_tmp = L_add_in;
				nextstate = state61;
			end
			
			state61: begin
				mpy_32_16_ina = {coeff2,coeff_lsf2};
				mpy_32_16_inb = g2_code;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				L_add_outa = L_tmp;
				L_add_outb = mpy_32_16_out;
				next_L_tmp = L_add_in;
				nextstate = state62;
			end
			
			state62: begin
				mpy_32_16_ina = {coeff3,coeff_lsf3};
				mpy_32_16_inb = g_code;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				L_add_outa = L_tmp;
				L_add_outb = mpy_32_16_out;
				next_L_tmp = L_add_in;
				nextstate = state63;
			end
			
			state63: begin
				mpy_32_16_ina = {coeff4,coeff_lsf4};
				mpy_32_16_inb = g_pit_cod;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				L_add_outa = L_tmp;
				L_add_outb = mpy_32_16_out;
				next_L_tmp = L_add_in;
				L_sub_outa = L_add_in;
				L_sub_outb = L_dist_min;
				next_L_temp = L_sub_in;
				if(L_sub_in[31] == 1'd1) begin
					next_L_dist_min = L_add_in;
					add_outa = cand1;
					add_outb = i;
					next_index1 = add_in;
					nextstate = state64;
				end
				else begin
					add_outa = j;
					add_outb = 'd1;
					next_j = add_in;
					nextstate = state50;
				end
			end
			
			state64: begin
				add_outa = cand2;
				add_outb = j;
				next_index2 = add_in;
				L_add_outa = {16'd0,j};
				L_add_outb = 'd1;
				next_j = L_add_in[15:0];
				nextstate = state50;
			end
			
			state65: begin
				if(i == 'd4) begin
					next_i = 'd0;
					constant_mem_read_addr = {GBK1[11:4],index1[2:0],1'd0};
					nextstate = state81;
				end
				else
					nextstate = state66;
			end
			
			state66: begin
				if(j == 'd8) begin
					add_outa = i;
					add_outb = 'd1;
					next_i = add_in;
					next_j = 0;
					nextstate = state65;
				end
				else begin
					add_outa = cand1;
					add_outb = i;
					constant_mem_read_addr = {GBK1[11:4],add_in[2:0],1'd0};
					nextstate = state67;
				end
			end
			
			state67: begin
				next_temp16 = constant_mem_in[15:0];
				add_outa = cand2;
				add_outb = j;
				constant_mem_read_addr = {GBK2[11:5],add_in[3:0],1'd0};
				nextstate = state68;
			end
			
			state68: begin
				add_outa = temp16;
				add_outb = constant_mem_in[15:0];
				next_g_pitch = add_in;
				nextstate = state69;
			end
			
			state69: begin
				add_outa = cand1;
				add_outb = i;
				constant_mem_read_addr = {GBK1[11:4],add_in[2:0],1'd1};
				nextstate = state70;
			end
			
			state70: begin
				next_L_acc = {16'd0,constant_mem_in[15:0]};
				add_outa = cand2;
				add_outb = j;
				constant_mem_read_addr = {GBK2[11:5],add_in[3:0],1'd1};
				nextstate = state71;
			end
			
			state71: begin
				next_L_accb = {16'd0,constant_mem_in[15:0]};
				L_add_outa = L_acc;
				L_add_outb = {16'd0,constant_mem_in[15:0]};
				next_L_tmp = L_add_in;
				L_shr_outa = L_add_in;
				L_shr_outb = 'd1;
				next_temp = L_shr_in[15:0];
				mult_outa = gcode0;
				mult_outb = L_shr_in[15:0];
				next_g_code = mult_in;
				nextstate = state72;
			end
			
			state72: begin
				mult_outa = g_pitch;
				mult_outb = g_pitch;
				next_g2_pitch = mult_in;
				nextstate = state73;
			end
			
			state73: begin
				mult_outa = g_code;
				mult_outb = g_code;
				next_g2_code = mult_in;
				nextstate = state74;
			end
			
			state74: begin
				mult_outa = g_code;
				mult_outb = g_pitch;
				next_g_pit_cod = mult_in;
				nextstate = state75;
			end
			
			state75: begin
				mpy_32_16_ina = {coeff0,coeff_lsf0};
				mpy_32_16_inb = g2_pitch;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				next_L_tmp = mpy_32_16_out;
				nextstate = state76;
			end
			
			state76: begin
				mpy_32_16_ina = {coeff1,coeff_lsf1};
				mpy_32_16_inb = g_pitch;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				L_add_outa = L_tmp;
				L_add_outb = mpy_32_16_out;
				next_L_tmp = L_add_in;
				nextstate = state77;
			end
			
			state77: begin
				mpy_32_16_ina = {coeff2,coeff_lsf2};
				mpy_32_16_inb = g2_code;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				L_add_outa = L_tmp;
				L_add_outb = mpy_32_16_out;
				next_L_tmp = L_add_in;
				nextstate = state78;
			end
			
			state78: begin
				mpy_32_16_ina = {coeff3,coeff_lsf3};
				mpy_32_16_inb = g_code;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				L_add_outa = L_tmp;
				L_add_outb = mpy_32_16_out;
				next_L_tmp = L_add_in;
				nextstate = state79;
			end
			
			state79: begin
				mpy_32_16_ina = {coeff4,coeff_lsf4};
				mpy_32_16_inb = g_pit_cod;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				L_add_outa = L_tmp;
				L_add_outb = mpy_32_16_out;
				next_L_tmp = L_add_in;
				L_sub_outa = L_add_in;
				L_sub_outb = L_dist_min;
				next_L_temp = L_sub_in;
				if(L_sub_in[31] == 1'd1) begin
					next_L_dist_min = L_add_in;
					add_outa = cand1;
					add_outb = i;
					next_index1 = add_in;
					nextstate = state80;
				end
				else begin
					add_outa = j;
					add_outb = 'd1;
					next_j = add_in;
					nextstate = state66;
				end
			end
			
			state80: begin
				add_outa = cand2;
				add_outb = j;
				next_index2 = add_in;
				L_add_outa = {16'd0,j};
				L_add_outb = 'd1;
				next_j = L_add_in[15:0];
				nextstate = state66;
			end
			
			state81: begin
				next_temp16 = constant_mem_in[15:0];
				constant_mem_read_addr = {GBK2[11:5],index2[3:0],1'd0};
				nextstate = state82;
			end
			
			state82: begin
				add_outa = temp16;
				add_outb = constant_mem_in[15:0];
				next_gain_pit = add_in;
				scratch_mem_write_addr = GAIN_PIT;
				scratch_mem_out = {16'd0,add_in};
				scratch_mem_write_en = 'd1;
				constant_mem_read_addr = {GBK1[11:4],index1[2:0],1'd1};
				nextstate = state83;
			end
			
			state83: begin
				next_L_acc = {16'd0,constant_mem_in[15:0]};
				constant_mem_read_addr = {GBK2[11:5],index2[3:0],1'd1};
				nextstate = state84;
			end
			
			state84: begin
				next_L_accb = {16'd0,constant_mem_in[15:0]};
				L_add_outa = L_acc;
				L_add_outb = {16'd0,constant_mem_in[15:0]};
				next_L_gbk12 = L_add_in;
				L_shr_outa = L_add_in;
				L_shr_outb = 'd1;
				next_temp = L_shr_in[15:0];
				L_mult_outa = L_shr_in[15:0];
				L_mult_outb = gcode0;
				next_L_acc = L_mult_in;
				L_shl_outa = L_mult_in;
				L_negate_out = {16'd0,exp_gcode0};
				add_outa = L_negate_in[15:0];
				add_outb = 'd4;
				L_shl_outb = add_in;
				next_temp16 = add_in;
				L_shl_start = 'd1;
				nextstate = state85;
			end
			
			state85: begin
				if(L_shl_done == 'd1) begin
					next_L_acc = L_shl_in;
					next_gain_cod = L_shl_in[31:16];
					scratch_mem_write_addr = GAIN_CODE;
					scratch_mem_out = {16'd0,L_shl_in[31:16]};
					scratch_mem_write_en = 'd1;
					gain_update_start = 'd1;
					gain_update_L_gbk12 = L_gbk12;
					nextstate = state86;
				end
				else begin
					L_shl_outa = L_acc;
					L_shl_outb = temp16;
					nextstate = state85;
				end
			end
			
			state86: begin
				if(gain_update_done == 'd1) begin
					constant_mem_read_addr = {MAP1[11:3],index1[2:0]};
					nextstate = state87;
				end
				else begin
					gain_update_L_gbk12 = L_gbk12;
					scratch_mem_write_en = gain_update_scratch_mem_write_en;
					L_shl_start = gain_update_L_shl_start;
					norm_l_start = gain_update_norm_l_start;
					scratch_mem_read_addr = gain_update_scratch_mem_read_addr;
					scratch_mem_write_addr = gain_update_scratch_mem_write_addr;
					constant_mem_read_addr = gain_update_constant_mem_read_addr;
					add_outa = gain_update_add_outa;
					add_outb = gain_update_add_outb;
					sub_outa = gain_update_sub_outa;
					sub_outb = gain_update_sub_outb;
					L_shl_outb = gain_update_L_shl_outb;
					mult_outa = gain_update_mult_outa;
					mult_outb = gain_update_mult_outb;
					L_shr_outb = gain_update_L_shr_outb;
					L_msu_outa = gain_update_L_msu_outa;
					L_msu_outb = gain_update_L_msu_outb;
					L_mac_outa = gain_update_L_mac_outa;
					L_mac_outb = gain_update_L_mac_outb;
					L_shl_outa = gain_update_L_shl_outa;
					L_shr_outa = gain_update_L_shr_outa;
					L_msu_outc = gain_update_L_msu_outc;
					norm_l_out = gain_update_norm_l_out;
					L_mac_outc = gain_update_L_mac_outc;
					scratch_mem_out = gain_update_scratch_mem_out;
					nextstate = state86;
				end
			end
			
			state87: begin
				constant_mem_read_addr = {MAP2[11:4],index2[3:0]};
				next_temp16 = constant_mem_in[15:0] << 'd4;
				nextstate = state88;
			end
			
			state88: begin
				add_outa = temp16;
				add_outb = constant_mem_in[15:0];
				next_out = add_in;
				next_done = 'd1;
				nextstate = done_state;
			end
			
			done_state: begin
				next_done = done;
				next_gain_pit = 'd0;
				next_gain_cod = 'd0;
				next_i = 'd0;
				next_j = 'd0;
				next_index1 = 'd0;
				next_index2 = 'd0;
				next_cand1 = 'd0;
				next_cand2 = 'd0;
				next_exp = 'd0;
				next_gcode0 = 'd0;
				next_exp_gcode0 = 'd0;
				next_gcode0_org = 'd0;
				next_e_min = 'd0;
				next_nume = 'd0;
				next_denom = 'd0;
				next_denom = 'd0;
				next_exp_inv_denom = 'd0;
				next_sft = 'd0;
				next_temp = 'd0;
				next_g_pitch = 'd0;
				next_g2_pitch = 'd0;
				next_g_code = 'd0;
				next_g2_code = 'd0;
				next_g_pit_cod = 'd0;
				next_exp1 = 'd0;
				next_exp2 = 'd0;
				next_exp_nume = 'd0;
				next_exp_denom = 'd0;
				next_L_gbk12 = 'd0;
				next_L_temp = 'd0;
				next_L_dist_min = 'd0;
				next_L_tmp = 'd0;
				next_L_tmp1 = 'd0;
				next_L_tmp2 = 'd0;
				next_L_acc = 'd0;
				next_L_accb = 'd0;
							
				next_coeff0 = 'd0;
				next_coeff1 = 'd0;
				next_coeff2 = 'd0;
				next_coeff3 = 'd0;
				next_coeff4 = 'd0;
			
				next_coeff_lsf0 = 'd0;
				next_coeff_lsf1 = 'd0;
				next_coeff_lsf2 = 'd0;
				next_coeff_lsf3 = 'd0;
				next_coeff_lsf4 = 'd0;
			
				next_exp_min0 = 'd0;
				next_exp_min1 = 'd0;
				next_exp_min2 = 'd0;
				next_exp_min3 = 'd0;
				next_exp_min4 = 'd0;
				
				next_temp32 = 'd0;
				next_temp16 = 'd0;
				
				next_temp_g_coeff0 = 'd0;
				next_temp_g_coeff1 = 'd0;
				next_temp_g_coeff2 = 'd0;
				next_temp_g_coeff3 = 'd0;
				next_temp_g_coeff4 = 'd0;
				
				next_temp_exp_g_coeff0 = 'd0;
				next_temp_exp_g_coeff1 = 'd0;
				next_temp_exp_g_coeff2 = 'd0;
				next_temp_exp_g_coeff3 = 'd0;
				next_temp_exp_g_coeff4 = 'd0;
				
				next_done = 'd0;
				nextstate = INIT;
			end
			
		endcase
	end
endmodule

