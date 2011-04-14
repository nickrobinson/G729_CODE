`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:10:29 04/13/2011 
// Design Name: 
// Module Name:    test_err 
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
module test_err(clock,reset,start,done,out,T0,T0_frac,
						add_outa,add_outb,add_in,
						sub_outa,sub_outb,sub_in,
						L_sub_outa,L_sub_outb,L_sub_in,
						scratch_mem_read_addr,scratch_mem_write_addr,
						scratch_mem_in,scratch_mem_out,
						scratch_mem_write_en,
						constant_mem_read_addr,constant_mem_in
					
    );
	 
	 `include "paramList.v"
	 `include "constants_param_list.v"
	 
	input clock,reset,start;
	output reg done;
	
	input [15:0] T0,T0_frac;
	output reg [15:0] out;

	input [15:0] add_in,sub_in;
	output reg [15:0] add_outa,add_outb,sub_outa,sub_outb;
	
	input [31:0] L_sub_in;
	output reg [31:0] L_sub_outa,L_sub_outb;
	
	input [31:0] scratch_mem_in;
	output reg scratch_mem_write_en;
	output reg [11:0] scratch_mem_read_addr,scratch_mem_write_addr;
	output reg [31:0] scratch_mem_out;
	
	input [31:0] constant_mem_in;
	output reg [11:0] constant_mem_read_addr;
	
	reg next_done;
	reg [15:0] next_out;
	
	reg [15:0] next_i,i,next_t1,t1,next_zone1,zone1,next_zone2,zone2;
	reg [31:0] next_L_maxloc,L_maxloc,next_L_acc,L_acc;
	
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
			i = 'd0;
		else
			i = next_i;
	end
	
	always@(posedge clock) begin
		if(reset)
			t1 = 'd0;
		else
			t1 = next_t1;
	end
	
	always@(posedge clock) begin
		if(reset)
			zone1 = 'd0;
		else
			zone1 = next_zone1;
	end
	
	always@(posedge clock) begin
		if(reset)
			zone2 = 'd0;
		else
			zone2 = next_zone2;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_maxloc = 'd0;
		else
			L_maxloc = next_L_maxloc;
	end
	
	always@(posedge clock) begin
		if(reset)
			L_acc = 'd0;
		else
			L_acc = next_L_acc;
	end
	
	parameter INIT = 4'd0;
	parameter state1 = 4'd1;
	parameter state2 = 4'd2;
	parameter state3 = 4'd3;
	parameter state4 = 4'd4;
	parameter state5 = 4'd5;
	parameter state6 = 4'd6;
	parameter state7 = 4'd7;
	parameter done_state = 4'd8;
	
	reg [3:0] currentstate,nextstate;
	
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
		next_i = i;
		next_t1 = t1;
		next_zone1 = zone1;
		next_zone2 = zone2;
		next_L_maxloc = L_maxloc;
		next_L_acc = L_acc;
		
		sub_outa = 'd0;
		sub_outb = 'd0;
		add_outa = 'd0;
		add_outb = 'd0;
		L_sub_outa = 'd0;
		L_sub_outb = 'd0;
		
		scratch_mem_write_addr = 'd0;
		scratch_mem_read_addr = 'd0;
		scratch_mem_write_en = 'd0;
		scratch_mem_out = 'd0;
		
		constant_mem_read_addr = 'd0;
		
		case(currentstate) 
			
			INIT: begin
				if(start)
					nextstate = state1;
				else
					nextstate = INIT;
			end
			
			state1: begin
				if(T0_frac[15] != 1'd1 && T0_frac != 'd0) begin
					add_outa = T0;
					add_outb = 'd1;
					next_t1 = add_in;
				end
				else begin
					next_t1 = T0;
				end
				nextstate = state2;
			end
			
			state2: begin
				sub_outa = t1;
				sub_outb = 'd50;
				if(sub_in[15] == 'd1)
					next_i = 'd0;
				else
					next_i = sub_in;
				nextstate = state3;
			end
			
			state3: begin
				constant_mem_read_addr = {TAB_ZONE[11:8],i[7:0]};
				nextstate = state4;
			end
			
			state4: begin
				next_zone1 = constant_mem_in[15:0];
				add_outa = t1;
				add_outb = 'd8;
				next_i = add_in;
				constant_mem_read_addr = {TAB_ZONE[11:8],add_in[7:0]};
				nextstate = state5;
			end
			
			state5: begin
				next_zone2 = constant_mem_in[15:0];
				next_L_maxloc = 'd1;
				next_i = constant_mem_in[15:0];
				nextstate = state6;
			end
			
			state6: begin
				if(i < zone1 || i[15] == 'd1) begin
					L_sub_outa = L_maxloc;
					L_sub_outb = 'd983040000;
					next_L_acc = L_sub_in;
					if(L_sub_in[31] != 1'd1 && L_sub_in != 'd0)
						next_out = 'd1;
					else
						next_out = 'd0;
					next_done = 'd1;
					nextstate = done_state;
				end
				else begin
					scratch_mem_read_addr = {L_EXC_ERR[11:2],i[1:0]};
					nextstate = state7;
				end
			end
			
			state7: begin
				L_sub_outa = scratch_mem_in;
				L_sub_outb = L_maxloc;
				next_L_acc = L_sub_in;
				if(L_sub_in[31] != 'd1 && L_sub_in != 'd0)
					next_L_maxloc = scratch_mem_in;
				sub_outa = i;
				sub_outb ='d1;
				next_i = sub_in;
				nextstate = state6;
			end
			
			done_state: begin
				nextstate = INIT;
				next_done = 'd0;
				next_i = 'd0;
				next_L_acc = 'd0;
				next_L_maxloc = 'd0;
				next_zone1 = 'd0;
				next_zone2 = 'd0;
				next_t1 = 'd0;
			end
		endcase
	end				
endmodule
