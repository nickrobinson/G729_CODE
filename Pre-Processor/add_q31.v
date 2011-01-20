`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Dr. Tommy Morris
// 
// Create Date:    11:17:50 06/18/2010
// Module Name:    add_q31.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a q31 adder with saturation.
// Dependencies: 	 N/A

//
//////////////////////////////////////////////////////////////////////////////////

module add_q31(a, b, sum);

input [31:0] a, b;
output [31:0] sum;

wire signed [31:0] a, b;
reg signed [31:0] sum;

reg signed [31:0] temp;

parameter MIN_32 = 32'h8000_0000;
parameter MAX_32  = 32'h7fff_ffff;

always @(*)
  begin
    temp = a + b;
    if (temp[31] & ~a[31] & ~b[31]) // neg+neg=pos NOT ALLOWED
      temp = 32'h8000_0000;
    else if (~temp[31] & a[31] & b[31]) // pos+pos=neg NOT ALLOWED
      temp = 32'h7fff_ffff;
    sum = temp[31:0];
  end 

endmodule
