`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University 
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    14:12:54 10/14/2010 
// Module Name:    G729_Pipe 
// Project Name: 	 ITU G.729 Hardware Implementation
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5
// Tool versions:  Xilinx 9.2i
// Description: 	 Top Level Datapath for G.729 Encoder. Instatiated all the math modules, sub-modules FSMS,
//						 Memories, and muxes needed to select which sub-module controls each resource
//
// Dependencies: 	 L_mult.v, mux128_16.v, mult.v, L_mac.v, mux128_32.v, L_msu.v, L_add.v, L_sub.v, norm_l.v, mux128_1.v
//						 norm_s.v, L_shl.v, L_shr.v, L_abs.v, L_negate.v, add.v, sub.v, shr.v, shl.v, Scratch_Memory_Controller.v,
//						 mux128_11.v, g729_hpfilter.v, LPC_Mem_Ctrl.v, autocorrFSM.v, lag_window.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module G729_Pipe (clock,reset,xn,preProcReady,autocorrReady,lagReady,levinsonReady,AzReady,Qua_lspReady,
						Int_lpcReady,Int_qlpcReady,Math1Ready,perc_varReady,Weight_AzReady,ResiduReady,Syn_filtReady,Pitch_olReady,Math2Ready,Math3Ready,Pitch_fr3Ready,Enc_lag3Ready,Parity_PitchReady,
						Pred_lt_3Ready,ConvolveReady,G_pitchReady,Math4Ready,test_errReady,ACELP_CodebookReady,Math5Ready,Corr_xy2Ready,Qua_gainReady,Math6Ready,update_exc_errReady,Math7Ready,CopyReady,prm2bits_ld8kReady,
						LDk,LDi_subfr,LDi_gamma,LDT_op,LDT0,LDT0_min,LDT0_max,LDT0_frac,LDgain_pit,LDgain_code,LDindex,LDtemp,LDA_Addr,LDAq_Addr,LDsharp,LDi,resetk,reseti_subfr,reseti_gamma,resetT_op,
						resetT0,resetT0_min,resetT0_max,resetT0_frac,resetgain_pit,resetgain_code,resetindex,resettemp,resetA_Addr,resetAq_Addr,resetsharp,reseti,LDL_temp,resetL_temp,mathMuxSel,frame_done,autocorrDone,lagDone,
						levinsonDone,AzDone,Qua_lspDone,Int_lpcDone,Int_qlpcDone,Math1Done,perc_varDone,Weight_AzDone,ResiduDone,Syn_filtDone,Pitch_olDone,Math2Done,Math3Done,Pitch_fr3Done,Enc_lag3Done,Parity_PitchDone,
						Pred_lt_3Done,ConvolveDone,G_pitchDone,Math4Done,test_errDone,ACELP_CodebookDone,Math5Done,Corr_xy2Done,Qua_gainDone,Math6Done,update_exc_errDone,Math7Done,CopyDone,prm2bits_ld8kDone,		
						i_subfr,divErr,outBufAddr,out);

`include "paramList.v"
   
	//inputs
	input clock;
   input reset;
	input [15:0] xn; 
	input preProcReady; 
	input autocorrReady;
	input lagReady;
	input levinsonReady;
	input AzReady;
	input Qua_lspReady;
	input Int_lpcReady;
	input Int_qlpcReady;
	input Math1Ready;
	input perc_varReady;
	input Weight_AzReady;
	input ResiduReady;
	input Syn_filtReady;
	input Pitch_olReady;
	input Math2Ready;
	input Math3Ready;
	input Pitch_fr3Ready;		//New submodules
	input Enc_lag3Ready;
	input Parity_PitchReady;
	input Pred_lt_3Ready;
	input ConvolveReady;
	input G_pitchReady;
	input Math4Ready;
	input test_errReady;
	input ACELP_CodebookReady;
	input Math5Ready;
	input Corr_xy2Ready;
	input Qua_gainReady;
	input Math6Ready;
	input update_exc_errReady;
	input Math7Ready;
	input CopyReady;
	input prm2bits_ld8kReady;	 //End new submodules
	input [5:0] mathMuxSel;
	input [11:0] outBufAddr;
	input LDk, LDi_subfr, LDi_gamma, LDT_op, LDT0, LDT0_min, LDT0_max, LDT0_frac, LDgain_pit, LDgain_code, LDindex, LDtemp, LDA_Addr, LDAq_Addr, LDsharp, LDi;
	input resetk, reseti_subfr, reseti_gamma, resetT_op, resetT0, resetT0_min, resetT0_max, resetT0_frac, resetgain_pit, resetgain_code, resetindex, resettemp, resetA_Addr, resetAq_Addr, resetsharp, reseti;
   input LDL_temp;
   input resetL_temp;
	
	//outputs
	output frame_done;
	output autocorrDone;
   output lagDone;
	output levinsonDone;
	output AzDone;	
	output Qua_lspDone;
	output Int_lpcDone;
	output Int_qlpcDone;
	output Math1Done;
	output perc_varDone;
	output Weight_AzDone;
	output ResiduDone;
	output Syn_filtDone;
	output Pitch_olDone;
	output Math2Done;
	output Math3Done;
	output Pitch_fr3Done;	//New submodules
	output Enc_lag3Done;
	output Parity_PitchDone;
	output Pred_lt_3Done;
	output ConvolveDone;
	output G_pitchDone;
	output Math4Done;
	output test_errDone;
	output ACELP_CodebookDone;
	output Math5Done;
	output Corr_xy2Done;
	output Qua_gainDone;
	output Math6Done;
	output update_exc_errDone;
	output Math7Done;
	output CopyDone;
	output prm2bits_ld8kDone;	
	output i_subfr;
	output reg divErr;
	output [31:0] out;	

	parameter OLD_SPEECH = 'd0;
	parameter PRM_SIZE = 'd11;
	parameter L_TOTAL = 'd240;
	parameter L_FRAME = 'd80;
	parameter L_NEXT = 'd40;
	parameter L_SUBFR = 'd40;
	parameter L_WINDOW = 'd240;
	parameter PIT_MIN = 'd20;
	parameter PIT_MAX = 'd143;
	parameter L_INTERPOL = 'd11;
	parameter M = 'd10;
	parameter MP1 = M + 'd1;
	parameter GPCLIP = 'd15564;
	parameter SHARPMIN = 'd3277;
	parameter SHARPMAX = 'd13017;

	parameter NEW_SPEECH = OLD_SPEECH + L_TOTAL - L_FRAME;
	parameter SPEECH = OLD_SPEECH + L_TOTAL - L_FRAME - L_NEXT;
	parameter P_WINDOW = OLD_SPEECH + L_TOTAL - L_WINDOW;
	parameter WSP = OLD_WSP + PIT_MAX;
	parameter EXC = OLD_EXC + PIT_MAX + L_INTERPOL;
	parameter ZERO = AI_ZERO + MP1;
	parameter ERROR = MEM_ERR + M;

	//done signals
	wire norm_l_done,norm_s_done,L_shl_done;
	
	//overflow signals
	wire L_mult_overflow,mult_overflow,L_mac_overflow,L_msu_overflow,L_add_overflow,L_sub_overflow,
				L_shl_overflow,L_shr_overflow,add_overflow,sub_overflow,shr_overflow,shl_overflow;
				
	//output signals
	wire [15:0] mult_out,norm_l_out,norm_s_out,add_out,sub_out,shr_out,shl_out;
	wire [31:0] L_mult_out,L_mac_out,L_msu_out,L_add_out,L_sub_out,L_shl_out,L_shr_out,L_abs_out,
						L_negate_out;
						
	//FFs regs/wires
	reg [15:0] k, i_subfr, i_gamma, T_op, T0, T0_min, T0_max, T0_frac, gain_pit, gain_code, index, temp, A_Addr, Aq_Addr, sharp, i;
	wire [15:0] nextk, nexti_subfr, nexti_gamma, nextT_op, nextT0, nextT0_min, nextT0_max, nextT0_frac, nextgain_pit, nextgain_code, nextindex, nexttemp, nextA_Addr, nextAq_Addr, nextsharp, nexti;
   reg [31:0] L_temp;
	wire [31:0] nextL_temp;
				
	//Scratch Memory signals
	wire [31:0] memOut;
	
	//Constant Memory wires
	wire [31:0] constantMemOut;
		
	//pre-proc mem wires
	wire [11:0] preProcMemReadAddr;
	
	//Pre-Processor signals		
	wire [15:0] yn; 
	wire preProcDone;
	
	//Autocorrelation signals	
	wire [11:0] autocorrRequested; 
	wire [31:0] autocorrScratchMemOut;	
    wire [11:0] autocorrScratchReadRequested;
	wire [11:0] autocorrScratchWriteRequested;
	wire autocorrScratchWriteEn;
	wire [31:0] speechIn;
	wire [15:0] autocorr_multOutA;
	wire [15:0] autocorr_multOutB;
	wire multRselOut;
	wire [15:0] autocorr_L_macOutA;
	wire [15:0] autocorr_L_macOutB;
	wire [31:0] autocorr_L_macOutC;
	wire [15:0] autocorr_L_msuOutA;
	wire [15:0] autocorr_L_msuOutB;
	wire [31:0] autocorr_L_msuOutC;
	wire [31:0] autocorr_norm_lVar1Out;
	wire autocorr_norm_lReady;
	wire autocorr_norm_lReset;	
	wire autocorr_L_shlReady;
	wire [31:0] autocorr_L_shlVar1Out;
	wire [15:0] autocorr_L_shlNumShiftOut;
	wire [31:0]	autocorr_L_shrVar1Out;
	wire [15:0] autocorr_L_shrNumShiftOut;
	wire [15:0] autocorr_shrVar1Out;
	wire [15:0] autocorr_shrVar2Out;
	wire [15:0] autocorr_addOutA;
	wire [15:0] autocorr_addOutB;
	wire [15:0] autocorr_subOutA;
	wire [15:0] autocorr_subOutB;
	wire autocorr_zero;
	wire [15:0] autocorr_zero16;
	wire [31:0] autocorr_zero32;
	assign autocorr_zero = 1'd0;
	assign autocorr_zero16 = 16'd0;
	assign autocorr_zero32 = 32'd0;
	
	//Lag Window wires
	wire lag_scratchWriteEn;
	wire [11:0] lag_scratchReadRequested;
	wire [11:0] lag_scratchWriteRequested;
	wire [31:0] lag_scratchMemOut; 
	wire [15:0] lag_L_multOutA; 
	wire [15:0] lag_L_multOutB;	
	wire [15:0] lag_multOutA; 
	wire [15:0] lag_multOutB;	
	wire [15:0] lag_L_macOutA; 
	wire [15:0] lag_L_macOutB;
	wire [31:0] lag_L_macOutC;	
	wire [15:0] lag_L_msuOutA; 
	wire [15:0] lag_L_msuOutB; 
	wire [31:0] lag_L_msuOutC; 	
	wire [15:0] lag_addOutA;
	wire [15:0] lag_addOutB;	
	wire [31:0] lag_L_shrOutVar1;
	wire [15:0] lag_L_shrOutNumShift;	
	wire lag_zero;
	wire [15:0] lag_zero16;
	wire [31:0] lag_zero32;
	assign lag_zero = 1'd0;
	assign lag_zero16 = 16'd0;
	assign lag_zero32 = 32'd0;
	
	//Levinson Durbin wires
	wire [31:0] levinson_abs_out; 	
	wire [31:0] levinson_negate_out;	
	wire [31:0] levinson_L_shr_outa; 
	wire [15:0] levinson_L_shr_outb; 	
	wire [31:0] levinson_L_sub_outa; 
	wire [31:0] levinson_L_sub_outb; 	
	wire [31:0] levinson_norm_L_out;											
	wire levinson_norm_L_start;	
	wire [31:0] levinson_L_shl_outa; 
	wire [15:0] levinson_L_shl_outb;											
	wire levinson_L_shl_start;		
	wire [15:0] levinson_L_mult_outa; 
	wire [15:0] levinson_L_mult_outb;	
	wire [15:0] levinson_L_mac_outa; 
	wire [15:0] levinson_L_mac_outb; 
	wire [31:0] levinson_L_mac_outc;	
	wire [15:0] levinson_mult_outa; 
	wire [15:0] levinson_mult_outb;	
	wire [31:0] levinson_L_add_outa;
	wire [31:0] levinson_L_add_outb;	
	wire [15:0] levinson_sub_outa;
	wire [15:0] levinson_sub_outb;	
	wire [15:0] levinson_add_outa;
	wire [15:0] levinson_add_outb;	
	wire [11:0] levinson_scratch_mem_read_addr;
	wire [11:0] levinson_scratch_mem_write_addr;
	wire [31:0] levinson_scratch_mem_out;
	wire levinson_scratch_mem_write_en;											
	
	//A(z) to LSP wires
	wire [15:0] Az_addOutA; 
	wire [15:0] Az_addOutB;	
	wire [15:0] Az_subOutA;
	wire [15:0] Az_subOutB;	
	wire [15:0] Az_shrOutVar1;
	wire [15:0] Az_shrOutVar2;	
	wire [31:0] Az_L_shrOutVar1;
	wire [15:0] Az_L_shrOutNumShift;	
	wire [31:0] Az_L_addOutA;
	wire [31:0] Az_L_addOutB;	
	wire [31:0] Az_L_subOutA; 
	wire [31:0] Az_L_subOutB;	
	wire [15:0] Az_multOutA; 
	wire [15:0] Az_multOutB;	
	wire [15:0] Az_L_multOutA; 
	wire [15:0] Az_L_multOutB; 	
	wire [15:0] Az_L_macOutA; 
	wire [15:0] Az_L_macOutB; 
	wire [31:0] Az_L_macOutC; 	
	wire [15:0] Az_L_msuOutA; 
	wire [15:0] Az_L_msuOutB; 
	wire [31:0] Az_L_msuOutC;	
	wire [31:0] Az_L_shlVar1Out; 
	wire [15:0] Az_L_shlNumShiftOut; 
	wire Az_L_shlReady;	
	wire [15:0] Az_norm_sOut; 
	wire Az_norm_sReady; 
	wire Az_divErr;
	wire Az_zero;
	wire [15:0] Az_zero16;
	wire [31:0] Az_zero32;
	assign Az_zero = 1'd0;
	assign Az_zero16 = 16'd0;
	assign Az_zero32 = 32'd0;
	
	wire [11:0] Az_scratchWriteRequested; 
	wire [11:0] Az_scratchReadRequested; 
	wire [31:0] Az_scratchMemOut; 
	wire Az_scratchWriteEn;
	
	//Qua_lsp Wires
	wire [31:0] Qua_lsp_L_addOutA; 
	wire [31:0] Qua_lsp_L_addOutB; 
	wire [31:0] Qua_lsp_L_subOutA; 
	wire [31:0] Qua_lsp_L_subOutB; 
	wire [15:0] Qua_lsp_L_multOutA; 
	wire [15:0] Qua_lsp_L_multOutB; 
	wire [15:0] Qua_lsp_L_macOutA; 
	wire [15:0] Qua_lsp_L_macOutB; 
	wire [31:0] Qua_lsp_L_macOutC; 
	wire [15:0] Qua_lsp_addOutA; 
	wire [15:0] Qua_lsp_addOutB; 
	wire [15:0] Qua_lsp_subOutA; 
	wire [15:0] Qua_lsp_subOutB; 
	wire [15:0] Qua_lsp_shrVar1Out; 
	wire [15:0] Qua_lsp_shrVar2Out; 
	wire [15:0] Qua_lsp_L_msuOutA; 
	wire [15:0] Qua_lsp_L_msuOutB; 
	wire [31:0] Qua_lsp_L_msuOutC; 
	wire [31:0] Qua_lsp_L_shlOutVar1; 
	wire Qua_lsp_L_shlReady; 
	wire [15:0] Qua_lsp_L_shlNumShiftOut; 
	wire [15:0] Qua_lsp_multOutA; 
	wire [15:0] Qua_lsp_multOutB; 
	wire [15:0] Qua_lsp_shlOutVar1; 
	wire [15:0] Qua_lsp_shlOutVar2; 
	wire [15:0] Qua_lsp_norm_sOut; 
	wire Qua_lsp_norm_sReady; 
	wire [31:0] Qua_lsp_L_shrVar1Out; 
	wire [15:0] Qua_lsp_L_shrNumShiftOut;
	
	wire [11:0] Qua_lsp_memReadAddr; 
	wire [11:0] Qua_lsp_memWriteAddr; 
	wire [31:0] Qua_lsp_memIn; 
	wire [11:0] Qua_lsp_constantMemAddr; 
	wire Qua_lsp_memWriteEn; 
	
	
	//Int_lpc Wires
	wire [31:0] Int_lpc_L_addOutA; 
	wire [31:0] Int_lpc_L_addOutB; 
	wire [31:0] Int_lpc_L_subOutA; 
	wire [31:0] Int_lpc_L_subOutB; 
	wire [15:0] Int_lpc_L_multOutA; 
	wire [15:0] Int_lpc_L_multOutB; 
	wire [15:0] Int_lpc_L_macOutA; 
	wire [15:0] Int_lpc_L_macOutB; 
	wire [31:0] Int_lpc_L_macOutC; 
	wire [15:0] Int_lpc_addOutA; 
	wire [15:0] Int_lpc_addOutB; 
	wire [15:0] Int_lpc_subOutA; 
	wire [15:0] Int_lpc_subOutB; 
	wire [15:0] Int_lpc_shrVar1Out; 
	wire [15:0] Int_lpc_shrVar2Out; 
	wire [15:0] Int_lpc_L_msuOutA; 
	wire [15:0] Int_lpc_L_msuOutB; 
	wire [31:0] Int_lpc_L_msuOutC; 
	wire [31:0] Int_lpc_L_shlOutVar1; 
	wire Int_lpc_L_shlReady; 
	wire [15:0] Int_lpc_L_shlNumShiftOut; 
	wire [15:0] Int_lpc_multOutA; 
	wire [15:0] Int_lpc_multOutB; 
	wire [15:0] Int_lpc_shlOutVar1; 
	wire [15:0] Int_lpc_shlOutVar2; 
	wire [15:0] Int_lpc_norm_sOut; 
	wire Int_lpc_norm_sReady; 
	wire [31:0] Int_lpc_L_shrVar1Out; 
	wire [15:0] Int_lpc_L_shrNumShiftOut;
	wire [31:0] Int_lpc_L_abs_out;
	wire [31:0] Int_lpc_L_negate_out;
	wire [31:0] Int_lpc_norm_l_out;
	wire Int_lpc_norm_l_start;
	
	wire [11:0] Int_lpc_memReadAddr; 
	wire [11:0] Int_lpc_memWriteAddr; 
	wire [31:0] Int_lpc_memIn; 
	wire [11:0] Int_lpc_constantMemAddr; 
	wire Int_lpc_memWriteEn; 
	
	
	//Int_qlpc Wires
	wire [31:0] Int_qlpc_L_addOutA; 
	wire [31:0] Int_qlpc_L_addOutB; 
	wire [31:0] Int_qlpc_L_subOutA; 
	wire [31:0] Int_qlpc_L_subOutB; 
	wire [15:0] Int_qlpc_L_multOutA; 
	wire [15:0] Int_qlpc_L_multOutB; 
	wire [15:0] Int_qlpc_L_macOutA; 
	wire [15:0] Int_qlpc_L_macOutB; 
	wire [31:0] Int_qlpc_L_macOutC; 
	wire [15:0] Int_qlpc_addOutA; 
	wire [15:0] Int_qlpc_addOutB; 
	wire [15:0] Int_qlpc_subOutA; 
	wire [15:0] Int_qlpc_subOutB; 
	wire [15:0] Int_qlpc_shrVar1Out; 
	wire [15:0] Int_qlpc_shrVar2Out; 
	wire [15:0] Int_qlpc_L_msuOutA; 
	wire [15:0] Int_qlpc_L_msuOutB; 
	wire [31:0] Int_qlpc_L_msuOutC; 
	wire [31:0] Int_qlpc_L_shlOutVar1; 
	wire Int_qlpc_L_shlReady; 
	wire [15:0] Int_qlpc_L_shlNumShiftOut; 
	wire [15:0] Int_qlpc_multOutA; 
	wire [15:0] Int_qlpc_multOutB; 
	wire [15:0] Int_qlpc_norm_sOut; 
	wire Int_qlpc_norm_sReady; 
	wire [31:0] Int_qlpc_L_shrVar1Out; 
	wire [15:0] Int_qlpc_L_shrNumShiftOut;
	wire [31:0] Int_qlpc_L_abs_out;
	wire [31:0] Int_qlpc_L_negate_out;
	wire [31:0] Int_qlpc_norm_l_out;
	wire Int_qlpc_norm_l_start;
	
	wire [11:0] Int_qlpc_memReadAddr; 
	wire [11:0] Int_qlpc_memWriteAddr; 
	wire [31:0] Int_qlpc_memIn; 
	wire [11:0] Int_qlpc_constantMemAddr; 
	wire Int_qlpc_memWriteEn; 

	
	//Math1 Wires
	wire [15:0] Math1_addOutA; 
	wire [15:0] Math1_addOutB; 
	
	wire [11:0] Math1_memWriteAddr; 
	wire [31:0] Math1_memIn; 
	wire Math1_memWriteEn; 
	wire [11:0] Math1_memReadAddr; 
	wire [11:0] Math1_constantMemAddr; 
	
	
	//perc_var Wires
	wire [15:0] perc_var_shlOutVar1;
	wire [15:0] perc_var_shlOutVar2;
	wire [15:0] perc_var_shrVar1Out;
	wire [15:0] perc_var_shrVar2Out;
	wire [15:0] perc_var_subOutA;
	wire [15:0] perc_var_subOutB;
	wire [15:0] perc_var_L_multOutA;
	wire [15:0] perc_var_L_multOutB;
	wire [31:0] perc_var_L_subOutA;
	wire [31:0] perc_var_L_subOutB;
	wire [31:0] perc_var_L_shrVar1Out;
	wire [15:0] perc_var_L_shrNumShiftOut;
	wire [31:0] perc_var_L_addOutA;
	wire [31:0] perc_var_L_addOutB;
	wire [15:0] perc_var_addOutA;
	wire [15:0] perc_var_addOutB;
	wire [15:0] perc_var_multOutA;
	wire [15:0] perc_var_multOutB;
	wire [11:0] perc_var_memReadAddr;
	wire [11:0] perc_var_memWriteAddr;
	wire perc_var_memWriteEn;
	wire [31:0] perc_var_memIn;
	
	
	//Weight_Az Wires
	wire [11:0] Weight_Az_memReadAddr;
	wire [11:0] Weight_Az_memWriteAddr;
	wire Weight_Az_memWriteEn;
	wire [31:0] Weight_Az_memIn;
	wire [15:0] Weight_Az_L_multOutA;
	wire [15:0] Weight_Az_L_multOutB;
	wire [15:0] Weight_Az_addOutA;
	wire [15:0] Weight_Az_addOutB;
	wire [31:0] Weight_Az_L_addOutA;
	wire [31:0] Weight_Az_L_addOutB;
	
	//Residu Wires
	wire Residu_memWriteEn;
	wire [11:0] Residu_memReadAddr;
	wire [11:0] Residu_memWriteAddr;
	wire [31:0] Residu_memIn;
	wire [15:0] Residu_L_multOutA;
	wire [15:0] Residu_L_multOutB;
	wire [15:0] Residu_L_macOutA;
	wire [15:0] Residu_L_macOutB;
	wire [31:0] Residu_L_macOutC;
	wire [15:0] Residu_subOutA;
	wire [15:0] Residu_subOutB;
	wire [31:0] Residu_L_shlOutVar1;
	wire [15:0] Residu_L_shlNumShiftOut;
	wire [15:0] Residu_addOutA;
	wire [15:0] Residu_addOutB;
	wire [31:0] Residu_L_addOutA;
	wire [31:0] Residu_L_addOutB;
	wire Residu_L_shlReady;
	wire [11:0] Residu_speechAddr;

	//Syn_filt Wires
	wire Syn_filt_memWriteEn;
	wire [11:0] Syn_filt_memReadAddr;
	wire [11:0] Syn_filt_memWriteAddr;
	wire [31:0] Syn_filt_memIn;
	wire [15:0] Syn_filt_addOutA;
	wire [15:0] Syn_filt_addOutB;
	wire [15:0] Syn_filt_subOutA;
	wire [15:0] Syn_filt_subOutB;
	wire [31:0] Syn_filt_L_addOutA;
	wire [31:0] Syn_filt_L_addOutB;
	wire [15:0] Syn_filt_L_multOutA;
	wire [15:0] Syn_filt_L_multOutB;
	wire [15:0] Syn_filt_L_msuOutA; 
	wire [15:0] Syn_filt_L_msuOutB; 
	wire [31:0] Syn_filt_L_msuOutC; 
	wire [31:0] Syn_filt_L_shlOutVar1; 
	wire Syn_filt_L_shlReady; 
	wire [15:0] Syn_filt_L_shlNumShiftOut; 

	//Pitch_ol Wires
	wire [15:0] Pitch_ol_nextT_op;
	
	wire [31:0] Pitch_ol_L_addOutA; 
	wire [31:0] Pitch_ol_L_addOutB; 
	wire [31:0] Pitch_ol_L_subOutA; 
	wire [31:0] Pitch_ol_L_subOutB; 
	wire [15:0] Pitch_ol_L_multOutA; 
	wire [15:0] Pitch_ol_L_multOutB; 
	wire [15:0] Pitch_ol_L_macOutA; 
	wire [15:0] Pitch_ol_L_macOutB; 
	wire [31:0] Pitch_ol_L_macOutC; 
	wire [15:0] Pitch_ol_addOutA; 
	wire [15:0] Pitch_ol_addOutB; 
	wire [15:0] Pitch_ol_subOutA; 
	wire [15:0] Pitch_ol_subOutB; 
	wire [15:0] Pitch_ol_shrVar1Out; 
	wire [15:0] Pitch_ol_shrVar2Out; 
	wire [15:0] Pitch_ol_L_msuOutA; 
	wire [15:0] Pitch_ol_L_msuOutB; 
	wire [31:0] Pitch_ol_L_msuOutC; 
	wire [31:0] Pitch_ol_L_shlOutVar1; 
	wire Pitch_ol_L_shlReady; 
	wire [15:0] Pitch_ol_L_shlNumShiftOut; 
	wire [15:0] Pitch_ol_multOutA; 
	wire [15:0] Pitch_ol_multOutB; 
	wire [15:0] Pitch_ol_shlOutVar1; 
	wire [15:0] Pitch_ol_shlOutVar2; 
	wire [31:0] Pitch_ol_L_shrVar1Out; 
	wire [15:0] Pitch_ol_L_shrNumShiftOut;
	wire [31:0] Pitch_ol_norm_l_out;
	wire Pitch_ol_norm_l_start;
	
	wire [11:0] Pitch_ol_memReadAddr; 
	wire [11:0] Pitch_ol_memWriteAddr; 
	wire [31:0] Pitch_ol_memIn; 
	wire [11:0] Pitch_ol_constantMemAddr; 
	wire Pitch_ol_memWriteEn; 

	//TL_Math2 Wires
	wire [15:0] TL_Math2_nextT0_min;
	wire [15:0] TL_Math2_nextT0_max;
	wire [15:0] TL_Math2_addOutA; 
	wire [15:0] TL_Math2_addOutB; 
	wire [15:0] TL_Math2_subOutA; 
	wire [15:0] TL_Math2_subOutB; 
	wire [31:0] TL_Math2_L_subOutA; 
	wire [31:0] TL_Math2_L_subOutB; 
		
	//TL_Math3 Wires
	wire [15:0] TL_Math3_addOutA;
	wire [15:0] TL_Math3_addOutB;
	wire [11:0] TL_Math3_memWriteAddr;
	wire [31:0] TL_Math3_memIn;
	wire TL_Math3_memWriteEn;
	wire [11:0] TL_Math3_memReadAddr;

	//Pitch_fr3 Wires
	wire [15:0] Pitch_fr3_nextT0;
	wire [15:0] Pitch_fr3_nextT0_frac;
	
	wire [15:0] Pitch_fr3_subOutA; 
	wire [15:0] Pitch_fr3_subOutB; 
	wire [15:0] Pitch_fr3_addOutA; 
	wire [15:0] Pitch_fr3_addOutB; 
	wire [31:0] Pitch_fr3_L_addOutA; 
	wire [31:0] Pitch_fr3_L_addOutB; 
	wire [31:0] Pitch_fr3_L_subOutA; 
	wire [31:0] Pitch_fr3_L_subOutB; 
	wire [31:0] Pitch_fr3_L_negate_out;
	wire [15:0] Pitch_fr3_L_macOutA; 
	wire [15:0] Pitch_fr3_L_macOutB; 
	wire [31:0] Pitch_fr3_L_macOutC; 
	wire [15:0] Pitch_fr3_L_msuOutA; 
	wire [15:0] Pitch_fr3_L_msuOutB; 
	wire [31:0] Pitch_fr3_L_msuOutC; 
	wire [15:0] Pitch_fr3_L_multOutA; 
	wire [15:0] Pitch_fr3_L_multOutB; 
	wire [31:0] Pitch_fr3_L_shlOutVar1; 
	wire Pitch_fr3_L_shlReady; 
	wire [15:0] Pitch_fr3_L_shlNumShiftOut; 
	wire [31:0] Pitch_fr3_L_shrVar1Out; 
	wire [15:0] Pitch_fr3_L_shrNumShiftOut;
	wire [15:0] Pitch_fr3_multOutA; 
	wire [15:0] Pitch_fr3_multOutB; 
	wire [31:0] Pitch_fr3_norm_l_out;
	wire Pitch_fr3_norm_l_start;
	wire [15:0] Pitch_fr3_shrVar1Out; 
	wire [15:0] Pitch_fr3_shrVar2Out;
	
	wire [11:0] Pitch_fr3_memReadAddr; 
	wire [11:0] Pitch_fr3_memWriteAddr; 
	wire [31:0] Pitch_fr3_memIn; 
	wire [11:0] Pitch_fr3_constantMemAddr; 
	wire Pitch_fr3_memWriteEn; 
	
	//Enc_lag3 Wires
	wire [15:0] Enc_lag3_nextindex;
	wire [15:0] Enc_lag3_nextT0_min;
	wire [15:0] Enc_lag3_nextT0_max;
	
	wire [15:0] Enc_lag3_addOutA;
	wire [15:0] Enc_lag3_addOutB;
	wire [15:0] Enc_lag3_subOutA;
	wire [15:0] Enc_lag3_subOutB;
	
	wire [11:0] Enc_lag3_memReadAddr;	
	wire [11:0] Enc_lag3_memWriteAddr;
	wire Enc_lag3_memWriteEn;
	wire [31:0] Enc_lag3_memIn;

	//Parity_Pitch Wires
	wire [15:0] Parity_pitch_sum;
	
	wire [15:0] Parity_pitch_addOutA;
	wire [15:0] Parity_pitch_addOutB;
	wire [15:0] Parity_pitch_shrVar1Out;
	wire [15:0] Parity_pitch_shrVar2Out;

	
	//Pred_lt_3 Wires
	wire [15:0] Pred_lt_3_addOutA;
	wire [15:0] Pred_lt_3_addOutB;
	wire [15:0] Pred_lt_3_subOutA;
	wire [15:0] Pred_lt_3_subOutB;
	wire [15:0] Pred_lt_3_L_macOutA; 
	wire [15:0] Pred_lt_3_L_macOutB; 
	wire [31:0] Pred_lt_3_L_macOutC; 	
	wire [31:0] Pred_lt_3_L_addOutA; 
	wire [31:0] Pred_lt_3_L_addOutB;
	wire [31:0] Pred_lt_3_L_negate_out;	
	wire [11:0] Pred_lt_3_constantMemAddr;
	
	wire [11:0] Pred_lt_3_memReadAddr;	
	wire [11:0] Pred_lt_3_memWriteAddr;
	wire Pred_lt_3_memWriteEn;
	wire [31:0] Pred_lt_3_memIn;	
	
	//Convolve Wires

	wire [11:0] Convolve_memWriteAddr;
	wire Convolve_memWriteEn;
	wire [31:0] Convolve_memIn;	
	wire [15:0] Convolve_L_macOutA; 
	wire [15:0] Convolve_L_macOutB; 
	wire [31:0] Convolve_L_macOutC; 	
	wire [31:0] Convolve_L_shlOutVar1; 
	wire Convolve_L_shlReady; 
	wire [15:0] Convolve_L_shlNumShiftOut; 
	wire [31:0] Convolve_L_subOutA; 
	wire [31:0] Convolve_L_subOutB;
	wire [31:0] Convolve_L_addOutA; 
	wire [31:0] Convolve_L_addOutB; 
	wire [15:0] Convolve_addOutA; 
	wire [15:0] Convolve_addOutB; 
	
	//G_pitch Wires
	wire [15:0] G_pitch_nextgain_pit;
	
	wire [15:0] G_pitch_subOutA; 
	wire [15:0] G_pitch_subOutB; 
	wire [15:0] G_pitch_addOutA; 
	wire [15:0] G_pitch_addOutB; 
	wire [31:0] G_pitch_L_addOutA; 
	wire [31:0] G_pitch_L_addOutB; 
	wire [31:0] G_pitch_L_subOutA; 
	wire [31:0] G_pitch_L_subOutB; 
	wire [15:0] G_pitch_L_macOutA; 
	wire [15:0] G_pitch_L_macOutB; 
	wire [31:0] G_pitch_L_macOutC; 
	wire [31:0] G_pitch_L_shlOutVar1; 
	wire G_pitch_L_shlReady; 
	wire [15:0] G_pitch_L_shlNumShiftOut; 
	wire [31:0] G_pitch_norm_l_out;
	wire G_pitch_norm_l_start;
	wire [15:0] G_pitch_shrVar1Out; 
	wire [15:0] G_pitch_shrVar2Out;
	
	wire [11:0] G_pitch_memReadAddr; 
	wire [11:0] G_pitch_memWriteAddr; 
	wire [31:0] G_pitch_memIn; 
	wire G_pitch_memWriteEn;
	
	//test_err Wires
	wire [15:0] test_err_nexttemp;
	
	wire [15:0] test_err_addOutA;
	wire [15:0] test_err_addOutB;
	wire [15:0] test_err_subOutA;
	wire [15:0] test_err_subOutB;
	wire [31:0] test_err_L_subOutA;
	wire [31:0] test_err_L_subOutB;
	

	wire [11:0] test_err_memReadAddr;
	wire [11:0] test_err_memWriteAddr;
	wire [31:0] test_err_memIn;
	wire test_err_memWriteEn;
	wire [11:0] test_err_constantMemAddr;

	//Math 4 Wires					<------ FIX ME
	wire [31:0] TL_Math4_nextL_temp;
	wire [15:0] TL_Math4_nextgain_pit;
	
	wire [15:0] TL_Math4_addOutA;
	wire [15:0] TL_Math4_addOutB;
	wire [15:0] TL_Math4_subOutA;
	wire [15:0] TL_Math4_subOutB;
	wire [15:0] TL_Math4_L_multOutA;
	wire [15:0] TL_Math4_L_multOutB;
	wire [31:0] TL_Math4_L_shlOutVar1;
	wire [15:0] TL_Math4_L_shlNumShiftOut;
	wire TL_Math4_L_shlReady;
	wire [11:0] TL_Math4_memReadAddr;
	wire [11:0] TL_Math4_memWriteAddr;
	wire [31:0] TL_Math4_memIn;
	wire TL_Math4_memWriteEn;	
	
	//ACELP_Codebook Wires					<------ FIX ME
	wire [31:0] L_add_a2,L_add_b2,L_add_out2,L_add_a3,L_add_b3,L_add_out3,L_add_a4,L_add_b4,L_add_out4;
	wire [15:0] ACELP_Codebook_nextindex;
	wire [15:0] ACELP_Codebook_nexti;

	wire [15:0] ACELP_Codebook_shlVar1Out;
	wire [15:0] ACELP_Codebook_shlVar2Out;
	wire [15:0] ACELP_Codebook_subOutA;
	wire [15:0] ACELP_Codebook_subOutB;
	wire [15:0] ACELP_Codebook_addOutA;
	wire [15:0] ACELP_Codebook_addOutB;
	wire [15:0] ACELP_Codebook_multOutA;
	wire [15:0] ACELP_Codebook_multOutB;
	wire [15:0] ACELP_Codebook_L_macOutA;
	wire [15:0] ACELP_Codebook_L_macOutB;
	wire [31:0] ACELP_Codebook_L_macOutC;
	wire [31:0] ACELP_Codebook_L_addOutA;
	wire [31:0] ACELP_Codebook_L_addOutB;
	wire [31:0] ACELP_Codebook_L_subOutA;
	wire [31:0] ACELP_Codebook_L_subOutB;
	wire [31:0] ACELP_Codebook_L_abs_out;
	wire [31:0] ACELP_Codebook_norm_l_out;
	wire ACELP_Codebook_norm_l_start;
	wire [31:0] ACELP_Codebook_L_shrVar1Out;
	wire [15:0] ACELP_Codebook_L_shrNumShiftOut;
	wire [31:0] ACELP_Codebook_L_negate_out;
	wire [15:0] ACELP_Codebook_L_multOutA;
	wire [15:0] ACELP_Codebook_L_multOutB;
	wire [15:0] ACELP_Codebook_L_msuOutA;
	wire [15:0] ACELP_Codebook_L_msuOutB;
	wire [31:0] ACELP_Codebook_L_msuOutC;
	wire [15:0] ACELP_Codebook_shrVar1Out;
	wire [15:0] ACELP_Codebook_shrVar2Out;
	wire [11:0] ACELP_Codebook_memReadAddr;
	wire [11:0] ACELP_Codebook_memWriteAddr;
	wire [31:0] ACELP_Codebook_memIn;
	wire ACELP_Codebook_memWriteEn;	

	//Math 5 Wires					<------ FIX ME
	wire [15:0] TL_Math5_addOutA;
	wire [15:0] TL_Math5_addOutB;
	wire [31:0] TL_Math5_L_negate_out;
	wire [11:0] TL_Math5_memReadAddr;
	wire [11:0] TL_Math5_memWriteAddr;
	wire [31:0] TL_Math5_memIn;
	wire TL_Math5_memWriteEn;
	
	//Corr_xy2 Wires
	wire [15:0] Corr_xy2_shrVar1Out;
	wire [15:0] Corr_xy2_shrVar2Out;
	wire [15:0] Corr_xy2_L_macOutA;
	wire [15:0] Corr_xy2_L_macOutB;
	wire [31:0] Corr_xy2_L_macOutC;
	wire [15:0] Corr_xy2_addOutA;
	wire [15:0] Corr_xy2_addOutB;
	wire [31:0] Corr_xy2_norm_l_out;
	wire Corr_xy2_norm_l_start;
	wire [31:0] Corr_xy2_L_shlOutVar1;
	wire [15:0] Corr_xy2_L_shlNumShiftOut;
	wire Corr_xy2_L_shlReady;
	wire [31:0] Corr_xy2_L_addOutA;
	wire [31:0] Corr_xy2_L_addOutB;
	wire [15:0] Corr_xy2_subOutA;
	wire [15:0] Corr_xy2_subOutB;
	wire [31:0] Corr_xy2_L_negate_out;
	
	wire [11:0] Corr_xy2_memReadAddr;
	wire [11:0] Corr_xy2_memWriteAddr;
	wire [31:0] Corr_xy2_memIn;
	wire Corr_xy2_memWriteEn;

	
	//Qua_gain Wires
	wire [15:0] Qua_gain_gain_pit;
	wire [15:0] Qua_gain_gain_cod;
	
	wire [15:0] Qua_gain_L_macOutA;
	wire [15:0] Qua_gain_L_macOutB;
	wire [31:0] Qua_gain_L_macOutC;
	wire [15:0] Qua_gain_L_msuOutA;
	wire [15:0] Qua_gain_L_msuOutB;
	wire [31:0] Qua_gain_L_msuOutC;
	wire [15:0] Qua_gain_L_multOutA;
	wire [15:0] Qua_gain_L_multOutB;
	wire [31:0] Qua_gain_L_addOutA;
	wire [31:0] Qua_gain_L_addOutB;
	wire [31:0] Qua_gain_L_subOutA;
	wire [31:0] Qua_gain_L_subOutB;
	wire [31:0] Qua_gain_L_shrVar1Out;
	wire [15:0] Qua_gain_L_shrNumShiftOut;
	wire [31:0] Qua_gain_L_shlOutVar1;
	wire [15:0] Qua_gain_L_shlNumShiftOut;
	wire Qua_gain_L_shlReady;
	wire [31:0] Qua_gain_norm_l_out;
	wire Qua_gain_norm_l_start;
	wire [15:0] Qua_gain_multOutA;
	wire [15:0] Qua_gain_multOutB;
	wire [15:0] Qua_gain_shlVar1Out;
	wire [15:0] Qua_gain_shlVar2Out;
	wire [15:0] Qua_gain_addOutA;
	wire [15:0] Qua_gain_addOutB;
	wire [15:0] Qua_gain_subOutA;
	wire [15:0] Qua_gain_subOutB;
	wire [31:0] Qua_gain_L_negate_out;
	wire [15:0] Qua_gain_shrVar1Out;
	wire [15:0] Qua_gain_shrVar2Out;	
	
	wire [11:0] Qua_gain_memWriteAddr;
	wire [11:0] Qua_gain_memReadAddr;
	wire Qua_gain_memWriteEn;
	wire [31:0] Qua_gain_memIn;
	wire [11:0] Qua_gain_constantMemAddr;
	
	//Math 6 Wires					<------ FIX ME

	wire [15:0] TL_Math6_nextsharp;
	wire [31:0] TL_Math6_nextL_temp;

	wire [15:0] TL_Math6_L_multOutA;
	wire [15:0] TL_Math6_L_multOutB;
	wire [15:0] TL_Math6_L_macOutA;
	wire [15:0] TL_Math6_L_macOutB;
	wire [31:0] TL_Math6_L_macOutC;
	wire [31:0] TL_Math6_L_shlOutVar1;
	wire [15:0] TL_Math6_L_shlNumShiftOut;
	wire TL_Math6_L_shlReady;
	wire [15:0] TL_Math6_addOutA;
	wire [15:0] TL_Math6_addOutB;
	wire [15:0] TL_Math6_subOutA;
	wire [15:0] TL_Math6_subOutB;
	wire [11:0] TL_Math6_memReadAddr;
	wire [11:0] TL_Math6_memWriteAddr;
	wire [31:0] TL_Math6_memIn;
	wire TL_Math6_memWriteEn;
	wire [31:0] TL_Math6_L_addOutA;
	wire [31:0] TL_Math6_L_addOutB;
	
	//update_exc_err Wires
	wire [15:0] update_exc_err_subOutA;
	wire [15:0] update_exc_err_subOutB;
	wire [31:0] update_exc_err_L_shlOutVar1;
	wire [15:0] update_exc_err_L_shlNumShiftOut;
	wire update_exc_err_L_shlReady;
	wire [31:0] update_exc_err_L_addOutA;
	wire [31:0] update_exc_err_L_addOutB;
	wire [31:0] update_exc_err_L_subOutA;
	wire [31:0] update_exc_err_L_subOutB;
	wire [15:0] update_exc_err_addOutA;
	wire [15:0] update_exc_err_addOutB;
	wire [15:0] update_exc_err_L_macOutA;
	wire [15:0] update_exc_err_L_macOutB;
	wire [31:0] update_exc_err_L_macOutC;
	wire [15:0] update_exc_err_L_multOutA;
	wire [15:0] update_exc_err_L_multOutB;
	wire [15:0] update_exc_err_multOutA;
	wire [15:0] update_exc_err_multOutB;
	wire [15:0] update_exc_err_L_msuOutA;
	wire [15:0] update_exc_err_L_msuOutB;
	wire [31:0] update_exc_err_L_msuOutC;
	wire [31:0] update_exc_err_L_shrVar1Out;
	wire [15:0] update_exc_err_L_shrNumShiftOut;

	wire [11:0] update_exc_err_memReadAddr;
	wire [11:0] update_exc_err_memWriteAddr;
	wire [31:0] update_exc_err_memIn;
	wire update_exc_err_memWriteEn;
	wire [11:0] update_exc_err_constantMemAddr;

	
	//Math 7 Wires					<------ FIX ME


	

	//Copy Wires
	wire [15:0] Copy_addOutA;
	wire [15:0] Copy_addOutB;
	wire [31:0] Copy_L_addOutA;
	wire [31:0] Copy_L_addOutB;
	
	wire [11:0] Copy_memWriteAddr;
	wire [11:0] Copy_memReadAddr;
	wire Copy_memWriteEn;
	wire [31:0] Copy_memIn;
	
	
	//prm2bits_ld8kDone Wires
	wire [15:0] prm2bits_ld8k_addOutA;
	wire [15:0] prm2bits_ld8k_addOutB;
	wire [31:0] prm2bits_ld8k_L_addOutA;
	wire [31:0] prm2bits_ld8k_L_addOutB;
	wire [15:0] prm2bits_ld8k_subOutA;
	wire [15:0] prm2bits_ld8k_subOutB;

	wire [11:0] prm2bits_ld8k_memReadAddr;
	wire [11:0] prm2bits_ld8k_memWriteAddr;
	wire [31:0] prm2bits_ld8k_memIn;
	wire prm2bits_ld8k_memWriteEn;
	wire [11:0] prm2bits_ld8k_constantMemAddr;
	
	//always block regs
	reg [11:0] Residu_memSameAddr;
	reg [31:0] memReadDataA;
	reg [31:0] memReadDataX;
	reg [11:0] LOAD_ANA_2_7_Addr;
	reg [11:0] LOAD_ANA_4_8_Addr;
	reg [11:0] LOAD_ANA_5_9_Addr;
	reg [31:0] LOAD_ANA_2_7_Data;
	reg [31:0] LOAD_ANA_4_8_Data;
	reg [31:0] LOAD_ANA_5_9_Data;
	reg [31:0] Parity_pitch_sum_Data;

