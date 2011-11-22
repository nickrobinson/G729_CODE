`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:28:57 10/31/2011 
// Design Name: 
// Module Name:    bits2prm_ld8k 
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
module bits2prm_ld8k( clk, start, reset, done, add_a, add_b, add_in, shl_a, shl_b,
	 shl_in, scratch_mem_read_addr, scratch_mem_in, const_mem_read_addr, const_mem_in,
	 scratch_mem_write_en, scratch_mem_write_addr, scratch_mem_out );

	`include "paramList.v"
	`include "data_paramList.v"
	`include "constants_param_list.v"
	
	input clk, reset, start;
	input [15:0] add_in, shl_in;
	input [31:0] scratch_mem_in, const_mem_in;
	
	output reg done, scratch_mem_write_en;
	output reg [15:0] add_a, add_b, shl_a, shl_b;
	output reg [11:0] scratch_mem_read_addr, scratch_mem_write_addr, const_mem_read_addr;
	output reg [31:0] scratch_mem_out;
	
	reg [15:0] i, next_i;
	reg [15:0] bitno, next_bitno;
	reg [15:0] bitaddr, next_bitaddr;
	reg [15:0] value, next_value;
	reg [3:0]  current_state, next_state;
	reg next_done;
	
	reg b2i_start;
	wire [15:0] b2i_value;
	wire [11:0] b2i_scratch_mem_read_addr;
	wire [15:0] b2i_add_a, b2i_add_b, b2i_shl_a, b2i_shl_b;
	wire b2i_done;
	
	bits2int b2i(
		.clk(clk), 
		.start(b2i_start), 
		.reset(reset), 
		.done(b2i_done), 
		.bitsno(bitno), 
		.bitstream(bitaddr), 
		.value(b2i_value), 
		.add_a(b2i_add_a), 
		.add_b(b2i_add_b), 
		.add_in(add_in),
		.shl_a(b2i_shl_a), 
		.shl_b(b2i_shl_b), 
		.shl_in(shl_in), 
		.scratch_mem_read_addr(b2i_scratch_mem_read_addr), 
		.scratch_mem_in(scratch_mem_in));
	
	parameter INIT = 'd0;
	parameter S1 	= 'd1;
	parameter S2 	= 'd2;
	parameter S3 	= 'd3;
	parameter S4 	= 'd4;

always@(posedge clk) begin
		if(reset)
			done = 'd0;
		else
			done = next_done;
	end

	always@(posedge clk) begin
		if(reset)
			i = 'd0;
		else
			i = next_i;
	end
	
	always@(posedge clk) begin
		if(reset)
			bitaddr = 'd2;
		else
			bitaddr = next_bitaddr;
	end
	
	always@(posedge clk) begin
		if(reset)
			bitno = 'd0;
		else
			bitno = next_bitno;
	end
	
	always@(posedge clk) begin
		if(reset)
			value = 'd0;
		else
			value = next_value;
	end
	
	always@(posedge clk) begin
		if(reset)
			current_state = INIT;
		else
			current_state = next_state;
	end
	
	always@(*) begin
		add_a = 0;
		add_b = 0;
		shl_a = 0;
		shl_b = 0;
		b2i_start = 0;
		next_state = current_state;
		next_i = i;
		scratch_mem_read_addr = 0;
		scratch_mem_write_addr = 0;
		scratch_mem_out = 0;
		scratch_mem_write_en = 0;
		
		case(current_state)
			
			INIT: begin
				if(start) begin
					next_state = S1;
					next_bitaddr = 'd2;
					next_i = 'd0;
				end
				else begin
					next_done = 'd0;
					next_state = INIT;
				end
			end
			S1: begin
				if(i == PRM_SIZE) begin
					next_done = 'd1;
					next_state = INIT;
				end
				else begin
					const_mem_read_addr = {BITSNO[11:4], i[3:0]};
					next_state = S2;
				end
			end
			S2: begin
					//bin2int(bitsno[i], bits);
					next_bitno = const_mem_in[15:0];
					add_a = b2i_add_a;
					add_b = b2i_add_b;
					shl_a = b2i_shl_a;
					shl_b = b2i_shl_b;
					scratch_mem_read_addr = b2i_scratch_mem_read_addr;
					b2i_start = 1;
					if(b2i_done == 1)begin
						b2i_start = 0;
						next_state = S3;
						next_value = b2i_value;
						end
					else if(b2i_done == 0)
						next_state = S2;
			end
			S3: begin
			//prm[i] = bin2int(bitsno[i], bits);
			//bits  += bitsno[i];
				scratch_mem_write_addr = {PRM[11:4], i[3:0]};
				scratch_mem_out = {16'd0, value[15:0]};
				scratch_mem_write_en = 'd1;
				add_a = bitaddr;
				add_b = bitno;
				next_bitaddr = add_in;
				next_state = S4;
			end
			
			S4: begin
				add_a = i;
				add_b = 'd1;
				next_i = add_in;
				next_state = S1;
			end
			
			endcase
	end	//FSM always block end

endmodule
