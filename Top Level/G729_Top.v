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
module G729_Top(clock, reset, start,in, outBufAddr, out, testdone, done);
   
	//inputs
	input clock;
   input reset;
	input start;
	input [11:0] outBufAddr;
   input [15:0] in;
	input testdone;
	
	//outputs
   output [31:0] out;
	output reg done;
	
	//working wires
	wire FSMdone;
	wire frame_done;
	wire [5:0] mathMuxSel;
//	wire autocorrReady;
//	wire lagReady;
//	wire levinsonReady;
//	wire AzReady;
//	wire Qua_lspReady;
//	wire Int_lpcReady;
//	wire Int_qlpcReady;
//	wire Math1Ready;
	wire autocorrDone;
	wire lagDone;
	wire levinsonDone;
	wire AzDone;
	wire Qua_lspDone;
	wire Int_lpcDone;
	wire Int_qlpcDone;
	wire Math1Done;
	wire divErr;
//	assign done = FSMdone;

	reg preProcReady;
	reg preProcWaiting;
	reg autocorrReady;
	reg autocorrWaiting;
	reg lagReady;
	reg lagWaiting;
	reg levinsonReady;
	reg levinsonWaiting;
	reg AzReady;
	reg AzWaiting;
	reg Qua_lspReady;
	reg Qua_lspWaiting;
	reg Int_lpcReady;
	reg Int_lpcWaiting;
	reg Int_qlpcReady;
	reg Int_qlpcWaiting;
	reg Math1Ready;
	reg Math1Waiting;
	
	wire autocorrReadyFSM;
	wire lagReadyFSM;
	wire levinsonReadyFSM;
	wire AzReadyFSM;
	wire Qua_lspReadyFSM;
	wire Int_lpcReadyFSM;
	wire Int_qlpcReadyFSM;
	wire Math1ReadyFSM;

	G729_Pipe i_G729_Pipe(
								 .clock(clock),
								 .reset(reset),
								 .xn(in),
								 .preProcReady(preProcReady),
								 .autocorrReady(autocorrReady),
								 .lagReady(lagReady),
								 .levinsonReady(levinsonReady),
								 .AzReady(AzReady),
								 .Qua_lspReady(Qua_lspReady),
								 .Int_lpcReady(Int_lpcReady),
								 .Int_qlpcReady(Int_qlpcReady),
								 .Math1Ready(Math1Ready),
								 .mathMuxSel(mathMuxSel),
								 .frame_done(frame_done),
								 .autocorrDone(autocorrDone),
								 .lagDone(lagDone),
								 .levinsonDone(levinsonDone),
								 .AzDone(AzDone),
								 .Qua_lspDone(Qua_lspDone),
 								 .Int_lpcDone(Int_lpcDone),
 								 .Int_qlpcDone(Int_qlpcDone),
 								 .Math1Done(Math1Done),
								 .divErr(divErr),
								 .outBufAddr(outBufAddr),
								 .out(out)
								 );
	
	
	G729_FSM i_G729_FSM(
								.clock(clock),
								.reset(reset),
								.start(start),
								.divErr(divErr),
								.frame_done(frame_done),
								.autocorrDone(autocorrDone),
								.lagDone(lagDone),
								.levinsonDone(levinsonDone),
								.AzDone(AzDone),
								.Qua_lspDone(Qua_lspDone),
 								.Int_lpcDone(Int_lpcDone),
 								.Int_qlpcDone(Int_qlpcDone),
 								.Math1Done(Math1Done),
								.mathMuxSel(mathMuxSel),
								.autocorrReady(autocorrReadyFSM),
								.lagReady(lagReadyFSM),
								.levinsonReady(levinsonReadyFSM),
								.AzReady(AzReadyFSM),	
								.Qua_lspReady(Qua_lspReadyFSM),
								.Int_lpcReady(Int_lpcReadyFSM),
								.Int_qlpcReady(Int_qlpcReadyFSM),
								.Math1Ready(Math1ReadyFSM),
								.done(FSMdone)
							 );

	always @ (*)
	begin
		preProcReady = 0;
		if (start)
			preProcWaiting = 1;
		if (preProcWaiting)
		begin
			if (testdone)
			begin
				preProcReady = 1;
				preProcWaiting = 0;
			end
		end
	end
							 
	always @ (*)
	begin
		autocorrReady = 0;
		if (autocorrReadyFSM)
			autocorrWaiting = 1;
		if (autocorrWaiting)
		begin
			if (testdone)
			begin
				autocorrReady = 1;
				autocorrWaiting = 0;
			end
		end
	end
	
	always @ (*)
	begin
		lagReady = 0;
		if (lagReadyFSM)
			lagWaiting = 1;
		if (lagWaiting)
		begin
			if (testdone)
			begin
				lagReady = 1;
				lagWaiting = 0;
			end
		end
	end
	
	always @ (*)
	begin
		levinsonReady = 0;
		if (levinsonReadyFSM)
			levinsonWaiting = 1;
		if (levinsonWaiting)
		begin
			if (testdone)
			begin
				levinsonReady = 1;
				levinsonWaiting = 0;
			end
		end
	end
	
	always @ (*)
	begin
		AzReady = 0;
		if (AzReadyFSM)
			AzWaiting = 1;
		if (AzWaiting)
		begin
			if (testdone)
			begin
				AzReady = 1;
				AzWaiting = 0;
			end
		end
	end
	
	always @ (*)
	begin
		Qua_lspReady = 0;
		if (Qua_lspReadyFSM)
			Qua_lspWaiting = 1;
		if (Qua_lspWaiting)
		begin
			if (testdone)
			begin
				Qua_lspReady = 1;
				Qua_lspWaiting = 0;
			end
		end
	end
	
	always @ (*)
	begin
		Int_lpcReady = 0;
		if (Int_lpcReadyFSM)
			Int_lpcWaiting = 1;
		if (Int_lpcWaiting)
		begin
			if (testdone)
			begin
				Int_lpcReady = 1;
				Int_lpcWaiting = 0;
			end
		end
	end
	
	always @ (*)
	begin
		Int_qlpcReady = 0;
		if (Int_qlpcReadyFSM)
			Int_qlpcWaiting = 1;
		if (Int_qlpcWaiting)
		begin
			if (testdone)
			begin
				Int_qlpcReady = 1;
				Int_qlpcWaiting = 0;
			end
		end
	end
	
	always @ (*)
	begin
		Math1Ready = 0;
		if (Math1ReadyFSM)
			Math1Waiting = 1;
		if (Math1Waiting)
		begin
			if (testdone)
			begin
				Math1Ready = 1;
				Math1Waiting = 0;
			end
		end
	end
	
	always @ (*)
	begin
		if (autocorrReadyFSM || autocorrDone || lagDone || levinsonDone || AzDone || Qua_lspDone || Int_lpcDone || Int_qlpcDone || Math1Done)
			done = 1;
		else 
			done = 0;
	end

endmodule