//	//////////////////////////////////////////////////////////////////////////////////////////////
//	//
//	//		FFs
//	//
//	//////////////////////////////////////////////////////////////////////////////////////////////
//	
// Word16 k, i_subfr, i_gamma;
// Word16 T_op, T0, T0_min, T0_max, T0_frac;
// Word16 gain_pit, gain_code, index;
// Word16 temp;
// Word32 L_temp;

	always @(posedge clock)
	begin
		if(reset)
			A_Addr <= 0;
		else if(resetA_Addr)
			A_Addr <= 0;
		else if(LDA_Addr)
		begin
			if (i_subfr == 'd40)
				A_Addr <= A_T_HIGH;
			else
				A_Addr <= A_T_LOW;
		end
	end
	always @(posedge clock)
	begin
		if(reset)
			Aq_Addr <= 0;
		else if(resetAq_Addr)
			Aq_Addr <= 0;
		else if(LDAq_Addr)
		begin
			if (i_subfr == 'd40)
				Aq_Addr <= AQ_T_HIGH;
			else
				Aq_Addr <= AQ_T_LOW;
		end
	end
	always @(posedge clock)
	begin
		if(reset)
			i_gamma <= 0;
		else if(reseti_gamma)
			i_gamma <= 0;
		else if(LDi_gamma)
		begin
			i_gamma <= i_gamma + 'd1;
		end
	end	
	always @(posedge clock)
	begin
		if(reset)
			i_subfr <= 0;
		else if(reseti_subfr)
			i_subfr <= 0;
		else if(LDi_subfr)
		begin
			i_subfr <= i_subfr + L_SUBFR;
		end
	end
	wire [15:0] i_subfr_in;

//********************************************************************************************************
	
	always @(posedge clock)
	begin
		if(reset)
			gain_code <= 0;
		else if(resetgain_code)
			gain_code <= 0;
		else if(LDgain_code)
			gain_code <= nextgain_code;
	end	
	mux128_16 i_mux128_16_gain_code(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(Qua_gain_gain_cod),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nextgain_code));
	always @(posedge clock)
	begin
		if(reset)
			gain_pit <= 0;
		else if(resetgain_pit)
			gain_pit <= 0;
		else if(LDgain_pit)
			gain_pit <= nextgain_pit;
	end	
	mux128_16 i_mux128_16_gain_pit(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(G_pitch_nextgain_pit),.in37(0),.in38(TL_Math4_nextgain_pit),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(Qua_gain_gain_pit),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nextgain_pit));

	always @(posedge clock)
	begin
		if(reset)
			index <= 0;
		else if(resetindex)
			index <= 0;
		else if(LDindex)
			index <= nextindex;
	end
	mux128_16 i_mux128_16_index(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(Enc_lag3_nextindex),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(ACELP_Codebook_nextindex),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nextindex));
	always @(posedge clock)
	begin
		if(reset)
			k <= 0;
		else if(resetk)
			k <= 0;
		else if(LDk)
			k <= nextk;
	end	
	mux128_16 i_mux128_16_k(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nextk));
	always @(posedge clock)
	begin
		if(reset)
			L_temp <= 0;
		else if(resetL_temp)
			L_temp <= 0;
		else if(LDL_temp)
			L_temp <= nextL_temp;
	end	
	mux128_32 i_mux128_32_L_temp(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(TL_Math4_nextL_temp),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(TL_Math6_nextL_temp),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nextL_temp));

	always @(posedge clock)
	begin
		if(reset)
			sharp <= SHARPMIN;
		else if(resetsharp)
			sharp <= SHARPMIN;
		else if(LDsharp)
			sharp <= nextsharp;
	end
		mux128_16 i_mux128_16_sharp(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(TL_Math6_nextsharp),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nextsharp));

	always @(posedge clock)
	begin
		if(reset)
			i <= 0;
		else if(reseti)
			i <= 0;
		else if(LDi)
			i <= nexti;
	end
		mux128_16 i_mux128_16_i(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(ACELP_Codebook_nexti),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nexti));

	always @(posedge clock)
	begin
		if(reset)
			T_op <= 0;
		else if(resetT_op)
			T_op <= 0;
		else if(LDT_op)
			T_op <= nextT_op;
	end
	mux128_16 i_mux128_16_T_op(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(Pitch_ol_nextT_op),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nextT_op));
	always @(posedge clock)
	begin
		if(reset)
			T0 <= 0;
		else if(resetT0)
			T0 <= 0;
		else if(LDT0)
			T0 <= nextT0;
	end
	mux128_16 i_mux128_16_T0(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(Pitch_fr3_nextT0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nextT0));
	always @(posedge clock)
	begin
		if(reset)
			T0_frac <= 0;
		else if(resetT0_frac)
			T0_frac <= 0;
		else if(LDT0_frac)
			T0_frac <= nextT0_frac;
	end	
	mux128_16 i_mux128_16_T0_frac(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(Pitch_fr3_nextT0_frac),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nextT0_frac));
	always @(posedge clock)
	begin
		if(reset)
			T0_max <= 0;
		else if(resetT0_max)
			T0_max <= 0;
		else if(LDT0_max)
			T0_max <= nextT0_max;
	end
	mux128_16 i_mux128_16_T0_max(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(TL_Math2_nextT0_max),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(Enc_lag3_nextT0_max),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nextT0_max));

	always @(posedge clock)
	begin
		if(reset)
			T0_min <= 0;
		else if(resetT0_min)
			T0_min <= 0;
		else if(LDT0_min)
			T0_min <= nextT0_min;
	end
		mux128_16 i_mux128_16_T0_min(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(TL_Math2_nextT0_min),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(Enc_lag3_nextT0_min),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nextT0_min));

	always @(posedge clock)
	begin
		if(reset)
			temp <= 0;
		else if(resettemp)
			temp <= 0;
		else if(LDtemp)
			temp <= nexttemp;
	end
		mux128_16 i_mux128_16_temp(
												.in0(0),
												.in1(0),
												.in2(0),
												.in3(0),
												.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(test_err_nexttemp),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(nexttemp));
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		add
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [15:0] add_a,add_b;
	
	add i_add_1(
					.a(add_a),
					.b(add_b),
					.overflow(add_overflow),
					.sum(add_out)
					);
					
		mux128_16 i_mux128_16_add_a(
											.in0(autocorr_addOutA),
											.in1(lag_addOutA),
											.in2(levinson_add_outa),
											.in3(Az_addOutA),
											.in4(Qua_lsp_addOutA),.in5(Int_lpc_addOutA),
		.in6(Int_qlpc_addOutA),.in7(Math1_addOutA),.in8(perc_var_addOutA),.in9(Weight_Az_addOutA),.in10(Weight_Az_addOutA),.in11(Residu_addOutA),.in12(Syn_filt_addOutA),.in13(Weight_Az_addOutA),.in14(Weight_Az_addOutA),.in15(Residu_addOutA),
		.in16(Syn_filt_addOutA),.in17(Pitch_ol_addOutA),.in18(TL_Math2_addOutA),.in19(Weight_Az_addOutA),.in20(Weight_Az_addOutA),.in21(TL_Math3_addOutA),.in22(Syn_filt_addOutA),.in23(Syn_filt_addOutA),.in24(Residu_addOutA),
		.in25(Syn_filt_addOutA),.in26(Residu_addOutA),.in27(Syn_filt_addOutA),.in28(Pitch_fr3_addOutA),.in29(Enc_lag3_addOutA),.in30(0),.in31(Parity_pitch_addOutA),.in32(0),.in33(Pred_lt_3_addOutA),
		.in34(Convolve_addOutA),.in35(G_pitch_addOutA),.in36(test_err_addOutA),.in37(TL_Math4_addOutA),.in38(ACELP_Codebook_addOutA),.in39(0),.in40(0),.in41(TL_Math5_addOutA),.in42(Corr_xy2_addOutA),
		.in43(Qua_gain_addOutA),.in44(TL_Math6_addOutA),.in45(update_exc_err_addOutA),.in46(Syn_filt_addOutA),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(add_a));
	
	mux128_16 i_mux128_16_add_b(
											.in0(autocorr_addOutB),
											.in1(lag_addOutB),
											.in2(levinson_add_outb),
											.in3(Az_addOutB),
											.in4(Qua_lsp_addOutB),.in5(Int_lpc_addOutB),
		.in6(Int_qlpc_addOutB),.in7(Math1_addOutB),.in8(perc_var_addOutB),.in9(Weight_Az_addOutB),.in10(Weight_Az_addOutB),.in11(Residu_addOutB),.in12(Syn_filt_addOutB),.in13(Weight_Az_addOutB),.in14(Weight_Az_addOutB),.in15(Residu_addOutB),
		.in16(Syn_filt_addOutB),.in17(Pitch_ol_addOutB),.in18(TL_Math2_addOutB),.in19(Weight_Az_addOutB),.in20(Weight_Az_addOutB),.in21(TL_Math3_addOutB),.in22(Syn_filt_addOutB),.in23(Syn_filt_addOutB),.in24(Residu_addOutB),
		.in25(Syn_filt_addOutB),.in26(Residu_addOutB),.in27(Syn_filt_addOutB),.in28(Pitch_fr3_addOutB),.in29(Enc_lag3_addOutB),.in30(0),.in31(Parity_pitch_addOutB),.in32(0),.in33(Pred_lt_3_addOutB),
		.in34(Convolve_addOutB),.in35(G_pitch_addOutB),.in36(test_err_addOutB),.in37(TL_Math4_addOutB),.in38(ACELP_Codebook_addOutB),.in39(0),.in40(0),.in41(TL_Math5_addOutB),.in42(Corr_xy2_addOutB),
		.in43(Qua_gain_addOutB),.in44(TL_Math6_addOutB),.in45(update_exc_err_addOutB),.in46(Syn_filt_addOutB),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(add_b));
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		L_abs
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [31:0] L_abs_a;
	
	L_abs i_L_abs_1(
						.var_in(L_abs_a),
						.var_out(L_abs_out)
						);
	
	mux128_32 i_mux128_32_L_abs_a(
											.in0(autocorr_zero32),
											.in1(lag_zero32),
											.in2(levinson_abs_out),
											.in3(Az_zero32),.in4(0),.in5(Int_lpc_L_abs_out),
		.in6(Int_qlpc_L_abs_out),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(ACELP_Codebook_L_abs_out),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_abs_a));		
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		L_add
	//
	//////////////////////////////////////////////////////////////////////////////////////////////	
	wire [31:0] L_add_a,L_add_b;
	
	L_add i_L_add_1(
						.a(L_add_a),
						.b(L_add_b),
						.overflow(L_add_overflow),
						.sum(L_add_out)
						);
	
	mux128_32 i_mux128_32_L_add_a(
											.in0(autocorr_zero32),
											.in1(lag_zero32),
											.in2(levinson_L_add_outa),
											.in3(Az_L_addOutA),
											.in4(Qua_lsp_L_addOutA),.in5(Int_lpc_L_addOutA),
		.in6(Int_qlpc_L_addOutA),.in7(0),.in8(perc_var_L_addOutA),.in9(Weight_Az_L_addOutA),.in10(Weight_Az_L_addOutA),.in11(Residu_L_addOutA),.in12(Syn_filt_L_addOutA),.in13(Weight_Az_L_addOutA),.in14(Weight_Az_L_addOutA),.in15(Residu_L_addOutA),
		.in16(Syn_filt_L_addOutA),.in17(Pitch_ol_L_addOutA),.in18(0),.in19(Weight_Az_L_addOutA),.in20(Weight_Az_L_addOutA),.in21(0),.in22(Syn_filt_L_addOutA),.in23(Syn_filt_L_addOutA),.in24(Residu_L_addOutA),
		.in25(Syn_filt_L_addOutA),.in26(Residu_L_addOutA),.in27(Syn_filt_L_addOutA),.in28(Pitch_fr3_L_addOutA),.in29(0),.in30(0),.in31(0),.in32(0),.in33(Pred_lt_3_L_addOutA),
		.in34(Convolve_L_addOutA),.in35(G_pitch_L_addOutA),.in36(0),.in37(0),.in38(ACELP_Codebook_L_addOutA),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_L_addOutA),
		.in43(Qua_gain_L_addOutA),.in44(TL_Math6_L_addOutA),.in45(update_exc_err_L_addOutA),.in46(Syn_filt_L_addOutA),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_add_a));
		
	mux128_32 i_mux128_32_L_add_b(
											.in0(autocorr_zero32),
											.in1(lag_zero32),
											.in2(levinson_L_add_outb),
											.in3(Az_L_addOutB),
											.in4(Qua_lsp_L_addOutB),.in5(Int_lpc_L_addOutB),
		.in6(Int_qlpc_L_addOutB),.in7(0),.in8(perc_var_L_addOutB),.in9(Weight_Az_L_addOutB),.in10(Weight_Az_L_addOutB),.in11(Residu_L_addOutB),.in12(Syn_filt_L_addOutB),.in13(Weight_Az_L_addOutB),.in14(Weight_Az_L_addOutB),.in15(Residu_L_addOutB),
		.in16(Syn_filt_L_addOutB),.in17(Pitch_ol_L_addOutB),.in18(0),.in19(Weight_Az_L_addOutB),.in20(Weight_Az_L_addOutB),.in21(0),.in22(Syn_filt_L_addOutB),.in23(Syn_filt_L_addOutB),.in24(Residu_L_addOutB),
		.in25(Syn_filt_L_addOutB),.in26(Residu_L_addOutB),.in27(Syn_filt_L_addOutB),.in28(Pitch_fr3_L_addOutB),.in29(0),.in30(0),.in31(0),.in32(0),.in33(Pred_lt_3_L_addOutB),
		.in34(Convolve_L_addOutB),.in35(G_pitch_L_addOutB),.in36(0),.in37(0),.in38(ACELP_Codebook_L_addOutB),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_L_addOutB),
		.in43(Qua_gain_L_addOutB),.in44(TL_Math6_L_addOutB),.in45(update_exc_err_L_addOutB),.in46(Syn_filt_L_addOutB),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_add_b));

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		L_mac
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [15:0] L_mac_a,L_mac_b;
	wire [31:0] L_mac_c;
	
	L_mac i_L_mac_1(
						.a(L_mac_a),
						.b(L_mac_b),
						.c(L_mac_c),
						.overflow(L_mac_overflow),
						.out(L_mac_out)
						);

	mux128_16 i_mux128_16_L_mac_a(
											.in0(autocorr_L_macOutA),
											.in1(lag_L_macOutA),
											.in2(levinson_L_mac_outa),
											.in3(Az_L_macOutA),
											.in4(Qua_lsp_L_macOutA),.in5(Int_lpc_L_macOutA),
			.in6(Int_qlpc_L_macOutA),.in7(0),.in8(0),.in9(0),.in10(0),.in11(Residu_L_macOutA),.in12(0),.in13(0),.in14(0),.in15(Residu_L_macOutA),
			.in16(0),.in17(Pitch_ol_L_macOutA),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(Residu_L_macOutA),
			.in25(0),.in26(Residu_L_macOutA),.in27(0),.in28(Pitch_fr3_L_macOutA),.in29(0),.in30(0),.in31(0),.in32(0),.in33(Pred_lt_3_L_macOutA),
			.in34(Convolve_L_macOutA),.in35(G_pitch_L_macOutA),.in36(0),.in37(0),.in38(ACELP_Codebook_L_macOutA),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_L_macOutA),
			.in43(Qua_gain_L_macOutA),.in44(TL_Math6_L_macOutA),.in45(update_exc_err_L_macOutA),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
			.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
			.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
			.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
			.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
			.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
			.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
			.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
			.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
			.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_mac_a));
			
	mux128_16 i_mux128_16_L_mac_b(
											.in0(autocorr_L_macOutB),
											.in1(lag_L_macOutB),
											.in2(levinson_L_mac_outb),
											.in3(Az_L_macOutB),
											.in4(Qua_lsp_L_macOutB),.in5(Int_lpc_L_macOutB),
		.in6(Int_qlpc_L_macOutB),.in7(0),.in8(0),.in9(0),.in10(0),.in11(Residu_L_macOutB),.in12(0),.in13(0),.in14(0),.in15(Residu_L_macOutB),
		.in16(0),.in17(Pitch_ol_L_macOutB),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(Residu_L_macOutB),
		.in25(0),.in26(Residu_L_macOutB),.in27(0),.in28(Pitch_fr3_L_macOutB),.in29(0),.in30(0),.in31(0),.in32(0),.in33(Pred_lt_3_L_macOutB),
		.in34(Convolve_L_macOutB),.in35(G_pitch_L_macOutB),.in36(0),.in37(0),.in38(ACELP_Codebook_L_macOutB),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_L_macOutB),
		.in43(Qua_gain_L_macOutB),.in44(TL_Math6_L_macOutB),.in45(update_exc_err_L_macOutB),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_mac_b));
			
	mux128_32 i_mux128_32_L_mac_c(
											.in0(autocorr_L_macOutC),
											.in1(lag_L_macOutC),
											.in2(levinson_L_mac_outc),
											.in3(Az_L_macOutC),
											.in4(Qua_lsp_L_macOutC),.in5(Int_lpc_L_macOutC),
		.in6(Int_qlpc_L_macOutC),.in7(0),.in8(0),.in9(0),.in10(0),.in11(Residu_L_macOutC),.in12(0),.in13(0),.in14(0),.in15(Residu_L_macOutC),
		.in16(0),.in17(Pitch_ol_L_macOutC),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(Residu_L_macOutC),
		.in25(0),.in26(Residu_L_macOutC),.in27(0),.in28(Pitch_fr3_L_macOutC),.in29(0),.in30(0),.in31(0),.in32(0),.in33(Pred_lt_3_L_macOutC),
		.in34(Convolve_L_macOutC),.in35(G_pitch_L_macOutC),.in36(0),.in37(0),.in38(ACELP_Codebook_L_macOutC),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_L_macOutC),
		.in43(Qua_gain_L_macOutC),.in44(TL_Math6_L_macOutC),.in45(update_exc_err_L_macOutC),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_mac_c));
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		L_msu
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [15:0] L_msu_a,L_msu_b;
	wire [31:0] L_msu_c;
	
	L_msu i_L_msu_1(
						.a(L_msu_a),
						.b(L_msu_b),
						.c(L_msu_c),
						.overflow(L_msu_overflow),
						.out(L_msu_out)
						);	

	mux128_16 i_mux128_16_L_msu_a(
											.in0(autocorr_L_msuOutA),
											.in1(lag_L_msuOutA),
											.in2(0),
											.in3(Az_L_msuOutA),
											.in4(Qua_lsp_L_msuOutA),.in5(Int_lpc_L_msuOutA),
		.in6(Int_qlpc_L_msuOutA),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(Syn_filt_L_msuOutA),.in13(0),.in14(0),.in15(0),
		.in16(Syn_filt_L_msuOutA),.in17(Pitch_ol_L_msuOutA),.in18(0),.in19(0),.in20(0),.in21(0),.in22(Syn_filt_L_msuOutA),.in23(Syn_filt_L_msuOutA),.in24(0),
		.in25(Syn_filt_L_msuOutA),.in26(0),.in27(Syn_filt_L_msuOutA),.in28(Pitch_fr3_L_msuOutA),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(ACELP_Codebook_L_msuOutA),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(Qua_gain_L_msuOutA),.in44(0),.in45(update_exc_err_L_msuOutA),.in46(Syn_filt_L_msuOutA),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_msu_a));
			
	mux128_16 i_mux128_16_L_msu_b(
											.in0(autocorr_L_msuOutB),
											.in1(lag_L_msuOutB),
											.in2(0),
											.in3(Az_L_msuOutB),
											.in4(Qua_lsp_L_msuOutB),.in5(Int_lpc_L_msuOutB),
		.in6(Int_qlpc_L_msuOutB),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(Syn_filt_L_msuOutB),.in13(0),.in14(0),.in15(0),
		.in16(Syn_filt_L_msuOutB),.in17(Pitch_ol_L_msuOutB),.in18(0),.in19(0),.in20(0),.in21(0),.in22(Syn_filt_L_msuOutB),.in23(Syn_filt_L_msuOutB),.in24(0),
		.in25(Syn_filt_L_msuOutB),.in26(0),.in27(Syn_filt_L_msuOutB),.in28(Pitch_fr3_L_msuOutB),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(ACELP_Codebook_L_msuOutB),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(Qua_gain_L_msuOutB),.in44(0),.in45(update_exc_err_L_msuOutB),.in46(Syn_filt_L_msuOutB),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_msu_b));
			
	mux128_32 i_mux128_32_L_msu_c(
											.in0(autocorr_L_msuOutC),
											.in1(lag_L_msuOutC),
											.in2(0),
											.in3(Az_L_msuOutC),
											.in4(Qua_lsp_L_msuOutC),.in5(Int_lpc_L_msuOutC),
		.in6(Int_qlpc_L_msuOutC),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(Syn_filt_L_msuOutC),.in13(0),.in14(0),.in15(0),
		.in16(Syn_filt_L_msuOutC),.in17(Pitch_ol_L_msuOutC),.in18(0),.in19(0),.in20(0),.in21(0),.in22(Syn_filt_L_msuOutC),.in23(Syn_filt_L_msuOutC),.in24(0),
		.in25(Syn_filt_L_msuOutC),.in26(0),.in27(Syn_filt_L_msuOutC),.in28(Pitch_fr3_L_msuOutC),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(ACELP_Codebook_L_msuOutC),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(Qua_gain_L_msuOutC),.in44(0),.in45(update_exc_err_L_msuOutC),.in46(Syn_filt_L_msuOutC),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_msu_c));		
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		L_mult
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [15:0] L_mult_a, L_mult_b;
	
	L_mult i_L_mult_1(.a(L_mult_a),.b(L_mult_b),.overflow(L_mult_overflow),.product(L_mult_out));

	mux128_16 i_mux128_16_L_mult_a(
												.in0(autocorr_zero16),
												.in1(lag_L_multOutA),
												.in2(levinson_L_mult_outa),
												.in3(Az_L_multOutA),
												.in4(Qua_lsp_L_multOutA),.in5(Int_lpc_L_multOutA),
			.in6(Int_qlpc_L_multOutA),.in7(0),.in8(perc_var_L_multOutA),.in9(Weight_Az_L_multOutA),.in10(Weight_Az_L_multOutA),.in11(Residu_L_multOutA),.in12(Syn_filt_L_multOutA),.in13(Weight_Az_L_multOutA),.in14(Weight_Az_L_multOutA),.in15(Residu_L_multOutA),
			.in16(Syn_filt_L_multOutA),.in17(Pitch_ol_L_multOutA),.in18(0),.in19(Weight_Az_L_multOutA),.in20(Weight_Az_L_multOutA),.in21(0),.in22(Syn_filt_L_multOutA),.in23(Syn_filt_L_multOutA),.in24(Residu_L_multOutA),
			.in25(Syn_filt_L_multOutA),.in26(Residu_L_multOutA),.in27(Syn_filt_L_multOutA),.in28(Pitch_fr3_L_multOutA),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
			.in34(0),.in35(0),.in36(0),.in37(TL_Math4_L_multOutA),.in38(ACELP_Codebook_L_multOutA),.in39(0),.in40(0),.in41(0),.in42(0),
			.in43(Qua_gain_L_multOutA),.in44(TL_Math6_L_multOutA),.in45(update_exc_err_L_multOutA),.in46(Syn_filt_L_multOutA),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
			.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
			.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
			.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
			.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
			.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
			.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
			.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
			.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
			.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_mult_a));
	
	mux128_16 i_mux128_16_L_mult_b(
											.in0(autocorr_zero16),
											.in1(lag_L_multOutB),
											.in2(levinson_L_mult_outb),
											.in3(Az_L_multOutB),
											.in4(Qua_lsp_L_multOutB),.in5(Int_lpc_L_multOutB),
			.in6(Int_qlpc_L_multOutB),.in7(0),.in8(perc_var_L_multOutB),.in9(Weight_Az_L_multOutB),.in10(Weight_Az_L_multOutB),.in11(Residu_L_multOutB),.in12(Syn_filt_L_multOutB),.in13(Weight_Az_L_multOutB),.in14(Weight_Az_L_multOutB),.in15(Residu_L_multOutB),
			.in16(Syn_filt_L_multOutB),.in17(Pitch_ol_L_multOutB),.in18(0),.in19(Weight_Az_L_multOutB),.in20(Weight_Az_L_multOutB),.in21(0),.in22(Syn_filt_L_multOutB),.in23(Syn_filt_L_multOutB),.in24(Residu_L_multOutB),
			.in25(Syn_filt_L_multOutB),.in26(Residu_L_multOutB),.in27(Syn_filt_L_multOutB),.in28(Pitch_fr3_L_multOutB),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
			.in34(0),.in35(0),.in36(0),.in37(TL_Math4_L_multOutB),.in38(ACELP_Codebook_L_multOutB),.in39(0),.in40(0),.in41(0),.in42(0),
			.in43(Qua_gain_L_multOutB),.in44(TL_Math6_L_multOutB),.in45(update_exc_err_L_multOutB),.in46(Syn_filt_L_multOutB),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
			.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
			.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
			.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
			.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
			.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
			.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
			.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
			.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
			.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_mult_b));
			
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		L_negate
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [31:0] L_negate_a;
	
	L_negate i_L_negate_1(
								.var_in(L_negate_a),
								.var_out(L_negate_out)
								);

	mux128_32 i_mux128_32_L_negate_a(
												.in0(autocorr_zero32),
												.in1(lag_zero32),
												.in2(levinson_negate_out),
												.in3(Az_zero32),.in4(0),.in5(Int_lpc_L_negate_out),
		.in6(Int_qlpc_L_negate_out),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_L_negate_out),.in29(0),.in30(0),.in31(0),.in32(0),.in33(Pred_lt_3_L_negate_out),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(ACELP_Codebook_L_negate_out),.in39(0),.in40(0),.in41(TL_Math5_L_negate_out),.in42(Corr_xy2_L_negate_out),
		.in43(Qua_gain_L_negate_out),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_negate_a));			

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		L_shl
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [31:0] L_shl_a;
	wire [15:0] L_shl_b;
	wire L_shl_start;

	
	L_shl i_L_shl_1(
						.clk(clock),
						.reset(reset),
						.ready(L_shl_start),
						.overflow(L_shl_overflow),
						.var1(L_shl_a),
						.numShift(L_shl_b),
						.done(L_shl_done),
						.out(L_shl_out));						

	mux128_32 i_mux128_32_L_shl_a(
											.in0(autocorr_L_shlVar1Out),
											.in1(lag_zero32),
											.in2(levinson_L_shl_outa),
											.in3(Az_L_shlVar1Out),
											.in4(Qua_lsp_L_shlOutVar1),.in5(Int_lpc_L_shlOutVar1),
		.in6(Int_qlpc_L_shlOutVar1),.in7(0),.in8(0),.in9(0),.in10(0),.in11(Residu_L_shlOutVar1),.in12(Syn_filt_L_shlOutVar1),.in13(0),.in14(0),.in15(Residu_L_shlOutVar1),
		.in16(Syn_filt_L_shlOutVar1),.in17(Pitch_ol_L_shlOutVar1),.in18(0),.in19(0),.in20(0),.in21(0),.in22(Syn_filt_L_shlOutVar1),.in23(Syn_filt_L_shlOutVar1),.in24(Residu_L_shlOutVar1),
		.in25(Syn_filt_L_shlOutVar1),.in26(Residu_L_shlOutVar1),.in27(Syn_filt_L_shlOutVar1),.in28(Pitch_fr3_L_shlOutVar1),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(Convolve_L_shlOutVar1),.in35(G_pitch_L_shlOutVar1),.in36(0),.in37(TL_Math4_L_shlOutVar1),.in38(0),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_L_shlOutVar1),
		.in43(Qua_gain_L_shlOutVar1),.in44(TL_Math6_L_shlOutVar1),.in45(update_exc_err_L_shlOutVar1),.in46(Syn_filt_L_shlOutVar1),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_shl_a));
		
	mux128_16 i_mux128_16_L_shl_b(
											.in0(autocorr_L_shlNumShiftOut),
											.in1(lag_zero16),
											.in2(levinson_L_shl_outb),
											.in3(Az_L_shlNumShiftOut),
											.in4(Qua_lsp_L_shlNumShiftOut),.in5(Int_lpc_L_shlNumShiftOut),
		.in6(Int_qlpc_L_shlNumShiftOut),.in7(0),.in8(0),.in9(0),.in10(0),.in11(Residu_L_shlNumShiftOut),.in12(Syn_filt_L_shlNumShiftOut),.in13(0),.in14(0),.in15(Residu_L_shlNumShiftOut),
		.in16(Syn_filt_L_shlNumShiftOut),.in17(Pitch_ol_L_shlNumShiftOut),.in18(0),.in19(0),.in20(0),.in21(0),.in22(Syn_filt_L_shlNumShiftOut),.in23(Syn_filt_L_shlNumShiftOut),.in24(Residu_L_shlNumShiftOut),
		.in25(Syn_filt_L_shlNumShiftOut),.in26(Residu_L_shlNumShiftOut),.in27(Syn_filt_L_shlNumShiftOut),.in28(Pitch_fr3_L_shlNumShiftOut),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(Convolve_L_shlNumShiftOut),.in35(G_pitch_L_shlNumShiftOut),.in36(0),.in37(TL_Math4_L_shlNumShiftOut),.in38(0),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_L_shlNumShiftOut),
		.in43(Qua_gain_L_shlNumShiftOut),.in44(TL_Math6_L_shlNumShiftOut),.in45(update_exc_err_L_shlNumShiftOut),.in46(Syn_filt_L_shlNumShiftOut),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_shl_b));
		
	mux128_1 i_mux128_1_L_shl_start(
												.in0(autocorr_L_shlReady),
												.in1(lag_zero),
												.in2(levinson_L_shl_start),
												.in3(Az_L_shlReady),
												.in4(Qua_lsp_L_shlReady),.in5(Int_lpc_L_shlReady),
		.in6(Int_qlpc_L_shlReady),.in7(Pitch_ol_L_shlReady),.in8(0),.in9(0),.in10(0),.in11(Residu_L_shlReady),.in12(Syn_filt_L_shlReady),.in13(0),.in14(0),.in15(Residu_L_shlReady),
		.in16(Syn_filt_L_shlReady),.in17(Pitch_ol_L_shlReady),.in18(0),.in19(0),.in20(0),.in21(0),.in22(Syn_filt_L_shlReady),.in23(Syn_filt_L_shlReady),.in24(Residu_L_shlReady),
		.in25(Syn_filt_L_shlReady),.in26(Residu_L_shlReady),.in27(Syn_filt_L_shlReady),.in28(Pitch_fr3_L_shlReady),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(Convolve_L_shlReady),.in35(G_pitch_L_shlReady),.in36(0),.in37(TL_Math4_L_shlReady),.in38(0),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_L_shlReady),
		.in43(Qua_gain_L_shlReady),.in44(TL_Math6_L_shlReady),.in45(update_exc_err_L_shlReady),.in46(Syn_filt_L_shlReady),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_shl_start));
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		L_shr
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [31:0] L_shr_a;
	wire [15:0] L_shr_b;

	L_shr i_L_shr_1(
						.var1(L_shr_a),
						.numShift(L_shr_b),
						.overflow(L_shr_overflow),
						.out(L_shr_out));		
						
	mux128_32 i_mux128_32_L_shr_a(
											.in0(autocorr_L_shrVar1Out),
											.in1(lag_L_shrOutVar1),
											.in2(levinson_L_shr_outa),
											.in3(Az_L_shrOutVar1),
											.in4(Qua_lsp_L_shrVar1Out),.in5(Int_lpc_L_shrVar1Out),
		.in6(Int_qlpc_L_shrVar1Out),.in7(0),.in8(perc_var_L_shrVar1Out),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(Pitch_ol_L_shrVar1Out),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_L_shrVar1Out),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(ACELP_Codebook_L_shrVar1Out),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(Qua_gain_L_shrVar1Out),.in44(0),.in45(update_exc_err_L_shrVar1Out),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_shr_a));
		
	mux128_16 i_mux128_16_L_shr_b(
											.in0(autocorr_L_shrNumShiftOut),
											.in1(lag_L_shrOutNumShift),
											.in2(levinson_L_shr_outb),
											.in3(Az_L_shrOutNumShift),
											.in4(Qua_lsp_L_shrNumShiftOut),.in5(Int_lpc_L_shrNumShiftOut),
		.in6(Int_qlpc_L_shrNumShiftOut),.in7(0),.in8(perc_var_L_shrNumShiftOut),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(Pitch_ol_L_shrNumShiftOut),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_L_shrNumShiftOut),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(ACELP_Codebook_L_shrNumShiftOut),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(Qua_gain_L_shrNumShiftOut),.in44(0),.in45(update_exc_err_L_shrNumShiftOut),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_shr_b));		

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		L_sub
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [31:0] L_sub_a,L_sub_b;
	
	L_sub i_L_sub_1(
						.a(L_sub_a),
						.b(L_sub_b),
						.overflow(L_sub_overflow),
						.diff(L_sub_out)
						);

		
	mux128_32 i_mux128_32_L_sub_a(
											.in0(autocorr_zero32),
											.in1(lag_zero32),
											.in2(levinson_L_sub_outa),
											.in3(Az_L_subOutA),
											.in4(Qua_lsp_L_subOutA),.in5(Int_lpc_L_subOutA),
		.in6(Int_qlpc_L_subOutA),.in7(0),.in8(perc_var_L_subOutA),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(Pitch_ol_L_subOutA),.in18(TL_Math2_L_subOutA),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_L_subOutA),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(Convolve_L_subOutA),.in35(G_pitch_L_subOutA),.in36(test_err_L_subOutA),.in37(0),.in38(ACELP_Codebook_L_subOutA),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(Qua_gain_L_subOutA),.in44(0),.in45(update_exc_err_L_subOutA),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_sub_a));
		
	mux128_32 i_mux128_32_L_sub_b(
											.in0(autocorr_zero32),
											.in1(lag_zero32),
											.in2(levinson_L_sub_outb),
											.in3(Az_L_subOutB),
											.in4(Qua_lsp_L_subOutB),.in5(Int_lpc_L_subOutB),
		.in6(Int_qlpc_L_subOutB),.in7(0),.in8(perc_var_L_subOutB),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(Pitch_ol_L_subOutB),.in18(TL_Math2_L_subOutB),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_L_subOutB),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(Convolve_L_subOutB),.in35(G_pitch_L_subOutB),.in36(test_err_L_subOutB),.in37(0),.in38(ACELP_Codebook_L_subOutB),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(Qua_gain_L_subOutB),.in44(0),.in45(update_exc_err_L_subOutB),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_sub_b));
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		mult
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [15:0] mult_a,mult_b;
	reg multRout;	
	
	always@(*)
	begin
		case(mathMuxSel)
		'd0:		multRout = multRselOut;
		default:	multRout = 0;
		endcase
	end

	mult i_mult_1(
						.a(mult_a),
						.b(mult_b),
						.multRsel(multRout),
						.overflow(mult_overflow),
						.product(mult_out)
						);
	
	mux128_16 i_mux128_16_mult_a(
											.in0(autocorr_multOutA),
											.in1(lag_multOutA),
											.in2(levinson_mult_outa),
											.in3(Az_multOutA),
											.in4(Qua_lsp_multOutA),.in5(Int_lpc_multOutA),
			.in6(Int_qlpc_multOutA),.in7(0),.in8(perc_var_multOutA),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
			.in16(0),.in17(Pitch_ol_multOutA),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
			.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_multOutA),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
			.in34(0),.in35(0),.in36(0),.in37(0),.in38(ACELP_Codebook_multOutA),.in39(0),.in40(0),.in41(0),.in42(0),
			.in43(Qua_gain_multOutA),.in44(0),.in45(update_exc_err_multOutA),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
			.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
			.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
			.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
			.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
			.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
			.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
			.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
			.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
			.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(mult_a));
			
	mux128_16 i_mux128_16_mult_b(
											.in0(autocorr_multOutB),
											.in1(lag_multOutB),
											.in2(levinson_mult_outb),
											.in3(Az_multOutB),
											.in4(Qua_lsp_multOutB),.in5(Int_lpc_multOutB),
			.in6(Int_qlpc_multOutB),.in7(0),.in8(perc_var_multOutB),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
			.in16(0),.in17(Pitch_ol_multOutB),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
			.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_multOutB),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
			.in34(0),.in35(0),.in36(0),.in37(0),.in38(ACELP_Codebook_multOutB),.in39(0),.in40(0),.in41(0),.in42(0),
			.in43(Qua_gain_multOutB),.in44(0),.in45(update_exc_err_multOutB),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
			.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
			.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
			.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
			.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
			.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
			.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
			.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
			.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
			.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(mult_b));
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		norm_l
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [31:0] norm_l_a;
	wire norm_l_start;
	
	norm_l i_norm_l_1(
							.var1(norm_l_a),
							.norm(norm_l_out),
							.clk(clock),
							.ready(norm_l_start),
							.reset(reset||autocorr_norm_lReset),
							.done(norm_l_done)
							);

	mux128_32 i_mux128_32_norm_l_a(
											.in0(autocorr_norm_lVar1Out),
											.in1(lag_zero32),
											.in2(levinson_norm_L_out),
											.in3(Az_zero32),
											.in4(0),.in5(Int_lpc_norm_l_out),
		.in6(Int_qlpc_norm_l_out),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(Pitch_ol_norm_l_out),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_norm_l_out),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(G_pitch_norm_l_out),.in36(0),.in37(0),.in38(ACELP_Codebook_norm_l_out),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_norm_l_out),
		.in43(Qua_gain_norm_l_out),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(norm_l_a));
		
	mux128_1 i_mux128_1_norm_l_start(
												.in0(autocorr_norm_lReady),
												.in1(lag_zero),
												.in2(levinson_norm_L_start),
												.in3(Az_zero),
												.in4(0),.in5(Int_lpc_norm_l_start),
		.in6(Int_qlpc_norm_l_start),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(Pitch_ol_norm_l_start),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_norm_l_start),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(G_pitch_norm_l_start),.in36(0),.in37(0),.in38(ACELP_Codebook_norm_l_start),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_norm_l_start),
		.in43(Qua_gain_norm_l_start),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(norm_l_start));
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		norm_s
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [15:0] norm_s_a;
	wire norm_s_start;
	
	norm_s i_norm_s_1(
							.var1(norm_s_a),
							.norm(norm_s_out),
							.clk(clock),
							.ready(norm_s_start),
							.reset(reset),
							.done(norm_s_done)
							);
				
	mux128_16 i_mux128_16_norm_s_a(
												.in0(autocorr_zero16),
												.in1(lag_zero16),
												.in2(0),
												.in3(Az_norm_sOut),
												.in4(Qua_lsp_norm_sOut),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(norm_s_a));
		
		mux128_1 i_mux128_1_norm_s_start(
												.in0(autocorr_zero),
												.in1(lag_zero),
												.in2(0),
												.in3(Az_norm_sReady),
												.in4(Qua_lsp_norm_sReady),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(norm_s_start));
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		shl
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [15:0] shl_var1,shl_var2;
	
	shl i_shl_1shl(
						.var1(shl_var1),
						.var2(shl_var2),
						.overflow(shl_overflow),
						.result(shl_out)
						);
	
	mux128_16 i_mux128_16_shl_var1(
											.in0(autocorr_zero16),
											.in1(lag_zero16),
											.in2(0),
											.in3(Az_zero16),
											.in4(Qua_lsp_shlOutVar1),.in5(Int_lpc_shlOutVar1),
		.in6(0),.in7(0),.in8(perc_var_shlOutVar1),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(Pitch_ol_shlOutVar1),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(ACELP_Codebook_shlVar1Out),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(Qua_gain_shlVar1Out),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(shl_var1));
	
	mux128_16 i_mux128_16_shl_var2(
												.in0(autocorr_zero16),
												.in1(lag_zero16),
												.in2(0),
												.in3(Az_zer016),
												.in4(Qua_lsp_shlOutVar2),.in5(Int_lpc_shlOutVar2),
		.in6(0),.in7(0),.in8(perc_var_shlOutVar2),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(Pitch_ol_shlOutVar2),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(ACELP_Codebook_shlVar2Out),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(Qua_gain_shlVar2Out),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(shl_var2));

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		shr
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [15:0] shr_var1,shr_var2;
	
	shr i_shr_1shr(
						.var1(shr_var1),
						.var2(shr_var2),
						.overflow(shr_overflow),
						.result(shr_out)
						);
	
	mux128_16 i_mux128_16_shr_var1(
												.in0(autocorr_shrVar1Out),
												.in1(lag_zero16),
												.in2(0),
												.in3(Az_shrOutVar1),
												.in4(Qua_lsp_shrVar1Out),.in5(Int_lpc_shrVar1Out),
		.in6(Int_qlpc_shrVar1Out),.in7(0),.in8(perc_var_shrVar1Out),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(Pitch_ol_shrVar1Out),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_shrVar1Out),.in29(0),.in30(0),.in31(Parity_pitch_shrVar1Out),.in32(0),.in33(0),
		.in34(0),.in35(G_pitch_shrVar1Out),.in36(0),.in37(0),.in38(ACELP_Codebook_shrVar1Out),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_shrVar1Out),
		.in43(Qua_gain_shrVar1Out),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(shr_var1));
	
	mux128_16 i_mux128_16_shr_var2(
												.in0(autocorr_shrVar2Out),
												.in1(lag_zero16),
												.in2(0),
												.in3(Az_shrOutVar2),
												.in4(Qua_lsp_shrVar2Out),.in5(Int_lpc_shrVar2Out),
		.in6(Int_qlpc_shrVar2Out),.in7(0),.in8(perc_var_shrVar2Out),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(Pitch_ol_shrVar2Out),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_shrVar2Out),.in29(0),.in30(0),.in31(Parity_pitch_shrVar2Out),.in32(0),.in33(0),
		.in34(0),.in35(G_pitch_shrVar2Out),.in36(0),.in37(0),.in38(ACELP_Codebook_shrVar2Out),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_shrVar2Out),
		.in43(Qua_gain_shrVar2Out),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(shr_var2));
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		sub
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [15:0] sub_a,sub_b;
	
	sub i_sub_1(
					.a(sub_a),
					.b(sub_b),
					.overflow(sub_overflow),
					.diff(sub_out)
					);

	mux128_16 i_mux128_16_sub_a(
											.in0(autocorr_subOutA),
											.in1(lag_zero16),
											.in2(levinson_sub_outa),
											.in3(Az_subOutA),
											.in4(Qua_lsp_subOutA),.in5(Int_lpc_subOutA),
		.in6(Int_qlpc_subOutA),.in7(0),.in8(perc_var_subOutA),.in9(0),.in10(0),.in11(Residu_subOutA),.in12(Syn_filt_subOutA),.in13(0),.in14(0),.in15(Residu_subOutA),
		.in16(Syn_filt_subOutA),.in17(Pitch_ol_subOutA),.in18(TL_Math2_subOutA),.in19(0),.in20(0),.in21(0),.in22(Syn_filt_subOutA),.in23(Syn_filt_subOutA),.in24(Residu_subOutA),
		.in25(Syn_filt_subOutA),.in26(Residu_subOutA),.in27(Syn_filt_subOutA),.in28(Pitch_fr3_subOutA),.in29(Enc_lag3_subOutA),.in30(0),.in31(0),.in32(0),.in33(Pred_lt_3_subOutA),
		.in34(0),.in35(G_pitch_subOutA),.in36(test_err_subOutA),.in37(TL_Math4_subOutA),.in38(ACELP_Codebook_subOutA),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_subOutA),
		.in43(Qua_gain_subOutA),.in44(TL_Math6_subOutA),.in45(update_exc_err_subOutA),.in46(Syn_filt_subOutA),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(sub_a));
	
	mux128_16 i_mux128_16_sub_b(
											.in0(autocorr_subOutB),
											.in1(lag_zero16),
											.in2(levinson_sub_outb),
											.in3(Az_subOutB),
											.in4(Qua_lsp_subOutB),.in5(Int_lpc_subOutB),
		.in6(Int_qlpc_subOutB),.in7(0),.in8(perc_var_subOutB),.in9(0),.in10(0),.in11(Residu_subOutB),.in12(Syn_filt_subOutB),.in13(0),.in14(0),.in15(Residu_subOutB),
		.in16(Syn_filt_subOutB),.in17(Pitch_ol_subOutB),.in18(TL_Math2_subOutB),.in19(0),.in20(0),.in21(0),.in22(Syn_filt_subOutB),.in23(Syn_filt_subOutB),.in24(Residu_subOutB),
		.in25(Syn_filt_subOutB),.in26(Residu_subOutB),.in27(Syn_filt_subOutB),.in28(Pitch_fr3_subOutB),.in29(Enc_lag3_subOutB),.in30(0),.in31(0),.in32(0),.in33(Pred_lt_3_subOutB),
		.in34(0),.in35(G_pitch_subOutB),.in36(test_err_subOutB),.in37(TL_Math4_subOutB),.in38(ACELP_Codebook_subOutB),.in39(0),.in40(0),.in41(0),.in42(Corr_xy2_subOutB),
		.in43(Qua_gain_subOutB),.in44(TL_Math6_subOutB),.in45(update_exc_err_subOutB),.in46(Syn_filt_subOutB),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(sub_b));		
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Scratch Memory
	//
	//////////////////////////////////////////////////////////////////////////////////////////////	
		wire [11:0] addra;
		wire [31:0] dina;
		wire wea;
		wire [11:0] addrb;
		
		Scratch_Memory_Controller scratch_mem(
															.addra(addra),
															.dina(dina),
															.wea(wea),
															.clk(clock),
															.addrb(addrb),
															.doutb(memOut)
															);
		mux128_12 i_mux128_12_scratch_addra(
														.in0(autocorrScratchWriteRequested),
														.in1(lag_scratchWriteRequested),
														.in2(levinson_scratch_mem_write_addr),
														.in3(Az_scratchWriteRequested),
														.in4(Qua_lsp_memWriteAddr),.in5(Int_lpc_memWriteAddr),
		.in6(Int_qlpc_memWriteAddr),.in7(Math1_memWriteAddr),.in8(perc_var_memWriteAddr),.in9(Weight_Az_memWriteAddr),.in10(Weight_Az_memWriteAddr),.in11(Residu_memWriteAddr),.in12(Syn_filt_memWriteAddr),.in13(Weight_Az_memWriteAddr),.in14(Weight_Az_memWriteAddr),.in15(Residu_memWriteAddr),
		.in16(Syn_filt_memWriteAddr),.in17(Pitch_ol_memWriteAddr),.in18(0),.in19(Weight_Az_memWriteAddr),.in20(Weight_Az_memWriteAddr),.in21(TL_Math3_memWriteAddr),.in22(Syn_filt_memWriteAddr),.in23(Syn_filt_memWriteAddr),.in24(Residu_memWriteAddr),
		.in25(Syn_filt_memWriteAddr),.in26(Residu_memWriteAddr),.in27(Syn_filt_memWriteAddr),.in28(Pitch_fr3_memWriteAddr),.in29(Enc_lag3_memWriteAddr),.in30(LOAD_ANA_2_7_Addr),.in31(PRM+'d3),.in32(0),.in33(Pred_lt_3_memWriteAddr),
		.in34(Convolve_memWriteAddr),.in35(G_pitch_memWriteAddr),.in36(test_err_memWriteAddr),.in37(TL_Math4_memWriteAddr),.in38(ACELP_Codebook_memWriteAddr),.in39(LOAD_ANA_4_8_Addr),.in40(LOAD_ANA_5_9_Addr),.in41(TL_Math5_memWriteAddr),.in42(Corr_xy2_memWriteAddr),
		.in43(Qua_gain_memWriteAddr),.in44(TL_Math6_memWriteAddr),.in45(update_exc_err_memWriteAddr),.in46(Syn_filt_memWriteAddr),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addra));
		
		mux128_32 i_mux128_32_scratch_dina(
														.in0(autocorrScratchMemOut),
														.in1(lag_scratchMemOut),
														.in2(levinson_scratch_mem_out),
														.in3(Az_scratchMemOut),
														.in4(Qua_lsp_memIn),.in5(Int_lpc_memIn),
		.in6(Int_qlpc_memIn),.in7(Math1_memIn),.in8(perc_var_memIn),.in9(Weight_Az_memIn),.in10(Weight_Az_memIn),.in11(Residu_memIn),.in12(Syn_filt_memIn),.in13(Weight_Az_memIn),.in14(Weight_Az_memIn),.in15(Residu_memIn),
		.in16(Syn_filt_memIn),.in17(Pitch_ol_memIn),.in18(0),.in19(Weight_Az_memIn),.in20(Weight_Az_memIn),.in21(TL_Math3_memIn),.in22(Syn_filt_memIn),.in23(Syn_filt_memIn),.in24(Residu_memIn),
		.in25(Syn_filt_memIn),.in26(Residu_memIn),.in27(Syn_filt_memIn),.in28(Pitch_fr3_memIn),.in29(Enc_lag3_memIn),.in30(LOAD_ANA_2_7_Data),.in31(Parity_pitch_sum_Data),.in32(0),.in33(Pred_lt_3_memIn),
		.in34(Convolve_memIn),.in35(G_pitch_memIn),.in36(test_err_memIn),.in37(TL_Math4_memIn),.in38(ACELP_Codebook_memIn),.in39(LOAD_ANA_4_8_Data),.in40(LOAD_ANA_5_9_Data),.in41(TL_Math5_memIn),.in42(Corr_xy2_memIn),
		.in43(Qua_gain_memIn),.in44(TL_Math6_memIn),.in45(update_exc_err_memIn),.in46(Syn_filt_memIn),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(dina));
		
		mux128_1 i_mux128_1_scratch_wea(
														.in0(autocorrScratchWriteEn),
														.in1(lag_scratchWriteEn),
														.in2(levinson_scratch_mem_write_en),
														.in3(Az_scratchWriteEn),
														.in4(Qua_lsp_memWriteEn),.in5(Int_lpc_memWriteEn),
		.in6(Int_qlpc_memWriteEn),.in7(Math1_memWriteEn),.in8(perc_var_memWriteEn),.in9(Weight_Az_memWriteEn),.in10(Weight_Az_memWriteEn),.in11(Residu_memWriteEn),.in12(Syn_filt_memWriteEn),.in13(Weight_Az_memWriteEn),.in14(Weight_Az_memWriteEn),.in15(Residu_memWriteEn),
		.in16(Syn_filt_memWriteEn),.in17(Pitch_ol_memWriteEn),.in18(0),.in19(Weight_Az_memWriteEn),.in20(Weight_Az_memWriteEn),.in21(TL_Math3_memWriteEn),.in22(Syn_filt_memWriteEn),.in23(Syn_filt_memWriteEn),.in24(Residu_memWriteEn),
		.in25(Syn_filt_memWriteEn),.in26(Residu_memWriteEn),.in27(Syn_filt_memWriteEn),.in28(Pitch_fr3_memWriteEn),.in29(Enc_lag3_memWriteEn),.in30('d1),.in31(Parity_PitchDone&'d1),.in32(0),.in33(Pred_lt_3_memWriteEn),
		.in34(Convolve_memWriteEn),.in35(G_pitch_memWriteEn),.in36(test_err_memWriteEn),.in37(TL_Math4_memWriteEn),.in38(ACELP_Codebook_memWriteEn),.in39('d1),.in40('d1),.in41(TL_Math5_memWriteEn),.in42(Corr_xy2_memWriteEn),
		.in43(Qua_gain_memWriteEn),.in44(TL_Math6_memWriteEn),.in45(update_exc_err_memWriteEn),.in46(Syn_filt_memWriteEn),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(wea));
		
		mux128_12 i_mux128_12_scratch_addrb(
														.in0(autocorrScratchReadRequested),
														.in1(lag_scratchReadRequested),
														.in2(levinson_scratch_mem_read_addr),
														.in3(Az_scratchReadRequested),
														.in4(Qua_lsp_memReadAddr),.in5(Int_lpc_memReadAddr),
		.in6(Int_qlpc_memReadAddr),.in7(Math1_memReadAddr),.in8(perc_var_memReadAddr),.in9(Weight_Az_memReadAddr),.in10(Weight_Az_memReadAddr),.in11(Residu_memReadAddr),.in12(Syn_filt_memReadAddr),.in13(Weight_Az_memReadAddr),.in14(Weight_Az_memReadAddr),.in15(Residu_memReadAddr),
		.in16(Syn_filt_memReadAddr),.in17(Pitch_ol_memReadAddr),.in18(0),.in19(Weight_Az_memReadAddr),.in20(Weight_Az_memReadAddr),.in21(TL_Math3_memReadAddr),.in22(Syn_filt_memReadAddr),.in23(Syn_filt_memReadAddr),.in24(Residu_memReadAddr),
		.in25(Syn_filt_memReadAddr),.in26(Residu_memSameAddr),.in27(Syn_filt_memReadAddr),.in28(Pitch_fr3_memReadAddr),.in29(Enc_lag3_memReadAddr),.in30(0),.in31(0),.in32(0),.in33(Pred_lt_3_memReadAddr),
		.in34(Convolve_memWriteAddr),.in35(G_pitch_memReadAddr),.in36(test_err_memReadAddr),.in37(TL_Math4_memReadAddr),.in38(ACELP_Codebook_memReadAddr),.in39(0),.in40(0),.in41(TL_Math5_memReadAddr),.in42(Corr_xy2_memReadAddr),
		.in43(Qua_gain_memReadAddr),.in44(TL_Math6_memReadAddr),.in45(update_exc_err_memReadAddr),.in46(Syn_filt_memReadAddr),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addrb));
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Constants Memory
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	wire [11:0] constantMemAddr;
	
	Constant_Memory_Controller constantMem(
														.addra(constantMemAddr),
														.dina(32'd0),
														.wea(1'd0),
														.clock(clock),
														.douta(constantMemOut)
														);
	mux128_12 i_mux128_12_constantMemAddr(
														.in0(12'd0),	//Autocorr
														.in1(12'd0),	//Lag Window
														.in2(12'd0),	//Levinson-Durbin
														.in3(12'd0),	//Az to LSP
														.in4(Qua_lsp_constantMemAddr),.in5(Int_lpc_constantMemAddr),
		.in6(Int_qlpc_constantMemAddr),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
		.in16(0),.in17(Pitch_ol_constantMemAddr),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(Pitch_fr3_constantMemAddr),.in29(0),.in30(0),.in31(0),.in32(0),.in33(Pred_lt_3_constantMemAddr),
		.in34(0),.in35(0),.in36(test_err_constantMemAddr),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(Qua_gain_constantMemAddr),.in44(0),.in45(update_exc_err_constantMemAddr),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(constantMemAddr));								
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Pre-Processor
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

		//high pass filter
		g729_hpfilter pre_proc (
									.clk(clock), 
									.reset(reset), 
									.xn(xn), 
									.ready(preProcReady), 
									.yn(yn), 
									.done(preProcDone)
								);
		//pre-proc/autocorr memory
		LPC_Mem_Ctrl pre_proc_mem (
											.clock(clock), 
											.reset(reset), 
											.In_Done(preProcDone), 
											.In_Sample(yn), 
											.Out_Count(preProcMemReadAddr), 
											.Out_Sample(speechIn), 
											.frame_done(frame_done)
											);
			//pre-proc/autocorr memory read address mux	
		mux128_11 i_mux128_11_pre_proc_mem_addr(
														.in0(autocorrRequested),
														.in1(autocorrRequested),
														.in2(autocorrRequested),
														.in3(autocorrRequested),
														.in4(autocorrRequested),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(Residu_speechAddr),.in12(0),.in13(0),.in14(0),.in15(Residu_speechAddr),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(Residu_speechAddr),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(preProcMemReadAddr)
															);
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Autocorellation
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

			autocorrFSM autocorr(
										 .clk(clock),
										 .reset(reset),
										 .ready(autocorrReady),
										 .xIn(speechIn),
										 .memIn(memOut),
										 .L_shlDone(L_shl_done),
										 .norm_lDone(norm_l_done),
										 .L_shlIn(L_shl_out),
										 .L_shrIn(L_shr_out),
										 .shrIn(shr_out),
										 .addIn(add_out),
										 .subIn(sub_out),
										 .overflow(L_mac_overflow),
										 .norm_lIn(norm_l_out),										 
										 .multIn(mult_out),
										 .L_macIn(L_mac_out),
										 .L_msuIn(L_msu_out),		 
										 .L_macOutA(autocorr_L_macOutA),
										 .L_macOutB(autocorr_L_macOutB),
										 .L_macOutC(autocorr_L_macOutC),
										 .L_msuOutA(autocorr_L_msuOutA),
										 .L_msuOutB(autocorr_L_msuOutB),
										 .L_msuOutC(autocorr_L_msuOutC),
										 .norm_lVar1Out(autocorr_norm_lVar1Out),
										 .multOutA(autocorr_multOutA),
										 .multOutB(autocorr_multOutB),
										 .multRselOut(multRselOut),
										 .L_shlReady(autocorr_L_shlReady),
										 .L_shlVar1Out(autocorr_L_shlVar1Out),
										 .L_shlNumShiftOut(autocorr_L_shlNumShiftOut),
										 .L_shrVar1Out(autocorr_L_shrVar1Out),
										 .L_shrNumShiftOut(autocorr_L_shrNumShiftOut),
										 .shrVar1Out(autocorr_shrVar1Out),
										 .shrVar2Out(autocorr_shrVar2Out),
										 .addOutA(autocorr_addOutA),
										 .addOutB(autocorr_addOutB),
										 .subOutA(autocorr_subOutA),
										 .subOutB(autocorr_subOutB),		
										 .norm_lReady(autocorr_norm_lReady),
										 .norm_lReset(autocorr_norm_lReset),
										 .writeEn(autocorrScratchWriteEn),
										 .xRequested(autocorrRequested),						 
										 .readRequested(autocorrScratchReadRequested),
										 .writeRequested(autocorrScratchWriteRequested),
										 .memOut(autocorrScratchMemOut),						 
										 .done(autocorrDone)
										 );			 
										 
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Lag-Window
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
		lag_window lagwindow (		
									.clk(clock), 
									.reset(reset), 
									.start(lagReady), 
									.rPrimeIn(memOut),
									.L_multIn(L_mult_out), 
									.multIn(mult_out), 
									.L_macIn(L_mac_out),
									.L_msuIn(L_msu_out), 
									.addIn(add_out),
									.L_shrIn(L_shr_out),		
									.rPrimeWrite(lag_scratchWriteEn), 
									.rPrimeRequested(lag_scratchWriteRequested), 
									.rPrimeReadAddr(lag_scratchReadRequested),
									.L_multOutA(lag_L_multOutA), 
									.L_multOutB(lag_L_multOutB), 
									.multOutA(lag_multOutA),
									.multOutB(lag_multOutB), 
									.L_macOutA(lag_L_macOutA), 
									.L_macOutB(lag_L_macOutB), 
									.L_macOutC(lag_L_macOutC),
									.L_msuOutA(lag_L_msuOutA), 
									.L_msuOutB(lag_L_msuOutB), 
									.L_msuOutC(lag_L_msuOutC), 		
									.rPrimeOut(lag_scratchMemOut), 
									.addOutA(lag_addOutA),
									.addOutB(lag_addOutB),
									.L_shrOutVar1(lag_L_shrOutVar1),
									.L_shrOutNumShift(lag_L_shrOutNumShift),
									.done(lagDone)
									);
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Levinson-Durbin
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

	Levinson_Durbin_FSM levinson(
											.clock(clock), 
											.reset(reset), 
											.start(levinsonReady), 
											.done(levinsonDone),
											.abs_in(L_abs_out),
											.abs_out(levinson_abs_out), 
											.negate_out(levinson_negate_out), 
											.negate_in(L_negate_out),
											.L_shr_outa(levinson_L_shr_outa), 
											.L_shr_outb(levinson_L_shr_outb),
											.L_shr_in(L_shr_out), 
											.L_sub_outa(levinson_L_sub_outa), 
											.L_sub_outb(levinson_L_sub_outb), 
											.L_sub_in(L_sub_out), 
											.norm_L_out(levinson_norm_L_out),	
											.norm_L_in(norm_l_out),
											.norm_L_start(levinson_norm_L_start),	
											.norm_L_done(norm_l_done),
											.L_shl_outa(levinson_L_shl_outa), 
											.L_shl_outb(levinson_L_shl_outb),										
											.L_shl_in(L_shl_out),
											.L_shl_start(levinson_L_shl_start),	
											.L_shl_done(L_shl_done), 
											.L_mult_outa(levinson_L_mult_outa),
											.L_mult_outb(levinson_L_mult_outb),	
											.L_mult_in(L_mult_out),
											.L_mult_overflow(L_mult_overflow),
											.L_mac_outa(levinson_L_mac_outa), 
											.L_mac_outb(levinson_L_mac_outb), 
											.L_mac_outc(levinson_L_mac_outc),	
											.L_mac_in(L_mac_out), 
											.L_mac_overflow(L_mac_overflow),	
											.mult_outa(levinson_mult_outa), 
											.mult_outb(levinson_mult_outb),
											.mult_in(mult_out),
											.mult_overflow(mult_overflow),
											.L_add_outa(levinson_L_add_outa),
											.L_add_outb(levinson_L_add_outb),	
											.L_add_overflow(L_add_overflow),
											.L_add_in(L_add_out),
											.sub_outa(levinson_sub_outa),
											.sub_outb(levinson_sub_outb),
											.sub_overflow(sub_overflow),
											.sub_in(sub_out),
											.scratch_mem_in(memOut),	 										
											.scratch_mem_read_addr(levinson_scratch_mem_read_addr),
											.scratch_mem_write_addr(levinson_scratch_mem_write_addr),
											.scratch_mem_out(levinson_scratch_mem_out),
											.scratch_mem_write_en(levinson_scratch_mem_write_en),											
											.add_outa(levinson_add_outa),
											.add_outb(levinson_add_outb),
											.add_overflow(add_overflow),
											.add_in(add_out)										
										);	
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		A(Z) to LSP
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
		Az_toLSP_FSM AzToLSP (
									.clk(clock), 
									.reset(reset), 
									.start(AzReady),									
									.addIn(add_out), 
									.subIn(sub_out),
									.shrIn(shr_out),
									.L_shrIn(L_shr_out),
									.L_addIn(L_add_out),
									.L_subIn(L_sub_out), 
									.multIn(mult_out), 
									.L_multIn(L_mult_out), 
									.L_macIn(L_mac_out), 
									.L_msuIn(L_msu_out), 
									.L_shlIn(L_shl_out), 									
									.L_shlDone(L_shl_done), 
									.norm_sIn(norm_s_out), 
									.norm_sDone(norm_s_done),									
									.lspIn(memOut), 				
									.addOutA(Az_addOutA), 
									.addOutB(Az_addOutB), 
									.subOutA(Az_subOutA),
									.subOutB(Az_subOutB),
									.shrOutVar1(Az_shrOutVar1),
									.shrOutVar2(Az_shrOutVar2),
									.L_shrOutVar1(Az_L_shrOutVar1),
									.L_shrOutNumShift(Az_L_shrOutNumShift),
									.L_addOutA(Az_L_addOutA), 
									.L_addOutB(Az_L_addOutB), 
									.L_subOutA(Az_L_subOutA), 
									.L_subOutB(Az_L_subOutB), 
									.multOutA(Az_multOutA), 
									.multOutB(Az_multOutB), 
									.L_multOutA(Az_L_multOutA), 
									.L_multOutB(Az_L_multOutB), 
									.L_multOverflow(L_mult_overflow), 
									.L_macOutA(Az_L_macOutA),
									.L_macOutB(Az_L_macOutB), 
									.L_macOutC(Az_L_macOutC), 
									.L_macOverflow(L_mac_overflow), 
									.L_msuOutA(Az_L_msuOutA), 
									.L_msuOutB(Az_L_msuOutB), 
									.L_msuOutC(Az_L_msuOutC), 
									.L_msuOverflow(L_msu_overflow), 
									.L_shlVar1Out(Az_L_shlVar1Out), 
									.L_shlNumShiftOut(Az_L_shlNumShiftOut), 
									.L_shlReady(Az_L_shlReady), 
									.norm_sOut(Az_norm_sOut), 
									.norm_sReady(Az_norm_sReady), 
									.lspWriteRequested(Az_scratchWriteRequested), 
									.lspReadRequested(Az_scratchReadRequested), 
									.lspOut(Az_scratchMemOut), 
									.lspWrite(Az_scratchWriteEn), 
									.divErr(Az_divErr),
									.done(AzDone)
								);
								
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Qua_lsp
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
		Qua_lsp_FSM Qua_lsp (
							.clk(clock), 
							.reset(reset), 
							.start(Qua_lspReady), 
							.L_addIn(L_add_out), 
							.L_subIn(L_sub_out), 
							.L_multIn(L_mult_out), 
							.L_macIn(L_mac_out), 
							.addIn(add_out), 
							.subIn(sub_out),  
							.shrIn(shr_out), 
							.memIn(memOut), 
							.constantMemIn(constantMemOut), 
							.L_addOutA(Qua_lsp_L_addOutA), 
							.L_addOutB(Qua_lsp_L_addOutB), 
							.L_subOutA(Qua_lsp_L_subOutA), 
							.L_subOutB(Qua_lsp_L_subOutB), 
							.L_multOutA(Qua_lsp_L_multOutA), 
							.L_multOutB(Qua_lsp_L_multOutB), 
							.L_macOutA(Qua_lsp_L_macOutA), 
							.L_macOutB(Qua_lsp_L_macOutB), 
							.L_macOutC(Qua_lsp_L_macOutC), 
							.addOutA(Qua_lsp_addOutA), 
							.addOutB(Qua_lsp_addOutB), 
							.subOutA(Qua_lsp_subOutA), 
							.subOutB(Qua_lsp_subOutB), 
							.shrVar1Out(Qua_lsp_shrVar1Out), 
							.shrVar2Out(Qua_lsp_shrVar2Out), 
							.L_msuOutA(Qua_lsp_L_msuOutA), 
							.L_msuOutB(Qua_lsp_L_msuOutB), 
							.L_msuOutC(Qua_lsp_L_msuOutC), 
							.L_msuIn(L_msu_out),
							.L_shlIn(L_shl_out), 
							.L_shlOutVar1(Qua_lsp_L_shlOutVar1), 
							.L_shlReady(Qua_lsp_L_shlReady), 
							.L_shlDone(L_shl_done), 
							.L_shlNumShiftOut(Qua_lsp_L_shlNumShiftOut), 
							.multOutA(Qua_lsp_multOutA), 
							.multOutB(Qua_lsp_multOutB), 
							.memOut(Qua_lsp_memIn), 
							.multIn(mult_out), 
							.memReadAddr(Qua_lsp_memReadAddr), 
							.memWriteAddr(Qua_lsp_memWriteAddr), 
							.memWriteEn(Qua_lsp_memWriteEn), 
							.constantMemAddr(Qua_lsp_constantMemAddr), 
							.done(Qua_lspDone),
							.lsp_qAddr(LSP_NEW_Q), 
							.shlOutVar1(Qua_lsp_shlOutVar1), 
							.shlOutVar2(Qua_lsp_shlOutVar2), 
							.shlIn(shl_out), 
							.norm_sIn(norm_s_out), 
							.norm_sDone(norm_s_done), 
							.L_shrIn(L_shr_out),
							.norm_sOut(Qua_lsp_norm_sOut), 
							.norm_sReady(Qua_lsp_norm_sReady), 
							.lspAddr(LSP_NEW), 
							.anaAddr(PRM),
							.freq_prevAddr(FREQ_PREV),
							.L_shrVar1Out(Qua_lsp_L_shrVar1Out), 
							.L_shrNumShiftOut(Qua_lsp_L_shrNumShiftOut)
						);
						
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Int_lpc
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
		int_lpc Int_lpc(
							.clock(clock),
							.reset(reset),
							.done(Int_lpcDone),
							.start(Int_lpcReady),
							.scratch_mem_write_addr(Int_lpc_memWriteAddr),
							.scratch_mem_out(Int_lpc_memIn),
							.scratch_mem_write_en(Int_lpc_memWriteEn),
							.scratch_mem_read_addr(Int_lpc_memReadAddr),
							.scratch_mem_in(memOut),
							.constant_mem_read_addr(Int_lpc_constantMemAddr),
							.constant_mem_in(constantMemOut),
							.abs_out(Int_lpc_L_abs_out),
							.abs_in(L_abs_out),
							.negate_out(Int_lpc_L_negate_out),
							.negate_in(L_negate_out),
							.L_sub_outa(Int_lpc_L_subOutA),
							.L_sub_outb(Int_lpc_L_subOutB),
							.L_sub_in(L_sub_out),
							.L_shr_outa(Int_lpc_L_shrVar1Out),
							.L_shr_outb(Int_lpc_L_shrNumShiftOut),
							.L_shr_in(L_shr_out),
							.norm_L_out(Int_lpc_norm_l_out),
							.norm_L_in(norm_l_out),
							.norm_L_start(Int_lpc_norm_l_start),
							.norm_L_done(norm_l_done),
							.L_shl_outa(Int_lpc_L_shlOutVar1),
							.L_shl_outb(Int_lpc_L_shlNumShiftOut),
							.L_shl_in(L_shl_out),
							.L_shl_start(Int_lpc_L_shlReady),
							.L_shl_done(L_shl_done),
							.L_mult_outa(Int_lpc_L_multOutA),
							.L_mult_outb(Int_lpc_L_multOutB),
							.L_mult_in(L_mult_out),
							.L_mult_overflow(L_mult_overflow),
							.L_mac_outa(Int_lpc_L_macOutA),
							.L_mac_outb(Int_lpc_L_macOutB),
							.L_mac_outc(Int_lpc_L_macOutC),
							.L_mac_in(L_mac_out),
							.L_mac_overflow(L_mac_overflow),
							.mult_outa(Int_lpc_multOutA),
							.mult_outb(Int_lpc_multOutB),
							.mult_in(mult_out),
							.mult_overflow(mult_overflow),
							.L_add_outa(Int_lpc_L_addOutA),
							.L_add_outb(Int_lpc_L_addOutB),
							.L_add_overflow(L_add_overflow),
							.L_add_in(L_add_out),
							.add_outa(Int_lpc_addOutA),
							.add_outb(Int_lpc_addOutB),
							.add_overflow(add_overflow),
							.add_in(add_out),
							.sub_outa(Int_lpc_subOutA),
							.sub_outb(Int_lpc_subOutB),
							.sub_overflow(sub_overflow),
							.sub_in(sub_out),
							.L_msu_outa(Int_lpc_L_msuOutA),
							.L_msu_outb(Int_lpc_L_msuOutB),
							.L_msu_outc(Int_lpc_L_msuOutC),
							.L_msu_overflow(L_msu_overflow),
							.L_msu_in(L_msu_out),
							.shl_outa(Int_lpc_shlOutVar1),
							.shl_outb(Int_lpc_shlOutVar2),
							.shl_in(shl_out),
							.shl_overflow(shl_overflow),
							.shr_outa(Int_lpc_shrVar1Out),
							.shr_outb(Int_lpc_shrVar2Out),
							.shr_in(shr_out),
							.shr_overflow(shr_overflow)
						);
						
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Int_qlpc
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
		int_qlpc Int_qlpc(
							.clock(clock),
							.reset(reset),
							.done(Int_qlpcDone),
							.start(Int_qlpcReady),
							.scratch_mem_write_addr(Int_qlpc_memWriteAddr),
							.scratch_mem_out(Int_qlpc_memIn),
							.scratch_mem_write_en(Int_qlpc_memWriteEn),
							.scratch_mem_read_addr(Int_qlpc_memReadAddr),
							.scratch_mem_in(memOut),
							.constant_mem_read_addr(Int_qlpc_constantMemAddr),
							.constant_mem_in(constantMemOut),
							.abs_out(Int_qlpc_L_abs_out),
							.abs_in(L_abs_out),
							.negate_out(Int_qlpc_L_negate_out),
							.negate_in(L_negate_out),
							.L_sub_outa(Int_qlpc_L_subOutA),
							.L_sub_outb(Int_qlpc_L_subOutB),
							.L_sub_in(L_sub_out),
							.L_shr_outa(Int_qlpc_L_shrVar1Out),
							.L_shr_outb(Int_qlpc_L_shrNumShiftOut),
							.L_shr_in(L_shr_out),
							.norm_L_out(Int_qlpc_norm_l_out),
							.norm_L_in(norm_l_out),
							.norm_L_start(Int_qlpc_norm_l_start),
							.norm_L_done(norm_l_done),
							.L_shl_outa(Int_qlpc_L_shlOutVar1),
							.L_shl_outb(Int_qlpc_L_shlNumShiftOut),
							.L_shl_in(L_shl_out),
							.L_shl_start(Int_qlpc_L_shlReady),
							.L_shl_done(L_shl_done),
							.L_mult_outa(Int_qlpc_L_multOutA),
							.L_mult_outb(Int_qlpc_L_multOutB),
							.L_mult_in(L_mult_out),
							.L_mult_overflow(L_mult_overflow),
							.L_mac_outa(Int_qlpc_L_macOutA),
							.L_mac_outb(Int_qlpc_L_macOutB),
							.L_mac_outc(Int_qlpc_L_macOutC),
							.L_mac_in(L_mac_out),
							.L_mac_overflow(L_mac_overflow),
							.mult_outa(Int_qlpc_multOutA),
							.mult_outb(Int_qlpc_multOutB),
							.mult_in(mult_out),
							.mult_overflow(mult_overflow),
							.L_add_outa(Int_qlpc_L_addOutA),
							.L_add_outb(Int_qlpc_L_addOutB),
							.L_add_overflow(L_add_overflow),
							.L_add_in(L_add_out),
							.add_outa(Int_qlpc_addOutA),
							.add_outb(Int_qlpc_addOutB),
							.add_overflow(add_overflow),
							.add_in(add_out),
							.sub_outa(Int_qlpc_subOutA),
							.sub_outb(Int_qlpc_subOutB),
							.sub_overflow(sub_overflow),
							.sub_in(sub_out),
							.L_msu_outa(Int_qlpc_L_msuOutA),
							.L_msu_outb(Int_qlpc_L_msuOutB),
							.L_msu_outc(Int_qlpc_L_msuOutC),
							.L_msu_overflow(L_msu_overflow),
							.L_msu_in(L_msu_out),
							.shr_outa(Int_qlpc_shrVar1Out),
							.shr_outb(Int_qlpc_shrVar2Out),
							.shr_in(shr_out),
							.shr_overflow(shr_overflow)
					    );
						
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		TL_Math1
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

		TL_Math1 TL_Math1(
					.clock(clock),
					.reset(reset),
					.start(Math1Ready),
					.addIn(add_out),
					.memIn(memOut),
					.addOutA(Math1_addOutA),
					.addOutB(Math1_addOutB),
					.memWriteAddr(Math1_memWriteAddr),
					.memOut(Math1_memIn),
					.memWriteEn(Math1_memWriteEn),
					.memReadAddr(Math1_memReadAddr),
					.done(Math1Done)
				);
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		perc_var
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	    percVarFSM perc_var(
					.clk(clock),
					.reset(reset),
					.start(perc_varReady),
					.shlIn(shl_out),
					.shrIn(shr_out),
					.subIn(sub_out),
					.L_multIn(L_mult_out),
					.L_subIn(L_sub_out),
					.L_shrIn(L_shr_out),
					.L_addIn(L_add_out),
					.addIn(add_out),
					.multIn(mult_out),
					.memIn(memOut),
					.shlVar1Out(perc_var_shlOutVar1),
					.shlVar2Out(perc_var_shlOutVar2),
					.shrVar1Out(perc_var_shrVar1Out),
					.shrVar2Out(perc_var_shrVar2Out),
					.subOutA(perc_var_subOutA),
					.subOutB(perc_var_subOutB),
					.L_multOutA(perc_var_L_multOutA),
					.L_multOutB(perc_var_L_multOutB),
					.L_subOutA(perc_var_L_subOutA),
					.L_subOutB(perc_var_L_subOutB),
					.L_shrOutVar1(perc_var_L_shrVar1Out),
					.L_shrOutNumShift(perc_var_L_shrNumShiftOut),
					.L_addOutA(perc_var_L_addOutA),
					.L_addOutB(perc_var_L_addOutB),
					.addOutA(perc_var_addOutA),
					.addOutB(perc_var_addOutB),
					.multOutA(perc_var_multOutA),
					.multOutB(perc_var_multOutB),
					.memReadAddr(perc_var_memReadAddr),
					.memWriteAddr(perc_var_memWriteAddr),
					.memWrite(perc_var_memWriteEn),
					.memOut(perc_var_memIn),
					.done(perc_varDone)
				);

				
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Weight_Az
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

		wire [11:0] addr_Weight_Az_A;
		wire [11:0] addr_Weight_Az_AP;
		wire [11:0] addr_Weight_Az_gamma;
	
		Weight_Az Weight_Az(
					.start(Weight_AzReady),
					.clk(clock),
					.done(Weight_AzDone),
					.reset(reset),
					.A(addr_Weight_Az_A),
					.AP(addr_Weight_Az_AP),
					.gammaAddr(addr_Weight_Az_gamma),
					.readAddr(Weight_Az_memReadAddr),
					.readIn(memOut),
					.writeAddr(Weight_Az_memWriteAddr),
					.writeOut(Weight_Az_memIn),
					.writeEn(Weight_Az_memWriteEn),
					.L_mult_in(L_mult_out),
					.L_add_in(L_add_out),
					.add_in(add_out),
					.L_mult_a(Weight_Az_L_multOutA),
					.L_mult_b(Weight_Az_L_multOutB),
					.add_a(Weight_Az_addOutA),
					.add_b(Weight_Az_addOutB),
					.L_add_a(Weight_Az_L_addOutA),
					.L_add_b(Weight_Az_L_addOutB)
				);
				
		//A
		mux128_12 i_mux128_12_Weight_Az_A(
														.in0(0),
														.in1(0),
														.in2(0),
														.in3(0),
														.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(A_T_LOW),.in10(A_T_LOW),.in11(0),.in12(0),.in13(A_T_HIGH),.in14(A_T_HIGH),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(A_Addr),.in20(A_Addr),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addr_Weight_Az_A));
		
		//AP
		mux128_12 i_mux128_12_Weight_Az_AP(
														.in0(0),
														.in1(0),
														.in2(0),
														.in3(0),
														.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(WEIGHT_AZ_AP_OUT),.in10(WEIGHT_AZ_AP_OUT2),.in11(0),.in12(0),.in13(WEIGHT_AZ_AP_OUT),.in14(WEIGHT_AZ_AP_OUT2),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(WEIGHT_AZ_AP_OUT),.in20(WEIGHT_AZ_AP_OUT2),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addr_Weight_Az_AP));
		
		//gammaAddr
		mux128_12 i_mux128_12_Weight_Az_gammaAddr(
														.in0(0),
														.in1(0),
														.in2(0),
														.in3(0),
														.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(PERC_VAR_GAMMA1),.in10(PERC_VAR_GAMMA2),.in11(0),.in12(0),.in13(PERC_VAR_GAMMA1+'d1),.in14(PERC_VAR_GAMMA2+'d1),.in15(0),
		.in16(0),.in17(0),.in18(0),.in19(PERC_VAR_GAMMA1+i_gamma),.in20(PERC_VAR_GAMMA2+i_gamma),.in21(0),.in22(0),.in23(0),.in24(0),
		.in25(0),.in26(0),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addr_Weight_Az_gamma));

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Residu
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

		wire [11:0] addr_Residu_A;
		wire [11:0] addr_Residu_X;
		wire [11:0] addr_Residu_Y;

		Residu Residu(
					.clk(clock),
					.reset(reset),
					.start(ResiduReady),
					.done(ResiduDone),
					.A(addr_Residu_A),
					.X(addr_Residu_X),
					.Y(addr_Residu_Y),
					.LG(L_SUBFR),
					.memReadDataA(memReadDataA),
					.memReadDataX(memReadDataX),
					.memWriteEn(Residu_memWriteEn),
					.memReadAddrA(Residu_memReadAddr),
					.memReadAddrX(Residu_speechAddr),
					.memWriteAddr(Residu_memWriteAddr),
					.memWriteData(Residu_memIn),
					.L_multOutA(Residu_L_multOutA),
					.L_multOutB(Residu_L_multOutB),
					.L_multIn(L_mult_out),
					.L_macOutA(Residu_L_macOutA),
					.L_macOutB(Residu_L_macOutB),
					.L_macOutC(Residu_L_macOutC),
					.L_macIn(L_mac_out),
					.subOutA(Residu_subOutA),
					.subOutB(Residu_subOutB),
					.subIn(sub_out),
					.L_shlOutA(Residu_L_shlOutVar1),
					.L_shlOutB(Residu_L_shlNumShiftOut),
					.L_shlIn(L_shl_out),
				    .addOutA(Residu_addOutA),
					.addOutB(Residu_addOutB),
					.addIn(add_out),
					.L_addOutA(Residu_L_addOutA),
					.L_addOutB(Residu_L_addOutB),
					.L_addIn(L_add_out),
					.L_shlDone(L_shl_done),
					.L_shlReady(Residu_L_shlReady)
				);
				
		always @ (*)
		begin
			Residu_memSameAddr = 'd0;
			if (mathMuxSel == 'd26)
			begin
				if (Residu_memReadAddr != 'd0)
					Residu_memSameAddr = Residu_memReadAddr;
				else if (Residu_speechAddr != 'd0)
					Residu_memSameAddr = Residu_speechAddr;
			end
		end
		
		always @ (*)
		begin
			memReadDataA = memOut;
			if (mathMuxSel == 'd26)
				memReadDataX = memOut;
			else
				memReadDataX = speechIn;
		end
		

		//A
		mux128_12 i_mux128_12_Residu_A(
														.in0(0),
														.in1(0),
														.in2(0),
														.in3(0),
														.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(WEIGHT_AZ_AP_OUT),.in12(0),.in13(0),.in14(0),.in15(WEIGHT_AZ_AP_OUT),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(Aq_Addr),
		.in25(0),.in26(WEIGHT_AZ_AP_OUT),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addr_Residu_A));
		
		//X
		mux128_12 i_mux128_12_Residu_X(
														.in0(0),
														.in1(0),
														.in2(0),
														.in3(0),
														.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(SPEECH),.in12(0),.in13(0),.in14(0),.in15(SPEECH+L_SUBFR),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(SPEECH+i_subfr),
		.in25(0),.in26(ERROR),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addr_Residu_X));
		
		//Y
		mux128_12 i_mux128_12_Residu_Y(
														.in0(0),
														.in1(0),
														.in2(0),
														.in3(0),
														.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(WSP),.in12(0),.in13(0),.in14(0),.in15(WSP+L_SUBFR),
		.in16(0),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(0),.in23(0),.in24(EXC+i_subfr),
		.in25(0),.in26(XN),.in27(0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(0),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addr_Residu_Y));
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Syn_filt
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

		wire [11:0] addr_Syn_filt_A;
		wire [11:0] addr_Syn_filt_X;
		wire [11:0] addr_Syn_filt_Y;
		wire [11:0] addr_Syn_filt_MEM;
		wire [31:0] Syn_filt_UPDATE;
		
		syn_filt Syn_filt(
					.clk(clock), 
					.reset(reset), 
					.start(Syn_filtReady), 
					.memIn(memOut), 
					.memWriteEn(Syn_filt_memWriteEn), 
					.memWriteAddr(Syn_filt_memWriteAddr), 
					.memOut(Syn_filt_memIn),
					.memReadAddr(Syn_filt_memReadAddr),
					.done(Syn_filtDone),
					.xAddr(addr_Syn_filt_X),
					.aAddr(addr_Syn_filt_A), 
					.yAddr(addr_Syn_filt_Y), 
					.fMemAddr(addr_Syn_filt_MEM), 
					.update(Syn_filt_UPDATE),
					.addOutA(Syn_filt_addOutA),
					.addOutB(Syn_filt_addOutB),
					.addIn(add_out),
					.subOutA(Syn_filt_subOutA),
					.subOutB(Syn_filt_subOutB),
					.subIn(sub_out),
					.L_addOutA(Syn_filt_L_addOutA), 
					.L_addOutB(Syn_filt_L_addOutB), 
					.L_addIn(L_add_out), 
					.L_multOutA(Syn_filt_L_multOutA),
					.L_multOutB(Syn_filt_L_multOutB), 
					.L_multIn(L_mult_out), 
					.L_msuOutA(Syn_filt_L_msuOutA), 
					.L_msuOutB(Syn_filt_L_msuOutB), 
					.L_msuOutC(Syn_filt_L_msuOutC), 
					.L_msuIn(L_msu_out),  
					.L_shlIn(L_shl_out), 
					.L_shlOutVar1(Syn_filt_L_shlOutVar1),
					.L_shlReady(Syn_filt_L_shlReady), 
					.L_shlDone(L_shl_done), 
					.L_shlNumShiftOut(Syn_filt_L_shlNumShiftOut)
				);
		//A
		mux128_12 i_mux128_12_Syn_filt_A(
														.in0(0),
														.in1(0),
														.in2(0),
														.in3(0),
														.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(WEIGHT_AZ_AP_OUT2),.in13(0),.in14(0),.in15(0),
		.in16(WEIGHT_AZ_AP_OUT2),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(Aq_Addr),.in23(WEIGHT_AZ_AP_OUT2),.in24(0),
		.in25(Aq_Addr),.in26(0),.in27(WEIGHT_AZ_AP_OUT2),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(Aq_Addr),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addr_Syn_filt_A));
		
		//X
		mux128_12 i_mux128_12_Syn_filt_X(
														.in0(0),
														.in1(0),
														.in2(0),
														.in3(0),
														.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(WSP),.in13(0),.in14(0),.in15(0),
		.in16(WSP+L_SUBFR),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(AI_ZERO),.in23(H1),.in24(0),
		.in25(EXC+i_subfr),.in26(0),.in27(XN),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(EXC+i_subfr),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addr_Syn_filt_X));
		
		//Y
		mux128_12 i_mux128_12_Syn_filt_Y(
														.in0(0),
														.in1(0),
														.in2(0),
														.in3(0),
														.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(WSP),.in13(0),.in14(0),.in15(0),
		.in16(WSP+L_SUBFR),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(H1),.in23(H1),.in24(0),
		.in25(ERROR),.in26(0),.in27(XN),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(SYN+i_subfr),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addr_Syn_filt_Y));
		
		//MEM
		mux128_12 i_mux128_12_Syn_filt_MEM(
														.in0(0),
														.in1(0),
														.in2(0),
														.in3(0),
														.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(MEM_W),.in13(0),.in14(0),.in15(0),
		.in16(MEM_W),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22(ZERO),.in23(ZERO),.in24(0),
		.in25(MEM_ERR),.in26(0),.in27(MEM_W0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46(MEM_SYN),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addr_Syn_filt_MEM));
		
		//UPDATE
		mux128_32 i_mux128_32_Syn_filt_UPDATE(
														.in0(0),
														.in1(0),
														.in2(0),
														.in3(0),
														.in4(0),.in5(0),
		.in6(0),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12('d1),.in13(0),.in14(0),.in15(0),
		.in16('d1),.in17(0),.in18(0),.in19(0),.in20(0),.in21(0),.in22('d0),.in23('d0),.in24(0),
		.in25('d0),.in26(0),.in27('d0),.in28(0),.in29(0),.in30(0),.in31(0),.in32(0),.in33(0),
		.in34(0),.in35(0),.in36(0),.in37(0),.in38(0),.in39(0),.in40(0),.in41(0),.in42(0),
		.in43(0),.in44(0),.in45(0),.in46('d1),.in47(0),.in48(0),.in49(0),.in50(0),.in51(0),
		.in52(0),.in53(0),.in54(0),.in55(0),.in56(0),.in57(0),.in58(0),.in59(0),.in60(0),
		.in61(0),.in62(0),.in63(0),.in64(0),.in65(0),.in66(0),.in67(0),.in68(0),.in69(0),
		.in70(0),.in71(0),.in72(0),.in73(0),.in74(0),.in75(0),.in76(0),.in77(0),.in78(0),
		.in79(0),.in80(0),.in81(0),.in82(0),.in83(0),.in84(0),.in85(0),.in86(0),.in87(0),
		.in88(0),.in89(0),.in90(0),.in91(0),.in92(0),.in93(0),.in94(0),.in95(0),.in96(0),
		.in97(0),.in98(0),.in99(0),.in100(0),.in101(0),.in102(0),.in103(0),.in104(0),.in105(0),
		.in106(0),.in107(0),.in108(0),.in109(0),.in110(0),.in111(0),.in112(0),.in113(0),
		.in114(0),.in115(0),.in116(0),.in117(0),.in118(0),.in119(0),.in120(0),.in121(0),
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(Syn_filt_UPDATE));

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Pitch_ol
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
		
		Pitch_ol Pitch_ol (
					.clk(clock), 
					.start(Pitch_olReady), 
					.reset(reset), 
					.done(Pitch_olDone), 
					.signal(WSP), 
					.pit_min(PIT_MIN), 
					.pit_max(PIT_MAX), 
					.L_frame(L_FRAME),
					.p_max1(Pitch_ol_nextT_op),
					.writeAddr(Pitch_ol_memWriteAddr),
					.writeOut(Pitch_ol_memIn), 
					.writeEn(Pitch_ol_memWriteEn),
					.readAddr(Pitch_ol_memReadAddr), 
					.readIn(memOut), 
					.L_mac_a(Pitch_ol_L_macOutA), 
					.L_mac_b(Pitch_ol_L_macOutB), 
					.L_mac_c(Pitch_ol_L_macOutC), 
					.L_mac_overflow(L_mac_overflow), 
					.L_mac_in(L_mac_out), 
					.mult_a(Pitch_ol_multOutA), 
					.mult_b(Pitch_ol_multOutB), 
					.mult_in(mult_out),
					.shr_a(Pitch_ol_shrVar1Out), 
					.shr_b(Pitch_ol_shrVar2Out), 
					.shr_in(shr_out), 
					.shl_a(Pitch_ol_shlOutVar1), 
					.shl_b(Pitch_ol_shlOutVar2), 
					.shl_in(shl_out), 
					.add_a(Pitch_ol_addOutA), 
					.add_b(Pitch_ol_addOutB), 
					.add_in(add_out),
					.sub_a(Pitch_ol_subOutA),
					.sub_b(Pitch_ol_subOutB),
					.sub_in(sub_out), 
					.L_sub_a(Pitch_ol_L_subOutA), 
					.L_sub_b(Pitch_ol_L_subOutB), 
					.L_sub_in(L_sub_out), 
					.L_msu_a(Pitch_ol_L_msuOutA), 
					.L_msu_b(Pitch_ol_L_msuOutB), 
					.L_msu_c(Pitch_ol_L_msuOutC), 
					.L_shr_a(Pitch_ol_L_shrVar1Out),
					.L_shr_b(Pitch_ol_L_shrNumShiftOut), 
					.L_add_a(Pitch_ol_L_addOutA), 
					.L_add_b(Pitch_ol_L_addOutB), 
					.L_mult_a(Pitch_ol_L_multOutA), 
					.L_mult_b(Pitch_ol_L_multOutB), 
					.L_mult_in(L_mult_out), 
					.L_msu_in(L_msu_out), 
					.L_shr_in(L_shr_out), 
					.L_add_in(L_add_out), 
					.norm_l_in(norm_l_out), 
					.norm_l_done(norm_l_done), 
					.L_shl_in(L_shl_out), 
					.L_shl_done(L_shl_done), 
					.constantMemIn(constantMemOut), 
					.norm_l_var1(Pitch_ol_norm_l_out), 
					.norm_l_ready(Pitch_ol_norm_l_start), 
					.L_shl_var1(Pitch_ol_L_shlOutVar1), 
					.L_shl_numshift(Pitch_ol_L_shlNumShiftOut), 
					.L_shl_ready(Pitch_ol_L_shlReady), 
					.constantMemAddr(Pitch_ol_constantMemAddr)
				);

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		TL_Math2
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
				
		TL_Math2 TL_Math2 (
					.clock(clock),
					.reset(reset),
					.start(Math2Ready),
					.addIn(add_out),
					.subIn(sub_out),
					.L_subIn(L_sub_out),
					.T_op(T_op),
					.PIT_MIN(PIT_MIN),
					.PIT_MAX(PIT_MAX),
					.addOutA(TL_Math2_addOutA),
					.addOutB(TL_Math2_addOutB),
					.subOutA(TL_Math2_subOutA),
					.subOutB(TL_Math2_subOutB),
					.L_subOutA(TL_Math2_L_subOutA),
					.L_subOutB(TL_Math2_L_subOutB),
					.T0_min(TL_Math2_nextT0_min),
					.T0_max(TL_Math2_nextT0_max),
					.done(Math2Done)
				);

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		TL_Math3
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

		TL_Math3 TL_Math3(
					.clock(clock),
					.reset(reset),
					.start(Math3Ready),
					.i_gamma_in(i_gamma),
					.Ap1(WEIGHT_AZ_AP_OUT),
					.ai_zero(AI_ZERO),
					.M(M),
					.addIn(add_out),
					.memIn(memOut),
					.addOutA(TL_Math3_addOutA),
					.addOutB(TL_Math3_addOutB),
					.memWriteAddr(TL_Math3_memWriteAddr),
					.memOut(TL_Math3_memIn),
					.memWriteEn(TL_Math3_memWriteEn),
					.memReadAddr(TL_Math3_memReadAddr),
					.i_gamma_out(nexti_gamma),
					.done(Math3Done)
				);

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Pitch_fr3
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

		Pitch_fr3 Pitch_fr3(
					.clock(clock),
					.start(Pitch_fr3Ready),
					.reset(reset),
					.done(Pitch_fr3Done),
					.exc(EXC+i_subfr),
					.xn(XN),
					.h(H1),
					.L_subfr(L_SUBFR),
					.t0_min(T0_min),
					.t0_max(T0_max),
					.i_subfr(i_subfr),
					.pit_frac(Pitch_fr3_nextT0_frac),
					.lag(Pitch_fr3_nextT0),
					.sub_outa(Pitch_fr3_subOutA),
					.sub_outb(Pitch_fr3_subOutB),
					.sub_in(sub_out),
					.add_outa(Pitch_fr3_addOutA),
					.add_outb(Pitch_fr3_addOutB),
					.add_in(add_out),
					.L_add_outa(Pitch_fr3_L_addOutA),
					.L_add_outb(Pitch_fr3_L_addOutB),
					.L_add_in(L_add_out),
					.L_sub_outa(Pitch_fr3_L_subOutA),
					.L_sub_outb(Pitch_fr3_L_subOutB),
					.L_sub_in(L_sub_out),
					.L_negate_out(Pitch_fr3_L_negate_out),
					.L_negate_in(L_negate_out),
					.L_mac_outa(Pitch_fr3_L_macOutA),
					.L_mac_outb(Pitch_fr3_L_macOutB),
					.L_mac_outc(Pitch_fr3_L_macOutC),
					.L_mac_in(L_mac_out),
					.L_msu_outa(Pitch_fr3_L_msuOutA),
					.L_msu_outb(Pitch_fr3_L_msuOutB),
					.L_msu_outc(Pitch_fr3_L_msuOutC),
					.L_msu_in(L_msu_out),
					.L_mult_outa(Pitch_fr3_L_multOutA),
					.L_mult_outb(Pitch_fr3_L_multOutB),
					.L_mult_in(L_mult_out),
					.L_shl_outa(Pitch_fr3_L_shlOutVar1),
					.L_shl_outb(Pitch_fr3_L_shlNumShiftOut),
					.L_shl_start(Pitch_fr3_L_shlReady),
					.L_shl_done(L_shl_done),
					.L_shl_in(L_shl_out),
					.L_shr_outa(Pitch_fr3_L_shrVar1Out),
					.L_shr_outb(Pitch_fr3_L_shrNumShiftOut),
					.L_shr_in(L_shr_out),
					.mult_outa(Pitch_fr3_multOutA),
					.mult_outb(Pitch_fr3_multOutB),
					.mult_in(mult_out),
					.norm_l_out(Pitch_fr3_norm_l_out),
					.norm_l_start(Pitch_fr3_norm_l_start),
					.norm_l_in(norm_l_out),
					.norm_l_done(norm_l_done),
					.shr_outa(Pitch_fr3_shrVar1Out),
					.shr_outb(Pitch_fr3_shrVar2Out),
					.shr_in(shr_out),
					.scratch_mem_read_addr(Pitch_fr3_memReadAddr),
					.scratch_mem_write_addr(Pitch_fr3_memWriteAddr),
					.scratch_mem_out(Pitch_fr3_memIn),
					.scratch_mem_in(memOut),
					.scratch_mem_write_en(Pitch_fr3_memWriteEn),
					.constant_mem_read_addr(Pitch_fr3_constantMemAddr),
					.constant_mem_in(constantMemOut)
				);	
				
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Enc_lag3 & LOAD_ANA_2_7_Addr
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
/* 	module Enc_lag3(clk,reset,start,T0,T0_frac,T0_min,T0_max,PIT_MIN,PIT_MAX,pit_flag,addIn,subIn,memIn,addOutA,addOutB,
					subOutA,subOutB,memReadAddr,memWriteAddr,memWriteEn,
					memOut,index,done); */

		Enc_lag3 Enc_lag3 (
					.clk(clock),
					.reset(reset),
					.start(Enc_lag3Ready),
					.T0(T0),
					.T0_frac(T0_frac),
					.T0_min_in(T0_min),
					.T0_min_out(Enc_lag3_nextT0_min),
					.T0_max(Enc_lag3_nextT0_max),
					.PIT_MIN(PIT_MIN),
					.PIT_MAX(PIT_MAX),
					.pit_flag(i_subfr),
					.addIn(add_out),
					.subIn(sub_out),
					.memIn(memOut),
					.addOutA(Enc_lag3_addOutA),
					.addOutB(Enc_lag3_addOutB),
					.subOutA(Enc_lag3_subOutA),
					.subOutB(Enc_lag3_subOutB),
					.memReadAddr(Enc_lag3_memReadAddr),
					.memWriteAddr(Enc_lag3_memWriteAddr),
					.memWriteEn(Enc_lag3_memWriteEn),
					.memOut(Enc_lag3_memIn),
					.index(Enc_lag3_nextindex),
					.done(Enc_lag3Done)	
				);

		always @ (*)
		begin
			if (i_subfr == 'd0)
				LOAD_ANA_2_7_Addr = PRM + 'd2;
			else if (i_subfr == 'd40)
				LOAD_ANA_2_7_Addr = PRM + 'd7;
		end
		
		always @ (*)
		begin
			if (index[15] == 'd0)
				LOAD_ANA_2_7_Data = {16'h0000, index};
			else if (index[15] == 'd1)
				LOAD_ANA_2_7_Data = {16'hffff, index};
		end
		
								
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Parity_Pitch
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

	/*module Parity_pitch(clk, start, reset, done, pitch_index, sum, add_a, add_b, add_in, shr_a, shr_b, shr_in);*/

		Parity_pitch Parity_pitch(
					.clk(clock),
					.start(Parity_PitchReady),
					.reset(reset),
					.done(Parity_PitchDone),
					.pitch_index(index),
					.sum(Parity_pitch_sum),
					.add_a(Parity_pitch_addOutA),
					.add_b(Parity_pitch_addOutB),
					.add_in(add_out),
					.shr_a(Parity_pitch_shrVar1Out),
					.shr_b(Parity_pitch_shrVar2Out),
					.shr_in(shr_out)
				);
		
		always @ (*)
		begin
			if (Parity_pitch_sum[15] == 'd0)
				Parity_pitch_sum_Data = {16'h0000, Parity_pitch_sum};
			else if (Parity_pitch_sum[15] == 'd1)
				Parity_pitch_sum_Data = {16'hffff, Parity_pitch_sum};
		end

	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Pred_lt_3
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	/*module Pred_lt_3(clk, start, reset, done, exc, t0, frac, L_subfr, writeAddr, writeOut, writeEn, readAddr, readIn, 
						add_a, add_b, add_in, L_mac_a, L_mac_b, L_mac_c, L_mac_in, L_add_a, L_add_b, L_add_in, 
						L_negate_out, L_negate_in, sub_a, sub_b, sub_in, constantMemIn, constantMemAddr);*/

		
		//    Pred_lt_3(&exc[i_subfr], T0, T0_frac, L_SUBFR);
		Pred_lt_3 Pred_lt_3(
					.clk(clock),
					.start(Pred_lt_3Ready),
					.reset(reset),
					.done(Pred_lt_3Done),


					.exc(EXC+i_subfr),
					.t0(T0),
					.frac(T0_frac),
					.L_subfr(L_SUBFR),
					.writeAddr(Pred_lt_3_memWriteAddr),
					.writeOut(Pred_lt_3_memIn),
					.writeEn(Pred_lt_3_memWriteEn),
					.readAddr(Pred_lt_3_memReadAddr),
					.readIn(memOut),
					.add_a(Pred_lt_3_addOutA),
					.add_b(Pred_lt_3_addOutB),
					.add_in(add_out),
					.L_mac_a(Pred_lt_3_L_macOutA),
					.L_mac_b(Pred_lt_3_L_macOutB),
					.L_mac_c(Pred_lt_3_L_macOutC),
					.L_mac_in(L_mac_out),
					.L_add_a(Pred_lt_3_L_addOutA),
					.L_add_b(Pred_lt_3_L_addOutB),
					.L_add_in(L_add_out),
					.L_negate_out(Pred_lt_3_L_negate_out),
					.L_negate_in(L_negate_out),
					.sub_a(Pred_lt_3_subOutA),
					.sub_b(Pred_lt_3_subOutB),
					.sub_in(sub_out),
					.constantMemIn(constantMemOut),
					.constantMemAddr(Pred_lt_3_constantMemAddr)
				);						
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Convolve
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	/*module convolve(clk, reset, start, memIn, memWriteEn, memWriteAddr, memOut, done,
					    L_macIn, L_macOutA, L_macOutB, L_macOutC, L_shlIn, L_shlOutVar1,
						 L_shlReady, L_shlDone, L_shlNumShiftOut, xAddr, hAddr, yAddr, L_subOutA,
						 L_subOutB, L_subIn, L_addOutA, L_addOutB, L_addIn,addOutA,addOutB,addIn);*/
	
		convolve convolve(
					.clk(clock),
					.reset(reset),
					.start(ConvolveReady),
					.memIn(memOut),
					.memWriteEn(Convolve_memWriteEn),
					.memWriteAddr(Convolve_memWriteAddr),
					.memOut(Convolve_memIn),
					.done(ConvolveDone),
					.L_macIn(L_mac_out),
					.L_macOutA(Convolve_L_macOutA),
					.L_macOutB(Convolve_L_macOutB),
					.L_macOutC(Convolve_L_macOutC),
					.L_shlIn(L_shl_out),
					.L_shlOutVar1(Convolve_L_shlOutVar1),
					.L_shlReady(Convolve_L_shlReady),
					.L_shlDone(L_shl_done),
					.L_shlNumShiftOut(Convolve_L_shlNumShiftOut),
					.xAddr(EXC+i_subfr),
					.hAddr(H1),
					.yAddr(Y1),
					.L_subOutA(Convolve_L_subOutA),
					.L_subOutB(Convolve_L_subOutB),
					.L_subIn(L_sub_out),
					.L_addOutA(Convolve_L_addOutA),
					.L_addOutB(Convolve_L_addOutB),
					.L_addIn(L_add_out),
					.addOutA(Convolve_addOutA),
					.addOutB(Convolve_addOutB),
					.addIn(add_out)
				);	
				
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		G_pitch
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	/*module G_pitch(clock,reset,start,done,out,
					shr_outa,shr_outb,shr_in,
					L_mac_outa,L_mac_outb,L_mac_outc,L_mac_in,L_mac_overflow,
					norm_l_out,norm_l_in,norm_l_start,norm_l_done,
					L_shl_outa,L_shl_outb,L_shl_start,L_shl_in,L_shl_done,
					sub_outa,sub_outb,sub_in,
					add_outa,add_outb,add_in,
					scratch_mem_read_addr,scratch_mem_write_addr,scratch_mem_in,scratch_mem_out,
					scratch_mem_write_en,
					L_add_outa,L_add_outb,L_add_in,
					L_sub_outa,L_sub_outb,L_sub_in);*/

		G_pitch G_pitch(
					.clock(clock),
					.reset(reset),
					.start(G_pitchReady),
					.done(G_pitchDone),
					.out(G_pitch_nextgain_pit),
					.shr_outa(G_pitch_shrVar1Out),
					.shr_outb(G_pitch_shrVar2Out),
					.shr_in(shr_out),
					.L_mac_outa(G_pitch_L_macOutA),
					.L_mac_outb(G_pitch_L_macOutB),
					.L_mac_outc(G_pitch_L_macOutC),
					.L_mac_in(L_mac_out),
					.L_mac_overflow(L_mac_overflow),
					.norm_l_out(G_pitch_norm_l_out),
					.norm_l_in(norm_l_out),
					.norm_l_start(G_pitch_norm_l_start),
					.norm_l_done(norm_l_done),
					.L_shl_outa(G_pitch_L_shlOutVar1),
					.L_shl_outb(G_pitch_L_shlNumShiftOut),
					.L_shl_start(G_pitch_L_shlReady),
					.L_shl_in(L_shl_out),
					.L_shl_done(L_shl_done),
					.sub_outa(G_pitch_subOutA),
					.sub_outb(G_pitch_subOutB),
					.sub_in(sub_out),
					.add_outa(G_pitch_addOutA),
					.add_outb(G_pitch_addOutB),
					.add_in(add_out),
					.scratch_mem_read_addr(G_pitch_memReadAddr),
					.scratch_mem_write_addr(G_pitch_memWriteAddr),
					.scratch_mem_in(memOut),
					.scratch_mem_out(G_pitch_memIn),
					.scratch_mem_write_en(G_pitch_memWriteEn),
					.L_add_outa(G_pitch_L_addOutA),
					.L_add_outb(G_pitch_L_addOutB),
					.L_add_in(L_add_out),
					.L_sub_outa(G_pitch_L_subOutA),
					.L_sub_outb(G_pitch_L_subOutB),
					.L_sub_in(L_sub_out)
				);	
					
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		test_err
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	/*module test_err(clock,reset,start,done,out,T0,T0_frac,
						add_outa,add_outb,add_in,
						sub_outa,sub_outb,sub_in,
						L_sub_outa,L_sub_outb,L_sub_in,
						scratch_mem_read_addr,scratch_mem_write_addr,
						scratch_mem_in,scratch_mem_out,
						scratch_mem_write_en,
						constant_mem_read_addr,constant_mem_in)*/

		test_err test_err(
					.clock(clock),
					.reset(reset),
					.start(test_errReady),
					.done(test_errDone),
					.out(test_err_nexttemp),
					.T0(T0),
					.T0_frac(T0_frac),
					.add_outa(test_err_addOutA),
					.add_outb(test_err_addOutB),
					.add_in(add_out),
					.sub_outa(test_err_subOutA),
					.sub_outb(test_err_subOutB),
					.sub_in(sub_out),
					.L_sub_outa(test_err_L_subOutA),
					.L_sub_outb(test_err_L_subOutB),
					.L_sub_in(L_sub_out),
					.scratch_mem_read_addr(test_err_memReadAddr),
					.scratch_mem_write_addr(test_err_memWriteAddr),
					.scratch_mem_in(memOut),
					.scratch_mem_out(test_err_memIn),
					.scratch_mem_write_en(test_err_memWriteEn),
					.constant_mem_read_addr(test_err_constantMemAddr),
					.constant_mem_in(constantMemOut)
				);

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Math 4
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

		TL_Math4 TL_Math4(
					.clock(clock),
					.reset(reset),
					.start(Math4Ready),
					.y1(Y1),
					.xn(XN),
					.xn2(XN2),
					.temp(temp),
					.gain_pit_in(gain_pit),
					.GPCLIP(GPCLIP),
					.L_SUBFR(L_SUBFR),
					.addIn(add_out),
					.subIn(sub_out),
					.L_multIn(L_mult_out),
					.memIn(memOut),
					.L_shlIn(L_shl_out),
					.L_shlDone(L_shl_done),
					.addOutA(TL_Math4_addOutA),
					.addOutB(TL_Math4_addOutB),
					.subOutA(TL_Math4_subOutA),
					.subOutB(TL_Math4_subOutB),
					.L_multOutA(TL_Math4_L_multOutA),
					.L_multOutB(TL_Math4_L_multOutB),
					.L_shlReady(TL_Math4_L_shlReady),
					.L_shlOutA(TL_Math4_L_shlOutVar1),
					.L_shlOutB(TL_Math4_L_shlNumShiftOut),
					.memWriteAddr(TL_Math4_memWriteAddr),
					.memOut(TL_Math4_memIn),
					.memWriteEn(TL_Math4_memWriteEn),
					.memReadAddr(TL_Math4_memReadAddr),
					.L_temp(TL_Math4_nextL_temp),
					.gain_pit_out(TL_Math4_nextgain_pit),
					.done(Math4Done)
				);		

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		ACELP_Codebook
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	/*module ACELP_Codebook(clk,reset,start,T0,pitch_sharp,i_subfr,shlIn,subIn,addIn,multIn,L_macIn,
							 L_absIn,L_subIn,norm_lIn,norm_lDone,L_shrIn,L_negateIn,L_multIn,L_msuIn,shrIn,
							 L_addIn,L_add2In,L_add3In,L_add4In,memIn,shlVar1Out,shlVar2Out,subOutA,
							 subOutB,addOutA,addOutB,multOutA,multOutB,L_macOutA,L_macOutB,L_macOutC,
							 L_absOut,L_subOutA,L_subOutB,norm_lVar1Out,norm_lReady,L_shrVar1Out,
							 L_shrNumShiftOut,L_negateOut,L_multOutA,L_multOutB,L_msuOutA,L_msuOutB,
							 L_msuOutC,shrVar1Out,shrVar2Out,L_addOutA,L_addOutB,L_add2OutA,L_add2OutB,
							 L_add3OutA,L_add3OutB,L_add4OutA,L_add4OutB,memReadAddr,memWriteAddr,memOut,
							 memWriteEn,index,done);*/

		ACELP_Codebook ACELP_Codebook(
					.clk(clock),
					.reset(reset),
					.start(ACELP_CodebookReady),
					.T0(T0),
					.pitch_sharp(sharp),
					.i_subfr(i_subfr),
					.shlIn(shl_out),
					.subIn(sub_out),
					.addIn(add_out),
					.multIn(mult_out),
					.L_macIn(L_mac_out),
					.L_absIn(L_abs_out),
					.L_subIn(L_sub_out),
					.norm_lIn(norm_l_out),
					.norm_lDone(norm_l_done),
					.L_shrIn(L_shr_out),
					.L_negateIn(L_negate_out),
					.L_multIn(L_mult_out),
					.L_msuIn(L_msu_out),
					.shrIn(shr_out),
					.L_addIn(L_add_out),
					.L_add2In(L_add_out2),
					.L_add3In(L_add_out3),
					.L_add4In(L_add_out4),
					.memIn(memOut),
					.shlVar1Out(ACELP_Codebook_shlVar1Out),
					.shlVar2Out(ACELP_Codebook_shlVar2Out),
					.subOutA(ACELP_Codebook_subOutA),
					.subOutB(ACELP_Codebook_subOutB),
					.addOutA(ACELP_Codebook_addOutA),
					.addOutB(ACELP_Codebook_addOutB),
					.multOutA(ACELP_Codebook_multOutA),
					.multOutB(ACELP_Codebook_multOutB),
					.L_macOutA(ACELP_Codebook_L_macOutA),
					.L_macOutB(ACELP_Codebook_L_macOutB),
					.L_macOutC(ACELP_Codebook_L_macOutC),
					.L_absOut(ACELP_Codebook_L_abs_out),
					.L_subOutA(ACELP_Codebook_L_subOutA),
					.L_subOutB(ACELP_Codebook_L_subOutB),
					.norm_lVar1Out(ACELP_Codebook_norm_l_out),
					.norm_lReady(ACELP_Codebook_norm_l_start),
					.L_shrVar1Out(ACELP_Codebook_L_shrVar1Out),
					.L_shrNumShiftOut(ACELP_Codebook_L_shrNumShiftOut),
					.L_negateOut(ACELP_Codebook_L_negate_out),
					.L_multOutA(ACELP_Codebook_L_multOutA),
					.L_multOutB(ACELP_Codebook_L_multOutB),
					.L_msuOutA(ACELP_Codebook_L_msuOutA),
					.L_msuOutB(ACELP_Codebook_L_msuOutB),
					.L_msuOutC(ACELP_Codebook_L_msuOutC),
					.shrVar1Out(ACELP_Codebook_shrVar1Out),
					.shrVar2Out(ACELP_Codebook_shrVar2Out),
					.L_addOutA(ACELP_Codebook_L_addOutA),
					.L_addOutB(ACELP_Codebook_L_addOutB),
					.L_add2OutA(L_add_a2),
					.L_add2OutB(L_add_b2),
					.L_add3OutA(L_add_a3),
					.L_add3OutB(L_add_b3),
					.L_add4OutA(L_add_a4),
					.L_add4OutB(L_add_b4),
					.memReadAddr(ACELP_Codebook_memReadAddr),
					.memWriteAddr(ACELP_Codebook_memWriteAddr),
					.memOut(ACELP_Codebook_memIn),
					.memWriteEn(ACELP_Codebook_memWriteEn),
					.index(ACELP_Codebook_nextindex),
					.i_out(ACELP_Codebook_nexti),
					.done(ACELP_CodebookDone)
				);
							 
	L_add i_L_add_2(
						.a(L_add_a2),
						.b(L_add_b2),
						.overflow(),
						.sum(L_add_out2)
						);
	L_add i_L_add_3(
						.a(L_add_a3),
						.b(L_add_b3),
						.overflow(),
						.sum(L_add_out3)
						);
	L_add i_L_add_4(
						.a(L_add_a4),
						.b(L_add_b4),
						.overflow(),
						.sum(L_add_out4)
						);
						
	always @ (*)
	begin
		if (i_subfr == 'd0)
			LOAD_ANA_4_8_Addr = PRM + 'd4;
		else if (i_subfr == 'd40)
			LOAD_ANA_4_8_Addr = PRM + 'd8;
	end
	
	always @ (*)
	begin
		if (i_subfr == 'd0)
			LOAD_ANA_5_9_Addr = PRM + 'd5;
		else if (i_subfr == 'd40)
			LOAD_ANA_5_9_Addr = PRM + 'd9;
	end

	always @ (*)
	begin
		if (index[15] == 'd0)
			LOAD_ANA_4_8_Data = {16'h0000, index};
		else if (index[15] == 'd1)
			LOAD_ANA_4_8_Data = {16'hffff, index};
	end

	always @ (*)
	begin
		if (i[15] == 'd0)
			LOAD_ANA_5_9_Data = {16'h0000, i};
		else if (i[15] == 'd1)
			LOAD_ANA_5_9_Data = {16'hffff, i};
	end
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Math 5
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

	/*module TL_Math5 (clock,reset,start,g_coeff,g_coeff_cs,exp_g_coeff_cs,addIn,negateIn,memIn,addOutA,
	addOutB,negateOut,memWriteAddr,memOut,memWriteEn,memReadAddr,done);*/

	   TL_Math5 TL_Math5(
					.clock(clock),
					.reset(reset),
					.start(Math5Ready),
					.g_coeff(G_COEFF),
					.g_coeff_cs(G_COEFF_CS),
					.exp_g_coeff_cs(EXP_G_COEFF_CS),
					.addIn(add_out),
					.negateIn(L_negate_out),
					.memIn(memOut),
					.addOutA(TL_Math5_addOutA),
					.addOutB(TL_Math5_addOutB),
					.negateOut(TL_Math5_L_negate_out),
					.memWriteAddr(TL_Math5_memWriteAddr),
					.memOut(TL_Math5_memIn),
					.memWriteEn(TL_Math5_memWriteEn),
					.memReadAddr(TL_Math5_memReadAddr),
					.done(Math5Done)
				);

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Corr_xy2
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	/*module Corr_xy2(clk,reset,start,shrIn,L_macIn,addIn,norm_lIn,norm_lDone,L_shlIn,L_shlDone,
					 L_addIn,subIn,L_negateIn,memIn,shrVar1Out,shrVar2Out,L_macOutA,L_macOutB,
					 L_macOutC,addOutA,addOutB,norm_lVar1Out,norm_lReady,L_shlVar1Out,L_shlNumShiftOut,
					 L_shlReady,L_addOutA,L_addOutB,subOutA,subOutB,L_negateOut,memReadAddr,memWriteAddr,
				    memOut,memWriteEn,done);*/
					

		Corr_xy2 Corr_xy2(
					.clk(clock),
					.reset(reset),
					.start(Corr_xy2Ready),
					.shrIn(shr_out),
					.L_macIn(L_mac_out),
					.addIn(add_out),
					.norm_lIn(norm_l_out),
					.norm_lDone(norm_l_done),
					.L_shlIn(L_shl_out),
					.L_shlDone(L_shl_done),
					.L_addIn(L_add_out),
					.subIn(sub_out),
					.L_negateIn(L_negate_out),
					.memIn(memOut),
					.shrVar1Out(Corr_xy2_shrVar1Out),
					.shrVar2Out(Corr_xy2_shrVar2Out),
					.L_macOutA(Corr_xy2_L_macOutA),
					.L_macOutB(Corr_xy2_L_macOutB),
					.L_macOutC(Corr_xy2_L_macOutC),
					.addOutA(Corr_xy2_addOutA),
					.addOutB(Corr_xy2_addOutB),
					.norm_lVar1Out(Corr_xy2_norm_l_out),
					.norm_lReady(Corr_xy2_norm_l_start),
					.L_shlVar1Out(Corr_xy2_L_shlOutVar1),
					.L_shlNumShiftOut(Corr_xy2_L_shlNumShiftOut),
					.L_shlReady(Corr_xy2_L_shlReady),
					.L_addOutA(Corr_xy2_L_addOutA),
					.L_addOutB(Corr_xy2_L_addOutB),
					.subOutA(Corr_xy2_subOutA),
					.subOutB(Corr_xy2_subOutB),
					.L_negateOut(Corr_xy2_L_negate_out),
					.memReadAddr(Corr_xy2_memReadAddr),
					.memWriteAddr(Corr_xy2_memWriteAddr),
					.memOut(Corr_xy2_memIn),
					.memWriteEn(Corr_xy2_memWriteEn),
					.done(Corr_xy2Done)
				);
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Qua_gain
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	/*module Qua_gain(clock,reset,start,done,out,tame_flag,
						L_mac_outa,L_mac_outb,L_mac_outc,L_mac_overflow,L_mac_in,
						L_msu_outa,L_msu_outb,L_msu_outc,L_msu_overflow,L_msu_in,
						L_mult_outa,L_mult_outb,L_mult_overflow,L_mult_in,
						L_add_outa,L_add_outb,L_add_overflow,L_add_in,
						L_sub_outa,L_sub_outb,L_sub_overflow,L_sub_in,
						L_shr_outa,L_shr_outb,L_shr_overflow,L_shr_in,
						L_shl_outa,L_shl_outb,L_shl_start,L_shl_in,L_shl_done,L_shl_overflow,
						norm_l_out,norm_l_start,norm_l_in,norm_l_done,
						mult_outa,mult_outb,mult_overflow,mult_in,
						shl_outa,shl_outb,shl_overflow,shl_in,
						add_outa,add_outb,add_overflow,add_in,
						sub_outa,sub_outb,sub_overflow,sub_in,
						scratch_mem_write_addr,scratch_mem_read_addr,
						scratch_mem_write_en,scratch_mem_out,scratch_mem_in,
						constant_mem_read_addr,constant_mem_in,
						L_negate_out,L_negate_in,
						shr_outa,shr_outb,shr_in);*/

												

		Qua_gain Qua_gain(
					.clock(clock),
					.reset(reset),
					.start(Qua_gainReady),
					.done(Qua_gainDone),
					.gain_pit(Qua_gain_gain_pit),
					.gain_cod(Qua_gain_gain_cod),
					.ANA(PRM),
					.i_subfr(i_subfr),
					.tame_flag(temp),
					.L_mac_outa(Qua_gain_L_macOutA),
					.L_mac_outb(Qua_gain_L_macOutB),
					.L_mac_outc(Qua_gain_L_macOutC),
					.L_mac_overflow(L_mac_overflow),
					.L_mac_in(L_mac_out),
					.L_msu_outa(Qua_gain_L_msuOutA),
					.L_msu_outb(Qua_gain_L_msuOutB),
					.L_msu_outc(Qua_gain_L_msuOutC),
					.L_msu_overflow(L_msu_overflow),
					.L_msu_in(L_msu_out),
					.L_mult_outa(Qua_gain_L_multOutA),
					.L_mult_outb(Qua_gain_L_multOutB),
					.L_mult_overflow(L_mult_overflow),
					.L_mult_in(L_mult_out),
					.L_add_outa(Qua_gain_L_addOutA),
					.L_add_outb(Qua_gain_L_addOutB),
					.L_add_overflow(L_add_overflow),
					.L_add_in(L_add_out),
					.L_sub_outa(Qua_gain_L_subOutA),
					.L_sub_outb(Qua_gain_L_subOutB),
					.L_sub_overflow(L_sub_overflow),
					.L_sub_in(L_sub_out),
					.L_shr_outa(Qua_gain_L_shrVar1Out),
					.L_shr_outb(Qua_gain_L_shrNumShiftOut),
					.L_shr_overflow(L_shr_overflow),
					.L_shr_in(L_shr_out),
					.L_shl_outa(Qua_gain_L_shlOutVar1),
					.L_shl_outb(Qua_gain_L_shlNumShiftOut),
					.L_shl_start(Qua_gain_L_shlReady),
					.L_shl_in(L_shl_out),
					.L_shl_done(L_shl_done),
					.L_shl_overflow(L_shl_overflow),
					.norm_l_out(Qua_gain_norm_l_out),
					.norm_l_start(Qua_gain_norm_l_start),
					.norm_l_in(norm_l_out),		
					.norm_l_done(norm_l_done),
					.mult_outa(Qua_gain_multOutA),
					.mult_outb(Qua_gain_multOutB),
					.mult_overflow(mult_overflow),
					.mult_in(mult_out),
					.shl_outa(Qua_gain_shlVar1Out),
					.shl_outb(Qua_gain_shlVar2Out),
					.shl_overflow(shl_overflow),
					.shl_in(shl_out),
					.add_outa(Qua_gain_addOutA),
					.add_outb(Qua_gain_addOutB),
					.add_overflow(add_overflow),
					.add_in(add_out),
					.sub_outa(Qua_gain_subOutA),
					.sub_outb(Qua_gain_subOutB),
					.sub_overflow(sub_overflow),
					.sub_in(sub_out),
					.scratch_mem_write_addr(Qua_gain_memWriteAddr),
					.scratch_mem_read_addr(Qua_gain_memReadAddr),
					.scratch_mem_write_en(Qua_gain_memWriteEn),
					.scratch_mem_out(Qua_gain_memIn),
					.scratch_mem_in(memOut),
					.constant_mem_read_addr(Qua_gain_constantMemAddr),
					.constant_mem_in(constantMemOut),
					.L_negate_out(Qua_gain_L_negate_out),
					.L_negate_in(L_negate_out),
					.shr_outa(Qua_gain_shrVar1Out),
					.shr_outb(Qua_gain_shrVar2Out),
					.shr_in(shr_out)
				);


	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Math 6
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

		TL_Math6 TL_Math6(
					.clock(clock),
					.reset(reset),
					.start(Math6Ready),
					.gain_pit(gain_pit),
					.gain_code(gain_code),
					.SHARPMIN(SHARPMIN),
					.SHARPMAX(SHARPMAX),
					.exc(EXC),
					.i_subfr(i_subfr),
					.code(CODE),
					.L_SUBFR(L_SUBFR),
					.L_multIn(L_mult_out),
					.L_macIn(L_mac_out),
					.L_shlIn(L_shl_out),
					.L_shlDone(L_shl_done),
					.addIn(add_out),
					.subIn(sub_out),
					.memIn(memOut),
					.L_addIn(L_add_out),
					.sharp(TL_Math6_nextsharp),
					.L_temp(TL_Math6_nextL_temp),
					.L_multOutA(TL_Math6_L_multOutA),
					.L_multOutB(TL_Math6_L_multOutB),
					.L_macOutA(TL_Math6_L_macOutA),
					.L_macOutB(TL_Math6_L_macOutB),
					.L_macOutC(TL_Math6_L_macOutC),
					.L_shlReady(TL_Math6_L_shlReady),
					.L_shlOutA(TL_Math6_L_shlOutVar1),
					.L_shlOutB(TL_Math6_L_shlNumShiftOut),
					.addOutA(TL_Math6_addOutA),
					.addOutB(TL_Math6_addOutB),
					.subOutA(TL_Math6_subOutA),
					.subOutB(TL_Math6_subOutB),
					.memWriteAddr(TL_Math6_memWriteAddr),
					.memOut(TL_Math6_memIn),
					.memWriteEn(TL_Math6_memWriteEn),
					.memReadAddr(TL_Math6_memReadAddr),
					.L_addOutA(TL_Math6_L_addOutA),
					.L_addOutB(TL_Math6_L_addOutB),
					.done(Math6Done)
				);
				
	//////////////////////////////////////////////////////////////////////////////////////////////
	//000000000000000000000000000000000000000000000000
	//		update_exc_err
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	/*module update_exc_err(clock,reset,start,done,gain_pit,T0,
								sub_outa,sub_outb,sub_in,
								L_shl_outa,L_shl_outb,L_shl_in,L_shl_start,L_shl_done,
								L_add_outa,L_add_outb,L_add_in,
								L_sub_outa,L_sub_outb,L_sub_in,
								add_outa,add_outb,add_in,
								L_mac_outa,L_mac_outb,L_mac_outc,L_mac_in,L_mac_overflow,
								L_mult_outa,L_mult_outb,L_mult_in,L_mult_overflow,
								mult_outa,mult_outb,mult_in,mult_overflow,
								L_msu_outa,L_msu_outb,L_msu_outc,L_msu_in,
								L_shr_outa,L_shr_outb,L_shr_in,
								scratch_mem_read_addr,scratch_mem_write_addr,
								scratch_mem_out,scratch_mem_in,
								scratch_mem_write_en,
								constant_mem_read_addr,constant_mem_in);*/
								

		update_exc_err update_exc_err(
					.clock(clock),
					.reset(reset),
					.start(update_exc_errReady),
					.done(update_exc_errDone),
					.gain_pit(gain_pit),
					.T0(T0),
					.sub_outa(update_exc_err_subOutA),
					.sub_outb(update_exc_err_subOutB),
					.sub_in(sub_out),
					.L_shl_outa(update_exc_err_L_shlOutVar1),
					.L_shl_outb(update_exc_err_L_shlNumShiftOut),
					.L_shl_in(L_shl_out),
					.L_shl_start(update_exc_err_L_shlReady),
					.L_shl_done(L_shl_done),
					.L_add_outa(update_exc_err_L_addOutA),
					.L_add_outb(update_exc_err_L_addOutB),
					.L_add_in(L_add_out),
					.L_sub_outa(update_exc_err_L_subOutA),
					.L_sub_outb(update_exc_err_L_subOutB),
					.L_sub_in(L_sub_out),
					.add_outa(update_exc_err_addOutA),
					.add_outb(update_exc_err_addOutB),
					.add_in(add_out),
					.L_mac_outa(update_exc_err_L_macOutA),
					.L_mac_outb(update_exc_err_L_macOutB),
					.L_mac_outc(update_exc_err_L_macOutC),
					.L_mac_in(L_mac_out),
					.L_mac_overflow(L_mac_overflow),
					.L_mult_outa(update_exc_err_L_multOutA),
					.L_mult_outb(update_exc_err_L_multOutB),
					.L_mult_in(L_mult_out),
					.L_mult_overflow(L_mult_overflow),
					.mult_outa(update_exc_err_multOutA),
					.mult_outb(update_exc_err_multOutB),
					.mult_in(mult_out),
					.mult_overflow(mult_overflow),
					.L_msu_outa(update_exc_err_L_msuOutA),
					.L_msu_outb(update_exc_err_L_msuOutB),
					.L_msu_outc(update_exc_err_L_msuOutC),
					.L_msu_in(L_msu_out),
					.L_shr_outa(update_exc_err_L_shrVar1Out),
					.L_shr_outb(update_exc_err_L_shrNumShiftOut),
					.L_shr_in(L_shr_out),
					.scratch_mem_read_addr(update_exc_err_memReadAddr),
					.scratch_mem_write_addr(update_exc_err_memWriteAddr),
					.scratch_mem_out(update_exc_err_memIn),
					.scratch_mem_in(memOut),
					.scratch_mem_write_en(update_exc_err_memWriteEn),
					.constant_mem_read_addr(update_exc_err_constantMemAddr),
					.constant_mem_in(constantMemOut)
				);
								
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Math 7
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
		
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Copy
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	/*module copy(clk,reset,start,xAddr,yAddr,L,memIn,addIn,L_addIn,
				addOutA,addOutB,L_addOutA,L_addOutB,memWriteAddr,memReadAddr,memWriteEn,memOut,done);*/
	
/*		copy copy(
					.clk(clock),
					.reset(reset),
					.start(CopyReady),
					.xAddr(),
					.yAddr(),
					.L(),
					.memIn(memOut),
					.addIn(add_out),
					.L_addIn(L_add_out),
					.addOutA(Copy_addOutA),
					.addOutB(Copy_addOutB),
					.L_addOutA(Copy_L_addOutA),
					.L_addOutB(Copy_L_addOutB),
					.memWriteAddr(Copy_memWriteAddr),
					.memReadAddr(Copy_memReadAddr),
					.memWriteEn(Copy_memWriteEn),
					.memOut(Copy_memIn),
					.done(CopyDone)
				);*/	
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		prm2bits_ld8kDone
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	/*module prm2bits_ld8k(clock,reset,start,done,add_outa,add_outb,add_in,constant_mem_read_addr,
							constant_mem_in,scratch_mem_read_addr,scratch_mem_write_addr,scratch_mem_in,
							scratch_mem_out,scratch_mem_write_en,L_add_outa,L_add_outb,L_add_in,sub_outa,
							sub_outb,sub_in);*/
							
/*		prm2bits_ld8k prm2bits_ld8k(
					.clock(clock),
					.reset(reset),
					.start(prm2bits_ld8kReady),
					.done(prm2bits_ld8kDone),
					.add_outa(prm2bits_ld8k_addOutA),
					.add_outb(prm2bits_ld8k_addOutB),
					.add_in(add_out),
					.constant_mem_read_addr(prm2bits_ld8k_constantMemAddr),
					.constant_mem_in(constantMemOut),
					.scratch_mem_read_addr(prm2bits_ld8k_memReadAddr),
					.scratch_mem_write_addr(prm2bits_ld8k_memWriteAddr),
					.scratch_mem_in(memOut),
					.scratch_mem_out(prm2bits_ld8k_memIn),
					.scratch_mem_write_en(prm2bits_ld8k_memWriteEn),
					.L_add_outa(prm2bits_ld8k_L_addOutA),
					.L_add_outb(prm2bits_ld8k_L_addOutB),
					.L_add_in(L_add_out),
					.sub_outa(prm2bits_ld8k_subOutA),
					.sub_outb(prm2bits_ld8k_subOutB),
					.sub_in(sub_out)
				);
*/							
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		divErr always block(checking for divide by zero errors)
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	always @(*)
	begin		
		if(Az_divErr)
			divErr = 1;
		else 
			divErr = 0;
	end

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Output buffer memory
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	reg outBufWriteEn;
	reg [11:0] outBufWriteAddr;
	reg [31:0] outBufIn;
	reg [7:0] sample_count, nextsample_count;
	reg [5:0] state, nextstate;
	reg sample_countLD;
	
	parameter PRE_PROCESS = 6'd0;
	parameter AUTOCORR = 6'd1;
	parameter LAG_WINDOW = 6'd2;
	parameter LEVINSON = 6'd3;
	parameter AZ_LSP = 6'd4;
	parameter QUA_LSP = 6'd5;
	parameter INT_LPC = 6'd6;
	parameter INT_QLPC = 6'd7;
	parameter TL_MATH1 = 6'd8;
	parameter PERC_VAR = 6'd9;
	parameter WEIGHT_AZ1 = 6'd10;
	parameter WEIGHT_AZ2 = 6'd11;
	parameter RESIDU1 = 6'd12;
	parameter SYN_FILT1 = 6'd13;
	parameter WEIGHT_AZ3 = 6'd14;
	parameter WEIGHT_AZ4 = 6'd15;
	parameter RESIDU2 = 6'd16;
	parameter SYN_FILT2 = 6'd17;
	parameter PITCH_OL = 6'd18;
	parameter TL_MATH2 = 6'd19;
	parameter WEIGHT_AZ5 = 6'd20;
	parameter WEIGHT_AZ6 = 6'd21;
	parameter TL_MATH3 = 6'd22;
	parameter SYN_FILT3 = 6'd23;
	parameter SYN_FILT4 = 6'd24;
	parameter RESIDU3 = 6'd25;
	parameter SYN_FILT5 = 6'd26;
	parameter RESIDU4 = 6'd27;
	parameter SYN_FILT6 = 6'd28;
	parameter PITCH_FR3 = 6'd29;
	parameter ENC_LAG3 = 6'd30;
	parameter PRED_LT_3 = 6'd31;
	parameter CONVOLVE = 6'd32;
	parameter G_PITCH = 6'd33;
	parameter TEST_ERR = 6'd34;
	parameter TL_MATH4 = 6'd35;
	parameter ACELP_CODEBOOK = 6'd36;
	parameter TL_MATH5 = 6'd37;
	parameter CORR_XY2 = 6'd38;
	parameter QUA_GAIN = 6'd39;
	parameter TL_MATH6 = 6'd40;
	parameter UPDATE_EXC_ERR = 6'd41;
	parameter SYN_FILT7 = 6'd42;

	always @ (posedge clock)
	begin
		if (reset)
			state = PRE_PROCESS;
		else
			state = nextstate;
	end
	
	always @ (posedge clock)
	begin
		if (reset)
			sample_count = 'd0;
		else if (sample_countLD == 'd1)
		begin
			if (sample_count == 'd79)
				sample_count = 'd0;
			else
				sample_count = sample_count + 'd1;
		end
	end
	
	always @(*)
	begin
		nextstate = state;
		outBufWriteEn = 0;
		outBufWriteAddr = 0;
		outBufIn = 0;
		sample_countLD = 0;
		case (state)
			PRE_PROCESS:
			begin
				if (preProcDone)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = sample_count + NEW_SPEECH;
					outBufIn = yn;
					sample_countLD = 'd1;
				end
				if (autocorrReady)
					nextstate = AUTOCORR;
			end
			AUTOCORR:
			begin
				if ((addra >= AUTOCORR_R && addra < (AUTOCORR_R+'d16)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (autocorrDone)
					nextstate = LAG_WINDOW;
			end
			LAG_WINDOW:
			begin
				if ((addra >= LAG_WINDOW_R_PRIME && addra < (LAG_WINDOW_R_PRIME+'d16)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (lagDone)
					nextstate = LEVINSON;
			end
			LEVINSON:
			begin
				if (((addra >= A_T_HIGH && addra < (A_T_HIGH+16))||(addra >= LEVINSON_DURBIN_RC && addra < (LEVINSON_DURBIN_RC+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (levinsonDone)
					nextstate = AZ_LSP;
			end
			AZ_LSP:
			begin
				if ((addra >= LSP_NEW && addra < (LSP_NEW+'d16)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (AzDone)
					nextstate = QUA_LSP;
			end
			QUA_LSP:
			begin
				if (((addra >= LSP_NEW_Q && addra < (LSP_NEW_Q+16))||(addra >= PRM && addra < (PRM+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Qua_lspDone)
					nextstate = INT_LPC;
			end
			INT_LPC:
			begin
			if(((addra >= INTERPOLATION_LSF_INT && addra < (INTERPOLATION_LSF_INT+'d16))||(addra >= INTERPOLATION_LSF_NEW && addra < (INTERPOLATION_LSF_NEW+'d16))||(addra >= A_T_LOW && addra < (A_T_LOW+'d16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Int_lpcDone)
					nextstate = INT_QLPC;
			end
			INT_QLPC:
			begin
				if (((addra >= AQ_T_LOW && addra < (AQ_T_LOW+16))||(addra >= AQ_T_HIGH && addra < (AQ_T_HIGH+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Int_qlpcDone)
					nextstate = TL_MATH1;
			end
			TL_MATH1:
			begin
				if (((addra >= LSP_OLD && addra < (LSP_OLD+16))||(addra >= LSP_OLD_Q && addra < (LSP_OLD_Q+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Math1Done)
					nextstate = PERC_VAR;
			end
			PERC_VAR:
			begin
				if (((addra >= PERC_VAR_GAMMA1 && addra < (PERC_VAR_GAMMA1+2))||(addra >= PERC_VAR_GAMMA2 && addra < (PERC_VAR_GAMMA2+2))||(addra >= INTERPOLATION_LSF_INT && addra < (INTERPOLATION_LSF_INT+16))||(addra >= INTERPOLATION_LSF_NEW && addra < (INTERPOLATION_LSF_NEW+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (perc_varDone)
					nextstate = WEIGHT_AZ1;
			end
			WEIGHT_AZ1:
			begin
				if ((addra >= WEIGHT_AZ_AP_OUT && addra < (WEIGHT_AZ_AP_OUT+'d16)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Weight_AzDone)
					nextstate = WEIGHT_AZ2;
			end
			WEIGHT_AZ2:
			begin
				if ((addra >= WEIGHT_AZ_AP_OUT2 && addra < (WEIGHT_AZ_AP_OUT2+'d16)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Weight_AzDone)
					nextstate = RESIDU1;
			end
			RESIDU1:
			begin
				if ((addra >= WSP && addra < (WSP+'d64)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (ResiduDone)
					nextstate = SYN_FILT1;
			end
			SYN_FILT1:
			begin
				if (((addra >= WSP && addra < (WSP+'d64))||(addra >= MEM_W && addra < (MEM_W+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Syn_filtDone)
					nextstate = WEIGHT_AZ3;
			end
			WEIGHT_AZ3:
			begin
				if ((addra >= WEIGHT_AZ_AP_OUT && addra < (WEIGHT_AZ_AP_OUT+'d16)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Weight_AzDone)
					nextstate = WEIGHT_AZ4;
			end
			WEIGHT_AZ4:
			begin
				if ((addra >= WEIGHT_AZ_AP_OUT2 && addra < (WEIGHT_AZ_AP_OUT2+'d16)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Weight_AzDone)
					nextstate = RESIDU2;
			end
			RESIDU2:
			begin
				if ((addra >= (WSP+L_SUBFR) && addra < ((WSP+L_SUBFR)+'d64)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (ResiduDone)
					nextstate = SYN_FILT2;
			end
			SYN_FILT2:
			begin
				if (((addra >= (WSP+L_SUBFR) && addra < ((WSP+L_SUBFR)+'d64))||(addra >= MEM_W && addra < (MEM_W+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Syn_filtDone)
					nextstate = PITCH_OL;
			end
			PITCH_OL:
			begin
				if (addra == T_OP && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Pitch_olDone)
					nextstate = TL_MATH2;
			end
			TL_MATH2:
			begin
				if (Math2Done)
					nextstate = WEIGHT_AZ5;
			end
			WEIGHT_AZ5:
			begin
				if ((addra >= WEIGHT_AZ_AP_OUT && addra < (WEIGHT_AZ_AP_OUT+'d16)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Weight_AzDone)
					nextstate = WEIGHT_AZ6;
			end
			WEIGHT_AZ6:
			begin
				if ((addra >= WEIGHT_AZ_AP_OUT2 && addra < (WEIGHT_AZ_AP_OUT2+'d16)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Weight_AzDone)
					nextstate = TL_MATH3;
			end
			TL_MATH3:
			begin
				if ((addra >= AI_ZERO && addra < (AI_ZERO+'d64)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Math3Done)
					nextstate = SYN_FILT3;
			end
			SYN_FILT3:
			begin
				if (((addra >= H1 && addra < (H1+'d64))||(addra >= ZERO && addra < (ZERO+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Syn_filtDone)
					nextstate = SYN_FILT4;
			end
			SYN_FILT4:
			begin
				if (((addra >= H1 && addra < (H1+'d64))||(addra >= ZERO && addra < (ZERO+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Syn_filtDone)
				begin
					nextstate = RESIDU3;
				end
			end
			RESIDU3:
			begin
				if (i_subfr == 'd40)
					if ((addra >= (EXC+L_SUBFR) && addra < ((EXC+L_SUBFR)+'d64)) && wea == 1)
					begin
						outBufWriteEn = 1;
						outBufWriteAddr = addra;
						outBufIn = dina;
					end
				else
					if ((addra >= EXC && addra < (EXC+'d64)) && wea == 1)
					begin
						outBufWriteEn = 1;
						outBufWriteAddr = addra;
						outBufIn = dina;
					end
				if (ResiduDone)
					nextstate = SYN_FILT5;
			end
			SYN_FILT5:
			begin
				if (((addra >= ERROR && addra < (ERROR+'d64))||(addra >= MEM_ERR && addra < (MEM_ERR+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Syn_filtDone)
					nextstate = RESIDU4;
			end
			RESIDU4:
			begin
				if ((addra >= XN && addra < (XN+'d64)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (ResiduDone)
					nextstate = SYN_FILT6;
			end
			SYN_FILT6:
			begin
				if (((addra >= XN && addra < (XN+'d64))||(addra >= MEM_W0 && addra < (MEM_W0+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Syn_filtDone)
					nextstate = PITCH_FR3;
			end
			PITCH_FR3:
			begin
				if (Pitch_fr3Done)
					nextstate = ENC_LAG3;
			end
			ENC_LAG3:
			begin
				if (Enc_lag3Done)
					nextstate = PRED_LT_3;
			end
			PRED_LT_3:
			begin
				if (i_subfr == 'd40)
					if ((addra >= (EXC+L_SUBFR) && addra < ((EXC+L_SUBFR)+'d64)) && wea == 1)
					begin
						outBufWriteEn = 1;
						outBufWriteAddr = addra;
						outBufIn = dina;
					end
				else
					if ((addra >= EXC && addra < (EXC+'d64)) && wea == 1)
					begin
						outBufWriteEn = 1;
						outBufWriteAddr = addra;
						outBufIn = dina;
					end
				if (Pred_lt_3Done)
					nextstate = CONVOLVE;
			end
			CONVOLVE:
			begin
				if ((addra >= Y1 && addra < (Y1+'d64)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (ConvolveDone)
					nextstate = G_PITCH;
			end
			G_PITCH:
			begin
				if (G_pitchDone)
					nextstate = TEST_ERR;
			end
			TEST_ERR:
			begin
				if (test_errDone)
					nextstate = TL_MATH4;
			end
			TL_MATH4:
			begin
				if (((addra >= XN2 && addra < (XN2+'d64))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Math4Done)
					nextstate = ACELP_CODEBOOK;
			end
			ACELP_CODEBOOK:
			begin
				if (((addra >= CODE && addra < (CODE+'d64))||(addra >= Y2 && addra < (Y2+64))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (ACELP_CodebookDone)
					nextstate = TL_MATH5;
			end
			TL_MATH5:
			begin
				if (((addra >= G_COEFF_CS && addra < (G_COEFF_CS+'d8))||(addra >= EXP_G_COEFF_CS && addra < (EXP_G_COEFF_CS+8))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Math5Done)
					nextstate = CORR_XY2;
			end
			CORR_XY2:
			begin
				if (((addra >= G_COEFF_CS && addra < (G_COEFF_CS+'d8))||(addra >= EXP_G_COEFF_CS && addra < (EXP_G_COEFF_CS+8))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Corr_xy2Done)
					nextstate = QUA_GAIN;
			end
			QUA_GAIN:
			begin
				if (Qua_gainDone)
					nextstate = TL_MATH6;
			end
			TL_MATH6:
			begin
				if ((addra >= (EXC+i_subfr) && addra < ((EXC+i_subfr)+'d64)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Math6Done)
					nextstate = UPDATE_EXC_ERR;
			end
			UPDATE_EXC_ERR:
			begin
				if ((addra >= L_EXC_ERR && addra < (L_EXC_ERR+'d4)) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (update_exc_errDone)
					nextstate = SYN_FILT7;
			end
			SYN_FILT7:
			begin
				if (((addra >= (SYN+i_subfr) && addra < ((SYN+i_subfr)+'d64))||(addra >= MEM_SYN && addra < (MEM_SYN+16))) && wea == 1)
				begin
					outBufWriteEn = 1;
					outBufWriteAddr = addra;
					outBufIn = dina;
				end
				if (Syn_filtDone)
				begin
					if (i_subfr == 'd40)
						nextstate = PRE_PROCESS;
					else
						nextstate = WEIGHT_AZ5;
				end
			end
		endcase
	end
	
		Scratch_Memory_Controller outBuf_mem(
															.addra(outBufWriteAddr),
															.dina(outBufIn),
															.wea(outBufWriteEn),
															.clk(clock),
															.addrb(outBufAddr),
															.doutb(out)
															);
															
endmodule
