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
module G729_Top(clock, reset, start, in, outBufAddr, out, testdone, done);
  
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
	wire Pitch_fr3Done;	//New submodules
	wire Enc_lag3Done;
	wire Parity_PitchDone;
	wire Pred_lt_3Done;
	wire ConvolveDone;
	wire G_pitchDone;
	wire Math4Done;
	wire test_errDone;
	wire ACELP_CodebookDone;
	wire Math5Done;
	wire Corr_xy2Done;
	wire Qua_gainDone;
	wire Math6Done;
	wire update_exc_errDone;
	wire Math7Done;
	wire CopyDone;
	wire prm2bits_ld8kDone;	

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
	reg Pitch_fr3Ready;			//New submodules
	reg Pitch_fr3Waiting;	
	reg Enc_lag3Ready;
	reg Enc_lag3Waiting;
	reg Parity_PitchReady;
	reg Parity_PitchWaiting;
	reg Pred_lt_3Ready;
	reg Pred_lt_3Waiting;
	reg ConvolveReady;
	reg ConvolveWaiting;
	reg G_pitchReady;
	reg G_pitchWaiting;	
	reg Math4Ready;
	reg Math4Waiting;
	reg test_errReady;
	reg test_errWaiting;
	reg ACELP_CodebookReady;
	reg ACELP_CodebookWaiting;
	reg Math5Ready;
	reg Math5Waiting;
	reg Corr_xy2Ready;
	reg Corr_xy2Waiting;	
	reg Qua_gainReady;
	reg Qua_gainWaiting;	
	reg Math6Ready;
	reg Math6Waiting;	
	reg update_exc_errReady;
	reg update_exc_errWaiting;
	reg Math7Ready;
	reg Math7Waiting;
	reg CopyReady;
	reg CopyWaiting;
	reg prm2bits_ld8kReady;
	reg prm2bits_ld8kWaiting;
	
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
	wire Pitch_fr3ReadyFSM;		//New submodules
	wire Enc_lag3ReadyFSM;
	wire Parity_PitchReadyFSM;
	wire Pred_lt_3ReadyFSM;
	wire ConvolveReadyFSM;
	wire G_pitchReadyFSM;
	wire Math4ReadyFSM;
	wire test_errReadyFSM;
	wire ACELP_CodebookReadyFSM;
	wire Math5ReadyFSM;
	wire Corr_xy2ReadyFSM;
	wire Qua_gainReadyFSM;
	wire Math6ReadyFSM;
	wire update_exc_errReadyFSM;
	wire Math7ReadyFSM;
	wire CopyReadyFSM;
	wire prm2bits_ld8kReadyFSM;		

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
	wire LDsharp;
	wire LDi;
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
	wire resetsharp;
	wire reseti;

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
								.Pitch_fr3Ready(Pitch_fr3Ready),
								.Enc_lag3Ready(Enc_lag3Ready),
								.Parity_PitchReady(Parity_PitchReady),
								.Pred_lt_3Ready(Pred_lt_3Ready),
								.ConvolveReady(ConvolveReady),
								.G_pitchReady(G_pitchReady),
								.Math4Ready(Math4Ready),
								.test_errReady(test_errReady),
								.ACELP_CodebookReady(ACELP_CodebookReady),
								.Math5Ready(Math5Ready),
								.Corr_xy2Ready(Corr_xy2Ready),
								.Qua_gainReady(Qua_gainReady),
								.Math6Ready(Math6Ready),
								.update_exc_errReady(update_exc_errReady),
								.Math7Ready(Math7Ready),
								.CopyReady(CopyReady),
								.prm2bits_ld8kReady(prm2bits_ld8kReady),
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
								.LDsharp(LDsharp),
								.LDi(LDi),
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
								.resetsharp(resetsharp),
								.reseti(reseti),
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
								.Pitch_fr3Done(Pitch_fr3Done),
								.Enc_lag3Done(Enc_lag3Done),
								.Parity_PitchDone(Parity_PitchDone),
								.Pred_lt_3Done(Pred_lt_3Done),
								.ConvolveDone(ConvolveDone),
								.G_pitchDone(G_pitchDone),
								.Math4Done(Math4Done),
								.test_errDone(test_errDone),
								.ACELP_CodebookDone(ACELP_CodebookDone),
								.Math5Done(Math5Done),
								.Corr_xy2Done(Corr_xy2Done),
								.Qua_gainDone(Qua_gainDone),
								.Math6Done(Math6Done),
								.update_exc_errDone(update_exc_errDone),
								.Math7Done(Math7Done),
								.CopyDone(CopyDone),
								.prm2bits_ld8kDone(prm2bits_ld8kDone),								
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
								.Pitch_fr3Done(Pitch_fr3Done),
								.Enc_lag3Done(Enc_lag3Done),
								.Parity_PitchDone(Parity_PitchDone),
								.Pred_lt_3Done(Pred_lt_3Done),
								.ConvolveDone(ConvolveDone),
								.G_pitchDone(G_pitchDone),
								.Math4Done(Math4Done),
								.test_errDone(test_errDone),
								.ACELP_CodebookDone(ACELP_CodebookDone),
								.Math5Done(Math5Done),
								.Corr_xy2Done(Corr_xy2Done),
								.Qua_gainDone(Qua_gainDone),
								.Math6Done(Math6Done),
								.update_exc_errDone(update_exc_errDone),
								.Math7Done(Math7Done),
								.CopyDone(CopyDone),
								.prm2bits_ld8kDone(prm2bits_ld8kDone),								
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
								.LDsharp(LDsharp),
								.LDi(LDi),
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
								.resetsharp(resetsharp),
								.reseti(reseti),
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
								.Pitch_fr3Ready(Pitch_fr3ReadyFSM),
								.Enc_lag3Ready(Enc_lag3ReadyFSM),
								.Parity_PitchReady(Parity_PitchReadyFSM),
								.Pred_lt_3Ready(Pred_lt_3ReadyFSM),
								.ConvolveReady(ConvolveReadyFSM),
								.G_pitchReady(G_pitchReadyFSM),
								.Math4Ready(Math4ReadyFSM),
								.test_errReady(test_errReadyFSM),
								.ACELP_CodebookReady(ACELP_CodebookReadyFSM),
								.Math5Ready(Math5ReadyFSM),
								.Corr_xy2Ready(Corr_xy2ReadyFSM),
								.Qua_gainReady(Qua_gainReadyFSM),
								.Math6Ready(Math6ReadyFSM),
								.update_exc_errReady(update_exc_errReadyFSM),
								.Math7Ready(Math7ReadyFSM),
								.CopyReady(CopyReadyFSM),
								.prm2bits_ld8kReady(prm2bits_ld8kReadyFSM),
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
	
	always @ (*)		//Pitch_fr3
	begin
		Pitch_fr3Ready = 0;
		if (Pitch_fr3ReadyFSM)
			Pitch_fr3Waiting = 1;
		if (Pitch_fr3Waiting)
		begin
			if (testdone)
			begin
				Pitch_fr3Ready = 1;
				Pitch_fr3Waiting = 0;
			end
		end
	end
	
	always @ (*)		//Enc_lag3FSM
	begin
		Enc_lag3Ready = 0;
		if (Enc_lag3ReadyFSM)
			Enc_lag3Waiting = 1;
		if (Enc_lag3Waiting)
		begin
			if (testdone)
			begin
				Enc_lag3Ready = 1;
				Enc_lag3Waiting = 0;
			end
		end
	end	
	
	always @ (*)		//Parity_Pitch
	begin
		Parity_PitchReady = 0;
		if (Parity_PitchReadyFSM)
			Parity_PitchWaiting = 1;
		if (Parity_PitchWaiting)
		begin
			if (testdone)
			begin
				Parity_PitchReady = 1;
				Parity_PitchWaiting = 0;
			end
		end
	end	
	
	always @ (*)		//Pred_lt_3
	begin
		Pred_lt_3Ready = 0;
		if (Pred_lt_3ReadyFSM)
			Pred_lt_3Waiting = 1;
		if (Pred_lt_3Waiting)
		begin
			if (testdone)
			begin
				Pred_lt_3Ready = 1;
				Pred_lt_3Waiting = 0;
			end
		end
	end	
	
	always @ (*)		//Convolve
	begin
		ConvolveReady = 0;
		if (ConvolveReadyFSM)
			ConvolveWaiting = 1;
		if (ConvolveWaiting)
		begin
			if (testdone)
			begin
				ConvolveReady = 1;
				ConvolveWaiting = 0;
			end
		end
	end	
	
	always @ (*)		//G_pitch
	begin
		G_pitchReady = 0;
		if (G_pitchReadyFSM)
			G_pitchWaiting = 1;
		if (G_pitchWaiting)
		begin
			if (testdone)
			begin
				G_pitchReady = 1;
				G_pitchWaiting = 0;
			end
		end
	end	
	
	always @ (*)		//Math4
	begin
		Math4Ready = 0;
		if (Math4ReadyFSM)
			Math4Waiting = 1;
		if (Math4Waiting)
		begin
			if (testdone)
			begin
				Math4Ready = 1;
				Math4Waiting = 0;
			end
		end
	end	
	
	always @ (*)		//test_err
	begin
		test_errReady = 0;
		if (test_errReadyFSM)
			test_errWaiting = 1;
		if (test_errWaiting)
		begin
			if (testdone)
			begin
				test_errReady = 1;
				test_errWaiting = 0;
			end
		end
	end	
	
	always @ (*)		//ACELP_Codebook
	begin
		ACELP_CodebookReady = 0;
		if (ACELP_CodebookReadyFSM)
			ACELP_CodebookWaiting = 1;
		if (ACELP_CodebookWaiting)
		begin
			if (testdone)
			begin
				ACELP_CodebookReady = 1;
				ACELP_CodebookWaiting = 0;
			end
		end
	end	
	
	always @ (*)		//Math 5
	begin
		Math5Ready = 0;
		if (Math5ReadyFSM)
			Math5Waiting = 1;
		if (Math5Waiting)
		begin
			if (testdone)
			begin
				Math5Ready = 1;
				Math5Waiting = 0;
			end
		end
	end
	
	always @ (*)		//Corr_xy2
	begin
		Corr_xy2Ready = 0;
		if (Corr_xy2ReadyFSM)
			Corr_xy2Waiting = 1;
		if (Corr_xy2Waiting)
		begin
			if (testdone)
			begin
				Corr_xy2Ready = 1;
				Corr_xy2Waiting = 0;
			end
		end
	end
	
	always @ (*)		//Qua_gain
	begin
		Qua_gainReady = 0;
		if (Qua_gainReadyFSM)
			Qua_gainWaiting = 1;
		if (Qua_gainWaiting)
		begin
			if (testdone)
			begin
				Qua_gainReady = 1;
				Qua_gainWaiting = 0;
			end
		end
	end	
	
	always @ (*)		//Math 6
	begin
		Math6Ready = 0;
		if (Math6ReadyFSM)
			Math6Waiting = 1;
		if (Math6Waiting)
		begin
			if (testdone)
			begin
				Math6Ready = 1;
				Math6Waiting = 0;
			end
		end
	end	
	
	always @ (*)		//update_exc_err
	begin
		update_exc_errReady = 0;
		if (update_exc_errReadyFSM)
			update_exc_errWaiting = 1;
		if (update_exc_errWaiting)
		begin
			if (testdone)
			begin
				update_exc_errReady = 1;
				update_exc_errWaiting = 0;
			end
		end
	end	
	
	always @ (*)		//Math 7
	begin
		Math7Ready = 0;
		if (Math7ReadyFSM)
			Math7Waiting = 1;
		if (Math7Waiting)
		begin
			if (testdone)
			begin
				Math7Ready = 1;
				Math7Waiting = 0;
			end
		end
	end	
	
	always @ (*)		//Copy
	begin
		CopyReady = 0;
		if (CopyReadyFSM)
			CopyWaiting = 1;
		if (CopyWaiting)
		begin
			if (testdone)
			begin
				CopyReady = 1;
				CopyWaiting = 0;
			end
		end
	end	
	
	always @ (*)		//prm2bits_ld8k
	begin
		prm2bits_ld8kReady = 0;
		if (prm2bits_ld8kReadyFSM)
			prm2bits_ld8kWaiting = 1;
		if (prm2bits_ld8kWaiting)
		begin
			if (testdone)
			begin
				prm2bits_ld8kReady = 1;
				prm2bits_ld8kWaiting = 0;
			end
		end
	end	
	
	always @ (*)
	begin
		if (autocorrReadyFSM || autocorrDone || lagDone || levinsonDone || AzDone || Qua_lspDone || Int_lpcDone || Int_qlpcDone || Math1Done || perc_varDone || Weight_AzDone || ResiduDone || Syn_filtDone || Pitch_olDone || Math2Done || Math3Done || Pitch_fr3Done || Enc_lag3Done || Parity_PitchDone || Pred_lt_3Done || ConvolveDone || G_pitchDone || Math4Done || test_errDone || ACELP_CodebookDone || Math5Done || Corr_xy2Done || Qua_gainDone || Math6Done || update_exc_errDone || Math7Done || CopyDone || prm2bits_ld8kDone)								
			done = 1;
		else 
			done = 0;
	end

endmodule
