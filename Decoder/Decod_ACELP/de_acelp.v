`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:02:51 09/12/2011 
// Design Name: 
// Module Name:    de_acelp 
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
module de_acelp(clk, start, reset, done, add_in, shr_in, shl_in, add_a, add_b,
						shr_a, shr_b, shl_a, shl_b, scratch_mem_in, scratch_mem_write_en, scratch_mem_read_addr,
						scratch_mem_write_addr, scratch_mem_out);

	`include "paramList.v"

	input clk, start, reset;
		
	output reg done;
	
	input [15:0] add_in;
	input [15:0] shr_in;
	input [15:0] shl_in;
	output reg [15:0] add_a, add_b;
	output reg [15:0] shr_a, shr_b;
	output reg [15:0] shl_a, shl_b;
	
	input [31:0] scratch_mem_in;
	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_read_addr, scratch_mem_write_addr;
	output reg [31:0] scratch_mem_out;
	
	parameter INIT = 0;
	parameter S1 = 1;
	parameter S2 = 2;
	parameter S3 = 3;
	parameter S4 = 4;
	parameter S5 = 5;
	parameter S6 = 6;
	parameter S7 = 7;
	parameter S8 = 8;
	parameter S9 = 9;
	parameter S10 = 10;
	parameter S11 = 11;
	parameter S12 = 12;
	parameter S13 = 13;
	parameter S14 = 14;
	parameter GET_INDEX = 15;
	parameter GET_SIGN = 16;
	
	reg [4:0] state, nextstate;
	reg [15:0] i, next_i;
	reg [15:0] j, next_j;
	reg [15:0] pos0, pos1, pos2, pos3;
	reg [15:0] next_pos0, next_pos1, next_pos2, next_pos3;
	
	reg [15:0] index, next_index;
	reg [15:0] sign, next_sign;
	
	reg ld_pos0, ld_pos1, ld_pos2, ld_pos3;
	reg ld_index, ld_sign;
	reg ld_i, ld_j;
	
	reg next_done;
	
	always @(posedge clk)
		begin
			if(reset)
				state = INIT;
			else
				state = nextstate;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				i = 0;
			else if(ld_i)
				i = next_i;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				j = 0;
			else if(ld_j)
				j = next_j;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				index = 0;
			else if(ld_index)
				index = next_index;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				sign = 0;
			else if(ld_sign)
				sign = next_sign;
		end
		
	always @(posedge clk)
		begin
			if(reset)
				done = 0;
			else
				done = next_done;
		end

	always @(posedge clk)
		begin
			if(reset)
   		  pos0 = 0;
			else if(ld_pos0)
				pos0 = next_pos0;
		end

	always @(posedge clk)
		begin
			if(reset)
   		  pos1 = 0;
			else if(ld_pos1)
				pos1 = next_pos1;
		end

	always @(posedge clk)
		begin
			if(reset)
   		  pos2 = 0;
			else if(ld_pos2)
				pos2 = next_pos2;
		end
		
	always @(posedge clk)
		begin
			if(reset)
   		  pos3 = 0;
			else if(ld_pos3)
				pos3 = next_pos3;
		end
		
	always @(*)
		begin
			nextstate = state;
			next_index = 0;
			next_sign = 0;
			
			next_i = 0;
			next_j = 0;
			
			add_a = 0;
			add_b = 0;
			shr_a = 0;
			shr_b = 0;
			shl_a = 0;
			shl_b = 0;
			
			next_done = 0;
			
			next_pos0 = 0;
			next_pos1 = 0;
			next_pos2 = 0;
			next_pos3 = 0;

         ld_pos0 = 0;	
         ld_pos1 = 0;	
         ld_pos2 = 0;	
         ld_pos3 = 0;
			
			ld_index = 0;
			ld_sign = 0;
			
			ld_i = 0;
			ld_j = 0;
			
			scratch_mem_read_addr = 'd0;
			scratch_mem_write_addr = 'd0;
			scratch_mem_out = 'd0;
			scratch_mem_write_en = 'd0;
			
			case(state)
				INIT:
					begin
						if(start) begin
							scratch_mem_read_addr = INDEX_IN;
							nextstate = GET_INDEX;
						end
					end
				GET_INDEX:
					begin
						next_index = scratch_mem_in[15:0];
						ld_index = 1;
						nextstate = S1;
					end
				S1: 
					begin
						next_i = index & 16'd7;			// i      = index & (Word16)7;
						ld_i = 1;
						shl_a = index & 16'd7;
						shl_b = 16'd2;
						add_a = index & 16'd7;
						add_b = shl_in;
						next_pos0 = add_in;						// pos[0] = add(i, shl(i, 2)); 
						ld_pos0 = 1;
						nextstate = S2;
					end
				S2:
					begin
						shr_a = index;
						shr_b = 16'd3;
						next_index = shr_in;				// index  = shr(index, 3);
						ld_index = 1;
						add_a = shr_in & 16'd7;
						shl_a = shr_in & 16'd7;
						shl_b = 16'd2;
						add_b = shl_in;
						next_i = add_in;					// i      = add(i, shl(i, 2));
						ld_i = 1;
						nextstate = S3;
					end
				S3:
					begin
						add_a = i;
						add_b = 16'd1;
						next_pos1 = add_in;						// pos[1] = add(i, 1);
						ld_pos1 =1;
						nextstate = S4;
					end
				S4:
					begin
						shr_a = index;
						shr_b = 16'd3;
						next_index = shr_in;				// index  = shr(index, 3);
						ld_index = 1;
						add_a = shr_in & 16'd7;
						shl_a = shr_in & 16'd7;
						shl_b = 16'd2;
						add_b = shl_in;
						next_i = add_in;					// i      = add(i, shl(i, 2));
						ld_i = 1;
						nextstate = S5;
					end
				S5:
					begin
						add_a = i;
						add_b = 16'd2;
						next_pos2 = add_in;						// pos[2] = add(i, 2);
						ld_pos2 = 1;
						nextstate = S6;
					end
				S6:
					begin
						shr_a = index;
						shr_b = 16'd3;
						next_index = shr_in;				// index  = shr(index, 3);
						ld_index = 1;
						next_j = shr_in & 16'd1;		// j      = index & (Word16)1;
						ld_j = 1;
						nextstate = S7;
					end
				S7:
					begin
						shr_a = index;
						shr_b = 16'd1;
						next_index = shr_in;				// index  = shr(index, 1);
						ld_index = 1;
						add_a = shr_in & 16'd7;
						shl_a = shr_in & 16'd7;
						shl_b = 16'd2;
						add_b = shl_in;
						next_i = add_in;					// i      = add(i, shl(i, 2));           /* pos3 =i*5+3+j */
						ld_i = 1;
						nextstate = S8;
					end
				S8:
					begin
						add_a = i;
						add_b = 16'd3;
						next_i = add_in;					// i      = add(i, 3);
						ld_i = 1;
						nextstate = S9;
					end
				S9:
					begin
						add_a = i;
						add_b = j;
						next_pos3 = add_in;						// pos[3] = add(i, j);
						ld_pos3 = 1;
						next_i = 16'd0;						// set i = 0 for upcoming for loop
						ld_i = 1;
						nextstate = S10;
					end
				S10:
					begin
						if(i == 16'd40) begin
							next_j = 16'd0;
							ld_j = 1;
							scratch_mem_read_addr = SIGN_IN;
							nextstate = GET_SIGN;
						end
						else begin
							nextstate = S11;
						end
					end
				S11:
					begin
						scratch_mem_write_addr = {COD[11:6],i[5:0]};
						// cod[i] = 0;
						scratch_mem_out = 16'd0;
						scratch_mem_write_en = 16'd1;
						// increment i
						add_a = i;
						add_b = 16'd1;
						next_i = add_in;
						ld_i = 1;
						nextstate = S10;
					end
				GET_SIGN:
					begin
						next_sign = scratch_mem_in[15:0];
						ld_sign = 1;
						nextstate = S12;
					end
				S12:
					begin
						if(j == 'd4) begin
							next_done = 1;
							nextstate = S14;
						end
						else begin
							// i = sign & (Word16)1;
							next_i = sign & 16'd1;
							ld_i = 1;
							//sign = shr(sign, 1);
							shr_a = sign;
							shr_b = 16'd1;
							next_sign = shr_in;
							ld_sign = 1;
							nextstate = S13;
						end
					end
				S13:
					begin
						// if (i != 0) -> cod[pos[j]] = 8191;
						if(i != 16'd0) begin
							if(j == 16'd0) begin
								scratch_mem_write_addr = {COD[11:6],pos0[5:0]};
								scratch_mem_out = 'd8191;
								scratch_mem_write_en = 'd1;
							end
							else if(j == 16'd1) begin
								scratch_mem_write_addr = {COD[11:6],pos1[5:0]};
								scratch_mem_out = 'd8191;
								scratch_mem_write_en = 'd1;
							end
							else if(j == 16'd2) begin
								scratch_mem_write_addr = {COD[11:6],pos2[5:0]};
								scratch_mem_out = 'd8191;
								scratch_mem_write_en = 'd1;
							end
							else if(j == 16'd3) begin
								scratch_mem_write_addr = {COD[11:6],pos3[5:0]};
								scratch_mem_out = 'd8191;
								scratch_mem_write_en = 'd1;
							end
						end
						// else -> cod[pos[j]] = -8192;
						else begin
							if(j == 16'd0) begin
								scratch_mem_write_addr = {COD[11:6],pos0[5:0]};
								scratch_mem_out = -8192;
								scratch_mem_write_en = 'd1;
							end
							else if(j == 16'd1) begin
								scratch_mem_write_addr = {COD[11:6],pos1[5:0]};
								scratch_mem_out = -8192;
								scratch_mem_write_en = 'd1;
							end
							else if(j == 16'd2) begin
								scratch_mem_write_addr = {COD[11:6],pos2[5:0]};
								scratch_mem_out = -8192;
								scratch_mem_write_en = 'd1;
							end
							else if(j == 16'd3) begin
								scratch_mem_write_addr = {COD[11:6],pos3[5:0]};
								scratch_mem_out = -8192;
								scratch_mem_write_en = 'd1;
							end
						end
						add_a = j;
						add_b = 'd1;
						next_j = add_in;
						ld_j = 1;
						nextstate = S12;
					end
				S14:
					begin
						next_done = 0;
						next_i = 0;
						next_j = 0;
						ld_i = 1;
						ld_j = 1;
						nextstate = INIT;
					end
			endcase			
		end

endmodule
