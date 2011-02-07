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
	reg LSP_OPT;
	wire [31:0] abs_in;
	wire [31:0] negate_in;
	wire [31:0] L_shr_in;
	wire [31:0] L_sub_in;
	wire [15:0] norm_L_in;
	wire norm_L_done;
	wire [31:0] L_shl_in;
	wire L_shl_done;
	wire [31:0] L_mult_in;
	wire L_mult_overflow;
	wire [31:0] L_mac_in;
	wire L_mac_overflow;
	wire [15:0] mult_in;
	wire mult_overflow;
	wire L_add_overflow;
	wire [31:0] L_add_in;
	wire [15:0] sub_in;
	wire sub_overflow;
	reg [31:0] scratch_mem_in;
	wire add_overflow;
	wire [15:0] add_in;
	wire L_msu_overflow;
	wire [31:0] L_msu_in;

	// Outputs
	wire done;
	wire [31:0] abs_out;
	wire [31:0] negate_out;
	wire [31:0] L_shr_outa;
	wire [15:0] L_shr_outb;
	wire [31:0] L_sub_outa;
	wire [31:0] L_sub_outb;
	wire [31:0] norm_L_out;
	wire norm_L_start;
	wire [31:0] L_shl_outa;
	wire [15:0] L_shl_outb;
	wire L_shl_start;
	wire [15:0] L_mult_outa;
	wire [15:0] L_mult_outb;
	wire [15:0] L_mac_outa;
	wire [15:0] L_mac_outb;
	wire [31:0] L_mac_outc;
	wire [15:0] mult_outa;
	wire [15:0] mult_outb;
	wire [31:0] L_add_outa;
	wire [31:0] L_add_outb;
	wire [15:0] sub_outa;
	wire [15:0] sub_outb;
	wire [6:0] scratch_mem_read_addr;
	wire [6:0] scratch_mem_write_addr;
	wire [31:0] scratch_mem_out;
	wire scratch_mem_write_en;
	wire [15:0] add_outa;
	wire [15:0] add_outb;
	wire [15:0] L_msu_outa;
	wire [15:0] L_msu_outb;
	wire [31:0] L_msu_outc;

