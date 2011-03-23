`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    20:54:24 10/25/2010  
// Module Name:    Levinson-Durbin_FSM  
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is the top_level FSM to perform the Levinson_Durbin algorithm, producing the A(z) 
//						and the RC coefficients
//						 
// Dependencies: 	 Mpy_32.v,Div_32.v,mpy_32_mux.v
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Updated A_T memory locations
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Levinson_Durbin_FSM(clock,reset,start,done,abs_in,abs_out,negate_out,negate_in,L_shr_outa,L_shr_outb,
									L_shr_in,L_sub_outa,L_sub_outb,L_sub_in,norm_L_out,norm_L_in,norm_L_start,norm_L_done,
									L_shl_outa,L_shl_outb,L_shl_in,L_shl_start,L_shl_done,L_mult_outa,L_mult_outb,L_mult_in,
									L_mult_overflow,L_mac_outa,L_mac_outb,L_mac_outc,L_mac_in,L_mac_overflow,mult_outa,mult_outb,mult_in,
									mult_overflow,L_add_outa,L_add_outb,L_add_overflow,L_add_in,sub_outa,sub_outb,sub_in,sub_overflow,
									scratch_mem_read_addr,scratch_mem_write_addr,scratch_mem_out,scratch_mem_write_en,scratch_mem_in,add_outa,add_outb,
									add_overflow,add_in);										
	`include "paramList.v"
	
   input clock;
   input reset;
   input start;
	input norm_L_done,L_shl_done;
	input L_mult_overflow,mult_overflow,L_mac_overflow,L_add_overflow,sub_overflow,add_overflow;
	input [15:0] norm_L_in,mult_in,sub_in,add_in;
	input [31:0] abs_in,negate_in,L_shr_in,L_sub_in,L_shl_in,L_mac_in,L_mult_in,L_add_in;
	
	output reg done,norm_L_start,L_shl_start;
	output reg [15:0] L_shr_outb,L_shl_outb,sub_outa,sub_outb,add_outa,add_outb;
	output reg [31:0] abs_out,negate_out,L_shr_outa,L_sub_outa,L_sub_outb,norm_L_out,L_shl_outa,L_add_outa,L_add_outb;
	
	output reg [15:0] mult_outa,mult_outb,L_mult_outa,L_mult_outb,L_mac_outa,L_mac_outb;
	output reg [31:0] L_mac_outc;
	
	output reg [11:0] scratch_mem_read_addr,scratch_mem_write_addr;
	output reg [31:0] scratch_mem_out;
	output reg scratch_mem_write_en;
	input [31:0] scratch_mem_in;
	
	reg mpy_32_start;
	reg mpy_32_L_mult_overflow, mpy_32_L_mac_overflow, mpy_32_mult_overflow;
	reg [15:0] mpy_32_mult_in;
	reg [31:0] mpy_32_ina, mpy_32_inb, mpy_32_L_mult_in, mpy_32_L_mac_in;	
   wire [15:0] mpy_32_L_mult_outa, mpy_32_L_mult_outb, mpy_32_L_mac_outa, mpy_32_L_mac_outb, mpy_32_mult_outa, mpy_32_mult_outb;
   wire [31:0] mpy_32_L_mac_outc, mpy_32_out;
	wire mpy_32_done;
	
	Mpy_32 i_Mpy_32(.clock(clock),.reset(reset),.start(mpy_32_start),.done(mpy_32_done),.var1(mpy_32_ina),.var2(mpy_32_inb),
							.out(mpy_32_out),.L_mult_outa(mpy_32_L_mult_outa),.L_mult_outb(mpy_32_L_mult_outb),
							.L_mult_overflow(mpy_32_L_mult_overflow),.L_mult_in(mpy_32_L_mult_in),.L_mac_outa(mpy_32_L_mac_outa),
							.L_mac_outb(mpy_32_L_mac_outb),.L_mac_outc(mpy_32_L_mac_outc),.L_mac_overflow(mpy_32_L_mac_overflow), 
							.L_mac_in(mpy_32_L_mac_in),.mult_outa(mpy_32_mult_outa),.mult_outb(mpy_32_mult_outb),
							.mult_in(mpy_32_mult_in),.mult_overflow(mpy_32_mult_overflow));
	
	reg div_32_start,div_32_L_shl_done;
	reg [15:0] div_32_mult_in,div_32_add_in;
	reg [31:0] div_32_ina, div_32_inb,div_32_subin,div_32_L_mult_in,div_32_L_mac_in,div_32_L_shl_in;
	wire div_32_done,div_32_L_mult_overflow,div_32_mult_overflow,div_32_L_mac_overflow,div_32_L_shl_start;
	wire [15:0] div_32_L_mult_outa,div_32_L_mult_outb,div_32_mult_outa,div_32_mult_outb,div_32_L_mac_outa,div_32_L_mac_outb,div_32_L_shl_outb;
	wire [15:0] div_32_add_outa,div_32_add_outb;
	wire [31:0] div_32_out,div_32_subouta,div_32_suboutb,div_32_L_mac_outc,div_32_L_shl_outa;
	reg [31:0] r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
	reg [31:0] nextr0,nextr1,nextr2,nextr3,nextr4,nextr5,nextr6,nextr7,nextr8,nextr9,nextr10;
							
	Div_32 i_Div_32(.clock(clock),.reset(reset),.start(div_32_start),.done(div_32_done),.num(div_32_ina),.denom(div_32_inb),.out(div_32_out),
							.subouta(div_32_subouta),.suboutb(div_32_suboutb),.subin(div_32_subin),.L_mult_outa(div_32_L_mult_outa),
							.L_mult_outb(div_32_L_mult_outb),.L_mult_in(div_32_L_mult_in),.L_mult_overflow(div_32_L_mult_overflow),.mult_outa(div_32_mult_outa),
							.mult_outb(div_32_mult_outb),.mult_in(div_32_mult_in),.mult_overflow(div_32_mult_overflow),.L_mac_outa(div_32_L_mac_outa),
							.L_mac_outb(div_32_L_mac_outb),.L_mac_outc(div_32_L_mac_outc),.L_mac_in(div_32_L_mac_in),.L_mac_overflow(div_32_L_mac_overflow),
							.L_shl_outa(div_32_L_shl_outa),.L_shl_outb(div_32_L_shl_outb),.L_shl_in(div_32_L_shl_in),.L_shl_start(div_32_L_shl_start),
							.L_shl_done(div_32_L_shl_done),.add_outa(div_32_add_outa),.add_outb(div_32_add_outb),.add_in(div_32_add_in));
							
	reg [3:0] r_mux_sel,a_mux_sel;
	wire [31:0] r_mux_out;
		
	mpy_32_mux i_r_mux(.in1(r1),.in2(r2),.in3(r3),.in4(r4),.in5(r5),.in6(r6),.in7(r7),.in8(r8),.in9(r9),.in10(r10),.sel(r_mux_sel),.out(r_mux_out));

	reg [31:0] temp1,next_temp1,temp2,next_temp2,alp,next_alp,temp3,next_temp3,k,next_k;
	reg [15:0] alp_exp,next_alp_exp,next_rc0;
	
	reg [31:0] mpyReg,nextmpyReg;
	reg mpyRegReset,mpyRegLd;
	

	
	
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
			alp_exp = 15'd0;
		else
			alp_exp = next_alp_exp;
	end
	
	always@(posedge clock) begin
		if(reset)
			alp = 32'd0;
		else
			alp = next_alp;
	end
	
	always@(posedge clock) begin
		if(reset)
			k = 32'd0;
		else
			k = next_k;
	end
	
	always@(posedge clock) begin
		if(reset)
			mpyReg = 32'd0;
		else if(mpyRegReset)
			mpyReg = 32'd0;
		else if(mpyRegLd)
			mpyReg = nextmpyReg;
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
	parameter state15 = 6'd15;
	parameter state16 = 6'd16;
	parameter state17 = 6'd17;
	parameter state18 = 6'd18;
	parameter state19 = 6'd19;
	parameter state20 = 6'd20;
	parameter state21 = 6'd21;
	parameter state22 = 6'd22;
	parameter state23 = 6'd23;
	parameter state24 = 6'd24;
	parameter state25 = 6'd25;
	parameter state26 = 6'd26;
	parameter state27 = 6'd27;
	parameter state28 = 6'd28;
	parameter state29 = 6'd29;
	parameter state30 = 6'd30;
	parameter state31 = 6'd31;
	parameter state32 = 6'd32;
	parameter state16_5 = 6'd33;
	parameter waitstate0 = 6'd34;
	parameter waitstate1 = 6'd35;
	parameter waitstate2 = 6'd36;
	parameter waitstate3 = 6'd37;
	parameter waitstate4 = 6'd38;
	parameter waitstate5 = 6'd39;
	parameter waitstate6 = 6'd40;
	parameter waitstate7 = 6'd41;
	parameter stateR0 = 6'd42;
	parameter stateR1 = 6'd43;
	parameter stateR2= 6'd44;
	parameter stateR3 = 6'd45;
	parameter stateR4 = 6'd46;
	parameter stateR5 = 6'd47;
	parameter stateR6 = 6'd48;
	parameter stateR7 = 6'd49;
	parameter stateR8 = 6'd50;
	parameter stateR9 = 6'd51;
	parameter stateR10 = 6'd52;
	parameter state15_5 = 6'd53;
	parameter L_shl_wait = 6'd54;
	

	reg [3:0] iterator1,iterator2,iterator3,iterator4,iterator5,iterator6;
	reg [3:0] next_iterator1,next_iterator2,next_iterator3,next_iterator4,next_iterator5,next_iterator6;
	
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
			iterator3 = 1;
		else
			iterator3 = next_iterator3;
	end
	
	always@(posedge clock) begin
		if(reset)
			iterator4 = 0;
		else
			iterator4 = next_iterator4;
	end
	
	always@(posedge clock) begin
		if(reset)
			iterator5 = 0;
		else
			iterator5 = next_iterator5;
	end
	
	always@(posedge clock) begin
		if(reset)
			iterator6 = 1;
		else
			iterator6 = next_iterator6;
	end
	
	always@(posedge clock) begin
		if(reset)
			currentstate = init;
		else
			currentstate = nextstate;
	end
	
	always@(posedge clock) begin
		if(reset)
			r0 = 0;
		else
			r0 = nextr0;
	end
	
	always@(posedge clock) begin
		if(reset)
			r1 = 0;
		else
			r1 = nextr1;
	end
	
	always@(posedge clock) begin
		if(reset)
			r2 = 0;
		else
			r2 = nextr2;
	end
	
	always@(posedge clock) begin
		if(reset)
			r2 = 0;
		else
			r2 = nextr2;
	end
	
	always@(posedge clock) begin
		if(reset)
			r3 = 0;
		else
			r3 = nextr3;
	end
	
	always@(posedge clock) begin
		if(reset)
			r4 = 0;
		else
			r4 = nextr4;
	end
	
	always@(posedge clock) begin
		if(reset)
			r5 = 0;
		else
			r5 = nextr5;
	end
	
	always@(posedge clock) begin
		if(reset)
			r6 = 0;
		else
			r6 = nextr6;
	end
	
	always@(posedge clock) begin
		if(reset)
			r7 = 0;
		else
			r7 = nextr7;
	end
	
	always@(posedge clock) begin
		if(reset)
			r8 = 0;
		else
			r8 = nextr8;
	end
	
	always@(posedge clock) begin
		if(reset)
			r9 = 0;
		else
			r9 = nextr9;
	end
	
	always@(posedge clock) begin
		if(reset)
			r10 = 0;
		else
			r10 = nextr10;
	end
	
	always@(*) begin
		
		nextstate = currentstate;
		next_iterator1 = iterator1;
		next_iterator2 = iterator2;
		next_iterator3 = iterator3;
		next_iterator4 = iterator4;
		next_iterator5 = iterator5;
		next_iterator6 = iterator6;
		next_temp1 = temp1;
		next_temp2 = temp2;
		next_temp3 = temp3;
		next_alp_exp = alp_exp;
		next_alp = alp;
		next_k = k;
		
		done = 1'd0;
		
		abs_out = 32'd0;
		
		div_32_ina = 32'd0;
		div_32_inb = 32'd0;
		div_32_start = 1'd0;
		div_32_subin = 32'd0;
		div_32_L_mult_in = 32'd0;
		div_32_mult_in = 32'd0;
		div_32_L_mac_in = 32'd0;
		div_32_L_shl_in = 32'd0;
		div_32_L_shl_done = L_shl_done;
		
		negate_out = 32'd0;
		
		L_shr_outa = 32'd0;
		L_shr_outb = 16'd0;
		
		mpy_32_ina = 32'd0;
		mpy_32_inb = 32'd0;
		mpy_32_start = 1'd0;
		mpy_32_L_mult_in = 32'd0;
		mpy_32_mult_in = 32'd0;
		mpy_32_L_mac_in = 32'd0;
		
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
		
		mult_outa = 16'd0;
		mult_outb = 16'd0;
		
		sub_outa = 16'd0;
		sub_outb = 16'd0;
		
		add_outa = 16'd0;
		add_outb = 16'd0;
		
		r_mux_sel = 0;
		a_mux_sel = 0;
		
		scratch_mem_read_addr = 'd0;
		scratch_mem_write_addr = 'd0;
		scratch_mem_out = 'd0;
		scratch_mem_write_en = 'd0;
		
		mpyRegReset = 0;
		mpyRegLd = 0;
		nextmpyReg = mpyReg;
		
		nextr0 = r0;
		nextr1 = r1;
		nextr2 = r2;
		nextr3 = r3;
		nextr4 = r4;
		nextr5 = r5;
		nextr6 = r6;
		nextr7 = r7;
		nextr8 = r8;
		nextr9 = r9;
		nextr10 = r10;
		
		case(currentstate)
				
			
			init: begin
				if(start == 1)
				begin
					nextstate = stateR0;
					mpyRegReset = 1;
					scratch_mem_read_addr = {LAG_WINDOW_R_PRIME[10:4],4'd0};
				end
				else
					nextstate = init;
			end
			
			stateR0:
			begin
				nextr0 = scratch_mem_in;
				scratch_mem_read_addr = {LAG_WINDOW_R_PRIME[10:4],4'd1};
				nextstate = stateR1;
			end
			
			stateR1:
			begin
				nextr1 = scratch_mem_in;
				scratch_mem_read_addr = {LAG_WINDOW_R_PRIME[10:4],4'd2};
				nextstate = stateR2;
			end
			
			stateR2:
			begin
				nextr2 = scratch_mem_in;
				scratch_mem_read_addr = {LAG_WINDOW_R_PRIME[10:4],4'd3};
				nextstate = stateR3;
			end
			
			stateR3:
			begin
				nextr3 = scratch_mem_in;
				scratch_mem_read_addr = {LAG_WINDOW_R_PRIME[10:4],4'd4};
				nextstate = stateR4;
			end

			stateR4:
			begin
				nextr4 = scratch_mem_in;
				scratch_mem_read_addr = {LAG_WINDOW_R_PRIME[10:4],4'd5};
				nextstate = stateR5;
			end

			stateR5:
			begin
				nextr5 = scratch_mem_in;
				scratch_mem_read_addr = {LAG_WINDOW_R_PRIME[10:4],4'd6};
				nextstate = stateR6;
			end
			
			stateR6:
			begin
				nextr6 = scratch_mem_in;
				scratch_mem_read_addr = {LAG_WINDOW_R_PRIME[10:4],4'd7};
				nextstate = stateR7;
			end	

			stateR7:
			begin
				nextr7 = scratch_mem_in;
				scratch_mem_read_addr = {LAG_WINDOW_R_PRIME[10:4],4'd8};
				nextstate = stateR8;
			end	

			stateR8:
			begin
				nextr8 = scratch_mem_in;
				scratch_mem_read_addr = {LAG_WINDOW_R_PRIME[10:4],4'd9};
				nextstate = stateR9;
			end		

			stateR9:
			begin
				nextr9 = scratch_mem_in;
				scratch_mem_read_addr = {LAG_WINDOW_R_PRIME[10:4],4'd10};
				nextstate = stateR10;
			end

			stateR10:
			begin
				nextr10 = scratch_mem_in;
				nextstate = state1;
			end			
			
			state1: begin
				abs_out = {r1[31:16],r1[14:0],1'd0};
				next_temp1 = abs_in;
				div_32_ina = abs_in;
				div_32_inb = r0;
				div_32_start = 1'd1;
				nextstate = state2;
			end
			
			state2: begin
				if(div_32_done == 1) begin
					div_32_L_shl_in = L_shl_in;
					if(r1[31] == 0) begin
						negate_out = div_32_out;
						next_temp2 = negate_in;
						next_k = {negate_in[31:16],1'd0,negate_in[15:1]};
						nextstate = state3;
					end
					else begin
						next_k = {div_32_out[31:16],1'd0,div_32_out[15:1]};
						next_temp2 = div_32_out;
						nextstate = state3;
					end
				end
				else begin
					div_32_ina = temp1;
					div_32_inb = r0;
					div_32_subin = L_sub_in;
					div_32_L_mult_in = L_mult_in;
					div_32_mult_in = mult_in;
					div_32_L_mac_in = L_mac_in;
					div_32_L_shl_in = L_shl_in;
					div_32_add_in = add_in;
					L_sub_outa = div_32_subouta;
					L_sub_outb = div_32_suboutb;
					L_mult_outa = div_32_L_mult_outa;
					L_mult_outb = div_32_L_mult_outb;
					L_mac_outa = div_32_L_mac_outa;
					L_mac_outb = div_32_L_mac_outb;
					L_mac_outc = div_32_L_mac_outc;
					mult_outa = div_32_mult_outa;
					mult_outb = div_32_mult_outb;
					add_outa = div_32_add_outa;
					add_outb = div_32_add_outb;
					L_shl_outa = div_32_L_shl_outa;
					L_shl_outb = div_32_L_shl_outb;
					L_shl_start = div_32_L_shl_start;
					nextstate = state2;
				end
			end
			
			state3: begin
				scratch_mem_out = k[31:16];
				scratch_mem_write_addr = {LEVINSON_DURBIN_RC[10:4],4'd0};
				scratch_mem_write_en = 1'd1;
				nextstate = state4;
			end
			
			state4: begin
				L_shr_outa = temp2;
				L_shr_outb = 16'd4;
				scratch_mem_out = {L_shr_in[31:16],1'd0,L_shr_in[15:1]};
				scratch_mem_write_addr = {LEVINSON_DURBIN_ATEMP[10:4],4'd1};
				scratch_mem_write_en = 1'd1;
				mpy_32_ina = k;
				mpy_32_inb = k;
				mpy_32_start = 1'd1;
				nextstate = state5;
			end
			
			state5: begin
				if(mpy_32_done == 1) begin
					next_temp2 = mpy_32_out;
					nextstate = state6;
				end
				else begin
					mpy_32_ina = k;
					mpy_32_inb = k;
					mpy_32_L_mult_in = L_mult_in;
					mpy_32_mult_in = mult_in;
					mpy_32_L_mac_in = L_mac_in;
					L_mult_outa = mpy_32_L_mult_outa;
					L_mult_outb = mpy_32_L_mult_outb;
					L_mac_outa = mpy_32_L_mac_outa;
					L_mac_outb = mpy_32_L_mac_outb;
					L_mac_outc = mpy_32_L_mac_outc;
					mult_outa = mpy_32_mult_outa;
					mult_outb = mpy_32_mult_outb;
					nextstate = state5;
				end
			end
					
			state6: begin
				abs_out = temp2;
				L_sub_outa = 32'h7fff_ffff;
				L_sub_outb = abs_in;
				next_temp1 = L_sub_in;
				mpy_32_ina = r0;
				mpy_32_inb = {L_sub_in[31:16],1'd0,L_sub_in[15:1]};
				mpy_32_start = 1'd1;
				nextstate = state7;
			end
			
			state7: begin
				if(mpy_32_done == 1) begin
					norm_L_out = mpy_32_out;
					next_temp1 = mpy_32_out;
					norm_L_start = 1'd1;
					nextstate = state8;
				end
				else begin
					mpy_32_ina = r0;
					mpy_32_inb = {temp1[31:16],1'd0,temp1[15:1]};
					mpy_32_L_mult_in = L_mult_in;
					mpy_32_mult_in = mult_in;
					mpy_32_L_mac_in = L_mac_in;
					L_mult_outa = mpy_32_L_mult_outa;
					L_mult_outb = mpy_32_L_mult_outb;
					L_mac_outa = mpy_32_L_mac_outa;
					L_mac_outb = mpy_32_L_mac_outb;
					L_mac_outc = mpy_32_L_mac_outc;
					mult_outa = mpy_32_mult_outa;
					mult_outb = mpy_32_mult_outb;
					nextstate = state7;
				end
			end
				
			state8: begin
				if(norm_L_done == 1) begin
					L_shl_outa = temp1;
					L_shl_outb = norm_L_in;
					L_shl_start = 1'd1;
					next_alp_exp = norm_L_in;
					nextstate = state9;
				end
				else begin
					nextstate = state8;
					norm_L_out = temp1;
				end
			end
			
			state9: begin
				if(L_shl_done == 1) begin
					next_alp = {L_shl_in[31:16],1'd0,L_shl_in[15:1]};
					nextstate = 10;
				end
				else begin
					nextstate = state9;
				end
			end

			
			state10: begin
				if(iterator1 >= 'd11) begin
					next_iterator1 = 2;
					scratch_mem_out = 'd4096;
					scratch_mem_write_addr = {A_T[10:4],4'd11};
					scratch_mem_write_en = 1'd1;
					nextstate = 29;
				end
				else begin
					next_temp2 = 0;
					nextstate = state11;
				end
			end
			
			state11: begin
				if(iterator2 >= iterator1) begin
					next_iterator2 = 1;
					L_shl_outa = temp2;
					L_shl_outb = 'd4;
					L_shl_start = 'd1;
					nextstate = 14;
				end
				else begin
					r_mux_sel = iterator2;
					mpy_32_ina = r_mux_out;
					sub_outa = iterator1;
					sub_outb = iterator2;
					scratch_mem_read_addr = {LEVINSON_DURBIN_ATEMP[10:4],sub_in[3:0]};
					mpy_32_inb = scratch_mem_in;
					mpy_32_start = 1;					
					nextstate = state12;
				end
			end
			
			state12: begin				
				if(mpy_32_done == 1'd1) begin
					next_temp1 = mpy_32_out;
					nextstate = state13;
					mpy_32_start = 0;
				end
				else begin
					r_mux_sel = iterator2;
					mpy_32_ina = r_mux_out;
					sub_outa = iterator1;
					sub_outb = iterator2;
					scratch_mem_read_addr = {LEVINSON_DURBIN_ATEMP[10:4],sub_in[3:0]};
					mpy_32_inb = scratch_mem_in;					
					L_mult_outa = mpy_32_L_mult_outa;
					L_mult_outb = mpy_32_L_mult_outb;
					mpy_32_L_mult_in = L_mult_in;
					mpy_32_L_mult_overflow = L_mult_overflow;
					mult_outa = mpy_32_mult_outa;
					mult_outb = mpy_32_mult_outb;
					mpy_32_mult_in = mult_in;
					mpy_32_mult_overflow = mult_overflow;
					L_mac_outa = mpy_32_L_mac_outa;
					L_mac_outb = mpy_32_L_mac_outb;
					L_mac_outc = mpy_32_L_mac_outc;
					mpy_32_L_mac_in = L_mac_in;
					mpy_32_L_mac_overflow = L_mac_overflow;
					nextstate = state12;
				end
			end
			
			state13: begin
				L_add_outa = temp2;
				L_add_outb = temp1;
				next_temp2 = L_add_in;
				add_outa = iterator2;
				add_outb = 1;
				next_iterator2 = add_in;
				nextstate = state11;
			end
			
			state14: begin
				if(L_shl_done == 1) begin
					L_add_outa = L_shl_in;
					r_mux_sel = iterator1;
					L_add_outb = {r_mux_out[31:16],r_mux_out[14:0],1'd0};
					next_temp1 = L_add_in;
					abs_out = L_add_in;
					next_temp2 = abs_in;
					div_32_ina = abs_in;
					div_32_inb = alp;
					div_32_start = 1'd1;
					nextstate = state15;
				end
				else begin
					L_shl_outa = temp2;
					L_shl_outb = 'd4;
					nextstate = state14;
				end
			end
			
			state15: begin
				if(div_32_done == 1) begin
					div_32_L_shl_in = L_shl_in;
					next_temp2 = div_32_out;
					if(temp1[31] == 0 && temp1 > 0) begin
						negate_out = div_32_out;
						next_temp3 = negate_in;
						next_k = {negate_in[31:16],1'd0,negate_in[15:1]};
					end
					else begin
						next_temp3 = div_32_out;
					end
					L_shl_outb = alp_exp;
					L_shl_start = 1;
					nextstate = L_shl_wait;
				end
				else begin
					div_32_ina = temp2;
					div_32_inb = alp;
					div_32_subin = L_sub_in;
					div_32_L_mult_in = L_mult_in;
					div_32_mult_in = mult_in;
					div_32_L_mac_in = L_mac_in;
					div_32_L_shl_in = L_shl_in;
					div_32_L_shl_done = L_shl_done;
					div_32_add_in = add_in;
					L_sub_outa = div_32_subouta;
					L_sub_outb = div_32_suboutb;
					L_mult_outa = div_32_L_mult_outa;
					L_mult_outb = div_32_L_mult_outb;
					L_mac_outa = div_32_L_mac_outa;
					L_mac_outb = div_32_L_mac_outb;
					L_mac_outc = div_32_L_mac_outc;
					mult_outa = div_32_mult_outa;
					mult_outb = div_32_mult_outb;
					add_outa = div_32_add_outa;
					add_outb = div_32_add_outb;
					L_shl_outa = div_32_L_shl_outa;
					L_shl_outb = div_32_L_shl_outb;
					L_shl_start = div_32_L_shl_start;
					nextstate = state15;
				end
			end
			
			L_shl_wait: begin
				nextstate = state15_5;
			end
			
			state15_5: begin
				L_shl_outa = temp3;
				L_shl_outb = alp_exp;
				L_shl_start = 'd1;
				nextstate = state16;
			end
			
			state16: begin
				if(L_shl_done == 1) begin
					next_temp1 = L_shl_in;
					next_k = {L_shl_in[31:16],1'd0,L_shl_in[15:1]};
					nextstate = state16_5;
				end
				else begin
					L_shl_outa = temp3;
					L_shl_outb = alp_exp;
					nextstate = state16;
				end
			end
			
			state16_5: begin
				sub_outa = iterator1;
				sub_outb = 1;
				scratch_mem_out = k[31:16];
				scratch_mem_write_addr = {LEVINSON_DURBIN_RC[10:4],sub_in[3:0]};
				scratch_mem_write_en = 1'd1;
				nextstate = state17;
			end
			
			state17: begin
				abs_out = temp2;
				sub_outa = abs_in;
				sub_outb = 'd32750;
				if(sub_in[15] == 0 && sub_in > 0)
				begin
					nextstate = state18;
									end
				else
					nextstate = state21;
			end
			
			state18: begin
				if(iterator4 > 'd10) 
				begin
					next_iterator4 = 'd0;
					nextstate = state19;					
				end
				else begin
					scratch_mem_read_addr = {LEVINSON_DURBIN_AOLD[10:4], iterator4[3:0]};
					nextstate = waitstate5;					
				end
			end
			
			waitstate5:
			begin
				scratch_mem_read_addr = {LEVINSON_DURBIN_AOLD[10:4], iterator4[3:0]};
				scratch_mem_out = scratch_mem_in;
				scratch_mem_write_addr = {A_T[10:4], add_in[3:0]};
				scratch_mem_write_en = 1'd1;
				add_outa = iterator4;
				add_outb = 'd11;
				sub_outa = add_in;
				sub_outb = 'd10;
				next_iterator4 = sub_in;
				nextstate = state18;
			end
			
			state19: begin
				scratch_mem_read_addr = {LEVINSON_DURBIN_RCOLD[10:4], 4'd0};				
				nextstate = waitstate0;
			end
			
			waitstate0:
			begin
				scratch_mem_read_addr = {LEVINSON_DURBIN_RCOLD[10:4], 4'd0};
				scratch_mem_out = scratch_mem_in;
				scratch_mem_write_addr = {LEVINSON_DURBIN_RC[10:4], 4'd0};
				scratch_mem_write_en = 1'd1;
				nextstate = state20;
			end
			
			state20: begin
				scratch_mem_read_addr = {LEVINSON_DURBIN_RCOLD[10:4], 4'd1};
				nextstate = waitstate6;
			end
			
			waitstate6:
			begin
				scratch_mem_read_addr = {LEVINSON_DURBIN_RCOLD[10:4], 4'd1};
				scratch_mem_out = scratch_mem_in;
				scratch_mem_write_addr = {LEVINSON_DURBIN_RC[10:4], 4'd1};
				scratch_mem_write_en = 1'd1;
				done = 1'd1;
				nextstate = init;
			end
			
			state21: begin
				if(iterator3 >= iterator1) begin
					next_iterator3 = 1;
					L_shr_outa = temp1;
					L_shr_outb = 'd4;
					scratch_mem_out = {L_shr_in[31:16],1'd0,L_shr_in[15:1]};
					scratch_mem_write_addr = {LEVINSON_DURBIN_ANEXT[10:4],iterator1[3:0]};
					scratch_mem_write_en = 1'd1;
					mpy_32_ina = k;
					mpy_32_inb = k;
					mpy_32_start = 1'd1;
					nextstate = state23;
				end
				else begin
					mpy_32_ina = k;
					sub_outa = iterator1;
					sub_outb = iterator3;
					scratch_mem_read_addr = {LEVINSON_DURBIN_ATEMP[10:4],sub_in[3:0]};
					mpy_32_inb = scratch_mem_in;					
					nextstate = state22;
				end
			end
			
			state22: begin				
				if(mpy_32_done == 1) begin
					mpy_32_start = 0;
					scratch_mem_read_addr = {LEVINSON_DURBIN_ATEMP[10:4],iterator3[3:0]};
					nextmpyReg = mpy_32_out;
					mpyRegLd = 1;	
					nextstate = waitstate1;	
				end
				else begin
					mpy_32_start = 1;
					mpy_32_ina = k;
					sub_outa = iterator1;
					sub_outb = iterator3;
					scratch_mem_read_addr = {LEVINSON_DURBIN_ATEMP[10:4],sub_in[3:0]};
					mpy_32_inb = scratch_mem_in;					
					L_mult_outa = mpy_32_L_mult_outa;
					L_mult_outb = mpy_32_L_mult_outb;
					mpy_32_L_mult_in = L_mult_in;
					mpy_32_L_mult_overflow = L_mult_overflow;
					mult_outa = mpy_32_mult_outa;
					mult_outb = mpy_32_mult_outb;
					mpy_32_mult_in = mult_in;
					mpy_32_mult_overflow = mult_overflow;
					L_mac_outa = mpy_32_L_mac_outa;
					L_mac_outb = mpy_32_L_mac_outb;
					L_mac_outc = mpy_32_L_mac_outc;
					mpy_32_L_mac_in = L_mac_in;
					mpy_32_L_mac_overflow = L_mac_overflow;
					nextstate = state22;
				end
			end
			
			waitstate1:
			begin
				scratch_mem_read_addr = {LEVINSON_DURBIN_ATEMP[10:4],iterator3[3:0]};
				L_add_outa = mpyReg;
				L_add_outb = {scratch_mem_in[31:16],scratch_mem_in[14:0],1'd0};
				scratch_mem_out = {L_add_in[31:16],1'd0,L_add_in[15:1]};
				scratch_mem_write_addr = {LEVINSON_DURBIN_ANEXT[10:4],iterator3[3:0]};
				scratch_mem_write_en = 1'd1;
				add_outa = iterator3;
				add_outb = 1;
				next_iterator3 = add_in;
				nextstate = state21;			
			end
			
			state23: begin
				if(mpy_32_done == 1) begin
					abs_out = mpy_32_out;
					L_sub_outa = 32'h7fff_ffff;
					L_sub_outb = abs_in;
					next_temp3 = L_sub_in;
					nextstate = state24;
				end
				else begin
					mpy_32_ina = k;
					mpy_32_inb = k;
					L_mult_outa = mpy_32_L_mult_outa;
					L_mult_outb = mpy_32_L_mult_outb;
					mpy_32_L_mult_in = L_mult_in;
					mpy_32_L_mult_overflow = L_mult_overflow;
					mult_outa = mpy_32_mult_outa;
					mult_outb = mpy_32_mult_outb;
					mpy_32_mult_in = mult_in;
					mpy_32_mult_overflow = mult_overflow;
					L_mac_outa = mpy_32_L_mac_outa;
					L_mac_outb = mpy_32_L_mac_outb;
					L_mac_outc = mpy_32_L_mac_outc;
					mpy_32_L_mac_in = L_mac_in;
					mpy_32_L_mac_overflow = L_mac_overflow;
					nextstate = state23;
				end
			end
					
			state24: begin
					mpy_32_ina = alp;
					mpy_32_inb = {temp3[31:16],1'd0,temp3[15:1]};
					mpy_32_start = 1'd1;
					nextstate = state25;
			end
			
			state25: begin
				if(mpy_32_done == 1) begin
					norm_L_out = mpy_32_out;
					next_temp1 = mpy_32_out;
					norm_L_start = 1'd1;
					nextstate = state26;
				end
				else begin
					mpy_32_ina = alp;
					mpy_32_inb = {temp3[31:16],1'd0,temp3[15:1]};
					L_mult_outa = mpy_32_L_mult_outa;
					L_mult_outb = mpy_32_L_mult_outb;
					mpy_32_L_mult_in = L_mult_in;
					mpy_32_L_mult_overflow = L_mult_overflow;
					mult_outa = mpy_32_mult_outa;
					mult_outb = mpy_32_mult_outb;
					mpy_32_mult_in = mult_in;
					mpy_32_mult_overflow = mult_overflow;
					L_mac_outa = mpy_32_L_mac_outa;
					L_mac_outb = mpy_32_L_mac_outb;
					L_mac_outc = mpy_32_L_mac_outc;
					mpy_32_L_mac_in = L_mac_in;
					mpy_32_L_mac_overflow = L_mac_overflow;
					nextstate = state25;
				end
			end
			
			state26: begin
				if(norm_L_done == 1) begin
					L_shl_outa = temp1;
					L_shl_outb = norm_L_in;
					next_temp2 = norm_L_in;
					L_shl_start = 1;
					nextstate = state27;
				end
				else begin
					norm_L_out = temp1;
					nextstate = state26;
				end
			end
			
			state27: begin
				if(L_shl_done == 1) begin
					next_alp = {L_shl_in[31:16],1'd0,L_shl_in[15:1]};
					add_outa = alp_exp;
					add_outb = temp2;
					next_alp_exp = add_in;
					nextstate = 28;
					end
				else begin
					L_shl_outa = temp1;
					L_shl_outb = temp2;
					nextstate = 27;
				end
			end
			
			state28: begin
				if(iterator5 > iterator1) begin
					next_iterator5 = 1;
					add_outa = iterator1;
					add_outb = 1;
					next_iterator1 = add_in;
					nextstate = state10;
				end
				else begin
					scratch_mem_read_addr = {LEVINSON_DURBIN_ANEXT[10:4], iterator5[3:0]};
					nextstate = waitstate7;
				end
			end
			
			waitstate7:
			begin
				scratch_mem_out = scratch_mem_in;
				scratch_mem_write_addr = {LEVINSON_DURBIN_ATEMP[10:4], iterator5[3:0]};
				scratch_mem_write_en = 1'd1;
				add_outa = iterator5;
				add_outb = 1;
				next_iterator5 = add_in;
				nextstate = state28;
			end
			
			state29: begin
				if(iterator6 > 10) 
				begin					
					scratch_mem_read_addr = {LEVINSON_DURBIN_RC[10:4],4'd0};
					nextstate = waitstate2;
				end
				else 
				begin
					scratch_mem_read_addr = {LEVINSON_DURBIN_ATEMP[10:4],iterator6[3:0]};
					nextstate = waitstate3;					
				end
			end
			
			waitstate2:
			begin
				next_iterator6 = 'd1;
				scratch_mem_read_addr = {LEVINSON_DURBIN_RC[10:4],4'd0};
				scratch_mem_out = scratch_mem_in;
				scratch_mem_write_addr = {LEVINSON_DURBIN_RCOLD[10:4],4'd0};
				scratch_mem_write_en = 1'd1;
				nextstate = state32;
			end
			
			waitstate3:
			begin
				scratch_mem_read_addr = {LEVINSON_DURBIN_ATEMP[10:4],iterator6[3:0]};
				L_shl_outa = {scratch_mem_in[31:16],scratch_mem_in[14:0],1'd0};
				next_temp1 = {scratch_mem_in[31:16],scratch_mem_in[14:0],1'd0};
				L_shl_outb = 'd1;
				L_shl_start = 1'd1;
				nextstate = state30;
			end
			
			
			state30: begin
				if(L_shl_done == 1) begin
					L_add_outa = L_shl_in;
					L_add_outb = 32'h0000_8000;
					next_temp2 = L_add_in;
					scratch_mem_out = L_add_in[31:16];
					add_outa = iterator6;
					add_outb = 'd11;
					scratch_mem_write_addr = {A_T[10:4],add_in[3:0]};
					scratch_mem_write_en = 1'd1;
					nextstate = state31;
				end
				else begin
					L_shl_outa = temp1;
					L_shl_outb = 'd1;
					nextstate = state30;
				end
			end
			
			state31: begin
				scratch_mem_out = L_add_in[31:16];
				scratch_mem_write_addr = {LEVINSON_DURBIN_AOLD[10:4],iterator6[3:0]};
				scratch_mem_write_en = 1'd1;
				add_outa = iterator6;
				add_outb = 1;
				next_iterator6 = add_in;
				nextstate = state29;
			end
			
			state32: begin
				scratch_mem_read_addr = {LEVINSON_DURBIN_RC[10:4],4'd1};
				nextstate = waitstate4;
			end
			
			waitstate4:
			begin
				scratch_mem_read_addr = {LEVINSON_DURBIN_RC[10:4],4'd1};
				scratch_mem_out = scratch_mem_in;
				scratch_mem_write_addr = {LEVINSON_DURBIN_RCOLD[10:4],4'd1};
				scratch_mem_write_en = 1'd1;
				done = 1'd1;
				nextstate = init;
			end
		endcase
end				
					
			
endmodule
