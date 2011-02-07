`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:58:27 11/22/2010 
// Design Name: 
// Module Name:    LSP_to_Az 
// Project Name: 
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
module LSP_to_Az(clock,reset,start,done,abs_in,abs_out,negate_out,negate_in,L_shr_outa,
							L_shr_outb,L_shr_in,L_sub_outa,L_sub_outb,L_sub_in,norm_L_out,norm_L_in,norm_L_start,
							norm_L_done,L_shl_outa,L_shl_outb,L_shl_in,L_shl_start,L_shl_done,L_mult_outa,L_mult_outb,L_mult_in,
							L_mult_overflow,L_mac_outa,L_mac_outb,L_mac_outc,L_mac_in,L_mac_overflow,mult_outa,mult_outb,mult_in,
							mult_overflow,L_add_outa,L_add_outb,L_add_overflow,L_add_in,sub_outa,sub_outb,sub_in,sub_overflow,
							scratch_mem_read_addr,scratch_mem_write_addr,scratch_mem_out,scratch_mem_write_en,scratch_mem_in,add_outa,add_outb,
							add_overflow,add_in,L_msu_outa,L_msu_outb,L_msu_outc,L_msu_overflow,L_msu_in);
   input clock;
   input reset;
	input start;
	
	input norm_L_done,L_shl_done;
	input L_mult_overflow,mult_overflow,L_mac_overflow,L_add_overflow,sub_overflow,add_overflow,L_msu_overflow;
	input [15:0] norm_L_in,mult_in,sub_in,add_in;
	input [31:0] abs_in,negate_in,L_shr_in,L_sub_in,L_shl_in,L_mac_in,L_mult_in,L_add_in,L_msu_in;
	
	output reg done,norm_L_start,L_shl_start;
	output reg [15:0] L_shr_outb,L_shl_outb,sub_outa,sub_outb,add_outa,add_outb;
	output reg [31:0] abs_out,negate_out,L_shr_outa,L_sub_outa,L_sub_outb,norm_L_out,L_shl_outa,L_add_outa,L_add_outb;
	
	output reg [15:0] mult_outa,mult_outb,L_mult_outa,L_mult_outb,L_mac_outa,L_mac_outb,L_msu_outa,L_msu_outb;
	output reg [31:0] L_mac_outc,L_msu_outc;
	
	output reg [6:0] scratch_mem_read_addr,scratch_mem_write_addr;
	output reg [31:0] scratch_mem_out;
	output reg scratch_mem_write_en;
	input [31:0] scratch_mem_in;
	
	reg get_lsp_pol_start,get_lsp_pol_f_opt,get_lsp_pol_lsp_opt;
	wire get_lsp_pol_norm_L_start,get_lsp_pol_L_shl_start;
	wire get_lsp_pol_done;
	reg get_lsp_pol_norm_L_done,get_lsp_pol_L_shl_done;
	reg [31:0] get_lsp_pol_abs_in,get_lsp_pol_negate_in,get_lsp_pol_L_sub_in,get_lsp_pol_norm_L_in;
	reg [31:0] get_lsp_pol_L_shr_in,get_lsp_pol_L_shl_in;
	wire [31:0] get_lsp_pol_abs_out,get_lsp_pol_negate_out,get_lsp_pol_L_sub_outa,get_lsp_pol_L_sub_outb,get_lsp_pol_norm_L_out;
	wire [31:0] get_lsp_pol_L_shr_outa,get_lsp_pol_L_shl_outa;
	wire [15:0] get_lsp_pol_L_shl_outb,get_lsp_pol_L_shr_outb;
	
	wire get_lsp_pol_L_mult_overflow,get_lsp_pol_L_mac_overflow,get_lsp_pol_mult_overflow,get_lsp_pol_L_msu_overflow;
	reg [31:0] get_lsp_pol_L_mult_in,get_lsp_pol_L_mac_in,get_lsp_pol_L_msu_in;
	reg [15:0] get_lsp_pol_mult_in;
	wire [31:0] get_lsp_pol_L_mac_outc,get_lsp_pol_L_msu_outc;
	wire [15:0] get_lsp_pol_L_mac_outa,get_lsp_pol_L_mac_outb,get_lsp_pol_mult_outa,get_lsp_pol_mult_outb,get_lsp_pol_L_msu_outa,get_lsp_pol_L_msu_outb;
	wire [15:0] get_lsp_pol_L_mult_outa,get_lsp_pol_L_mult_outb;

	wire get_lsp_pol_L_add_overflow,get_lsp_pol_sub_overflow,get_lsp_pol_add_overflow;
	reg [31:0] get_lsp_pol_L_add_in;
	wire [31:0] get_lsp_pol_L_add_outa,get_lsp_pol_L_add_outb;
	reg [15:0] get_lsp_pol_sub_in,get_lsp_pol_add_in;
	wire [15:0] get_lsp_pol_sub_outa,get_lsp_pol_sub_outb,get_lsp_pol_add_outa,get_lsp_pol_add_outb;
	
	wire [6:0] get_lsp_pol_scratch_mem_write_addr,get_lsp_pol_scratch_mem_read_addr;
	wire get_lsp_pol_scratch_mem_write_en;
	reg [31:0] get_lsp_pol_scratch_mem_in;
	wire [31:0] get_lsp_pol_scratch_mem_out;
	
	get_lsp_pol i_get_lsp_pol_1(.clock(clock),.reset(reset),.start(get_lsp_pol_start),.F_OPT(get_lsp_pol_f_opt),.LSP_OPT(get_lsp_pol_lsp_opt),
								.done(get_lsp_pol_done),.abs_in(get_lsp_pol_abs_in),.abs_out(get_lsp_pol_abs_out),.negate_out(get_lsp_pol_negate_out),
								.negate_in(get_lsp_pol_negate_in),.L_shr_outa(get_lsp_pol_L_shr_outa),.L_shr_outb(get_lsp_pol_L_shr_outb),
								.L_shr_in(get_lsp_pol_L_shr_in),.L_sub_outa(get_lsp_pol_L_sub_outa),.L_sub_outb(get_lsp_pol_L_sub_outb),
								.L_sub_in(get_lsp_pol_L_sub_in),.norm_L_out(get_lsp_pol_norm_L_out),.norm_L_in(get_lsp_pol_norm_L_in),
								.norm_L_start(get_lsp_pol_norm_L_start),.norm_L_done(get_lsp_pol_norm_L_done),.L_shl_outa(get_lsp_pol_L_shl_outa),
								.L_shl_outb(get_lsp_pol_L_shl_outb),.L_shl_in(get_lsp_pol_L_shl_in),.L_shl_start(get_lsp_pol_L_shl_start),
								.L_shl_done(get_lsp_pol_L_shl_done),.L_mult_outa(get_lsp_pol_L_mult_outa),.L_mult_outb(get_lsp_pol_L_mult_outb),
								.L_mult_in(get_lsp_pol_L_mult_in),.L_mult_overflow(get_lsp_pol_L_mult_overflow),.L_mac_outa(get_lsp_pol_L_mac_outa),
								.L_mac_outb(get_lsp_pol_L_mac_outb),.L_mac_outc(get_lsp_pol_L_mac_outc),.L_mac_in(get_lsp_pol_L_mac_in),
								.L_mac_overflow(get_lsp_pol_L_mac_overflow),.mult_outa(get_lsp_pol_mult_outa),.mult_outb(get_lsp_pol_mult_outb),
								.mult_in(get_lsp_pol_mult_in),.mult_overflow(get_lsp_pol_mult_overflow),.L_add_outa(get_lsp_pol_L_add_outa),
								.L_add_outb(get_lsp_pol_L_add_outb),.L_add_overflow(get_lsp_pol_L_add_overflow),.L_add_in(get_lsp_pol_L_add_in),
								.sub_outa(get_lsp_pol_sub_outa),.sub_outb(get_lsp_pol_sub_outb),.sub_in(get_lsp_pol_sub_in),
								.sub_overflow(get_lsp_pol_sub_overflow),.scratch_mem_read_addr(get_lsp_pol_scratch_mem_read_addr),
								.scratch_mem_write_addr(get_lsp_pol_scratch_mem_write_addr),.scratch_mem_out(get_lsp_pol_scratch_mem_out),
								.scratch_mem_write_en(get_lsp_pol_scratch_mem_write_en),.scratch_mem_in(get_lsp_pol_scratch_mem_in),
								.add_outa(get_lsp_pol_add_outa),.add_outb(get_lsp_pol_add_outb),.add_overflow(get_lsp_pol_add_overflow),
								.add_in(get_lsp_pol_add_in),.L_msu_outa(get_lsp_pol_L_msu_outa),.L_msu_outb(get_lsp_pol_L_msu_outb),
								.L_msu_outc(get_lsp_pol_L_msu_outc),.L_msu_overflow(get_lsp_pol_L_msu_overflow),.L_msu_in(get_lsp_pol_L_msu_in));
	
	reg [31:0] temp1,next_temp1,temp2,next_temp2,temp3,next_temp3;
	
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
	
	parameter LSP_A = 3'd4;
	parameter LSP_F = 2'd1;
		
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
		get_lsp_pol_norm_L_done = norm_L_done;
		get_lsp_pol_L_shl_done = L_shl_done;
		get_lsp_pol_abs_in = abs_in;
		get_lsp_pol_negate_in = negate_in;
		get_lsp_pol_L_sub_in = L_sub_in;
		get_lsp_pol_norm_L_in = norm_L_in;
		get_lsp_pol_L_shr_in = L_shr_in;
		get_lsp_pol_L_shl_in = L_shl_in;
		get_lsp_pol_L_mult_in = L_mult_in;
		get_lsp_pol_L_mac_in = L_mac_in;
		get_lsp_pol_L_msu_in = L_msu_in;
		get_lsp_pol_mult_in = mult_in;
		get_lsp_pol_L_add_in = L_add_in;
		get_lsp_pol_sub_in = sub_in;
		get_lsp_pol_add_in = add_in;
		get_lsp_pol_scratch_mem_in = scratch_mem_in;
		
		
		case(currentstate)
		
		init: begin
			if(start == 1) begin
					nextstate = state1;
				end
				else
					nextstate = init;
		end
			
		state1: begin
			get_lsp_pol_f_opt = 1'd0;
			get_lsp_pol_lsp_opt = 1'd0;
			get_lsp_pol_start = 1'd1;
			nextstate = state2;
		end
		
		state2: begin
			if(get_lsp_pol_done == 1) begin
				nextstate = state3;
			end
			else begin
				get_lsp_pol_f_opt = 1'd0;
				get_lsp_pol_lsp_opt = 1'd0;
				nextstate = state2;
			end
		end
		
		state3: begin
			get_lsp_pol_f_opt = 1'd1;
			get_lsp_pol_lsp_opt = 1'd1;
			get_lsp_pol_start = 1'd1;
			nextstate = state4;
		end
		
		state4: begin
			if(get_lsp_pol_done == 1) begin
				nextstate = state5;
			end
			else begin
				get_lsp_pol_f_opt = 1'd1;
				get_lsp_pol_lsp_opt = 1'd1;
				nextstate = state4;
			end
		end
		
		state5: begin
			if(iterator1 <= 0) begin
				scratch_mem_write_addr = {LSP_A,4'd0};
				scratch_mem_out = 'd4096;
				scratch_mem_write_en = 1'd1;
				next_iterator1 = 5;
				nextstate = state9;
			end
			else begin
				scratch_mem_read_addr = {LSP_F,1'd0,iterator1};
				next_temp1 = scratch_mem_in;
				nextstate = state6;
			end
		end
		
		state6: begin
			sub_outa = iterator1;
			sub_outb = 'd1;
			scratch_mem_read_addr = {LSP_F,1'd0,sub_in};
			L_add_outa = temp1;
			L_add_outb = scratch_mem_in;
			scratch_mem_write_addr = {LSP_F,1'd0,iterator1};
			scratch_mem_out = L_add_in;
			scratch_mem_write_en = 1'd1;
			nextstate = state7;
		end
		
		state7: begin
			scratch_mem_read_addr = {LSP_F,1'd1,iterator1};
			next_temp1 = scratch_mem_in;
			nextstate = state8;
		end
		
		state8: begin
			sub_outa = iterator1;
			sub_outb = 'd1;
			scratch_mem_read_addr = {LSP_F,1'd1,sub_in};
			L_sub_outa = temp1;
			L_sub_outb = scratch_mem_in;
			scratch_mem_write_addr = {LSP_F,1'd1,iterator1};
			scratch_mem_out = L_sub_in;
			scratch_mem_write_en = 1'd1;
			next_iterator1 = sub_in;
			nextstate = state5;
		end
		
		state9: begin
			if(iterator2 > 5) begin
				done = 1'd1;
				next_iterator2 = 1;
				next_iterator3 = 10;
				nextstate = init;
			end
			else begin
				scratch_mem_read_addr = {LSP_F,1'd0,iterator1};
				next_temp1 = scratch_mem_in;
				nextstate = state10;
			end
		end
		
		state10: begin
			scratch_mem_read_addr = {LSP_F,1'd1,iterator1};
			L_add_outa = temp1;
			L_add_outb = scratch_mem_in;
			next_temp2 = scratch_mem_in;
			L_shr_outa = L_add_in;
			L_shr_outb = 'd13;
			next_temp3 = L_shr_in;
			if(L_shr_in & 32'h0000_1000)
				nextstate = state11;
			else
				nextstate = state12;
		end
		
		state11: begin
			L_add_outa = temp3;
			L_add_outb = 'd1;
			next_temp3 = L_add_in;
			nextstate = state12;
		end
		
		state12: begin
			scratch_mem_write_addr = {LSP_A,iterator2};
			scratch_mem_out = temp3[15:0];
			scratch_mem_write_en = 1'd1;
			L_sub_outa = temp1;
			L_sub_outb = temp2;
			L_shr_outa = L_sub_in;
			L_shr_outb = 'd13;
			next_temp3 = L_shr_in;
			if(L_shr_in & 32'h0000_1000)
				nextstate = state13;
			else
				nextstate = state14;
		end
		
		state13: begin
			L_add_outa = temp3;
			L_add_outb = 'd1;
			next_temp3 = L_add_in;
			nextstate = state14;
		end
		
		state14: begin
			scratch_mem_write_addr = {LSP_A,iterator3};
			scratch_mem_out = temp3[15:0];
			scratch_mem_write_en = 1'd1;
			add_outa = iterator2;
			add_outb = 'd1;
			next_iterator2 = add_in;
			sub_outa = iterator3;
			sub_outb = 'd1;
			next_iterator3 = sub_in;
			nextstate = state9;
		end
	endcase
end
			
endmodule
