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

	
	//working integers
	integer i;
	integer k;
	reg flag1,flag2,flag3;	
	
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
			@(posedge clock) #5;
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
			@(posedge clock) #5;

			for (i = 0; i<80;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				outBufAddr = AUTOCORR_Y+i+'d160;
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Pre_Process_new_speech[i+80*k])
				begin
					$display($time, " ERROR: new_speech[%d] = %x, expected = %x", i+80*k, out, Pre_Process_new_speech[i+80*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
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
			@(posedge clock) #5;

			for (i = 0; i<11;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				outBufAddr = {AUTOCORR_R[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Autocorr_r[i+11*k])
				begin
					$display($time, " ERROR: r[%d] = %x, expected = %x", i+11*k, out, Autocorr_r[i+11*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
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
			@(posedge clock) #5;

			for (i = 0; i<11;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				outBufAddr = {LAG_WINDOW_R_PRIME[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Lag_window_r[i+11*k])
				begin
					$display($time, " ERROR: r[%d] = %x, expected = %x", i+11*k, out, Lag_window_r[i+11*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
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
			@(posedge clock) #5;

			for (i = 0; i<11;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				outBufAddr = {A_T_HIGH[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Levinson_A_t_MP1[i+11*k])
				begin
					$display($time, " ERROR: A_t_MP1[%d] = %x, expected = %x", i+11*k, out, Levinson_A_t_MP1[i+11*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
			end

			@(posedge clock);
			@(posedge clock) #5;

			for (i = 0; i<10;i=i+1)
			begin		
					
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				outBufAddr = {LEVINSON_DURBIN_RC[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Levinson_rc[i+10*k])
				begin
					$display($time, " ERROR: rc[%d] = %x, expected = %x", i+10*k, out, Levinson_rc[i+10*k]);
					flag2 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
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
			@(posedge clock) #5;
			
			for (i = 0; i<10;i=i+1)
			begin		
				outBufAddr = LSP_NEW + i;
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Az_lsp_lsp_new[i+10*k])
				begin
					$display($time, " ERROR: lsp_new[%d] = %x, expected = %x", i+10*k, out, Az_lsp_lsp_new[i+10*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
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
			@(posedge clock) #5;
			
			for (i = 0; i<10;i=i+1)
			begin		
				outBufAddr = LSP_NEW_Q + i;
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Qua_lsp_lsp_new_q[i+10*k])
				begin
					$display($time, " ERROR: lsp_new_q[%d] = %x, expected = %x", i+10*k, out, Qua_lsp_lsp_new_q[i+10*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
			end	
			
			for (i = 0; i<11;i=i+1)
			begin		
				outBufAddr = PRM + i;
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Qua_lsp_ana[i+11*k])
				begin
					$display($time, " ERROR: ana[%d] = %x, expected = %x", i+11*k, out, Qua_lsp_ana[i+11*k]);
					flag2 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
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
			@(posedge clock) #5;

			for (i = 0; i<10;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				outBufAddr = {INTERPOLATION_LSF_INT[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Int_lpc_lsf_int[i+10*k])
				begin
					$display($time, " ERROR: lsf_int[%d] = %x, expected = %x", i+10*k, out, Int_lpc_lsf_int[i+10*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
			end

			@(posedge clock);
			@(posedge clock) #5;

			for (i = 0; i<10;i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				outBufAddr = {INTERPOLATION_LSF_NEW[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Int_lpc_lsf_new[i+10*k])
				begin
					$display($time, " ERROR: lsf_new[%d] = %x, expected = %x", i+10*k, out, Int_lpc_lsf_new[i+10*k]);
					flag2 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
			end

			@(posedge clock);
			@(posedge clock) #5;
			
			for (i = 0; i<11; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				outBufAddr = {A_T_LOW[11:4],i[3:0]};
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Int_lpc_A_t[i+11*k])
				begin
					$display($time, " ERROR: A_t[%d] = %x, expected = %x", i+11*k, out, Int_lpc_A_t[i+11*k]);
					flag3 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
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
			@(posedge clock) #5;

			for (i = 0; i<22; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				if (i < 11)
					outBufAddr = AQ_T_LOW + i;
				else
					outBufAddr = AQ_T_HIGH + (i%11);
				@(posedge clock);
				@(posedge clock) #5;
				if (out != Int_qlpc_Aq_t[i+22*k])
				begin
					$display($time, " ERROR: Aq_t[%d] = %x, expected = %x", i+22*k, out, Int_qlpc_Aq_t[i+22*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
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
			@(posedge clock) #5;
			
			for (i = 0; i<10; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				outBufAddr = LSP_OLD + i;
				@(posedge clock);
				@(posedge clock) #5;
				if (out != TL_Math1_lsp_old[i+10*k])
				begin
					$display($time, " ERROR: lsp_old[%d] = %x, expected = %x", i+10*k, out, TL_Math1_lsp_old[i+10*k]);
					flag1 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
			end
			
			for (i = 0; i<10; i=i+1)
			begin		
				@(posedge clock);
				@(posedge clock);
				@(posedge clock) #5;
				outBufAddr = LSP_OLD_Q + i;
				@(posedge clock);
				@(posedge clock) #5;
				if (out != TL_Math1_lsp_old_q[i+10*k])
				begin
					$display($time, " ERROR: lsp_old_q[%d] = %x, expected = %x", i+10*k, out, TL_Math1_lsp_old_q[i+10*k]);
					flag2 = 1;
				end
				@(posedge clock);
				@(posedge clock) #5;
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
			
					
		end//k for loop
	end//initial 
	
	initial forever #10 clock = ~clock;
      
endmodule

