`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	   Mississippi State University
// Engineer: 	   David Mudd
// 
// Create Date:    14:40:43 11/24/2011 
// Design Name: 
// Module Name:    Dec_gain 
// Project Name: 	ITU G.729 Decoder
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
module Dec_gain(clk, start, reset, done, scratch_mem_in, scratch_mem_write_en,
				scratch_mem_read_addr, scratch_mem_write_addr, scratch_mem_out,
				constant_mem_in, constant_mem_read_addr, add_in, add_a, add_b,
				add_overflow, sub_overflow, mult_overflow, L_shr_overflow,
				sub_in, sub_a, sub_b, mult_in, mult_a, mult_b, L_add_in, L_add_a,
				L_add_b, L_shr_in, L_shr_a, L_shr_b, L_shl_in, L_shl_a, L_shl_b,
				L_shl_done, L_shl_overflow, L_shl_start, norm_l_in, norm_l_out,
				norm_l_done, norm_l_start, L_msu_in, L_msu_a, L_msu_b, L_msu_c,
				L_msu_overflow, L_mac_in, L_mac_a, L_mac_b, L_mac_c, L_mac_overflow,
				L_mult_in, L_mult_a, L_mult_b, L_mult_overflow, L_negate_in,
				L_negate_out, shr_in, shr_a, shr_b);

	`include "paramList.v"
	`include "constants_param_list.v"

	input clk, start, reset;
	
	output reg done;
	reg next_done;
	
	input [31:0] scratch_mem_in;
	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_read_addr, scratch_mem_write_addr;
	output reg [31:0] scratch_mem_out;
	
	input [31:0] constant_mem_in;
	output reg [11:0] constant_mem_read_addr;
	
	input [15:0] add_in;
	input add_overflow;
	output reg [15:0] add_a, add_b;
	
	input [15:0] sub_in;
	input sub_overflow;
	output reg [15:0] sub_a, sub_b;
	
	input [15:0] mult_in;
	input mult_overflow;
	output reg [15:0] mult_a, mult_b;
	
	input [31:0] L_add_in;
	output reg [31:0] L_add_a, L_add_b;
	
	input [31:0] L_shr_in;
	input L_shr_overflow;
	output reg [31:0] L_shr_a;
	output reg [15:0] L_shr_b;
	
	input [31:0] L_shl_in;
	input L_shl_done, L_shl_overflow;
	output reg [31:0] L_shl_a;
	output reg [15:0] L_shl_b;
	output reg L_shl_start;
	
	input [15:0] norm_l_in;
	input norm_l_done;
	output reg [31:0] norm_l_out;
	output reg norm_l_start;
	
	input [31:0] L_msu_in;
	input L_msu_overflow;
	output reg [31:0] L_msu_c;
	output reg [15:0] L_msu_a, L_msu_b;
	
	input [31:0] L_mac_in;
	input L_mac_overflow;
	output reg [31:0] L_mac_c;
	output reg [15:0] L_mac_a, L_mac_b;
	
	input [31:0] L_mult_in;
	input L_mult_overflow;
	output reg [15:0] L_mult_a, L_mult_b;
	
	input [31:0] L_negate_in;
	output reg [31:0] L_negate_out;
	
	input [15:0] shr_in;
	output reg [15:0] shr_a, shr_b;
	
	reg [15:0] index1, next_index1;
	reg [15:0] index2, next_index2;
	reg [15:0] tmp, next_tmp;
	reg ld_index1, ld_index2, ld_tmp;
	
	reg [15:0] gcode0, next_gcode0;
	reg [15:0] exp_gcode0, next_exp_gcode0;
	reg ld_gcode0, ld_exp_gcode0;
	
	reg [31:0] L_gbk12, next_L_gbk12;
	reg [31:0] L_acc, next_L_acc;
	reg [31:0] L_accb, next_L_accb;
	reg ld_L_gbk12, ld_L_acc, ld_L_accb;
	
	reg [4:0] state, nextstate;
	
	reg [2:0] i, next_i;
	reg ld_i;
	
	// Gain_update_erasure wires and regs
	reg Gain_update_erasure_Start;
	wire Gain_update_erasure_Done;
	wire [15:0] Gain_update_erasure_add_a, Gain_update_erasure_add_b;
	wire [15:0] Gain_update_erasure_sub_a, Gain_update_erasure_sub_b;
	wire [31:0] Gain_update_erasure_L_add_a, Gain_update_erasure_L_add_b;
	wire [31:0] Gain_update_erasure_L_shr_a;
	wire [15:0] Gain_update_erasure_L_shr_b;
	wire [31:0] Gain_update_erasure_scratch_mem_out;
	wire [11:0] Gain_update_erasure_scratch_read_addr;
	wire [11:0] Gain_update_erasure_scratch_write_addr;
	wire Gain_update_erasure_scratch_write_en;
	
	Gain_update_erasure i_Gain_update_erasure(
	.clk(clk), .start(Gain_update_erasure_Start), 
	.reset(reset), .done(Gain_update_erasure_Done),
	.add_in(add_in), .add_a(Gain_update_erasure_add_a), 
	.add_b(Gain_update_erasure_add_b),.sub_in(sub_in), 
	.sub_a(Gain_update_erasure_sub_a), .sub_b(Gain_update_erasure_sub_b),
	.L_add_in(L_add_in), .L_add_a(Gain_update_erasure_L_add_a),
	.L_add_b(Gain_update_erasure_L_add_b),.L_shr_in(L_shr_in), 
	.L_shr_a(Gain_update_erasure_L_shr_a), .L_shr_b(Gain_update_erasure_L_shr_b),
	.scratch_mem_in(scratch_mem_in), .scratch_mem_write_en(Gain_update_erasure_scratch_write_en),
	.scratch_mem_read_addr(Gain_update_erasure_scratch_read_addr),
	.scratch_mem_write_addr(Gain_update_erasure_scratch_write_addr),
	.scratch_mem_out(Gain_update_erasure_scratch_mem_out));
	
	// Gain_predict wires and regs
	reg Gain_predict_Start;
	wire Gain_predict_Done;
	wire [11:0] Gain_predict_s_read_addr;
	wire [11:0] Gain_predict_s_write_addr;
	wire Gain_predict_s_write_en;
	wire [31:0] Gain_predict_s_out;
	wire [11:0] Gain_predict_c_read_addr;
	wire [31:0] G_p_L_shl_a, G_p_L_shr_a;
	wire [15:0] G_p_L_shl_b, G_p_L_shr_b;
	wire G_p_L_shl_start, G_p_norm_l_start;
	wire [31:0] G_p_norm_l_out;
	wire [15:0] G_p_sub_a, G_p_sub_b, G_p_add_a, G_p_add_b;
	wire [31:0] G_p_L_msu_c, G_p_L_mac_c;
	wire [15:0] G_p_L_msu_a, G_p_L_msu_b, G_p_L_mac_a, G_p_L_mac_b;
	wire [15:0] G_p_L_mult_a, G_p_L_mult_b, G_p_mult_a, G_p_mult_b;
	wire [15:0] G_p_gcode0, G_p_exp_gcode0;
	
	Gain_predict i_Gain_predict(
	.clock(clk), .reset(reset), .start(Gain_predict_Start), .done(Gain_predict_Done),
	.scratch_mem_read_addr(Gain_predict_s_read_addr), .scratch_mem_write_addr(Gain_predict_s_write_addr),
	.gcode0(G_p_gcode0), .exp_gcode0(G_p_exp_gcode0), .scratch_mem_write_en(Gain_predict_s_write_en),
	.scratch_mem_in(scratch_mem_in), .scratch_mem_out(Gain_predict_s_out), .constant_mem_read_addr(Gain_predict_c_read_addr),
	.constant_mem_in(constant_mem_in), .L_shl_outa(G_p_L_shl_a), .L_shl_outb(G_p_L_shl_b), .L_shl_start(G_p_L_shl_start),
	.L_shl_done(L_shl_done), .L_shl_in(L_shl_in), .L_shl_overflow(L_shl_overflow),
	.L_shr_outa(G_p_L_shr_a), .L_shr_outb(G_p_L_shr_b), .L_shr_in(L_shr_in), .L_shr_overflow(L_shr_overflow),
	.norm_l_out(G_p_norm_l_out), .norm_l_start(G_p_norm_l_start), .norm_l_done(norm_l_done), .norm_l_in(norm_l_in),
	.sub_outa(G_p_sub_a), .sub_outb(G_p_sub_b), .sub_overflow(sub_overflow), .sub_in(sub_in),
	.L_msu_outa(G_p_L_msu_a), .L_msu_outb(G_p_L_msu_b), .L_msu_outc(G_p_L_msu_c), .L_msu_overflow(L_msu_overflow), .L_msu_in(L_msu_in),
	.add_outa(G_p_add_a), .add_outb(G_p_add_b), .add_overflow(add_overflow), .add_in(add_in),
	.L_mac_outa(G_p_L_mac_a), .L_mac_outb(G_p_L_mac_b), .L_mac_outc(G_p_L_mac_c), .L_mac_in(L_mac_in), .L_mac_overflow(L_mac_overflow),
	.L_mult_outa(G_p_L_mult_a), .L_mult_outb(G_p_L_mult_b), .L_mult_overflow(L_mult_overflow), .L_mult_in(L_mult_in),
	.mult_outa(G_p_mult_a), .mult_outb(G_p_mult_b), .mult_overflow(mult_overflow), .mult_in(mult_in)
    );
	
	// Gain_update wires and regs
	reg Gain_update_Start;
	wire Gain_update_Done;
	wire [11:0] G_u_s_read_addr;
	wire [11:0] G_u_s_write_addr;
	wire G_u_s_write_en;
	wire [31:0] G_u_s_out;
	wire [11:0] G_u_c_read_addr;
	wire [31:0] G_u_L_shl_a, G_u_L_shr_a;
	wire [15:0] G_u_L_shl_b, G_u_L_shr_b;
	wire G_u_L_shl_start, G_u_norm_l_start;
	wire [31:0] G_u_norm_l_out;
	wire [15:0] G_u_sub_a, G_u_sub_b, G_u_add_a, G_u_add_b;
	wire [31:0] G_u_L_msu_c, G_u_L_mac_c;
	wire [15:0] G_u_L_msu_a, G_u_L_msu_b, G_u_L_mac_a, G_u_L_mac_b;
	wire [15:0] G_u_mult_a, G_u_mult_b;
	
	Gain_update i_Gain_update(
	.clock(clk), .reset(reset), .start(Gain_update_Start), .done(Gain_update_Done), .L_gbk12(L_gbk12),
	.scratch_mem_read_addr(G_u_s_read_addr), .scratch_mem_write_addr(G_u_s_write_addr),
	.scratch_mem_out(G_u_s_out), .scratch_mem_write_en(G_u_s_write_en), .scratch_mem_in(scratch_mem_in),
	.add_outa(G_u_add_a), .add_outb(G_u_add_b), .add_in(add_in), .add_overflow(add_overflow),
	.sub_outa(G_u_sub_a), .sub_outb(G_u_sub_b), .sub_in(sub_in), .sub_overflow(sub_overflow), .L_shl_start(G_u_L_shl_start),
	.L_shl_outa(G_u_L_shl_a), .L_shl_outb(G_u_L_shl_b), .L_shl_overflow(L_shl_overflow), .L_shl_in(L_shl_in), .L_shl_done(L_shl_done),
	.mult_outa(G_u_mult_a), .mult_outb(G_u_mult_b), .mult_in(mult_in), .mult_overflow(mult_overflow), .L_shr_outa(G_u_L_shr_a),
	.L_shr_outb(G_u_L_shr_b), .L_shr_overflow(L_shr_overflow), .L_shr_in(L_shr_in), .L_msu_outa(G_u_L_msu_a),
	.L_msu_outb(G_u_L_msu_b), .L_msu_outc(G_u_L_msu_c), .L_msu_overflow(L_msu_overflow), .L_msu_in(L_msu_in),
	.norm_l_out(G_u_norm_l_out), .norm_l_start(G_u_norm_l_start), .norm_l_in(norm_l_in), .norm_l_done(norm_l_done),
	.constant_mem_read_addr(G_u_c_read_addr), .constant_mem_in(constant_mem_in), .L_mac_outa(G_u_L_mac_a),
	.L_mac_outb(G_u_L_mac_b), .L_mac_outc(G_u_L_mac_c), .L_mac_overflow(L_mac_overflow), .L_mac_in(L_mac_in)
    );
	
	parameter INIT = 0;
	parameter IF_CLAUSE = 1;
	parameter IF_BODY_1 = 2;
	parameter IF_BODY_2 = 3;
	parameter IF_BODY_3 = 4;
	parameter GAIN_UPDATE_ERASURE = 5;
	parameter CAL_INDEX1_1 = 6;
	parameter CAL_INDEX1_2 = 7;
	parameter CAL_INDEX2_1 = 8;
	parameter CAL_INDEX2_2 = 9;
	parameter CAL_GAIN_PIT_1 = 10;
	parameter CAL_GAIN_PIT_2 = 11;
	parameter GAIN_PREDICT = 12;
	parameter S13 = 13;
	parameter S14 = 14;
	parameter S15 = 15;
	parameter S16 = 16;
	parameter S17 = 17;
	parameter S18 = 18;
	parameter CONT_L_SHL = 19;
	parameter S20 = 20;
	parameter S21 = 21;
	parameter GAIN_UPDATE = 22;
	parameter FINAL_STATE = 23;
	
	always@(posedge clk)
	begin
		if(reset)
			state = INIT;
		else
			state = nextstate;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			done = 0;
		else
			done = next_done;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			index1 = 0;
		else if(ld_index1)
			index1 = next_index1;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			index2 = 0;
		else if(ld_index2)
			index2 = next_index2;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			tmp = 0;
		else if(ld_tmp)
			tmp = next_tmp;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			gcode0 = 0;
		else if(ld_gcode0)
			gcode0 = next_gcode0;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			exp_gcode0 = 0;
		else if(ld_exp_gcode0)
			exp_gcode0 = next_exp_gcode0;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			L_gbk12 = 0;
		else if(ld_L_gbk12)
			L_gbk12 = next_L_gbk12;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			L_acc = 0;
		else if(ld_L_acc)
			L_acc = next_L_acc;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			L_accb = 0;
		else if(ld_L_accb)
			L_accb = next_L_accb;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			i = 0;
		else if(ld_i)
			i = next_i;
	end
	
	parameter NCODE2_B = 4;
	parameter NCODE2 = 1<<NCODE2_B;
	
	/*** START CODE ***/
	always@(*)
	begin
		nextstate = state;
		next_done = 0;
		next_index1 = 0;
		next_index2 = 0;
		next_tmp = 0;
		next_gcode0 = 0;
		next_exp_gcode0 = 0;
		next_L_gbk12 = 0;
		next_L_acc = 0;
		next_L_accb = 0;
		next_i = 0;
		
		ld_index1 = 0;
		ld_index2 = 0;
		ld_tmp = 0;
		ld_gcode0 = 0;
		ld_exp_gcode0 = 0;
		ld_L_gbk12 = 0;
		ld_L_acc = 0;
		ld_L_accb = 0;
		ld_i = 0;
		
		add_a = 0;
		add_b = 0;
		sub_a = 0;
		sub_b = 0;
		mult_a = 0;
		mult_b = 0;
		L_add_a = 0;
		L_add_b = 0;
		L_shr_a = 0;
		L_shr_b = 0;
		L_shl_a = 0;
		L_shl_b = 0;
		L_shl_start = 0;
		norm_l_out = 0;
		norm_l_start = 0;
		L_msu_a = 0;
		L_msu_b = 0;
		L_msu_c = 0;
		L_mac_a = 0;
		L_mac_b = 0;
		L_mac_c = 0;
		L_mult_a = 0;
		L_mult_b = 0;
		L_negate_out = 0;
		shr_a = 0;
		shr_b = 0;
		
		scratch_mem_read_addr = 0;
		scratch_mem_write_addr = 0;
		scratch_mem_out = 0;
		scratch_mem_write_en = 0;
		
		constant_mem_read_addr = 0;
		
		Gain_update_erasure_Start = 0;
		Gain_predict_Start = 0;
		Gain_update_Start = 0;
		
		case(state)
			INIT: // 0
			begin
				if(start)
				begin
					next_i = 0;
					ld_i = 1;
					next_gcode0 = 0;
					ld_gcode0 = 1;
					next_exp_gcode0 = 0;
					ld_exp_gcode0 = 1;
					scratch_mem_read_addr = BFI;
					nextstate = IF_CLAUSE;
				end
			end
			IF_CLAUSE: // 1
			begin
				// if(bfi != 0)
				if(scratch_mem_in != 0)
				begin
					scratch_mem_read_addr = GAIN_PIT;
					nextstate = IF_BODY_1;
				end
				else
				begin
					scratch_mem_read_addr = INDEX;
					nextstate = CAL_INDEX1_1;
				end
			end
			IF_BODY_1: // 2
			begin
				// *gain_pit = mult( *gain_pit, 29491 );
				mult_a = scratch_mem_in[15:0];
				mult_b = 16'd29491;
				scratch_mem_write_addr = GAIN_PIT;
				scratch_mem_out = mult_in;
				scratch_mem_write_en = 1;
				scratch_mem_read_addr = GAIN_PIT;
				nextstate = IF_BODY_2;
			end
			IF_BODY_2: // 3
			begin
				// if (sub( *gain_pit, 29491) > 0) *gain_pit = 29491;
				sub_a = scratch_mem_in[15:0];
				sub_b = 16'd29491;
				if($signed(sub_in)>$signed(16'd0))
				begin
					scratch_mem_write_addr = GAIN_PIT;
					scratch_mem_out = 16'd29491;
					scratch_mem_write_en = 1;
				end
				scratch_mem_read_addr = GAIN_CODE;
				nextstate = IF_BODY_3;
			end
			IF_BODY_3: // 4
			begin
				// *gain_cod = mult( *gain_cod, 32111 );
				mult_a = scratch_mem_in[15:0];
				mult_b = 16'd32111;
				scratch_mem_write_addr = GAIN_CODE;
				scratch_mem_out = mult_in;
				scratch_mem_write_en = 1;
				nextstate = GAIN_UPDATE_ERASURE;
			end
			GAIN_UPDATE_ERASURE: // 5
			begin
				Gain_update_erasure_Start = 1;
				add_a = Gain_update_erasure_add_a;
				add_b = Gain_update_erasure_add_b;
				sub_a = Gain_update_erasure_sub_a;
				sub_b = Gain_update_erasure_sub_b;
				L_add_a = Gain_update_erasure_L_add_a;
				L_add_b = Gain_update_erasure_L_add_b;
				L_shr_a = Gain_update_erasure_L_shr_a;
				L_shr_b = Gain_update_erasure_L_shr_b;
				scratch_mem_out = Gain_update_erasure_scratch_mem_out;
				scratch_mem_read_addr = Gain_update_erasure_scratch_read_addr;
				scratch_mem_write_addr = Gain_update_erasure_scratch_write_addr;
				scratch_mem_write_en = Gain_update_erasure_scratch_write_en;
				if(Gain_update_erasure_Done == 0)
					nextstate = GAIN_UPDATE_ERASURE;
				else if(Gain_update_erasure_Done == 1)
				begin
					Gain_update_erasure_Start = 0;
					next_done = 1;
					nextstate = FINAL_STATE;
				end
			end
			CAL_INDEX1_1: // 6
			begin
				// index1 = imap1[ shr(index,NCODE2_B) ] ;
				shr_a = scratch_mem_in[15:0];
				shr_b = NCODE2_B;
				constant_mem_read_addr = IMAP1+shr_in;
				nextstate = CAL_INDEX1_2;
			end
			CAL_INDEX1_2: // 7
			begin
				next_index1 = constant_mem_in[15:0];
				ld_index1 = 1;
				scratch_mem_read_addr = INDEX;
				nextstate = CAL_INDEX2_1;
			end
			CAL_INDEX2_1: // 8
			begin
				// index2 = imap2[ index & (NCODE2-1) ] ;
				constant_mem_read_addr = IMAP2+(scratch_mem_in[15:0] & (NCODE2-1));
				nextstate = CAL_INDEX2_2;
			end
			CAL_INDEX2_2: // 9
			begin
				next_index2 = constant_mem_in[15:0];
				ld_index2 = 1;
				constant_mem_read_addr = {GBK1[11:4],index1[2:0],1'b0};
				nextstate = CAL_GAIN_PIT_1;
			end
			CAL_GAIN_PIT_1: // 10
			begin
				//*gain_pit = add( gbk1[index1][0], gbk2[index2][0] );
				next_tmp = constant_mem_in[15:0];
				ld_tmp = 1;
				constant_mem_read_addr = {GBK2[11:4],index2[2:0],1'b0};
				nextstate = CAL_GAIN_PIT_2;
			end
			CAL_GAIN_PIT_2: // 11
			begin
				add_a = tmp;
				add_b = constant_mem_in[15:0];
				scratch_mem_write_addr = GAIN_PIT;
				scratch_mem_out = add_in;
				scratch_mem_write_en = 1;
				nextstate = GAIN_PREDICT;
			end
			GAIN_PREDICT: // 12
			begin
				// Gain_predict( past_qua_en, code, L_subfr, &gcode0, &exp_gcode0 );
				Gain_predict_Start = 1;
				scratch_mem_read_addr = Gain_predict_s_read_addr;
				scratch_mem_write_addr = Gain_predict_s_write_addr;
				scratch_mem_write_en = Gain_predict_s_write_en;
				scratch_mem_out = Gain_predict_s_out;
				constant_mem_read_addr = Gain_predict_c_read_addr;
				L_shl_a = G_p_L_shl_a;
				L_shr_a = G_p_L_shr_a;
				L_shl_b = G_p_L_shl_b;
				L_shr_b = G_p_L_shr_b;
				L_shl_start = G_p_L_shl_start;
				norm_l_start = G_p_norm_l_start;
				norm_l_out = G_p_norm_l_out;
				sub_a = G_p_sub_a;
				sub_b = G_p_sub_b;
				add_a = G_p_add_a;
				add_b = G_p_add_b;
				L_msu_c = G_p_L_msu_c;
				L_mac_c = G_p_L_mac_c;
				L_msu_a = G_p_L_msu_a;
				L_msu_b = G_p_L_msu_b;
				L_mac_a = G_p_L_mac_a;
				L_mac_b = G_p_L_mac_b;
				L_mult_a = G_p_L_mult_a;
				L_mult_b = G_p_L_mult_b;
				mult_a = G_p_mult_a;
				mult_b = G_p_mult_b;
				next_gcode0 = G_p_gcode0;
				next_exp_gcode0 = G_p_exp_gcode0;
				ld_gcode0 = 1;
				ld_exp_gcode0 = 1;
				if(Gain_predict_Done == 0)
					nextstate = GAIN_PREDICT;
				else if(Gain_predict_Done == 1)
				begin
					Gain_predict_Start = 0;
					constant_mem_read_addr = {GBK1[11:4],index1[2:0],1'b1};
					nextstate = S13;
				end
			end
			S13: // 13
			begin
				// L_acc = L_deposit_l( gbk1[index1][1] );
				if(constant_mem_in[15] == 1)
					next_L_acc = {16'hffff,constant_mem_in[15:0]};
				else if(constant_mem_in[15] == 0)
					next_L_acc = {16'd0,constant_mem_in[15:0]};
				ld_L_acc = 1;
				constant_mem_read_addr = {GBK2[11:4],index2[2:0],1'b1};
				nextstate = S14;
			end
			S14: // 14
			begin
				// L_accb = L_deposit_l( gbk2[index2][1] );
				if(constant_mem_in[15] == 1)
					next_L_accb = {16'hffff,constant_mem_in[15:0]};
				else if(constant_mem_in[15] == 0)
					next_L_accb = {16'd0,constant_mem_in[15:0]};
				ld_L_accb = 1;
				nextstate = S15;
			end
			S15: // 15
			begin
				// L_gbk12 = L_add( L_acc, L_accb );
				L_add_a = L_acc;
				L_add_b = L_accb;
				next_L_gbk12 = L_add_in;
				ld_L_gbk12 = 1;
				nextstate = S16;
			end
			S16: // 16
			begin
				// tmp = extract_l( L_shr( L_gbk12,1 ) );
				L_shr_a = L_gbk12;
				L_shr_b = 16'd1;
				next_tmp = L_shr_in[15:0];
				ld_tmp = 1;
				nextstate = S17;
			end
			S17: // 17
			begin
				// L_acc = L_mult(tmp, gcode0);
				L_mult_a = tmp;
				L_mult_b = gcode0;
				next_L_acc = L_mult_in;
				ld_L_acc = 1;
				nextstate = S18;
			end
			S18: // 18
			begin
				// L_acc = L_shl(L_acc, add( negate(exp_gcode0),(-12-1+1+16) ));
				L_negate_out = exp_gcode0;
				//add_a = L_negate_in[15:0];
				add_a = L_negate_in;
				add_b = -12-1+1+16;
				L_shl_a = L_acc;
				L_shl_b = add_in;
				L_shl_start = 1;
				if(L_shl_done == 0)
					nextstate = CONT_L_SHL;
				else
					nextstate = S20;
			end
			CONT_L_SHL: // 19
			begin
				// L_acc = L_shl(L_acc, add( negate(exp_gcode0),(-12-1+1+16) ));
				L_negate_out = exp_gcode0;
				//add_a = L_negate_in[15:0];
				add_a = L_negate_in;
				add_b = -12-1+1+16;
				L_shl_a = L_acc;
				L_shl_b = add_in;
				if(L_shl_done == 0)
					nextstate = CONT_L_SHL;
				else if(L_shl_done == 1)
					nextstate = S20;
			end
			S20: // 20
			begin
				next_L_acc = L_shl_in;
				ld_L_acc = 1;
				nextstate = S21;
			end
			S21: // 21
			begin
				// *gain_cod = extract_h( L_acc ); 
				scratch_mem_write_addr = GAIN_CODE;
				scratch_mem_out = L_acc[31:16];
				scratch_mem_write_en = 1;
				nextstate = GAIN_UPDATE;
			end
			GAIN_UPDATE: // 22
			begin
				Gain_update_Start = 1;
				scratch_mem_read_addr = G_u_s_read_addr;
				scratch_mem_write_addr = G_u_s_write_addr;
				scratch_mem_write_en = G_u_s_write_en;
				scratch_mem_out = G_u_s_out;
				constant_mem_read_addr = G_u_c_read_addr;
				L_shl_a = G_u_L_shl_a;
				L_shr_a = G_u_L_shr_a;
				L_shl_b = G_u_L_shl_b;
				L_shr_b = G_u_L_shr_b;
				L_shl_start = G_u_L_shl_start;
				norm_l_start = G_u_norm_l_start;
				norm_l_out = G_u_norm_l_out;
				sub_a = G_u_sub_a;
				sub_b = G_u_sub_b;
				add_a = G_u_add_a;
				add_b = G_u_add_b;
				L_msu_c = G_u_L_msu_c;
				L_mac_c = G_u_L_mac_c;
				L_msu_a = G_u_L_msu_a;
				L_msu_b = G_u_L_msu_b;
				L_mac_a = G_u_L_mac_a;
				L_mac_b = G_u_L_mac_b;
				mult_a = G_u_mult_a;
				mult_b = G_u_mult_b;
				if(Gain_update_Done == 0)
					nextstate = GAIN_UPDATE;
				else if(Gain_update_Done == 1)
				begin
					Gain_update_Start = 0;
					next_done = 1;
					nextstate = FINAL_STATE;
				end
			end
			FINAL_STATE: // 23
			begin
				next_done = 0;
				nextstate = INIT;
			end
		endcase
		
	end

endmodule
