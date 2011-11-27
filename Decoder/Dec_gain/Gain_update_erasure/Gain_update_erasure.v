`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	   David Mudd
// 
// Create Date:    21:24:48 11/23/2011 
// Design Name: 
// Module Name:    Gain_update_erasure 
// Project Name:   ITU G.729 Decoder
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
module Gain_update_erasure(clk, start, reset, done, add_in, add_a, add_b, sub_in,
							sub_a, sub_b, L_add_in, L_add_a, L_add_b, L_shr_in,
							L_shr_a, L_shr_b, scratch_mem_in, scratch_mem_write_en, 
							scratch_mem_read_addr, scratch_mem_write_addr, 
							scratch_mem_out);

	`include "paramList.v"
							
	input clk, start, reset;
	output reg done;
	
	input [15:0] add_in;
	output reg [15:0] add_a, add_b;
	
	input [15:0] sub_in;
	output reg [15:0] sub_a, sub_b;
	
	input [31:0] L_add_in;
	output reg [31:0] L_add_a, L_add_b;
	
	input [31:0] L_shr_in;
	output reg [31:0] L_shr_a;
	output reg [15:0] L_shr_b;
	
	input [31:0] scratch_mem_in;
	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_read_addr, scratch_mem_write_addr;
	output reg [31:0] scratch_mem_out;
	
	reg next_done;
	
	reg [15:0] i, next_i;
	reg [15:0] av_pred_en, next_av_pred_en;
	reg [31:0] L_tmp, next_L_tmp;
	
	reg [15:0] tmp_i, next_tmp_i;
	
	reg ld_i, ld_av_pred_en, ld_L_tmp, ld_tmp_i;
	
	reg [3:0] state, nextstate;
	
	parameter INIT = 0;
	parameter S1 = 1;
	parameter S2 = 2;
	parameter S3 = 3;
	parameter S4 = 4;
	parameter S5 = 5;
	parameter S6 = 6;
	parameter S7 = 7;
	parameter S8 = 8;
	parameter FINAL_STATE = 9;
	
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
			i = 0;
		else if(ld_i)
			i = next_i;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			av_pred_en = 0;
		else if(ld_av_pred_en)
			av_pred_en = next_av_pred_en;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			L_tmp = 0;
		else if(ld_L_tmp)
			L_tmp = next_L_tmp;
	end
	
	always@(posedge clk)
	begin
		if(reset)
			tmp_i = 0;
		else if(ld_tmp_i)
			tmp_i = next_tmp_i;
	end
	
	/*** START CODE ***/
	
	// past_qua_en[4]
	
	always@(*)
	begin
		nextstate = state;
		next_done = 0;
		next_i = 0;
		next_av_pred_en = 0;
		next_L_tmp = 0;
		next_tmp_i = 0;
		
		ld_i = 0;
		ld_av_pred_en = 0;
		ld_L_tmp = 0;
		ld_tmp_i = 0;
		
		add_a = 0;
		add_b = 0;
		sub_a = 0;
		sub_b = 0;
		L_add_a = 0;
		L_add_b = 0;
		L_shr_a = 0;
		L_shr_b = 0;
		
		scratch_mem_read_addr = 0;
		scratch_mem_write_addr = 0;
		scratch_mem_out = 0;
		scratch_mem_write_en = 0;
		
		case(state)
			INIT: // 0
			begin
				if(start)
				begin
					// L_tmp = 0;
					next_L_tmp = 0;
					ld_L_tmp = 1;
					next_i = 0;
					ld_i = 1;
					nextstate = S1;
				end
			end
			S1: // 1
			begin
				if(i==4)
				begin
					next_i = 16'd3;
					ld_i = 1;
					nextstate = S3;
				end
				else
				begin
					scratch_mem_read_addr = {PAST_QUA_EN[11:2],i[1:0]};
					nextstate = S2;
				end
			end
			S2: // 2
			begin
				// L_tmp = L_add( L_tmp, L_deposit_l( past_qua_en[i] ) );
				if(scratch_mem_in[15] == 1)
					L_add_b = {16'hffff,scratch_mem_in[15:0]};
				else if(scratch_mem_in[15] == 0)
					L_add_b = {16'd0,scratch_mem_in[15:0]};
				L_add_a = L_tmp;
				next_L_tmp = L_add_in;
				ld_L_tmp = 1;
				//increment i
				add_a = i;
				add_b = 16'd1;
				next_i = add_in;
				ld_i = 1;
				nextstate = S1;
			end
			S3: // 3
			begin
				//av_pred_en = extract_l( L_shr( L_tmp, 2 ) );
				L_shr_a = L_tmp;
				L_shr_b = 16'd2;
				next_av_pred_en = L_shr_in[15:0];
				ld_av_pred_en = 1;
				nextstate = S4;
			end
			S4: // 4
			begin
				// av_pred_en = sub( av_pred_en, 4096 );
				sub_a = av_pred_en;
				sub_b = 16'd4096;
				next_av_pred_en = sub_in;
				ld_av_pred_en = 1;
				nextstate = S5;
			end
			S5: // 5
			begin
				// if( sub(av_pred_en, -14336) < 0 ){
				//		av_pred_en = -14336;
				// }
				sub_a = av_pred_en;
				sub_b = -16'd14336;
				if($signed(sub_in) < $signed(16'd0))
				begin
					next_av_pred_en = -16'd14336;
					ld_av_pred_en = 1;
				end
				next_tmp_i = i; // tmp_i = 3;
				ld_tmp_i = 1;
				nextstate = S6;
			end
			S6: // 6
			begin
				// for(i=3; i>0; i--)
				if(i==16'd0)
				begin
					nextstate = S8;
				end
				else
				begin
					sub_a = tmp_i;
					sub_b = 16'd1;
					next_tmp_i = sub_in;
					ld_tmp_i = 1;
					scratch_mem_read_addr = {PAST_QUA_EN[11:2],sub_in[1:0]};
					nextstate = S7;
				end
			end
			S7: // 7
			begin
				// past_qua_en[i] = past_qua_en[i-1];
				scratch_mem_write_addr = {PAST_QUA_EN[11:2],i[1:0]};
				scratch_mem_out = scratch_mem_in;
				scratch_mem_write_en = 1;
				sub_a = i;
				sub_b = 1;
				next_i = sub_in;
				ld_i = 1;
				nextstate = S6;
			end
			S8: // 8
			begin
				// past_qua_en[0] = av_pred_en;
				scratch_mem_write_addr = {PAST_QUA_EN[11:1],1'b0};
				if(av_pred_en[15] == 1)
					scratch_mem_out = {16'hffff,av_pred_en[15:0]};
				else if(av_pred_en[15] == 0)
					scratch_mem_out = {20'hfffff,av_pred_en[12:0]}; 
				scratch_mem_write_en = 1;
				next_done = 1;
				nextstate = FINAL_STATE;
			end
			FINAL_STATE: // 9
			begin
				next_done = 0;
				nextstate = INIT;
			end
		endcase
	end

endmodule
