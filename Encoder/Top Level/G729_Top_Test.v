`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:41:04 11/26/2010
// Design Name:   G729_Top
// Module Name:   C:/Users/Muaddib/Documents/Zach Office/School MSU/Fall 2010/Senior Design I/G729 Verilog Code/Top_Level/G729_Top_Test.v
// Project Name:  Top_Level
// Target Device:  
// Tool versions:  
// Description: 	This is a top level test to read in the inputs to the encoder, and compare the ouput
//						of the encoder with the C-model outputs
//
// Verilog Test Fixture created by ISE for module: G729_Top
//
// Dependencies: G729_Top.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module G729_Top_Test_v;

	`include "constants_param_list.v"
	`include "paramList.v"
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Top Level Input/Output
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

	// Inputs
	reg clock;
	reg reset;
	reg start;
	reg [15:0] in;
	reg [11:0] outBufAddr;
	reg testdone;
	
	// Outputs	
	wire [31:0] out;
	wire done;
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Working regs
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

	//Input Samples
	reg [15:0] samplesmem [0:10239];
	
	//Pre-Processor
	reg [31:0] Pre_Process_new_speech [0:10239];
	
	//Autocorellation
	reg [31:0] Autocorr_r [0:10239];
	
	//Lag-Window
	reg [31:0] Lag_window_r [0:10239];
	
	//Levinson-Durbin
	reg [31:0] Levinson_A_t_MP1 [0:10239];
	reg [31:0] Levinson_rc [0:10239];
	
	//A(Z) to LSP
	reg [31:0] Az_lsp_lsp_new [0:10239];
	
	//Qua_lsp
	reg [31:0] Qua_lsp_lsp_new_q [0:9999];
	reg [31:0] Qua_lsp_ana [0:9999];

	//Int_lpc
	reg [31:0] Int_lpc_lsf_int [0:4999];
	reg [31:0] Int_lpc_lsf_new [0:4999];
	reg [31:0] Int_lpc_A_t [0:4999];
	
	//Int_qlpc
	reg [31:0] Int_qlpc_Aq_t [0:4999];
	
	//TL_Math1
	reg [31:0] TL_Math1_lsp_old [0:4999];
	reg [31:0] TL_Math1_lsp_old_q [0:4999];

	//perc_var
	reg [31:0] perc_var_gamma1 [0:4999];
	reg [31:0] perc_var_gamma2 [0:4999];
	reg [31:0] perc_var_lsf_int [0:4999];
	reg [31:0] perc_var_lsf_new [0:4999];

	//Weight_Az1
	reg [31:0] Weight_Az1_Ap1 [0:4999];

	//Weight_Az2
	reg [31:0] Weight_Az2_Ap2 [0:4999];

	//Residu1
	reg [31:0] Residu1_wsp [0:4999];

	//Syn_filt1
	reg [31:0] Syn_filt1_wsp [0:4999];
	reg [31:0] Syn_filt1_mem_w [0:4999];

	//Weight_Az3
	reg [31:0] Weight_Az3_Ap1 [0:4999];

	//Weight_Az4
	reg [31:0] Weight_Az4_Ap2 [0:4999];

	//Residu2
	reg [31:0] Residu2_wsp [0:4999];

	//Syn_filt2
	reg [31:0] Syn_filt2_wsp [0:4999];
	reg [31:0] Syn_filt2_mem_w [0:4999];
	
	//Pitch_ol
	reg [31:0] Pitch_ol_T_op [0:4999];
	
	//Weight_Az5
	reg [31:0] Weight_Az5_Ap1 [0:4999];

	//Weight_Az6
	reg [31:0] Weight_Az6_Ap2 [0:4999];

	//TL_Math3
	reg [31:0] TL_Math3_ai_zero [0:4999];

	//Syn_filt3
	reg [31:0] Syn_filt3_h1 [0:4999];
	reg [31:0] Syn_filt3_zero [0:4999];

	//Syn_filt4
	reg [31:0] Syn_filt4_h1 [0:4999];
	reg [31:0] Syn_filt4_zero [0:4999];

	//Residu3
	reg [31:0] Residu3_exc [0:4999];
	
	//Syn_filt5
	reg [31:0] Syn_filt5_error [0:4999];
	reg [31:0] Syn_filt5_mem_err [0:4999];

	//Residu4
	reg [31:0] Residu4_xn [0:4999];
	
	//Syn_filt6
	reg [31:0] Syn_filt6_xn [0:4999];
	reg [31:0] Syn_filt6_mem_w0 [0:4999];

	//Pred_lt_3
	reg [31:0] Pred_lt_3_exc [0:4999];

	//Convolve
	reg [31:0] Convolve_y1 [0:4999];

	//TL_Math4
	reg [31:0] TL_Math4_xn2 [0:4999];

	//ACELP_Codebook
	reg [31:0] ACELP_Codebook_code [0:4999];
	reg [31:0] ACELP_Codebook_y2 [0:4999];

	//Corr_xy2
	reg [31:0] Corr_xy2_g_coeff_cs [0:4999];
	reg [31:0] Corr_xy2_exp_g_coeff_cs [0:4999];

	//TL_Math6
	reg [31:0] TL_Math6_exc [0:4999];

	//update_exc_err
	reg [31:0] update_exc_err_L_exc_err [0:4999];

	//Syn_filt7
	reg [31:0] Syn_filt7_synth [0:4999];
	reg [31:0] Syn_filt7_mem_syn [0:4999];

	//TL_Math7
	reg [31:0] TL_Math7_mem_err [0:4999];
	reg [31:0] TL_Math7_mem_w0 [0:4999];
	
	//working integers
	integer i;
	integer k;
	integer z;
	reg flag1,flag2,flag3,flag4;	
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Input/Output Samples
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

	
	initial
	begin
		//Input Samples
		$readmemh("samples.out", samplesmem);
		
		//Pre-Processor
		$readmemh("filtered.out", Pre_Process_new_speech);
		
		//Autocorellation
		$readmemh("Autocorr_r.out", Autocorr_r);
		
		//Lag-Window
		$readmemh("Lag_window_r.out", Lag_window_r);
		
		//Levinson-Durbin
		$readmemh("Levinson_A_t_MP1.out", Levinson_A_t_MP1);
		$readmemh("Levinson_rc.out", Levinson_rc);
		
		//A(Z) to LSP
		$readmemh("Az_lsp_lsp_new.out", Az_lsp_lsp_new);
	
		//Qua_lsp
		$readmemh("Qua_lsp_lsp_new_q.out", Qua_lsp_lsp_new_q);
		$readmemh("Qua_lsp_ana.out", Qua_lsp_ana);

		//Int_lpc
		$readmemh("Int_lpc_lsf_int.out", Int_lpc_lsf_int);
		$readmemh("Int_lpc_lsf_new.out", Int_lpc_lsf_new);
		$readmemh("Int_lpc_A_t.out", Int_lpc_A_t);
		
		//Int_qlpc
		$readmemh("Int_qlpc_Aq_t.out", Int_qlpc_Aq_t);

		//TL_Math1
		$readmemh("TL_Math1_lsp_old.out", TL_Math1_lsp_old);
		$readmemh("TL_Math1_lsp_old_q.out", TL_Math1_lsp_old_q);

		//perc_var
		$readmemh("perc_var_gamma1.out", perc_var_gamma1);
		$readmemh("perc_var_gamma2.out", perc_var_gamma2);
		$readmemh("perc_var_lsf_int.out", perc_var_lsf_int);
		$readmemh("perc_var_lsf_new.out", perc_var_lsf_new);
		
		//Weight_Az1
		$readmemh("Weight_Az1_Ap1.out", Weight_Az1_Ap1);
		
		//Weight_Az2
		$readmemh("Weight_Az2_Ap2.out", Weight_Az2_Ap2);

		//Residu1
		$readmemh("Residu1_wsp.out", Residu1_wsp);

		//Syn_filt
		$readmemh("Syn_filt1_wsp.out", Syn_filt1_wsp);
		$readmemh("Syn_filt1_mem_w.out", Syn_filt1_mem_w);
		
		//Weight_Az3
		$readmemh("Weight_Az3_Ap1.out", Weight_Az3_Ap1);
		
		//Weight_Az4
		$readmemh("Weight_Az4_Ap2.out", Weight_Az4_Ap2);
		
		//Residu2
		$readmemh("Residu2_wsp.out", Residu2_wsp);

		//Syn_filt2
		$readmemh("Syn_filt2_wsp.out", Syn_filt2_wsp);
		$readmemh("Syn_filt2_mem_w.out", Syn_filt2_mem_w);

		//Pitch_ol
		$readmemh("Pitch_ol_T_op.out", Pitch_ol_T_op);

		//Weight_Az5
		$readmemh("Weight_Az5_Ap1.out", Weight_Az5_Ap1);
		
		//Weight_Az6
		$readmemh("Weight_Az6_Ap2.out", Weight_Az6_Ap2);

		//TL_Math3
		$readmemh("TL_Math3_ai_zero.out", TL_Math3_ai_zero);

		//Syn_filt3
		$readmemh("Syn_filt3_h1.out", Syn_filt3_h1);
		$readmemh("Syn_filt3_zero.out", Syn_filt3_zero);

		//Syn_filt4
		$readmemh("Syn_filt4_h1.out", Syn_filt4_h1);
		$readmemh("Syn_filt4_zero.out", Syn_filt4_zero);
		
		//Residu3
		$readmemh("Residu3_exc.out", Residu3_exc);
		
		//Syn_filt5
		$readmemh("Syn_filt5_error.out", Syn_filt5_error);
		$readmemh("Syn_filt5_mem_err.out", Syn_filt5_mem_err);

		//Residu4
		$readmemh("Residu4_xn.out", Residu4_xn);
		
		//Syn_filt6
		$readmemh("Syn_filt6_xn.out", Syn_filt6_xn);
		$readmemh("Syn_filt6_mem_w0.out", Syn_filt6_mem_w0);

		//Pred_lt_3
		$readmemh("Pred_lt_3_exc.out", Pred_lt_3_exc);

		//Convolve
		$readmemh("Convolve_y1.out", Convolve_y1);

		//TL_Math4
		$readmemh("TL_Math4_xn2.out", TL_Math4_xn2);

		//ACELP_Codebook
		$readmemh("ACELP_Codebook_code.out", ACELP_Codebook_code);
		$readmemh("ACELP_Codebook_y2.out", ACELP_Codebook_y2);

		//Corr_xy2
		$readmemh("Corr_xy2_g_coeff_cs.out", Corr_xy2_g_coeff_cs);
		$readmemh("Corr_xy2_exp_g_coeff_cs.out", Corr_xy2_exp_g_coeff_cs);

		//TL_Math6
		$readmemh("TL_Math6_exc.out", TL_Math6_exc);

		//update_exc_err
		$readmemh("update_exc_err_L_exc_err.out", update_exc_err_L_exc_err);

		//Syn_filt7
		$readmemh("Syn_filt7_synth.out", Syn_filt7_synth);
		$readmemh("Syn_filt7_mem_syn.out", Syn_filt7_mem_syn);

		//TL_Math7
		$readmemh("TL_Math7_mem_err.out", TL_Math7_mem_err);
		$readmemh("TL_Math7_mem_w0.out", TL_Math7_mem_w0);
		
	end	

	// Instantiate the Unit Under Test (UUT)
	G729_Top uut (
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.in(in),
		.outBufAddr(outBufAddr),
		.out(out), 
		.testdone(testdone),
		.done(done)
	);
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Parameters
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

	parameter OLD_SPEECH = 'd0;
	parameter PRM_SIZE = 'd11;
	parameter L_SUBFR = 'd40;
	parameter L_TOTAL = 'd240;
	parameter L_FRAME = 'd80;
	parameter L_NEXT = 'd40;
	parameter L_WINDOW = 'd240;
	parameter PIT_MIN = 'd20;
	parameter PIT_MAX = 'd143;
	parameter L_INTERPOL = 'd11;
	parameter M = 'd10;
	parameter MP1 = M + 'd1;

	parameter NEW_SPEECH = OLD_SPEECH + L_TOTAL - L_FRAME;
	parameter SPEECH = OLD_SPEECH + L_TOTAL - L_FRAME - L_NEXT;                    
	parameter P_WINDOW = OLD_SPEECH + L_TOTAL - L_WINDOW;
	parameter WSP = OLD_WSP + PIT_MAX;
	parameter EXC = OLD_EXC + PIT_MAX + L_INTERPOL;
	parameter ZERO = AI_ZERO + MP1;
	parameter ERROR = MEM_ERR + M;
	
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Begin Test
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
	initial 
	begin
			
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Initialization of Test
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
		clock = 0;
		reset = 0;
		start = 0;
		in = 0;
		testdone = 1;
		outBufAddr = 0;
		flag1 = 0;
		flag2 = 0;
		flag3 = 0;
		flag4 = 0;
		
		#50;
		reset = 1;
		#50;		
		reset = 0;
		#100;			// Wait 100 ns for global reset to finish
					
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Begin Encoder
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
		for(k=0;k<128;k=k+1)
		begin

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Input Samples
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
		
			@(posedge clock);
			@(posedge clock);
			testdone = 1;
			for (i=0;i<80;i=i+1)
				begin
				  @(posedge clock);
				  start = 1;
				  in = samplesmem[i+80*k];
				  @(posedge clock);
				  start = 0;			  
				  #300;
				end			
			
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Pre-Processor
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);

			for (i = 0; i<L_FRAME;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = NEW_SPEECH + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Pre_Process_new_speech[i+L_FRAME*k])
				begin
					$display($time, " ERROR: new_speech[%d] = %x, expected = %x", i+L_FRAME*k, out, Pre_Process_new_speech[i+L_FRAME*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			if (flag1)
				$display($time, "!!!!!Pre_Process Failed: new_speech!!!!!");
			else
				$display($time, "*****Pre_Process Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Autocorellation
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);

			for (i = 0; i<MP1;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = {AUTOCORR_R[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (out != Autocorr_r[i+MP1*k])
				begin
					$display($time, " ERROR: r[%d] = %x, expected = %x", i+MP1*k, out, Autocorr_r[i+MP1*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			if (flag1)
				$display($time, "!!!!!Autocorr Failed: r!!!!!");
			else
				$display($time, "*****Autocorr Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Lag-Window
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);

			for (i = 0; i<MP1;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = {LAG_WINDOW_R_PRIME[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (out != Lag_window_r[i+MP1*k])
				begin
					$display($time, " ERROR: r[%d] = %x, expected = %x", i+MP1*k, out, Lag_window_r[i+MP1*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			if (flag1)
				$display($time, "!!!!!Lag_window Failed: r!!!!!");
			else
				$display($time, "*****Lag_window Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Levinson-Durbin
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			flag2 = 0;
			@(posedge clock);
			@(posedge clock);

			for (i = 0; i<MP1;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = {A_T_HIGH[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (out != Levinson_A_t_MP1[i+MP1*k])
				begin
					$display($time, " ERROR: A_t_MP1[%d] = %x, expected = %x", i+MP1*k, out, Levinson_A_t_MP1[i+MP1*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end

			@(posedge clock);
			@(posedge clock);

			for (i = 0; i<M;i=i+1)
			begin		
					
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = {LEVINSON_DURBIN_RC[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (out != Levinson_rc[i+M*k])
				begin
					$display($time, " ERROR: rc[%d] = %x, expected = %x", i+M*k, out, Levinson_rc[i+M*k]);
					flag2 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end

			if (flag1)
				$display($time, "!!!!!Levinson Failed: A_t_MP1!!!!!");
			if (flag2)
				$display($time, "!!!!!Levinson Failed: rc!!!!!");
			if (!flag1 && !flag2)
				$display($time, "*****Levinson Completed Successfully*****");
			
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		A(Z) to LSP
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<M;i=i+1)
			begin		
				outBufAddr = LSP_NEW + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Az_lsp_lsp_new[i+M*k])
				begin
					$display($time, " ERROR: lsp_new[%d] = %x, expected = %x", i+M*k, out, Az_lsp_lsp_new[i+M*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end	
			
			if (flag1)
				$display($time, "!!!!!Az_lsp Failed: lsp_new!!!!!");
			else
				$display($time, "*****Az_lsp Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Qua_lsp
	//
	//////////////////////////////////////////////////////////////////////////////////////////////

			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			flag2 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<M;i=i+1)
			begin		
				outBufAddr = LSP_NEW_Q + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Qua_lsp_lsp_new_q[i+M*k])
				begin
					$display($time, " ERROR: lsp_new_q[%d] = %x, expected = %x", i+M*k, out, Qua_lsp_lsp_new_q[i+M*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end	
			
			for (i = 0; i<PRM_SIZE;i=i+1)
			begin		
				outBufAddr = PRM + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Qua_lsp_ana[i+PRM_SIZE*k])
				begin
					$display($time, " ERROR: ana[%d] = %x, expected = %x", i+PRM_SIZE*k, out, Qua_lsp_ana[i+PRM_SIZE*k]);
					flag2 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end	
			
			if (flag1)
				$display($time, "!!!!!Qua_lsp Failed: lsp_new_q!!!!!");
			if (flag2)
				$display($time, "!!!!!Qua_lsp Failed: ana!!!!!");
			if (!flag1 && !flag2)
				$display($time, "*****Qua_lsp Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Int_lpc
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			flag2 = 0;
			flag3 = 0;
			@(posedge clock);
			@(posedge clock);

			for (i = 0; i<M;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = {INTERPOLATION_LSF_INT[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (out != Int_lpc_lsf_int[i+M*k])
				begin
					$display($time, " ERROR: lsf_int[%d] = %x, expected = %x", i+M*k, out, Int_lpc_lsf_int[i+M*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end

			@(posedge clock);
			@(posedge clock);

			for (i = 0; i<M;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = {INTERPOLATION_LSF_NEW[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (out != Int_lpc_lsf_new[i+M*k])
				begin
					$display($time, " ERROR: lsf_new[%d] = %x, expected = %x", i+M*k, out, Int_lpc_lsf_new[i+M*k]);
					flag2 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end

			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<MP1; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = {A_T_LOW[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (out != Int_lpc_A_t[i+MP1*k])
				begin
					$display($time, " ERROR: A_t[%d] = %x, expected = %x", i+MP1*k, out, Int_lpc_A_t[i+MP1*k]);
					flag3 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end

			if (flag1)
				$display($time, "!!!!!Int_lpc Failed: lsf_int!!!!!");
			if (flag2)
				$display($time, "!!!!!Int_lpc Failed: lsf_new!!!!!");
			if (flag3)
				$display($time, "!!!!!Int_lpc Failed: A_t!!!!!");
			if (!flag1 && !flag2 && !flag3)
				$display($time, "*****Int_lpc Completed Successfully*****");
			
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Int_qlpc
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);

			for (i = 0; i<(MP1*2); i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				if (i < MP1)
					outBufAddr = AQ_T_LOW + i;
				else
					outBufAddr = AQ_T_HIGH + (i%MP1);
				@(posedge clock);
				@(posedge clock);
				if (out != Int_qlpc_Aq_t[i+(MP1*2)*k])
				begin
					$display($time, " ERROR: Aq_t[%d] = %x, expected = %x", i+(MP1*2)*k, out, Int_qlpc_Aq_t[i+(MP1*2)*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			if (flag1)
				$display($time, "!!!!!Int_qlpc Failed: Aq_t!!!!!");
			else
				$display($time, "*****Int_qlpc Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		TL_Math1
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			flag2 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<M; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = LSP_OLD + i;
				@(posedge clock);
				@(posedge clock);
				if (out != TL_Math1_lsp_old[i+M*k])
				begin
					$display($time, " ERROR: lsp_old[%d] = %x, expected = %x", i+M*k, out, TL_Math1_lsp_old[i+M*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			for (i = 0; i<M; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = LSP_OLD_Q + i;
				@(posedge clock);
				@(posedge clock);
				if (out != TL_Math1_lsp_old_q[i+M*k])
				begin
					$display($time, " ERROR: lsp_old_q[%d] = %x, expected = %x", i+M*k, out, TL_Math1_lsp_old_q[i+M*k]);
					flag2 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			if (flag1)
				$display($time, "!!!!!TL_Math1 Failed: lsp_old!!!!!");
			if (flag2)
				$display($time, "!!!!!TL_Math1 Failed: lsp_old_q!!!!!");
			if (!flag1 && !flag2)
				$display($time, "*****TL_Math1 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		perc_var
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			

			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			flag2 = 0;
			flag3 = 0;
			flag4 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<2; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = PERC_VAR_GAMMA1 + i;
				@(posedge clock);
				@(posedge clock);
				if (out != perc_var_gamma1[i+2*k])
				begin
					$display($time, " ERROR: gamma1[%d] = %x, expected = %x", i+2*k, out, perc_var_gamma1[i+2*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			for (i = 0; i<2; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = PERC_VAR_GAMMA2 + i;
				@(posedge clock);
				@(posedge clock);
				if (out != perc_var_gamma2[i+2*k])
				begin
					$display($time, " ERROR: gamma2[%d] = %x, expected = %x", i+2*k, out, perc_var_gamma2[i+2*k]);
					flag2 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end

			for (i = 0; i<M; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = INTERPOLATION_LSF_INT + i;
				@(posedge clock);
				@(posedge clock);
				if (out != perc_var_lsf_int[i+M*k])
				begin
					$display($time, " ERROR: lsf_int[%d] = %x, expected = %x", i+M*k, out, perc_var_lsf_int[i+M*k]);
					flag3 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end

			for (i = 0; i<M; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = INTERPOLATION_LSF_NEW + i;
				@(posedge clock);
				@(posedge clock);
				if (out != perc_var_lsf_new[i+M*k])
				begin
					$display($time, " ERROR: lsf_new[%d] = %x, expected = %x", i+M*k, out, perc_var_lsf_new[i+M*k]);
					flag4 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			if (flag1)
				$display($time, "!!!!!perc_var Failed: gamma1!!!!!");
			if (flag2)
				$display($time, "!!!!!perc_var Failed: gamma2!!!!!");
			if (flag3)
				$display($time, "!!!!!perc_var Failed: lsf_int!!!!!");
			if (flag4)
				$display($time, "!!!!!perc_var Failed: lsf_new!!!!!");
			if (!flag1 && !flag2 && !flag3 && !flag4)
				$display($time, "*****perc_var Completed Successfully*****");
			
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Weight_Az1
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<MP1;i=i+1)
			begin		
				outBufAddr = WEIGHT_AZ_AP_OUT + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Weight_Az1_Ap1[i+MP1*k])
				begin
					$display($time, " ERROR: Ap1[%d] = %x, expected = %x", i+MP1*k, out, Weight_Az1_Ap1[i+MP1*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end	
			
			if (flag1)
				$display($time, "!!!!!Weight_Az1 Failed: Ap1!!!!!");
			else
				$display($time, "*****Weight_Az1 Completed Successfully*****");
			
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Weight_Az2
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<MP1;i=i+1)
			begin		
				outBufAddr = WEIGHT_AZ_AP_OUT2 + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Weight_Az2_Ap2[i+MP1*k])
				begin
					$display($time, " ERROR: Ap2[%d] = %x, expected = %x", i+MP1*k, out, Weight_Az2_Ap2[i+MP1*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end	
			
			if (flag1)
				$display($time, "!!!!!Weight_Az2 Failed: Ap2!!!!!");
			else
				$display($time, "*****Weight_Az2 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Residu1
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<L_SUBFR;i=i+1)
			begin		
				outBufAddr = WSP + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Residu1_wsp[i+L_SUBFR*k])
				begin
					$display($time, " ERROR: wsp[%d] = %x, expected = %x", i+L_SUBFR*k, out, Residu1_wsp[i+L_SUBFR*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end	
			
			if (flag1)
				$display($time, "!!!!!Residu1 Failed: wsp!!!!!");
			else
				$display($time, "*****Residu1 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Syn_filt1
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			flag2 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<L_SUBFR; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = WSP + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Syn_filt1_wsp[i+L_SUBFR*k])
				begin
					$display($time, " ERROR: wsp[%d] = %x, expected = %x", i+L_SUBFR*k, out, Syn_filt1_wsp[i+L_SUBFR*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			for (i = 0; i<M; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = MEM_W + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Syn_filt1_mem_w[i+M*k])
				begin
					$display($time, " ERROR: mem_w[%d] = %x, expected = %x", i+M*k, out, Syn_filt1_mem_w[i+M*k]);
					flag2 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			if (flag1)
				$display($time, "!!!!!Syn_filt1 Failed: wsp!!!!!");
			if (flag2)
				$display($time, "!!!!!Syn_filt1 Failed: mem_w!!!!!");
			if (!flag1 && !flag2)
				$display($time, "*****Syn_filt1 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Weight_Az3
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<MP1;i=i+1)
			begin		
				outBufAddr = WEIGHT_AZ_AP_OUT + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Weight_Az3_Ap1[i+MP1*k])
				begin
					$display($time, " ERROR: Ap1[%d] = %x, expected = %x", i+MP1*k, out, Weight_Az3_Ap1[i+MP1*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end	
			
			if (flag1)
				$display($time, "!!!!!Weight_Az3 Failed: Ap1!!!!!");
			else
				$display($time, "*****Weight_Az3 Completed Successfully*****");
			
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Weight_Az4
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<MP1;i=i+1)
			begin		
				outBufAddr = WEIGHT_AZ_AP_OUT2 + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Weight_Az4_Ap2[i+MP1*k])
				begin
					$display($time, " ERROR: Ap2[%d] = %x, expected = %x", i+MP1*k, out, Weight_Az4_Ap2[i+MP1*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end	
			
			if (flag1)
				$display($time, "!!!!!Weight_Az4 Failed: Ap2!!!!!");
			else
				$display($time, "*****Weight_Az4 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Residu2
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<L_SUBFR;i=i+1)
			begin		
				outBufAddr = WSP + L_SUBFR + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Residu2_wsp[i+L_SUBFR*k])
				begin
					$display($time, " ERROR: wsp[L_SUBFR+%d] = %x, expected = %x", i+L_SUBFR*k, out, Residu2_wsp[i+L_SUBFR*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end	
			
			if (flag1)
				$display($time, "!!!!!Residu2 Failed: wsp!!!!!");
			else
				$display($time, "*****Residu2 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Syn_filt2
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			flag2 = 0;
			@(posedge clock);
			@(posedge clock);
			
			for (i = 0; i<L_SUBFR; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = WSP + L_SUBFR + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Syn_filt2_wsp[i+L_SUBFR*k])
				begin
					$display($time, " ERROR: wsp[L_SUBFR+%d] = %x, expected = %x", i+L_SUBFR*k, out, Syn_filt2_wsp[i+L_SUBFR*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			for (i = 0; i<M; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock);
				outBufAddr = MEM_W + i;
				@(posedge clock);
				@(posedge clock);
				if (out != Syn_filt2_mem_w[i+M*k])
				begin
					$display($time, " ERROR: mem_w[%d] = %x, expected = %x", i+M*k, out, Syn_filt2_mem_w[i+M*k]);
					flag2 = 1;
				end
				@(posedge clock);
				@(posedge clock);
			end
			
			if (flag1)
				$display($time, "!!!!!Syn_filt2 Failed: wsp!!!!!");
			if (flag2)
				$display($time, "!!!!!Syn_filt2 Failed: mem_w!!!!!");
			if (!flag1 && !flag2)
				$display($time, "*****Syn_filt2 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Pitch_ol
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
			testdone = 1;
			wait(done);
			testdone = 0;
			flag1 = 0;
			@(posedge clock);
			@(posedge clock);
			
			outBufAddr = T_OP;
			@(posedge clock);
			@(posedge clock);
			if (out != Pitch_ol_T_op[k])
			begin
				$display($time, " ERROR: T_op[%d] = %x, expected = %x", k, out, Pitch_ol_T_op[k]);
				flag1 = 1;
			end
			@(posedge clock);
			@(posedge clock);
			
			if (flag1)
				$display($time, "!!!!!Pitch_ol Failed: T_op!!!!!");
			else
				$display($time, "*****Pitch_ol Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		TL_Math2
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
			testdone = 1;
			wait(done);
			testdone = 0;
			@(posedge clock);
			@(posedge clock);
			$display($time, "*****TL_Math2 Completed Successfully*****");

		//////////////////////////////////////////////////////////////////////////////////////////////
		//
		//		Weight_Az5
		//
		//////////////////////////////////////////////////////////////////////////////////////////////
			
			for (z = 0; z < 2; z = z + 1)
			begin

				@(posedge clock);
				@(posedge clock);
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<MP1;i=i+1)
				begin		
					outBufAddr = WEIGHT_AZ_AP_OUT + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Weight_Az5_Ap1[(2*k+z)*MP1+i])
					begin
						$display($time, " ERROR: Ap1[%d] = %x, expected = %x", (2*k+z)*MP1+i, out, Weight_Az5_Ap1[(2*k+z)*MP1+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				if (flag1)
					$display($time, "!!!!!Weight_Az5 Failed: Ap1!!!!!");
				else
					$display($time, "*****Weight_Az5 Completed Successfully*****");
				
		//////////////////////////////////////////////////////////////////////////////////////////////
		//
		//		Weight_Az6
		//
		//////////////////////////////////////////////////////////////////////////////////////////////
		
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<MP1;i=i+1)
				begin		
					outBufAddr = WEIGHT_AZ_AP_OUT2 + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Weight_Az6_Ap2[(2*k+z)*MP1+i])
					begin
						$display($time, " ERROR: Ap2[%d] = %x, expected = %x", (2*k+z)*MP1+i, out, Weight_Az6_Ap2[(2*k+z)*MP1+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				if (flag1)
					$display($time, "!!!!!Weight_Az6 Failed: Ap2!!!!!");
				else
					$display($time, "*****Weight_Az6 Completed Successfully*****");

		//////////////////////////////////////////////////////////////////////////////////////////////
		//
		//		TL_Math3
		//
		//////////////////////////////////////////////////////////////////////////////////////////////
		
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<MP1;i=i+1)
				begin		
					outBufAddr = AI_ZERO + i;
					@(posedge clock);
					@(posedge clock);
					if (out != TL_Math3_ai_zero[(2*k+z)*MP1+i])
					begin
						$display($time, " ERROR: ai_zero[%d] = %x, expected = %x", (2*k+z)*MP1+i, out, TL_Math3_ai_zero[(2*k+z)*MP1+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				if (flag1)
					$display($time, "!!!!!TL_Math3 Failed: ai_zero!!!!!");
				else
					$display($time, "*****TL_Math3 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Syn_filt3
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				flag2 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = H1 + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Syn_filt3_h1[(2*k+z)*L_SUBFR+i])
					begin
						$display($time, " ERROR: h1[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, Syn_filt3_h1[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				for (i = 0; i<M; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = ZERO + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Syn_filt3_zero[(2*k+z)*M+i])
					begin
						$display($time, " ERROR: zero[%d] = %x, expected = %x", (2*k+z)*M+i, out, Syn_filt3_zero[(2*k+z)*M+i]);
						flag2 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				if (flag1)
					$display($time, "!!!!!Syn_filt3 Failed: h1!!!!!");
				if (flag2)
					$display($time, "!!!!!Syn_filt3 Failed: zero!!!!!");
				if (!flag1 && !flag2)
					$display($time, "*****Syn_filt3 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Syn_filt4
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				flag2 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = H1 + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Syn_filt4_h1[(2*k+z)*L_SUBFR+i])
					begin
						$display($time, " ERROR: h1[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, Syn_filt4_h1[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				for (i = 0; i<M; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = ZERO + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Syn_filt4_zero[(2*k+z)*M+i])
					begin
						$display($time, " ERROR: zero[%d] = %x, expected = %x", (2*k+z)*M+i, out, Syn_filt4_zero[(2*k+z)*M+i]);
						flag2 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				if (flag1)
					$display($time, "!!!!!Syn_filt4 Failed: h1!!!!!");
				if (flag2)
					$display($time, "!!!!!Syn_filt4 Failed: zero!!!!!");
				if (!flag1 && !flag2)
					$display($time, "*****Syn_filt4 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Residu3
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR;i=i+1)
				begin
					if (z == 'd0)
						outBufAddr = EXC + i;
					else
						outBufAddr = EXC + L_SUBFR + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Residu3_exc[(2*k+z)*L_SUBFR+i])
					begin
						if (z == 'd0)
							$display($time, " ERROR: exc[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, Residu3_exc[(2*k+z)*L_SUBFR+i]);
						else
							$display($time, " ERROR: exc[L_SUBFR+%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, Residu3_exc[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				if (flag1)
				begin
					if (z == 'd0)
						$display($time, "!!!!!Residu3 Failed: exc!!!!!");
					else
						$display($time, "!!!!!Residu3 Failed: exc[L_SUBFR]!!!!!");
				end
				else
					$display($time, "*****Residu3 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Syn_filt5
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				flag2 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = ERROR + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Syn_filt5_error[(2*k+z)*L_SUBFR+i])
					begin
						$display($time, " ERROR: error[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, Syn_filt5_error[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				for (i = 0; i<M; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = MEM_ERR + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Syn_filt5_mem_err[(2*k+z)*M+i])
					begin
						$display($time, " ERROR: mem_err[%d] = %x, expected = %x", (2*k+z)*M+i, out, Syn_filt5_mem_err[(2*k+z)*M+i]);
						flag2 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				if (flag1)
					$display($time, "!!!!!Syn_filt5 Failed: error!!!!!");
				if (flag2)
					$display($time, "!!!!!Syn_filt5 Failed: mem_err!!!!!");
				if (!flag1 && !flag2)
					$display($time, "*****Syn_filt5 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Residu4
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR;i=i+1)
				begin
					outBufAddr = XN + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Residu4_xn[(2*k+z)*L_SUBFR+i])
					begin
						$display($time, " ERROR: xn[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, Residu4_xn[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				if (flag1)
					$display($time, "!!!!!Residu4 Failed: xn!!!!!");
				else
					$display($time, "*****Residu4 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Syn_filt6
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				flag2 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = XN + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Syn_filt6_xn[(2*k+z)*L_SUBFR+i])
					begin
						$display($time, " ERROR: xn[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, Syn_filt6_xn[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				for (i = 0; i<M; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = MEM_W0 + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Syn_filt6_mem_w0[(2*k+z)*M+i])
					begin
						$display($time, " ERROR: mem_w0[%d] = %x, expected = %x", (2*k+z)*M+i, out, Syn_filt6_mem_w0[(2*k+z)*M+i]);
						flag2 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				if (flag1)
					$display($time, "!!!!!Syn_filt6 Failed: xn!!!!!");
				if (flag2)
					$display($time, "!!!!!Syn_filt6 Failed: mem_w0!!!!!");
				if (!flag1 && !flag2)
					$display($time, "*****Syn_filt6 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Pitch_fr3
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				@(posedge clock);
				@(posedge clock);
				$display($time, "*****Pitch_fr3 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Enc_lag3
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				@(posedge clock);
				@(posedge clock);
				$display($time, "*****Enc_lag3 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Parity_Pitch
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
				
				if (z == 0)
				begin
					testdone = 1;
					wait(done);
					testdone = 0;
					@(posedge clock);
					@(posedge clock);
					$display($time, "*****Parity_Pitch Completed Successfully*****");
				end

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Pred_lt_3
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR;i=i+1)
				begin
					if (z == 'd0)
						outBufAddr = EXC + i;
					else
						outBufAddr = EXC + L_SUBFR + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Pred_lt_3_exc[(2*k+z)*L_SUBFR+i])
					begin
						if (z == 'd0)
							$display($time, " ERROR: exc[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, Pred_lt_3_exc[(2*k+z)*L_SUBFR+i]);
						else
							$display($time, " ERROR: exc[L_SUBFR+%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, Pred_lt_3_exc[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				if (flag1)
				begin
					if (z == 'd0)
						$display($time, "!!!!!Pred_lt_3 Failed: exc!!!!!");
					else
						$display($time, "!!!!!Pred_lt_3 Failed: exc[L_SUBFR]!!!!!");
				end
				else
					$display($time, "*****Pred_lt_3 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Convolve
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR;i=i+1)
				begin
					outBufAddr = Y1 + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Convolve_y1[(2*k+z)*L_SUBFR+i])
					begin
						$display($time, " ERROR: y1[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, Convolve_y1[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				if (flag1)
					$display($time, "!!!!!Convolve Failed: y1!!!!!");
				else
					$display($time, "*****Convolve Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		G_pitch
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				@(posedge clock);
				@(posedge clock);
				$display($time, "*****G_pitch Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		test_err
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				@(posedge clock);
				@(posedge clock);
				$display($time, "*****test_err Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		TL_Math4
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR;i=i+1)
				begin
					outBufAddr = XN2 + i;
					@(posedge clock);
					@(posedge clock);
					if (out != TL_Math4_xn2[(2*k+z)*L_SUBFR+i])
					begin
						$display($time, " ERROR: xn2[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, TL_Math4_xn2[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				if (flag1)
					$display($time, "!!!!!TL_Math4 Failed: xn2!!!!!");
				else
					$display($time, "*****TL_Math4 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		ACELP_Codebook
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR;i=i+1)
				begin
					outBufAddr = CODE + i;
					@(posedge clock);
					@(posedge clock);
					if (out != ACELP_Codebook_code[(2*k+z)*L_SUBFR+i])
					begin
						$display($time, " ERROR: code[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, ACELP_Codebook_code[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				for (i = 0; i<L_SUBFR;i=i+1)
				begin
					outBufAddr = Y2 + i;
					@(posedge clock);
					@(posedge clock);
					if (out != ACELP_Codebook_y2[(2*k+z)*L_SUBFR+i])
					begin
						$display($time, " ERROR: y2[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, ACELP_Codebook_y2[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	

				if (flag1)
					$display($time, "!!!!!ACELP_Codebook Failed: code!!!!!");
				if (flag2)
					$display($time, "!!!!!ACELP_Codebook Failed: y2!!!!!");
				if (!flag1 && !flag2)
					$display($time, "*****ACELP_Codebook Completed Successfully*****");
					
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		TL_Math5
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				@(posedge clock);
				@(posedge clock);
				$display($time, "*****TL_Math5 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Corr_xy2
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<5;i=i+1)
				begin
					outBufAddr = G_COEFF_CS + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Corr_xy2_g_coeff_cs[(2*k+z)*5+i])
					begin
						$display($time, " ERROR: g_coeff_cs[%d] = %x, expected = %x", (2*k+z)*5+i, out, Corr_xy2_g_coeff_cs[(2*k+z)*5+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				for (i = 0; i<5;i=i+1)
				begin
					outBufAddr = EXP_G_COEFF_CS + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Corr_xy2_exp_g_coeff_cs[(2*k+z)*5+i])
					begin
						$display($time, " ERROR: exp_g_coeff_cs[%d] = %x, expected = %x", (2*k+z)*5+i, out, Corr_xy2_exp_g_coeff_cs[(2*k+z)*5+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	

				if (flag1)
					$display($time, "!!!!!Corr_xy2 Failed: g_coeff_cs!!!!!");
				if (flag2)
					$display($time, "!!!!!Corr_xy2 Failed: exp_g_coeff_cs!!!!!");
				if (!flag1 && !flag2)
					$display($time, "*****Corr_xy2 Completed Successfully*****");
				
	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Qua_gain
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				@(posedge clock);
				@(posedge clock);
				$display($time, "*****Qua_gain Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		TL_Math6
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR;i=i+1)
				begin
					outBufAddr = EXC + (z * L_SUBFR) + i;
					@(posedge clock);
					@(posedge clock);
					if (out != TL_Math6_exc[(2*k+z)*L_SUBFR+i])
					begin
						$display($time, " ERROR: exc[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, TL_Math6_exc[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				if (flag1)
					$display($time, "!!!!!TL_Math6 Failed: exc!!!!!");
				else
					$display($time, "*****TL_Math6 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		update_exc_err
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
	
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<4;i=i+1)
				begin
					outBufAddr = L_EXC_ERR + i;
					@(posedge clock);
					@(posedge clock);
					if (out != update_exc_err_L_exc_err[(2*k+z)*4+i])
					begin
						$display($time, " ERROR: L_exc_err[%d] = %x, expected = %x", (2*k+z)*4+i, out, update_exc_err_L_exc_err[(2*k+z)*4+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end	
				
				if (flag1)
					$display($time, "!!!!!update_exc_err Failed: L_exc_err!!!!!");
				else
					$display($time, "*****update_exc_err Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		Syn_filt7
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				flag2 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<L_SUBFR; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = SYN + (z * L_SUBFR) + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Syn_filt7_synth[(2*k+z)*L_SUBFR+i])
					begin
						$display($time, " ERROR: synth[%d] = %x, expected = %x", (2*k+z)*L_SUBFR+i, out, Syn_filt7_synth[(2*k+z)*L_SUBFR+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				for (i = 0; i<M; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = MEM_SYN + i;
					@(posedge clock);
					@(posedge clock);
					if (out != Syn_filt7_mem_syn[(2*k+z)*M+i])
					begin
						$display($time, " ERROR: mem_syn[%d] = %x, expected = %x", (2*k+z)*M+i, out, Syn_filt7_mem_syn[(2*k+z)*M+i]);
						flag2 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				if (flag1)
					$display($time, "!!!!!Syn_filt7 Failed: synth!!!!!");
				if (flag2)
					$display($time, "!!!!!Syn_filt7 Failed: mem_syn!!!!!");
				if (!flag1 && !flag2)
					$display($time, "*****Syn_filt7 Completed Successfully*****");

	//////////////////////////////////////////////////////////////////////////////////////////////
	//
	//		TL_Math7
	//
	//////////////////////////////////////////////////////////////////////////////////////////////
			
				testdone = 1;
				wait(done);
				testdone = 0;
				flag1 = 0;
				flag2 = 0;
				@(posedge clock);
				@(posedge clock);
				
				for (i = 0; i<M; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = MEM_ERR + i;
					@(posedge clock);
					@(posedge clock);
					if (out != TL_Math7_mem_err[(2*k+z)*M+i])
					begin
						$display($time, " ERROR: mem_err[%d] = %x, expected = %x", (2*k+z)*M+i, out, TL_Math7_mem_err[(2*k+z)*M+i]);
						flag1 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				for (i = 0; i<M; i=i+1)
				begin		
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					outBufAddr = MEM_W0 + i;
					@(posedge clock);
					@(posedge clock);
					if (out != TL_Math7_mem_w0[(2*k+z)*M+i])
					begin
						$display($time, " ERROR: mem_w0[%d] = %x, expected = %x", (2*k+z)*M+i, out, TL_Math7_mem_w0[(2*k+z)*M+i]);
						flag2 = 1;
					end
					@(posedge clock);
					@(posedge clock);
				end
				
				if (flag1)
					$display($time, "!!!!!TL_Math7 Failed: mem_err!!!!!");
				if (flag2)
					$display($time, "!!!!!TL_Math7 Failed: mem_w0!!!!!");
				if (!flag1 && !flag2)
					$display($time, "*****TL_Math7 Completed Successfully*****");

			end//z for loop
		end//k for loop
	end//initial 
	
	initial forever #10 clock = ~clock;
      
endmodule

