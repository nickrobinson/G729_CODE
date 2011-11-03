`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design 
// Engineer: Sean Owens
// 
// Create Date:    16:33:55 04/12/2011
// Module Name:    G_pitch 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T
// Tool versions:  Xilinx ISE 12.4
// Description: 
//
// Dependencies: 	 div_s.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module G_pitch(clock,reset,start,done,out,
					shr_outa,shr_outb,shr_in,
					L_mac_outa,L_mac_outb,L_mac_outc,L_mac_in,L_mac_overflow,
					norm_l_out,norm_l_in,norm_l_start,norm_l_done,
					L_shl_outa,L_shl_outb,L_shl_start,L_shl_in,L_shl_done,
					sub_outa,sub_outb,sub_in,
					add_outa,add_outb,add_in,
					scratch_mem_read_addr,scratch_mem_write_addr,scratch_mem_in,scratch_mem_out,
					scratch_mem_write_en,
					L_add_outa,L_add_outb,L_add_in,
					L_sub_outa,L_sub_outb,L_sub_in
    );
	 
	 `include "paramList.v"
	 
	input clock,reset,start;
	output reg done;
	output reg [15:0] out;
	 
	output reg [15:0] shr_outa,shr_outb;
	input [15:0] shr_in;
	 
	output reg [15:0] L_mac_outa,L_mac_outb;
	output reg [31:0] L_mac_outc;
	input L_mac_overflow;
	input [31:0] L_mac_in;
	
	output reg [31:0] L_sub_outa,L_sub_outb;
	input [31:0] L_sub_in;
	
	output reg norm_l_start;
	output reg [31:0] norm_l_out;
	input norm_l_done;
	input [15:0] norm_l_in;
	
	output reg L_shl_start;
	output reg [31:0] L_shl_outa;
	output reg [15:0] L_shl_outb;
	input L_shl_done;
	input [31:0] L_shl_in;
	
	output reg [15:0] sub_outa,sub_outb;
	input [15:0] sub_in;

	output reg [15:0] add_outa,add_outb;
	input [15:0] add_in;
	
	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_read_addr,scratch_mem_write_addr;
	output reg [31:0] scratch_mem_out;
	input [31:0] scratch_mem_in;
	
	output reg [31:0] L_add_outa,L_add_outb;
	input [31:0] L_add_in;
	
	reg div_s_start;
	reg [15:0] div_s_ina,div_s_inb;
	wire [15:0] div_s_add_outa,div_s_add_outb;
	wire [31:0] div_s_sub_outa,div_s_sub_outb;
	
	wire div_s_div_err;
	wire [15:0] div_s_out;
					
	div_s i_div_s(
					.clock(clock),.reset(reset),.a(div_s_ina),.b(div_s_inb),.div_err(div_s_div_err),
					.out(div_s_out),.start(div_s_start),.done(div_s_done),.subouta(div_s_sub_outa),
					.suboutb(div_s_sub_outb),.subin(L_sub_in),.add_outa(div_s_add_outa),
					.add_outb(div_s_add_outb),.add_in(add_in));
					
	reg next_done;
	reg [15:0] next_out;
	
	reg [15:0] temp16,next_temp16;
	
	reg overflow,next_overflow;
	reg [15:0] i,next_i,xy,next_xy,yy,next_yy,exp_xy,next_exp_xy,exp_yy,next_exp_yy,gain,next_gain;
	reg [31:0] s,next_s;
	
	always@(posedge clock) begin
		if(reset)
			done = 'd0;
		else
			done = next_done;
	end
	
	always@(posedge clock) begin
		if(reset)
			out = 'd0;
		else
			out = next_out;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp16 = 'd0;
		else
			temp16 = next_temp16;
	end
	
	always@(posedge clock) begin
		if(reset)
			overflow = 'd0;
		else
			overflow = next_overflow;
	end
	
	always@(posedge clock) begin
		if(reset)
			i = 'd0;
		else
			i = next_i;
	end
	
	always@(posedge clock) begin
		if(reset)
			xy = 'd0;
		else
			xy = next_xy;
	end
	
	always@(posedge clock) begin
		if(reset)
			yy = 'd0;
		else
			yy = next_yy;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp_xy = 'd0;
		else
			exp_xy = next_exp_xy;
	end
	
	always@(posedge clock) begin
		if(reset)
			exp_yy = 'd0;
		else
			exp_yy = next_exp_yy;
	end
	
	always@(posedge clock) begin
		if(reset)
			gain = 'd0;
		else
			gain = next_gain;
	end
	
	always@(posedge clock) begin
		if(reset)
			s = 'd0;
		else
			s = next_s;
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
	parameter state15 = 5'd15;
	parameter state16 = 5'd16;
	parameter state17 = 5'd17;
	parameter state18 = 5'd18;
	parameter state19 = 5'd19;
	parameter state20 = 5'd20;
	parameter state21 = 5'd21;
	parameter state22 = 5'd22;
	parameter state23 = 5'd23;
	parameter state24 = 5'd24;
	parameter state25 = 5'd25;
	parameter state26 = 5'd26;
	parameter state27 = 5'd27;
	parameter state28 = 5'd28;
	parameter done_state = 5'd29;
	
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
		next_out = out;
		next_overflow = overflow;
		next_i = i;
		next_xy = xy;
		next_yy = yy;
		next_exp_xy = exp_xy;
		next_exp_yy = exp_yy;
		next_gain = gain;
		next_s = s;
		next_temp16 = temp16;
		
		shr_outa = 'd0;
		shr_outb = 'd0;
		L_mac_outa = 'd0;
		L_mac_outb = 'd0;
		L_mac_outc = 'd0;
		norm_l_out = 'd0;
		norm_l_start = 'd0;
		L_shl_outa = 'd0;
		L_shl_outb = 'd0;
		L_shl_start = 'd0;
		sub_outa = 'd0;
		sub_outb = 'd0;
		add_outa = 'd0;
		add_outb = 'd0;
		L_sub_outa = 'd0;
		L_sub_outb = 'd0;
		L_add_outa = 'd0;
		L_add_outb = 'd0;
		
		div_s_start = 'd0;
		div_s_ina = 'd0;
		div_s_inb = 'd0;
		
		scratch_mem_read_addr = 'd0;
		scratch_mem_write_addr = 'd0;
		scratch_mem_out = 'd0;
		scratch_mem_write_en = 'd0;
		
		case(currentstate)
			
			INIT: begin
				if(start) begin
					nextstate = state1;
				end
				else begin
					nextstate = INIT;
				end
			end
			
			state1: begin
				if(i == 'd40) begin
					next_i = 'd0;
					next_overflow = 'd0;
					next_s = 'd1;
					nextstate = state3;
				end
				else begin
					scratch_mem_read_addr = {Y1[11:6],i[5:0]};
					nextstate = state2;
				end
			end
			
			state2: begin
				shr_outa = scratch_mem_in[15:0];
				shr_outb = 'd2;
				scratch_mem_write_addr = {G_PITCH_SCALED_Y1[11:6],i[5:0]};
				scratch_mem_out = {16'd0,shr_in};
				scratch_mem_write_en = 'd1;
				add_outa = i;
				add_outb = 'd1;
				next_i = add_in;
				nextstate = state1;
			end
			
			state3: begin
				if(i == 'd40) begin
					next_i = 'd0;
					if(overflow == 'd0) begin
						norm_l_out = s;
						norm_l_start = 'd1;
						nextstate = state5;
					end
					else begin
						next_s = 'd1;
						nextstate = state7;
					end
				end
				else begin
					scratch_mem_read_addr = {Y1[11:6],i[5:0]};
					nextstate = state4;
				end
			end
			
			state4: begin
				L_mac_outa = scratch_mem_in[15:0];
				L_mac_outb = scratch_mem_in[15:0];
				L_mac_outc = s;
				if(L_mac_overflow == 'd1) 
					next_overflow = 'd1;
				next_s = L_mac_in;
				add_outa = i;
				add_outb = 'd1;
				next_i = add_in;
				nextstate = state3;
			end
	
			state5: begin
				if(norm_l_done == 'd1) begin
					next_exp_yy = norm_l_in;
					L_shl_outa = s;
					L_shl_outb = norm_l_in;
					L_shl_start = 'd1;
					nextstate = state6;
				end
				else begin
					norm_l_out = s;
					nextstate = state5;
				end
			end
			
			state6: begin
				if(L_shl_done == 'd1) begin
					L_add_outa = L_shl_in;
					L_add_outb = 32'h0000_8000;
					next_yy = L_add_in[31:16];
					next_overflow = 'd0;
					next_s = 'd0;
					nextstate = state11;
				end
				else begin
					L_shl_outa = s;
					L_shl_outb = exp_yy;
					nextstate = state6;
				end
			end
			
			state7: begin
				if(i == 'd40) begin
					next_i = 'd0;
					norm_l_out = s;
					norm_l_start = 'd1;
					nextstate = state9;
				end
				else begin
					scratch_mem_read_addr = {G_PITCH_SCALED_Y1[11:6],i[5:0]};
					nextstate = state8;
				end
			end
			
			state8: begin
				L_mac_outa = scratch_mem_in[15:0];
				L_mac_outb = scratch_mem_in[15:0];
				L_mac_outc = s;
				next_s = L_mac_in;
				add_outa = i;
				add_outb = 'd1;
				next_i = add_in;
				nextstate = state7;
			end
			
			state9: begin
				if(norm_l_done == 'd1) begin
					next_exp_yy = norm_l_in;
					L_shl_outa = s;
					L_shl_outb = norm_l_in;
					L_shl_start = 'd1;
					nextstate = state10;
				end
				else begin
					norm_l_out = s;
				end
			end
			
			state10: begin
				if(L_shl_done == 'd1) begin
					L_add_outa = L_shl_in;
					L_add_outb = 32'h0000_8000;
					next_yy = L_add_in[31:16];
					sub_outa = exp_yy;
					sub_outb = 'd4;
					next_exp_yy = sub_in;
					next_overflow = 'd0;
					next_s = 'd0;
					nextstate = state11;
				end
				else begin
					L_shl_outa = s;
					L_shl_outb = exp_yy;
					nextstate = state10;
				end
			end
			
			state11: begin
				if(i == 'd40) begin
					next_i = 'd0;
					if(overflow == 'd0) begin
						norm_l_out = s;
						norm_l_start = 'd1;
						nextstate = state14;
					end
					else begin
						next_s = 'd0;
						nextstate = state16;
					end
				end
				else begin
					scratch_mem_read_addr = {XN[11:6],i[5:0]};
					nextstate = state12;
				end
			end
			
			state12: begin
				next_temp16 = scratch_mem_in[15:0];
				scratch_mem_read_addr = {Y1[11:6],i[5:0]};
				nextstate = state13;
			end
			
			state13: begin
				L_mac_outa = temp16;
				L_mac_outb = scratch_mem_in[15:0];
				L_mac_outc = s;
				if(L_mac_overflow == 'd1)
					next_overflow = 'd1;
				next_s = L_mac_in;
				add_outa = i;
				add_outb = 'd1;
				next_i = add_in;
				nextstate = state11;
			end
			
			state14: begin
				if(norm_l_done == 'd1) begin
					next_exp_xy = norm_l_in;
					L_shl_outa = s;
					L_shl_outb = norm_l_in;
					L_shl_start = 'd1;
					nextstate = state15;
				end
				else begin
					norm_l_out = s;
					nextstate = state14;
				end
			end
			
			state15: begin
				if(L_shl_done == 'd1) begin
					L_add_outa = L_shl_in;
					L_add_outb = 32'h0000_8000;
					next_xy = L_add_in[31:16];
					nextstate = state21;
				end
				else begin
					L_shl_outa = s;
					L_shl_outb = exp_xy;
					nextstate = state15;
				end
			end
			
			state16: begin
				if(i == 'd40) begin
					next_i = 'd0;
					norm_l_out = s;
					norm_l_start = 'd1;
					nextstate = state19;
				end
				else begin
					scratch_mem_read_addr = {XN[11:6],i[5:0]};
					nextstate = state17;
				end
			end
			
			state17: begin
				next_temp16 = scratch_mem_in[15:0];
				scratch_mem_read_addr = {G_PITCH_SCALED_Y1[11:6],i[5:0]};
				nextstate = state18;
			end
			
			state18: begin
				L_mac_outa = temp16;
				L_mac_outb = scratch_mem_in[15:0];
				L_mac_outc = s;
				next_s = L_mac_in;
				add_outa = i;
				add_outb = 'd1;
				next_i = add_in;
				nextstate = state16;
			end
			
			state19: begin
				if(norm_l_done == 'd1) begin
					next_exp_xy = norm_l_in;
					L_shl_outa = s;
					L_shl_outb = norm_l_in;
					L_shl_start = 'd1;
					nextstate = state20;
				end
				else begin
					norm_l_out = s;
					nextstate = state19;
				end
			end
			
			state20: begin
				if(L_shl_done == 'd1) begin
					L_add_outa = L_shl_in;
					L_add_outb = 32'h0000_8000;
					next_xy = L_add_in[31:16];
					sub_outa = exp_xy;
					sub_outb = 'd2;
					next_exp_xy = sub_in;
					nextstate = state21;
				end
				else begin
					L_shl_outa = s;
					L_shl_outb = exp_xy;
					nextstate = state20;
				end
			end
			
			state21: begin
				scratch_mem_write_addr = {G_COEFF[11:2],2'd0};
				if (yy[15] == 1)
					scratch_mem_out = {16'hffff,yy};
				else
					scratch_mem_out = {16'h0000,yy};
				scratch_mem_write_en = 'd1;
				nextstate = state22;
			end
			
			state22: begin
				scratch_mem_write_addr = {G_COEFF[11:2],2'd1};
				sub_outa = 'd15;
				sub_outb = exp_yy;
				if (sub_in[15] == 1)
					scratch_mem_out = {16'hffff,sub_in};
				else
					scratch_mem_out = {16'h0000,sub_in};
				scratch_mem_write_en = 'd1;
				nextstate = state23;
			end
			
			state23: begin
				scratch_mem_write_addr = {G_COEFF[11:2],2'd2};
				if (xy[15] == 1)
					scratch_mem_out = {16'hffff,xy};
				else
					scratch_mem_out = {16'h0000,xy};
				scratch_mem_write_en = 'd1;
				nextstate = state24;
			end
			
			state24: begin
				scratch_mem_write_addr = {G_COEFF[11:2],2'd3};
				sub_outa = 'd15;
				sub_outb = exp_xy;
				if (sub_in[15] == 1)
					scratch_mem_out = {16'hffff,sub_in};
				else
					scratch_mem_out = {16'd0,sub_in};
				scratch_mem_write_en = 'd1;
				if(xy[15] == 'd1 || xy == 'd0) begin
					nextstate = state25;
				end
				else
					nextstate = state26;
			end
			
			state25: begin
				scratch_mem_write_addr = {G_COEFF[11:2],2'd3};
				scratch_mem_out = 32'hffff_fff1;
				scratch_mem_write_en = 'd1;
				next_out = 'd0;
				next_done = 'd1;
				nextstate = done_state;
			end
			
			state26: begin
				shr_outa = xy;
				shr_outb = 'd1;
				next_xy = shr_in;
				div_s_ina = shr_in;
				div_s_inb = yy;
				div_s_start = 'd1;
				nextstate = 27;
			end
			
			state27: begin
				if(div_s_done == 'd1) begin
					sub_outa = exp_xy;
					sub_outb = exp_yy;
					next_i = sub_in;
					shr_outa = div_s_out;
					shr_outb = sub_in;
					next_gain = shr_in;
					nextstate = state28;
				end
				else begin
					div_s_ina = xy;
					div_s_inb = yy;
					add_outa = div_s_add_outa;
					add_outb = div_s_add_outb;
					L_sub_outa = div_s_sub_outa;
					L_sub_outb = div_s_sub_outb;
					nextstate = 27;
				end
			end
			
			state28: begin
				sub_outa = gain;
				sub_outb = 'd19661;
				if(sub_in[15] == 'd0 && sub_in != 'd0) begin
					next_gain = 'd19661;
					next_out = 'd19661;
				end
				else begin
					next_out = gain;
				end
				next_done = 'd1;
				nextstate = done_state;
			end
			
			done_state: begin
				next_done = 'd0;
				next_i = 'd0;
				next_xy = 'd0;
				next_yy = 'd0;
				next_exp_xy = 'd0;
				next_exp_yy = 'd0;
				next_gain = 'd0;
				next_s = 'd0;
				next_temp16 = 'd0;
				nextstate = INIT;
			end	
		endcase
	end
endmodule
