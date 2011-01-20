`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:43:55 10/19/2010
// Design Name:   Div_32
// Module Name:   C:/Users/Sean/Documents/MSU Files/Senior Design/Div_32/div_32_tb.v
// Project Name:  Div_32
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Div_32
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module div_32_tb_v;

	// Inputs
	reg clock;
	reg reset;
	reg start;
	reg [31:0] num;
	reg [31:0] denom;
	wire [31:0] subin;
	wire [31:0] L_mult_in;
	wire L_mult_overflow;
	wire [15:0] mult_in;
	wire mult_overflow;
	wire [31:0] L_mac_in;
	wire L_mac_overflow;

	// Outputs
	wire done;
	wire [31:0] out;
	wire [31:0] subouta;
	wire [31:0] suboutb;
	wire [15:0] L_mult_outa;
	wire [15:0] L_mult_outb;
	wire [15:0] mult_outa;
	wire [15:0] mult_outb;
	wire [15:0] L_mac_outa;
	wire [15:0] L_mac_outb;
	wire [31:0] L_mac_outc;

	// Instantiate the Unit Under Test (UUT)
	L_sub i_L_sub_1(.a(subouta),.b(suboutb),.overflow(sub_overflow),.diff(subin));
	
	L_mac i_L_mac_1(.a(L_mac_outa),.b(L_mac_outb),.c(L_mac_outc),.overflow(L_mac_overflow),.out(L_mac_in));
	
	L_mult i_L_mult_1(.a(L_mult_outa),.b(L_mult_outb),.overflow(L_mult_overflow),.product(L_mult_in));
	
	mult i_mult_1(.a(mult_outa),.b(mult_outb),.overflow(mult_overflow),.product(mult_in));
	
	
	
	Div_32 uut (
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.done(done), 
		.num(num), 
		.denom(denom), 
		.out(out), 
		.subouta(subouta), 
		.suboutb(suboutb), 
		.subin(subin), 
		.L_mult_outa(L_mult_outa), 
		.L_mult_outb(L_mult_outb), 
		.L_mult_in(L_mult_in), 
		.L_mult_overflow(L_mult_overflow), 
		.mult_outa(mult_outa), 
		.mult_outb(mult_outb), 
		.mult_in(mult_in), 
		.mult_overflow(mult_overflow), 
		.L_mac_outa(L_mac_outa), 
		.L_mac_outb(L_mac_outb), 
		.L_mac_outc(L_mac_outc), 
		.L_mac_in(L_mac_in), 
		.L_mac_overflow(L_mac_overflow)
	);

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		start = 0;
		num = 0;
		denom = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		reset = 1;
		#50;
		reset = 0;
		#100;
		
		num = 32'h0115_6f98;
		denom = 32'h456f_683c;
		
		#50;
		start = 1;
		#50;
		start = 0;
	end
      
		initial forever #10 clock = ~clock;
endmodule

