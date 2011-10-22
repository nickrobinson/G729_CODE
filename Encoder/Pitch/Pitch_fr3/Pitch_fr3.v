`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    23:15:41 04/18/2011 
// Module Name:    Pitch_fr3 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T
// Tool versions:  Xilinx ISE 12.4
// Description: 
//
// Dependencies: 	 Norm_Corr.v
//						 Interpol_3.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Pitch_fr3(clock,start,reset,done,exc,xn,h,L_subfr,t0_min,t0_max,i_subfr,pit_frac,lag,
						sub_outa,sub_outb,sub_in,
						add_outa,add_outb,add_in,
						L_add_outa,L_add_outb,L_add_in,
						L_sub_outa,L_sub_outb,L_sub_in,
						L_negate_out,L_negate_in,
						L_mac_outa,L_mac_outb,L_mac_outc,L_mac_in,
						L_msu_outa,L_msu_outb,L_msu_outc,L_msu_in,
						L_mult_outa,L_mult_outb,L_mult_in,
						L_shl_outa,L_shl_outb,L_shl_start,L_shl_done,L_shl_in,
						L_shr_outa,L_shr_outb,L_shr_in,
						mult_outa,mult_outb,mult_in,
						norm_l_out,norm_l_start,norm_l_in,norm_l_done,
						shr_outa,shr_outb,shr_in,
						scratch_mem_read_addr,scratch_mem_write_addr,
						scratch_mem_out,scratch_mem_in,
						scratch_mem_write_en,
						constant_mem_read_addr,constant_mem_in
    );
	 
	`include "constants_param_list.v"
	`include "paramList.v"

	input clock,start,reset;
	output reg done;
	
	input [11:0] exc;
	input [11:0] xn;
	input [11:0] h;
	input [15:0] L_subfr;
	input [15:0] t0_min;
	input [15:0] t0_max;
	input [15:0] i_subfr;
	
	output reg [15:0] pit_frac;
	output reg [15:0] lag;
	
	input [31:0] scratch_mem_in;
	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_write_addr,scratch_mem_read_addr;
	output reg [31:0] scratch_mem_out;
	
	input [15:0] sub_in;
	output reg [15:0] sub_outa,sub_outb;
	
	input [15:0] add_in;
	output reg [15:0] add_outa,add_outb;
	
	input [31:0] L_add_in;
	output reg [31:0] L_add_outa,L_add_outb;
	
	input [31:0] L_sub_in;
	output reg [31:0] L_sub_outa,L_sub_outb;
	
	input [31:0] L_negate_in;
	output reg [31:0] L_negate_out;
	
	input [31:0] L_mac_in;
	output reg [15:0] L_mac_outa,L_mac_outb;
	output reg [31:0] L_mac_outc;
	
	input [31:0] L_msu_in;
	output reg [15:0] L_msu_outa,L_msu_outb;
	output reg [31:0] L_msu_outc;
	
	input [31:0] L_mult_in;
	output reg [15:0] L_mult_outa,L_mult_outb;
	
	input L_shl_done;
	input [31:0] L_shl_in;
	output reg L_shl_start;
	output reg [15:0] L_shl_outb;
	output reg [31:0] L_shl_outa;
	
	input [31:0] L_shr_in;
	output reg [15:0] L_shr_outb;
	output reg [31:0] L_shr_outa;
	
	input [15:0] mult_in;
	output reg [15:0] mult_outa,mult_outb;
	
	input norm_l_done;
	input [15:0] norm_l_in;
	output reg norm_l_start;
	output reg [31:0] norm_l_out;
	
	input [15:0] shr_in;
	output reg [15:0] shr_outa,shr_outb;
	
	input [31:0] constant_mem_in;
	output reg [11:0] constant_mem_read_addr;
	
	reg next_done;
	
	reg [15:0] i,next_i,t_min,next_t_min,t_max,next_t_max,max,next_max,next_pit_frac,next_lag,frac,next_frac,
					corr,next_corr,corr_int,next_corr_int;
					
	reg [15:0] temp_t_min,next_temp_t_min,temp_t_max,next_temp_t_max;
	
	reg [15:0] temp16, next_temp16;
	
	reg norm_corr_start;
	wire [15:0] norm_corr_add_outa,norm_corr_add_outb;
	wire [31:0] norm_corr_L_add_outa,norm_corr_L_add_outb;
	wire [31:0] norm_corr_L_negate_out;
	wire [15:0] norm_corr_L_mac_outa,norm_corr_L_mac_outb;
	wire [31:0] norm_corr_L_mac_outc;
	wire [15:0] norm_corr_L_msu_outa,norm_corr_L_msu_outb;
	wire [31:0] norm_corr_L_msu_outc;
	wire [15:0] norm_corr_L_mult_outa,norm_corr_L_mult_outb;
	wire [31:0] norm_corr_L_shl_outa;
	wire [15:0] norm_corr_L_shl_outb;
	wire norm_corr_L_shl_start;
	wire [31:0] norm_corr_L_shr_outa;
	wire [15:0] norm_corr_L_shr_outb;
	wire [31:0] norm_corr_L_sub_outa,norm_corr_L_sub_outb;
	wire [15:0] norm_corr_mult_outa,norm_corr_mult_outb;
	wire [31:0] norm_corr_norm_l_out;
	wire norm_corr_norm_l_start;
	wire [15:0] norm_corr_shr_outa,norm_corr_shr_outb;
	wire [15:0] norm_corr_sub_outa,norm_corr_sub_outb;
	wire [11:0] norm_corr_constant_mem_read_addr;
	wire norm_corr_scratch_mem_write_en;
	wire [11:0] norm_corr_scratch_mem_read_addr;
	wire [11:0] norm_corr_scratch_mem_write_addr;
	wire [31:0] norm_corr_scratch_mem_out;
	wire norm_corr_done;
	
	Norm_Corr i_Norm_Corr(
						.clk(clock),.start(norm_corr_start),.reset(reset),.excAddr(exc),.xnAddr(xn),.hAddr(h),
						.t_min(t_min),.t_max(t_max),
						.addIn(add_in),.L_addIn(L_add_in),.L_macIn(L_mac_in),.L_msuIn(L_msu_in),.L_multIn(L_mult_in),
					  .L_negateIn(L_negate_in),.L_shlIn(L_shl_in),.L_shlDone(L_shl_done),.L_shrIn(L_shr_in),
					  .L_subIn(L_sub_in),.multIn(mult_in),.norm_lIn(norm_l_in),.norm_lDone(norm_l_done),.shrIn(shr_in),
					  .subIn(sub_in),
					  .constantMemIn(constant_mem_in),.memIn(scratch_mem_in),
					  .addOutA(norm_corr_add_outa),.addOutB(norm_corr_add_outb),
					  .L_addOutA(norm_corr_L_add_outa),.L_addOutB(norm_corr_L_add_outb),
					  .L_negateOut(norm_corr_L_negate_out),
					  .L_macOutA(norm_corr_L_mac_outa),.L_macOutB(norm_corr_L_mac_outb),.L_macOutC(norm_corr_L_mac_outc),
					  .L_msuOutA(norm_corr_L_msu_outa),.L_msuOutB(norm_corr_L_msu_outb),.L_msuOutC(norm_corr_L_msu_outc),
					  .L_multOutA(norm_corr_L_mult_outa),.L_multOutB(norm_corr_L_mult_outb),
					  .L_shlVar1Out(norm_corr_L_shl_outa),.L_shlNumShiftOut(norm_corr_L_shl_outb),.L_shlReady(norm_corr_L_shl_start),
					  .L_shrVar1Out(norm_corr_L_shr_outa),.L_shrNumShiftOut(norm_corr_L_shr_outb),
					  .L_subOutA(norm_corr_L_sub_outa),.L_subOutB(norm_corr_L_sub_outb),
					  .multOutA(norm_corr_mult_outa),.multOutB(norm_corr_mult_outb),
					  .norm_lVar1Out(norm_corr_norm_l_out),.norm_lReady(norm_corr_norm_l_start),
					  .shrVar1Out(norm_corr_shr_outa),.shrVar2Out(norm_corr_shr_outb),
					  .subOutA(norm_corr_sub_outa),.subOutB(norm_corr_sub_outb),
					  .constantMemAddr(norm_corr_constant_mem_read_addr),
					  .memWriteEn(norm_corr_scratch_mem_write_en),.memReadAddr(norm_corr_scratch_mem_read_addr),
					  .memWriteAddr(norm_corr_scratch_mem_write_addr),
					  .memOut(norm_corr_scratch_mem_out),.done(norm_corr_done));
	
	reg interpol_3_start;
	reg [11:0] interpol_3_xin;
	reg [15:0] interpol_3_fracin;
	
	wire interpol_3_done;
	wire [11:0] interpol_3_scratch_mem_read_addr,interpol_3_constant_mem_read_addr;
	wire [15:0] interpol_3_add_outa,interpol_3_add_outb,interpol_3_sub_outa,interpol_3_sub_outb;
	wire [15:0] interpol_3_L_mac_outa,interpol_3_L_mac_outb;
	wire [15:0] interpol_3_out;
	wire [31:0] interpol_3_L_mac_outc,interpol_3_L_add_outa,interpol_3_L_add_outb;
	
	
	Interpol_3 i_Interpol_3(
			.clk(clock),
			.reset(reset),
			.start(interpol_3_start),
			.x(interpol_3_xin),
			.frac(interpol_3_fracin),
			.inter_3(INTER_3[11:0]),
			.addIn(add_in),
			.subIn(sub_in),
			.L_addIn(L_add_in),
			.L_macIn(L_mac_in),
			.FSMdataInScratch(scratch_mem_in),
			.FSMdataInConstant(constant_mem_in),	
			.addOutA(interpol_3_add_outa),
			.addOutB(interpol_3_add_outb),
			.subOutA(interpol_3_sub_outa),
			.subOutB(interpol_3_sub_outb),
			.L_addOutA(interpol_3_L_add_outa),
			.L_addOutB(interpol_3_L_add_outb),
			.L_macOutA(interpol_3_L_mac_outa),
			.L_macOutB(interpol_3_L_mac_outb),
			.L_macOutC(interpol_3_L_mac_outc),
			.FSMreadAddrScratch(interpol_3_scratch_mem_read_addr),
			.FSMreadAddrConstant(interpol_3_constant_mem_read_addr),
			.returnS(interpol_3_out),
			.done(interpol_3_done)
		);
	
	
					
	always@(posedge clock) begin
		if(reset)
			done = 'd0;
		else
			done = next_done;
	end
	
	always@(posedge clock) begin
		if(reset)
			lag = 'd0;
		else
			lag = next_lag;
	end
	
	always@(posedge clock) begin
		if(reset)
			i = 'd0;
		else
			i = next_i;
	end
	
	always@(posedge clock) begin
		if(reset)
			t_min = 'd0;
		else
			t_min = next_t_min;
	end

	always@(posedge clock) begin
		if(reset)
			t_max = 'd0;
		else
			t_max = next_t_max;
	end
	
	always@(posedge clock) begin
		if(reset)
			max = 'd0;
		else
			max = next_max;
	end
	
	always@(posedge clock) begin
		if(reset)
			lag = 'd0;
		else
			lag = next_lag;
	end

	always@(posedge clock) begin
		if(reset)
			pit_frac = 'd0;
		else
			pit_frac = next_pit_frac;
	end
	
	always@(posedge clock) begin
		if(reset)
			frac = 'd0;
		else
			frac = next_frac;
	end

	always@(posedge clock) begin
		if(reset)
			corr = 'd0;
		else
			corr = next_corr;
	end

	always@(posedge clock) begin
		if(reset)
			corr_int = 'd0;
		else
			corr_int = next_corr_int;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_t_min = 'd0;
		else
			temp_t_min = next_temp_t_min;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_t_max = 'd0;
		else
			temp_t_max = next_temp_t_max;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp16 = 'd0;
		else
			temp16 = next_temp16;
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
	parameter done_state = 5'd15;
	
	reg [4:0] currentstate,nextstate;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = 'd0;
		else
			currentstate = nextstate;
	end

	always@(*) begin
		nextstate = currentstate;
		next_done = done;
		next_lag = lag;
		next_i = i;
		next_t_min = t_min;
		next_t_max = t_max;
		next_max = max;
		next_pit_frac = pit_frac;
		next_frac = frac;
		next_corr = corr;
		next_corr_int = corr_int;
		next_temp_t_min = temp_t_min;
		next_temp_t_max = temp_t_max;
		next_temp16 = temp16;
		
		sub_outa = 'd0;
		sub_outb = 'd0;
		add_outa = 'd0;
		add_outb = 'd0;
		
		L_add_outa = 'd0;
		L_add_outb = 'd0;
		L_sub_outa = 'd0;
		L_sub_outb = 'd0;
	
		L_negate_out = 'd0;
	
		L_mac_outa = 'd0;
		L_mac_outb = 'd0;
		L_mac_outc = 'd0;
	
		L_msu_outa = 'd0;
		L_msu_outb = 'd0;
		L_msu_outc = 'd0;
	
		L_mult_outa = 'd0;
		L_mult_outb = 'd0;
	
		L_shl_start = 'd0;
		L_shl_outb = 'd0;
		L_shl_outa = 'd0;
	
		L_shr_outb = 'd0;
		L_shr_outa = 'd0;
	
		mult_outa = 'd0;
		mult_outb = 'd0;
	
		norm_l_start = 'd0;
		norm_l_out = 'd0;
	
		shr_outa = 'd0;
		shr_outb = 'd0;
		
		scratch_mem_write_addr = 'd0;
		scratch_mem_read_addr = 'd0;
		scratch_mem_out = 'd0;
		scratch_mem_write_en = 'd0;
		
		constant_mem_read_addr = 'd0;
		
		norm_corr_start = 'd0;
		
		interpol_3_start = 'd0;
		interpol_3_xin = 'd0;
		interpol_3_fracin = 'd0;
		
		case(currentstate)
			
			INIT: begin
				if(start)
					nextstate = state1;
				else
					nextstate = INIT;
			end
			
			state1: begin
				//scratch_mem_read_addr = T0_MIN;
				nextstate = state2;
			end
			
			state2: begin
				next_temp_t_min = t0_min[15:0];
				sub_outa = t0_min[15:0];
				sub_outb = 'd4;
				next_t_min = sub_in;
				//scratch_mem_read_addr = T0_MAX;
				nextstate = state3;
			end
			
			state3: begin
				next_temp_t_max = t0_max[15:0];
				add_outa = t0_max[15:0];
				add_outb = 'd4;
				next_t_max = add_in;
				sub_outa = {5'd0,PITCH_FR3_CORR_V};
				sub_outb = t_min;
				next_corr = sub_in[11:0];
				norm_corr_start = 'd1;
				nextstate = state4;
			end
			
			state4: begin
				if(norm_corr_done == 'd1) begin
					nextstate = state5;
				end
				else begin
					add_outa = norm_corr_add_outa;
					add_outb = norm_corr_add_outb;
					L_add_outa = norm_corr_L_add_outa;
					L_add_outb = norm_corr_L_add_outb;
					L_negate_out = norm_corr_L_negate_out;
					L_mac_outa = norm_corr_L_mac_outa;
					L_mac_outb = norm_corr_L_mac_outb;
					L_mac_outc = norm_corr_L_mac_outc;
					L_msu_outa = norm_corr_L_msu_outa;
					L_msu_outb = norm_corr_L_msu_outb;
					L_msu_outc = norm_corr_L_msu_outc;
					L_mult_outa = norm_corr_L_mult_outa;
					L_mult_outb = norm_corr_L_mult_outb;
					L_shl_outa = norm_corr_L_shl_outa;
					L_shl_outb = norm_corr_L_shl_outb;
					L_shl_start = norm_corr_L_shl_start;
					L_shr_outa = norm_corr_L_shr_outa;
					L_shr_outb = norm_corr_L_shr_outb;
					L_sub_outa = norm_corr_L_sub_outa;
					L_sub_outb = norm_corr_L_sub_outb;
					mult_outa = norm_corr_mult_outa;
					mult_outb = norm_corr_mult_outb;
					norm_l_out = norm_corr_norm_l_out;
					norm_l_start = norm_corr_norm_l_start;
					shr_outa = norm_corr_shr_outa;
					shr_outb = norm_corr_shr_outb;
					sub_outa = norm_corr_sub_outa;
					sub_outb = norm_corr_sub_outb;
					constant_mem_read_addr = norm_corr_constant_mem_read_addr;
					scratch_mem_write_en = norm_corr_scratch_mem_write_en;
					scratch_mem_read_addr = norm_corr_scratch_mem_read_addr;
					scratch_mem_write_addr = norm_corr_scratch_mem_write_addr;
					scratch_mem_out = norm_corr_scratch_mem_out;
					nextstate = state4;
				end
			end
			
			state5: begin
				add_outa = corr;
				add_outb = temp_t_min;
				scratch_mem_read_addr = add_in[11:0];
				nextstate = state6;
			end
			
			state6: begin
				next_max = scratch_mem_in[15:0];
				next_lag = temp_t_min;
				add_outa = temp_t_min;
				add_outb = 'd1;
				next_i = add_in;
				nextstate = state7;
			end
			
			state7: begin
				if(i[15] != 'd1 && i>temp_t_max) begin
					sub_outa = lag;
					sub_outb = 'd84;
					if(i_subfr == 'd0 && sub_in[15] == 'd0 && sub_in != 'd0) begin
						// scratch_mem_write_addr = T0_FRAC;
						// scratch_mem_out = 'd0;
						// scratch_mem_write_en = 'd1;
						next_pit_frac = 'd0;
						next_lag = lag;
						next_done = 'd1;
						nextstate = done_state;
					end
					else begin
						add_outa = corr;
						add_outb = lag;
						next_temp16 = add_in;
						interpol_3_start = 'd1;
						interpol_3_xin = add_in[11:0];
						interpol_3_fracin = 16'hfffe;
						nextstate = state9;
					end
				end
				else begin
					add_outa = corr;
					add_outb = i;
					scratch_mem_read_addr = add_in[11:0];
					nextstate = state8;
				end
			end
			
			state8: begin
				sub_outa = scratch_mem_in[15:0];
				sub_outb = max;
				if(sub_in[15] != 'd1) begin
					next_max = scratch_mem_in[15:0];
					next_lag = i;
				end
				add_outa = i;
				add_outb = 'd1;
				next_i = add_in;
				nextstate = state7;
			end
			
			state9: begin
				if(interpol_3_done == 'd1) begin
					next_max = interpol_3_out;
					next_frac = 'hfffe;
					next_i = 'hffff;
					nextstate = state10;
				end
				else begin
					interpol_3_xin = temp16[11:0];
					interpol_3_fracin = 'hfffe;
					scratch_mem_read_addr = interpol_3_scratch_mem_read_addr;
					constant_mem_read_addr = interpol_3_constant_mem_read_addr;
					add_outa = interpol_3_add_outa;
					add_outb = interpol_3_add_outb;
					sub_outa = interpol_3_sub_outa;
					sub_outb = interpol_3_sub_outb;
					L_mac_outa = interpol_3_L_mac_outa;
					L_mac_outb = interpol_3_L_mac_outb;
					L_mac_outc = interpol_3_L_mac_outc;
					L_add_outa = interpol_3_L_add_outa;
					L_add_outb = interpol_3_L_add_outb;
					nextstate = state9;
				end
			end
			
			state10: begin
				if(i[15] == 'd0 && i > 'd2) begin
					sub_outa = frac;
					sub_outb = 'hfffe;
					if(sub_in == 'd0) begin
						nextstate = state12;
					end
					else begin
						nextstate = state13;
					end
				end
				else begin
					interpol_3_start = 'd1;
					interpol_3_xin = temp16[11:0];
					interpol_3_fracin = i;
					nextstate = state11;
				end
			end
			
			state11: begin
				if(interpol_3_done == 'd1) begin
					next_corr_int = interpol_3_out;
					sub_outa = interpol_3_out;
					sub_outb = max;
					if(sub_in[15] != 'd1 && sub_in != 'd0) begin
						next_max = interpol_3_out;
						next_frac = i;
					end
					add_outa = i;
					add_outb = 'd1;
					next_i = add_in;
					nextstate = state10;
				end
				else begin
					interpol_3_xin = temp16[11:0];
					interpol_3_fracin = i;
					scratch_mem_read_addr = interpol_3_scratch_mem_read_addr;
					constant_mem_read_addr = interpol_3_constant_mem_read_addr;
					add_outa = interpol_3_add_outa;
					add_outb = interpol_3_add_outb;
					sub_outa = interpol_3_sub_outa;
					sub_outb = interpol_3_sub_outb;
					L_mac_outa = interpol_3_L_mac_outa;
					L_mac_outb = interpol_3_L_mac_outb;
					L_mac_outc = interpol_3_L_mac_outc;
					L_add_outa = interpol_3_L_add_outa;
					L_add_outb = interpol_3_L_add_outb;
					nextstate = state11;
				end
			end
			
			state12: begin
				next_frac = 'd1;
				sub_outa = lag;
				sub_outb = 'd1;
				next_lag = sub_in;
				nextstate = state13;
			end
			
			state13: begin
				sub_outa = frac;
				sub_outb = 'd2;
				if(sub_in == 'd0) begin
					next_frac = 'hffff;
					add_outa = lag;
					add_outb = 'd1;
					next_lag = add_in;
				end
				nextstate = state14;
			end
			
			state14: begin
				// scratch_mem_write_addr = T0_FRAC;
				// scratch_mem_out = frac;
				// scratch_mem_write_en = 'd1;
				next_pit_frac = frac;
				next_lag = lag;
				next_done = 'd1;
				nextstate = done_state;
			end
			
			done_state: begin
				nextstate = INIT;
				next_done = 'd0;
				next_i = 0;
				next_t_min = 'd0;
				next_t_max = 'd0;
				next_max = 'd0;
				next_pit_frac = 'd0;
				next_lag = 'd0;
				next_frac = 'd0;
				next_corr = 'd0;
				next_corr_int = 'd0;
				next_temp_t_min = 'd0;
				next_temp_t_max = 'd0;
			end
		endcase
	end		
			
endmodule
