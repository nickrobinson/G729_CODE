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
output [15:0] norm;
input clk ,ready, reset;
output done;

wire signed [31:0] var1;

reg signed [31:0] var1reg, next_var1reg;
reg [15:0] norm;
reg normld,normreset;
reg state,nextstate;
reg done;

parameter NORM_FACTOR = 32'h4000_0000;
parameter INIT = 1'd0;
parameter S1 = 1'd1;

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
	else if(normreset)
		norm <= 0;
	else if(normld)
		norm <= norm + 1;
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
	normreset = 0;
	normld = 0;	
	next_var1reg = var1reg;
	done = 0;
	
	case(state)
	INIT: begin
		
		if(ready == 0)
			nextstate = INIT;
			
		else if(ready == 1)
		begin //else1	
			done = 0;
			next_var1reg = var1;
			normreset = 1;
			if(var1 == 0) 
			begin
				normreset = 1;
				nextstate = INIT;
				done = 1;
			end
		
			else if(var1 == 32'hffff_ffff) 
			begin
				normreset = 1;
				nextstate = INIT;
				done = 1;
			end
		
			else 
			begin
				if(var1[31] == 1)
					next_var1reg = ~var1 + 32'd1;
				nextstate = S1;
			end
		end //end else1
	end //end INIT

	

	S1: begin	 
		 
		if(var1reg >= NORM_FACTOR) 
		 begin
			nextstate = INIT;
			done = 1;			
		 end	
		
		else if(var1reg < NORM_FACTOR) 
		begin
			next_var1reg = var1reg <<< 1;
			normld = 1;			
			nextstate = S1;
		end
		 
		 
		
		
	end // end S1
		
	default:	begin
	nextstate = INIT;
	end
		
		
			
endcase
end//end always
endmodule
