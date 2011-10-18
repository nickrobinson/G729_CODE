`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:08:31 02/28/2011
// Design Name:   Lsp_get_tdist_pipe
// Module Name:   C:/Users/Cooper/Documents/_SeniorDesign/Lsp_get_tdist/Lsp_get_tdist_test.v
// Project Name:  Lsp_get_tdist
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Lsp_get_tdist_pipe
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Lsp_get_tdist_test;

	// Inputs
	reg clk;
	reg reset;
	reg start;
	reg [11:0] wegt;
	reg [11:0] buff;
	reg [11:0] L_tdist;
	reg [11:0] rbuf;
	reg [11:0] fg_sum;
	reg [11:0] TBwriteAddrScratch;
	reg [31:0] TBwriteDataScratch;
	reg TBwriteEnScratch;
	reg [11:0] TBreadAddrScratch;
	reg writeAddrScratchSel;
	reg writeDataScratchSel;
	reg writeEnScratchSel;
	reg readAddrScratchSel;

	// Outputs
	wire [31:0] dataInScratch;
	wire done;

	// TB Ints
	integer i, j;

	// Instantiate the Unit Under Test (UUT)
	Lsp_get_tdist_pipe _pipe (
		.clk(clk), 
		.reset(reset), 
		.start(start), 
		.wegt(wegt), 
		.buff(buff), 
		.L_tdist(L_tdist), 
		.rbuf(rbuf), 
		.fg_sum(fg_sum),
		.TBwriteAddrScratch(TBwriteAddrScratch),
		.TBwriteDataScratch(TBwriteDataScratch),
		.TBwriteEnScratch(TBwriteEnScratch),
		.TBreadAddrScratch(TBreadAddrScratch),
		.writeAddrScratchSel(writeAddrScratchSel),
	   .writeDataScratchSel(writeDataScratchSel),
	   .writeEnScratchSel(writeEnScratchSel),
		.readAddrScratchSel(readAddrScratchSel),
		.dataInScratch(dataInScratch),
		.done(done)
	);

	//Memory Regs
	reg [31:0] Lsp_get_tdist_in_buf [0:9999];		  
	reg [31:0] Lsp_get_tdist_in_rbuf [0:9999];
	reg [31:0] Lsp_get_tdist_in_wegt [0:9999];
	reg [31:0] Lsp_get_tdist_out_L_tdist [0:9999];
		
	initial 
	begin
		// samples out are samples from ITU G.729 test vectors
		$readmemh("Lsp_get_tdist_in_buf.out", Lsp_get_tdist_in_buf);
		$readmemh("Lsp_get_tdist_in_rbuf.out", Lsp_get_tdist_in_rbuf);
		$readmemh("Lsp_get_tdist_in_wegt.out", Lsp_get_tdist_in_wegt);
		$readmemh("Lsp_get_tdist_out_L_tdist.out", Lsp_get_tdist_out_L_tdist);
   end
	
	initial forever #10 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		start = 0;
		wegt = 'd0;
		buff = 'd16;
		L_tdist = 'd48;
		rbuf = 'd32;
		fg_sum = 'd0;
		TBwriteAddrScratch = 'd0;
		TBwriteDataScratch = 'd0;
		TBwriteEnScratch = 'd0;
		TBreadAddrScratch = 'd0;
		writeAddrScratchSel = 'd1;
		writeDataScratchSel = 'd1;
		writeEnScratchSel = 'd1;
		readAddrScratchSel = 'd1;

		// Wait 100 ns for global reset to finish
		@(posedge clk) #5;
		reset = 1;
		@(posedge clk) #5;
		reset = 0;
        
		// Add stimulus here
		for(j=0;j<256;j=j+1)
		begin
			if(j%2 == 0)
				fg_sum = 'd3778;
			else
				fg_sum = 'd3794;
			@(posedge clk) #5;
			for(i = 0; i < 10; i = i + 1)
			begin
				@(posedge clk) #5;
				TBwriteAddrScratch = {wegt[11:4],i[3:0]};
				TBwriteDataScratch = Lsp_get_tdist_in_wegt[j*10+i];
				TBwriteEnScratch = 1;
				@(posedge clk) #5;
			end
			
			for(i = 0; i < 10; i = i + 1)
			begin
				@(posedge clk) #5;
				TBwriteAddrScratch = {buff[11:4],i[3:0]};
				TBwriteDataScratch = Lsp_get_tdist_in_buf[j*10+i];
				TBwriteEnScratch = 1;
				@(posedge clk) #5;
			end
			
			for(i = 0; i < 10; i = i + 1)
			begin
				@(posedge clk) #5;
				TBwriteAddrScratch = {rbuf[11:4],i[3:0]};
				TBwriteDataScratch = Lsp_get_tdist_in_rbuf[j*10+i];
				TBwriteEnScratch = 1;
				@(posedge clk) #5;
			end
			
			@(posedge clk) #5;
			TBwriteEnScratch = 0;
			
			@(posedge clk) #5;
			start = 1;
			writeAddrScratchSel = 'd0;
			writeDataScratchSel = 'd0;
			writeEnScratchSel = 'd0;
			readAddrScratchSel = 'd0;
			@(posedge clk) #5;
			start = 0;
			
			wait(done);
			
			writeAddrScratchSel = 'd1;
			writeDataScratchSel = 'd1;
			writeEnScratchSel = 'd1;
			readAddrScratchSel = 'd1;
			@(posedge clk) #5;
			TBreadAddrScratch = L_tdist;
			@(posedge clk) #10;
			if (dataInScratch != Lsp_get_tdist_out_L_tdist[j])
				$display($time, " ERROR: y[%d] = %x, expected = %x", j, dataInScratch, Lsp_get_tdist_out_L_tdist[j]);
			else
				$display($time, " CORRECT:  y[%d] = %x", j, dataInScratch);
			@(posedge clk) #5;
		end//j loop
	end
      
endmodule

