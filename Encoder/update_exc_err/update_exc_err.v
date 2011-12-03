`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:08:31 04/14/2011 
// Design Name: 
// Module Name:    update_exc_err 
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
module update_exc_err(clock,reset,start,done,gain_pit,T0,
								sub_outa,sub_outb,sub_in,
								L_shl_outa,L_shl_outb,L_shl_in,L_shl_start,L_shl_done,
								L_add_outa,L_add_outb,L_add_in,
								L_sub_outa,L_sub_outb,L_sub_in,
								add_outa,add_outb,add_in,
								L_mac_outa,L_mac_outb,L_mac_outc,L_mac_in,L_mac_overflow,
								L_mult_outa,L_mult_outb,L_mult_in,L_mult_overflow,
								mult_outa,mult_outb,mult_in,mult_overflow,
								L_msu_outa,L_msu_outb,L_msu_outc,L_msu_in,
								L_shr_outa,L_shr_outb,L_shr_in,
								scratch_mem_read_addr,scratch_mem_write_addr,
								scratch_mem_out,scratch_mem_in,
								scratch_mem_write_en,
								constant_mem_read_addr,constant_mem_in
    );
	 
	 `include "paramList.v"
	 `include "constants_param_list.v"
	 
	input clock,reset,start;
	output reg done;
	
	input [15:0] gain_pit,T0;
	
	input [15:0] sub_in,add_in;
	output reg [15:0] sub_outa,sub_outb,add_outa,add_outb;
	
	input mult_overflow;
	input [15:0] mult_in;
	output [15:0] mult_outa,mult_outb;
	
	input [31:0] L_add_in,L_sub_in;
	output reg [31:0] L_add_outa,L_add_outb,L_sub_outa,L_sub_outb;
	
	input L_mac_overflow;
	input [31:0] L_mac_in;
	output [15:0] L_mac_outa,L_mac_outb;
	output [31:0] L_mac_outc;
	
	input L_shl_done;
	input [31:0] L_shl_in;
	output reg L_shl_start;
	output reg [15:0] L_shl_outb;
	output reg [31:0] L_shl_outa;
	
	input L_mult_overflow;
	input [31:0] L_mult_in;
	output [15:0] L_mult_outa,L_mult_outb;
	
	input [31:0] L_msu_in;
	output reg [15:0] L_msu_outa,L_msu_outb;
	output reg [31:0] L_msu_outc;
	
	input [31:0] L_shr_in;
	output reg [15:0] L_shr_outb;
	output reg [31:0] L_shr_outa;
	
	input [31:0] scratch_mem_in,constant_mem_in;
	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_read_addr,scratch_mem_write_addr,constant_mem_read_addr;
	output reg [31:0] scratch_mem_out;

	reg [31:0] mpy_32_16_ina;
	reg [15:0] mpy_32_16_inb;
	wire [31:0] mpy_32_16_out;

	mpy_32_16 i_mpy_32_16(
					.var1(mpy_32_16_ina),.var2(mpy_32_16_inb),.out(mpy_32_16_out),
					.L_mult_outa(L_mult_outa),.L_mult_outb(L_mult_outb),.L_mult_overflow(L_mult_overflow),.L_mult_in(L_mult_in),
					.L_mac_outa(L_mac_outa),.L_mac_outb(L_mac_outb),.L_mac_outc(L_mac_outc),.L_mac_overflow(L_mac_overflow),.L_mac_in(L_mac_in),
					.mult_outa(mult_outa),.mult_outb(mult_outb),.mult_in(mult_in),.mult_overflow(mult_overflow));
					
	reg next_done;
	reg [15:0] next_i,i,next_zone1,zone1,next_zone2,zone2,next_n,n,next_hi,hi,next_lo,lo;
	reg [31:0] next_L_worst,L_worst,next_L_temp,L_temp,next_L_acc,L_acc;
	
	always@(posedge clock) begin
		if(reset)
			done = 'd0;
		else
			done = next_done;
	end
	
	always@(posedge clock) begin
		if(reset)
			i = 'd0;
		else
			i = next_i;
	end
	
	always@(posedge clock) begin
		if(reset)
			zone1 = 'd0;
		else
			zone1 = next_zone1;
	end
	
	always@(posedge clock) begin
		if(reset)
			zone2 = 'd0;
		else
			zone2 = next_zone2;
	end
	
	always@(posedge clock) begin
		if(reset)
			n = 'd0;
		else
			n = next_n;
	end
	
	always@(posedge clock) begin
		if(reset)
			hi = 'd0;
		else
			hi = next_hi;
	end
	
	always@(posedge clock) begin
		if(reset)
			lo = 'd0;
		else
			lo = next_lo;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_worst = 'd0;
		else
			L_worst = next_L_worst;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_temp = 'd0;
		else
			L_temp = next_L_temp;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_acc = 'd0;
		else
			L_acc = next_L_acc;
	end
	
	parameter INIT = 4'd0;
	parameter state1 = 4'd1;
	parameter state2 = 4'd2;
	parameter state3 = 4'd3;
	parameter state4 = 4'd4;
	parameter state5 = 4'd5;
	parameter state6 = 4'd6;
	parameter state7 = 4'd7;
	parameter state8 = 4'd8;
	parameter state9 = 4'd9;
	parameter state10 = 4'd10;
	parameter state11 = 4'd11;
	parameter state12 = 4'd12;
	parameter state13 = 4'd13;
	parameter done_state = 4'd14;
	
	reg [3:0] currentstate,nextstate;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = 'd0;
		else
			currentstate = nextstate;
	end
	
	always@(*)begin
		nextstate = currentstate;
		next_done = done;
		next_i = i;
		next_zone1 = zone1;
		next_zone2 = zone2;
		next_n = n;
		next_hi = hi;
		next_lo = lo;
		next_L_worst = L_worst;
		next_L_temp = L_temp;
		next_L_acc = L_acc;
		
		sub_outa = 'd0;
		sub_outb = 'd0;
		add_outa = 'd0;
		add_outb = 'd0;
		L_add_outa = 'd0;
		L_add_outb = 'd0;
		L_sub_outa = 'd0;
		L_sub_outb = 'd0;
		L_shl_outa = 'd0;
		L_shl_outb = 'd0;
		L_shl_start = 'd0;
		L_shr_outa = 'd0;
		L_shr_outb = 'd0;
		L_msu_outa = 'd0;
		L_msu_outb = 'd0;
		L_msu_outc = 'd0;
		
		
		scratch_mem_write_addr = 'd0;
		scratch_mem_read_addr = 'd0;
		scratch_mem_out = 'd0;
		scratch_mem_write_en = 'd0;
		
		constant_mem_read_addr = 'd0;
		
		mpy_32_16_ina = 'd0;
		mpy_32_16_inb = 'd0;
		
		case(currentstate)
			
			INIT: begin
				if(start) begin
					next_L_worst = 32'hffff_ffff;
					nextstate = state1;
				end
				else
					nextstate = INIT;
			end
			
			state1: begin
				sub_outa = T0;
				sub_outb = 'd40;
				next_n = sub_in;
				if(sub_in[15] == 'd1) begin
					scratch_mem_read_addr = {L_EXC_ERR[11:2],2'd0};
					nextstate = state2;
				end
				else
					nextstate = state6;
			end
				
			state2: begin
				next_hi = scratch_mem_in[31:16];
				L_shr_outa = scratch_mem_in;
				L_shr_outb = 'd1;
				L_msu_outa = scratch_mem_in[31:16];
				L_msu_outb = 'd16384;
				L_msu_outc = L_shr_in;
				next_lo = L_msu_in[15:0];
				mpy_32_16_ina = {scratch_mem_in[31:16],L_msu_in[15:0]};
				mpy_32_16_inb = gain_pit;
				next_L_temp = mpy_32_16_out;
				L_shl_outa = mpy_32_16_out;
				L_shl_outb = 'd1;
				L_shl_start = 'd1;
				nextstate = state3;
			end
			
			state3: begin
				if(L_shl_done == 'd1) begin
					L_add_outa = {16'd0,16'h4000};
					L_add_outb = L_shl_in;
					next_L_temp = L_add_in;
					L_sub_outa = L_add_in;
					L_sub_outb = L_worst;
					next_L_acc = L_sub_in;
					if(L_sub_in[31] != 'd1 && L_sub_in != 'd0)
						next_L_worst = L_add_in;
					next_hi = L_add_in[31:16];
					L_shr_outa = L_add_in;
					L_shr_outb = 'd1;
					L_msu_outa = L_add_in[31:16];
					L_msu_outb = 'd16384;
					L_msu_outc = L_shr_in;
					next_lo = L_msu_in[15:0];
					mpy_32_16_ina = {L_add_in[31:16],L_msu_in[15:0]};
					mpy_32_16_inb = gain_pit;
					next_L_temp = mpy_32_16_out;
					nextstate = state4;
				end
				else begin
					L_shl_outa = L_temp;
					L_shl_outb = 'd1;
					nextstate = state3;
				end
			end
			
			state4: begin
				L_shl_outa = L_temp;
				L_shl_outb = 'd1;
				L_shl_start = 'd1;
				nextstate = state5;
			end
			
			state5: begin
				if(L_shl_done == 'd1) begin
					L_add_outa = {16'd0,16'h4000};
					L_add_outb = L_shl_in;
					next_L_temp = L_add_in;
					L_sub_outa = L_add_in;
					L_sub_outb = L_worst;
					next_L_acc = L_sub_in;
					if(L_sub_in[31] != 'd1 && L_sub_in != 'd0)
						next_L_worst = L_add_in;
					next_i = 'd3;
					nextstate = state12;
				end
				else begin
					L_shl_outa = L_temp;
					L_shl_outb = 'd1;
					nextstate = state5;
				end
			end
			
			state6: begin
				constant_mem_read_addr = {TAB_ZONE[11:8],n[7:0]};
				nextstate = state7;
			end
			
			state7: begin
				next_zone1 = constant_mem_in[15:0];
				sub_outa = T0;
				sub_outb = 'd1;
				next_i = sub_in;
				constant_mem_read_addr = {TAB_ZONE[11:8],sub_in[7:0]};
				nextstate = state8;
			end
			
			state8: begin
				next_zone2 = constant_mem_in[15:0];
				next_i = zone1;
				nextstate = state9;
			end
			
			state9: begin
				if(i > zone2 && i[15] != 'd1) begin
					next_i = 'd3;
					nextstate = state12;
				end
				else begin
					scratch_mem_read_addr = {L_EXC_ERR[11:2],i[1:0]};
					nextstate = state10;
				end
			end
			
			state10: begin
				next_hi = scratch_mem_in[31:16];
				L_shr_outa = scratch_mem_in;
				L_shr_outb = 'd1;
				L_msu_outa = scratch_mem_in[31:16];
				L_msu_outb = 'd16384;
				L_msu_outc = L_shr_in;
				next_lo = L_msu_in[15:0];
				mpy_32_16_ina = {scratch_mem_in[31:16],L_msu_in[15:0]};
				mpy_32_16_inb = gain_pit;
				next_L_temp = mpy_32_16_out;
				L_shl_outa = mpy_32_16_out;
				L_shl_outb = 'd1;
				L_shl_start = 'd1;
				nextstate = state11;
			end
			
			state11: begin
				if(L_shl_done == 'd1) begin
					L_add_outa = {16'd0,16'h4000};
					L_add_outb = L_shl_in;
					next_L_temp = L_add_in;
					L_sub_outa = L_add_in;
					L_sub_outb = L_worst;
					if(L_sub_in[31] != 'd1 && L_sub_in != 'd0) begin
						next_L_worst = L_add_in;
					end
					add_outa = i;
					add_outb = 'd1;
					next_i = add_in;
					nextstate = state9;
				end
				else begin
					L_shl_outa = L_temp;
					L_shl_outb = 'd1;
					nextstate = state11;
				end
			end
			
			state12: begin
				if(i == 'd0) begin
					scratch_mem_write_addr = {L_EXC_ERR[11:2],2'd0};
					scratch_mem_out = L_worst;
					scratch_mem_write_en = 'd1;
					next_done = 'd1;
					nextstate = done_state;
				end
				else begin
					sub_outa = i;
					sub_outb = 'd1;
					scratch_mem_read_addr = {L_EXC_ERR[11:2],sub_in[1:0]};
					nextstate = state13;
				end
			end
			
			state13: begin
				scratch_mem_out = scratch_mem_in;
				scratch_mem_write_addr = {L_EXC_ERR[11:2],i[1:0]};
				scratch_mem_write_en = 'd1;
				sub_outa = i;
				sub_outb = 'd1;
				next_i = sub_in;
				nextstate = state12;
			end
			
			done_state: begin
				next_done = 'd0;
				next_i = 'd0;
				next_zone1 = 'd0;
				next_zone2 = 'd0;
				next_n = 'd0;
				next_hi = 'd0;
				next_lo = 'd0;
				next_L_worst = 'd0;
				next_L_temp = 'd0;
				next_L_acc = 'd0;
				nextstate = INIT;
			end
		endcase
	end
endmodule	
