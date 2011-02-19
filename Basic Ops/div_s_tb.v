`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:24:50 10/17/2010
// Design Name:   div_s
// Module Name:   C:/Users/Sean/Documents/MSU Files/Senior Design/Sean_Levinson-Durbin/div_s_tb.v
// Project Name:  Sean_Levinson-Durbin
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: div_s
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module div_s_tb_v;

	// Inputs
	reg clock;
	reg reset;
	reg [15:0] a;
	reg [15:0] b;
	reg start;
	wire [31:0] subin;

	// Outputs
	wire div_err;
	wire [15:0] out;
	wire done;
	wire [31:0] subouta;
	wire [31:0] suboutb;
	wire [15:0] add_outa;
	wire [15:0] add_outb;
	wire [15:0] add_in;

	// Instantiate the Unit Under Test (UUT)
	div_s uut (
		.clock(clock), 
		.reset(reset), 
		.a(a), 
		.b(b), 
		.div_err(div_err), 
		.out(out), 
		.start(start), 
		.done(done), 
		.subouta(subouta), 
		.suboutb(suboutb), 
		.subin(subin), 
		.add_outa(add_outa),
		.add_outb(add_outb),
		.add_in(add_in)
	);

	L_sub i_L_sub_1(.a(subouta),.b(suboutb),.overflow(sub_overflow),.diff(subin));
	
	add i_add(.a(add_outa),.b(add_outb),.overflow(),.sum(add_in));
	
	reg [15:0] div_s_in [0:9999];
	reg [15:0] div_s_out [0:9999];
	
	initial 
	begin// samples out are samples from ITU G.729 test vectors
		$readmemh("div_s_in.out", div_s_in);
		$readmemh("div_s_out.out", div_s_out);
	end
	
	integer j;
	
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		a = 0;
		b = 0;
		start = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		reset = 1;
		#50;
		reset = 0;
		#100;
		
		for(j=0;j<60;j=j+1)
		begin
		a = 16'h3fff;
		b = div_s_in[j];
		#50;
		
		start = 1;
		#50;
		start = 0;
		
		wait(done)
		if (out != div_s_out[j])
					$display($time, " ERROR: A[%d] = %x, expected = %x", j, out,div_s_out[j]);
		else if (out == div_s_out[j])
					$display($time, " CORRECT:  A[%d] = %x",j,out);
		end
	end
      
		
	initial forever #10 clock = ~clock;
	
endmodule

