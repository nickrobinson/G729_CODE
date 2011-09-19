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
						Int_lpcReady,Int_qlpcReady,Math1Ready,mathMuxSel,frame_done,autocorrDone,lagDone,levinsonDone,
						AzDone,Qua_lspDone,Int_lpcDone,Int_qlpcDone,Math1Done,divErr,outBufAddr,out);

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
	input [5:0] mathMuxSel;
	input [11:0] outBufAddr;
	
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
	output reg divErr;
	output [31:0] out;	
	
	//done signals
	wire norm_l_done,norm_s_done,L_shl_done;
	
	//overflow signals
	wire L_mult_overflow,mult_overflow,L_mac_overflow,L_msu_overflow,L_add_overflow,L_sub_overflow,
				L_shl_overflow,add_overflow,sub_overflow,shr_overflow,shl_overflow;
				
	//output signals
	wire [15:0] mult_out,norm_l_out,norm_s_out,add_out,sub_out,shr_out,shl_out;
	wire [31:0] L_mult_out,L_mac_out,L_msu_out,L_add_out,L_sub_out,L_shl_out,L_shr_out,L_abs_out,
						L_negate_out;
						
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
	wire [15:0] autocorrIn;
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
	
	
//	//perc_var Wires
//	wire perc_varReady;
//	wire [15:0] perc_var_shlOutVar1;
//	wire [15:0] perc_var_shlOutVar2;
//	wire [15:0] perc_var_shrVar1Out;
//	wire [15:0] perc_var_shrVar2Out;
//	wire [15:0] perc_var_subOutA;
//	wire [15:0] perc_var_subOutB;
//	wire [15:0] perc_var_L_multOutA;
//	wire [15:0] perc_var_L_multOutB;
//	wire [31:0] perc_var_L_subOutA;
//	wire [31:0] perc_var_L_subOutB;
//	wire [31:0] perc_var_L_shrVar1Out;
//	wire [15:0] perc_var_L_shrNumShiftOut;
//	wire [31:0] perc_var_L_addOutA;
//	wire [31:0] perc_var_L_addOutB;
//	wire [15:0] perc_var_addOutA;
//	wire [15:0] perc_var_addOutB;
//	wire [15:0] perc_var_multOutA;
//	wire [15:0] perc_var_multOutB;
//	wire [11:0] perc_var_memReadAddr;
//	wire [11:0] perc_var_memWriteAddr;
//	wire perc_var_memWriteEn;
//	wire [31:0] perc_var_memIn;
//	wire perc_varDone;	

	
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
			.in6(Int_qlpc_L_multOutA),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
			.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_mult_a));
	
	mux128_16 i_mux128_16_L_mult_b(
											.in0(autocorr_zero16),
											.in1(lag_L_multOutB),
											.in2(levinson_L_mult_outb),
											.in3(Az_L_multOutB),
											.in4(Qua_lsp_L_multOutB),.in5(Int_lpc_L_multOutB),
			.in6(Int_qlpc_L_multOutB),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
			.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_mult_b));
	
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
			.in6(Int_qlpc_multOutA),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
			.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(mult_a));
			
	mux128_16 i_mux128_16_mult_b(
											.in0(autocorr_multOutB),
											.in1(lag_multOutB),
											.in2(levinson_mult_outb),
											.in3(Az_multOutB),
											.in4(Qua_lsp_multOutB),.in5(Int_lpc_multOutB),
			.in6(Int_qlpc_multOutB),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
			.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(mult_b));
	
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
			.in6(Int_qlpc_L_macOutA),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
			.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_mac_a));
			
	mux128_16 i_mux128_16_L_mac_b(
											.in0(autocorr_L_macOutB),
											.in1(lag_L_macOutB),
											.in2(levinson_L_mac_outb),
											.in3(Az_L_macOutB),
											.in4(Qua_lsp_L_macOutB),.in5(Int_lpc_L_macOutB),
		.in6(Int_qlpc_L_macOutB),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_mac_b));
			
	mux128_32 i_mux128_32_L_mac_c(
											.in0(autocorr_L_macOutC),
											.in1(lag_L_macOutC),
											.in2(levinson_L_mac_outc),
											.in3(Az_L_macOutC),
											.in4(Qua_lsp_L_macOutC),.in5(Int_lpc_L_macOutC),
		.in6(Int_qlpc_L_macOutC),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in6(Int_qlpc_L_msuOutA),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_msu_a));
			
	mux128_16 i_mux128_16_L_msu_b(
											.in0(autocorr_L_msuOutB),
											.in1(lag_L_msuOutB),
											.in2(0),
											.in3(Az_L_msuOutB),
											.in4(Qua_lsp_L_msuOutB),.in5(Int_lpc_L_msuOutB),
		.in6(Int_qlpc_L_msuOutB),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_msu_b));
			
	mux128_32 i_mux128_32_L_msu_c(
											.in0(autocorr_L_msuOutC),
											.in1(lag_L_msuOutC),
											.in2(0),
											.in3(Az_L_msuOutC),
											.in4(Qua_lsp_L_msuOutC),.in5(Int_lpc_L_msuOutC),
		.in6(Int_qlpc_L_msuOutC),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_msu_c));
		
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
		.in6(Int_qlpc_L_addOutA),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_add_a));
		
	mux128_32 i_mux128_32_L_add_b(
											.in0(autocorr_zero32),
											.in1(lag_zero32),
											.in2(levinson_L_add_outb),
											.in3(Az_L_addOutB),
											.in4(Qua_lsp_L_addOutB),.in5(Int_lpc_L_addOutB),
		.in6(Int_qlpc_L_addOutB),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_add_b));
		
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
		.in6(Int_qlpc_L_subOutA),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_sub_a));
		
	mux128_32 i_mux128_32_L_sub_b(
											.in0(autocorr_zero32),
											.in1(lag_zero32),
											.in2(levinson_L_sub_outb),
											.in3(Az_L_subOutB),
											.in4(Qua_lsp_L_subOutB),.in5(Int_lpc_L_subOutB),
		.in6(Int_qlpc_L_subOutB),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_sub_b));
	
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(norm_l_a));
		
	mux128_1 i_mux128_1_norm_l_start(
												.in0(autocorr_norm_lReady),
												.in1(lag_zero),
												.in2(levinson_norm_L_start),
												.in3(Az_zero),
												.in4(0),.in5(Int_lpc_norm_l_start),
		.in6(Int_qlpc_norm_l_start),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in6(Int_qlpc_L_shlOutVar1),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_shl_a));
		
	mux128_16 i_mux128_16_L_shl_b(
											.in0(autocorr_L_shlNumShiftOut),
											.in1(lag_zero16),
											.in2(levinson_L_shl_outb),
											.in3(Az_L_shlNumShiftOut),
											.in4(Qua_lsp_L_shlNumShiftOut),.in5(Int_lpc_L_shlNumShiftOut),
		.in6(Int_qlpc_L_shlNumShiftOut),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_shl_b));
		
	mux128_1 i_mux128_1_L_shl_start(
												.in0(autocorr_L_shlReady),
												.in1(lag_zero),
												.in2(levinson_L_shl_start),
												.in3(Az_L_shlReady),
												.in4(Qua_lsp_L_shlReady),.in5(Int_lpc_L_shlReady),
		.in6(Int_qlpc_L_shlReady),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
						.overflow(),
						.out(L_shr_out));		
						
	mux128_32 i_mux128_32_L_shr_a(
											.in0(autocorr_L_shrVar1Out),
											.in1(lag_L_shrOutVar1),
											.in2(levinson_L_shr_outa),
											.in3(Az_L_shrOutVar1),
											.in4(Qua_lsp_L_shrVar1Out),.in5(Int_lpc_L_shrVar1Out),
		.in6(Int_qlpc_L_shrVar1Out),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_shr_a));
		
	mux128_16 i_mux128_16_L_shr_b(
											.in0(autocorr_L_shrNumShiftOut),
											.in1(lag_L_shrOutNumShift),
											.in2(levinson_L_shr_outb),
											.in3(Az_L_shrOutNumShift),
											.in4(Qua_lsp_L_shrNumShiftOut),.in5(Int_lpc_L_shrNumShiftOut),
		.in6(Int_qlpc_L_shrNumShiftOut),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_shr_b));
	
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_abs_a));
	
		
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(L_negate_a));
	
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
		.in6(Int_qlpc_addOutA),.in7(Math1_addOutA),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(add_a));
	
	mux128_16 i_mux128_16_add_b(
											.in0(autocorr_addOutB),
											.in1(lag_addOutB),
											.in2(levinson_add_outb),
											.in3(Az_addOutB),
											.in4(Qua_lsp_addOutB),.in5(Int_lpc_addOutB),
		.in6(Int_qlpc_addOutB),.in7(Math1_addOutB),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(add_b));
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
		.in6(Int_qlpc_subOutA),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(sub_a));
	
	mux128_16 i_mux128_16_sub_b(
											.in0(autocorr_subOutB),
											.in1(lag_zero16),
											.in2(levinson_sub_outb),
											.in3(Az_subOutB),
											.in4(Qua_lsp_subOutB),.in5(Int_lpc_subOutB),
		.in6(Int_qlpc_subOutB),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(sub_b));
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
		.in6(Int_qlpc_shrVar1Out),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(shr_var1));
	
	mux128_16 i_mux128_16_shr_var2(
												.in0(autocorr_shrVar2Out),
												.in1(lag_zero16),
												.in2(0),
												.in3(Az_shrOutVar2),
												.in4(Qua_lsp_shrVar2Out),.in5(Int_lpc_shrVar2Out),
		.in6(Int_qlpc_shrVar2Out),.in7(0),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(shr_var2));
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(shl_var1));
	
	mux128_16 i_mux128_16_shl_var2(
												.in0(autocorr_zero16),
												.in1(lag_zero16),
												.in2(0),
												.in3(Az_zer016),
												.in4(Qua_lsp_shlOutVar2),.in5(Int_lpc_shlOutVar2),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(shl_var2));
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
		.in6(Int_qlpc_memWriteAddr),.in7(Math1_memWriteAddr),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(addra));
		
		mux128_32 i_mux128_32_scratch_dina(
														.in0(autocorrScratchMemOut),
														.in1(lag_scratchMemOut),
														.in2(levinson_scratch_mem_out),
														.in3(Az_scratchMemOut),
														.in4(Qua_lsp_memIn),.in5(Int_lpc_memIn),
		.in6(Int_qlpc_memIn),.in7(Math1_memIn),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(dina));
		
		mux128_1 i_mux128_1_scratch_wea(
														.in0(autocorrScratchWriteEn),
														.in1(lag_scratchWriteEn),
														.in2(levinson_scratch_mem_write_en),
														.in3(Az_scratchWriteEn),
														.in4(Qua_lsp_memWriteEn),.in5(Int_lpc_memWriteEn),
		.in6(Int_qlpc_memWriteEn),.in7(Math1_memWriteEn),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
		.in122(0),.in123(0),.in124(0),.in125(0),.in126(0),.in127(0),.sel(mathMuxSel),.out(wea));
		
		mux128_12 i_mux128_12_scratch_addrb(
														.in0(autocorrScratchReadRequested),
														.in1(lag_scratchReadRequested),
														.in2(levinson_scratch_mem_read_addr),
														.in3(Az_scratchReadRequested),
														.in4(Qua_lsp_memReadAddr),.in5(Int_lpc_memReadAddr),
		.in6(Int_qlpc_memReadAddr),.in7(Math1_memReadAddr),.in8(0),.in9(0),.in10(0),.in11(0),.in12(0),.in13(0),.in14(0),.in15(0),
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
											.Out_Sample(autocorrIn), 
											.frame_done(frame_done)
											);
			//pre-proc/autocorr memory read address mux	
		mux128_11 i_mux128_11_pre_proc_mem_addr(
														.in0(autocorrRequested),
														.in1(autocorrRequested),
														.in2(autocorrRequested),
														.in3(autocorrRequested),
														.in4(autocorrRequested),.in5(0),
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
										 .xIn(autocorrIn),
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
	

		TL_Math1 Math1(
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
	
	
//	//////////////////////////////////////////////////////////////////////////////////////////////
//	//
//	//		perc_var
//	//
//	//////////////////////////////////////////////////////////////////////////////////////////////
//
//	
//	   percVarFSM perc_var(
//					 .clk(clock),
//					 .reset(reset),
//					 .start(perc_varReady),
//					 .shlIn(shl_out),
//					 .shrIn(shr_out),
//					 .subIn(sub_out),
//					 .L_multIn(L_mult_out),
//					 .L_subIn(L_sub_out),
//					 .L_shrIn(L_shr_out),
//					 .L_addIn(L_add_out),
//					 .addIn(add_out),
//					 .multIn(mult_out),
//					 .memIn(memOut),
//					 .shlVar1Out(perc_var_shlOutVar1),
//					 .shlVar2Out(perc_var_shlOutVar2),
//					 .shrVar1Out(perc_var_shrVar1Out),
//					 .shrVar2Out(perc_var_shrVar2Out),
//					 .subOutA(perc_var_subOutA),
//					 .subOutB(perc_var_subOutB),
//					 .L_multOutA(perc_var_L_multOutA),
//					 .L_multOutB(perc_var_L_multOutB),
//					 .L_subOutA(perc_var_L_subOutA),
//					 .L_subOutB(perc_var_L_subOutB),
//					 .L_shrOutVar1(perc_var_L_shrVar1Out),
//					 .L_shrOutNumShift(perc_var_L_shrNumShiftOut),
//					 .L_addOutA(perc_var_L_addOutA),
//					 .L_addOutB(perc_var_L_addOutB),
//					 .addOutA(perc_var_addOutA),
//					 .addOutB(perc_var_addOutB),
//					 .multOutA(perc_var_multOutA),
//					 .multOutB(perc_var_multOutB),
//					 .memReadAddr(perc_var_memReadAddr),
//					 .memWriteAddr(perc_var_memWriteAddr),
//					 .memWrite(perc_var_memWriteEn),
//					 .memOut(perc_var_memIn),
//					 .done(perc_varDone)
//				);
	

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
	
	always @(*)
	begin
		//if(((addra >= 12'd416 && addra < 12'd432)||(addra >= 12'd432 && addra < 12'd448)||(addra >= 12'd768 && addra < 12'd784)) && wea == 1)
		if(((addra >= 12'd400 && addra < 12'd416)||(addra >= 12'd736 && addra < 12'd752)) && wea == 1)
		begin
			outBufWriteEn = 1;
			outBufWriteAddr = addra;
			outBufIn = dina;
		end
		else
		begin
			outBufWriteEn = 0;
			outBufWriteAddr = 0;
			outBufIn = 0;
		end
	end
		Scratch_Memory_Controller outBuf_mem(
															.addra(outBufWriteAddr),
															.dina(outBufIn),
															.wea(outBufWriteEn),
															.clk(clock),
															.addrb(outBufAddr),
															.doutb(out)
															);
															
															
															
															
															
															
															
	reg [7:0] sample_count, nextsample_count;
	reg [4:0] state, nextstate;
	reg sample_countLD;
	
	parameter PRE_PROCESS = 5'd0;
	parameter AUTOCORR = 5'd1;
	parameter LAG_WINDOW = 5'd2;
	parameter LEVINSON = 5'd3;
	parameter AZ_LSP = 5'd4;
	parameter QUA_LSP = 5'd5;
	parameter INT_LPC = 5'd6;
	parameter INT_QLPC = 5'd7;
	parameter TL_MATH1 = 5'd8;

	
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
			sample_count = 'd160;
		else if (sample_countLD == 'd1)
		begin
			if (sample_count == 'd239)
				sample_count = 'd160;
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
					outBufWriteAddr = sample_count;
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
					nextstate = PRE_PROCESS;
			end
		endcase
	
	end
					
															
endmodule
