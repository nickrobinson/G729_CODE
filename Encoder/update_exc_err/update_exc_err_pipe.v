`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:32:25 04/14/2011 
// Design Name: 
// Module Name:    update_exc_err_pipe 
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
module update_exc_err_pipe(clock,reset,start,mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,mem_Mux4Sel,
							test_write_addr,test_read_addr,test_write,test_write_en,done,
							scratch_mem_in,gain_pit,T0
    );
	 
	`include "constants_param_list.v"
	`include "paramList.v"
	 
	input clock,reset,start;
	input mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,mem_Mux4Sel;
	input [11:0] test_write_addr,test_read_addr;
	input [31:0] test_write;
	input test_write_en;
	
	input [15:0] gain_pit,T0;
	
	output done;
	output [31:0] scratch_mem_in;
	
	wire [11:0] scratch_mem_write_addr,scratch_mem_read_addr;
	wire [31:0] scratch_mem_out;
	wire scratch_mem_write_en;
	
	reg [11:0] mem_Mux1Out,mem_Mux4Out;
	reg [31:0] mem_Mux2Out;
	reg mem_Mux3Out;

	wire [11:0] constant_mem_read_addr;
	wire [31:0] constant_mem_in;
	
	wire L_shl_start,L_shl_done,L_mac_overflow,L_mult_overflow,mult_overflow;
	wire [15:0] sub_outa,sub_outb,sub_in,add_outa,add_outb,add_in;
	
	wire [15:0] L_mac_outa,L_mac_outb,L_msu_outa,L_msu_outb;
	wire [31:0] L_mac_outc,L_msu_outc,L_mac_in,L_msu_in;
	
	wire [15:0] L_shr_outb,L_shl_outb;
	wire [31:0] L_shr_outa,L_shl_outa,L_shl_in,L_shr_in;
	
	wire [15:0] mult_outa,mult_outb,L_mult_outa,L_mult_outb,mult_in;
	wire [31:0] L_mult_in;
	
	wire [31:0] L_add_outa,L_add_outb,L_add_in,L_sub_outa,L_sub_outb,L_sub_in;
	
	update_exc_err i_update_exc_err(
								clock,reset,start,done,gain_pit,T0,
								sub_outa,sub_outb,sub_in,
								L_shl_outa,L_shl_outb,L_shl_in,L_shl_start,L_shl_done,
								L_add_outa,L_add_outb,L_add_in,
								L_sub_outa,L_sub_outb,L_sub_in,
								add_outa,add_outb,add_in,
								L_mac_outa,L_mac_outb,L_mac_outc,L_mac_in,L_mac_overflow,
								L_mult_outa,L_mult_outb,L_mult_in,L_mult_overflow,
								mult_outa,mult_outb,mult_in,mult_overflow,
								L_msu_outa,L_msu_outb,L_msu_outc,L_msu_in,
								L_shr_outa,L_shr_outb,L_shr_in,
								scratch_mem_read_addr,scratch_mem_write_addr,
								scratch_mem_out,scratch_mem_in,
								scratch_mem_write_en,
								constant_mem_read_addr,constant_mem_in
    );
	 
	L_sub i_L_sub_1(.a(L_sub_outa),.b(L_sub_outb),.overflow(L_sub_overflow),.diff(L_sub_in));

	L_mac i_L_mac_1(.a(L_mac_outa),.b(L_mac_outb),.c(L_mac_outc),.overflow(L_mac_overflow),.out(L_mac_in));
	
	L_mult i_L_mult_1(.a(L_mult_outa),.b(L_mult_outb),.overflow(L_mult_overflow),.product(L_mult_in));
	
	mult i_mult_1(.a(mult_outa),.b(mult_outb),.overflow(mult_overflow),.product(mult_in));
	
	L_shl i_L_shl_1(.clk(clock),.reset(reset),.ready(L_shl_start),.var1(L_shl_outa),.numShift(L_shl_outb),
							.done(L_shl_done),.out(L_shl_in));
	
	L_shr i_L_shr_1(.var1(L_shr_outa),.numShift(L_shr_outb),.out(L_shr_in));
	
	L_add i_L_add_1(.a(L_add_outa),.b(L_add_outb),.overflow(L_add_overflow),.sum(L_add_in));
	
	add i_add_1(.a(add_outa),.b(add_outb),.overflow(add_overflow),.sum(add_in));
	
	sub i_sub_1(.a(sub_outa),.b(sub_outb),.overflow(sub_overflow),.diff(sub_in));
	
	L_msu i_L_msu_1(.a(L_msu_outa),.b(L_msu_outb),.c(L_msu_outc),.overflow(L_msu_overflow),.out(L_msu_in));
	
	
	
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
			'd1:	mem_Mux2Out = test_write;
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
	
	Scratch_Memory_Controller test_scratch_mem(
												 .addra(mem_Mux1Out),
												 .dina(mem_Mux2Out),
												 .wea(mem_Mux3Out),
												 .clk(clock),
												 .addrb(mem_Mux4Out),
												 .doutb(scratch_mem_in)
	);
	
	Constant_Memory_Controller test_constant_mem(
												.addra(constant_mem_read_addr),
												.dina('d0),
												.wea(1'd0),
												.clock(clock),
												.douta(constant_mem_in)
	);

endmodule

