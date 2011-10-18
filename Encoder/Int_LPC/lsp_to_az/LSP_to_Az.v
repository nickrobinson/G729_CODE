`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    15:58:27 11/22/2010 
// Module Name:    LSP_to_Az 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description: 	 This module performs the operations done by the lsp_az function
//
// Dependencies: 	 get_lsp_pol.v
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Updated to support input addresses
// Revision 0.03 - Updated to support 12 bit memory addresses
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LSP_to_Az(clock,reset,start,done,lsp_az_addr1,lsp_az_addr2,abs_in,abs_out,negate_out,negate_in,L_shr_outa,
							L_shr_outb,L_shr_in,L_sub_outa,L_sub_outb,L_sub_in,norm_L_out,norm_L_in,norm_L_start,
							norm_L_done,L_shl_outa,L_shl_outb,L_shl_in,L_shl_start,L_shl_done,L_mult_outa,L_mult_outb,L_mult_in,
							L_mult_overflow,L_mac_outa,L_mac_outb,L_mac_outc,L_mac_in,L_mac_overflow,mult_outa,mult_outb,mult_in,
							mult_overflow,L_add_outa,L_add_outb,L_add_overflow,L_add_in,sub_outa,sub_outb,sub_in,sub_overflow,
							scratch_mem_read_addr,scratch_mem_write_addr,scratch_mem_out,scratch_mem_write_en,scratch_mem_in,add_outa,add_outb,
							add_overflow,add_in,L_msu_outa,L_msu_outb,L_msu_outc,L_msu_overflow,L_msu_in);
							
	`include "paramList.v"
   input clock;
   input reset;
	input start;
	
	input [11:0] lsp_az_addr1,lsp_az_addr2;
	
	input norm_L_done,L_shl_done;
	input L_mult_overflow,mult_overflow,L_mac_overflow,L_add_overflow,sub_overflow,add_overflow,L_msu_overflow;
	input [15:0] norm_L_in,mult_in,sub_in,add_in;
	input [31:0] abs_in,negate_in,L_shr_in,L_sub_in,L_shl_in,L_mac_in,L_mult_in,L_add_in,L_msu_in;
	
	output reg done,norm_L_start,L_shl_start;
	output reg [15:0] L_shr_outb,L_shl_outb,sub_outa,sub_outb,add_outa,add_outb;
	output reg [31:0] abs_out,negate_out,L_shr_outa,L_sub_outa,L_sub_outb,norm_L_out,L_shl_outa,L_add_outa,L_add_outb;
	
	output reg [15:0] mult_outa,mult_outb,L_mult_outa,L_mult_outb,L_mac_outa,L_mac_outb,L_msu_outa,L_msu_outb;
	output reg [31:0] L_mac_outc,L_msu_outc;
	
	output reg [11:0] scratch_mem_read_addr,scratch_mem_write_addr;
	output reg [31:0] scratch_mem_out;
	output reg scratch_mem_write_en;
	input [31:0] scratch_mem_in;
	
	reg get_lsp_pol_start,get_lsp_pol_f_opt,get_lsp_pol_lsp_opt;
	wire get_lsp_pol_norm_L_start,get_lsp_pol_L_shl_start;
	wire get_lsp_pol_done;
	wire [31:0] get_lsp_pol_abs_out,get_lsp_pol_negate_out,get_lsp_pol_L_sub_outa,get_lsp_pol_L_sub_outb,get_lsp_pol_norm_L_out;
	wire [31:0] get_lsp_pol_L_shr_outa,get_lsp_pol_L_shl_outa;
	wire [15:0] get_lsp_pol_L_shl_outb,get_lsp_pol_L_shr_outb;
	
	wire [31:0] get_lsp_pol_L_mac_outc,get_lsp_pol_L_msu_outc;
	wire [15:0] get_lsp_pol_L_mac_outa,get_lsp_pol_L_mac_outb,get_lsp_pol_mult_outa,get_lsp_pol_mult_outb,get_lsp_pol_L_msu_outa,
					get_lsp_pol_L_msu_outb;
	wire [15:0] get_lsp_pol_L_mult_outa,get_lsp_pol_L_mult_outb;

	wire [31:0] get_lsp_pol_L_add_outa,get_lsp_pol_L_add_outb;
	wire [15:0] get_lsp_pol_sub_outa,get_lsp_pol_sub_outb,get_lsp_pol_add_outa,get_lsp_pol_add_outb;
	
	wire [11:0] get_lsp_pol_scratch_mem_write_addr,get_lsp_pol_scratch_mem_read_addr;
	wire get_lsp_pol_scratch_mem_write_en;
	wire [31:0] get_lsp_pol_scratch_mem_out;
	
	reg [11:0] get_lsp_pol_addr1;
	
	get_lsp_pol i_get_lsp_pol_1(.clock(clock),.reset(reset),.start(get_lsp_pol_start),.done(get_lsp_pol_done),
								.get_lsp_pol_addr1(lsp_az_addr1),.F_OPT(get_lsp_pol_f_opt),.LSP_OPT(get_lsp_pol_lsp_opt),
								.abs_in(abs_in),.abs_out(get_lsp_pol_abs_out),.negate_out(get_lsp_pol_negate_out),.negate_in(negate_in),
								.L_shr_outa(get_lsp_pol_L_shr_outa),.L_shr_outb(get_lsp_pol_L_shr_outb),.L_shr_in(L_shr_in),
								.L_sub_outa(get_lsp_pol_L_sub_outa),.L_sub_outb(get_lsp_pol_L_sub_outb),.L_sub_in(L_sub_in),
								.norm_L_out(get_lsp_pol_norm_L_out),.norm_L_in(norm_L_in),.norm_L_start(get_lsp_pol_norm_L_start),
								.norm_L_done(norm_L_done),
								.L_shl_outa(get_lsp_pol_L_shl_outa),.L_shl_outb(get_lsp_pol_L_shl_outb),.L_shl_in(L_shl_in),
								.L_shl_start(get_lsp_pol_L_shl_start),.L_shl_done(L_shl_done),
								.L_mult_outa(get_lsp_pol_L_mult_outa),.L_mult_outb(get_lsp_pol_L_mult_outb),.L_mult_in(L_mult_in),
								.L_mult_overflow(L_mult_overflow),
								.L_mac_outa(get_lsp_pol_L_mac_outa),.L_mac_outb(get_lsp_pol_L_mac_outb),.L_mac_outc(get_lsp_pol_L_mac_outc),
								.L_mac_in(L_mac_in),.L_mac_overflow(L_mac_overflow),
								.mult_outa(get_lsp_pol_mult_outa),.mult_outb(get_lsp_pol_mult_outb),.mult_in(mult_in),.mult_overflow(mult_overflow),
								.L_add_outa(get_lsp_pol_L_add_outa),.L_add_outb(get_lsp_pol_L_add_outb),.L_add_overflow(L_add_overflow),
								.L_add_in(L_add_in),
								.sub_outa(get_lsp_pol_sub_outa),.sub_outb(get_lsp_pol_sub_outb),.sub_in(sub_in),.sub_overflow(sub_overflow),
								.scratch_mem_read_addr(get_lsp_pol_scratch_mem_read_addr),.scratch_mem_write_addr(get_lsp_pol_scratch_mem_write_addr),
								.scratch_mem_out(get_lsp_pol_scratch_mem_out),.scratch_mem_write_en(get_lsp_pol_scratch_mem_write_en),
								.scratch_mem_in(scratch_mem_in),
								.add_outa(get_lsp_pol_add_outa),.add_outb(get_lsp_pol_add_outb),.add_overflow(add_overflow),.add_in(add_in),
								.L_msu_outa(get_lsp_pol_L_msu_outa),.L_msu_outb(get_lsp_pol_L_msu_outb),.L_msu_outc(get_lsp_pol_L_msu_outc),
								.L_msu_overflow(L_msu_overflow),.L_msu_in(L_msu_in)
		);
	
	reg [31:0] temp1,next_temp1,temp2,next_temp2,temp3,next_temp3,temp4,next_temp4;
	
	always@(posedge clock) begin
		if(reset)
			temp1 = 32'd0;
		else
			temp1 = next_temp1;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp2 = 32'd0;
		else
			temp2 = next_temp2;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp3 = 32'd0;
		else
			temp3 = next_temp3;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp4 = 32'd0;
		else
			temp4 = next_temp4;
	end
	
	reg [5:0] currentstate,nextstate;
	parameter init = 6'd0;
	parameter state1 = 6'd1;
	parameter state2 = 6'd2;
	parameter state3 = 6'd3;
	parameter state4 = 6'd4;
	parameter state5 = 6'd5;
	parameter state6 = 6'd6;
	parameter state7 = 6'd7;
	parameter state8 = 6'd8;
	parameter state9 = 6'd9;
	parameter state10 = 6'd10;
	parameter state11 = 6'd11;
	parameter state12 = 6'd12;
	parameter state13 = 6'd13;
	parameter state14 = 6'd14;
	
	reg [3:0] iterator1,iterator2,iterator3;
	reg [3:0] next_iterator1,next_iterator2,next_iterator3;
	
	always@(posedge clock) begin
		if(reset)
			iterator1 = 5;
		else
			iterator1 = next_iterator1;
	end
	
	always@(posedge clock) begin
		if(reset)
			iterator2 = 1;
		else
			iterator2 = next_iterator2;
	end
	
	always@(posedge clock) begin
		if(reset)
			iterator3 = 10;
		else
			iterator3 = next_iterator3;
	end
	
	always@(posedge clock) begin
		if(reset)
			currentstate = init;
		else
			currentstate = nextstate;
	end
	
	
	always@(*) begin
		
		nextstate = currentstate;
		next_iterator1 = iterator1;
		next_iterator2 = iterator2;
		next_iterator3 = iterator3;
		next_temp1 = temp1;
		next_temp2 = temp2;
		next_temp3 = temp3;
		next_temp4 = temp4;
		
		done = 1'd0;
		
		abs_out = get_lsp_pol_abs_out;
		
		negate_out = get_lsp_pol_negate_out;
		
		L_shr_outa = get_lsp_pol_L_shr_outa;
		L_shr_outb = get_lsp_pol_L_shr_outb;
		
		L_sub_outa = get_lsp_pol_L_sub_outa;
		L_sub_outb = get_lsp_pol_L_sub_outb;
		
		norm_L_out = get_lsp_pol_norm_L_out;
		norm_L_start = get_lsp_pol_norm_L_start;
		
		L_shl_outa = get_lsp_pol_L_shl_outa;
		L_shl_outb = get_lsp_pol_L_shl_outb;
		L_shl_start = get_lsp_pol_L_shl_start;
		
		L_mult_outa = get_lsp_pol_L_mult_outa;
		L_mult_outb = get_lsp_pol_L_mult_outb;
		
		L_mac_outa = get_lsp_pol_L_mac_outa;
		L_mac_outb = get_lsp_pol_L_mac_outb;
		L_mac_outc = get_lsp_pol_L_mac_outc;
		
		L_msu_outa = get_lsp_pol_L_msu_outa;
		L_msu_outb = get_lsp_pol_L_msu_outb;
		L_msu_outc = get_lsp_pol_L_msu_outc;
		
		mult_outa = get_lsp_pol_mult_outa;
		mult_outb = get_lsp_pol_mult_outb;
		
		sub_outa = get_lsp_pol_sub_outa;
		sub_outb = get_lsp_pol_sub_outb;
		
		L_add_outa = get_lsp_pol_L_add_outa;
		L_add_outb = get_lsp_pol_L_add_outb;
		
		add_outa = get_lsp_pol_add_outa;
		add_outb = get_lsp_pol_add_outb;
		
		scratch_mem_read_addr = get_lsp_pol_scratch_mem_read_addr;
		scratch_mem_write_addr = get_lsp_pol_scratch_mem_write_addr;
		scratch_mem_out = get_lsp_pol_scratch_mem_out;
		scratch_mem_write_en = get_lsp_pol_scratch_mem_write_en;
		
		get_lsp_pol_start = 0;
		get_lsp_pol_f_opt = 0;
		get_lsp_pol_lsp_opt = 0;		
		
		case(currentstate)
		
		init: begin
			if(start == 1) begin
					nextstate = state1;
				end
				else
					nextstate = init;
		end
		
		//Get_lsp_pol(&lsp[0],f1);
		state1: begin
			get_lsp_pol_f_opt = 1'd0;
			get_lsp_pol_lsp_opt = 1'd0;
			get_lsp_pol_addr1 = lsp_az_addr1;
			get_lsp_pol_start = 1'd1;
			nextstate = state2;
		end
		
		//Get_lsp_pol(&lsp[0],f1);
		state2: begin
			if(get_lsp_pol_done == 1) begin
				nextstate = state3;
			end
			else begin
				get_lsp_pol_f_opt = 1'd0;
				get_lsp_pol_lsp_opt = 1'd0;
				get_lsp_pol_addr1 = lsp_az_addr1;
				nextstate = state2;
			end
		end
		
		//Get_lsp_pol(&lsp[1],f2);
		state3: begin
			get_lsp_pol_f_opt = 1'd1;
			get_lsp_pol_lsp_opt = 1'd1;
			add_outa = lsp_az_addr1;
			add_outb = 'd1;
			next_temp1 = add_in;
			get_lsp_pol_addr1 = add_in;
			get_lsp_pol_start = 1'd1;
			nextstate = state4;
		end
		
		//Get_lsp_pol(&lsp[1],f2);
		state4: begin
			if(get_lsp_pol_done == 1) begin
				nextstate = state5;
			end
			else begin
				get_lsp_pol_f_opt = 1'd1;
				get_lsp_pol_lsp_opt = 1'd1;
				get_lsp_pol_addr1 = temp1;
				nextstate = state4;
			end
		end
		
		//for(i = 5; i > 0; i--);
		state5: begin
			//a[0] = 4096;
			if(iterator1 <= 0) begin
				scratch_mem_write_addr = {lsp_az_addr2[11:4],4'd0};
				scratch_mem_out = 'd4096;
				scratch_mem_write_en = 1'd1;
				next_iterator1 = 'd5;
				nextstate = state10;
			end
			//f1[i]
			else begin
				scratch_mem_read_addr = {INT_LPC_F1[11:4],1'd0,iterator1[2:0]};
				nextstate = state6;
			end
		end
		
		//f1[i-1]
		state6: begin
			next_temp1 = scratch_mem_in;
			sub_outa = iterator1;
			sub_outb = 'd1;
			scratch_mem_read_addr = {INT_LPC_F1[11:4],1'd0,sub_in[2:0]};
			nextstate = state7;
		end
		
		//f1[i] = L_add(f1[i],f1[i-1]);
		//f2[i]
		state7: begin
			L_add_outa = temp1;
			L_add_outb = scratch_mem_in;
			scratch_mem_write_addr = {INT_LPC_F1[11:4],1'd0,iterator1[2:0]};
			scratch_mem_out = L_add_in;
			scratch_mem_write_en = 1'd1;
			scratch_mem_read_addr = {INT_LPC_F1[11:4],1'd1,iterator1[2:0]};
			nextstate = state8;
		end
		
		//f2[i-1]
		state8: begin
			next_temp1 = scratch_mem_in;
			sub_outa = iterator1;
			sub_outb = 'd1;
			scratch_mem_read_addr = {INT_LPC_F1[11:4],1'd1,sub_in[2:0]};
			nextstate = state9;
		end
		
		//f2[i] = L_sub(f2[i],f2[i-1]);
		state9: begin
			L_sub_outa = temp1;
			L_sub_outb = scratch_mem_in;
			scratch_mem_write_addr = {INT_LPC_F1[11:4],1'd1,iterator1[2:0]};
			scratch_mem_out = L_sub_in;
			scratch_mem_write_en = 1'd1;
			sub_outa = iterator1;
			sub_outb = 'd1;
			next_iterator1 = sub_in;
			nextstate = state5;
		end
		
		//for(i=1,j=10;i<=5;i++,j--);
		state10: begin
			//reset iterators
			if(iterator2 > 5) begin
				done = 'd1;
				next_iterator2 = 'd1;
				next_iterator3 = 'd10;
				nextstate = init;
			end
			//f1[i]
			else begin
				scratch_mem_read_addr = {INT_LPC_F1[11:4],1'd0,iterator2[2:0]};
				nextstate = state11;
			end
		end
		
		//f2[i]
		state11: begin
			next_temp1 = scratch_mem_in;
			scratch_mem_read_addr = {INT_LPC_F1[11:4],1'd1,iterator2[2:0]};
			nextstate = state12;
		end
		
		//t0 = L_add(f1[i],f2[i]);
		//L_shr_r(t0,13);
		state12: begin
			next_temp2 = scratch_mem_in;
			L_add_outa = temp1;
			L_add_outb = scratch_mem_in;
			L_shr_outa = L_add_in;
			next_temp4 = L_add_in;
			L_shr_outb = 'd13;
			next_temp3 = L_shr_in;
			nextstate = state13;
		end
		
		//a[i] = extract_l(L_shr_r(t0,13));
		state13: begin
			if(temp4[12] == 1) begin
				L_add_outa = temp3;
				L_add_outb = 'd1;
				scratch_mem_write_addr = {lsp_az_addr2[11:4],iterator2};
				scratch_mem_out = L_add_in;
			end
			else begin
				scratch_mem_write_addr = {lsp_az_addr2[11:4],iterator2};
				scratch_mem_out = temp3;
			end
			scratch_mem_write_en = 1'd1;
			nextstate = state14;
		end
		
		//t0 = L_sub(f1[i],f2[i]);
		//a[j] = extract_l(L_shr_r(t0,13));
		state14: begin
			L_sub_outa = temp1;
			L_sub_outb = temp2;
			L_shr_outa = L_sub_in;
			L_shr_outb = 'd13;
			if(L_sub_in[12] == 1) begin
				L_add_outa = L_shr_in;
				L_add_outb = 'd1;
				scratch_mem_write_addr = {lsp_az_addr2[11:4],iterator3};
				scratch_mem_out = L_add_in;
			end
			else begin
				scratch_mem_write_addr = {lsp_az_addr2[11:4],iterator3};
				scratch_mem_out = L_shr_in;
			end
			scratch_mem_write_en = 1'd1;
			add_outa = iterator2;
			add_outb = 'd1;
			next_iterator2 = add_in;
			sub_outa = iterator3;
			sub_outb = 'd1;
			next_iterator3 = sub_in;
			nextstate = state10;
		end
		
	endcase
end
			
endmodule
