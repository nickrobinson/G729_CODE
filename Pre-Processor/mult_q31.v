`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Dr. Tommy Morris
// 
// Create Date:    11:17:50 06/18/2010
// Module Name:    mult_q31.v
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	This is a q31*q12 multiplier with saturation.
// Dependencies: 	 N/A

//
//////////////////////////////////////////////////////////////////////////////////

module mult_q31(a, b, product);

input [31:0] a;
input [15:0] b;
output [31:0] product;

wire signed [31:0] a;
wire signed [15:0] b;
wire signed [31:0] product;

//reg signed [47:0] temp;

parameter MIN_32 = 32'h8000_0000;
parameter MAX_32  = 32'h7fff_ffff;

wire signed [47:0] t1;
wire signed [47:0] t2;
 
  // Q31 * Q12
  //   s.nnn_nnnn_nnnn_nnnn_nnnn_nnnn_nnnn_nnnn
  // * ssss.nnnn_nnnn_nnnn
  // ------------------------------------------
  //   sssss.nnn_nnnn_nnnn_nnnn_nnnn_nnnn_nnnn_nnnn_nnnn_nnnn_nnnn
  // We drop the first 4 bits since 1*1, -1*-1, etc, never needs these bits 
  // keep 32-bits from 43 downto 16
  // the lest significant 4 bits are dropped to match ITU G.729
  // ANSI C fixed point model (this causes precision loss, but we want
  // a bit exact match with the standard
  //   s.nnn_nnnn_nnnn_nnnn_nnnn_nnnn_nnnn_0000 

  assign t1 = a * b;
  assign t2 = (~a[31] & ~b[15] & t1[43])   ? 48'h07ff_ffff_ffff : //overflow pos*pos=neg NOT ALLOWED
              (a[31] & b[15] & t1[43])   ? 48'h07ff_ffff_ffff : //overflow neg*neg=neg NOT ALLOWED
              (~a[31] & b[15] & ~t1[43]) ? 48'h0800_0000_0000 : //overflow neg*pos=pos NOT ALLOWED
              (a[31] & ~b[15] & ~t1[43]) ? 48'h0800_0000_0000 : //overflow pos*neg=pos NOT ALLOWED
              t1;

  assign product = {t1[43:16], 4'd0};

endmodule
