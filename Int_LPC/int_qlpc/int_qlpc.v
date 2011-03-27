`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    10:17:20 03/10/2011
// Module Name:    int_qlpc 
// Project Name:   ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX100T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description:    This module performs the operations done by the int_qlpc function
//
// Dependencies:   LSP_to_Az.v
//						 
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Updated to support 12 bit scratch memory address wires
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module int_qlpc(clock,reset,done,start,scratch_mem_write_addr,scratch_mem_out,scratch_mem_write_en,
					scratch_mem_read_addr,scratch_mem_in,constant_mem_read_addr,constant_mem_in,abs_out,
					abs_in,negate_out,negate_in,L_sub_outa,L_sub_outb,L_sub_in,L_shr_outa,L_shr_outb,L_shr_in,
					norm_L_out,norm_L_in,norm_L_start,norm_L_done,L_shl_outa,L_shl_outb,L_shl_in,L_shl_start,
					L_shl_done,L_mult_outa,L_mult_outb,L_mult_in,L_mult_overflow,L_mac_outa,L_mac_outb,L_mac_outc,
					L_mac_in,L_mac_overflow,mult_outa,mult_outb,mult_in,mult_overflow,L_add_outa,L_add_outb,
					L_add_overflow,L_add_in,add_outa,add_outb,add_overflow,add_in,sub_outa,sub_outb,sub_overflow,
					sub_in,L_msu_outa,L_msu_outb,L_msu_outc,L_msu_overflow,L_msu_in,shr_outa,shr_outb,shr_in,shr_overflow
    );

	`include "paramList.v"
	`include "constants_param_list.v"

	input clock,start,reset;
	output reg done;
	
	input [31:0] scratch_mem_in;
	output reg [31:0] scratch_mem_out;

	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_read_addr,scratch_mem_write_addr;
	
	output reg [11:0] constant_mem_read_addr;
	input [31:0] constant_mem_in;
	
	input sub_overflow,add_overflow,mult_overflow,shr_overflow;
	input [15:0] sub_in,add_in,mult_in,shr_in;
	output reg [15:0] sub_outa,sub_outb,add_outa,add_outb,mult_outa,mult_outb,shr_outa,shr_outb;
	
	input L_add_overflow;
	input [31:0] abs_in,negate_in,L_sub_in,L_add_in;
	output reg [31:0] abs_out,negate_out,L_sub_outa,L_sub_outb,L_add_outa,L_add_outb;
	
	input L_shl_done;
	input [31:0] L_shr_in,L_shl_in;
	output reg L_shl_start;
	output reg [15:0] L_shr_outb,L_shl_outb;
	output reg [31:0] L_shr_outa,L_shl_outa;
	
	input norm_L_done;
	input [15:0] norm_L_in;
	output reg norm_L_start;
	output reg [31:0] norm_L_out;
	
	input L_mult_overflow,L_mac_overflow,L_msu_overflow;
	input [31:0] L_mult_in,L_mac_in,L_msu_in;
	output reg [15:0] L_mult_outa,L_mult_outb,L_mac_outa,L_mac_outb,L_msu_outa,L_msu_outb;
	output reg [31:0] L_mac_outc,L_msu_outc;


	reg lsp_az_start;
	wire lsp_az_done,lsp_az_norm_L_start,lsp_az_L_shl_start,lsp_az_scratch_mem_write_en;
	wire [11:0] lsp_az_scratch_mem_write_addr, lsp_az_scratch_mem_read_addr;
	reg [11:0] lsp_az_addr1,lsp_az_addr2;
	wire [15:0] lsp_az_L_shr_outb,lsp_az_L_shl_outb,lsp_az_L_mult_outa,lsp_az_L_mult_outb,lsp_az_L_mac_outa,lsp_az_L_mac_outb,lsp_az_mult_outa,lsp_az_mult_outb,
					lsp_az_sub_outa,lsp_az_sub_outb,lsp_az_add_outa,lsp_az_add_outb,lsp_az_L_msu_outa,lsp_az_L_msu_outb;
	wire [31:0] lsp_az_abs_out,lsp_az_negate_out,lsp_az_L_shr_outa,lsp_az_L_sub_outa,lsp_az_L_sub_outb,lsp_az_norm_L_out,lsp_az_L_shl_outa,
					lsp_az_L_mac_outc,lsp_az_L_add_outa,lsp_az_L_add_outb,lsp_az_scratch_mem_out,lsp_az_L_msu_outc;
	
	LSP_to_Az int_qlpc_lsp_az(
			.clock(clock),.reset(reset),.start(lsp_az_start),.done(lsp_az_done),
			.lsp_az_addr1(lsp_az_addr1),.lsp_az_addr2(lsp_az_addr2),
			.abs_in(abs_in),.abs_out(lsp_az_abs_out),
			.negate_out(lsp_az_negate_out),.negate_in(negate_in),
			.L_shr_outa(lsp_az_L_shr_outa),.L_shr_outb(lsp_az_L_shr_outb),.L_shr_in(L_shr_in),
			.L_sub_outa(lsp_az_L_sub_outa),.L_sub_outb(lsp_az_L_sub_outb),.L_sub_in(L_sub_in),
			.norm_L_out(lsp_az_norm_L_out),.norm_L_in(norm_L_in),.norm_L_start(lsp_az_norm_L_start),.norm_L_done(norm_L_done),
			.L_shl_outa(lsp_az_L_shl_outa),.L_shl_outb(lsp_az_L_shl_outb),.L_shl_in(L_shl_in),.L_shl_start(lsp_az_L_shl_start),.L_shl_done(L_shl_done),
			.L_mult_outa(lsp_az_L_mult_outa),.L_mult_outb(lsp_az_L_mult_outb),.L_mult_in(L_mult_in),.L_mult_overflow(L_mult_overflow),
			.L_mac_outa(lsp_az_L_mac_outa),.L_mac_outb(lsp_az_L_mac_outb),.L_mac_outc(lsp_az_L_mac_outc),.L_mac_in(L_mac_in),.L_mac_overflow(L_mac_overflow),
			.mult_outa(lsp_az_mult_outa),.mult_outb(lsp_az_mult_outb),.mult_in(mult_in),.mult_overflow(mult_overflow),
			.L_add_outa(lsp_az_L_add_outa),.L_add_outb(lsp_az_L_add_outb),.L_add_overflow(L_add_overflow),.L_add_in(L_add_in),
			.sub_outa(lsp_az_sub_outa),.sub_outb(lsp_az_sub_outb),.sub_in(sub_in),.sub_overflow(sub_overflow),
			.scratch_mem_read_addr(lsp_az_scratch_mem_read_addr),.scratch_mem_write_addr(lsp_az_scratch_mem_write_addr),
			.scratch_mem_out(lsp_az_scratch_mem_out),.scratch_mem_write_en(lsp_az_scratch_mem_write_en),.scratch_mem_in(scratch_mem_in),
			.add_outa(lsp_az_add_outa),.add_outb(lsp_az_add_outb),.add_overflow(add_overflow),.add_in(add_in),
			.L_msu_outa(lsp_az_L_msu_outa),.L_msu_outb(lsp_az_L_msu_outb),.L_msu_outc(lsp_az_L_msu_outc),.L_msu_overflow(L_msu_overflow),.L_msu_in(L_msu_in)
	);
	
	reg [3:0] currentstate,nextstate;
	reg [3:0] iterator1,next_iterator1;
	reg [15:0] temp1, next_temp1;
	
	parameter init = 4'd0;
	parameter state1 = 4'd1;
	parameter state2 = 4'd2;
	parameter state3 = 4'd3;
	parameter state4 = 4'd4;
	parameter state5 = 4'd5;
	parameter state6 = 4'd6;
	parameter state7 = 4'd7;
	parameter state8 = 4'd8;
	parameter state9 = 4'd9;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = init;
		else
			currentstate = nextstate;
	end
	
	always@(posedge clock) begin
		if(reset)
			iterator1 = 'd0;
		else
			iterator1 = next_iterator1;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp1 = 'd0;
		else
			temp1 = next_temp1;
	end
	
	always@(*) begin
		
		nextstate = currentstate;
		next_iterator1 = iterator1;
		next_temp1 = temp1;
		
		done = 'd0;
		scratch_mem_out = 'd0;
		scratch_mem_write_en = 'd0;
		scratch_mem_read_addr = 'd0;
		scratch_mem_write_addr = 'd0;
		constant_mem_read_addr = 'd0;
		sub_outa = 'd0;
		sub_outb = 'd0;
		add_outa = 'd0;
		add_outb = 'd0;
		abs_out = 'd0;
		negate_out = 'd0;
		L_sub_outa = 'd0;
		L_sub_outb = 'd0;
		L_add_outa = 'd0;
		L_add_outb = 'd0;
		L_shr_outb = 'd0;
		L_shl_outb = 'd0;
		L_shr_outa = 'd0;
		L_shl_outa = 'd0;
		norm_L_start = 'd0;
		norm_L_out = 'd0;
		L_mult_outa = 'd0;
		L_mult_outb = 'd0;
		L_mac_outa = 'd0;
		L_mac_outb = 'd0;
		L_msu_outa = 'd0;
		L_msu_outb = 'd0;
		L_mac_outc = 'd0;
		L_msu_outc = 'd0;
		mult_outa = 'd0;
		mult_outb = 'd0;
		L_shl_start = 'd0;
		shr_outa = 'd0;
		lsp_az_addr1 = 'd0;
		lsp_az_addr2 = 'd0;
		lsp_az_start = 'd0;
		
		case(currentstate)
		
		init: begin
			if(start == 1)
				nextstate = state1;
			else
				nextstate = init;
		end
		
		//for(i = 0; i < M; i++)
		state1: begin
			//reset iterator
			if(iterator1 >= 'd10) begin
				next_iterator1 = 'd0;
				nextstate = state4;
			end
			//lsp_new[i]
			else begin
				scratch_mem_read_addr = {LSP_NEW_Q[11:4],iterator1[3:0]};
				nextstate = state2;
			end
		end
		
		//shr(lsp_new[i],1)
		//lsp_old[i]
		state2: begin
			shr_outa = scratch_mem_in[15:0];
			shr_outb = 'd1;
			next_temp1 = shr_in;
			scratch_mem_read_addr = {LSP_OLD_Q[11:4],iterator1[3:0]};
			nextstate = state3;
		end
		
		//shr(lsp_old[i],1)
		//lsp[i] = add(shr(lsp_new[i],1),shr(lsp_old[i],1));
		//i++
		state3: begin
			shr_outa = scratch_mem_in[15:0];
			shr_outb = 'd1;
			add_outa = temp1;
			add_outb = shr_in;
			scratch_mem_write_addr = {INT_LPC_LSP_TEMP[11:4],iterator1[3:0]};
			scratch_mem_out = {16'd0,add_in[15:0]};
			scratch_mem_write_en = 'd1;
			L_add_outa = iterator1;
			L_add_outb = 'd1;
			next_iterator1 = L_add_in[3:0];
			nextstate = state1;
		end
		
		//Lsp_Az(lsp, Az);
		state4: begin
			lsp_az_start = 'd1;
			nextstate = state5;
		end
		
		//Lsp_Az(lsp, Az);
		state5: begin
			if(lsp_az_done == 1) begin
				nextstate = state6;
			end
			else begin
				lsp_az_addr1 = INT_LPC_LSP_TEMP;
				lsp_az_addr2 = AQ_T_LOW;
				norm_L_start = lsp_az_norm_L_start;
				L_shl_start = lsp_az_L_shl_start;
				scratch_mem_write_en = lsp_az_scratch_mem_write_en;
				scratch_mem_write_addr = lsp_az_scratch_mem_write_addr;
				scratch_mem_read_addr = lsp_az_scratch_mem_read_addr;
				L_shr_outb = lsp_az_L_shr_outb;
				L_shl_outb = lsp_az_L_shl_outb;
				L_mult_outa = lsp_az_L_mult_outa;
				L_mult_outb = lsp_az_L_mult_outb;
				L_mac_outa = lsp_az_L_mac_outa;
				L_mac_outb = lsp_az_L_mac_outb;
				mult_outa = lsp_az_mult_outa;
				mult_outb = lsp_az_mult_outb;
				sub_outa = lsp_az_sub_outa;
				sub_outb = lsp_az_sub_outb;
				add_outa = lsp_az_add_outa;
				add_outb = lsp_az_add_outb;
				L_msu_outa = lsp_az_L_msu_outa;
				L_msu_outb = lsp_az_L_msu_outb;
				abs_out = lsp_az_abs_out;
				negate_out = lsp_az_negate_out;
				L_shr_outa = lsp_az_L_shr_outa;
				L_sub_outa = lsp_az_L_sub_outa;
				L_sub_outb = lsp_az_L_sub_outb;
				norm_L_out = lsp_az_norm_L_out;
				L_shl_outa = lsp_az_L_shl_outa;
				L_mac_outc = lsp_az_L_mac_outc;
				L_add_outa = lsp_az_L_add_outa;
				L_add_outb = lsp_az_L_add_outb;
				scratch_mem_out = lsp_az_scratch_mem_out;
				L_msu_outc = lsp_az_L_msu_outc;
				nextstate = state5;
			end
		end

		//Lsp_Az(lsp_new, &Az[MP1]);
		state6: begin
			lsp_az_start = 'd1;
			nextstate = state7;
		end
		
		//Lsp_Az(lsp_new, &Az[MP1]);
		state7: begin
			if(lsp_az_done == 1) begin
				done = 'd1;
				nextstate = init;
			end
			else begin
				lsp_az_addr1 = LSP_NEW_Q;
				lsp_az_addr2 = AQ_T_HIGH;
				norm_L_start = lsp_az_norm_L_start;
				L_shl_start = lsp_az_L_shl_start;
				scratch_mem_write_en = lsp_az_scratch_mem_write_en;
				scratch_mem_write_addr = lsp_az_scratch_mem_write_addr;
				scratch_mem_read_addr = lsp_az_scratch_mem_read_addr;
				L_shr_outb = lsp_az_L_shr_outb;
				L_shl_outb = lsp_az_L_shl_outb;
				L_mult_outa = lsp_az_L_mult_outa;
				L_mult_outb = lsp_az_L_mult_outb;
				L_mac_outa = lsp_az_L_mac_outa;
				L_mac_outb = lsp_az_L_mac_outb;
				mult_outa = lsp_az_mult_outa;
				mult_outb = lsp_az_mult_outb;
				sub_outa = lsp_az_sub_outa;
				sub_outb = lsp_az_sub_outb;
				add_outa = lsp_az_add_outa;
				add_outb = lsp_az_add_outb;
				L_msu_outa = lsp_az_L_msu_outa;
				L_msu_outb = lsp_az_L_msu_outb;
				abs_out = lsp_az_abs_out;
				negate_out = lsp_az_negate_out;
				L_shr_outa = lsp_az_L_shr_outa;
				L_sub_outa = lsp_az_L_sub_outa;
				L_sub_outb = lsp_az_L_sub_outb;
				norm_L_out = lsp_az_norm_L_out;
				L_shl_outa = lsp_az_L_shl_outa;
				L_mac_outc = lsp_az_L_mac_outc;
				L_add_outa = lsp_az_L_add_outa;
				L_add_outb = lsp_az_L_add_outb;
				scratch_mem_out = lsp_az_scratch_mem_out;
				L_msu_outc = lsp_az_L_msu_outc;
				nextstate = state7;
			end
		end
		endcase
	end
endmodule
