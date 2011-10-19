`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:57:14 09/12/2011 
// Design Name: 
// Module Name:    CheckPartityPitch_Pipe 
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
module CheckParityPitch_Pipe(clk, start, reset, done, pitch_index, parity, sum);

   //inputs
	input clk;
	input reset;
	input start;
	
	input [15:0] pitch_index;
	input [15:0] parity;

	output done;
	output [15:0] sum;

	wire [15:0] add_a, add_b;
	wire [15:0] shr_a, shr_b;
	wire [15:0] add_in, shr_in;

	add Check_Parity_pitch_add(
	.a(add_a),
	.b(add_b),
	.overflow(),
	.sum(add_in));

	shr Check_Parity_pitch_shr(
	.var1(shr_a),
	.var2(shr_b),
	.overflow(),
	.result(shr_in));
	
	CheckParityPitch i_fsm(
	.clk(clk), 
	.start(start), 
	.reset(reset), 
	.done(done), 
	.pitch_index(pitch_index),
	.parity(parity),
	.sum(sum), 
	.add_a(add_a), 
	.add_b(add_b), 
	.add_in(add_in), 
	.shr_a(shr_a), 
	.shr_b(shr_b), 
	.shr_in(shr_in));

endmodule
