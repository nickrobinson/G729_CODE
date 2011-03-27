`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    09:28:11 02/14/2011 
// Module Name:    lsp_lsf 
// Project Name:   ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T - 1FF1136
// Tool versions:  Xilinx ISE 12.4
// Description:    This module performs the operations done by the lsp_lsf function
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Updated to support address input wires
// Revision 0.03 - Updated to support 12 bit memory address wires
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lsp_lsf(clock,reset,start,done,scratch_mem_read_addr,scratch_mem_write_addr,
					scratch_mem_out,scratch_mem_write_en,scratch_mem_in,constant_mem_read_addr,
					constant_mem_in,lsf_addr1,lsf_addr2,add_outa,add_outb,add_in,sub_outa,sub_outb,sub_in,
					shl_outa,shl_outb,shl_in,L_add_outa,L_add_outb,L_add_in,L_mult_outa,L_mult_outb,
					L_mult_in,L_shl_start,L_shl_outa,L_shl_outb,L_shl_in,L_shl_done
    );

	`include "constants_param_list.v"
	`include "paramList.v"
	
	input clock,reset,start;
	
	input [11:0] lsf_addr1,lsf_addr2;
	
	input [31:0] scratch_mem_in;
	input [31:0] constant_mem_in;
	
	output reg [11:0] scratch_mem_read_addr,scratch_mem_write_addr;
	output reg [31:0] scratch_mem_out;
	output reg scratch_mem_write_en;
	
	output reg [11:0] constant_mem_read_addr;
	
	output reg done;
	
	input L_shl_done;
	input [15:0] add_in,sub_in,shl_in;
	input [31:0] L_add_in,L_mult_in,L_shl_in;
	output reg L_shl_start;
	output reg [15:0] add_outa,add_outb,sub_outa,sub_outb,shl_outa,shl_outb,L_mult_outa,L_mult_outb,L_shl_outb;
	output reg [31:0] L_add_outa,L_add_outb,L_shl_outa;
	
	parameter init = 'd0;
	parameter state1 = 'd1;
	parameter state2 = 'd2;
	parameter state3 = 'd3;
	parameter state4 = 'd4;
	parameter state5 = 'd5;
	parameter state6 = 'd6;
	parameter state7 = 'd7;
	parameter state8 = 'd8;
	parameter state9 = 'd9;
	parameter state10 = 'd10;
	
	reg [3:0] currentstate, nextstate;
	reg [5:0] ind, next_ind;
	reg signed [4:0] iterator1, next_iterator1;
	reg [31:0] temp1, next_temp1, temp2, next_temp2;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = init;
		else
			currentstate = nextstate;
	end
	
	always@(posedge clock) begin
		if(reset)
			ind = 'd63;
		else
			ind = next_ind;
	end
	
	always@(posedge clock) begin
		if(reset)
			iterator1 = 'd9;
		else
			iterator1 = next_iterator1;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp1 = 'd0;
		else
			temp1 = next_temp1;
	end
	
	always@(posedge clock) begin
		if(reset)
			temp2 = 'd0;
		else
			temp2 = next_temp2;
	end
	
	always@(*) begin
		
		nextstate = currentstate;
		next_ind = ind;
		next_temp1 = temp1;
		next_temp2 = temp2;
		
		next_iterator1 = iterator1;
		
		scratch_mem_read_addr = 12'd0;
		scratch_mem_write_addr = 12'd0;
		scratch_mem_out = 32'd0;
		scratch_mem_write_en = 1'd0;
		
		constant_mem_read_addr = 12'd0;
		
		done = 1'd0;
		
		add_outa = 'd0;
		add_outb = 'd0;
		sub_outa = 'd0;
		sub_outb = 'd0;
		L_add_outa = 'd0;
		L_add_outb = 'd0;
		L_mult_outa = 'd0;
		L_mult_outb = 'd0;
		L_shl_start = 'd0;
		L_shl_outa = 'd0;
		L_shl_outb = 'd0;
		shl_outa = 'd0;
		shl_outb = 'd0;
		
		case(currentstate)
		
			init: begin
				if(start)
					nextstate = state1;
				else
					nextstate = init;
			end
			
			//for(i=m-1;i>=0;i--)
			state1: begin
			   //reset iterators
				if(iterator1 < 0) begin
					next_iterator1 = 'd9;
					next_ind = 'd63;
					done = 'd1;
					nextstate = init;
				end
				//table[ind]
				else begin
					constant_mem_read_addr = {TABLE1[11:6],ind[5:0]};
					nextstate = state2;
				end
			end
			
			//lsp[i]
			state2: begin
				next_temp1 = constant_mem_in;
				scratch_mem_read_addr = {lsf_addr1[11:4],iterator1[3:0]};
				nextstate = state3;
			end
			
			//while(sub(table[ind], lsp[i])<0)
			state3: begin
				sub_outa = temp1;
				sub_outb = scratch_mem_in[15:0];
				if(sub_in[15] != 1) begin
					scratch_mem_read_addr = {lsf_addr1[11:4],iterator1[3:0]};
					nextstate = state5;
				end
				else
					nextstate = state4;
			end
			
			//ind = sub(ind,1);
			state4: begin
				sub_outa = ind;
				sub_outb = 'd1;
				next_ind = sub_in;
				nextstate = state1;
			end
			
			//lsp[i]
			state5: begin
				scratch_mem_read_addr = {lsf_addr1[11:4],iterator1[3:0]};
				nextstate = state6;
			end
			
			//table[ind]
			state6: begin
				next_temp1 = scratch_mem_in;
				constant_mem_read_addr = {TABLE1[11:6],ind[5:0]};
				nextstate = state7;
			end
			
			//sub(lsp[i], table[ind])
			//slope[ind]
			state7: begin
				sub_outa = temp1[15:0];
				sub_outb = constant_mem_in[15:0];
				next_temp1 = {16'd0,sub_in};
				constant_mem_read_addr = {SLOPE[11:6],ind[5:0]};
				nextstate = state8;
			end
			
			//L_tmp = L_mult( sub(lsp[i], table[ind]), slope[ind]);
			state8: begin
				L_mult_outa = temp1[15:0];
				L_mult_outb = {constant_mem_in[15:0]};
				L_shl_outa = L_mult_in;
				next_temp1 = L_mult_in;
				L_shl_outb = 'd3;
				L_shl_start = 'd1;
				nextstate = state9;
			end
			
			//tmp = round(L_shl(L_tmp, 3));
			//lsf[i] = add(tmp, shl(ind, 8));
			state9: begin
				if(L_shl_done == 1) begin
					L_add_outa = L_shl_in;
					L_add_outb = 32'h00008000;
					add_outa = L_add_in[31:16];
					shl_outa = ind;
					shl_outb = 'd8;
					add_outb = shl_in;
					scratch_mem_write_addr = {lsf_addr2[11:4],iterator1[3:0]};
					scratch_mem_out = {16'd0,add_in};
					scratch_mem_write_en = 'd1;
					nextstate = state10;
				end
				else begin
					L_shl_outa = temp1;
					L_shl_outb = 'd3;
					nextstate = state9;
				end
			end
			
			//i--
			state10: begin
				sub_outa = iterator1;
				sub_outb = 'd1;
				next_iterator1 = sub_in[4:0];
				nextstate = state1;
			end
		endcase

	end

endmodule
