`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:43:02 11/14/2011 
// Design Name: 
// Module Name:    Dec_lag3 
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
module Dec_lag3( clk, start, reset, done, scratch_mem_read_addr, scratch_mem_in,
	 scratch_mem_write_en, scratch_mem_write_addr, scratch_mem_out, sub_a, sub_b, sub_in, add_a, add_b, add_in, mult_a, mult_b, mult_in,
	 index_addr, i_subfr );
	 
	 `include "paramList.v"
	 `include "data_paramList.v"
	 
	 input clk, start, reset;
	 output reg done;
	 
	 input [31:0] scratch_mem_in;
	 output reg [11:0] scratch_mem_read_addr, scratch_mem_write_addr;
	 output reg [31:0] scratch_mem_out;
	 output reg scratch_mem_write_en;
	 
	 input [15:0] add_in, sub_in, mult_in;
	 output reg [15:0] add_a, add_b, sub_a, sub_b, mult_a, mult_b;
	 
	 input [15:0] index_addr, i_subfr;
	 
	 reg [15:0] i, next_i, temp, next_temp, T0_MIN, T0_MAX, next_T0_MIN, next_T0_MAX;
	 reg [5:0]  current_state, next_state;
	 reg next_done;
	 	 
	 parameter INIT = 'd0;
	 parameter S1 	= 'd1;
	 parameter S2 	= 'd2;
	 parameter S3 	= 'd3;
	 parameter S4 	= 'd4;
	 parameter S5 	= 'd5;
	 parameter S6 	= 'd6;
	 parameter S7 	= 'd7;
	 parameter S8 	= 'd8;
	 parameter S9 	= 'd9;
	 parameter S10 = 'd10;
	 parameter S11 = 'd11;
	 parameter S12 = 'd12;
	 parameter S13 = 'd13;
	 parameter S14 = 'd14;
	 parameter S15 = 'd15;
	 parameter S16 = 'd16;
	 parameter S17 = 'd17;
	 parameter S18 = 'd18;
	 parameter S19 = 'd19;
	 
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
			temp = 'd0;
		else
			temp = next_temp;
	 end
	 
	 always@(posedge clk) begin
		if(reset)
			T0_MIN = 'd0;
		else
			T0_MIN = next_T0_MIN;
	 end
	 
	 always@(posedge clk) begin
		if(reset)
			T0_MAX = 'd0;
		else
			T0_MAX = next_T0_MAX;
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
		sub_a = 0;
		sub_b = 0;
		mult_a = 0;
		mult_b = 0;
		next_state = current_state;
		next_i = i;
		scratch_mem_read_addr = 0;
		scratch_mem_write_addr = 0;
		scratch_mem_out = 0;
		scratch_mem_write_en = 0;
		next_temp = temp;
		next_T0_MIN = T0_MIN;
		next_T0_MAX = T0_MAX;
		
		case(current_state)
			
			INIT: begin
				if(start) begin
					next_state = S1;
					next_i = 'd0;
					next_temp = 'd0;
					next_done = 'd0;
				end
				else begin
					next_done = 'd0;
					next_state = INIT;
				end
			end
			S1: begin //if (i_subfr == 0) 
				if(i_subfr == 0) begin //get index
					scratch_mem_read_addr = {PRM[11:4], index_addr[3:0]};
					next_state = S2;
				end
				else begin //get T0
					scratch_mem_read_addr = T0;
					next_state = S9;
				end
			end
			S2: begin  //if (sub(index, 197) < 0)
				sub_a = scratch_mem_in[15:0];
				sub_b = 197;
				if(sub_in[15]) begin //*T0 = add(mult(add(index, 2), 10923), 19);
					add_a = scratch_mem_in[15:0];
					add_b = 2;
					mult_a = add_in;
					mult_b = 'd10923;
					next_temp = mult_in;
					next_state = S3;
				end
				else begin
					scratch_mem_read_addr = {PRM[11:4], index_addr[3:0]};
					next_state = S7;
				end
			end
			S3: begin
				add_a = temp;
				add_b = 19;
				scratch_mem_out = {16'd0, add_in[15:0]};
				scratch_mem_write_addr = T0;
				scratch_mem_write_en = 1;
				scratch_mem_read_addr = T0;
				next_state = S4;
			end
			S4: begin //i = add(add(*T0, *T0), *T0);
				add_a = scratch_mem_in[15:0];
				add_b = scratch_mem_in[15:0];
				next_temp = add_in;
				scratch_mem_read_addr = T0;
				next_state = S5;
			end
			S5: begin
				add_a = temp;
				add_b = scratch_mem_in[15:0];
				next_i = add_in;
				scratch_mem_read_addr = {PRM[11:4], index_addr[3:0]};
				next_state = S6;
			end
			S6: begin //*T0_frac = add(sub(index, i), 58);
				sub_a = scratch_mem_in[15:0];
				sub_b = i;
				add_a = sub_in;
				add_b = 58;
				scratch_mem_out = {16'd0, add_in[15:0]};
				scratch_mem_write_addr = T0_FRAC;
				scratch_mem_write_en = 1;
				next_state = S19; //done state
			end
			S7: begin //*T0 = sub(index, 112);
				sub_a = scratch_mem_in[15:0];
				sub_b = 112;
				scratch_mem_out = {16'd0, sub_in[15:0]};
				scratch_mem_write_addr = T0;
				scratch_mem_write_en = 1;
				next_state = S8;
			end
			S8: begin //*T0_frac = 0;
				scratch_mem_out = 0;
				scratch_mem_write_addr = T0_FRAC;
				scratch_mem_write_en = 1;
				next_state = S19; //done state
			end
			S9: begin //T0_min = sub(*T0, 5);
				sub_a = scratch_mem_in[15:0];
				sub_b = 5;
				next_T0_MIN = sub_in;
				next_state = S10;
			end
			S10: begin //if (sub(T0_min, pit_min) < 0)
				sub_a = T0_MIN;
				sub_b = PIT_MIN;
				if(sub_in[15]) begin //T0_min = pit_min;
					next_T0_MIN = PIT_MIN;
				end
				next_state = S11;
			end
			S11: begin //T0_max = add(T0_min, 9);
				add_a = T0_MIN;
				add_b = 9;
				next_T0_MAX = add_in;
				//if (sub(T0_max, pit_max) > 0)
				sub_a = add_in;
				sub_b = PIT_MAX;
				if(!sub_in[15]) begin 
					next_state = S12;
				end
				else begin
					scratch_mem_read_addr = {PRM[11:4], index_addr[3:0]};
					next_state = S13;
				end
			end
			S12: begin //T0_max = pit_max;
				next_T0_MAX = PIT_MAX;
				//T0_min = sub(T0_max, 9);
				sub_a = PIT_MAX;
				sub_b = 9;
				next_T0_MIN = sub_in;
				scratch_mem_read_addr = {PRM[11:4], index_addr[3:0]};
				next_state = S13;
			end
			S13: begin //i = sub(mult(add(index, 2), 10923), 1);
				add_a = scratch_mem_in[15:0];
				add_b = 2;
				mult_a = add_in;
				mult_b = 16'd10923;
				sub_a = mult_in;
				sub_b = 1;
				next_i = sub_in;
				next_state = S14;
			end
			S14: begin //*T0 = add(i, T0_min);
				add_a = i;
				add_b = T0_MIN;
				scratch_mem_write_addr = T0;
				scratch_mem_out = {16'd0, add_in[15:0]};
				scratch_mem_write_en = 1;
				next_state = S15;
			end
			S15: begin //i = add(add(i, i), i);
				add_a = i;
				add_b = i;
				next_temp = add_in;
				next_state = S16;
			end
			S16: begin
				add_a = temp;
				add_b = i;
				next_i = add_in;
				scratch_mem_read_addr = {PRM[11:4], index_addr[3:0]};
				next_state = S17;
			end
			S17: begin //*T0_frac = sub(sub(index, 2), i);
				sub_a = scratch_mem_in[15:0];
				sub_b = 2;
				next_temp = sub_in;
				next_state = S18;
			end
			S18: begin
				sub_a = temp;
				sub_b = i; 
				scratch_mem_write_addr = T0_FRAC;
				scratch_mem_out = {16'd0, sub_in[15:0]};
				scratch_mem_write_en = 1;
				next_state = S19; //done state;
			end
			S19: begin
				next_done = 1;
				next_state = INIT; 
			end
			
		endcase
	end	//FSM always block end

endmodule
