`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:00:47 02/19/2011 
// Design Name: 
// Module Name:    memory_tb 
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
module memory_tb;

	`include "constants_param_list.v"

	// Inputs
	reg clock;
	reg reset;

	integer i,j,k;
	
	wire [31:0] constant_mem_in;
	reg [11:0] testReadAddr;
	reg [31:0] testWriteOut;
	reg testWriteEnable;

	// Instantiate the Unit Under Test (UUT)
	Constant_Memory_Controller constant_mem_controller(
		.addra(testReadAddr),
		.dina(test_Write_Out),
		.wea(testWriteEnable),
		.clock(clock),
		.douta(constant_mem_in));

	
	reg [32:0] lspcb1 [0:1279];
	reg [32:0] lspcb2 [0:319];
	reg [32:0] tab_zone [0:152];
	reg [32:0] fg [0:79];
	reg [32:0] table1 [0:64];
	reg [32:0] tab_hup_l [0:111];
	reg [32:0] grid [0:60];
	reg [32:0] tabpow [0:32];
	reg [32:0] tablog [0:32];
	reg [32:0] tabsqr [0:48];
	reg [32:0] slope [0:63];
	reg [32:0] table2 [0:63];
	reg [32:0] slope_cos [0:63];
	reg [32:0] slope_acos [0:63];
	reg [32:0] freq_prev [0:39];
	reg [32:0] fg_sum [0:19];
	reg [32:0] fg_sum_inv [0:19];
	reg [32:0] inter_3l [0:30];
	reg [32:0] gbk2 [0:31];
	reg [32:0] tab_hup_s [0:27];
	reg [32:0] inter_3 [0:12];
	reg [32:0] gbk1 [0:15];
	reg [32:0] map2 [0:15];
	reg [32:0] imap2 [0:15];
	reg [32:0] bitsno [0:10];
	reg [32:0] map1 [0:7];
	reg [32:0] thr2 [0:7];
	reg [32:0] imap1 [0:7];
	reg [32:0] pred [0:3];
	reg [32:0] coef [0:3];
	reg [32:0] L_coef [0:3];
	reg [32:0] thr1 [0:3];
	reg [32:0] b100 [0:2];
	reg [32:0] a100 [0:2];
	reg [32:0] b140 [0:2];
	reg [32:0] a140 [0:2];
	
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("LSPCB1.out", lspcb1);
		$readmemh("LSPCB2.out", lspcb2);
		$readmemh("TAB_ZONE.out", tab_zone);
		$readmemh("FG.out", fg);
		$readmemh("TABLE1.out", table1);
		$readmemh("TAB_HUP_L.out", tab_hup_l);
		$readmemh("GRID.out", grid);
		$readmemh("TABPOW.out", tabpow);
		$readmemh("TABLOG.out", tablog);
		$readmemh("TABSQR.out", tabsqr);
		$readmemh("SLOPE.out", slope);
		$readmemh("TABLE2.out", table2);
		$readmemh("SLOPE_COS.out", slope_cos);
		$readmemh("SLOPE_ACOS.out", slope_acos);
		$readmemh("FREQ_PREV.out", freq_prev);
		$readmemh("FG_SUM.out", fg_sum);
		$readmemh("FG_SUM_INV.out", fg_sum_inv);
		$readmemh("INTER_3L.out", inter_3l);
		$readmemh("GBK2.out", gbk2);
		$readmemh("TAB_HUP_S.out", tab_hup_s);
		$readmemh("INTER_3.out", inter_3);
		$readmemh("GBK1.out", gbk1);
		$readmemh("MAP2.out", map2);
		$readmemh("IMAP2.out", imap2);
		$readmemh("BITSNO.out", bitsno);
		$readmemh("MAP1.out", map1);
		$readmemh("THR2.out", thr2);
		$readmemh("IMAP1.out", imap1);
		$readmemh("PRED.out", pred);
		$readmemh("COEF.out", coef);
		$readmemh("L_COEF.out", L_coef);
		$readmemh("THR1.out", thr1);
		$readmemh("B100.out", b100);
		$readmemh("A100.out", a100);
		$readmemh("B140.out", b140);
		$readmemh("A140.out", a140);
	end
	
	

	
	
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
      reset = 1;
		#50;
		reset = 0;
		#50;
		$display("LSPCB1");
		for(j=0;j<128;j=j+1)
		begin
			for(i=0;i<10;i=i+1)
			begin
				testReadAddr = {LSPCB1[11],j[6:0],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != lspcb1[10*j+i])
					$display($time, " ERROR: A[%d] = %x, expected = %x", 10*j+i, constant_mem_in, lspcb1[10*j+i]);
				else if (constant_mem_in == lspcb1[10*j+i])
					$display($time, " CORRECT:  A[%d] = %x", 10*j+i, constant_mem_in);
				@(posedge clock);
			end
			#50;
		end //for j loop
		$display("LSPCB2");
		for(j=0;j<32;j=j+1)
		begin
			for(i=0;i<10;i=i+1)
			begin
				testReadAddr = {LSPCB2[11:9],j[4:0],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != lspcb2[10*j+i])
					$display($time, " ERROR: A[%d] = %x, expected = %x", 10*j+i, constant_mem_in, lspcb2[10*j+i]);
				else if (constant_mem_in == lspcb2[10*j+i])
					$display($time, " CORRECT:  A[%d] = %x", 10*j+i, constant_mem_in);
				@(posedge clock);
			end
			#50;
		end //for j loop
		$display("TAB_ZONE");
		for(j=0;j<153;j=j+1)
		begin
				testReadAddr = {TAB_ZONE[11:8],j[7:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != tab_zone[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, tab_zone[j]);
				else if (constant_mem_in == tab_zone[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("FG");
		for(k=0;k<2;k=k+1)
		begin
			for(j=0;j<4;j=j+1)
			begin
				for(i=0;i<10;i=i+1)
				begin
				testReadAddr = {FG[11:7],k[0],j[1:0],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != fg[40*k+10*j+i])
					$display($time, " ERROR: A[%d] = %x, expected = %x", 40*k+10*j+i, constant_mem_in, fg[40*k+10*j+i]);
				else if (constant_mem_in == fg[40*k+10*j+i])
					$display($time, " CORRECT:  A[%d] = %x", 40*k+10*j+i, constant_mem_in);
				@(posedge clock);
				end //for i loop
			#50;
			end //for j loop
		end //for k loop
		$display("TABLE1");
		for(j=0;j<65;j=j+1)
		begin
				testReadAddr = {TABLE1[11:7],j[6:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != table1[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, table1[j]);
				else if (constant_mem_in == table1[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("TAB_HUP_L");
		for(j=0;j<65;j=j+1)
		begin
				testReadAddr = {TAB_HUP_L[11:7],j[6:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != tab_hup_l[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, tab_hup_l[j]);
				else if (constant_mem_in == tab_hup_l[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("GRID");
		for(j=0;j<61;j=j+1)
		begin
				testReadAddr = {GRID[11:6],j[5:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != grid[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, grid[j]);
				else if (constant_mem_in == grid[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("TABPOW");
		for(j=0;j<33;j=j+1)
		begin
				testReadAddr = {TABPOW[11:6],j[5:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != tabpow[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, tabpow[j]);
				else if (constant_mem_in == tabpow[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
      $display("TABLOG");
		for(j=0;j<33;j=j+1)
		begin
				testReadAddr = {TABLOG[11:6],j[5:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != tablog[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, tablog[j]);
				else if (constant_mem_in == tablog[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("TABSQR");
		for(j=0;j<49;j=j+1)
		begin
				testReadAddr = {TABSQR[11:6],j[5:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != tabsqr[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, tabsqr[j]);
				else if (constant_mem_in == tabsqr[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("SLOPE");
		for(j=0;j<64;j=j+1)
		begin
				testReadAddr = {SLOPE[11:6],j[5:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != slope[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, slope[j]);
				else if (constant_mem_in == slope[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("TABLE2");
		for(j=0;j<64;j=j+1)
		begin
				testReadAddr = {TABLE2[11:6],j[5:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != table2[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, table2[j]);
				else if (constant_mem_in == table2[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("SLOPE_COS");
		for(j=0;j<64;j=j+1)
		begin
				testReadAddr = {SLOPE_COS[11:6],j[5:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != slope_cos[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, slope_cos[j]);
				else if (constant_mem_in == slope_cos[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("FREQ_PREV");
		for(j=0;j<10;j=j+1)
		begin
				testReadAddr = {FREQ_PREV[11:4],j[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != freq_prev[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, freq_prev[j]);
				else if (constant_mem_in == freq_prev[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("FG_SUM");
		for(j=0;j<2;j=j+1)
		begin
			for(i=0;i<10;i=i+1)
			begin
				testReadAddr = {FG_SUM[11:5],j[0],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != fg_sum[10*j+i])
					$display($time, " ERROR: A[%d] = %x, expected = %x", 10*j+i, constant_mem_in, fg_sum[10*j+i]);
				else if (constant_mem_in == fg_sum[10*j+i])
					$display($time, " CORRECT:  A[%d] = %x", 10*j+i, constant_mem_in);
				@(posedge clock);
			end //for i loop
			#50;
		end //for j loop
		$display("FG_SUM");
		for(j=0;j<2;j=j+1)
		begin
			for(i=0;i<10;i=i+1)
			begin
				testReadAddr = {FG_SUM_INV[11:5],j[0],i[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != fg_sum_inv[10*j+i])
					$display($time, " ERROR: A[%d] = %x, expected = %x", 10*j+i, constant_mem_in, fg_sum_inv[10*j+i]);
				else if (constant_mem_in == fg_sum_inv[10*j+i])
					$display($time, " CORRECT:  A[%d] = %x", 10*j+i, constant_mem_in);
				@(posedge clock);
			end //for i loop
			#50;
		end //for j loop
		$display("INTER_3L");
		for(j=0;j<31;j=j+1)
		begin
				testReadAddr = {INTER_3L[11:5],j[4:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != inter_3l[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, inter_3l[j]);
				else if (constant_mem_in == inter_3l[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("GBK2");
		for(j=0;j<16;j=j+1)
		begin
			for(i=0;i<2;i=i+1)
			begin
				testReadAddr = {GBK2[11:5],j[3:0],i[0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != gbk2[2*j+i])
					$display($time, " ERROR: A[%d] = %x, expected = %x", 2*j+i, constant_mem_in, gbk2[2*j+i]);
				else if (constant_mem_in == gbk2[2*j+i])
					$display($time, " CORRECT:  A[%d] = %x", 2*j+i, constant_mem_in);
				@(posedge clock);
			end //for i loop
			#50;
		end //for j loop
		$display("TAB_HUP_S");
		for(j=0;j<28;j=j+1)
		begin
				testReadAddr = {TAB_HUP_S[11:5],j[4:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != tab_hup_s[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, tab_hup_s[j]);
				else if (constant_mem_in == tab_hup_s[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("INTER_3");
		for(j=0;j<13;j=j+1)
		begin
				testReadAddr = {INTER_3[11:4],j[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != inter_3[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, inter_3[j]);
				else if (constant_mem_in == inter_3[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("GBK1");
		for(j=0;j<8;j=j+1)
		begin
			for(i=0;i<2;i=i+1)
			begin
				testReadAddr = {GBK1[11:4],j[2:0],i[0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != gbk1[2*j+i])
					$display($time, " ERROR: A[%d] = %x, expected = %x", 2*j+i, constant_mem_in, gbk1[2*j+i]);
				else if (constant_mem_in == gbk1[2*j+i])
					$display($time, " CORRECT:  A[%d] = %x", 2*j+i, constant_mem_in);
				@(posedge clock);
			end //for i loop
			#50;
		end //for j loop
		$display("MAP2");
		for(j=0;j<16;j=j+1)
		begin
				testReadAddr = {MAP2[11:4],j[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != map2[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, map2[j]);
				else if (constant_mem_in == map2[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("IMAP2");
		for(j=0;j<16;j=j+1)
		begin
				testReadAddr = {IMAP2[11:4],j[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != imap2[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, imap2[j]);
				else if (constant_mem_in == imap2[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("IMAP2");
		for(j=0;j<11;j=j+1)
		begin
				testReadAddr = {BITSNO[11:4],j[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != bitsno[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, bitsno[j]);
				else if (constant_mem_in == bitsno[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("MAP1");
		for(j=0;j<8;j=j+1)
		begin
				testReadAddr = {MAP1[11:3],j[2:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != map1[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, map1[j]);
				else if (constant_mem_in == map1[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("THR2");
		for(j=0;j<8;j=j+1)
		begin
				testReadAddr = {THR2[11:3],j[2:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != thr2[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, thr2[j]);
				else if (constant_mem_in == thr2[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("IMAP1");
		for(j=0;j<8;j=j+1)
		begin
				testReadAddr = {IMAP1[11:3],j[2:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != imap1[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, imap1[j]);
				else if (constant_mem_in == imap1[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("PRED");
		for(j=0;j<4;j=j+1)
		begin
				testReadAddr = {PRED[11:2],j[1:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != pred[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, pred[j]);
				else if (constant_mem_in == pred[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("COEF");
		for(j=0;j<2;j=j+1)
		begin
			for(i=0;i<2;i=i+1)
			begin
				testReadAddr = {COEF[11:2],j[0],i[0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != coef[2*j+i])
					$display($time, " ERROR: A[%d] = %x, expected = %x", 2*j+i, constant_mem_in, coef[2*j+i]);
				else if (constant_mem_in == coef[2*j+i])
					$display($time, " CORRECT:  A[%d] = %x", 2*j+i, constant_mem_in);
				@(posedge clock);
			end //for i loop
			#50;
		end //for j loop
		$display("L_COEF");
		for(j=0;j<2;j=j+1)
		begin
			for(i=0;i<2;i=i+1)
			begin
				testReadAddr = {L_COEF[11:2],j[0],i[0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != L_coef[2*j+i])
					$display($time, " ERROR: A[%d] = %x, expected = %x", 2*j+i, constant_mem_in, L_coef[2*j+i]);
				else if (constant_mem_in == L_coef[2*j+i])
					$display($time, " CORRECT:  A[%d] = %x", 2*j+i, constant_mem_in);
				@(posedge clock);
			end //for i loop
			#50;
		end //for j loop
		$display("THR1");
		for(j=0;j<4;j=j+1)
		begin
				testReadAddr = {THR1[11:2],j[1:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != thr1[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, thr1[j]);
				else if (constant_mem_in == thr1[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("B100");
		for(j=0;j<3;j=j+1)
		begin
				testReadAddr = {B100[11:2],j[1:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != b100[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, b100[j]);
				else if (constant_mem_in == b100[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("A100");
		for(j=0;j<3;j=j+1)
		begin
				testReadAddr = {A100[11:2],j[1:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != a100[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, a100[j]);
				else if (constant_mem_in == a100[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("B140");
		for(j=0;j<3;j=j+1)
		begin
				testReadAddr = {B140[11:2],j[1:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != b140[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, b140[j]);
				else if (constant_mem_in == b140[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
		$display("A140");
		for(j=0;j<3;j=j+1)
		begin
				testReadAddr = {A140[11:2],j[1:0]};
				@(posedge clock);
				@(posedge clock);
				if (constant_mem_in != a140[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, constant_mem_in, a140[j]);
				else if (constant_mem_in == a140[j])
					$display($time, " CORRECT:  A[%d] = %x", j, constant_mem_in);
				@(posedge clock);
			#50;
		end //for j loop
	end//always
	initial forever #10 clock = ~clock;
endmodule