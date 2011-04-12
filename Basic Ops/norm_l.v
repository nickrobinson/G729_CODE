`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    11:00:50 09/11/2010
// Module Name:    norm_l.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is a function that returns the number of shifts needed to normalize var1.
// 					 The output is only valid when done goes high.
// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module norm_l(var1,norm,clk,ready,reset,done);

input [31:0] var1;
output reg [15:0] norm;
input clk ,ready, reset;
output reg done;

wire [31:0] var1;

reg signed [31:0] var1reg, next_var1reg;
reg [15:0] next_norm;
reg [1:0] state,nextstate;
reg next_done;

parameter INIT = 2'd0;
parameter state1 = 2'd1;
parameter done_state = 2'd2;

always @ (posedge clk) 
begin
	if(reset)
		state <= INIT;
	else
		state <= nextstate;
end

always @ (posedge clk) 
begin
	if(reset)
		norm <= 0;
	else
		norm <= next_norm;
end

always @ (posedge clk) 
begin
	if(reset)
		done <= 0;
	else
		done <= next_done;
end

always @ (posedge clk) 
begin
	if(reset)
		var1reg<= 0;
	else 
   	var1reg <= next_var1reg;
end

always @(*)
begin
	
	nextstate = state;	
	next_norm = norm;
	next_var1reg = var1reg;
	next_done = done;
	
	case(state)
		
		INIT: begin
			if(ready=='d1) begin
				next_norm = 'd0;
				if(var1 == 'd0) begin
					next_norm = 'd0;
					next_done = 'd1;
					nextstate = done_state;
				end
				else begin
					if(var1 == 32'hffff_ffff) begin
						next_norm = 'd31;
						next_done = 'd1;
						nextstate = done_state;
					end
					else begin
						if(var1[31] == 'd1) begin
							next_var1reg = ~var1;
						end
						else
							next_var1reg = var1;
						nextstate = state1;
					end
				end
			end
			else
				nextstate = INIT;
		end
		
		state1: begin
			if(var1reg[30] == 'd1) begin
				next_done = 'd1;
				nextstate = done_state;
			end
			else begin
				next_var1reg = var1reg << 1;
				next_norm = norm + 1;
				nextstate = state1;
			end
		end
		
		done_state: begin
			next_done = 'd0;
			next_var1reg = 'd0;
			nextstate = INIT;
		end
		
			
endcase
end//end always
endmodule
