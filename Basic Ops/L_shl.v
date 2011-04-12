`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    11:00:50 09/11/2010
// Module Name:    L_shl.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This is a function that shifts var1 left by numShift and places the result in out. 
// 					 Results are only valid when done is true. If the there is overflow, overflow and done 
//						 will go high and the output will be set to the appropriate limit. If numShift is negative,
// 					 done will go high and the output will be set to 0xffff_ffff
// Dependencies: 	 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module L_shl(clk,reset,ready,overflow,var1,numShift,done,out);

input clk, reset,ready;
output overflow;
input [31:0] var1; 
input [15:0] numShift;

output done; 
output [31:0] out;

wire signed [31:0] var1;
wire signed [15:0] numShift;

reg signed [15:0] numShiftReg,next_numShiftReg;
reg signed [31:0] var1reg,next_var1reg;

reg overflow;
reg state,nextstate;
reg done;
reg signed [31:0] out,nextout;
reg outld;


parameter INIT = 1'd0;
parameter S1 = 1'd1;
parameter OUTPUT_MAX = 32'h7fff_ffff;
parameter OUTPUT_MIN = 32'h8000_0000;
parameter INPUT_MAX = 32'h3fff_ffff;
parameter INPUT_MIN = 32'hc000_0000;

always @(posedge clk) 
begin
	if(reset) 
		state <= INIT;
	else
		state <= nextstate;
end

always @(posedge clk) 
begin
	if(reset)
		numShiftReg <= 0;
	else
		numShiftReg <= next_numShiftReg;
end

always @(posedge clk) 
begin
	if(reset)
		var1reg <= 0;
	else
		var1reg <= next_var1reg;
end

always @(posedge clk) 
begin
	if(reset)
		out <= 0;
	else if(outld)
		out <= nextout;
end


always @(*)
	begin
		overflow = 0;
		done = 0;
		outld = 0;
		next_var1reg = var1reg;
		nextout = out;
		next_numShiftReg = numShiftReg;
		nextstate = state;

		
		case(state)
		INIT: begin
			
			if(ready == 0)
					nextstate = INIT;
			
			else if(ready == 1)begin//else 1
		
				if(numShift[15] == 1) begin
					done = 1;
					nextout = 32'hffff_ffff;
					outld = 1;
					nextstate = INIT;
				end
				
				else 	
				begin
					next_numShiftReg = numShift;
					next_var1reg = var1;
					outld = 1;
					nextout = var1;
					nextstate = S1;
				end
			end //end else1
		end //end INIT
			
		S1:	begin
			nextstate = S1;
			
			if(numShiftReg <= 0) begin			
				done = 1;
				nextstate = INIT;
			end
			
			else begin //else 1			
				
				if((var1reg[31] == 0) && (var1reg > INPUT_MAX)) begin
					done = 1;
					overflow = 1;
					nextout = OUTPUT_MAX;
					outld = 1;
					nextstate = INIT;
				end //end if
				
				else if((var1reg[31] == 1) && (var1reg < INPUT_MIN)) begin //else 2
					done = 1; 
					overflow = 1;
					nextout = OUTPUT_MIN;
					outld = 1;
					nextstate = INIT;
				end //end else 2
				 
				else begin//else 3 
					next_numShiftReg = numShiftReg - 1;
					next_var1reg = var1reg * 2;
					nextout = next_var1reg;
					outld = 1;
					nextstate = S1;
				end//else 3
				
				end //end else 1
			end	//end S1
		endcase
end//always block

endmodule