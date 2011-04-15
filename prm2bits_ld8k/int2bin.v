`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:19:31 04/14/2011 
// Design Name: 
// Module Name:    int2bin 
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
module int2bin(clock,reset,start,done,value,bitsno,bitstream,add_outa,add_outb,add_in,
						scratch_mem_write_addr,scratch_mem_read_addr,scratch_mem_in,scratch_mem_out,
						scratch_mem_write_en,sub_outa,sub_outb,sub_in
    );
	 
	`include "constants_param_list.v"
	`include "paramList.v"

	input clock,reset,start;
	output reg done;
	
	input [15:0] value,bitsno,bitstream;

	output reg [15:0] add_outa,add_outb;
	input [15:0] add_in;
	
	output reg [15:0] sub_outa,sub_outb;
	input [15:0] sub_in;
	
	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_write_addr,scratch_mem_read_addr;
	output reg [31:0] scratch_mem_out;
	input [31:0] scratch_mem_in;

	reg next_done;

	reg [15:0] pt_bitstream,next_pt_bitstream,i,next_i,bitreg,next_bitreg;
	
	reg [15:0] valuereg,next_valuereg;
	
	always@(posedge clock) begin
		if(reset)
			done = 'd0;
		else
			done = next_done;
	end
	
	always@(posedge clock) begin
		if(reset)
			pt_bitstream = 'd0;
		else
			pt_bitstream = next_pt_bitstream;
	end

	always@(posedge clock) begin
		if(reset)
			i = 'd0;
		else
			i = next_i;
	end
	
	always@(posedge clock) begin
		if(reset)
			bitreg = 'd0;
		else
			bitreg = next_bitreg;
	end
	
	always@(posedge clock) begin
		if(reset)
			valuereg = 'd0;
		else
			valuereg = next_valuereg;
	end

	parameter INIT = 3'd0;
	parameter state1 = 3'd1;
	parameter state2 = 3'd2;
	parameter state3 = 3'd3;
	parameter done_state = 3'd4;
	
	reg [2:0] currentstate,nextstate;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = 'd0;
		else
			currentstate = nextstate;
	end
	
	always@(*) begin
		nextstate = currentstate;
		next_done = done;
		next_pt_bitstream = pt_bitstream;
		next_i = i;
		next_bitreg = bitreg;
		next_valuereg = valuereg;
		
		add_outa = 'd0;
		add_outb = 'd0;
		sub_outa = 'd0;
		sub_outb = 'd0;
		
		scratch_mem_read_addr = 'd0;
		scratch_mem_write_addr = 'd0;
		scratch_mem_out = 'd0;
		scratch_mem_write_en = 'd0;
		
		case(currentstate)
			
			INIT: begin
				if(start) begin
					next_valuereg = value;
					nextstate = state1;
				end
				else
					nextstate = INIT;
			end
			
			state1: begin
				add_outa = bitstream;
				add_outb = bitsno;
				next_pt_bitstream = add_in;
				nextstate = state2;
			end
			
			state2: begin
				if(i == bitsno) begin
					next_done = 'd1;
					nextstate = done_state;
				end
				else begin
					next_bitreg = valuereg & 16'h0001;
					nextstate = state3;
				end
			end
			
			state3: begin
				if(bitreg == 'd0) begin
					sub_outa = pt_bitstream;
					sub_outb = 'd1;
					next_pt_bitstream = sub_in;
					scratch_mem_write_addr = {SERIAL[11:7],sub_in[6:0]};
					scratch_mem_out = {16'd0,16'h007f};
					scratch_mem_write_en = 'd1;
					next_valuereg = valuereg >> 'd1;
					add_outa = i;
					add_outb = 'd1;
					next_i = add_in;
					nextstate = state2;
				end
				else begin
					sub_outa = pt_bitstream;
					sub_outb = 'd1;
					next_pt_bitstream = sub_in;
					scratch_mem_write_addr = {SERIAL[11:7],sub_in[6:0]};
					scratch_mem_out = {16'd0,16'h0081};
					scratch_mem_write_en = 'd1;
					next_valuereg = valuereg >> 'd1;
					add_outa = i;
					add_outb = 'd1;
					next_i = add_in;
					nextstate = state2;
				end
			end
			
			done_state: begin
				next_done = 'd0;
				nextstate = INIT;
				next_pt_bitstream = 'd0;
				next_i = 'd0;
				next_bitreg = 'd0;
				next_valuereg = 'd0;
			end
		endcase
	end					
endmodule
