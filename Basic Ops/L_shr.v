`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Zach Thornton
// 
// Create Date:    11:00:50 09/11/2010 
// Module Name:    L_shr.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a function that shifts var1 right by numShift and places the result in out.
// 					If numShift is negative, this right shifter will invert numShift and shift right by +numShift.
//						It does not function exactly as the L_shr, because if numShift is negative in the C-model, it will call L_shl.
//						This functionality could be changed if needed.

// Dependencies: 	 N/A
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module L_shr(var1,numShift,overflow,out);

//Inputs
input signed [15:0] numShift;
input signed [31:0] var1;

//Outputs
output reg signed [31:0] out;
output reg overflow;

//Internal wires
wire [15:0] negNumShift;
wire [31:0] L_shlOut;

//Max and min parameters
parameter OUTPUT_MAX = 32'h7fff_ffff;
parameter OUTPUT_MIN = 32'h8000_0000;
parameter INPUT_MAX = 32'h3fff_ffff;
parameter INPUT_MIN = 32'hc000_0000;

assign negNumShift = (~numShift) + 16'd1;
assign L_shlOut = var1 << negNumShift;

always @(*) 
begin
	overflow = 0;
	
	if(numShift[15] == 1) 
	begin //if1
		if((var1[31] == 0) && (var1 > INPUT_MAX || L_shlOut == 0) && (numShift>0)&& (var1>0))
			out = OUTPUT_MAX;
		else if((var1[31] == 1) && (var1 < INPUT_MIN || L_shlOut == 0)&&(numShift>0)&& (var1>0)) 
			out = OUTPUT_MIN;
		else
			out = L_shlOut;
	end//if1	
	
	else //else1
	begin
		if(numShift >= 31) 
		begin//if2
			if(var1[31] == 1)
				out = -1;
			else if(var1[31] == 0)
				out = 0;
		end//if2
			
		else
			out = var1 >>> numShift;
	end//else1


end //always


endmodule
 