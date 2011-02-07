`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:18:34 11/16/2010 
// Design Name: 
// Module Name:    get_lsp_pol 
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
module get_lsp_pol(clock,reset,start,F_OPT,LSP_OPT,done,abs_in,abs_out,negate_out,
								negate_in,L_shr_outa,L_shr_outb,L_shr_in,L_sub_outa,L_sub_outb,L_sub_in,norm_L_out,norm_L_in,norm_L_start,
								norm_L_done,L_shl_outa,L_shl_outb,L_shl_in,L_shl_start,L_shl_done,L_mult_outa,L_mult_outb,L_mult_in,
								L_mult_overflow,L_mac_outa,L_mac_outb,L_mac_outc,L_mac_in,L_mac_overflow,mult_outa,mult_outb,mult_in,
								mult_overflow,L_add_outa,L_add_outb,L_add_overflow,L_add_in,sub_outa,sub_outb,sub_in,sub_overflow,
								scratch_mem_read_addr,scratch_mem_write_addr,scratch_mem_out,scratch_mem_write_en,scratch_mem_in,add_outa,add_outb,
								add_overflow,add_in,L_msu_outa,L_msu_outb,L_msu_outc,L_msu_overflow,L_msu_in);
					
	`include "paramList.v"
   input clock;
   input reset;
   input start;
	input F_OPT,LSP_OPT;
	input norm_L_done,L_shl_done;
	input L_mult_overflow,mult_overflow,L_mac_overflow,L_add_overflow,sub_overflow,add_overflow,L_msu_overflow;
	input [15:0] mult_in,sub_in,add_in;
	input [31:0] abs_in,negate_in,L_shr_in,L_sub_in,L_shl_in,L_mac_in,L_mult_in,L_add_in,L_msu_in,norm_L_in;
	
	output reg done,norm_L_start,L_shl_start;
	output reg [15:0] L_shr_outb,L_shl_outb,sub_outa,sub_outb,add_outa,add_outb;
	output reg [31:0] abs_out,negate_out,L_shr_outa,L_sub_outa,L_sub_outb,norm_L_out,L_shl_outa,L_add_outa,L_add_outb;
	
	output reg [15:0] mult_outa,mult_outb,L_mult_outa,L_mult_outb,L_mac_outa,L_mac_outb,L_msu_outa,L_msu_outb;
	output reg [31:0] L_mac_outc,L_msu_outc;
	
	output reg [6:0] scratch_mem_read_addr,scratch_mem_write_addr;
	output reg [31:0] scratch_mem_out;
	output reg scratch_mem_write_en;
	input [31:0] scratch_mem_in;
	
								
								
	reg mpy_32_16_L_mult_overflow, mpy_32_16_L_mac_overflow, mpy_32_16_mult_overflow;
	reg [31:0] mpy_32_16_ina;
	reg [15:0] mpy_32_16_inb;
	wire [15:0] mpy_32_16_L_mult_outa, mpy_32_16_L_mult_outb, mpy_32_16_L_mac_outa, mpy_32_16_L_mac_outb;
	wire [15:0] mpy_32_16_mult_outa, mpy_32_16_mult_outb;
	wire [31:0] mpy_32_16_L_mac_outc, mpy_32_16_out;
	reg [31:0] mpy_32_16_L_mult_in, mpy_32_16_L_mac_in;
	reg [15:0] mpy_32_16_mult_in;
	 
	
	mpy_32_16 i_mpy_32_16(.var1(mpy_32_16_ina),.var2(mpy_32_16_inb),.out(mpy_32_16_out),.L_mult_outa(mpy_32_16_L_mult_outa),
									.L_mult_outb(mpy_32_16_L_mult_outb),.L_mult_overflow(mpy_32_16_L_mult_overflow),
									.L_mult_in(mpy_32_16_L_mult_in),.L_mac_outa(mpy_32_16_L_mac_outa),.L_mac_outb(mpy_32_16_L_mac_outb),
									.L_mac_outc(mpy_32_16_L_mac_outc),.L_mac_overflow(mpy_32_16_L_mac_overflow),
									.L_mac_in(mpy_32_16_L_mac_in),.mult_outa(mpy_32_16_mult_outa),.mult_outb(mpy_32_16_mult_outb),
									.mult_in(mpy_32_16_mult_in),.mult_overflow(mult_32_16_mult_overflow));
	
	reg [31:0] temp1,next_temp1,temp2,next_temp2;
	
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
		
	reg [3:0] iterator1,iterator2,f_iterator,lsp_iterator;
	reg [3:0] next_iterator1,next_iterator2,next_f_iterator,next_lsp_iterator;
	
	always@(posedge clock) begin
		if(reset)
			iterator1 = 2;
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
			f_iterator = 2;
		else
			f_iterator = next_f_iterator;
	end
	
	always@(posedge clock) begin
		if(reset)
			lsp_iterator = 0;
		else
			lsp_iterator = next_lsp_iterator;
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
		next_f_iterator = f_iterator;
		next_lsp_iterator = lsp_iterator;
		next_temp1 = temp1;
		next_temp2 = temp2;
		
		done = 1'd0;
		
		abs_out = 32'd0;
		
		negate_out = 32'd0;
		
		L_shr_outa = 32'd0;
		L_shr_outb = 16'd0;
		
		mpy_32_16_ina = 32'd0;
		mpy_32_16_inb = 32'd0;
		mpy_32_16_L_mult_in = 32'd0;
		mpy_32_16_mult_in = 32'd0;
		mpy_32_16_L_mac_in = 32'd0;
		
		L_sub_outa = 32'd0;
		L_sub_outb = 32'd0;
		
		norm_L_out = 32'd0;
		norm_L_start = 1'd0;
		
		L_shl_outa = 32'd0;
		L_shl_outb = 16'd0;
		L_shl_start = 1'd0;
		
		L_mult_outa = 16'd0;
		L_mult_outb = 16'd0;
		
		L_mac_outa = 16'd0;
		L_mac_outb = 16'd0;
		L_mac_outc = 32'd0;
		
		L_msu_outa = 16'd0;
		L_msu_outb = 16'd0;
		L_msu_outc = 32'd0;
		
		mult_outa = 16'd0;
		mult_outb = 16'd0;
		
		sub_outa = 16'd0;
		sub_outb = 16'd0;
		
		L_add_outa = 32'd0;
		L_add_outb = 32'd0;
		
		add_outa = 16'd0;
		add_outb = 16'd0;
		
		scratch_mem_read_addr = 'd0;
		scratch_mem_write_addr = 'd0;
		scratch_mem_out = 'd0;
		scratch_mem_write_en = 'd0;
		
		case(currentstate)
				
			
			init: begin
				if(start == 1) begin
					next_lsp_iterator = LSP_OPT;
					
					nextstate = state1;
				end
				else
					nextstate = init;
			end
			
			state1: begin
				L_mult_outa = 'd4096;
				L_mult_outb = 'd2048;
				scratch_mem_write_addr = {LSP_F[1:0],F_OPT,4'd0};
				scratch_mem_out = L_mult_in;
				scratch_mem_write_en = 1'd1;
				nextstate = state2;
			end
			
			state2: begin
				L_msu_outc = 32'h0;
				scratch_mem_read_addr = {LSP_TEMP,lsp_iterator};
				L_msu_outa = scratch_mem_in;
				L_msu_outb = 'd512;
				scratch_mem_write_addr = {LSP_F,F_OPT,4'd1};
				scratch_mem_out = L_msu_in;
				scratch_mem_write_en = 1'd1;
				add_outa = lsp_iterator;
				add_outb = 2;
				next_lsp_iterator = add_in;
				nextstate = state3;
			end
			
			state3: begin
				if(iterator1 > 5) begin
					done = 1'd1;
					next_iterator1 = 2;
					nextstate = init;
				end
				else begin
					sub_outa = f_iterator;
					sub_outb = 2;
					scratch_mem_read_addr = {LSP_F[1:0],F_OPT,sub_in[3:0]};
					scratch_mem_out = scratch_mem_in;
					scratch_mem_write_addr = {LSP_F,F_OPT,f_iterator};
					scratch_mem_write_en = 1'd1;
					nextstate = state4;
				end
			end
			
			state4: begin
				if(iterator2 >= iterator1) begin
					scratch_mem_read_addr = {LSP_F[1:0],F_OPT,f_iterator};
					next_temp1 = scratch_mem_in;
					next_iterator2 = 1;
					nextstate = state10;
				end
				else begin
					sub_outa = f_iterator;
					sub_outb = 1;
					scratch_mem_read_addr = {LSP_F,F_OPT,sub_in[3:0]};
					next_temp1 = scratch_mem_in;
					nextstate = state5;
				end
			end
			
			state5: begin
				scratch_mem_read_addr = {LSP_TEMP,lsp_iterator};
				mpy_32_16_ina = {temp1[31:16],1'd0,temp1[15:1]};
				mpy_32_16_inb = scratch_mem_in;
				mpy_32_16_L_mult_in = L_mult_in;
				mpy_32_16_mult_in = mult_in;
				mpy_32_16_L_mac_in = L_mac_in;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				L_shl_outa = mpy_32_16_out;
				next_temp1 = mpy_32_16_out;
				L_shl_outb = 'd1;
				L_shl_start = 1'd1;
				nextstate = state7;
			end
			
			state7: begin
				if(L_shl_done == 1) begin
					next_temp1 = L_shl_in;
					scratch_mem_read_addr = {LSP_F,F_OPT,f_iterator};
					next_temp2 = scratch_mem_in;
					nextstate = state8;
				end
				else begin
					L_shl_outa = temp1;
					L_shl_outb = 'd1;
					nextstate = state7;
				end
			end
			
			state8: begin
				sub_outa = f_iterator;
				sub_outb = 2;
				scratch_mem_read_addr = {LSP_F,F_OPT,sub_in[3:0]};
				L_add_outa = temp2;
				L_add_outb = scratch_mem_in;
				scratch_mem_write_addr = {LSP_F,F_OPT,f_iterator};
				L_sub_outa = L_add_in;
				L_sub_outb = temp1;
				scratch_mem_out = L_sub_in;
				scratch_mem_write_en = 1'd1;
				add_outa = iterator2;
				add_outb = 1;
				next_iterator2 = add_in;
				nextstate = state9;
			end
			
			state9: begin
				sub_outa = f_iterator;
				sub_outb = 1;
				next_f_iterator = sub_in[3:0];
				nextstate = state4;
			end
			
			state10: begin
				scratch_mem_read_addr = {LSP_TEMP,lsp_iterator};
				L_msu_outc = temp1;
				L_msu_outa = scratch_mem_in;
				L_msu_outb = 'd512;
				scratch_mem_write_addr = {LSP_F,F_OPT,f_iterator};
				scratch_mem_out = L_msu_in;
				scratch_mem_write_en = 1'd1;
				add_outa = f_iterator;
				add_outb = iterator1;
				next_f_iterator = add_in;
				nextstate = state11;
			end
			
			state11: begin
				add_outa = lsp_iterator;
				add_outb = 2;
				next_lsp_iterator = add_in;
				nextstate = state12;
			end
			
			state12: begin
				add_outa = iterator1;
				add_outb = 'd1;
				next_iterator1 = add_in;
				nextstate = state3;
			end
		endcase
	end
			
endmodule
