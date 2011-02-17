`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    18:46:59 10/14/2010  
// Module Name:    div_s 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is a function to perform division of the a input by the b input. The divErr bit will be set
//						 high should division by zero occur.
// 
// Dependencies: 	 regArraySize6.v, Chebps10_FSM.v, Chebps11_FSM.v, twoway_16bit_mux.v, gridPointsMem.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module div_s(clock, reset, a, b, div_err, out, start, done, subouta, suboutb, subin,
					add_outa,add_outb,add_in);
	input clock, reset, start;
   input [15:0] a;
   input [15:0] b;
	input [31:0] subin;
	input [15:0] add_in;
	output reg done, div_err;
   output reg [15:0] out;
	output reg [31:0] subouta, suboutb;
	output reg [15:0] add_outa, add_outb;
	
	parameter MIN_16 = 16'h8000;
	parameter MAX_16 = 16'h7fff;
	parameter init = 3'd0;
	parameter check_state = 3'd1;
	parameter err_state = 3'd2;
	parameter zero_state = 3'd3;
	parameter max_state = 3'd4;
	parameter div_state1 = 3'd5;
	parameter div_state2 = 3'd6;
	parameter div_state3 = 3'd7;
	
	reg [2:0] currentstate, nextstate;
	
	reg [3:0] iterator;
	reg [3:0] next_iterator;
	
	reg [15:0] next_out;
	
	reg [31:0] L_denom, L_num, L_out;
	reg [31:0] next_L_denom, next_L_num, next_L_out;
	
	always@(posedge clock) begin
		if(reset)
			currentstate = init;
		else
			currentstate = nextstate;
	end
	
	//temp_L_num_flop
	always@(posedge clock) begin
		if(reset)
			L_num = 0;
		else
			L_num = next_L_num;
	end
	
	//temp_L_num_flop
	always@(posedge clock) begin
		if(reset)
			L_denom = 0;
		else
			L_denom = next_L_denom;
	end
	
	always@(posedge clock) begin
		if(reset)
			out = 0;
		else
			out = next_out;
	end
	
	//iteration flop
	always@(posedge clock) begin
		if(reset)
			iterator = 0;
		else
			iterator = next_iterator;
	end
	
	always@(posedge clock) begin
		if(reset)
			currentstate = init;
		else
			currentstate = nextstate;
	end
	
	
	
	always@(*) begin
		next_L_num = L_num;
		next_L_denom = L_denom;
		next_out = out;
		next_iterator = iterator;
		nextstate = currentstate;
		done = 0;
		div_err = 0;
		
		subouta = 0;
		suboutb = 0;
		
		add_outa = 0;
		add_outb = 0;
		
		case(currentstate)
		
		
			init: begin
				next_out = 0;
				if(start==0)
					nextstate = init;
				else
					nextstate = check_state;
			end
			
			check_state: begin
				if((a>b) || (a[15]==1) || (b[15]==1) || (b==0))
					nextstate = err_state;
				else if(a==0) begin
					next_out = 'd0;
					nextstate = zero_state;
					end
				else if(a==b) begin
					next_out = MAX_16;
					nextstate = max_state;
				end
				else begin
					next_L_num = {16'd0,a};
					next_L_denom = {16'd0,b};
					nextstate = div_state1;
				end
			end

			err_state: begin
				div_err = 1;
			end
			
			zero_state: begin
				done = 'd1;
				nextstate = init;
			end
			
			max_state: begin
				done = 'd1;
				nextstate = init;
			end

			div_state1: begin
				if(iterator >= 'd15) begin
					next_iterator = 0;
					done = 1;
					nextstate = init;
				end
				else begin
					next_out = out << 1;
					next_L_num = L_num << 1;
					nextstate = div_state2;
				end
			end
			
			div_state2: begin
				if(L_num < L_denom) begin
					add_outa = iterator;
					add_outb = 'd1;
					next_iterator = add_in;
					nextstate = div_state1;
				end
				else begin
					subouta = L_num;
					suboutb = L_denom;
					next_L_num = subin;
					add_outa = out;
					add_outb = 'd1;
					next_out = add_in;
					nextstate = div_state3;
				end
			end
			
			div_state3: begin
				add_outa = iterator;
				add_outb = 'd1;
				next_iterator = add_in;
				nextstate = div_state1;
			end
		endcase
	end
				
endmodule
