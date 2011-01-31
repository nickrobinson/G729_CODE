`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:30:58 11/22/2010
// Design Name:   LSP_to_Az
// Module Name:   C:/Documents and Settings/Administrator/Desktop/Interpolation_LSP_to_Az/lsp_to_az_tb.v
// Project Name:  Interpolation_LSP_to_Az
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: LSP_to_Az
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module lsp_to_az_tb_v;

	// Inputs
	reg clock;
	reg reset;
	reg start;
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

	// Instantiate the Unit Under Test (UUT)
	LSP_to_Az uut (
		.clock(clock), 
		.reset(reset), 
		.start(start),  
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
	
	reg [31:0] scratch_mem [0:144];
	
	always@(*) begin
		scratch_mem_in = scratch_mem[scratch_mem_read_addr];
   end
	
	always@(posedge clock) begin
	   if (scratch_mem_write_en)
	     scratch_mem[scratch_mem_write_addr] <= scratch_mem_out;
	end
	
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		start = 0;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 1'd1;
		#20;
		reset = 1'd0;
		#10;
		scratch_mem[0] = 32'h0000_778a;
		scratch_mem[1] = 32'h0000_68ac;
		scratch_mem[2] = 32'h0000_528d;
		scratch_mem[3] = 32'h0000_37e8;
		scratch_mem[4] = 32'h0000_1877;
		scratch_mem[5] = 32'hffff_f6e6;
		scratch_mem[6] = 32'hffff_d5a4;
		scratch_mem[7] = 32'hffff_b8ca;
		scratch_mem[8] = 32'hffff_a11a;
		scratch_mem[9] = 32'hffff_8fd0;
		scratch_mem[10] = 32'h0000_1ba8;
     
		// Add stimulus here
		#20;
		start = 1'd1;
		#30;
		start = 1'd0;
	end
      
		initial forever #10 clock = ~clock;
		
endmodule

