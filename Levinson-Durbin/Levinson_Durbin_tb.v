`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:47:41 10/31/2010
// Design Name:   Levinson_Durbin_FSM
// Module Name:   C:/Documents and Settings/Administrator/Desktop/Levinson-Durbin/Levinson-Durbin/Levinson_Durbin_tb_1.v
// Project Name:  Levinson-Durbin
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Levinson_Durbin_FSM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Levinson_Durbin_tb_1_v;

`include "paramList.v"

	// Inputs
	reg clock;
	reg reset;
	reg start;
	
	wire done;
	wire [31:0] scratch_mem_in;
	
	//working regs
	reg [31:0] levinson_in [0:9999];
	reg [15:0] levinson_out_a [0:9999];
	reg [15:0] levinson_out_rc [0:9999];
	//mux0regs
	reg mux0sel;
	reg [11:0] testReadAddr;
	//mux1regs
	reg mux1sel;
	reg [11:0] testWriteAddr;
	//mux2regs
	reg mux2sel;
	reg [31:0] testWriteOut;
	//mux3regs
	reg mux3sel;
	reg testWriteEnable;
	
	integer i,j,k;
	
	Levinson_Durbin_test_top i_Levinson_Durbin_test_top_1(
			.clock(clock),
			.reset(reset),
			.start(start),
			.mux0sel(mux0sel),
			.mux1sel(mux1sel),
			.mux2sel(mux2sel),
			.mux3sel(mux3sel),
			.testWriteAddr(testWriteAddr),
			.testReadAddr(testReadAddr),
			.testWriteOut(testWriteOut),
			.testWriteEnable(testWriteEnable),
			.done(done),
			.scratch_mem_in(scratch_mem_in)
    );

	// Instantiate the Unit Under Test (UUT)
	
		
	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("levinson_in.out", levinson_in);
		$readmemh("levinson_out_a.out", levinson_out_a);
		$readmemh("levinson_out_rc.out", levinson_out_rc);
	end

	
	
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		start = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
      reset = 1;
		#50;
		reset = 0;
		#50;
		for(j=0;j<60;j=j+1)
		begin
			mux0sel = 0;
			mux1sel = 1;
			mux2sel = 1;
			mux3sel = 1;
			
			for(i=0;i<11;i=i+1)
			begin
				#50;
				testWriteAddr = {LAG_WINDOW_R_PRIME[11:4],i[3:0]};
				testWriteOut = levinson_in[j*11+i];
				testWriteEnable = 1;
				#50;
			end
			
			mux1sel = 0;
			mux2sel = 0;
			mux3sel = 0;		

			start = 1;
			#50;
			start = 0;
			wait(done);
			#50;
			
			mux0sel = 1;
			for(i=0;i<11;i=i+1)
			begin
				k = i + 11;
				testReadAddr = {A_T[11:4],k[3:0]};
				@(posedge clock);
				@(posedge clock);
				if (scratch_mem_in != levinson_out_a[11*j+i])
					$display($time, " ERROR: A[%d] = %x, expected = %x", 11*j+i, scratch_mem_in, levinson_out_a[11*j+i]);
				else if (scratch_mem_in == levinson_out_a[11*j+i])
					$display($time, " CORRECT:  A[%d] = %x", 11*j+i, scratch_mem_in);
				@(posedge clock);
			end
			#50;
		end //for j loop
		
	end//always
      
	initial forever #10 clock = ~clock;
endmodule

