`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    18:20:14 10/18/2010  
// Module Name:    Mpy_32 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is the Div_32 function replication the C-model function "div32". 
//						 
// Dependencies: 	 div_s.v, mpy_32_16.v,Mpy_32.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Div_32(clock, reset, start, done, num, denom, out, subouta, suboutb, subin,
					L_mult_outa, L_mult_outb, L_mult_in, L_mult_overflow, mult_outa, mult_outb,
					mult_in, mult_overflow, L_mac_outa, L_mac_outb, L_mac_outc, L_mac_in, 
					L_mac_overflow);
					
   input clock, reset, start, L_mult_overflow, mult_overflow, L_mac_overflow;
	input [15:0] mult_in;
   input [31:0] num, denom, subin, L_mult_in, L_mac_in;
	output reg done;
	output reg [15:0] L_mult_outa, L_mult_outb, mult_outa, mult_outb, L_mac_outa, L_mac_outb;
   output reg [31:0] subouta, suboutb, out, L_mac_outc;
	
	reg [15:0] div_s_ina, div_s_inb;
	reg [31:0] div_s_subin;
	reg div_s_start;
	wire [15:0] div_s_out;
	wire [31:0] div_s_subouta, div_s_suboutb;
	wire div_s_err, div_s_done, div_s_overflow;
	
	div_s i_div_s(.clock(clock),.reset(reset),.a(div_s_ina),.b(div_s_inb),.div_err(div_s_err),
							.out(div_s_out),.start(div_s_start),.done(div_s_done),.subouta(div_s_subouta),
							.suboutb(div_s_suboutb),.subin(subin),.overflow(div_s_overflow));
							
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
							
	wire L_shl_overflow;
	reg [31:0] L_shl_ina, mpy_32_product; 
	reg [15:0] L_shl_inb;
	reg L_shl_start;
	wire L_shl_done; 
	wire [31:0] L_shl_out;
							
	L_shl i_L_shl(.clk(clock),.reset(reset),.ready(L_shl_start),.overflow(L_shl_overflow),.var1(L_shl_ina),.numShift(L_shl_inb),
							.done(L_shl_done),.out(L_shl_out));
							

	reg [31:0] approx, next_approx, mpy_32_16_product, next_mpy_32_16_product, diff, next_diff, next_mpy_32_product;
	reg [15:0] div_s_quotient, next_div_s_quotient;
	
	//MPY_32_16 flop
	always@(posedge clock) begin
		if(reset)
			mpy_32_16_product = 32'd0;
		else
			mpy_32_16_product = next_mpy_32_16_product;
	end
	
	//MPY_32 flop
	always@(posedge clock) begin
		if(reset)
			mpy_32_product = 32'd0;
		else
			mpy_32_product = next_mpy_32_product;
	end
	
	//L_Sub flop
	always@(posedge clock) begin
		if(reset)
			diff = 32'd0;
		else
			diff = next_diff;
	end
	
	//div_s flop
	always@(posedge clock) begin
		if(reset)
			div_s_quotient = 16'd0;
		else
			div_s_quotient = next_div_s_quotient;
	end
	
	//approx flop
	always@(posedge clock) begin
		if(reset)
			approx = 32'd0;
		else
			approx = next_approx;
	end
	
	reg [4:0] currentstate, nextstate;
	parameter init = 5'd0;
	parameter state1 = 5'd1;
	parameter state2 = 5'd2;
	parameter state3 = 5'd3;
	parameter state4 = 5'd4;
	parameter state5 = 5'd5;
	parameter state6 = 5'd6;
	parameter state7 = 5'd7;
	parameter state8 = 5'd8;

	always@(posedge clock) begin
		if(reset)
			currentstate = init;
		else
			currentstate = nextstate;
	end
	
	
	always@(*) begin
		done = 0;
		next_diff = diff;
		next_mpy_32_product = mpy_32_product;
		next_mpy_32_16_product = mpy_32_16_product;
		next_approx = approx;
		nextstate = currentstate;
		subouta = div_s_subouta;
		suboutb = div_s_suboutb;
		L_shl_ina = mpy_32_product;
		L_shl_inb = 16'd2;
		mult_outa = 32'd0;
		mult_outb = 32'd0;
		L_mult_outa = 32'd0;
		L_mult_outb = 32'd0;
		L_mac_outa = 32'd0;
		L_mac_outb = 32'd0;
		L_mac_outc = 16'd0;
		out = 16'd0;
		mpy_32_start = 1'd0;
		div_s_start = 1'd0;
		L_shl_start = 1'd0;
		case(currentstate)
		
		init: begin
			if(start==1)
				nextstate = state1;
			else
				nextstate = init;
		end
		
		
		
		state1: begin
			div_s_ina = 16'h3fff;
			div_s_inb = denom[31:16];
			div_s_start = 1;
			next_div_s_quotient = div_s_out;
			nextstate = state2;
		end
		
		state2: begin
			if(div_s_done==1) begin
				next_approx = div_s_out;
				L_mult_outa = mpy_32_16_L_mult_outa;
				L_mult_outb = mpy_32_16_L_mult_outb;
				mpy_32_16_L_mult_in = L_mult_in;
				mpy_32_16_L_mult_overflow = L_mult_overflow;
				mult_outa = mpy_32_16_mult_outa;
				mult_outb = mpy_32_16_mult_outb;
				mpy_32_16_mult_in = mult_in;
				mpy_32_16_mult_overflow = mult_overflow;
				L_mac_outa = mpy_32_16_L_mac_outa;
				L_mac_outb = mpy_32_16_L_mac_outb;
				L_mac_outc = mpy_32_16_L_mac_outc;
				mpy_32_16_L_mac_in = L_mac_in;
				mpy_32_16_L_mac_overflow = L_mac_overflow;
				mpy_32_16_ina = denom;
				mpy_32_16_inb = div_s_out;
				next_mpy_32_16_product = mpy_32_16_out;
				nextstate = state3;
			end
			else
				nextstate = state2;
		end
		
		state3: begin
			subouta = 32'h7fff_ffff;
			suboutb = mpy_32_16_product;
			next_diff = subin;
			nextstate = state4;
		end
		
		state4: begin
			L_mult_outa = mpy_32_16_L_mult_outa;
			L_mult_outb = mpy_32_16_L_mult_outb;
			mpy_32_16_L_mult_in = L_mult_in;
			mpy_32_16_L_mult_overflow = L_mult_overflow;
			mult_outa = mpy_32_16_mult_outa;
			mult_outb = mpy_32_16_mult_outb;
			mpy_32_16_mult_in = mult_in;
			mpy_32_16_mult_overflow = mult_overflow;
			L_mac_outa = mpy_32_16_L_mac_outa;
			L_mac_outb = mpy_32_16_L_mac_outb;
			L_mac_outc = mpy_32_16_L_mac_outc;
			mpy_32_16_L_mac_in = L_mac_in;
			mpy_32_16_L_mac_overflow = L_mac_overflow;
			mpy_32_16_ina = {diff[31:16],1'd0,diff[15:1]};
			mpy_32_16_inb = approx;
			next_mpy_32_16_product = mpy_32_16_out;
			nextstate = state5;
		end
		
		state5: begin
			mpy_32_ina = {num[31:16],1'd0,num[15:1]};
			mpy_32_inb = {mpy_32_16_product[31:16],1'd0,mpy_32_16_product[15:1]};
			mpy_32_start = 1'd1;
			nextstate = state6;
		end
		
		state6: begin
			if(mpy_32_done == 1) begin
				next_mpy_32_product = mpy_32_out;
				nextstate = state7;
			end
			else begin 
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
				nextstate = state6;
			end
		end
		
		state7: begin
			L_shl_start = 1'd1;
			nextstate = state8;
		end
		
		state8: begin
			if(L_shl_done == 1) begin
				done = 1;
				out = L_shl_out;
				nextstate = init;
			end
			else
				nextstate = state8;
		end
	endcase
	end
endmodule