//Memory Mux regs
	reg mem_Mux4Sel;
	reg mem_Mux1Sel;
	reg mem_Mux2Sel;
	reg mem_Mux3Sel;
	reg [10:0] mem_Mux4Out;
	reg [10:0] test_write_addr;
	reg [10:0] mem_Mux1Out;
	reg [10:0] test_read_addr;
	reg [31:0] mem_Mux2Out;
	reg [31:0] test_write;
	reg mem_Mux3Out;
	reg test_write_en;
	
	//I/O regs
	//working regs
	reg [15:0] lsp_in [0:4999];
	reg [15:0] f_in [0:4999];
	reg [15:0] f_out [0:9999];
	
	

	integer i,j;
	// Instantiate the Unit Under Test (UUT)
	get_lsp_pol uut (
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.F_OPT(F_OPT), 
		.LSP_OPT(LSP_OPT), 
		.done(done), 
		.abs_in(abs_in), 
		.abs_out(abs_out), 
		.negate_out(negate_out), 
		.negate_in(negate_in), 
		.L_shr_outa(L_shr_outa), 
		.L_shr_outb(L_shr_outb), 
		.L_shr_in(L_shr_in), 
		.L_sub_outa(L_sub_outa), 
		.L_sub_outb(L_sub_outb), 
		.L_sub_in(L_sub_in), 
		.norm_L_out(norm_L_out), 
		.norm_L_in(norm_L_in), 
		.norm_L_start(norm_L_start), 
		.norm_L_done(norm_L_done), 
		.L_shl_outa(L_shl_outa), 
		.L_shl_outb(L_shl_outb), 
		.L_shl_in(L_shl_in), 
		.L_shl_start(L_shl_start), 
		.L_shl_done(L_shl_done), 
		.L_mult_outa(L_mult_outa), 
		.L_mult_outb(L_mult_outb), 
		.L_mult_in(L_mult_in), 
		.L_mult_overflow(L_mult_overflow), 
		.L_mac_outa(L_mac_outa), 
		.L_mac_outb(L_mac_outb), 
		.L_mac_outc(L_mac_outc), 
		.L_mac_in(L_mac_in), 
		.L_mac_overflow(L_mac_overflow), 
		.mult_outa(mult_outa), 
		.mult_outb(mult_outb), 
		.mult_in(mult_in), 
		.mult_overflow(mult_overflow), 
		.L_add_outa(L_add_outa), 
		.L_add_outb(L_add_outb), 
		.L_add_overflow(L_add_overflow), 
		.L_add_in(L_add_in), 
		.sub_outa(sub_outa), 
		.sub_outb(sub_outb), 
		.sub_in(sub_in), 
		.sub_overflow(sub_overflow), 
		.scratch_mem_read_addr(scratch_mem_read_addr), 
		.scratch_mem_write_addr(scratch_mem_write_addr), 
		.scratch_mem_out(scratch_mem_out), 
		.scratch_mem_write_en(scratch_mem_write_en), 
		.scratch_mem_in(scratch_mem_in), 
		.add_outa(add_outa), 
		.add_outb(add_outb), 
		.add_overflow(add_overflow), 
		.add_in(add_in), 
		.L_msu_outa(L_msu_outa), 
		.L_msu_outb(L_msu_outb), 
		.L_msu_outc(L_msu_outc), 
		.L_msu_overflow(L_msu_overflow), 
		.L_msu_in(L_msu_in)
	);


		L_sub i_L_sub_1(.a(L_sub_outa),.b(L_sub_outb),.overflow(sub_overflow),.diff(L_sub_in));
	
		L_mac i_L_mac_1(.a(L_mac_outa),.b(L_mac_outb),.c(L_mac_outc),.overflow(L_mac_overflow),.out(L_mac_in));
		
		L_mult i_L_mult_1(.a(L_mult_outa),.b(L_mult_outb),.overflow(L_mult_overflow),.product(L_mult_in));
		
		mult i_mult_1(.a(mult_outa),.b(mult_outb),.overflow(mult_overflow),.product(mult_in));
		
		L_shl i_L_shl_1(.clk(clock),.reset(reset),.ready(L_shl_start),.overflow(L_shl_overflow),.var1(L_shl_outa),.numShift(L_shl_outb),
								.done(L_shl_done),.out(L_shl_in));
		
		norm_l i_norm_l_1(.var1(norm_L_out),.norm(norm_L_in),.clk(clock),.ready(norm_L_start),.reset(reset),.done(norm_L_done));
		
		L_shr i_L_shr_1(.var1(L_shr_outa),.numShift(L_shr_outb),.out(L_shr_in));
		
		L_negate i_L_negate_1(.var_in(negate_out),.var_out(negate_in));
		
		L_abs i_L_abs_1(.var_in(abs_out),.var_out(abs_in));
		
		L_add i_L_add_1(.a(L_add_outa),.b(L_add_outb),.overflow(L_add_overflow),.sum(L_add_in));
		
		add i_add_1(.a(add_outa),.b(add_outb),.overflow(add_overflow),.sum(add_in));
		
		sub i_sub_1(.a(sub_outa),.b(sub_outb),.overflow(sub_overflow),.diff(sub_in));
		
		L_msu i_L_msu_1(.a(L_msu_outa),.b(L_msu_outb),.c(L_msu_outc),.overflow(L_msu_overflow),.out(L_msu_in));
	
	Scratch_Memory_Controller testMem(
												 .addra(mem_Mux1Out),
												 .dina(mem_Mux2Out),
												 .wea(mem_Mux3Out),
												 .clk(clk),
												 .addrb(mem_Mux4Out),
												 .doutb(scratch_mem_in)
												 );
	
												 
	//mem write address mux
	always @(*)
	begin
		case	(mem_Mux1Sel)	
			'd0 :	mem_Mux1Out = scratch_mem_write_addr;
			'd1:	mem_Mux1Out = test_write_addr;
		endcase
	end
	
	//mem input mux
	always @(*)
	begin
		case	(mem_Mux2Sel)	
			'd0 :	mem_Mux2Out = scratch_mem_out;
			'd1:	mem_Mux1Out = test_write;
		endcase
	end
	
	//mem write enable mux
	always @(*)
	begin
		case	(mem_Mux3Sel)	
			'd0 :	mem_Mux3Out = scratch_mem_write_en;
			'd1:	mem_Mux3Out = test_write_en;
		endcase
	end
	
	//mem read address mux
	always @(*)
	begin
		case	(mem_Mux4Sel)	
			'd0 :	mem_Mux4Out = scratch_mem_read_addr;
			'd1:	mem_Mux4Out = test_read_addr;
		endcase
	end											 
												 
												 
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
		LSP_OPT = 0;

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
				test_write_addr = {INT_LPC_LSP,i[3:0]};
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
				test_write_addr = {INT_LPC_F1,i[3:0]};
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
					test_read_addr = {INT_LPC_F1,i[3:0]};
					@(posedge clk);
					@(posedge clk);
					if (scratch_mem_in != f_out[j*6+i])
						$display($time, " ERROR: f[%d] = %x, expected = %x", i, scratch_mem_in, f_out[j*6+i]);
					else if (scratch_mem_in == f_out[j*6+i])
						$display($time, " CORRECT:  f[%d] = %x", i, scratch_mem_in);
					@(posedge clk);
			end	
			
		end//j for loop
      
	end
      
		initial forever #10 clock = ~clock;
endmodule

