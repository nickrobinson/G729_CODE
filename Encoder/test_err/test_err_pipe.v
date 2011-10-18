`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Mississippi State University
// ECE 4532-4542 Senior Design
// Engineer: Sean Owens
// 
// Create Date:    23:46:34 04/13/2011 
// Module Name:    test_err_pipe 
// Project Name:   ITU G.729 Hardware Implementation
// Target Devices: Virtex 5 - XC5VLX110T
// Tool versions:  Xilinx ISE 12.4
// Description: 
//
// Dependencies:   test_err.v
//				   sub.v
//				   add.v
//				   L_sub.v
//				   Scratch_Memory_Controller.v
//				   Constant_Memory_Controller.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module test_err_pipe(clock,reset,start,done,out,T0,T0_frac,mem_Mux1Sel,mem_Mux2Sel,
					mem_Mux3Sel,mem_Mux4Sel,test_write_addr,test_read_addr,test_write,test_write_en
    );

	input clock,reset,start;
	output done;
	output [15:0] out;
	
	input [15:0] T0,T0_frac;

	input mem_Mux1Sel,mem_Mux2Sel,mem_Mux3Sel,mem_Mux4Sel;
	input [11:0] test_write_addr,test_read_addr;
	input [31:0] test_write;
	input test_write_en;
	reg [11:0] mem_Mux1Out,mem_Mux4Out;
	reg [31:0] mem_Mux2Out;
	reg mem_Mux3Out;

	wire [11:0] scratch_mem_write_addr,scratch_mem_read_addr;
	wire [31:0] scratch_mem_out,scratch_mem_in;
	wire scratch_mem_write_en;
	
	wire [11:0] constant_mem_read_addr;
	wire [31:0] constant_mem_in;
	
	wire [15:0] sub_in,sub_outa,sub_outb,add_in,add_outa,add_outb;
	
	wire [31:0] L_sub_outa,L_sub_outb,L_sub_in;
	
	test_err i_test_err(
						clock,reset,start,done,out,T0,T0_frac,
						add_outa,add_outb,add_in,
						sub_outa,sub_outb,sub_in,
						L_sub_outa,L_sub_outb,L_sub_in,
						scratch_mem_read_addr,scratch_mem_write_addr,
						scratch_mem_in,scratch_mem_out,
						scratch_mem_write_en,
						constant_mem_read_addr,constant_mem_in
					
    );
	 
	 add i_add_1(.a(add_outa),.b(add_outb),.sum(add_in));
	
	 sub i_sub_1(.a(sub_outa),.b(sub_outb),.diff(sub_in));
	 
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
	
	Constant_Memory_Controller test_constant_mem(
												.addra(constant_mem_read_addr),
												.dina('d0),
												.wea(1'd0),
												.clock(clock),
												.douta(constant_mem_in)
	);
endmodule

