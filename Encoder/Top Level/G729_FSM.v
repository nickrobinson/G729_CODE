`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    14:13:23 10/14/2010 
// Module Name:    G729_FSM 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Top Level FSM Controller for G.729 Encoder. Signals each sub-module 
//						 to begin at the appropriate time.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module G729_FSM(clock,reset,start,divErr,
				frame_done,autocorrDone,lagDone,levinsonDone,AzDone,Qua_lspDone,Int_lpcDone,Int_qlpcDone,Math1Done,perc_varDone,Weight_AzDone,ResiduDone,Syn_filtDone,
				Pitch_olDone,Math2Done,Math3Done,Pitch_fr3Done,Enc_lag3Done,Parity_PitchDone,Pred_lt_3Done,ConvolveDone,G_pitchDone,Math4Done,test_errDone,ACELP_CodebookDone,
				Math5Done,Corr_xy2Done,Qua_gainDone,Math6Done,update_exc_errDone,Math7Done,CopyDone,prm2bits_ld8kDone,
				i_subfr,mathMuxSel,
				autocorrReady,lagReady,levinsonReady, AzReady,Qua_lspReady,Int_lpcReady,Int_qlpcReady,Math1Ready,perc_varReady,Weight_AzReady,ResiduReady,Syn_filtReady,Pitch_olReady,
				Math2Ready,Math3Ready,Pitch_fr3Ready,Enc_lag3Ready,Parity_PitchReady,Pred_lt_3Ready,ConvolveReady,G_pitchReady,Math4Ready,test_errReady,ACELP_CodebookReady,Math5Ready,
				Corr_xy2Ready,Qua_gainReady,Math6Ready,update_exc_errReady,Math7Ready,CopyReady,prm2bits_ld8kReady,	
				LDk,LDi_subfr,
				LDi_gamma,LDT_op,LDT0,LDT0_min,LDT0_max,LDT0_frac,LDgain_pit,LDgain_code,LDindex,LDtemp,LDA_Addr,LDAq_Addr,LDsharp,LDi,resetk,reseti_subfr,reseti_gamma,resetT_op,resetT0,resetT0_min,
				resetT0_max,resetT0_frac,resetgain_pit,resetgain_code,resetindex,resettemp,resetA_Addr,resetAq_Addr,resetsharp,reseti,LDL_temp,resetL_temp,done);
    
	 //inputs
	 input clock;
    input reset;
	 input start;
	 input divErr;
	 input frame_done;
	 input autocorrDone;
	 input lagDone;
	 input levinsonDone;
	 input AzDone;
	 input Qua_lspDone;
	 input Int_lpcDone;
 	 input Int_qlpcDone;
	 input Math1Done;
	 input perc_varDone;
	 input Weight_AzDone;
	 input ResiduDone;
	 input Syn_filtDone;
	 input Pitch_olDone;
	 input Math2Done;
	 input Math3Done;
	input Pitch_fr3Done;	//New submodules
	input Enc_lag3Done;
	input Parity_PitchDone;
	input Pred_lt_3Done;
	input ConvolveDone;
	input G_pitchDone;
	input Math4Done;
	input test_errDone;
	input ACELP_CodebookDone;
	input Math5Done;
	input Corr_xy2Done;
	input Qua_gainDone;
	input Math6Done;
	input update_exc_errDone;
	input Math7Done;
	input CopyDone;
	input prm2bits_ld8kDone;	 //End new submodules
	 input [15:0] i_subfr;
	 
	 ///outputs
	 output reg LDk, LDi_subfr, LDi_gamma, LDT_op, LDT0, LDT0_min, LDT0_max, LDT0_frac, LDgain_pit, LDgain_code, LDindex, LDtemp, LDA_Addr, LDAq_Addr, LDsharp, LDi;
	 output reg resetk, reseti_subfr, reseti_gamma, resetT_op, resetT0, resetT0_min, resetT0_max, resetT0_frac, resetgain_pit, resetgain_code, resetindex, resettemp, resetA_Addr, resetAq_Addr, resetsharp, reseti;
    output reg LDL_temp;
    output reg resetL_temp;
	 
	 output reg [5:0] mathMuxSel;
	 output reg autocorrReady;
	 output reg lagReady;
	 output reg levinsonReady;
	 output reg AzReady;
	 output reg Qua_lspReady;
	 output reg Int_lpcReady;
	 output reg Int_qlpcReady;
	 output reg Math1Ready;
	 output reg perc_varReady;
	 output reg Weight_AzReady;
	 output reg ResiduReady;
	 output reg Syn_filtReady;
	 output reg Pitch_olReady;
	 output reg Math2Ready;
	 output reg Math3Ready;
	output reg Pitch_fr3Ready;		//New submodules
	output reg Enc_lag3Ready;
	output reg Parity_PitchReady;
	output reg Pred_lt_3Ready;
	output reg ConvolveReady;
	output reg G_pitchReady;
	output reg Math4Ready;
	output reg test_errReady;
	output reg ACELP_CodebookReady;
	output reg Math5Ready;
	output reg Corr_xy2Ready;
	output reg Qua_gainReady;
	output reg Math6Ready;
	output reg update_exc_errReady;
	output reg Math7Ready;
	output reg CopyReady;
	output reg prm2bits_ld8kReady;	 //End new submodules
	 output reg done;
	 
	 parameter L_FRAME = 'd80;
	 
	 parameter INIT = 3'd0;
	 parameter S0 = 3'd1;
	 parameter S1 = 3'd2;
	 parameter SUB_MODULE_START = 7'd0;
	 parameter SUB_MODULE_AUTOCORR_READY = 7'd1;
	 parameter SUB_MODULE_AUTOCORR_DONE = 7'd2;
	 parameter SUB_MODULE_LAG_DONE = 7'd3;
	 parameter SUB_MODULE_LEVINSON_DONE = 7'd4;
	 parameter SUB_MODULE_AZ_DONE = 7'd5;
	 parameter SUB_MODULE_QUA_LSP_DONE = 7'd6;
	 parameter SUB_MODULE_INT_LPC_DONE = 7'd7;
 	 parameter SUB_MODULE_INT_QLPC_DONE = 7'd8;
	 parameter SUB_MODULE_MATH1_DONE = 7'd9;
	 parameter SUB_MODULE_PERC_VAR_DONE = 7'd10;
	 parameter SUB_MODULE_WEIGHT_AZ1_DONE = 7'd11;
	 parameter SUB_MODULE_WEIGHT_AZ_WAIT1 = 7'd12;
	 parameter SUB_MODULE_WEIGHT_AZ2_DONE = 7'd13;
	 parameter SUB_MODULE_RESIDU1_DONE = 7'd14;
	 parameter SUB_MODULE_SYN_FILT1_DONE = 7'd15;
	 parameter SUB_MODULE_WEIGHT_AZ3_DONE = 7'd16;
	 parameter SUB_MODULE_WEIGHT_AZ_WAIT2 = 7'd17;
	 parameter SUB_MODULE_WEIGHT_AZ4_DONE = 7'd18;
	 parameter SUB_MODULE_RESIDU2_DONE = 7'd19;
	 parameter SUB_MODULE_SYN_FILT2_DONE = 7'd20;
	 parameter SUB_MODULE_PITCH_OL_DONE = 7'd21;
	 parameter SUB_MODULE_MATH2_DONE = 7'd22;
	 parameter TL_FOR_LOOP = 7'd23;
	 parameter SUB_MODULE_WEIGHT_AZ5_DONE = 7'd24;
	 parameter SUB_MODULE_WEIGHT_AZ_WAIT3 = 7'd25;
	 parameter SUB_MODULE_WEIGHT_AZ6_DONE = 7'd26;
	 parameter SUB_MODULE_MATH3_DONE = 7'd27;
	 parameter SUB_MODULE_SYN_FILT3_DONE = 7'd28;
	 parameter SUB_MODULE_SYN_FILT_WAIT = 7'd29;
	 parameter SUB_MODULE_SYN_FILT4_DONE = 7'd30;
	 parameter SUB_MODULE_RESIDU3_DONE = 7'd31;
	 parameter SUB_MODULE_SYN_FILT5_DONE = 7'd32;
	 parameter SUB_MODULE_RESIDU4_DONE = 7'd33;
	 parameter SUB_MODULE_SYN_FILT6_DONE = 7'd34;
	 parameter SUB_MODULE_PITCH_FR3_DONE = 7'd35;
	 parameter SUB_MODULE_ENC_LAG3_DONE = 7'd36;
	 parameter LOAD_ANA_2_7 = 7'd37;
	 parameter CHECK_IF_PARITY_PITCH = 7'd38;
	 parameter SUB_MODULE_PARITY_PITCH_DONE = 7'd39;
	 parameter LOAD_ANA_3 = 7'd40;
	 parameter SUB_MODULE_PRED_LT_3_READY = 7'd41;
	 parameter SUB_MODULE_PRED_LT_3_DONE = 7'd42;
	 parameter SUB_MODULE_CONVOLVE_DONE = 7'd43;
	 parameter SUB_MODULE_G_PITCH_DONE = 7'd44;
	 parameter SUB_MODULE_TEST_ERR_DONE = 7'd45;
	 parameter SUB_MODULE_MATH4_DONE = 7'd46;
	 parameter SUB_MODULE_ACELP_CODEBOOK_DONE = 7'd47;
	 parameter LOAD_ANA_4_8 = 7'd48;
	 parameter LOAD_ANA_5_9 = 7'd49;
	 parameter SUB_MODULE_TL_MATH5_READY = 7'd50;
	 parameter SUB_MODULE_TL_MATH5_DONE = 7'd51;
	 parameter SUB_MODULE_CORR_XY2_DONE = 7'd52;
	 parameter SUB_MODULE_QUA_GAIN_DONE = 7'd53;
	 parameter SUB_MODULE_TL_MATH6_DONE = 7'd54;
	 parameter SUB_MODULE_UPDATE_EXC_ERR_DONE = 7'd55;
	 parameter SUB_MODULE_SYN_FILT7_DONE = 7'd56;
	 parameter SUB_MODULE_TL_MATH7_DONE = 7'd57;
	 parameter TL_FOR_LOOP_INC = 7'd58;
	 parameter SUB_MODULE_COPY1_DONE = 7'd59;
	 parameter SUB_MODULE_COPY_WAIT1_DONE = 7'd60;
	 parameter SUB_MODULE_COPY2_DONE = 7'd61;
	 parameter SUB_MODULE_COPY_WAIT2_DONE = 7'd62;
	 parameter SUB_MODULE_COPY3_DONE = 7'd63;
	 parameter SUB_MODULE_PRM2BITS_LD8K_DONE = 7'd64;
	 parameter TL_DONE = 7'd65;

	 //working regs
	 reg [2:0] frameDoneState, nextFrameDoneState;
	 reg [2:0] frameDoneCount,frameDoneCountLoad,frameDoneCountReset;	
	 reg [6:0] subModuleState,nextsubModuleState;
	 
	//autocorr ready state machine flop
		always @(posedge clock)
		begin
			if(reset)
				frameDoneState <= 0;
			else
				frameDoneState <= nextFrameDoneState;	
		end
	 
	//autocorr ready frame counter flop
		always @(posedge clock)
		begin
			if(reset)
				frameDoneCount <= 0;
			else if(frameDoneCountReset)
				frameDoneCount <= 0;
			else if(frameDoneCountLoad)
				frameDoneCount <= frameDoneCount + 1;
		end
		
		//submodule ready/done state machine flop
		always @(posedge clock)
		begin
			if(reset)
				subModuleState <= 0;
			else
				subModuleState <= nextsubModuleState;
			
		end
	
	 //Sub-Module state machine
	 always@(*)
	 begin
	    LDk = 0;
		LDi_subfr = 0;
		LDi_gamma = 0;
		LDT_op = 0;
		LDT0 = 0;
		LDT0_min = 0;
		LDT0_max = 0;
		LDT0_frac = 0;
		LDgain_pit = 0;
		LDgain_code = 0;
		LDindex = 0;
		LDtemp = 0;
	    LDL_temp = 0;
		LDA_Addr = 0;
		LDAq_Addr = 0;
		LDsharp = 0;
		LDi = 0;
		resetk = 0; 
		reseti_subfr = 0;
		reseti_gamma = 0;
		resetT_op = 0;
		resetT0 = 0;
		resetT0_min = 0;
		resetT0_max = 0; 
		resetT0_frac = 0;
		resetgain_pit = 0;
		resetgain_code = 0;
		resetindex = 0;
		resettemp = 0;
		resetL_temp = 0;
		resetA_Addr = 0;
		resetAq_Addr = 0;
		resetsharp = 0;
		reseti = 0;

		mathMuxSel = 0;
		done = 0;
		nextsubModuleState = subModuleState;
		lagReady = 0;
		levinsonReady = 0;
		AzReady = 0;
		Qua_lspReady = 0;
		Int_lpcReady = 0;
		Int_qlpcReady = 0;
		Math1Ready = 0;
		perc_varReady = 0;
		Weight_AzReady = 0;
		ResiduReady = 0;
		Syn_filtReady = 0;
		Pitch_olReady = 0;
		Math2Ready = 0;
		Math3Ready = 0;
		Pitch_fr3Ready = 0;		// New submodules
		Enc_lag3Ready = 0;
		Parity_PitchReady = 0;
		Pred_lt_3Ready = 0;
		ConvolveReady = 0;
		G_pitchReady = 0;
		Math4Ready = 0;
		test_errReady = 0;
		ACELP_CodebookReady = 0;
		Math5Ready = 0;
		Corr_xy2Ready = 0;
		Qua_gainReady = 0;
		Math6Ready = 0;
		update_exc_errReady = 0;
		Math7Ready = 0;
		CopyReady = 0;
		prm2bits_ld8kReady = 0;		//End new submodules
		
		if(divErr == 1)
			nextsubModuleState = SUB_MODULE_START;
			
		case(subModuleState)
		
			SUB_MODULE_START:
			begin
				if(start == 0)
				begin
					nextsubModuleState = SUB_MODULE_START;
					resetA_Addr = 1;
					resetAq_Addr = 1;
					reseti_gamma = 1;
					reseti_subfr = 1;
					resetgain_code = 1;
					resetgain_pit = 1;
					resetindex = 1;
					resetk = 1; 
					resetL_temp = 1;
					reseti = 1;
					resetT_op = 1;
					resetT0 = 1;
					resetT0_frac = 1;
					resetT0_max = 1; 
					resetT0_min = 1;
					resettemp = 1;
				end	
				else if(start == 1)
					nextsubModuleState = SUB_MODULE_AUTOCORR_READY;
			end	//SUB_MODULE_START
			
			SUB_MODULE_AUTOCORR_READY:
			begin
				if(autocorrReady == 0)
					nextsubModuleState = SUB_MODULE_AUTOCORR_READY;
				else if(autocorrReady == 1)
				begin
					nextsubModuleState = SUB_MODULE_AUTOCORR_DONE;
					mathMuxSel = 6'd0;
				end
			end//SUB_MODULE_AUTOCORR_READY
			
			SUB_MODULE_AUTOCORR_DONE:
			begin
				mathMuxSel = 6'd0;
				if(autocorrDone == 0)
					nextsubModuleState = SUB_MODULE_AUTOCORR_DONE;
				else if(autocorrDone == 1)
				begin	
					
					mathMuxSel = 6'd1;
					lagReady = 1;
					nextsubModuleState = SUB_MODULE_LAG_DONE; 
				end				
			end//SUB_MODULE_AUTOCORR_DONE
			
			SUB_MODULE_LAG_DONE:
			begin
				mathMuxSel = 6'd1;
				if(lagDone == 0)
					nextsubModuleState = SUB_MODULE_LAG_DONE;
				else if(lagDone == 1)
				begin				
					mathMuxSel = 6'd2;
					nextsubModuleState = SUB_MODULE_LEVINSON_DONE;
					levinsonReady = 1;
				end				
			end//SUB_MODULE_AUTOCORR_DONE
			
			SUB_MODULE_LEVINSON_DONE:
			begin
				mathMuxSel = 6'd2;
				if(levinsonDone == 0)
					nextsubModuleState = SUB_MODULE_LEVINSON_DONE;
				else if(levinsonDone == 1)
				begin					
					mathMuxSel = 6'd3;
					nextsubModuleState = SUB_MODULE_AZ_DONE;
					AzReady = 1;		
				end				
			end//SUB_MODULE_LEVINSON_DONE
			
			SUB_MODULE_AZ_DONE:
			begin
				mathMuxSel = 6'd3;
				if(AzDone == 0)
					nextsubModuleState = SUB_MODULE_AZ_DONE;
				else if(AzDone == 1)
				begin
					mathMuxSel = 6'd4;
					nextsubModuleState = SUB_MODULE_QUA_LSP_DONE;
					Qua_lspReady = 1;
				end				
			end//SUB_MODULE_AZ_DONE		
			
			SUB_MODULE_QUA_LSP_DONE:
			begin
				mathMuxSel = 6'd4;
				if(Qua_lspDone == 0)
					nextsubModuleState = SUB_MODULE_QUA_LSP_DONE;
				else if(Qua_lspDone == 1)
				begin
					mathMuxSel = 6'd5;
					nextsubModuleState = SUB_MODULE_INT_LPC_DONE;
					Int_lpcReady = 1;
				end				
			end//SUB_MODULE_QUA_LSP_DONE		
			
			SUB_MODULE_INT_LPC_DONE:
			begin
				mathMuxSel = 6'd5;
				if(Int_lpcDone == 0)
					nextsubModuleState = SUB_MODULE_INT_LPC_DONE;
				else if(Int_lpcDone == 1)
				begin
					mathMuxSel = 6'd6;
					nextsubModuleState = SUB_MODULE_INT_QLPC_DONE;
					Int_qlpcReady = 1;
				end				
			end//SUB_MODULE_INT_LPC_DONE		
			
			SUB_MODULE_INT_QLPC_DONE:
			begin
				mathMuxSel = 6'd6;
				if(Int_qlpcDone == 0)
					nextsubModuleState = SUB_MODULE_INT_QLPC_DONE;
				else if(Int_qlpcDone == 1)
				begin
					mathMuxSel = 6'd7;
					nextsubModuleState = SUB_MODULE_MATH1_DONE;
					Math1Ready = 1;
				end				
			end//SUB_MODULE_INT_QLPC_DONE		
			
			SUB_MODULE_MATH1_DONE:
			begin
				mathMuxSel = 6'd7;
				if(Math1Done == 0)
					nextsubModuleState = SUB_MODULE_MATH1_DONE;
				else if(Math1Done == 1)
				begin
					mathMuxSel = 6'd8;
					nextsubModuleState = SUB_MODULE_PERC_VAR_DONE;
					perc_varReady = 1;
				end				
			end//SUB_MODULE_MATH1_DONE		

			SUB_MODULE_PERC_VAR_DONE:
			begin
				mathMuxSel = 6'd8;
				if(perc_varDone == 0)
					nextsubModuleState = SUB_MODULE_PERC_VAR_DONE;
				else if(perc_varDone == 1)
				begin
					mathMuxSel = 6'd9;
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ1_DONE;
					Weight_AzReady = 1;
				end				
			end//SUB_MODULE_PERC_VAR_DONE		

			SUB_MODULE_WEIGHT_AZ1_DONE:
			begin
				mathMuxSel = 6'd9;
				if(Weight_AzDone == 0)
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ1_DONE;
				else if(Weight_AzDone == 1)
				begin
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ_WAIT1;
				end				
			end//SUB_MODULE_WEIGHT_AZ1_DONE		

			SUB_MODULE_WEIGHT_AZ_WAIT1:
			begin
					mathMuxSel = 6'd10;
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ2_DONE;
					Weight_AzReady = 1;
			end//SUB_MODULE_WEIGHT_AZ_WAIT1	

			SUB_MODULE_WEIGHT_AZ2_DONE:
			begin
				mathMuxSel = 6'd10;
				if(Weight_AzDone == 0)
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ2_DONE;
				else if(Weight_AzDone == 1)
				begin
					mathMuxSel = 6'd11;
					nextsubModuleState = SUB_MODULE_RESIDU1_DONE;
					ResiduReady = 1;
				end				
			end//SUB_MODULE_WEIGHT_AZ2_DONE		

			SUB_MODULE_RESIDU1_DONE:
			begin
				mathMuxSel = 6'd11;
				if(ResiduDone == 0)
					nextsubModuleState = SUB_MODULE_RESIDU1_DONE;
				else if(ResiduDone == 1)
				begin
					mathMuxSel = 6'd12;
					nextsubModuleState = SUB_MODULE_SYN_FILT1_DONE;
					Syn_filtReady = 1;
				end				
			end//SUB_MODULE_RESIDU1_DONE		
		
			SUB_MODULE_SYN_FILT1_DONE:
			begin
				mathMuxSel = 6'd12;
				if(Syn_filtDone == 0)
					nextsubModuleState = SUB_MODULE_SYN_FILT1_DONE;
				else if(Syn_filtDone == 1)
				begin
					mathMuxSel = 6'd13;
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ3_DONE;
					Weight_AzReady = 1;
				end				
			end//SUB_MODULE_SYN_FILT1_DONE		

			SUB_MODULE_WEIGHT_AZ3_DONE:
			begin
				mathMuxSel = 6'd13;
				if(Weight_AzDone == 0)
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ3_DONE;
				else if(Weight_AzDone == 1)
				begin
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ_WAIT2;
				end				
			end//SUB_MODULE_WEIGHT_AZ3_DONE		

			SUB_MODULE_WEIGHT_AZ_WAIT2:
			begin
					mathMuxSel = 6'd14;
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ4_DONE;
					Weight_AzReady = 1;
			end//SUB_MODULE_WEIGHT_AZ_WAIT2		

			SUB_MODULE_WEIGHT_AZ4_DONE:
			begin
				mathMuxSel = 6'd14;
				if(Weight_AzDone == 0)
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ4_DONE;
				else if(Weight_AzDone == 1)
				begin
					mathMuxSel = 6'd15;
					nextsubModuleState = SUB_MODULE_RESIDU2_DONE;
					ResiduReady = 1;
				end				
			end//SUB_MODULE_WEIGHT_AZ4_DONE		

			SUB_MODULE_RESIDU2_DONE:
			begin
				mathMuxSel = 6'd15;
				if(ResiduDone == 0)
					nextsubModuleState = SUB_MODULE_RESIDU2_DONE;
				else if(ResiduDone == 1)
				begin
					mathMuxSel = 6'd16;
					nextsubModuleState = SUB_MODULE_SYN_FILT2_DONE;
					Syn_filtReady = 1;
				end				
			end//SUB_MODULE_RESIDU2_DONE		

			SUB_MODULE_SYN_FILT2_DONE:
			begin
				mathMuxSel = 6'd16;
				if(Syn_filtDone == 0)
					nextsubModuleState = SUB_MODULE_SYN_FILT2_DONE;
				else if(Syn_filtDone == 1)
				begin
					mathMuxSel = 6'd17;
					nextsubModuleState = SUB_MODULE_PITCH_OL_DONE;
					Pitch_olReady = 1;
				end				
			end//SUB_MODULE_SYN_FILT2_DONE		
	
			SUB_MODULE_PITCH_OL_DONE:
			begin
				mathMuxSel = 6'd17;
				if(Pitch_olDone == 0)
					nextsubModuleState = SUB_MODULE_PITCH_OL_DONE;
				else if(Pitch_olDone == 1)
				begin
					LDT_op = 1;
					mathMuxSel = 6'd18;
					nextsubModuleState = SUB_MODULE_MATH2_DONE;
					Math2Ready = 1;
				end				
			end//SUB_MODULE_PITCH_OL_DONE	
			
			SUB_MODULE_MATH2_DONE:
			begin
				mathMuxSel = 6'd18;
				if(Math2Done == 0)
					nextsubModuleState = SUB_MODULE_MATH2_DONE;
				else if(Math2Done == 1)
				begin
					LDT0_min = 1;
					LDT0_max = 1;
					LDA_Addr = 1;
					LDAq_Addr = 1;
					reseti_gamma = 1;
					mathMuxSel = 6'd19;
					nextsubModuleState = TL_FOR_LOOP;
				end				
			end//SUB_MODULE_MATH2_DONE		

			TL_FOR_LOOP:
			begin
				if(i_subfr < L_FRAME)
				begin
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ5_DONE;
					mathMuxSel = 6'd19;
					Weight_AzReady = 1;
				end
				else
				begin
					reseti_subfr = 1;
					reseti_gamma = 1;
					mathMuxSel = 6'd48;
					nextsubModuleState = SUB_MODULE_COPY1_DONE;
					CopyReady = 1;
				end
			end//TL_FOR_LOOP		
			
			SUB_MODULE_WEIGHT_AZ5_DONE:
			begin
				mathMuxSel = 6'd19;
				if(Weight_AzDone == 0)
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ5_DONE;
				else if(Weight_AzDone == 1)
				begin
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ_WAIT3;
				end				
			end//SUB_MODULE_WEIGHT_AZ5_DONE		

			SUB_MODULE_WEIGHT_AZ_WAIT3:
			begin
					mathMuxSel = 6'd20;
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ6_DONE;
					Weight_AzReady = 1;
			end//SUB_MODULE_WEIGHT_AZ_WAIT3		

			SUB_MODULE_WEIGHT_AZ6_DONE:
			begin
				mathMuxSel = 6'd20;
				if(Weight_AzDone == 0)
					nextsubModuleState = SUB_MODULE_WEIGHT_AZ6_DONE;
				else if(Weight_AzDone == 1)
				begin
					mathMuxSel = 6'd21;
					nextsubModuleState = SUB_MODULE_MATH3_DONE;
					Math3Ready = 1;
				end				
			end//SUB_MODULE_WEIGHT_AZ6_DONE		

			SUB_MODULE_MATH3_DONE:
			begin
				mathMuxSel = 6'd21;
				if(Math3Done == 0)
					nextsubModuleState = SUB_MODULE_MATH3_DONE;
				else if(Math3Done == 1)
				begin
					LDi_gamma = 1;
					mathMuxSel = 6'd22;
					nextsubModuleState = SUB_MODULE_SYN_FILT3_DONE;
					Syn_filtReady = 1;
				end				
			end//SUB_MODULE_MATH3_DONE		

			SUB_MODULE_SYN_FILT3_DONE:
			begin
				mathMuxSel = 6'd22;
				if(Syn_filtDone == 0)
					nextsubModuleState = SUB_MODULE_SYN_FILT3_DONE;
				else if(Syn_filtDone == 1)
				begin
					nextsubModuleState = SUB_MODULE_SYN_FILT_WAIT;
				end				
			end//SUB_MODULE_SYN_FILT3_DONE		
			
			SUB_MODULE_SYN_FILT_WAIT:
			begin
					mathMuxSel = 6'd23;
					nextsubModuleState = SUB_MODULE_SYN_FILT4_DONE;
					Syn_filtReady = 1;
			end//SUB_MODULE_SYN_FILT_WAIT		

			SUB_MODULE_SYN_FILT4_DONE:
			begin
				mathMuxSel = 6'd23;
				if(Syn_filtDone == 0)
					nextsubModuleState = SUB_MODULE_SYN_FILT4_DONE;
				else if(Syn_filtDone == 1)
				begin
					mathMuxSel = 6'd24;
					nextsubModuleState = SUB_MODULE_RESIDU3_DONE;
					ResiduReady = 1;
				end				
			end//SUB_MODULE_SYN_FILT4_DONE		

			SUB_MODULE_RESIDU3_DONE:
			begin
				mathMuxSel = 6'd24;
				if(ResiduDone == 0)
					nextsubModuleState = SUB_MODULE_RESIDU3_DONE;
				else if(ResiduDone == 1)
				begin
					mathMuxSel = 6'd25;
					nextsubModuleState = SUB_MODULE_SYN_FILT5_DONE;
					Syn_filtReady = 1;
				end				
			end//SUB_MODULE_RESIDU3_DONE		

			SUB_MODULE_SYN_FILT5_DONE:
			begin
				mathMuxSel = 6'd25;
				if(Syn_filtDone == 0)
					nextsubModuleState = SUB_MODULE_SYN_FILT5_DONE;
				else if(Syn_filtDone == 1)
				begin
					mathMuxSel = 6'd26;
					nextsubModuleState = SUB_MODULE_RESIDU4_DONE;
					ResiduReady = 1;
				end				
			end//SUB_MODULE_SYN_FILT5_DONE		

			SUB_MODULE_RESIDU4_DONE:
			begin
				mathMuxSel = 6'd26;
				if(ResiduDone == 0)
					nextsubModuleState = SUB_MODULE_RESIDU4_DONE;
				else if(ResiduDone == 1)
				begin
					mathMuxSel = 6'd27;
					nextsubModuleState = SUB_MODULE_SYN_FILT6_DONE;
					Syn_filtReady = 1;
				end				
			end//SUB_MODULE_RESIDU4_DONE		

			SUB_MODULE_SYN_FILT6_DONE:
			begin
				mathMuxSel = 6'd27;
				if(Syn_filtDone == 0)
					nextsubModuleState = SUB_MODULE_SYN_FILT6_DONE;
				else if(Syn_filtDone == 1)
				begin
					mathMuxSel = 6'd28;
					nextsubModuleState = SUB_MODULE_PITCH_FR3_DONE;
					Pitch_fr3Ready = 1;
				end				
			end//SUB_MODULE_SYN_FILT6_DONE		

			SUB_MODULE_PITCH_FR3_DONE:
			begin
				mathMuxSel = 6'd28;
				if(Pitch_fr3Done == 0)
					nextsubModuleState = SUB_MODULE_PITCH_FR3_DONE;
				else if(Pitch_fr3Done == 1)
				begin
					LDT0 = 1; 
					LDT0_frac = 1;
					mathMuxSel = 6'd29;
					nextsubModuleState = SUB_MODULE_ENC_LAG3_DONE;
					Enc_lag3Ready = 1;
				end				
			end//SUB_MODULE_PITCH_FR3_DONE		

			SUB_MODULE_ENC_LAG3_DONE:
			begin
				mathMuxSel = 6'd29;
				if(Enc_lag3Done == 0)
					nextsubModuleState = SUB_MODULE_ENC_LAG3_DONE;
				else if(Enc_lag3Done == 1)
				begin
					LDindex = 1; 
					LDT0_min = 1; 
					LDT0_max = 1;
					mathMuxSel = 6'd30;
					nextsubModuleState = LOAD_ANA_2_7;
				end				
			end//SUB_MODULE_ENC_LAG3_DONE		

			LOAD_ANA_2_7:
			begin
				mathMuxSel = 6'd30;
				nextsubModuleState = CHECK_IF_PARITY_PITCH;
			end//LOAD_ANA_2_7

			CHECK_IF_PARITY_PITCH:
			begin
				if (i_subfr == 'd0)
				begin
					mathMuxSel = 6'd31;
					nextsubModuleState = SUB_MODULE_PARITY_PITCH_DONE;
					Parity_PitchReady = 1;
				end
				else if (i_subfr == 'd40)
				begin
					mathMuxSel = 6'd33;
					nextsubModuleState = SUB_MODULE_PRED_LT_3_READY;
				end
			end//CHECK_IF_PARITY_PITCH

			SUB_MODULE_PARITY_PITCH_DONE:
			begin
				mathMuxSel = 6'd31;
				if(Parity_PitchDone == 0)
					nextsubModuleState = SUB_MODULE_PARITY_PITCH_DONE;
				else if(Parity_PitchDone == 1)
					nextsubModuleState = LOAD_ANA_3;
			end//SUB_MODULE_PARITY_PITCH_DONE
//32
			LOAD_ANA_3:
			begin
				mathMuxSel = 6'd32;
				nextsubModuleState = SUB_MODULE_PRED_LT_3_READY;
			end//LOAD_ANA_2_7
//33		
			SUB_MODULE_PRED_LT_3_READY:
			begin
				mathMuxSel = 6'd33;
				nextsubModuleState = SUB_MODULE_PRED_LT_3_DONE;
				Pred_lt_3Ready = 1;
			end//LOAD_ANA_2_7

			SUB_MODULE_PRED_LT_3_DONE:
			begin
				mathMuxSel = 6'd33;
				if(Pred_lt_3Done == 0)
					nextsubModuleState = SUB_MODULE_PRED_LT_3_DONE;
				else if(Pred_lt_3Done == 1)
				begin
					mathMuxSel = 6'd34;
					nextsubModuleState = SUB_MODULE_CONVOLVE_DONE;
					ConvolveReady = 1;
				end				
			end//SUB_MODULE_PRED_LT_3_DONE
//34
			SUB_MODULE_CONVOLVE_DONE:
			begin
				mathMuxSel = 6'd34;
				if(ConvolveDone == 0)
					nextsubModuleState = SUB_MODULE_CONVOLVE_DONE;
				else if(ConvolveDone == 1)
				begin
					mathMuxSel = 6'd35;
					nextsubModuleState = SUB_MODULE_G_PITCH_DONE;
					G_pitchReady = 1;
				end				
			end//SUB_MODULE_CONVOLVE_DONE
//35
			SUB_MODULE_G_PITCH_DONE:
			begin
				mathMuxSel = 6'd35;
				if(G_pitchDone == 0)
					nextsubModuleState = SUB_MODULE_G_PITCH_DONE;
				else if(G_pitchDone == 1)
				begin
					LDgain_pit = 1;
					mathMuxSel = 6'd36;
					nextsubModuleState = SUB_MODULE_TEST_ERR_DONE;
					test_errReady = 1;
				end				
			end//SUB_MODULE_G_PITCH_DONE
//36	
			SUB_MODULE_TEST_ERR_DONE:
			begin
				mathMuxSel = 6'd36;
				if(test_errDone == 0)
					nextsubModuleState = SUB_MODULE_TEST_ERR_DONE;
				else if(test_errDone == 1)
				begin
					LDtemp = 1;
					mathMuxSel = 6'd37;
					nextsubModuleState = SUB_MODULE_MATH4_DONE;
					Math4Ready = 1;
				end				
			end//SUB_MODULE_TEST_ERR_DONE
//37	
			SUB_MODULE_MATH4_DONE:
			begin
				mathMuxSel = 6'd37;
				if(Math4Done == 0)
					nextsubModuleState = SUB_MODULE_MATH4_DONE;
				else if(Math4Done == 1)
				begin
					LDgain_pit = 1;
					LDL_temp = 1;
					mathMuxSel = 6'd38;
					nextsubModuleState = SUB_MODULE_ACELP_CODEBOOK_DONE;
					ACELP_CodebookReady = 1;
				end				
			end//SUB_MODULE_MATH4_DONE
//38	
			SUB_MODULE_ACELP_CODEBOOK_DONE:
			begin
				mathMuxSel = 6'd38;
				if(ACELP_CodebookDone == 0)
					nextsubModuleState = SUB_MODULE_ACELP_CODEBOOK_DONE;
				else if(ACELP_CodebookDone == 1)
				begin
					LDindex = 1;
					LDi = 1;
					mathMuxSel = 6'd39;
					nextsubModuleState = LOAD_ANA_4_8;
				end				
			end//SUB_MODULE_ACELP_CODEBOOK_DONE
//39
			LOAD_ANA_4_8:
			begin
				mathMuxSel = 6'd39;
				nextsubModuleState = LOAD_ANA_5_9;
			end//LOAD_ANA_4_8
//40
			LOAD_ANA_5_9:
			begin
				mathMuxSel = 6'd40;
				nextsubModuleState = SUB_MODULE_TL_MATH5_READY;
			end//LOAD_ANA_5_9

			SUB_MODULE_TL_MATH5_READY:
			begin
				mathMuxSel = 6'd41;
				nextsubModuleState = SUB_MODULE_TL_MATH5_DONE;
				Math5Ready = 1;
			end//SUB_MODULE_TL_MATH5_READY
			
			SUB_MODULE_TL_MATH5_DONE:
			begin
				mathMuxSel = 6'd41;
				if(Math5Done == 0)
					nextsubModuleState = SUB_MODULE_TL_MATH5_DONE;
				else if(Math5Done == 1)
				begin
					mathMuxSel = 6'd42;
					nextsubModuleState = SUB_MODULE_CORR_XY2_DONE;
					Corr_xy2Ready = 1;
				end				
			end//SUB_MODULE_TL_MATH5_DONE

			SUB_MODULE_CORR_XY2_DONE:
			begin
				mathMuxSel = 6'd42;
				if(Corr_xy2Done == 0)
					nextsubModuleState = SUB_MODULE_CORR_XY2_DONE;
				else if(Corr_xy2Done == 1)
				begin
					mathMuxSel = 6'd43;
					nextsubModuleState = SUB_MODULE_QUA_GAIN_DONE;
					Qua_gainReady = 1;
				end				
			end//SUB_MODULE_CORR_XY2_DONE

			SUB_MODULE_QUA_GAIN_DONE:
			begin
				mathMuxSel = 6'd43;
				if(Qua_gainDone == 0)
					nextsubModuleState = SUB_MODULE_QUA_GAIN_DONE;
				else if(Qua_gainDone == 1)
				begin
					LDgain_pit = 1;
					LDgain_code = 1;
					mathMuxSel = 6'd44;
					nextsubModuleState = SUB_MODULE_TL_MATH6_DONE;
					Math6Ready = 1;
				end				
			end//SUB_MODULE_QUA_GAIN_DONE

			SUB_MODULE_TL_MATH6_DONE:
			begin
				mathMuxSel = 6'd44;
				if(Math6Done == 0)
					nextsubModuleState = SUB_MODULE_TL_MATH6_DONE;
				else if(Math6Done == 1)
				begin
					LDsharp = 1;
					LDL_temp = 1;
					mathMuxSel = 6'd45;
					nextsubModuleState = SUB_MODULE_UPDATE_EXC_ERR_DONE;
					update_exc_errReady = 1;
				end				
			end//SUB_MODULE_TL_MATH6_DONE

			SUB_MODULE_UPDATE_EXC_ERR_DONE:
			begin
				mathMuxSel = 6'd45;
				if(update_exc_errDone == 0)
					nextsubModuleState = SUB_MODULE_UPDATE_EXC_ERR_DONE;
				else if(update_exc_errDone == 1)
				begin
					mathMuxSel = 6'd46;
					nextsubModuleState = SUB_MODULE_SYN_FILT7_DONE;
					Syn_filtReady = 1;
				end				
			end//SUB_MODULE_UPDATE_EXC_ERR_DONE
			
			SUB_MODULE_SYN_FILT7_DONE:
			begin
				mathMuxSel = 6'd46;
				if(Syn_filtDone == 0)
					nextsubModuleState = SUB_MODULE_SYN_FILT7_DONE;
				else if(Syn_filtDone == 1)
				begin
					mathMuxSel = 6'd47;
					nextsubModuleState = SUB_MODULE_TL_MATH7_DONE;
					Math7Ready = 1;
				end				
			end//SUB_MODULE_SYN_FILT7_DONE

			SUB_MODULE_TL_MATH7_DONE:
			begin
				mathMuxSel = 6'd47;
				if(Math7Done == 0)
					nextsubModuleState = SUB_MODULE_TL_MATH7_DONE;
				else if(Math7Done == 1)
				begin
					LDi_subfr = 1;
					nextsubModuleState = TL_FOR_LOOP_INC;
				end				
			end//SUB_MODULE_TL_MATH7_DONE

			TL_FOR_LOOP_INC:
			begin
				LDA_Addr = 1;
				LDAq_Addr = 1;
				nextsubModuleState = TL_FOR_LOOP;
			end//TL_FOR_LOOP_INC		
			
			SUB_MODULE_COPY1_DONE:
			begin
				mathMuxSel = 6'd48;
				if(CopyDone == 0)
					nextsubModuleState = SUB_MODULE_COPY1_DONE;
				else if(CopyDone == 1)
					nextsubModuleState = SUB_MODULE_COPY_WAIT1_DONE;
			end//SUB_MODULE_COPY1_DONE		
			
			SUB_MODULE_COPY_WAIT1_DONE:
			begin
				mathMuxSel = 6'd49;
				nextsubModuleState = SUB_MODULE_COPY2_DONE;
				CopyReady = 1;
			end//SUB_MODULE_COPY_WAIT1_DONE		

			SUB_MODULE_COPY2_DONE:
			begin
				mathMuxSel = 6'd49;
				if(CopyDone == 0)
					nextsubModuleState = SUB_MODULE_COPY2_DONE;
				else if(CopyDone == 1)
					nextsubModuleState = SUB_MODULE_COPY_WAIT2_DONE;
			end//SUB_MODULE_COPY2_DONE		

			SUB_MODULE_COPY_WAIT2_DONE:
			begin
				mathMuxSel = 6'd50;
				nextsubModuleState = SUB_MODULE_COPY3_DONE;
				CopyReady = 1;
			end//SUB_MODULE_COPY_WAIT2_DONE		

			SUB_MODULE_COPY3_DONE:
			begin
				mathMuxSel = 6'd50;
				if(CopyDone == 0)
					nextsubModuleState = SUB_MODULE_COPY3_DONE;
				else if(CopyDone == 1)
				begin
					mathMuxSel = 6'd51;
					nextsubModuleState = SUB_MODULE_PRM2BITS_LD8K_DONE;
					prm2bits_ld8kReady = 1;
				end
			end//SUB_MODULE_COPY3_DONE		

			SUB_MODULE_PRM2BITS_LD8K_DONE:
			begin
				mathMuxSel = 6'd51;
				if(prm2bits_ld8kDone == 0)
					nextsubModuleState = SUB_MODULE_PRM2BITS_LD8K_DONE;
				else if(prm2bits_ld8kDone == 1)
					nextsubModuleState = TL_DONE;
			end//SUB_MODULE_PRM2BITS_LD8K_DONE		

			TL_DONE:
			begin
				done = 1;
				nextsubModuleState = SUB_MODULE_START;
			end//TL_DONE		

		endcase
	end//Sub-Module state machine
	 
	 //Autocorr Ready state machine
	 always @(*)
	 begin	//always
	 
		nextFrameDoneState = frameDoneState;
		frameDoneCountReset = 0;
		frameDoneCountLoad = 0;
		autocorrReady = 0;
		
		case(frameDoneState)
		
		INIT: 
		begin	//INIT
			if(start == 0)
				nextFrameDoneState = INIT;
			else if(start == 1)
			begin
				nextFrameDoneState = S0;
			end//else if(start == 1)
		end	//INIT
		
		S0:
		begin
			if(frame_done)
					frameDoneCountLoad = 1;
					
				if(frameDoneCount == 2'd2)
				begin	//count
						frameDoneCountReset = 1;
						autocorrReady = 1;
						nextFrameDoneState = S1;
				end	//count
				
				else
					nextFrameDoneState = S0;
		end
		
		S1: 
		begin //S1
		
			if(frame_done)
					frameDoneCountLoad = 1;
					
			if(frameDoneCount == 2'd2)
			begin	//count
					frameDoneCountReset = 1;
					autocorrReady = 1;
					nextFrameDoneState = S1;
			end//count
			
			else
				nextFrameDoneState = S1;
		
		end	//S1
		endcase
	end	//always


endmodule
