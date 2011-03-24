`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:43:59 11/16/2010
// Design Name:   get_lsp_pol
// Module Name:   C:/Documents and Settings/Administrator/Desktop/Interpolation_LSP_to_Az/get_lsp_pol_tb.v
// Project Name:  Interpolation_LSP_to_Az
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: get_lsp_pol
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module get_lsp_pol_tb_v;

	`include "paramList.v"
	// Inputs
	reg clock;
	reg reset;
	reg start;
	reg F_OPT;
	
	wire done;
	wire [31:0] scratch_mem_in;

//Memory Mux regs
	reg mem_Mux4Sel;
	reg mem_Mux1Sel;
	reg mem_Mux2Sel;
	reg mem_Mux3Sel;

	reg [11:0] test_write_addr;

	reg [11:0] test_read_addr;

	reg [31:0] test_write;

	reg test_write_en;
	
	//I/O regs
	//working regs
	reg [32:0] lsp_in [0:4999];
	reg [32:0] f_in [0:4999];
	reg [32:0] f_out [0:9999];
	
	

	integer i,j;

	get_lsp_pol_test_top get_lsp_pol_test_top_1(
		.clock(clock),
		.reset(reset),
		.start(start),
		.F_OPT(F_OPT),
		.mem_Mux1Sel(mem_Mux1Sel),
		.mem_Mux2Sel(mem_Mux2Sel),
		.mem_Mux3Sel(mem_Mux3Sel),
		.mem_Mux4Sel(mem_Mux4Sel),
		.test_write_addr(test_write_addr),
		.test_read_addr(test_read_addr),
		.test_write(test_write),
		.test_write_en(test_write_en),
		.done(done),
		.scratch_mem_in(scratch_mem_in)
	);


												 
												 
	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("get_lsp_pol_lsp_in.out", lsp_in);
		$readmemh("get_lsp_pol_f_in.out", f_in);
		$readmemh("get_lsp_pol_f_out.out", f_out);
	end
	
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		start = 0;
		F_OPT = 0;

		#50
		reset = 1;
		// Wait 50 ns for global reset to finish
		#50;
		reset = 0;
		
		for(j=0;j<60;j=j+1)
		begin
			//TEST1
			mem_Mux1Sel = 0;
			mem_Mux2Sel = 0;
			mem_Mux3Sel = 0;
			mem_Mux4Sel = 0;
			test_read_addr = 0;
			
			for(i=0;i<10;i=i+1)
			begin
				#100;
				mem_Mux1Sel = 1;
				mem_Mux2Sel = 1;
				mem_Mux3Sel = 1;
				test_write_addr = {INT_LPC_LSP_TEMP[11:4],i[3:0]};
				test_write = lsp_in[10*j+i];
				test_write_en = 1;	
				#100;			
			end
			
			for(i=0;i<6;i=i+1)
			begin
				#100;
				mem_Mux1Sel = 1;
				mem_Mux2Sel = 1;
				mem_Mux3Sel = 1;
				test_write_addr = {INT_LPC_F1[11:5],F_OPT,i[3:0]};
				test_write = f_in[10*j+i];
				test_write_en = 1;	
				#100;
			end
			
			mem_Mux1Sel = 0;
			mem_Mux2Sel = 0;
			mem_Mux3Sel = 0;
			mem_Mux4Sel = 0;
	
			#50;		
			start = 1;
			#50;
			start = 0;
			#50;
			// Add stimulus here	
			wait(done);
			mem_Mux4Sel = 1;
			//gamma1 read
			for (i = 0; i<6;i=i+1)
			begin				
					test_read_addr = {INT_LPC_F1[11:5],F_OPT,i[3:0]};
					#50;
					if (scratch_mem_in != f_out[j*6+i])
						$display($time, " ERROR: f[%d] = %x, expected = %x", i, scratch_mem_in, f_out[j*6+i]);
					else if (scratch_mem_in == f_out[j*6+i])
						$display($time, " CORRECT:  f[%d] = %x", i, scratch_mem_in);
					@(posedge clock);
			end	
			
		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule

