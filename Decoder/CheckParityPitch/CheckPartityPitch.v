`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:59:29 09/12/2011 
// Design Name: 
// Module Name:    CheckPartityPitch 
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
module CheckParityPitch(clk, start, reset, done, pitch_index, parity, sum, add_a, add_b, add_in, shr_a, shr_b, shr_in
    );

input clk, start, reset;
input [15:0] pitch_index, parity;
input [15:0] shr_in, add_in;

output reg done;
output reg [15:0] sum;
output reg [15:0] shr_a, shr_b, add_a, add_b;

reg next_done;
reg [3:0] state, nextstate;
reg [15:0] next_sum;
reg [15:0] temp, next_temp;
reg [15:0] i, nexti;

parameter S0 = 0;
parameter S1 = 1;
parameter S2 = 2;
parameter S3 = 3;
parameter S4 = 4;
parameter INIT = 5;


//Changing States/variables/signals from the States on clk edges
//counter
always @(posedge clk)
		begin
			if(reset)
				i <= 0;
			else
				i <= nexti;
		end

//State
always @(posedge clk)
		begin
			if (reset)
				 state <= INIT;
			else
				 state <= nextstate;
		 end

	always @(posedge clk)
		begin
			if(reset)
				temp <= 0;
			else
				temp <= next_temp;
		end

//Sum
always @(posedge clk)
		begin
			if(reset)
				sum <= 0;
			else
				sum <= next_sum;
		end

//Done signal
always @(posedge clk)
		begin
			if(reset)
				done <= 0;
			else
				done <= next_done;
		end

always @(*)
begin
	nextstate = state;
	nexti = i;
	next_temp = temp;
	next_done = 0;
	next_sum = sum;
	add_a = 'd0;
	add_b = 'd0;
	shr_a = 'd0;
	shr_b = 'd0;
	
	case(state)
		INIT:
		begin
			if(start)
				nextstate = S0;
		end
		S0:
		begin
			//Temp = shr(pitch_index,1)
			shr_a = pitch_index;
			shr_b = 'd1;
			next_temp = shr_in;
			next_sum = 'd1;
			nexti = 'd0;
			nextstate = S1;
		end
		S1:
		begin
			//for loop
			//temp = shr(temp, 1)
			//bit = temp & (word16)
			//sum = add(sum, bit)
			if(i == 6)
			begin
				nexti = 'd0;
				nextstate = S3;
			end
			else
			begin
				shr_a = temp;
				shr_b = 'd1;
				next_temp = shr_in;
				add_a = sum;
				add_b = (shr_in & 16'd1);
				next_sum = add_in;
				nextstate = S2;
			end
		end
		S2:
		begin
			//increment for loop
			add_a = i;
			add_b = 'd1;
			nexti = add_in;
			nextstate = S1;		
		end
		S3:
		begin
			//sum = add(sum, parity);
			//sum = sum & (Word16)1;
			add_a = sum;
			add_b = parity;
			next_sum = (add_in & 16'd1);
			nextstate = S4;
		end
		S4:
		begin
			//done
			next_done = 'd1;
			nextstate = INIT;
		end
	endcase

end

endmodule
