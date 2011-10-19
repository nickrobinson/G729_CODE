`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:59:29 09/26/2011 
// Design Name: 
// Module Name:    bits2int 
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
module bits2int(clk, start, reset, done, bitsno, bitstream, value, add_a, add_b, add_in,
    shl_a, shl_b, shl_in, scratch_mem_read_addr, scratch_mem_in);

	input clk, reset, start;
	input [15:0] bitsno, bitstream;
	input [15:0] add_in, shl_in;
	input [15:0] scratch_mem_in;
	
	output reg done;
	output reg [15:0] value;
	output reg [15:0] add_a, add_b, shl_a, shl_b;
	output reg [11:0] scratch_mem_read_addr;
	
	reg [15:0] i, next_i;
	reg [15:0] bitreg, next_bitreg;
	reg [15:0] bitaddr, next_bitaddr;
	reg [15:0] next_value;
	reg [3:0]  current_state, next_state;
	
	parameter INIT = 'd0;
	parameter S1 	= 'd1;
	parameter S2 	= 'd2;
	parameter S3 	= 'd3;
	parameter S4 	= 'd4;
	
	parameter BIT_1 = 16'h0081;
	
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
			bitreg = 'd0;
		else
			bitreg = next_bitreg;
	end
	
	always@(posedge clk) begin
		if(reset)
			bitaddr = bitstream;
		else
			bitaddr = next_bitaddr;
	end
	
	always@(posedge clk) begin
		if(reset)
			value = 'd0;
		else
			value = next_value;
	end
	
	always@(posedge clock) begin
		if(reset)
			current_state = INIT;
		else
			current_state = next_state;
	end
	
	always@(*) begin
	
		next_bitreg = bitreg;
		next_value = value;
		next_state = current_state;
		next_i = i;
		next_done = done;
		
		case(current_state)
		
		INIT: begin
			if(start) begin
				next_state = S1;
				next_value = 'd0;
				next_done = 'd0;
				next_i = 'd0;
				next_bitreg = 'd0;
			end
			else
				next_state = INIT;
		end
		
		S1: begin
			if(i == bitsno) begin
				next_state = S4;
			end
			else begin
				shl_a = value;
				shl_b = 'd1;
				next_value = shl_in;	//value <<= 1;
				//bit = *bitstream++  using memory! may need to add to my addr pointer so may need
				//to do add i in next step
				scratch_mem_read_addr = {SERIAL[11:7], bitaddr[6:0]};  //Serial is where bitstream is saved
				add_a = bitaddr;	//the bitstream address;
				add_b = 'd1;
				next_bitaddr = add_in;
				next_state = S2;
			end
		end
		
		S2: begin
			next_bitreg = scratch_mem_in[15:0];
			add_a = i;
			add_b = 'd1;
			next_i = add_in;
			next_state = S3;
		end
		
		S3: begin
			if(bitreg == BIT_1) begin
				add_a = value;
				add_b = 'd1;
				next_value = add_in;
				next_state = S1;
			end
		end
		
		S4: begin
			next_done = 'd1;
			next_state = INIT;
		end
		
		endcase
	end	//FSM always block end

endmodule
