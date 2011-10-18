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
	wire frame_done;
	wire [5:0] mathMuxSel;
	wire autocorrDone;
	wire lagDone;
	wire levinsonDone;
	wire AzDone;
	wire Qua_lspDone;
	wire Int_lpcDone;
	wire Int_qlpcDone;
	wire Math1Done;
	wire perc_varDone;
	wire Weight_AzDone;
	wire ResiduDone;
	wire Syn_filtDone;
	wire Pitch_olDone;
	wire Math2Done;
	wire Math3Done;
	wire [15:0] i_subfr;
	wire divErr;

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
	reg perc_varReady;
	reg perc_varWaiting;
	reg Weight_AzReady;
	reg Weight_AzWaiting;
	reg ResiduReady;
	reg ResiduWaiting;
	reg Syn_filtReady;
	reg Syn_filtWaiting;
	reg Pitch_olReady;
	reg Pitch_olWaiting;
	reg Math2Ready;
	reg Math2Waiting;
	reg Math3Ready;
	reg Math3Waiting;

	wire autocorrReadyFSM;
	wire lagReadyFSM;
	wire levinsonReadyFSM;
	wire AzReadyFSM;
	wire Qua_lspReadyFSM;
	wire Int_lpcReadyFSM;
	wire Int_qlpcReadyFSM;
	wire Math1ReadyFSM;
	wire perc_varReadyFSM;
	wire Weight_AzReadyFSM;
	wire ResiduReadyFSM;
	wire Syn_filtReadyFSM;
	wire Pitch_olReadyFSM;
	wire Math2ReadyFSM;
	wire Math3ReadyFSM;

	wire LDk;
	wire LDi_subfr;
	wire LDi_gamma;
	wire LDT_op;
	wire LDT0;
	wire LDT0_min;
	wire LDT0_max;
	wire LDT0_frac;
	wire LDgain_pit;
	wire LDgain_code;
	wire LDindex;
	wire LDtemp;
	wire LDL_temp;
	wire LDA_Addr;
	wire LDAq_Addr;
	wire resetk; 
	wire reseti_subfr;
	wire reseti_gamma;
	wire resetT_op;
	wire resetT0;
	wire resetT0_min;
	wire resetT0_max; 
	wire resetT0_frac;
	wire resetgain_pit;
	wire resetgain_code;
	wire resetindex;
	wire resettemp;
	wire resetL_temp;
	wire resetA_Addr;
	wire resetAq_Addr;

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
								.perc_varReady(perc_varReady),
								.Weight_AzReady(Weight_AzReady),
								.ResiduReady(ResiduReady),
								.Syn_filtReady(Syn_filtReady),
								.Pitch_olReady(Pitch_olReady),
								.Math2Ready(Math2Ready),
								.Math3Ready(Math3Ready),
								.LDk(LDk),
								.LDi_subfr(LDi_subfr),
								.LDi_gamma(LDi_gamma),
								.LDT_op(LDT_op),
								.LDT0(LDT0),
								.LDT0_min(LDT0_min),
								.LDT0_max(LDT0_max),
								.LDT0_frac(LDT0_frac),
								.LDgain_pit(LDgain_pit),
								.LDgain_code(LDgain_code),
								.LDindex(LDindex),
								.LDtemp(LDtemp),
								.LDL_temp(LDL_temp),
								.LDA_Addr(LDA_Addr),
								.LDAq_Addr(LDAq_Addr),
								.resetk(resetk), 
								.reseti_subfr(reseti_subfr),
								.reseti_gamma(reseti_gamma),
								.resetT_op(resetT_op),
								.resetT0(resetT0),
								.resetT0_min(resetT0_min),
								.resetT0_max(resetT0_max), 
								.resetT0_frac(resetT0_frac),
								.resetgain_pit(resetgain_pit),
								.resetgain_code(resetgain_code),
								.resetindex(resetindex),
								.resettemp(resettemp),
								.resetL_temp(resetL_temp),
								.resetA_Addr(resetA_Addr),
								.resetAq_Addr(resetAq_Addr),
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
 	 							.perc_varDone(perc_varDone),
 	 							.Weight_AzDone(Weight_AzDone),
 	 							.ResiduDone(ResiduDone),
 	 							.Syn_filtDone(Syn_filtDone),
 	 							.Pitch_olDone(Pitch_olDone),
 								.Math2Done(Math2Done),
 								.Math3Done(Math3Done),
 								.i_subfr(i_subfr),
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
 								.perc_varDone(perc_varDone),
 								.Weight_AzDone(Weight_AzDone),
 								.ResiduDone(ResiduDone),
 								.Syn_filtDone(Syn_filtDone),
 								.Pitch_olDone(Pitch_olDone),
 								.Math2Done(Math2Done),
 								.Math3Done(Math3Done),
 								.i_subfr(i_subfr),
								.LDk(LDk),
								.LDi_subfr(LDi_subfr),
								.LDi_gamma(LDi_gamma),
								.LDT_op(LDT_op),
								.LDT0(LDT0),
								.LDT0_min(LDT0_min),
								.LDT0_max(LDT0_max),
								.LDT0_frac(LDT0_frac),
								.LDgain_pit(LDgain_pit),
								.LDgain_code(LDgain_code),
								.LDindex(LDindex),
								.LDtemp(LDtemp),
								.LDL_temp(LDL_temp),
								.LDA_Addr(LDA_Addr),
								.LDAq_Addr(LDAq_Addr),
								.resetk(resetk), 
								.reseti_subfr(reseti_subfr),
								.reseti_gamma(reseti_gamma),
								.resetT_op(resetT_op),
								.resetT0(resetT0),
								.resetT0_min(resetT0_min),
								.resetT0_max(resetT0_max), 
								.resetT0_frac(resetT0_frac),
								.resetgain_pit(resetgain_pit),
								.resetgain_code(resetgain_code),
								.resetindex(resetindex),
								.resettemp(resettemp),
								.resetL_temp(resetL_temp),
								.resetA_Addr(resetA_Addr),
								.resetAq_Addr(resetAq_Addr),
								.mathMuxSel(mathMuxSel),
								.autocorrReady(autocorrReadyFSM),
								.lagReady(lagReadyFSM),
								.levinsonReady(levinsonReadyFSM),
								.AzReady(AzReadyFSM),	
								.Qua_lspReady(Qua_lspReadyFSM),
								.Int_lpcReady(Int_lpcReadyFSM),
								.Int_qlpcReady(Int_qlpcReadyFSM),
								.Math1Ready(Math1ReadyFSM),
								.perc_varReady(perc_varReadyFSM),
								.Weight_AzReady(Weight_AzReadyFSM),
								.ResiduReady(ResiduReadyFSM),
								.Syn_filtReady(Syn_filtReadyFSM),
								.Pitch_olReady(Pitch_olReadyFSM),
								.Math2Ready(Math2ReadyFSM),
								.Math3Ready(Math3ReadyFSM),
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
		perc_varReady = 0;
		if (perc_varReadyFSM)
			perc_varWaiting = 1;
		if (perc_varWaiting)
		begin
			if (testdone)
			begin
				perc_varReady = 1;
				perc_varWaiting = 0;
			end
		end
	end
	
	always @ (*)
	begin
		Weight_AzReady = 0;
		if (Weight_AzReadyFSM)
			Weight_AzWaiting = 1;
		if (Weight_AzWaiting)
		begin
			if (testdone)
			begin
				Weight_AzReady = 1;
				Weight_AzWaiting = 0;
			end
		end
	end

	always @ (*)
	begin
		ResiduReady = 0;
		if (ResiduReadyFSM)
			ResiduWaiting = 1;
		if (ResiduWaiting)
		begin
			if (testdone)
			begin
				ResiduReady = 1;
				ResiduWaiting = 0;
			end
		end
	end

	always @ (*)
	begin
		Syn_filtReady = 0;
		if (Syn_filtReadyFSM)
			Syn_filtWaiting = 1;
		if (Syn_filtWaiting)
		begin
			if (testdone)
			begin
				Syn_filtReady = 1;
				Syn_filtWaiting = 0;
			end
		end
	end

	always @ (*)
	begin
		Pitch_olReady = 0;
		if (Pitch_olReadyFSM)
			Pitch_olWaiting = 1;
		if (Pitch_olWaiting)
		begin
			if (testdone)
			begin
				Pitch_olReady = 1;
				Pitch_olWaiting = 0;
			end
		end
	end
	
	always @ (*)
	begin
		Math2Ready = 0;
		if (Math2ReadyFSM)
			Math2Waiting = 1;
		if (Math2Waiting)
		begin
			if (testdone)
			begin
				Math2Ready = 1;
				Math2Waiting = 0;
			end
		end
	end

	always @ (*)
	begin
		Math3Ready = 0;
		if (Math3ReadyFSM)
			Math3Waiting = 1;
		if (Math3Waiting)
		begin
			if (testdone)
			begin
				Math3Ready = 1;
				Math3Waiting = 0;
			end
		end
	end
	
	always @ (*)
	begin
		if (autocorrReadyFSM || autocorrDone || lagDone || levinsonDone || AzDone || Qua_lspDone || Int_lpcDone || Int_qlpcDone || Math1Done || perc_varDone || Weight_AzDone || ResiduDone || Syn_filtDone || Pitch_olDone || Math2Done || Math3Done)
			done = 1;
		else 
			done = 0;
	end

endmodule
