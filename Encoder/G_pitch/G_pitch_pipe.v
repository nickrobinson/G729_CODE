`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    22:02:43 04/12/2011 
// Module Name:    G_pitch_pipe 
// Project Name: 	 ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T
// Tool versions:  Xilinx ISE 12.4
// Description: 
//
// Dependencies: 	 G_pitch.v
//						 L_mac.v
//						 L_shl.v
//						 norm_l.v
//						 add.v
//						 sub.v
//						 L_add.v
//						 shr.v
//						 L_sub.v
//						 Scratch_Memory_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module G_pitch_pipe(clock,reset,start,done,out,scratch_mem_in,mem_Mux1Sel,mem_Mux2Sel,
					mem_Mux3Sel,mem_Mux4Sel,test_write_addr,test_read_addr,test_write,test_write_en
    );

	input clock,reset,start;
	output done;
	output [15:0] out;
	output [31:0] scratch_mem_in;

	input mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,mem_Mux4Sel;
	input [11:0] test_write_addr,test_read_addr;
	input [31:0] test_write;
	input test_write_en;
	reg [11:0] mem_Mux1Out,mem_Mux4Out;
	reg [31:0] mem_Mux2Out;
	reg mem_Mux3Out;

	wire [11:0] scratch_mem_write_addr,scratch_mem_read_addr;
	wire [31:0] scratch_mem_out;
	wire scratch_mem_write_en;
	
	wire norm_l_done,L_shl_done;
	wire L_mac_overflow,sub_overflow,add_overflow;
	wire [15:0] norm_l_in,sub_in,add_in;
	wire [31:0] L_shl_in,L_mac_in;
	
	wire norm_l_start,L_shl_start;
	wire [15:0] L_shl_outb,sub_outa,sub_outb,add_outa,add_outb;
	wire [31:0] norm_l_out,L_shl_outa;
	
	wire [15:0] L_mac_outa,L_mac_outb;
	wire [31:0] L_mac_outc;
	
	wire L_add_overflow;
	wire [31:0] L_add_outa,L_add_outb,L_add_in,L_sub_outa,L_sub_outb,L_sub_in;
	
	wire [15:0] shr_outa,shr_outb,shr_in;
	
	G_pitch i_g_pitch(
					clock,reset,start,done,out,
					shr_outa,shr_outb,shr_in,
					L_mac_outa,L_mac_outb,L_mac_outc,L_mac_in,L_mac_overflow,
					norm_l_out,norm_l_in,norm_l_start,norm_l_done,
					L_shl_outa,L_shl_outb,L_shl_start,L_shl_in,L_shl_done,
					sub_outa,sub_outb,sub_in,
					add_outa,add_outb,add_in,
					scratch_mem_read_addr,scratch_mem_write_addr,scratch_mem_in,scratch_mem_out,
					scratch_mem_write_en,
					L_add_outa,L_add_outb,L_add_in,
					L_sub_outa,L_sub_outb,L_sub_in
    );
	 
	L_mac i_L_mac_1(.a(L_mac_outa),.b(L_mac_outb),.c(L_mac_outc),.overflow(L_mac_overflow),.out(L_mac_in)); 
	
	L_shl i_L_shl_1(.clk(clock),.reset(reset),.ready(L_shl_start),.var1(L_shl_outa),.numShift(L_shl_outb),
							.done(L_shl_done),.out(L_shl_in),.overflow(L_shl_overflow));
							
	norm_l i_norm_l_1(.var1(norm_l_out),.norm(norm_l_in),.clk(clock),.ready(norm_l_start),.reset(reset),.done(norm_l_done));
	
	add i_add_1(.a(add_outa),.b(add_outb),.overflow(add_overflow),.sum(add_in));
	
	sub i_sub_1(.a(sub_outa),.b(sub_outb),.overflow(sub_overflow),.diff(sub_in));
	
	L_add i_L_add_1(.a(L_add_outa),.b(L_add_outb),.overflow(L_add_overflow),.sum(L_add_in));
	
	shr i_shr_1(.var1(shr_outa),.var2(shr_outb),.result(shr_in));
	
	L_sub i_L_sub_1(.a(L_sub_outa),.b(L_sub_outb),.overflow(L_sub_overflow),.diff(L_sub_in));


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
	
endmodule
