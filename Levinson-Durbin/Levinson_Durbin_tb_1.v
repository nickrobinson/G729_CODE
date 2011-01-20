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
	wire [31:0] scratch_mem_in;
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
	wire [31:0] L_add_in;
	wire L_add_overflow;

	// Outputs
	wire [31:0] rc0;
	wire [31:0] a1;
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
	wire [10:0] scratch_mem_write_addr;
	wire [10:0] scratch_mem_read_addr;
	wire [31:0] scratch_mem_out;
	wire [15:0] sub_outa;
	wire [15:0] sub_outb;
	wire sub_overflow;
	wire [15:0] sub_in;
	wire [15:0] add_outa;
	wire [15:0] add_outb;
	wire add_overflow;
	wire [15:0] add_in;
	
	wire scratch_mem_write_en;
	
	//working regs
	reg [31:0] levinson_in [0:10];
	reg [15:0] levinson_out_a [0:10];
	reg [15:0] levinson_out_rc [0:10];
	//mux0regs
	reg mux0sel;
	reg [10:0] mux0out;
	reg [10:0] testReadAddr;
	//mux1regs
	reg mux1sel;
	reg [10:0] mux1out;
	reg [10:0] testWriteAddr;
	//mux2regs
	reg mux2sel;
	reg [31:0] mux2out;
	reg [31:0] testWriteOut;
	//mux3regs
	reg mux3sel;
	reg mux3out;
	reg testWriteEnable;
	
	integer i;

	// Instantiate the Unit Under Test (UUT)
	Levinson_Durbin_FSM levinson (
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
		.sub_overflow(sub_overflow),
		.sub_in(sub_in),
		.scratch_mem_read_addr(scratch_mem_read_addr),
		.scratch_mem_write_addr(scratch_mem_write_addr),
		.scratch_mem_out(scratch_mem_out),
		.scratch_mem_write_en(scratch_mem_write_en),
		.scratch_mem_in(scratch_mem_in),
		.add_outa(add_outa),
		.add_outb(add_outb),
		.add_overflow(add_overflow),
		.add_in(add_in)
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
		
	//file read in for inputs and output tests
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("levinson_in.out", levinson_in);
		$readmemh("levinson_out_a.out", levinson_out_a);
		$readmemh("levinson_out_rc.out", levinson_out_rc);
	end
	
	//Scratch read address	
	always@(*)
	begin
		case(mux0sel)
			'd0:	mux0out = scratch_mem_read_addr;
			'd1:	mux0out = testReadAddr;
		endcase
	end
	
	//Scratch read address	
	always@(*)
	begin
		case(mux1sel)
			'd0:	mux1out = scratch_mem_write_addr;
			'd1:	mux1out = testWriteAddr;
		endcase
	end
	
	//Scratch write output	
	always@(*)
	begin
		case(mux2sel)
			'd0:	mux2out = scratch_mem_out;
			'd1:	mux2out = testWriteOut;
		endcase
	end
	
	//Scratch write enable	
	always@(*)
	begin
		case(mux3sel)
			'd0:	mux3out = scratch_mem_write_en;
			'd1:	mux3out = testWriteEnable;
		endcase
	end
	
	
	Scratch_Memory_Controller Scratch(
												.addra(mux1out),
												.dina(mux2out),
												.wea(mux3out),
												.clk(clock),
												.addrb(mux0out),
												.doutb(scratch_mem_in)
												);
	
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		start = 0;
		mux0sel = 0;
		mux1sel = 1;
		mux2sel = 1;
		mux3sel = 1;
		
		for(i=0;i<11;i=i+1)
		begin
			#50;
			testWriteAddr = {LAG_WINDOW_R_PRIME[10:4],i[3:0]};
			testWriteOut = levinson_in[i];
			testWriteEnable = 1;
			#50;
		end
		
		mux1sel = 0;
		mux2sel = 0;
		mux3sel = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
      reset = 1;
		#50;
		reset = 0;
		#50;

		start = 1;
		#50;
		start = 0;
		wait(done);
		#50;
		
		mux0sel = 1;
		for(i=0;i<11;i=i+1)
		begin
			testReadAddr = {LEVINSON_DURBIN_A[10:4],i[3:0]};
			@(posedge clock);
			@(posedge clock);
			if (scratch_mem_in != levinson_out_a[i])
				$display($time, " ERROR: A[%d] = %x, expected = %x", i, scratch_mem_in, levinson_out_a[i]);
			else if (scratch_mem_in == levinson_out_a[i])
				$display($time, " CORRECT:  A[%d] = %x", i, scratch_mem_in);
			@(posedge clock);
		end
		
		#50;
		
		//TEST2
		$readmemh("levinson_in1.out", levinson_in);
		$readmemh("levinson_out_a1.out", levinson_out_a);
		mux0sel = 0;		
		mux1sel = 1;
		mux2sel = 1;
		mux3sel = 1;
		
		for(i=0;i<11;i=i+1)
		begin
			#50;
			testWriteAddr = {LAG_WINDOW_R_PRIME[10:4],i[3:0]};
			testWriteOut = levinson_in[i];
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
		mux0sel = 1;
		for(i=0;i<11;i=i+1)
		begin
			testReadAddr = {LEVINSON_DURBIN_A[10:4],i[3:0]};
			@(posedge clock);
			@(posedge clock);
			if (scratch_mem_in != levinson_out_a[i])
				$display($time, " ERROR: A[%d] = %x, expected = %x", i, scratch_mem_in, levinson_out_a[i]);
			else if (scratch_mem_in == levinson_out_a[i])
				$display($time, " CORRECT:  A[%d] = %x", i, scratch_mem_in);
			@(posedge clock);
		end
		
	end
      
	initial forever #10 clock = ~clock;
endmodule

