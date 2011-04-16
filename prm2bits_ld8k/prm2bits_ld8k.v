`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:12:37 04/14/2011 
// Design Name: 
// Module Name:    prm2bits_ld8k 
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
module prm2bits_ld8k(clock,reset,start,done,add_outa,add_outb,add_in,constant_mem_read_addr,
							constant_mem_in,scratch_mem_read_addr,scratch_mem_write_addr,scratch_mem_in,
							scratch_mem_out,scratch_mem_write_en,L_add_outa,L_add_outb,L_add_in,sub_outa,
							sub_outb,sub_in
    );
	
	`include "constants_param_list.v"
	`include "paramList.v"

	input clock,reset,start;
	output reg done;
	
	input [15:0] sub_in,add_in;
	output reg [15:0] sub_outa,sub_outb,add_outa,add_outb;
	
	input [31:0] L_add_in;
	output reg [31:0] L_add_outa,L_add_outb;
	
	input [31:0] constant_mem_in;
	output reg [11:0] constant_mem_read_addr;
	
	input [31:0] scratch_mem_in;
	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_read_addr,scratch_mem_write_addr;
	output reg [31:0] scratch_mem_out;
	
	reg int2bin_start;
	wire int2bin_done;
	
	reg [15:0] int2bin_value,int2bin_bitsno,int2bin_bitstream;
	
	wire [15:0] int2bin_add_outa,int2bin_add_outb,int2bin_sub_outa,int2bin_sub_outb;
	
	wire int2bin_scratch_mem_write_en;
	wire [11:0] int2bin_scratch_mem_write_addr,int2bin_scratch_mem_read_addr;
	wire [31:0] int2bin_scratch_mem_out;
	
	int2bin i_int2bin(
				.clock(clock),.reset(reset),.start(int2bin_start),.done(int2bin_done),
				.value(int2bin_value),.bitsno(int2bin_bitsno),.bitstream(int2bin_bitstream),
				.add_outa(int2bin_add_outa),.add_outb(int2bin_add_outb),.add_in(add_in),
				.sub_outa(int2bin_sub_outa),.sub_outb(int2bin_sub_outb),.sub_in(sub_in),
				.scratch_mem_write_addr(int2bin_scratch_mem_write_addr),.scratch_mem_read_addr(int2bin_scratch_mem_read_addr),
				.scratch_mem_in(scratch_mem_in),.scratch_mem_out(int2bin_scratch_mem_out),
				.scratch_mem_write_en(int2bin_scratch_mem_write_en)
    );
	 
	reg next_done;
	reg [15:0] bits,next_bits,i,next_i,temp_prm,next_temp_prm,temp_bitsno,next_temp_bitsno;
	
	always@(posedge clock) begin
		if(reset)
			done = 'd0;
		else
			done = next_done;
	end
	
	always@(posedge clock) begin
		if(reset)
			bits = 'd0;
		else
			bits = next_bits;
	end
	
	always@(posedge clock) begin
		if(reset)
			i = 'd0;
		else
			i = next_i;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_prm = 'd0;
		else
			temp_prm = next_temp_prm;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp_bitsno = 'd0;
		else
			temp_bitsno = next_temp_bitsno;
	end
	
	parameter INIT = 3'd0;
	parameter state1 = 3'd1;
	parameter state2 = 3'd2;
	parameter state3 = 3'd3;
	parameter state4 = 3'd4;
	parameter done_state = 3'd5;
	
	reg [2:0] currentstate,nextstate;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = INIT;
		else
			currentstate = nextstate;
	end
	
	always@(*) begin
		nextstate = currentstate;
		next_bits = bits;
		next_done = done;
		next_i = i;
		next_temp_prm = temp_prm;
		next_temp_bitsno = temp_bitsno;
		
		add_outa = 'd0;
		add_outb = 'd0;
		L_add_outa = 'd0;
		L_add_outb = 'd0;
		sub_outa = 'd0;
		sub_outb = 'd0;
		
		constant_mem_read_addr = 'd0;
		
		scratch_mem_read_addr = 'd0;
		scratch_mem_write_addr = 'd0;
		scratch_mem_write_en = 'd0;
		scratch_mem_out = 'd0;
		
		int2bin_start = 'd0;
		int2bin_value = 'd0;
		int2bin_bitsno = 'd0;
		int2bin_bitstream ='d0;
		
		case(currentstate)
			
			INIT: begin
				if(start) begin
					scratch_mem_write_addr = {SERIAL[11:7],7'd0};
					scratch_mem_out = {16'd0,16'h6b21};
					scratch_mem_write_en = 'd1;
					next_bits = 'd2;
					next_done = 'd0;
					next_i = 'd0;
					next_temp_prm = 'd0;
					next_temp_bitsno = 'd0;	
					nextstate = state1;
				end
				else
					nextstate = INIT;
			end
			
			state1: begin
				scratch_mem_write_addr = {SERIAL[11:7],7'd1};
				scratch_mem_out = 'd80;
				scratch_mem_write_en = 'd1;
				nextstate = state2;
			end
			
			state2: begin
				if(i == 'd11) begin
					next_done = 'd1;
					nextstate = done_state;
				end
				else begin
					scratch_mem_read_addr = {PRM[11:4],i[3:0]};
					constant_mem_read_addr = {BITSNO[11:4],i[3:0]};
					nextstate = state3;
				end
			end
			
			state3: begin
				next_temp_prm = scratch_mem_in[15:0];
				next_temp_bitsno = constant_mem_in[15:0];
				int2bin_start = 'd1;
				int2bin_value = scratch_mem_in[15:0];
				int2bin_bitsno = constant_mem_in[15:0];
				int2bin_bitstream = bits;
				nextstate = state4;
			end
			
			state4: begin
				if(int2bin_done == 'd1) begin
					add_outa = bits;
					add_outb = temp_bitsno;
					next_bits = add_in;
					L_add_outa = {16'd0,i};
					L_add_outb = 'd1;
					next_i = L_add_in[15:0];
					nextstate = state2;					
				end
				else begin
					int2bin_value = temp_prm;
					int2bin_bitsno = temp_bitsno;
					int2bin_bitstream = bits;
					nextstate = state4;
					add_outa = int2bin_add_outa;
					add_outb = int2bin_add_outb;
					sub_outa = int2bin_sub_outa;
					sub_outb = int2bin_sub_outb;
					scratch_mem_read_addr = int2bin_scratch_mem_read_addr;
					scratch_mem_write_addr = int2bin_scratch_mem_write_addr;
					scratch_mem_out = int2bin_scratch_mem_out;
					scratch_mem_write_en = int2bin_scratch_mem_write_en;
				end
			end
			
			done_state: begin
				nextstate = INIT;
				next_bits = 'd0;
				next_done = 'd0;
				next_i = 'd0;
				next_temp_prm = 'd0;
				next_temp_bitsno = 'd0;
			end
		endcase
	end
endmodule
