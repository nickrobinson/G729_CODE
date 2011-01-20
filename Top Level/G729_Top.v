`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    14:11:35 10/14/2010 
// Module Name:    G729_Top 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Top Level Module for G.729 Encoder.
//
// Dependencies: 	 G729_Pipe.v, G729_FSM.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module G729_Top(clock, reset, start,in, out,done);
   
	//inputs
	input clock;
   input reset;
	input start;
   input [15:0] in;
	
	//outputs
   output [31:0] out;
	output done;
	
	//working wires
	wire FSMdone;
	wire frame_done;
	wire [5:0] mathMuxSel;
	wire autocorrReady;
	wire lagReady;
	wire autocorrDone;
	wire lagDone;
	assign done = FSMdone;
	
	G729_Pipe i_G729_Pipe(
								 .clock(clock),
								 .reset(reset),
								 .xn(in),
								 .preProcReady(start),
								 .autocorrReady(autocorrReady),
								 .lagReady(lagReady),
								 .mathMuxSel(mathMuxSel),
								 .frame_done(frame_done),
								 .autocorrDone(autocorrDone),
								 .lagDone(lagDone),
								 .out(out)
								 );
	
	
	G729_FSM i_G729_FSM(
								.clock(clock),
								.reset(reset),
								.start(start),
								.frame_done(frame_done),
								.autocorrDone(autocorrDone),
								.lagDone(lagDone),
								.mathMuxSel(mathMuxSel),
								.autocorrReady(autocorrReady),
								.lagReady(lagReady),
								.done(FSMdone)
							 );

endmodule
