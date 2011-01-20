`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Dr. Tommy Morris, Zach Thornton
// 
// Create Date:    17:37:04 08/25/2010 
// Module Name:    preProcPipe.v 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 This level instatiates the adder, multiplier, muxs, and registers 
//                 needed for the operation of the pre-processing FIR filter, as well as declaring neccesary 
//						 constants for multiplication and rounding.
//
// Dependencies: 	 N/A

//
//////////////////////////////////////////////////////////////////////////////////
module preProcPipe(mclk,reset,xn,yn,ld1,ld2,ld3,ld4,ld5,ld6,ld7,mux0_sel,mux1_sel,mux2_sel,mux3_sel,mux4_sel);

input mclk,reset;
input ld1,ld2,ld3,ld4,ld5,ld6,ld7;
input mux0_sel,mux3_sel,mux4_sel;
input [2:0] mux1_sel,mux2_sel;
input [15:0] xn;
output [15:0] yn;

wire [31:0] R1_out, R2_out, R3_out, R4_out, R5_out, R6_out, R7_out;
wire [31:0] add_out, mult_out;
wire [31:0] mux0_out, mux1_out, mux3_out, mux4_out; 
wire [15:0]  mux2_out;
wire signed [15:0] a1 = -3798;
wire signed [15:0] a2 = 1899;
wire signed [15:0] a3 = 1899;
wire signed [15:0] b1 = 7807;
wire signed [15:0] b2 = -3733;
wire [31:0] round = 32'h00008000;
wire [31:0] yn_31;

assign yn_31 = add_out;
assign yn = yn_31[31:16];

reg_Q31 R1 (.mclk(mclk), .reset(reset), .ld(ld1), .d(R5_out) , .q(R1_out));
reg_Q31 R2 (.mclk(mclk), .reset(reset), .ld(ld2), .d(R1_out) , .q(R2_out));
reg_Q31 R3 (.mclk(mclk), .reset(reset), .ld(ld3), .d(add_out) , .q(R3_out));
reg_Q31 R4 (.mclk(mclk), .reset(reset), .ld(ld4), .d(R3_out) , .q(R4_out));
reg_Q31 R5 (.mclk(mclk), .reset(reset), .ld(ld5), .d({xn,16'd0}) , .q(R5_out));
reg_Q31 R6 (.mclk(mclk), .reset(reset), .ld(ld6), .d(mult_out) , .q(R6_out));
reg_Q31 R7 (.mclk(mclk), .reset(reset), .ld(ld7), .d(mux0_out) , .q(R7_out));

twoway_Q31mux mux0(.in0(add_out), .in1(mult_out), .sel(mux0_sel), .out(mux0_out));
fiveway_Q31mux mux1(.in0(R1_out), .in1(R5_out), .in2(R2_out), .in3(R3_out), .in4(R4_out),.sel(mux1_sel),.out(mux1_out));
fiveway_constantmux mux2(.in0(a1), .in1(a2), .in2(a3), .in3(b1), .in4(b2), .sel(mux2_sel), .out(mux2_out));
twoway_Q31mux mux3(.in0(R6_out), .in1(R3_out), .sel(mux3_sel), .out(mux3_out));
twoway_Q31mux mux4(.in0(R7_out), .in1(round), .sel(mux4_sel), .out(mux4_out));

mult_q31 mult(.a(mux1_out), .b(mux2_out), .product(mult_out));
add_q31 add (.a(mux3_out), .b(mux4_out), .sum(add_out));




endmodule
